"
An instance of this class represents an EV3 Bricks e.g. the EV3 main computer.

===
To test with BoTest:
motor+net
    motorsync+net
sensor+net
    colorsensor+net
    gyrosensor+net
    irsensor+net
    temperaturesensor+net
    touchsensor+net
brick+net
vehicule+net
bridge+net4
===



Some possible commands: 
-------

ev3 := Ev3Vehicle newIp: '192.168.2.3' port: 58871 serial: '0016533f8491' daisyChain: #EV3.
ev3 syncMotorsLeft: ev3 motorB right: ev3 motorC.
ev3 plugSensor1: Ev3TouchSensor.
ev3 plugSensor2: Ev3ColorSensor.
ev3 plugSensor4: Ev3IRSensor.
ev3 initializeSensors.

ev3 initializeSensors.
ev3 getSensorTypes.



[true] whileTrue:[
	Transcript show: ev3 sensor4 read.
	Transcript cr.
	(Delay forMilliseconds: 500) wait.
].



ev3 motorB speed: 50.
ev3 motorB start.
ev3 motorB stop.
ev3 motorB emergencyStop.

ev3 motorSync speed: -10.
ev3 motorSync start.
ev3 motorSync stop.
ev3 moveSpeed: 20 degrees: 200 reply: false.
ev3 motorC speed: 0.
ev3 motorC start.

ev3 motorA speed: 10.
ev3 motorA start.
ev3 motorA stop.



ev3 motorA startAtSpeed: 0.
ev3 motorA stop.


ev3 getSensorTypes.

"
Class {
	#name : #Ev3Brick,
	#superclass : #Object,
	#instVars : [
		'sensor1',
		'sensor2',
		'sensor3',
		'sensor4',
		'motorA',
		'motorB',
		'motorC',
		'motorD',
		'bridge',
		'memory',
		'fileSystem',
		'motorSync',
		'mailbox',
		'daisyChainLayer',
		'buttonUp',
		'buttonEnter',
		'buttonDown',
		'buttonRight',
		'buttonLeft',
		'buttonBack',
		'buttonAny',
		'screen',
		'led',
		'sound',
		'currentSequenceNumber'
	],
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3Brick class >> newDaisyChain: aDaisyChain [ 

	|ev3 ev3bdg |
	ev3 := self basicNew.
	ev3bdg := Ev3BridgeSocket new.
	ev3 bridge: ev3bdg.
	ev3 daisyChainLayer: (Ev3Command daisyChainLayer at: aDaisyChain).
	ev3 initialize.
	^ev3
]

{ #category : #'as yet unclassified' }
Ev3Brick class >> newIp: anIp daisyChain: aDaisyChain [ 

	|ev3 ev3bdg |
	ev3 := self basicNew.
	ev3bdg := Ev3BridgeSocket newWithIp: anIp.
	ev3 bridge: ev3bdg.
	ev3 daisyChainLayer: (Ev3Command daisyChainLayer at: aDaisyChain).
	ev3 initialize.
	^ev3
]

{ #category : #accessing }
Ev3Brick >> bridge [
	
	^ bridge
]

{ #category : #accessing }
Ev3Brick >> bridge: anObject [
	
	bridge := anObject
]

{ #category : #'as yet unclassified' }
Ev3Brick >> buildStartProgram: name reply: aBool [

	|command|
	command := Ev3Command newGlobal: 8 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #File).
	command appendByte: (Ev3Command fileSubCodes at: #LoadImage).
	command addInt16Value: (Ev3Command programSlots at: #User).
	command appendString: name constantParameterType: (Ev3Command constantParameterType at: #Value).
	command addShortByteGlobalVariableAtAddress: 0.
	command addShortByteGlobalVariableAtAddress: 4.
	command appendByte: (Ev3Command byteCodes at: #ProgramStart).
	command appendByte: (Ev3Command programSlots at: #User).
	command addShortByteGlobalVariableAtAddress: 0.
	command addShortByteGlobalVariableAtAddress: 4.
	command addShortValue: 0.

	^ command
]

{ #category : #accessing }
Ev3Brick >> buttonAny [
	^ buttonAny
]

{ #category : #accessing }
Ev3Brick >> buttonBack [
	^ buttonBack
]

{ #category : #accessing }
Ev3Brick >> buttonDown [
	^ buttonDown
]

{ #category : #accessing }
Ev3Brick >> buttonEnter [
	^ buttonEnter
]

{ #category : #accessing }
Ev3Brick >> buttonLeft [
	^ buttonLeft
]

{ #category : #accessing }
Ev3Brick >> buttonRight [
	^ buttonRight
]

{ #category : #accessing }
Ev3Brick >> buttonUp [
	^ buttonUp
]

{ #category : #accessing }
Ev3Brick >> currentSequenceNumber [
	
	currentSequenceNumber := currentSequenceNumber +1.
	^ currentSequenceNumber
]

{ #category : #accessing }
Ev3Brick >> daisyChainLayer [
	
	^ daisyChainLayer
]

{ #category : #accessing }
Ev3Brick >> daisyChainLayer: anObject [
	
	daisyChainLayer := anObject
]

{ #category : #'initialize-release' }
Ev3Brick >> detectSensors [
	|type|
	type := Ev3Sensor allSubclasses detect: [:e | e typeString = sensor1 getSensorType asString] ifNone: [Ev3Sensor].
	sensor1:= type newWithBrick: self.
	type := Ev3Sensor allSubclasses detect: [:e | e typeString = sensor2 getSensorType asString] ifNone: [Ev3Sensor].
	sensor2:= type newWithBrick: self.
	type := Ev3Sensor allSubclasses detect: [:e | e typeString = sensor3 getSensorType asString] ifNone: [Ev3Sensor].
	sensor3:= type newWithBrick: self.
	type := Ev3Sensor allSubclasses detect: [:e | e typeString = sensor4 getSensorType asString] ifNone: [Ev3Sensor].
	sensor4:= type newWithBrick: self.
	
	sensor1 brickPort: (Ev3Sensor sensorPort at: #In1).
	sensor2 brickPort: (Ev3Sensor sensorPort at: #In2).
	sensor3 brickPort: (Ev3Sensor sensorPort at: #In3).
	sensor4 brickPort: (Ev3Sensor sensorPort at: #In4).
	
	self initializeSensors.
]

{ #category : #accessing }
Ev3Brick >> fileSystem [
	
	^ fileSystem
]

{ #category : #'as yet unclassified' }
Ev3Brick >> getFirmware [

	^ self getFirmwareLength: 16r10 index: 0 reply: true
]

{ #category : #'as yet unclassified' }
Ev3Brick >> getFirmwareLength: maxLength index: ind reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #UIRead).
	command appendByte: (Ev3Command uiReadSubCodes at: #GetFirmware).
	command appendByte: maxLength.
	command addLongUInt16GlobalVariableAtAddress: ind.
	
	reply := self sendCommand: command withReply: aBool.	
	^(reply getDataFrom: 2) hex
]

{ #category : #'as yet unclassified' }
Ev3Brick >> getSensorTypes [

	|command reply |
	
	command := self queryToGetSensorTypes.
	reply := self sendCommand: command withReply: true.
	^ self sensorTypesIn: reply.
]

{ #category : #accessing }
Ev3Brick >> giveSequenceNumber [
	
	currentSequenceNumber := currentSequenceNumber +1.
	^ currentSequenceNumber.
]

{ #category : #'initialize-release' }
Ev3Brick >> initialize [ 

	super initialize.
	currentSequenceNumber := 0.
	
	sensor1 := Ev3Sensor newWithBrick: self.
	sensor2 := Ev3Sensor newWithBrick: self.
	sensor3 := Ev3Sensor newWithBrick: self.
	sensor4 := Ev3Sensor newWithBrick: self.
	motorA := Ev3Motor newWithBrick: self.
	motorB := Ev3Motor newWithBrick: self.
	motorC := Ev3Motor newWithBrick: self.
	motorD := Ev3Motor newWithBrick: self.
	motorSync := Ev3MotorSync newWithBrick: self.
	
	buttonUp := Ev3BrickButton newWithBrick: self.
	buttonEnter := Ev3BrickButton newWithBrick: self.
	buttonDown := Ev3BrickButton newWithBrick: self.
	buttonRight := Ev3BrickButton newWithBrick: self.
	buttonLeft := Ev3BrickButton newWithBrick: self.
	buttonBack := Ev3BrickButton newWithBrick: self.
	buttonAny := Ev3BrickButton newWithBrick: self.
	
	led := Ev3Led newWithBrick: self.
	screen := Ev3Screen newWithBrick: self.
	fileSystem := Ev3File newWithBrick: self.
	memory := Ev3Memory newWithBrick: self.
	mailbox := Ev3Mailbox newWithBrick: self.
	sound := Ev3Sound newWithBrick: self.
	"bridge:= Ev3Bridge newWithBrick: self."
	
	buttonUp buttonField: (Ev3BrickButton brickButton at: #Up).
	buttonEnter buttonField: (Ev3BrickButton brickButton at: #Enter).
	buttonDown buttonField: (Ev3BrickButton brickButton at: #Down).
	buttonRight buttonField: (Ev3BrickButton brickButton at: #Right).
	buttonLeft buttonField: (Ev3BrickButton brickButton at: #Left).
	buttonBack buttonField: (Ev3BrickButton brickButton at: #Back).
	buttonAny buttonField: (Ev3BrickButton brickButton at: #Any).
	
	motorA bitField: (Ev3Motor outputBitfield at: #OutA).
	motorB bitField: (Ev3Motor outputBitfield at: #OutB).
	motorC bitField: (Ev3Motor outputBitfield at: #OutC).
	motorD bitField: (Ev3Motor outputBitfield at: #OutD).
	motorSync bitField: ((Ev3Motor outputBitfield at: #OutA) | (Ev3Motor outputBitfield at: #OutD)).

	motorA inputBitField: (Ev3Motor inputBitfield at: #OutA).
	motorB inputBitField: (Ev3Motor inputBitfield at: #OutB).
	motorC inputBitField: (Ev3Motor inputBitfield at: #OutC).
	motorD inputBitField: (Ev3Motor inputBitfield at: #OutD).
	motorSync inputBitField: ((Ev3Motor inputBitfield at: #OutA) | (Ev3Motor inputBitfield at: #OutD)).
	
	
	sensor1 brickPort: (Ev3Sensor sensorPort at: #In1).
	sensor2 brickPort: (Ev3Sensor sensorPort at: #In2).
	sensor3 brickPort: (Ev3Sensor sensorPort at: #In3).
	sensor4 brickPort: (Ev3Sensor sensorPort at: #In4).
]

{ #category : #'initialize-release' }
Ev3Brick >> initializeSensors [

	sensor1 initializeSensor.
	sensor2 initializeSensor.
	sensor3 initializeSensor.
	sensor4 initializeSensor.
]

{ #category : #accessing }
Ev3Brick >> led [
	^ led
]

{ #category : #accessing }
Ev3Brick >> mailbox [
	
	^ mailbox
]

{ #category : #accessing }
Ev3Brick >> memory [
	
	^ memory
]

{ #category : #accessing }
Ev3Brick >> motorA [
	
	^ motorA
]

{ #category : #accessing }
Ev3Brick >> motorB [
	
	^ motorB
]

{ #category : #accessing }
Ev3Brick >> motorC [
	
	^ motorC
]

{ #category : #accessing }
Ev3Brick >> motorD [
	
	^ motorD
]

{ #category : #accessing }
Ev3Brick >> motorSync [
	
	^ motorSync
]

{ #category : #'initialize-release' }
Ev3Brick >> plugSensor1: aSensorType [

	self sensor1: (aSensorType newWithBrick: self).
	self sensor1 brickPort: (Ev3Sensor sensorPort at: #In1).
]

{ #category : #'initialize-release' }
Ev3Brick >> plugSensor2: aSensorType [

	self sensor2: (aSensorType newWithBrick: self).
	self sensor2 brickPort: (Ev3Sensor sensorPort at: #In2).
]

{ #category : #'initialize-release' }
Ev3Brick >> plugSensor3: aSensorType [

	self sensor3: (aSensorType newWithBrick: self).
	self sensor3 brickPort: (Ev3Sensor sensorPort at: #In3).
]

{ #category : #'initialize-release' }
Ev3Brick >> plugSensor4: aSensorType [

	self sensor4: (aSensorType newWithBrick: self).
	self sensor4 brickPort: (Ev3Sensor sensorPort at: #In4).
]

{ #category : #'initialize-release' }
Ev3Brick >> plugSensorAt: aSensorSymbol type: aSensorType [

	|meth|
	meth := {#sensor1 -> #plugSensor1: . #sensor2 -> #plugSensor2: . #sensor3 -> #plugSensor3: . #sensor4 -> #plugSensor4: } asDictionary at: aSensorSymbol.

	^ self perform: meth with: aSensorType.

]

{ #category : #queries }
Ev3Brick >> queryToGetSensorTypes [

	|command |
	
	command := Ev3Command newGlobal: 5 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InputDeviceList).
	command addShortValue: 4.
	command addShortByteGlobalVariableAtAddress: 0.
	command addShortByteGlobalVariableAtAddress: 4.
	^ command
]

{ #category : #accessing }
Ev3Brick >> screen [
	^ screen
]

{ #category : #accessing }
Ev3Brick >> sendCommand: aCommand withReply: aBool [

	^ self bridge sendCommand: aCommand withReply: aBool
]

{ #category : #accessing }
Ev3Brick >> sensor1 [
	
	^ sensor1
]

{ #category : #accessing }
Ev3Brick >> sensor1: anObject [
	
	sensor1 := anObject
]

{ #category : #accessing }
Ev3Brick >> sensor2 [
	
	^ sensor2
]

{ #category : #accessing }
Ev3Brick >> sensor2: anObject [
	
	sensor2 := anObject
]

{ #category : #accessing }
Ev3Brick >> sensor3 [
	
	^ sensor3
]

{ #category : #accessing }
Ev3Brick >> sensor3: anObject [
	
	sensor3 := anObject
]

{ #category : #accessing }
Ev3Brick >> sensor4 [
	
	^ sensor4
]

{ #category : #accessing }
Ev3Brick >> sensor4: anObject [
	
	sensor4 := anObject
]

{ #category : #'as yet unclassified' }
Ev3Brick >> sensorTypesIn: aReply [

	|sensorTypes|
	sensorTypes := OrderedCollection new: 4.
	1 to: 4 do:[:i |
		|value|
		value := aReply getInt32At: (4*i).
		sensorTypes add: (Ev3Sensor sensorType keyAtValue: value ifAbsent: [ #Unknown ])
	].
	^sensorTypes.
]

{ #category : #accessing }
Ev3Brick >> sound [
	^ sound
]

{ #category : #'as yet unclassified' }
Ev3Brick >> startProgram: name reply: aBool [

	|command reply|
	command := self buildStartProgram: name reply: aBool.
	
	
	reply := self sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Brick >> stopProgramReply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 8 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #ProgramStop).
	command addLongByteValue: (Ev3Command programSlots at: #User).
		
	reply := self sendCommand: command withReply: aBool.
	^reply
]
