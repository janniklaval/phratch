Class {
	#name : #BlocksBoardMorph,
	#superclass : #PhratchSpriteMorph,
	#instVars : [
		'column',
		'titleMorph',
		'portName',
		'port',
		'sensorValues',
		'curSlot',
		'slotValue',
		'scanState',
		'scanPorts',
		'scanStartMSecs',
		'readouts',
		'lastString'
	],
	#category : #PhratchEducationalBureau
}

{ #category : #'as yet unclassified' }
BlocksBoardMorph class >> showBlocksBoard [

	| workpane instance |
	workpane := self new ownerOrYourselfThatIsAPhratchStageMorph ifNil: [PhratchStageMorph allInstances first].
	instance := self new.
	instance position: workpane position + 20.
	workpane addMorph: instance.
	instance tryToOpenPort.
	World startSteppingSubmorphsOf: instance
]

{ #category : #initialization }
BlocksBoardMorph >> addReadouts [
	| t1 t2 t3 t4 t5 |
	column := AlignmentMorph newColumn centering: #center;
			 hResizing: #spaceFill;
			 vResizing: #shrinkWrap;
			 color: (Color
					r: 193 / 255
					g: 36 / 255
					b: 39 / 255);
			 borderWidth: 2;
			 borderColor: (Color
					r: 148 / 255
					g: 145 / 255
					b: 145 / 255);
			 useRoundedCorners;
			 inset: 3.
	titleMorph := StringMorph contents: '' font: (StrikeFont fontName: 'VerdanaBold' size: 10).
	titleMorph color: Color yellow.
	column addMorph: titleMorph.
	self updateTitle.
	column addMorphBack: (Morph new color: column color;
		 extent: 5 @ 3).
	self removeAllMorphs.
	readouts := Array new: 15.
	t1 := AlignmentMorph newRow color: column color;
			 inset: 2.
	t1 addMorphBack: (Morph new color: column color;
		 extent: 1 @ 3).
	1 to: 15 do: 
		[:t6 | 
		t2 := AlignmentMorph newColumn color: column color;
				 inset: 2.
		t2 centering: #center.
		t5 := StringMorph contents: t6 printString capitalized font: (StrikeFont fontName: 'VerdanaBold' size: 10).
		t5 color: Color yellow.
		t2 addMorphBack: t5.
		t3 := Morph new extent: 20 @ 20;
				 color: (PhratchCategory blockColorFor: 'sensing').
		t4 := StringMorph contents: ' ' font: (StrikeFont fontName: 'VerdanaBold' size: 10).
		t4 color: Color white.
		t3 addMorph: t4.
		t2 addMorphBack: t3.
		t1 addMorphBack: t2.
		t6 = 15 ifFalse: [t1 addMorphBack: (AlignmentMorph new color: column color;
				 extent: 10 @ 1;
				 hResizing: #spaceFill)].
		readouts at: t6 put: t4].
	t1 addMorphBack: (Morph new color: column color;
		 extent: 1 @ 3).
	column addMorphBack: t1.
	column position: self position - 2.
	self addMorph: column.
	self extent: column extent - 4
]

{ #category : #'serial port' }
BlocksBoardMorph >> blockClosePort [
	<phratchItem: 'close port' kind: #- category: 'educational bureau' defaultValues: #() subCategory: #a special: #()>
 
	[self say: 'I am closing the connection'.
	[self closePort] on: Error do: [PhratchError error: 'serial port cannot be closed'].
	2 seconds wait.
	self sayNothing.
	] fork
]

{ #category : #initialization }
BlocksBoardMorph >> blockOpenPort: aPortName [
	<phratchItem: 'open port $String$' kind: #- category: 'educational bureau' defaultValues: #('COM4') subCategory: #a special: #()>
	[self say: 'I am waiting for connection'.
   (self openPort: aPortName) 
		ifFalse:[self say: 'I am not connected'.]
		ifTrue:[self say: 'I am connected'.].
	self startReadingData.
	scanState := #on.
	2 seconds wait.
	self sayNothing.
	] fork
]

{ #category : #initialization }
BlocksBoardMorph >> blockReadAll [
	<phratchItem: 'read all' kind: #ReporterWatcherBlockMorph category: 'educational bureau' defaultValues: #('COM4') subCategory: #b special: #()>
	
	^ self lastString
]

{ #category : #initialization }
BlocksBoardMorph >> blockReadValueAt: anIndex [
	<phratchItem: 'read at $Number$' kind: #ReporterBlockMorph category: 'educational bureau' defaultValues: #('1') subCategory: #b special: #()>
	
	^ self lastString at: anIndex asInteger
]

{ #category : #initialization }
BlocksBoardMorph >> blockShow [
	"<phratchItem: 'show table' kind: #- category: 'educational bureau' defaultValues: #('') subCategory: #a special: #()>"
	| workpane |
	workpane := self ownerOrYourselfThatIsAPhratchFrameMorph workPane  ifNil: [^self].
	self position: workpane position + 20.
	workpane addMorph: self.
	self tryToOpenPort.
	World startSteppingSubmorphsOf: self
]

{ #category : #'serial port' }
BlocksBoardMorph >> closePort [
	port
		ifNotNil: 
			[port flushInputBuffer.
			port close].
	port := nil.
	sensorValues atAllPut: 0.
	1 to: 15 do: [:t1 | (readouts at: t1)
			contents: ' '].
	scanState := #off.
	self step
]

{ #category : #'object i/o' }
BlocksBoardMorph >> fieldsVersion [
	^ 1
]

{ #category : #'object i/o' }
BlocksBoardMorph >> initFieldsFrom: t1 version: t2 [ 
	super initFieldsFrom: t1 version: t2.
	self addReadouts
]

{ #category : #initialization }
BlocksBoardMorph >> initialize [
	super initialize.
	self initializeSkin.
	self setMyName: 'Educ-Bureau'.
	sensorValues := Array new: 15 withAll: 0.
	curSlot := 0.
	slotValue := 0.
	scanState := #off.
	self addReadouts.
	lastString := ByteString new: 15.
	
	self gotoX: -216 y: 156.
]

{ #category : #initialization }
BlocksBoardMorph >> initializeSkin [
	|        |
	"botSkin := Form fromFileNamed: (FileSystem workingDirectory / 'ScratchSkin' / 'defaultSpriteCostume.png').

	botImage := ImageMedia new form: botSkin.
	botImage mediaName: (self unusedMediaNameFromBaseName: (self defaultImageMedia mediaName)).
	media addLast: botImage.
	self lookLike: botImage mediaName.
	self updateMediaCategory."
	
	"workpane := self ownerOrYourselfThatIsAPhratchStageMorph ifNil: [PhratchStageMorph allInstances first].
	self position: workpane position + 20.
	workpane addMorph: self.
	self tryToOpenPort.
	World startSteppingSubmorphsOf: self"
]

{ #category : #accessing }
BlocksBoardMorph >> lastString [

	^ lastString
]

{ #category : #'event handling' }
BlocksBoardMorph >> mouseDown: t1 [ 
	t1 rightButtonPressed | t1 shiftPressed
		ifTrue: 
			[Sensor waitNoButton.
			^ self rightButtonMenu].
	t1 hand toolType = 'CutTool'
		ifTrue: 
			[t1 shiftPressed ifFalse: [t1 hand toolType: nil].
			PhratchFrameMorph putInClipboard: self.
			^ self delete].
	t1 hand waitForClicksOrDrag: self event: t1
]

{ #category : #'event handling' }
BlocksBoardMorph >> mouseHold: t1 [ 
	self rightButtonMenu
]

{ #category : #'serial port' }
BlocksBoardMorph >> openPort: t1 [ 
	| t2 t3 t4 |
	t2 := 9600.
	self closePort.
	portName := t1.
	PhratchPlugin serialPortOpsAvailable
		ifTrue: 
			[port := SerialPort2 new openPortNamed: portName baud: t2.
			port isOpen
				ifFalse: 
					[port := nil.
					^ false].
			port setOption: 20 to: 1.
			port setOption: 21 to: 0]
		ifFalse: 
			[t3 := 1.
			t4 := (1 to: portName size)
						detect: [:t5 | (portName at: t5) isDigit]
						ifNone: [0].
			t4 > 0 ifTrue: [t3 := (portName copyFrom: t4 to: portName size) asNumber].
			port := SerialPort new baudRate: t2;
					 inputFlowControlType: 2;
					 openPort: t3 ifFail: [^ false]].
	^ true
]

{ #category : #'serial port' }
BlocksBoardMorph >> portIsOpen [
	^ port notNil and: [port isOpen]
]

{ #category : #'serial port' }
BlocksBoardMorph >> portName [
	^portName
]

{ #category : #'serial port' }
BlocksBoardMorph >> portNames [
	PhratchPlugin serialPortOpsAvailable ifFalse: [^ (1 to: 32)
			collect: [:t1 | 'COM' , t1 printString]].
	^ SerialPort2 portNames
		reject: [:t2 | (t2 asLowercase includesSubstring: 'modem')
				or: [t2 asLowercase includesSubstring: 'pda-sync']]
]

{ #category : #'event handling' }
BlocksBoardMorph >> preemptsMouseDown: t1 [ 
	^ true
]

{ #category : #private }
BlocksBoardMorph >> processIncomingData [
	| t1 |
	(self portIsOpen and: [#on = scanState])
		ifFalse: [^ self].
	t1 := port readByteArray.
	t1 do: [:t2 | (44 = t2 or: [13 = t2])
			ifTrue: 
				[curSlot := curSlot + 1.
				sensorValues at: curSlot put: slotValue.
				slotValue := 0.
				13 = t2 ifTrue: [curSlot := 0]]
			ifFalse: [(48 <= t2 and: [57 >= t2])
					ifTrue: [slotValue := 10 * slotValue + t2 - 48]
					ifFalse: 
						[curSlot := 0.
						slotValue := 0]]]
]

{ #category : #'serial port' }
BlocksBoardMorph >> resetPort [
	self portIsOpen ifFalse: [^ self].
	portName ifNil: [^ self].
	self closePort.
	self openPort: portName.
	scanState := #on.
	self step
]

{ #category : #'event handling' }
BlocksBoardMorph >> rightButtonMenu [
	| t1 choice |
	t1 := MenuMorph new defaultTarget: self.
	t1 add: 'select serial/USB port' value: #selectPort.
	self portIsOpen ifTrue: [t1 add: 'close port' value: #stopReadingData].
	t1 addLine.
	t1 add: 'hide' value: #delete.
	t1 localize; invokeModal.
	choice := t1 selectedValue ifNil: [^ self].
	self perform: choice.
]

{ #category : #'serial port' }
BlocksBoardMorph >> scanForPort [
	| t1 |
	#off = scanState ifTrue: [self scanNextPort].
	#on = scanState
		ifTrue: 
			[scanPorts := nil.
			self scanNextPort].
	#start = scanState
		ifTrue: 
			[(scanPorts isNil or: [scanPorts size = 0])
				ifTrue: [scanPorts := self portNames asOrderedCollection].
			scanPorts size = 0 ifTrue: [^ self scanNextPort].
			self openPort: scanPorts removeFirst.
			self portIsOpen ifFalse: [^ self].
			scanState := #checkData.
			scanStartMSecs := Time millisecondClockValue.
			slotValue := ''.
			^ self].
	#checkData = scanState
		ifTrue: 
			[t1 := Time millisecondClockValue - scanStartMSecs.
			(self portIsOpen not or: [t1 > 4000])
				ifTrue: [^ self scanNextPort].
			slotValue := slotValue , port readByteArray.
			slotValue size < 7 ifTrue: [^ self].
			slotValue = 'PRONTO-' ifFalse: [^ self scanNextPort].
			slotValue := 0.
			scanState := #on]
]

{ #category : #'serial port' }
BlocksBoardMorph >> scanNextPort [
	self closePort.
	scanState := #start
]

{ #category : #'serial port' }
BlocksBoardMorph >> selectPort [
	| t1 t2 |
	self stopReadingData.
	self portNames size = 0 ifTrue: [^ DialogBoxMorph inform: 'No serial ports found'].
	t1 := MenuMorph new defaultTarget: self.
	self portNames do: [:t3 | t1 add: t3 value: t3].
	t1 localize; invokeModal.
	t2 := t1 selectedValue ifNil: [^ self].
	self openPort: t2.
	self startReadingData.
	scanState := #on
]

{ #category : #'sensor ops' }
BlocksBoardMorph >> sensor: t1 [ 
	t1 < 1 ifTrue: [^ 0].
	t1 > 15 ifTrue: [^ 0].
	^ sensorValues at: t1
]

{ #category : #'sensor ops' }
BlocksBoardMorph >> sensorString: t1 [ 
	^ self stringFor: (self sensor: t1)
]

{ #category : #'sensor ops' }
BlocksBoardMorph >> startReadingData [
	self portIsOpen ifFalse: [^ self].
	curSlot := 0.
	slotValue := 0.
	sensorValues atAllPut: 0.
	port flushInputBuffer
]

{ #category : #stepping }
BlocksBoardMorph >> step [
	| t1 |
	super step.
	(#checkData = scanState or: [#start = scanState])
		ifTrue: [self scanForPort].
	self portIsOpen
		ifTrue: [self processIncomingData]
		ifFalse: [port := nil].
	self updateTitle.
	1 to: 15 do: 
		[:t2 | 
		(readouts at: t2)
			contents: (self stringFor: (self sensor: t2)).
		lastString at: t2 put: (PhratchEducationalBureau characterAt: (self sensor: t2)).
		t1 := (readouts at: t2) owner.
		(t1 respondsTo: #fixLayout)
			ifTrue: [t1 fixLayout]]
]

{ #category : #stepping }
BlocksBoardMorph >> stepTime [
	^ 50
]

{ #category : #'sensor ops' }
BlocksBoardMorph >> stopReadingData [
	self closePort
]

{ #category : #private }
BlocksBoardMorph >> stringFor: t1 [ 
	t1 < 1 ifTrue: [^ ' '].
	t1 > 116 ifTrue: [^ ' '].
	^ String with: ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZáàâãÁÀÂÃéêÉÊíÍóôõÓÔÕúüÚÜ0123456789!?-_+=",.;:@#$%&*()/\|{}[]ªºçÇ' at: t1)
]

{ #category : #'serial port' }
BlocksBoardMorph >> tryToOpenPort [
	(port notNil
		and: [port isOpen and: [scanState = #on]])
		ifTrue: [^ true].
	self scanForPort.
	^ port notNil and: [port isOpen]
]

{ #category : #private }
BlocksBoardMorph >> updateTitle [
	| t1 |
	t1 := #on = scanState
				ifTrue: ['On' localized]
				ifFalse: ['Off' localized].
	t1 = titleMorph contents ifFalse: [titleMorph contents: t1]
]

{ #category : #'dropping/grabbing' }
BlocksBoardMorph >> xxxjustDroppedInto: t1 event: t2 [ 
	(t1 isKindOf: PhratchStageMorph)
		ifFalse: [self world addMorph: self]
]
