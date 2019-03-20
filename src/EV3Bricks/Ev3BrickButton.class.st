Class {
	#name : #Ev3BrickButton,
	#superclass : #Ev3Block,
	#instVars : [
		'buttonField'
	],
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3BrickButton class >> brickButton [
	^ { #None -> 0 . #Up -> 1 . #Enter -> 2 . #Down -> 3.
	#Right -> 4.
	#Left -> 5.
	#Back -> 6.
	#Any -> 7.
	} asDictionary.
]

{ #category : #accessing }
Ev3BrickButton >> buttonField [
	^ buttonField
]

{ #category : #accessing }
Ev3BrickButton >> buttonField: anObject [
	buttonField := anObject
]

{ #category : #accessing }
Ev3BrickButton >> isPressed [

	^ self isPressedIndex: 0 reply: true
]

{ #category : #accessing }
Ev3BrickButton >> isPressedIndex: ind reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #UIButton).
	command appendByte: (self buttonField).
	command addLongUInt16GlobalVariableAtAddress: ind.
					
	reply := self brick sendCommand: command withReply: aBool.
	^(reply at: 3) = self buttonField
]
