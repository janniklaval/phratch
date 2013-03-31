"
Low level interface to the Lego WeDo.

"
Class {
	#name : #WeDoPlugin,
	#superclass : #InterpreterPlugin,
	#classVars : [
		'LastReadTime',
		'MotorA',
		'MotorADirection',
		'MotorAOn',
		'MotorAPower',
		'MotorAStopTime',
		'MotorB',
		'MotorBDirection',
		'MotorBOn',
		'MotorBPower',
		'MotorBStopTime',
		'PortAID',
		'PortAValue',
		'PortBID',
		'PortBValue'
	],
	#category : #'Phratch-Primitives-Plugins'
}

{ #category : #private }
WeDoPlugin class >> closeIfInactive [
	"Close the WeDo if data is not received for a while. This allows the WeDo to be re-opened when it is unplugged and then plugged in again."

	| msecs inactiveMSecs |
	LastReadTime ifNil: [^ self].  "not open"

	msecs := Time millisecondClockValue.
	LastReadTime > msecs ifTrue: [LastReadTime := Time millisecondClockValue].  "clock wrap"

	inactiveMSecs := msecs - LastReadTime.
	inactiveMSecs > 2000 ifTrue: [
		self closePort.
		LastReadTime := nil].

]

{ #category : #primitives }
WeDoPlugin class >> closePort [
	"Close the WeDo port. Do nothing if the port is already closed."
	"self closePort"

	<primitive: 'primClosePort' module: 'WeDoPlugin'>
	^ nil

]

{ #category : #translation }
WeDoPlugin class >> declareCVarsIn: aCCodeGenerator [
	"self translate"

	super declareCVarsIn: aCCodeGenerator.
	aCCodeGenerator cExtras: '
/* WeDo Functions */
int WeDoOpenPort(void);
int WeDoClosePort(void);
int WeDoRead(char *bufPtr, int bufSize);
int WeDoWrite(char *bufPtr, int bufSize);
'.

]

{ #category : #sensors }
WeDoPlugin class >> distance [
	"Answer the value of the distance sensor."

	| distanceID v |
	distanceID := 9.
	self readInputs.
	v := nil.
	PortAID = distanceID ifTrue: [v := PortAValue].
	PortBID = distanceID ifTrue: [v := PortBValue].
	v ifNil: [^ 0].

	v := ((100 * (v - 70)) // 140) within: 0 and: 100.
	^ v

]

{ #category : #'class initialization' }
WeDoPlugin class >> initialize [
	"self initialize"

	MotorA := 0.
	MotorB := 0.
	MotorAOn := false.
	MotorBOn := false.
	MotorADirection := 1.
	MotorBDirection := 1.
	MotorAPower := 100.
	MotorBPower := 100.
	MotorAStopTime := 0.
	MotorBStopTime := 0.
	PortAID := 0.
	PortAValue := 0.
	PortBID := 0.
	PortBValue := 0.

]

{ #category : #other }
WeDoPlugin class >> isOpen [
	"Answer true if the WeDo port is open. If it is not open, try to open it."

	| isOpen |
	isOpen := self openPort notNil.
	isOpen ifFalse: [
		self turnOffMotors.
		PortAID := PortBID := 0.
		PortAValue := PortBValue := 0.
		LastReadTime := nil].

	^ isOpen

]

{ #category : #private }
WeDoPlugin class >> mapID: n [
	"Covert a raw ID value into a device index. Some device ID's:
		2 - tilt sensor
		9 - distance sensor
		10 - light brick
		13 - motor"

	| rangeMap |
	rangeMap := #(9 27 47 67 87 109 131 152 169 190 211 224 233 246 256).
	1 to: rangeMap size do: [:i |
		n < (rangeMap at: i) ifTrue: [^ i - 1]].
	^ rangeMap size

]

{ #category : #'motor control' }
WeDoPlugin class >> motorADirection: aNumber [
	"Set or reverse motor direction:
		-1 - counter-clockwise (that way)
		 0 - reverse current direction
		 1 - clockwise (this way)"

	aNumber = 0
		ifTrue: [MotorADirection := MotorADirection negated]
		ifFalse: [MotorADirection := (aNumber < 0) ifTrue: [-1] ifFalse: [1]].

	self updateMotors.

]

{ #category : #'motor control' }
WeDoPlugin class >> motorAIsOff [
	"Answer true if motor A has not run in the past second."

	| now |
	MotorA ~= 0 ifTrue: [^ false].  "currently running"

	now := Time millisecondClockValue.
	(MotorAStopTime isNil or:
	 [now < MotorAStopTime]) ifTrue: [
		MotorAStopTime := 0].

	^ (now - MotorAStopTime) > 1000

]

{ #category : #'motor control' }
WeDoPlugin class >> motorAOn: aBoolean [

	self readInputs.
	self motorAIsOff ifTrue: [
		"make sure that port A has a motor, not a sensor"
		PortAID = 13 ifFalse: [^ self]].

	MotorAOn := aBoolean.
	self updateMotors.

]

{ #category : #'motor control' }
WeDoPlugin class >> motorAPower: aNumber [
	"Set the power level to the absolute value of the given number. The range is 0-100."

	MotorAPower := aNumber abs.
	self updateMotors.

]

{ #category : #'motor control' }
WeDoPlugin class >> motorBDirection: aNumber [
	"Set or reverse motor direction:
		-1 - counter-clockwise (that way)
		 0 - reverse current direction
		 1 - clockwise (this way)"

	aNumber = 0
		ifTrue: [MotorBDirection := MotorBDirection negated]
		ifFalse: [MotorBDirection := (aNumber < 0) ifTrue: [-1] ifFalse: [1]].

	self updateMotors.

]

{ #category : #'motor control' }
WeDoPlugin class >> motorBIsOff [
	"Answer true if motor B has not run in the past second."

	| now |
	MotorB ~= 0 ifTrue: [^ false].  "currently running"

	now := Time millisecondClockValue.
	(MotorBStopTime isNil or:
	 [now < MotorBStopTime]) ifTrue: [
		MotorBStopTime := 0].

	^ (now - MotorBStopTime) > 1000

]

{ #category : #'motor control' }
WeDoPlugin class >> motorBOn: aBoolean [

	self readInputs.
	self motorBIsOff ifTrue: [
		"make sure that port B has a motor, not a sensor"
		PortBID = 13 ifFalse: [^ self]].

	MotorBOn := aBoolean.
	self updateMotors.

]

{ #category : #'motor control' }
WeDoPlugin class >> motorBPower: aNumber [
	"Set the power level to the absolute value of the given number. The range is 0-100."

	MotorBPower := aNumber abs.
	self updateMotors.

]

{ #category : #primitives }
WeDoPlugin class >> openPort [
	"Open the WeDo port. Return nil if the port could not be opened. Does nothing if the port is already open."
	"self openPort"

	<primitive: 'primOpenPort' module: 'WeDoPlugin'>
	^ nil

]

{ #category : #private }
WeDoPlugin class >> readInputs [
	"Return an array of the form <id1> <value1> <id2> <value2>. Answer nil if no data is available."
	"Note: read as much data as available and take the last 8 bytes read to get the most recent values."
	"Note: ID's are meaningless while the motor is running and for about a second after it has been turned off."
	"self readInputs"

	| buf n |
	self closeIfInactive.
	self isOpen ifFalse: [^ nil].

	buf := ByteArray new: 500.
	n := WeDoPlugin readInto: buf.
	n < 8 ifTrue: [^ nil]. "no data"
	buf := buf copyFrom: n - 7 to: n.
	LastReadTime := Time millisecondClockValue.

	self motorAIsOff ifTrue: [
		PortAID := self mapID: (buf at: 4).
		PortAValue := buf at: 3].
	self motorBIsOff ifTrue: [
		PortBID := self mapID: (buf at: 6).
		PortBValue := buf at: 5].

	^ {PortAID. PortBID. PortAValue. PortBValue }

]

{ #category : #primitives }
WeDoPlugin class >> readInto: buffer [
	"Read from the WeDo port into the given ByteArray and answer the number of bytes read."
	"self readInto: (ByteArray new: 10)"

	<primitive: 'primRead' module: 'WeDoPlugin'>
	^ 0

]

{ #category : #other }
WeDoPlugin class >> resetWeDo [
	"self resetWeDo"

	self sendStatus: 128 motorA: 0 motorB: 0.
	self sendStatus: 8 motorA: 0 motorB: 0.
	self sendStatus: 64 motorA: 0 motorB: 0.

	self turnOffMotors.
	MotorADirection := 1.
	MotorBDirection := 1.
	MotorAPower := 100.
	MotorBPower := 100.

]

{ #category : #'motor control' }
WeDoPlugin class >> scalePower: aNumber [
	"Scale the motor power to the range 0-127. The input is expected to be in the range 0-100."

	aNumber <= 0 ifTrue: [^ 0].
	^ ((1.1 * aNumber) + 17.0) rounded

]

{ #category : #private }
WeDoPlugin class >> sendStatus: status motorA: motorA motorB: motorB [

	| buf |
	buf := ByteArray new: 8.
	buf at: 1 put: status.
	buf at: 2 put: (motorA >= 0 ifTrue: [motorA] ifFalse: [256 + motorA]).
	buf at: 3 put: (motorB >= 0 ifTrue: [motorB] ifFalse: [256 + motorB]).
	self writeFrom: buf.

]

{ #category : #sensors }
WeDoPlugin class >> tilt [
	"Answer the value of the tilt sensor:
		0 - no tilt or tilt sensor not available
		1-4 - tilt direction"

	| tiltID v |
	tiltID := 2.
	self readInputs.
	v := nil.
	PortAID = tiltID ifTrue: [v := PortAValue].
	PortBID = tiltID ifTrue: [v := PortBValue].
	v ifNil: [^ 0].

	v < 49 ifTrue: [^ 3].
	v < 100 ifTrue: [^ 2].
	v < 154 ifTrue: [^ 0].
	v < 205 ifTrue: [^ 1].
	^ 4

]

{ #category : #private }
WeDoPlugin class >> turnOffMotors [
	"Clear my motor on state. Do not change the power and direction settings."

	MotorA = 0 ifFalse: [MotorAStopTime := Time millisecondClockValue].
	MotorB = 0 ifFalse: [MotorBStopTime := Time millisecondClockValue].
	MotorA := 0.
	MotorB := 0.
	MotorAOn := false.
	MotorBOn := false.


]

{ #category : #'motor control' }
WeDoPlugin class >> updateMotors [
	"Compute the motor control values and send them to the WeDo hub."

	| wasRunning controlByte |
	self readInputs.
	wasRunning := (MotorA ~= 0).
	controlByte := (MotorADirection * (self scalePower: MotorAPower)) within: -127 and: 127.
	MotorAOn ifFalse: [controlByte := 0].
	controlByte = 0
		ifTrue: [
			wasRunning ifTrue: [MotorAStopTime := Time millisecondClockValue]]
		ifFalse: [
			self motorAIsOff ifTrue: [
				"before starting, make sure that port A has a motor, not a sensor"
				PortAID = 13 ifFalse: [controlByte := 0]]].
	MotorA := controlByte.

	wasRunning := (MotorB ~= 0).
	controlByte := (MotorBDirection * (self scalePower: MotorBPower)) within: -127 and: 127.
	MotorBOn ifFalse: [controlByte := 0].
	controlByte = 0
		ifTrue: [
			wasRunning ifTrue: [MotorBStopTime := Time millisecondClockValue]]
		ifFalse: [
			self motorBIsOff ifTrue: [
				"before starting, make sure that port B has a motor, not a sensor"
				PortBID = 13 ifFalse: [controlByte := 0]]].
	MotorB := controlByte.

	self isOpen.
	self sendStatus: 64 motorA: MotorA motorB: MotorB.

]

{ #category : #primitives }
WeDoPlugin class >> writeFrom: buffer [
	"Write data from the given ByteArray or String to the WeDo and answer the number of bytes written."
	"self writeFrom: (0 to: 100) asByteArray"

	<primitive: 'primWrite' module: 'WeDoPlugin'>
	^ 0

]

{ #category : #'translated prims' }
WeDoPlugin >> primClosePort [
	"Close the WeDo port."

	self export: true.
	interpreterProxy success: (self cCode: 'WeDoClosePort()').
	^ 0

]

{ #category : #'translated prims' }
WeDoPlugin >> primOpenPort [
	"Open the WeDo port."

	self export: true.
	interpreterProxy success: (self cCode: 'WeDoOpenPort()').
	^ 0

]

{ #category : #'translated prims' }
WeDoPlugin >> primRead [
	"Read data from the WeDo port into the given buffer (a ByteArray or String). Answer the number of bytes read."

	| bufOop bufPtr bufSize byteCount |
	self export: true.
	self var: 'bufPtr' declareC: 'char *bufPtr'.

	bufOop := interpreterProxy stackValue: 0.
	((interpreterProxy isIntegerObject: bufOop) or:
	 [(interpreterProxy isBytes: bufOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	bufPtr := self cCoerce: (interpreterProxy firstIndexableField: bufOop) to: 'char *'.
	bufSize := interpreterProxy stSizeOf: bufOop.
	interpreterProxy failed ifTrue: [^ 0].

	byteCount := self cCode: 'WeDoRead(bufPtr, bufSize)'.
	byteCount < 0 ifTrue: [
		interpreterProxy success: false.
		^ 0].

	interpreterProxy pop: 2.  					"pop args and rcvr"
	interpreterProxy pushInteger: byteCount.	"push result"
	^ 0

]

{ #category : #'translated prims' }
WeDoPlugin >> primWrite [
	"Write data to the WeDo port from the given buffer (a ByteArray or String). Answer the number of bytes written."

	| bufOop bufPtr bufSize byteCount |
	self export: true.
	self var: 'bufPtr' declareC: 'char *bufPtr'.

	bufOop := interpreterProxy stackValue: 0.
	((interpreterProxy isIntegerObject: bufOop) or:
	 [(interpreterProxy isBytes: bufOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	bufPtr := self cCoerce: (interpreterProxy firstIndexableField: bufOop) to: 'char *'.
	bufSize := interpreterProxy stSizeOf: bufOop.
	interpreterProxy failed ifTrue: [^ 0].

	byteCount := self cCode: 'WeDoWrite(bufPtr, bufSize)'.
	byteCount < 0 ifTrue: [
		interpreterProxy success: false.
		^ 0].

	interpreterProxy pop: 2.  					"pop args and rcvr"
	interpreterProxy pushInteger: byteCount.	"push result"
	^ 0

]
