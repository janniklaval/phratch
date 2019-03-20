Class {
	#name : #Ev3MotorSync,
	#superclass : #Ev3Motor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3MotorSync >> startSpeed: speed turnRatio: turnRatio [	
	^ self startSpeed: speed turnRatio: turnRatio degrees: 0 reply: false.
]

{ #category : #'as yet unclassified' }
Ev3MotorSync >> startSpeed: speed turnRatio: turnRatio degrees: degrees [
	^ self startSpeed: speed turnRatio: turnRatio degrees: degrees reply: false.
]

{ #category : #'as yet unclassified' }
Ev3MotorSync >> startSpeed: speed turnRatio: turnRatio degrees: degrees reply: bool [
	^ self stepSyncSpeed: speed turnRatio: turnRatio steps: degrees brake: false reply: bool.
]

{ #category : #'as yet unclassified' }
Ev3MotorSync >> stepSyncSpeed: speed turnRatio: turnRatio steps: steps brake: brake reply: reply [
		
	^self setStepSync: speed turnRatio: turnRatio steps: steps brake: brake reply: reply
		
]

{ #category : #'as yet unclassified' }
Ev3MotorSync >> timeSyncSpeed: speed turnRatio: turnRatio time: timeInMs brake: brake [
		
	^self timeSyncSpeed: speed turnRatio: turnRatio time: timeInMs brake: brake reply: false
]

{ #category : #'as yet unclassified' }
Ev3MotorSync >> timeSyncSpeed: speed turnRatio: turnRatio time: timeInMs brake: brake reply: reply [
		
	^self setTimeSync: speed turnRatio: turnRatio time: timeInMs brake: brake reply: reply
]
