Class {
	#name : #Ev3Block,
	#superclass : #Object,
	#instVars : [
		'brick'
	],
	#category : #EV3Bricks
}

{ #category : #'instance-creation' }
Ev3Block class >> newWithBrick: aBrick [
	|aBlock|
	
	aBlock := self new.
	aBlock brick: aBrick.
	^ aBlock
]

{ #category : #accessing }
Ev3Block >> brick [
	
	^ brick
]

{ #category : #accessing }
Ev3Block >> brick: anObject [
	
	brick := anObject
]

{ #category : #accessing }
Ev3Block >> currentSequenceNumber [

	^ self brick currentSequenceNumber
]

{ #category : #accessing }
Ev3Block >> daisyChainLayer [
	
	^ self brick daisyChainLayer
]
