"
I represent the Squeak interface to a sensor board connected via a serial port. One such board, the Scratch Board, has 8 10-bit sensor inputs capable of reading switches or resistive sensors. Another alternative, the GoGoBoard, has 8 10-bit sensors inputs plus three motor control ports. See http://learning.media.mit.edu/projects/gogo/ for additional info about the GoGo board.

To create an instance of me:

	SensorBoardMorph open

(Note: You can only have one instance of me for each serial port that has a Scratch or GoGo board attached.)

Use the menu to choose the serial port. When you're done, you can use the menu to close the serial port.


------------------------------------------------------
Scratch Sensor Board Serial Protocol

When the sensor board is powered up or reset, it immediately begins sending
sensor data. Sensor data is sent as two byte messages, one message for each
of the available sensors. The first byte supplies the sensor number and the
high 3 bits of the sensor value. The second byte supplies the low 7 bits
of the sensor value. The values of all the available sensors are sent in
this format, followed by a pause of two full byte transmission times, then
the entire cycle repeats. The pause allows the receiver's UART to regain
synchronization in the rare event that it is lost.

Here is the byte format for the two bytes:

  Byte1: <1><sensor number (4 bits)><sensor value high bits (3 bits)>
  Byte2: <0><sensor value low bits (7 bits)>

Note that the most significant bit is one for the first byte of a pair
and zero for the second. This allows the receiver to tell if a given
byte is the first or second byte of a message.

Sensor board have various numbers of sensors. A given board with N sensors
will cycle through sensors numbers 0 through N-1, then repeat. For example,
a four-sensor board would send data for sensors 0 through 3. Up to sixteen
sensors can be handled by this protocol.

Sensor values should be normalized to fit a 10-bit, unsigned integer range.
That is, sensor values should range from 0 to ~1023. For example, if a given
sensor board only collects 8-bit values, these values should be shifted left
by two bits so that the maximum value is 1020. Likewise, a board that reads
over 10-bits of sensor resolution should shift its sensor values right so
that only the 10 most-significant bits of the data are sent.

The serial port should be set to 38.4 kbaud, one start bit, one stop bit,
and no parity.
------------------------------------------------------


"
Class {
	#name : #SensorBoardMorph,
	#superclass : #Morph,
	#instVars : [
		'column',
		'titleMorph',
		'portName',
		'port',
		'readouts',
		'sensorValues',
		'currentState',
		'highByte',
		'useGoGoProtocol',
		'scratchBoardV3',
		'reportRaw',
		'scanPorts',
		'scanState',
		'scanStartMSecs',
		'lastPollMSecs'
	],
	#category : #'Phratch-UI-Panes'
}

{ #category : #initialization }
SensorBoardMorph >> addReadoutLabeled: aString [
	"Add a readout row with the given label. Answer the stringmorph that's the readout."

	| row box readout |
	row := AlignmentMorph newRow color: column color; inset: 2.
	row addMorphBack: (Morph new color: column color; extent: 1@3). "spacer"
	row addMorphBack: (PhratchStringMorph contents: aString capitalized font: (StrikeFont fontName: 'VerdanaBold' size: 10)).
	row addMorphBack: (AlignmentMorph new color: column color; extent: 10@1; hResizing: #spaceFill).  "spacer"
	box := WatcherReadoutFrameMorph new
		extent: 42@14;
		color: (ScriptableScratchMorph blockColorFor: 'sensing').
	readout := PhratchStringMorph contents: '0' font: (StrikeFont fontName: 'VerdanaBold' size: 10).
	readout color: Color white.
	box addMorph: readout.
	row addMorphBack: box.
	column addMorphBack: row.
	^ readout

]

{ #category : #initialization }
SensorBoardMorph >> addReadouts [

	| readoutNames |
	readoutNames := #(
		slider
		light
		sound
		button
		A
		B
		C
		D
	).

	column := AlignmentMorph newColumn
		centering: #center;
		cellPositioning: #topCenter;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		color: (Color r: (193/255) g: (196/255) b: (199/255));
		borderWidth: 2;
		borderColor: (Color r: (148/255) g: (145/255) b: (145/255));
		useRoundedCorners;
		inset: 3.

	titleMorph := PhratchStringMorph
		contents: ''
		font: (StrikeFont fontName: 'VerdanaBold' size: 10).
	column addMorph: titleMorph.
	self updateTitle.
	column addMorphBack: (Morph new color: column color; extent: 5@3).  "spacer"

	self removeAllMorphs.
	readouts := readoutNames collect: [:i |
		(i size = 1)
			ifTrue:[self addReadoutLabeled: i]
			ifFalse:[self addReadoutLabeled: i localized]].
	column position: self position - 2.
	self addMorph: column.
	self extent: column extent - 4.


]

{ #category : #'serial port' }
SensorBoardMorph >> closePort [

	port ifNotNil: [
		port flushInputBuffer.
		port close].

	port := nil.
	currentState := #idle.
	sensorValues atAllPut: 0.
	scratchBoardV3 := false.
	1 to: 8 do: [:i | (readouts at: i) contents: '0'].
	scanState := #off.
	self step.

]

{ #category : #'motor ops' }
SensorBoardMorph >> coastToStopMotor: motorNum [
	"Let the given motor coast to a stop."

	self portIsOpen ifFalse: [^ self].
	self selectMotor: motorNum.
	port nextPutAll: #(84 254 84) asByteArray.

]

{ #category : #'object i/o' }
SensorBoardMorph >> fieldsVersion [

	^ 1

]

{ #category : #'event handling' }
SensorBoardMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #'object i/o' }
SensorBoardMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	anObjStream nextField.  "skip old portNum field"
	self addReadouts.

]

{ #category : #initialization }
SensorBoardMorph >> initialize [

	super initialize.
	sensorValues := Array new: 16 withAll: 0.
	currentState := #idle.
	highByte := 0.
	useGoGoProtocol ifNil: [useGoGoProtocol := false].
	scratchBoardV3 := false.
	reportRaw := false.
	scanState := #off.
	self addReadouts.

]

{ #category : #accessing }
SensorBoardMorph >> isScriptable [
	"I am not scriptable."

	^ false

]

{ #category : #'dropping/grabbing' }
SensorBoardMorph >> justDroppedInto: newOwner event: evt [
	"Only allow embedding into the stage; otherwise, float (i.e. be a submorph of the world)."

	(newOwner isKindOf: ScratchStageMorph) ifFalse: [ "only embed in the work pane"
		self world addMorph: self].


]

{ #category : #'event handling' }
SensorBoardMorph >> mouseDown: evt [

	evt rightButtonPressed | evt shiftPressed
		ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu].

	evt hand toolType = 'CutTool' ifTrue: [
		evt shiftPressed ifFalse: [evt hand toolType: nil].
		ScratchFrameMorph putInClipboard: self.
		^ self delete].

	evt hand waitForClicksOrDrag: self event: evt.

]

{ #category : #'event handling' }
SensorBoardMorph >> mouseHold: evt [

	self rightButtonMenu.

]

{ #category : #'serial port' }
SensorBoardMorph >> openPort: aString [
	"Close the serial port if it is open, then open the port with the given name and initialize streaming of sensor data. Answer true if the operation was successful."

	| baudRate portNum numStart |

	baudRate := useGoGoProtocol ifTrue: [9600] ifFalse: [38400].
	self closePort.
	portName := aString.
	ScratchPlugin serialPortOpsAvailable
		ifTrue: [
			port := SerialPort2 new openPortNamed: portName baud: baudRate.
			port isOpen ifFalse: [port := nil. ^ false].
			port setOption: 20 to: 1.  "set DTR high"
			port setOption: 21 to: 0]  "set RTS low"
		ifFalse: [
			portNum := 1.
			numStart := (1 to: portName size) detect: [:i | (portName at: i) isDigit] ifNone: [0].
			numStart > 0 ifTrue: [portNum := (portName copyFrom: numStart to: portName size) asNumber].
			port := SerialPort new
				baudRate: baudRate;
				inputFlowControlType: 2;
				openPort: portNum ifFail: [^ false]].

	"initialize polling state"
	lastPollMSecs := Time millisecondClockValue.

	^ true

]

{ #category : #private }
SensorBoardMorph >> ping [
	"Answer true if a GoGoBoard is connected to my serial port."

	| buf |
	port flushInputBuffer.
	port nextPutAll: #(84 254 0) asByteArray.
	buf := port next: 3.
	^ buf = #(85 255 170) asByteArray

]

{ #category : #'serial port' }
SensorBoardMorph >> portIsOpen [

	^ port notNil and: [port isOpen]

]

{ #category : #'serial port' }
SensorBoardMorph >> portNames [
	"Answer a collection of possible port names for the Scratch sensor board. Filter out modems and PDA cradles."

	ScratchPlugin serialPortOpsAvailable ifFalse: [
		^ (1 to: 32) collect: [:i | 'COM', i printString]].

	^ SerialPort2 portNames reject: [:n |
		(n asLowercase includesSubstring: 'modem') or:
		[n asLowercase includesSubstring: 'pda-sync']].

]

{ #category : #'event handling' }
SensorBoardMorph >> preemptsMouseDown: evt [

	^ true

]

{ #category : #'sensor ops' }
SensorBoardMorph >> privateSensor: sensorIndex [
	"Read the virtual sensor with the given index permuted according to which Scratch board is plugged in and scaled if it is a known special sensor such as the light or sound sensor. If reportRaw is true then the raw sensor value (0..1023) is reported."
	"This method does not call processIncomingData. It should only be used by the step method."

	| i raw |
	"map the sensor index to the corresponding channel"
	i := (sensorIndex asInteger max: 1) min: 8.
	useGoGoProtocol ifFalse: [
		scratchBoardV3
			ifTrue: [i := #(8 6 7 4 5 3 2 1) at: i] 
			ifFalse: [i := #(5 6 7 8 1 2 3 4) at: i]].

	raw := sensorValues at: i.
	reportRaw ifTrue: [^ raw].
	scratchBoardV3 ifTrue: [
		i = 6 ifTrue: [^ self scaleLight: raw].
		i = 7 ifTrue: [^ self scaleSound: raw]].
	raw > 1020 ifTrue: [raw := 1023].  "avoids jitter in the range 1021-1023"
	^ (100.0 * raw) / 1023.0  

]

{ #category : #private }
SensorBoardMorph >> processGoGoByte: aByte [
	"Process one byte of the incoming data stream from a GoGoBoard."
	"Details: This code recognizes three-byte sensor update messages starting with 16r0C using a simple, three-state finite state machine. We assume that sensor updates are always contiguous--that is, replies to motor or other GoGo board commands will not be inserted between the bytes of any given three-byte sensor update message. The sensor number is the top three bits of the byte two. The data value is the bottom two bits of byte two plus all eight bits of byte three."

	| sensorNum val |
	currentState = #idle ifTrue: [ 
		aByte = 16r0C ifTrue: [currentState := #startByteSeen].
		^ self].

	currentState = #startByteSeen ifTrue: [
		highByte := aByte.
		currentState := #highByteSeen.
		^ self].

	currentState = #highByteSeen ifTrue: [
		"final byte of message: report the sensor value"
		sensorNum := (highByte bitShift: -5) + 1.
		val := ((highByte bitAnd: 3) bitShift: 8) + aByte.
		(sensorNum between: 1 and: 8) ifTrue: [
			sensorValues at: sensorNum put: val].
		currentState := #idle].

]

{ #category : #private }
SensorBoardMorph >> processIncomingData [
	"Process incoming bytes from the serial port."
	"Details: To work around a problem with the Prolific USB-Serial drivers on some Windows machines, a strict turn-taking polling protocol is used. A poll byte is sent, the ScratchBoard sends a response, and after a small delay (to be sure that all the data from the last poll has arrived, another poll is sent. The goal is to never allow more that few bytes to accumulate in the serial input buffer and to avoid sending a poll byte while data is arriving. However, since different versions of the ScratchBoard may send different amounts of data, we don't want to hard-code the number of reply bytes. Thus"

	| buf msecsSinceLastPoll |
	(self portIsOpen and: [#on = scanState]) ifFalse: [^ self].

	useGoGoProtocol ifTrue: [
		buf := port readByteArray.
		buf do: [:b | self processGoGoByte: b].
		^ self].

	msecsSinceLastPoll := Time millisecondClockValue - lastPollMSecs.
	msecsSinceLastPoll < 20 ifTrue: [^ self].

	buf := port readByteArray.
	buf do: [:b | self processScratchByte: b].

	port nextPut: 1.	"send a ScratchBoard V4 poll byte"
	lastPollMSecs := Time millisecondClockValue.


]

{ #category : #private }
SensorBoardMorph >> processScratchByte: aByte [
	"Process one byte of the incoming data stream from a Scratch sensor board."
	"Sensor messages are two bytes with the following format:
		Byte1: <1><sensor number (4 bits)><sensor value high bits (3 bits)>
		Byte2: <0><sensor value low bits (7 bits)>"

	| sensorNum val |
	currentState = #idle ifTrue: [  "wait for first byte of message"
		(aByte bitAnd: 16r80) > 0 ifTrue: [
			currentState := #firstByteSeen.
			highByte := aByte].
		^ self].

	currentState = #firstByteSeen ifTrue: [
		(aByte bitAnd: 16r80) > 0 ifTrue: [  "must have lost second byte; stay in firstByteSeen state"
			highByte := aByte.
			^ self].

		"good second byte: report the sensor value"
		sensorNum := ((highByte bitShift: -3) bitAnd: 16rF) + 1.
		val := ((highByte bitAnd: 7) bitShift: 7) + (aByte bitAnd: 16r7F).
		sensorNum <= sensorValues size ifTrue: [
			sensorValues at: sensorNum put: val.
			sensorNum = 16 ifTrue: [
				(val == 3) | (val == 4) ifTrue: [
					scratchBoardV3 := true]]].  "ScratchBoard, version 3 or 4"

		currentState := #idle].

]

{ #category : #'serial port' }
SensorBoardMorph >> resetPort [
	"If the port is closed, do nothing. If it is open, close and reopen it. This can be used to reset the Prolific USB serial driver if it misbehaves."

	self portIsOpen ifFalse: [^ self].
	portName ifNil: [^ self].
	self closePort.
	self openPort: portName.
	scanState := #on.
	self step.

]

{ #category : #'motor ops' }
SensorBoardMorph >> reverseMotor: motorNum [
	"Reverse the direction of the given motor."

	self portIsOpen ifFalse: [^ self].
	self selectMotor: motorNum.
	port nextPutAll: #(84 254 72) asByteArray.

]

{ #category : #'event handling' }
SensorBoardMorph >> rightButtonMenu [

	| menu |
	menu := MenuMorph new defaultTarget: self.
	Sensor shiftPressed
		ifTrue: [
			reportRaw
				ifTrue: [menu add: 'stop reporting raw data' action: #toggleRawMode]
				ifFalse: [menu add: 'report raw data' action: #toggleRawMode].
			useGoGoProtocol
				ifTrue: [menu add: 'use Scratch board' action: #useScratchboardProtocol]
				ifFalse: [menu add: 'use GoGo board' action: #useGoGoProtocol]]
		ifFalse: [
			menu add: 'select serial/USB port' action: #selectPort.
			self portIsOpen
				ifTrue: [menu add: 'close port' action: #stopReadingData].
			menu addLine.
			menu add: 'hide' action: #delete].

	menu localize; popUpInWorld.

]

{ #category : #'dropping/grabbing' }
SensorBoardMorph >> rootForGrabOf: aMorph [
	"Allow myself to be extracted."

	(owner notNil and: [owner isPartsBin])
		ifTrue: [^ super rootForGrabOf: aMorph]
		ifFalse: [^ self].

]

{ #category : #private }
SensorBoardMorph >> scaleLight: val [

	val <= 25 ifTrue: [^ 100 - val].
	^ ((1023 - val) * (75.0 / 998)) rounded

]

{ #category : #private }
SensorBoardMorph >> scaleSound: val [

	| n |
	n := ((val - 18) max: 0) min: 630.
	n < 50 ifTrue: [^ n / 2.0].  "0 to 25"
	^ 25.0 + ((n - 50) * (75.0 / 580.0))


]

{ #category : #'serial port' }
SensorBoardMorph >> scanForPort [
	"Try to find the serial port that the sensor board is attached to. This is incremental--each time it is called it does the next task."
	"Details: scanState is one of: #(off, start, checkData, on). scanPorts is a list of port names to try. Attempt to open each port in turn, then wait for a while and see if Scratch Sensor data of the right form has arrived."

	| msecs buf i |
	#off = scanState ifTrue: [self scanNextPort].

	#on = scanState ifTrue: [  "if port is open, close it and start a new scan"
		scanPorts := nil.
		self scanNextPort].

	#start = scanState ifTrue: [
		(scanPorts isNil or: [scanPorts size = 0]) ifTrue: [
			scanPorts := self portNames asOrderedCollection].
		scanPorts size = 0 ifTrue: [^ self scanNextPort].
		self openPort: scanPorts removeFirst.
		self portIsOpen ifFalse: [^ self].
		scanState := #checkData.
		scanStartMSecs := Time millisecondClockValue.
		^ self].

	#checkData = scanState ifTrue: [
		msecs := Time millisecondClockValue - scanStartMSecs.
		(self portIsOpen not or: [msecs > 4000]) ifTrue: [^ self scanNextPort].
		port nextPut: 1.  "send poll byte"
		((buf := port readByteArray) size < 10) ifTrue: [^ self].  "no data yet"

		"check that the data is in Scratch Sensor Board format"
		i := (buf first bitAnd: 128) > 0 ifTrue: [1] ifFalse: [2].
		[i < (buf size - 1)] whileTrue: [
			(((buf at: i) bitAnd: 128) > 0 and:
			 [((buf at: i + 1) bitAnd: 128) = 0]) ifFalse: [^ self scanNextPort].
			i := i + 2].

		scanState := #on].

]

{ #category : #'serial port' }
SensorBoardMorph >> scanNextPort [
	"Called during port scanning. The current port does not seem to be a ScratchBoard. Close it and try the next port in the list."

	self closePort.
	scanState := #start.

]

{ #category : #'motor ops' }
SensorBoardMorph >> selectMotor: anInteger [
	"Select the motor to which subsequent motor commands will be addressed. Motors are numbered 1-6."

	| motorNum msg |
	motorNum := (anInteger truncated - 1 max: 0) min: 7. "motor bit index"
	msg := #(84 254 128 0) asByteArray.
	msg at: 4 put: (1 bitShift: motorNum).
	port nextPutAll: msg.

]

{ #category : #'serial port' }
SensorBoardMorph >> selectPort [

	| menu choice |
	self stopReadingData.

	self portNames size = 0 ifTrue: [^ DialogBoxMorph inform: 'No serial ports found'].

	menu := MenuMorph new.
	self portNames do: [:n | menu add: n
		target: self
		selector: #openPort:
		argument: n].
	
	"choice :=" menu invokeModal.
	"self halt."
	"choice ifNil: [^ self]."

	"self openPort: choice."
	self startReadingData.
	scanState := #on.

]

{ #category : #'sensor ops' }
SensorBoardMorph >> sensor: sensorIndex [
	"Answer the value of the virtual sensor with the given index. Sensors are numbered 1-8."

	^ self privateSensor: sensorIndex

]

{ #category : #'motor ops' }
SensorBoardMorph >> setPower: aNumber motor: motorNum [
	"Set the power of the given motor to 0 to 7."

	| power msg |
	self portIsOpen ifFalse: [^ self].
	self selectMotor: motorNum.
	power := (aNumber truncated max: 0) min: 7.
	msg := #(84 254 0) asByteArray.
	msg at: 3 put: 96 + (power bitShift: 2).
	port nextPutAll: msg.

]

{ #category : #'event handling' }
SensorBoardMorph >> startDrag: evt [

	| rootForGrab |
	self world ifNil: [^self].  "don't pick me up if in presentation mode"
	rootForGrab := owner rootForGrabOf: self.
	rootForGrab ifNil: [^ self].
	rootForGrab position: evt hand position + (self topLeft - evt cursorPoint).
	evt hand grabMorph: rootForGrab.

]

{ #category : #'sensor ops' }
SensorBoardMorph >> startReadingData [
	"Ensure that the serial port is open, turn off all motors and put them into a known state, and begin streaming sensor data."

	self portIsOpen ifFalse: [^ self].  "could not open the serial port"

	currentState := #idle.
	sensorValues atAllPut: 0.
	scratchBoardV3 := false.
	self startStreamingSensors: 0.  "in case board was left in streaming mode"
	port flushInputBuffer.

	useGoGoProtocol ifTrue: [
		1 to: 6 do: [:motor |
			self turnOffMotor: motor.
			self thisWayMotor: motor.
			self setPower: 3 motor: motor.
			self turnOffMotor: motor].
		self startStreamingSensors: 16rFF].  "all 8 sensors"

]

{ #category : #private }
SensorBoardMorph >> startStreamingSensors: sensorByte [
	"Begin streaming data from the set of sensors specified by the bits of the given byte. Invoke this method with 0 to stop streaming. Incoming sensor data is processed by frequent calls to processIncomingData."

	| cmd |
	useGoGoProtocol ifFalse: [^ self].
	port flushInputBuffer.
	cmd := #(84 254 160 0) asByteArray.
	cmd at: 4 put: sensorByte.
	port nextPutAll: cmd.

]

{ #category : #stepping }
SensorBoardMorph >> step [
	"Update my title and sensor readouts. If scanning for ports, keep scanning."

	| frame |
	#checkData = scanState ifTrue: [self scanForPort].

	self portIsOpen
		ifTrue: [self processIncomingData]
		ifFalse: [port := nil].

	self updateTitle.

	1 to: 8 do: [:i |
		(readouts at: i) contents: (self privateSensor: i) truncated printString.
		(scratchBoardV3 and: [i = 4])
			ifTrue: [(readouts at: i) contents: ((self privateSensor: i) < 10) printString]. "button"
		frame := (readouts at: i) owner.
		(frame respondsTo: #fixLayout) ifTrue: [frame fixLayout]].

]

{ #category : #stepping }
SensorBoardMorph >> stepTime [

	^ 50

]

{ #category : #'sensor ops' }
SensorBoardMorph >> stopReadingData [
	"Turn off all motors, stop streaming data, and close the port."

	(port notNil and: [port isOpen]) ifTrue: [
		useGoGoProtocol ifTrue: [
			1 to: 6 do: [:motor | self turnOffMotor: motor].
			self startStreamingSensors: 0]].  "turn off streaming"
	self closePort.

]

{ #category : #'object i/o' }
SensorBoardMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	anObjStream putField: 1.  "old portNum instance variable"


]

{ #category : #'motor ops' }
SensorBoardMorph >> thatWayMotor: motorNum [
	"Set motor direction to that way."

	self portIsOpen ifFalse: [^ self].
	self selectMotor: motorNum.
	port nextPutAll: #(84 254 80) asByteArray.

]

{ #category : #'motor ops' }
SensorBoardMorph >> thisWayMotor: motorNum [
	"Set motor direction to this way."

	self portIsOpen ifFalse: [^ self].
	self selectMotor: motorNum.
	port nextPutAll: #(84 254 76) asByteArray.

]

{ #category : #'event handling' }
SensorBoardMorph >> toggleRawMode [

	reportRaw := reportRaw not.

]

{ #category : #'serial port' }
SensorBoardMorph >> tryToOpenPort [
	"Attempt to open the port. If successful, or if the port was open already, answer true. Otherwise, answer false."

	(port notNil and: [port isOpen and: [scanState = #on]]) ifTrue: [^ true].  "already open"
	self scanForPort.
	^ port notNil and: [port isOpen]

]

{ #category : #'motor ops' }
SensorBoardMorph >> turnOffMotor: motorNum [

	self portIsOpen ifFalse: [^ self].
	self selectMotor: motorNum.
	port nextPutAll: #(84 254 68) asByteArray.

]

{ #category : #'motor ops' }
SensorBoardMorph >> turnOnMotor: motorNum [

	self portIsOpen ifFalse: [^ self].
	self selectMotor: motorNum.
	port nextPutAll: #(84 254 64) asByteArray.

]

{ #category : #private }
SensorBoardMorph >> updateTitle [
	"Update my title to reflect the current protocol and port number."

	| s |
	s := (#on = scanState) ifTrue: ['On' localized] ifFalse: ['Off' localized].
	s = titleMorph contents ifFalse: [titleMorph contents: s].


]

{ #category : #'serial port' }
SensorBoardMorph >> useGoGoProtocol [

	self stopReadingData.
	useGoGoProtocol := true.
	scratchBoardV3 := false.
	self startReadingData.

]

{ #category : #'serial port' }
SensorBoardMorph >> useScratchboardProtocol [

	self stopReadingData.
	useGoGoProtocol := false.
	self startReadingData.

]
