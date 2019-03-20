Class {
	#name : #Ev3Mailbox,
	#superclass : #Ev3Block,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3Mailbox >> sendMailTo: emailAddr data: byteArray reply: aBool [

	|command reply|
	command := Ev3SystemCommand newCommand: (Ev3SystemCommand systemCommand at: #WriteMailbox)  sequence: (self currentSequenceNumber) reply: aBool.
	
	command addLongByteValue: emailAddr size.
	command appendString: emailAddr constantParameterType: (Ev3Command constantParameterType at: #Value ).
	command addInt16Value: byteArray size +1.
	command appendString: byteArray constantParameterType: (Ev3Command constantParameterType at: #Value ).
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]
