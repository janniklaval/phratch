Class {
	#name : #Ev3ReplyInterpreter,
	#superclass : #Object,
	#instVars : [
		'data'
	],
	#category : #EV3Bricks
}

{ #category : #'instance-creation' }
Ev3ReplyInterpreter class >> newData: aByteArray [ 

	^ self newWithData: aByteArray
]

{ #category : #'instance-creation' }
Ev3ReplyInterpreter class >> newWithData: aByteArray [ 

	|newReply |
	
	newReply := self new.
	newReply data: (aByteArray copyFrom: 3 to: aByteArray size).
	
	newReply data size < 3 ifTrue:[
		Ev3Exception error: 'Invalid EV3 Reply'.
	].
	(Ev3BrickCommand commandType values includes: (newReply data at: 3)) ifFalse:[
		Ev3Exception error: 'Invalid EV3 Reply'.
	].
	
	^ newReply
]

{ #category : #accessing }
Ev3ReplyInterpreter >> at: anInt [
	^ data at: anInt
]

{ #category : #'error checking' }
Ev3ReplyInterpreter >> checkForError: expectedSequenceNumber [

		self hasError ifTrue:[
			self signal: 'error in reply'.
		].
	
		self sequenceNumber = expectedSequenceNumber ifFalse:[
			Ev3Exception new signal: ('WrongSequenceNumber value: ', self sequenceNumber asString, ' expected: ',  expectedSequenceNumber asString).
		].
		^true
]

{ #category : #accessing }
Ev3ReplyInterpreter >> commandType [ 

	^ self data at: 3.
]

{ #category : #converting }
Ev3ReplyInterpreter >> commandTypeAsString [

	^ (Ev3BrickCommand commandType keyAtValue: self commandType) asString.
]

{ #category : #accessing }
Ev3ReplyInterpreter >> data [
	^ data
]

{ #category : #accessing }
Ev3ReplyInterpreter >> data: anObject [
	data := anObject
]

{ #category : #'getting data' }
Ev3ReplyInterpreter >> getByteAt: anOffset [
	
	^ data at: anOffset
]

{ #category : #'getting data' }
Ev3ReplyInterpreter >> getDataFrom: anOffset [
	
	^ data copyFrom: anOffset to: data size.
]

{ #category : #'getting data' }
Ev3ReplyInterpreter >> getDataStringFrom: anOffset [
	
	|s|
	anOffset > data size ifTrue:[^''].
	s := self getDataStringFrom: anOffset size: (data size - anOffset).

	^s
]

{ #category : #'getting data' }
Ev3ReplyInterpreter >> getDataStringFrom: anOffset size: aSize [
	
	|s size|
	size := aSize.
	anOffset + size > data size ifTrue:[size := data size - anOffset].
	s :=  String new writeStream.
	anOffset to: (anOffset + size) do:[:i |
		s nextPutAll: (String value: (self at: i)) 
	].

	^s contents
]

{ #category : #'getting data' }
Ev3ReplyInterpreter >> getFloatAt: anOffset [
	
	^Float fromIEEE32Bit:(self getUInt32At: anOffset)
]

{ #category : #'getting data' }
Ev3ReplyInterpreter >> getInt16At: anOffset [
	
	|int|
	int := self data copyFrom: anOffset to: anOffset + 1.
	^ (int) shortAt: 1 bigEndian: false.
]

{ #category : #'getting data' }
Ev3ReplyInterpreter >> getInt32At: anOffset [
	
	|int|
	int := self data copyFrom: anOffset to: anOffset + 3.
	^ int longAt: 1 bigEndian: false.
]

{ #category : #'getting data' }
Ev3ReplyInterpreter >> getSByteAt: anOffset [
	
	|value|
	value := self getByteAt: anOffset.
	value < 128 
		ifTrue:[ ^ value]
		ifFalse: [^ (255 - value)*(-1) ] 
]

{ #category : #'getting data' }
Ev3ReplyInterpreter >> getUInt16At: anOffset [
	
	|int|
	int := self getInt16At: anOffset.
	int < 0 ifTrue: [ ^ (2 raisedTo: 16) + int].
	^int
]

{ #category : #'getting data' }
Ev3ReplyInterpreter >> getUInt32At: anOffset [
	
	|int|
	int := self getInt32At: anOffset.
	int < 0 ifTrue: [ ^ (2 raisedTo: 32) + int].
	^int
]

{ #category : #'error checking' }
Ev3ReplyInterpreter >> hasError [

	| type |
	type := self commandType.
	((type = (Ev3BrickCommand commandType at: #DirectReply)) or:[ (type = (Ev3BrickCommand commandType at: #SystemReply))]) ifTrue:[
		^false
	].
	^ true
]

{ #category : #printing }
Ev3ReplyInterpreter >> printString [

	| s |
	s := String new writeStream.
	s nextPutAll: 'Command: '.
	s nextPutAll: self commandTypeAsString.
	s nextPutAll: String cr.
	s nextPutAll:'Length: '.
	s nextPutAll: self size asString.
	s nextPutAll: String cr.
	1 to: self size do:[ :i |
		s nextPutAll: 'Reply['.
		s nextPutAll: i asString.
		s nextPutAll: ']: '.
		s nextPutAll: (data at: i) asString.
		s nextPutAll: String cr.
	].
	^s
]

{ #category : #'getting data' }
Ev3ReplyInterpreter >> sequenceNumber [ 

	^ 16r0000 | (self data first) | ((self data at: 2) << 4).
]

{ #category : #'getting data' }
Ev3ReplyInterpreter >> size [
	^ data size
]
