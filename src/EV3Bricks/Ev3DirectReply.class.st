Class {
	#name : #Ev3DirectReply,
	#superclass : #Ev3ReplyInterpreter,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3DirectReply class >> newWithData: aByteArray [ 

	| reply |
	reply := super newWithData: aByteArray.
	
	((reply data at: 3) = (Ev3BrickCommand commandType at: #DirectReply) or: [(reply data at: 3) = (Ev3BrickCommand commandType at: #DirectReplyWithError)]) ifFalse:[
		^ Ev3Exception signal: 'The reply has not the expected type'.
	].

	^ reply 
]

{ #category : #'as yet unclassified' }
Ev3DirectReply >> replyData [

	data size > 3 ifTrue:[
		^ self getDataFrom: 4.
	] ifFalse:[
		^ #[]
	]
]
