Class {
	#name : #Ev3SystemReply,
	#superclass : #Ev3ReplyInterpreter,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3SystemReply class >> errorType [
	^ {
	#Success -> 0.
	#UnknownHandle -> 16r01.
	#HandleNotReady -> 16r02.
	#CorruptFile -> 16r03.
	#NoHandlesAvailable -> 16r04.
	#NoPermissions -> 16r05.
	#IllegalPath -> 16r06.
	#FileExits -> 16r07.
	#EndOfFile -> 16r08.
	#SizeError -> 16r09.
	#UnknownError -> 16r0a.
	#IllegalFilename -> 16r0b.
	#IllegalConnection -> 16r0c.
	#WrongNumberOfBytes -> 16r40.
	#WrongSequenceNumber -> 16r41} asDictionary
]

{ #category : #'as yet unclassified' }
Ev3SystemReply class >> newWithData: aByteArray [ 

	| reply |
	reply := super newWithData: aByteArray.
	
	((reply data at: 3) = (Ev3BrickCommand commandType at: #SystemReply) or: [(reply data at: 3) = (Ev3BrickCommand commandType at: #SystemReplyWithError)]) ifFalse:[
		^ Ev3Exception signal: 'The reply has not the expected type'.
	].

	^ reply 
]

{ #category : #'error checking' }
Ev3SystemReply >> errorCode [

	^ data at: 5.
]

{ #category : #'error checking' }
Ev3SystemReply >> errorType [

	^ self class errorType keyAtValue: self errorCode.
]

{ #category : #'error checking' }
Ev3SystemReply >> printString [

	| s |
	s := String new writeStream.
	s nextPutAll: 'Command: '.
	s nextPutAll: self commandTypeAsString.
	s nextPutAll: String cr.
	s nextPutAll:'Length: '.
	s nextPutAll: self size asString.
	s nextPutAll: String cr.
	s nextPutAll: 'Errorcode: '.
	s nextPutAll: self class errorType asString.
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
Ev3SystemReply >> systemReplyCode [ 

	^ self data at: 4.
]

{ #category : #'error checking' }
Ev3SystemReply >> systemReplyData [

	data size > 5 ifTrue:[
		^ self getDataFrom: 6.
	] ifFalse:[
		^ #[]
	]
]

{ #category : #'getting data' }
Ev3SystemReply >> systemReplyType [ 

	^Ev3SystemCommand systemCommand keyAtValue: self systemReplyCode
]
