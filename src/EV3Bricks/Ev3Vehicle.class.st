"
ev3 := Ev3Vehicle newIp: '192.168.2.4' port: 57887 serial: '0016533f8491' daisyChain: #EV3.
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
ev3 moveSpeed: 50 degrees: 200 reply: true.
ev3 motorC speed: 0.
ev3 motorC start.
ev3 motorC stop.

ev3 motorA speed: 10.
ev3 motorA start.
ev3 motorA stop.

16r7b

ev3 motorA startAtSpeed: 10.
ev3 motorA stop.


ev3 getSensorTypes.

ev3 sensor4 setMode: #Mode0.
ev3 sensor4 getRead  
ev3 sensor4 getBumbs
"
Class {
	#name : #Ev3Vehicle,
	#superclass : #Ev3Brick,
	#instVars : [
		'leftPort',
		'rightPort'
	],
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3Vehicle >> handleLeftForwardSpeed: speed percent: turnPercent degrees: degrees reply: aBool [

	(leftPort isReversed not and:[rightPort isReversed not]) ifTrue: [ 
		^motorSync startSpeed: speed turnRatio: (-1 * turnPercent) degrees: degrees reply: aBool
	].
	(leftPort isReversed not and:[rightPort isReversed]) ifTrue: [ 
		^motorSync startSpeed: (-1 * speed) turnRatio: (-200 + turnPercent) degrees: degrees reply: aBool
	].
	(leftPort isReversed  and:[rightPort isReversed not]) ifTrue: [ 
		^motorSync startSpeed: speed turnRatio: (-200 + turnPercent) degrees: degrees reply: aBool
	].
	^motorSync startSpeed: (-1 * speed) turnRatio: (-1 * turnPercent) degrees: degrees reply: aBool
	
]

{ #category : #'as yet unclassified' }
Ev3Vehicle >> handleLeftReverseSpeed: speed percent: turnPercent degrees: degrees reply: aBool [

	(leftPort isReversed not and:[rightPort isReversed not]) ifTrue: [ 
		^motorSync startSpeed: (-1 * speed) turnRatio: (-1 * turnPercent) degrees: degrees reply: aBool
	].
	(leftPort isReversed not and:[rightPort isReversed]) ifTrue: [ 
		^motorSync startSpeed: speed turnRatio: (-200 + turnPercent) degrees: degrees reply: aBool
	].
	(leftPort isReversed  and:[rightPort isReversed not]) ifTrue: [ 
		^motorSync startSpeed: (-1 * speed) turnRatio: (-200 + turnPercent) degrees: degrees reply: aBool
	].
	^motorSync startSpeed: speed turnRatio: (-1 * turnPercent) degrees: degrees reply: aBool
	
]

{ #category : #'as yet unclassified' }
Ev3Vehicle >> handleRightForwardSpeed: speed percent: turnPercent degrees: degrees reply: aBool [

	(leftPort isReversed not and:[rightPort isReversed not]) ifTrue: [ 
		^motorSync startSpeed: speed turnRatio: turnPercent degrees: degrees reply: aBool
	].
	(leftPort isReversed not and:[rightPort isReversed]) ifTrue: [ 
		^motorSync startSpeed: speed turnRatio: (200 - turnPercent) degrees: degrees reply: aBool
	].
	(leftPort isReversed  and:[rightPort isReversed not]) ifTrue: [ 
		^motorSync startSpeed: (-1 * speed) turnRatio: (200 - turnPercent) degrees: degrees reply: aBool
	].
	^motorSync startSpeed: (-1 * speed) turnRatio: turnPercent degrees: degrees reply: aBool
	
]

{ #category : #'as yet unclassified' }
Ev3Vehicle >> handleRightReverseSpeed: speed percent: turnPercent degrees: degrees reply: aBool [

	(leftPort isReversed not and:[rightPort isReversed not]) ifTrue: [ 
		^motorSync startSpeed: (-1 * speed) turnRatio: turnPercent degrees: degrees reply: aBool
	].
	(leftPort isReversed not and:[rightPort isReversed]) ifTrue: [ 
		^motorSync startSpeed: (-1 * speed) turnRatio: (200 - turnPercent) degrees: degrees reply: aBool
	].
	(leftPort isReversed  and:[rightPort isReversed not]) ifTrue: [ 
		^motorSync startSpeed: speed turnRatio: (200 - turnPercent) degrees: degrees reply: aBool
	].
	^motorSync startSpeed: speed turnRatio: turnPercent degrees: degrees reply: aBool
	
]

{ #category : #'as yet unclassified' }
Ev3Vehicle >> handleSpinLeftSpeed: speed degrees: degrees [
	^ self handleSpinLeftSpeed: speed degrees: degrees reply: false
]

{ #category : #'as yet unclassified' }
Ev3Vehicle >> handleSpinLeftSpeed: speed degrees: degrees reply: aBool [

	(leftPort isReversed not and:[rightPort isReversed not]) ifTrue: [ 
		^motorSync startSpeed: speed turnRatio: -200 degrees: degrees reply: aBool
	].
	(leftPort isReversed not and:[rightPort isReversed]) ifTrue: [ 
		^motorSync startSpeed: (-1 * speed) turnRatio: 0 degrees: degrees reply: aBool
	].
	(leftPort isReversed  and:[rightPort isReversed not]) ifTrue: [ 
		^motorSync startSpeed: speed turnRatio: 0 degrees: degrees reply: aBool
	].
	^motorSync startSpeed: (-1 * speed) turnRatio: -200 degrees: degrees reply: aBool
	
]

{ #category : #'as yet unclassified' }
Ev3Vehicle >> handleSpinRightSpeed: speed degrees: degrees reply: aBool [

	(leftPort isReversed not and:[rightPort isReversed not]) ifTrue: [ 
		^motorSync startSpeed: speed turnRatio: 200 degrees: degrees reply: aBool
	].
	(leftPort isReversed not and:[rightPort isReversed]) ifTrue: [ 
		^motorSync startSpeed: speed turnRatio: 0 degrees: degrees reply: aBool
	].
	(leftPort isReversed  and:[rightPort isReversed not]) ifTrue: [ 
		^motorSync startSpeed: (-1 * speed) turnRatio: 0 degrees: degrees reply: aBool
	].
	^motorSync startSpeed: (-1 * speed) turnRatio: 200 degrees: degrees reply: aBool
	
]

{ #category : #accessing }
Ev3Vehicle >> initialize [ 
	
	super initialize.
	leftPort := self motorA.
	rightPort := self motorD.
]

{ #category : #accessing }
Ev3Vehicle >> leftPort [
	^ leftPort
]

{ #category : #accessing }
Ev3Vehicle >> leftPort: anObject [
	leftPort := anObject.
	motorSync bitField: (leftPort bitField | rightPort bitField).
]

{ #category : #'as yet unclassified' }
Ev3Vehicle >> moveSpeed: speed degrees: degrees [


	^ self moveSpeed: speed degrees: degrees reply: false
]

{ #category : #'as yet unclassified' }
Ev3Vehicle >> moveSpeed: speed degrees: degrees reply: aBool [

	(leftPort isReversed not and:[rightPort isReversed not]) ifTrue: [ 
		^motorSync startSpeed: speed turnRatio: -0 degrees: degrees reply: aBool
	].
	(leftPort isReversed not and:[rightPort isReversed]) ifTrue: [ 
		^motorSync startSpeed: speed turnRatio: 200 degrees: degrees reply: aBool
	].
	(leftPort isReversed  and:[rightPort isReversed not]) ifTrue: [ 
		^motorSync startSpeed: speed turnRatio: -200 degrees: degrees reply: aBool
	].
	^motorSync startSpeed: (-1 * speed) turnRatio: 0 degrees: degrees reply: aBool
	
]

{ #category : #accessing }
Ev3Vehicle >> rightPort [
	^ rightPort
]

{ #category : #accessing }
Ev3Vehicle >> rightPort: anObject [
	rightPort := anObject.
	motorSync bitField: (leftPort bitField | rightPort bitField).
]

{ #category : #'initialize-release' }
Ev3Vehicle >> syncMotorsLeft: aLeftMotor right: aRightMotor [

	self leftPort: aLeftMotor.
	self rightPort: aRightMotor.
]

{ #category : #'as yet unclassified' }
Ev3Vehicle >> turnLeftForwardSpeed: speed percent: turnPercent degrees: degrees [
	
	^ self turnLeftForwardSpeed: speed percent: turnPercent degrees: degrees reply: false
]

{ #category : #'as yet unclassified' }
Ev3Vehicle >> turnLeftForwardSpeed: speed percent: turnPercent degrees: degrees reply: aBool [
	leftPort bitField < rightPort bitField ifTrue:[
		self handleLeftForwardSpeed: speed percent: turnPercent degrees: degrees reply: aBool.
	] ifFalse: [
		self handleRightForwardSpeed: speed percent: turnPercent degrees: degrees reply: aBool.
	].

]

{ #category : #'as yet unclassified' }
Ev3Vehicle >> turnLefttReverseSpeed: speed percent: turnPercent degrees: degrees [

	^ self turnLefttReverseSpeed: speed percent: turnPercent degrees: degrees reply: false
]

{ #category : #'as yet unclassified' }
Ev3Vehicle >> turnLefttReverseSpeed: speed percent: turnPercent degrees: degrees reply: aBool [
	leftPort bitField < rightPort bitField ifTrue:[
		self handleLeftReverseSpeed: speed percent: turnPercent degrees: degrees reply: aBool.
	] ifFalse: [
		self handleRightReverseSpeed: speed percent: turnPercent degrees: degrees reply: aBool.
	].

]

{ #category : #'as yet unclassified' }
Ev3Vehicle >> turnRightForwardSpeed: speed percent: turnPercent degrees: degrees [

	^ self turnRightForwardSpeed: speed percent: turnPercent degrees: degrees reply: false
]

{ #category : #'as yet unclassified' }
Ev3Vehicle >> turnRightForwardSpeed: speed percent: turnPercent degrees: degrees reply: aBool [
	leftPort bitField < rightPort bitField ifTrue:[
		self handleRightForwardSpeed: speed percent: turnPercent degrees: degrees reply: aBool.
	] ifFalse: [
		self handleLeftForwardSpeed: speed percent: turnPercent degrees: degrees reply: aBool.
	].

]

{ #category : #'as yet unclassified' }
Ev3Vehicle >> turnRightReverseSpeed: speed percent: turnPercent degrees: degrees [ 

	^ self turnRightReverseSpeed: speed percent: turnPercent degrees: degrees reply: false

]

{ #category : #'as yet unclassified' }
Ev3Vehicle >> turnRightReverseSpeed: speed percent: turnPercent degrees: degrees reply: aBool [
	leftPort bitField < rightPort bitField ifTrue:[
		self handleRightReverseSpeed: speed percent: turnPercent degrees: degrees reply: aBool.
	] ifFalse: [
		self handleLeftReverseSpeed: speed percent: turnPercent degrees: degrees reply: aBool.
	].

]
