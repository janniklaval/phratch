Class {
	#name : #Ev3Motor,
	#superclass : #Ev3Block,
	#instVars : [
		'bitField',
		'polarity',
		'inputBitField'
	],
	#classVars : [
		'MotorPort',
		'OutputBitfield',
		'Polarity'
	],
	#category : #EV3Bricks
}

{ #category : #accessing }
Ev3Motor class >> inputBitfield [
	^ { #OutA -> 16r00 . #OutB -> 16r01 . #OutC -> 16r02 . #OutD -> 16r03} asDictionary.
]

{ #category : #accessing }
Ev3Motor class >> mode [ 

	^self motorMode 

]

{ #category : #accessing }
Ev3Motor class >> motorMode [ 

	^{ 
		#Degrees->#Mode0. 
		#Rotations->#Mode1.
		#Percent->#Mode2
	} asDictionary 
]

{ #category : #accessing }
Ev3Motor class >> outputBitfield [
	^ { #OutA -> 16r01 . #OutB -> 16r02 . #OutC -> 16r04 . #OutD -> 16r08 . #All -> 16r0f} asDictionary.
]

{ #category : #accessing }
Ev3Motor class >> polarity [
	^ { #Backward -> -1 . #Forward -> 1 . #OppositeDirection -> 0 } asDictionary
]

{ #category : #accessing }
Ev3Motor >> bitField [
	
	^ bitField
]

{ #category : #accessing }
Ev3Motor >> bitField: anObject [
	
	bitField := anObject
]

{ #category : #'as yet unclassified' }
Ev3Motor >> clearAll [

	^ self clearAllReply: false.
]

{ #category : #'as yet unclassified' }
Ev3Motor >> clearAllReply: aBool [

	|command reply  |
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #InputDevice).
	command appendByte: (Ev3Command inputSubCodes at: #ClearAll).
	command appendByte: self daisyChainLayer.
		
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #nottested }
Ev3Motor >> clearCount [

	^ self clearCountReply: false
]

{ #category : #nottested }
Ev3Motor >> clearCountReply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputClrCount).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'external api' }
Ev3Motor >> emergencyStop [

	^ self stopBrake: true reply: true.
]

{ #category : #nottested }
Ev3Motor >> getCount [

	^ self getCount: self inputBitField.
]

{ #category : #nottested }
Ev3Motor >> getCount: aPort [

	|command reply|
	command := Ev3Command newGlobal: 4 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #OutputGetCount).
	command appendByte: self daisyChainLayer.
	command appendByte: aPort.
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: true.
	^reply getInt32At: 4
]

{ #category : #nottested }
Ev3Motor >> getSpeed [

	^ self getSpeed: self inputBitField.
]

{ #category : #nottested }
Ev3Motor >> getSpeed: aPort [

	|command reply|
	command := Ev3Command newGlobal: 8 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #OutputRead).
	command appendByte: self daisyChainLayer.
	command appendByte: aPort.
	command addShortByteGlobalVariableAtAddress: 0.
	command addShortByteGlobalVariableAtAddress: 4.
	
	reply := self brick sendCommand: command withReply: true.
	^reply getSByteAt: 4
]

{ #category : #nottested }
Ev3Motor >> getType [

	self getType: self bitField.
]

{ #category : #nottested }
Ev3Motor >> getType: aPort [

	|command reply|
	command := Ev3Command newGlobal: 4 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #OutputGetType).
	command appendByte: self daisyChainLayer.
	command appendByte: aPort.
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: true.
	^reply
]

{ #category : #nottested }
Ev3Motor >> initialize [
	
	super initialize.
	polarity := (Ev3Motor polarity at: #Forward).
]

{ #category : #accessing }
Ev3Motor >> inputBitField [
	
	^ inputBitField
]

{ #category : #accessing }
Ev3Motor >> inputBitField: anObject [
	
	inputBitField := anObject
]

{ #category : #nottested }
Ev3Motor >> isReady [

	|command reply|
	command := Ev3Command newGlobal: 1 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #OutputTest).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	
	reply := self brick sendCommand: command withReply: true.
	^reply getByteAt: 4
]

{ #category : #nottested }
Ev3Motor >> isReversed [

	^ polarity = (Ev3Motor polarity at: #Forward)
]

{ #category : #nottested }
Ev3Motor >> isRunning [

	^ self getSpeed ~~ 0
]

{ #category : #nottested }
Ev3Motor >> moveToAbsolutePositionSpeed: speed position: position brake: aBoolBrake [

			^ self moveToAbsolutePositionSpeed: speed position: position brake: aBoolBrake reply: false
]

{ #category : #nottested }
Ev3Motor >> moveToAbsolutePositionSpeed: speed position: position brake: aBoolBrake reply: aBool [
	| currentPos diff motorSpeed moveForward |
	currentPos := self getCount.
	diff := 0.
	motorSpeed := 0.
	moveForward := false.
	currentPos < position
		ifTrue: [ 
			diff := position - currentPos.
			moveForward := true ]
		ifFalse: [ 
			diff := currentPos - position.
			moveForward := false ].
	motorSpeed := moveForward
		ifTrue: [ speed ]
		ifFalse: [ -1 * speed ].
	^ self
		moveToRelativePositionSpeed: motorSpeed
		degrees: diff
		brake: aBoolBrake
		reply: aBool
]

{ #category : #nottested }
Ev3Motor >> moveToRelativePositionSpeed: speed degrees: degrees brake: aBoolBrake [
	
	^ self moveToRelativePositionSpeed: speed degrees: degrees brake: aBoolBrake reply: false
]

{ #category : #nottested }
Ev3Motor >> moveToRelativePositionSpeed: speed degrees: degrees brake: aBoolBrake reply: aBool [
	
	| longDegrees rampUpDownSteps constantsSteps |
	longDegrees := degrees.
	rampUpDownSteps := (15 *  longDegrees * 100)/10000.
	constantsSteps := (70 *  longDegrees * 100)/10000.
	(rampUpDownSteps > 300) ifTrue: [
		rampUpDownSteps := 300.
		constantsSteps := degrees - (2*rampUpDownSteps).
	].
	self setStepSpeed: speed rampUpSteps: rampUpDownSteps rampDownSteps:  rampUpDownSteps constantSpeedSteps: constantsSteps brake: aBoolBrake reply: aBool.
]

{ #category : #accessing }
Ev3Motor >> polarity [
	^ polarity
]

{ #category : #accessing }
Ev3Motor >> polarity: anObject [
	polarity := anObject
]

{ #category : #nottested }
Ev3Motor >> read [

	|command reply|
	command := Ev3Command newGlobal: 8 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #OutputRead).
	command appendByte: self daisyChainLayer.
	command appendByte: self inputBitField.
	command addShortByteGlobalVariableAtAddress: 0.
	command addShortByteGlobalVariableAtAddress: 4.
	
	reply := self brick sendCommand: command withReply: true.
	^reply
]

{ #category : #nottested }
Ev3Motor >> reset [
	^ self resetReply: false
]

{ #category : #nottested }
Ev3Motor >> resetReply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputReset).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #nottested }
Ev3Motor >> reverse [

	^ self reverseReply: false
]

{ #category : #nottested }
Ev3Motor >> reverseReply: aBool [

	self isReversed ifFalse: [
		^ self setPolarity: (Ev3Motor polarity at: #Forward) reply: aBool
	] ifTrue: [
		^ self setPolarity: (Ev3Motor polarity at: #Backward) reply: aBool
	].
]

{ #category : #nottested }
Ev3Motor >> setPolarity: newPolarity [ 

	^ self setPolarity: newPolarity reply: false
]

{ #category : #nottested }
Ev3Motor >> setPolarity: newPolarity reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputPolarity).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	command addShortValue: newPolarity.
	
	reply := self brick sendCommand: command withReply: aBool.
	self polarity: newPolarity.
	
	^reply
]

{ #category : #nottested }
Ev3Motor >> setPosition: aPosition reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputPosition).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	command addInt32Value: aPosition.
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #nottested }
Ev3Motor >> setPower: aPowerValue [

	^ self setPower: aPowerValue reply: false
]

{ #category : #nottested }
Ev3Motor >> setPower: aPowerValue reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputPower).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	command addLongByteValue: aPowerValue.
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #nottested }
Ev3Motor >> setStepPower: power constantSpeed: constantSpeedSteps brake: aBoolBrake [

	^ self setStepPower: power constantSpeed: constantSpeedSteps brake: aBoolBrake reply: false
]

{ #category : #nottested }
Ev3Motor >> setStepPower: power constantSpeed: constantSpeedSteps brake: aBoolBrake reply: aBool [

	^ self setStepPower: power rampUp: 0 rampDown: 10 constantSpeed: constantSpeedSteps brake: aBoolBrake reply: aBool

]

{ #category : #nottested }
Ev3Motor >> setStepPower: power rampUp: rampUpSteps rampDown: rampDownSteps constantSpeed: constantSpeedSteps brake: aBoolBrake reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputStepPower).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	command addLongByteValue: power.
	command addInt32Value: rampUpSteps.
	command addInt32Value: constantSpeedSteps.
	command addInt32Value: rampDownSteps.
	
	aBoolBrake ifTrue: [ 
		command addShortValue: 1.
	] ifFalse: [ 
		command addShortValue: 0.
	].
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #controle }
Ev3Motor >> setStepSpeed: speed constantSpeedSteps: constantSpeedSteps brake: aBoolBrake [

	^ self setStepSpeed: speed constantSpeedSteps: constantSpeedSteps brake: aBoolBrake reply: false
]

{ #category : #controle }
Ev3Motor >> setStepSpeed: speed constantSpeedSteps: constantSpeedSteps brake: aBoolBrake reply: aBool [

	^ self setStepSpeed: speed rampUpSteps: 0 rampDownSteps: 10 constantSpeedSteps: constantSpeedSteps brake: aBoolBrake reply: aBool
]

{ #category : #controle }
Ev3Motor >> setStepSpeed: speed rampUpSteps: rampUpSteps rampDownSteps: rampDownSteps constantSpeedSteps: constantSpeedSteps brake: aBoolBrake reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputStepSpeed).
	command appendByte: self daisyChainLayer.
	command addShortValue: self bitField.
	command addLongByteValue: speed.
	command addShortValue: rampUpSteps.
	command addInt16Value: constantSpeedSteps.
	command addInt16Value: rampDownSteps.
	
	aBoolBrake ifTrue: [ 
		command addShortValue: 1.
	] ifFalse: [ 
		command addShortValue: 0.
	].
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #nottested }
Ev3Motor >> setStepSync: speed turnRatio: turnRatio steps: steps brake: aBoolBrake reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputStepSync).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	command addLongByteValue: speed.
	command addInt16Value: turnRatio.
	command addInt32Value: steps.
	
	aBoolBrake ifTrue: [ 
		command addShortValue: 1.
	] ifFalse: [ 
		command addShortValue: 0.
	].
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #nottested }
Ev3Motor >> setTimePower: power constantSpeedTime: constantSpeedTime brake: aBoolBrake [

	^ self setTimePower: power constantSpeedTime: constantSpeedTime brake: aBoolBrake reply: false
]

{ #category : #nottested }
Ev3Motor >> setTimePower: power constantSpeedTime: constantSpeedTime brake: aBoolBrake reply: aBool [

	^ self setTimePower: power rampUpTime: 0 rampDownTime: 10 constantSpeedTime: constantSpeedTime brake: aBoolBrake reply: aBool
]

{ #category : #nottested }
Ev3Motor >> setTimePower: power rampUpTime: rampUpTime rampDownTime: rampDownTime constantSpeedTime: constantSpeedTime brake: aBoolBrake reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputTimePower).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	command addShortValue: power.
	command addInt32Value: rampUpTime.
	command addInt32Value: constantSpeedTime.
	command addInt32Value: rampDownTime.
	
	aBoolBrake ifTrue: [ 
		command addShortValue: 1.
	] ifFalse: [ 
		command addShortValue: 0.
	].
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #nottested }
Ev3Motor >> setTimeSpeed: speed constantSpeedTime: constantSpeedTime  brake: aBoolBrake [

	^ self setTimeSpeed: speed constantSpeedTime: constantSpeedTime  brake: aBoolBrake reply: false
]

{ #category : #nottested }
Ev3Motor >> setTimeSpeed: speed constantSpeedTime: constantSpeedTime  brake: aBoolBrake reply: aBool [

	^ self setTimeSpeed: speed rampUpTime: 0 rampDownTime: 10 constantSpeedTime: constantSpeedTime  brake: aBoolBrake reply: aBool
]

{ #category : #nottested }
Ev3Motor >> setTimeSpeed: speed rampUpTime: rampUpTime rampDownTime: rampDownTime constantSpeedTime: constantSpeedTime  brake: aBoolBrake reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputTimeSpeed).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	command addLongByteValue: speed.
	command addInt32Value: rampUpTime.
	command addInt32Value: constantSpeedTime.
	command addInt32Value: rampDownTime.
	
	aBoolBrake ifTrue: [ 
		command addShortValue: 1.
	] ifFalse: [ 
		command addShortValue: 0.
	].
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #nottested }
Ev3Motor >> setTimeSync: speed turnRatio: turnRatio time: timeInMs brake: aBoolBrake reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputTimeSync).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	command addLongByteValue: speed.
	command addInt16Value: turnRatio.
	command addInt32Value: timeInMs.
	
	aBoolBrake ifTrue: [ 
		command addShortValue: 1.
	] ifFalse: [ 
		command addShortValue: 0.
	].
	
	reply := self brick sendCommand: command withReply: aBool.
	^ reply
]

{ #category : #nottested }
Ev3Motor >> setType: aType reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputSetType).
	command appendByte: self daisyChainLayer.
	command appendByte: self inputBitField.
	command addShortValue: aType.
	
	reply := self brick sendCommand: command withReply: aBool.
	^ reply
]

{ #category : #'external api' }
Ev3Motor >> speed: aSpeed [

	^ self speed: aSpeed reply: false.
]

{ #category : #controle }
Ev3Motor >> speed: aSpeed reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputSpeed).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	command addLongByteValue: aSpeed.

	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'external api' }
Ev3Motor >> start [

	^ self startReply: false.
]

{ #category : #'external api' }
Ev3Motor >> startAtSpeed: aSpeed [

	^ self startAtSpeed: aSpeed reply: false.
]

{ #category : #controle }
Ev3Motor >> startAtSpeed: aSpeed reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputSpeed).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	command addLongByteValue: aSpeed.
	command appendByte: (Ev3Command byteCodes at: #OutputStart).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	
	reply := self brick sendCommand: command withReply: aBool.
	^ reply
]

{ #category : #controle }
Ev3Motor >> startReply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputStart).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'external api' }
Ev3Motor >> stop [

	^ self stopBrake: false reply: false.
]

{ #category : #'external api' }
Ev3Motor >> stopBrake: aBoolForBrake reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputStop).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	command addShortValue: (aBoolForBrake ifTrue:[1] ifFalse:[0]).
	
	reply := self brick sendCommand: command withReply: aBool.
	^ reply
]

{ #category : #nottested }
Ev3Motor >> waitForReadyReply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #OutputReady).
	command appendByte: self daisyChainLayer.
	command appendByte: self bitField.
	
	reply := self brick sendCommand: command withReply: aBool.
	^ reply
]
