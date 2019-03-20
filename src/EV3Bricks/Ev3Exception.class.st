Class {
	#name : #Ev3Exception,
	#superclass : #Error,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3Exception class >> error: message [
	self new signal: message
]
