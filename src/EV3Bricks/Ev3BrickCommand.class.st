"
Command transcripter for MindStorms. Pay attention that the coding format is littleEndian.

"
Class {
	#name : #Ev3BrickCommand,
	#superclass : #Object,
	#instVars : [
		'data',
		'replyRequired',
		'sequenceNumber',
		'commandType'
	],
	#category : #EV3Bricks
}

{ #category : #accessing }
Ev3BrickCommand class >> commandType [
	^ {#DirectCommand -> 16r00. #SystemCommand -> 16r01. #DirectReply -> 16r02. #SystemReply -> 16r03. #DirectReplyWithError -> 16r04. #SystemReplyWithError -> 16r05} asDictionary.
]

{ #category : #building }
Ev3BrickCommand >> appendByte: anObject [ 
	
	data nextPutAll: (anObject printStringBase: 16 nDigits: 2)
]

{ #category : #building }
Ev3BrickCommand >> appendByteArray: aByteArray [
	
	self appendByteArray: aByteArray offSet:1 size: aByteArray size
]

{ #category : #building }
Ev3BrickCommand >> appendByteArray: aByteArray offSet: offset size: anInt [ 
	
	(aByteArray copyFrom: offset to: (offset+anInt -1)) do:[:i |
		data nextPutAll:  (i printStringBase: 16 nDigits: 2).
	].
]

{ #category : #building }
Ev3BrickCommand >> appendFloat: aFloat [
	| result |
	result := (aFloat closeTo: 0.0)
		ifTrue: [ '00000000' ]
		ifFalse: [ aFloat asFloat asIEEE32BitWord printStringBase: 16 ].
	data nextPutAll: (result copyFrom: 7 to: 8).
	data nextPutAll: (result copyFrom: 5 to: 6).
	data nextPutAll: (result copyFrom: 3 to: 4).
	data nextPutAll: (result copyFrom: 1 to: 2)
]

{ #category : #building }
Ev3BrickCommand >> appendInt16: anInteger [
 	| hex |
	hex := anInteger printStringBase: 16  nDigits:  4.
	data nextPutAll: (hex copyFrom: 3 to: 4).
	data nextPutAll: (hex copyFrom: 1 to: 2).
]

{ #category : #building }
Ev3BrickCommand >> appendInt32: anInteger [
 	| hex myInt |
	
	myInt:= anInteger.
	myInt < 0 ifTrue:[
		myInt := (2 raisedTo: 32) + myInt.
	].
	hex := String new writeStream.
	myInt asInteger printOn: hex base: 16  nDigits:  8.
	
	data nextPutAll: (hex contents copyFrom: 7 to: 8).
	data nextPutAll: (hex contents copyFrom: 5 to: 6).
	data nextPutAll: (hex contents copyFrom: 3 to: 4).
	data nextPutAll: (hex contents copyFrom: 1 to: 2).
]

{ #category : #building }
Ev3BrickCommand >> appendSByte: anObject [ 
	
	self appendByte: anObject.
]

{ #category : #building }
Ev3BrickCommand >> appendString: anObject [ 

	anObject do: [:a | a asCharacter asInteger printOn: data base: 16 nDigits: 2].
	16r00 printOn: data base: 16 nDigits: 2.
	
]

{ #category : #building }
Ev3BrickCommand >> appendString: aString constantParameterType: aType [

	self appendConstant: aType follow: (Ev3Command followType at: #TerminatedString2).
	self appendString: aString.
]

{ #category : #building }
Ev3BrickCommand >> appendStringNoTermination: anObject [ 

	anObject do: [:a | a asCharacter asInteger printOn: data base: 16 nDigits: 2].

	
]

{ #category : #building }
Ev3BrickCommand >> appendUInt16: anInteger [
 	
	self appendInt16: anInteger
]

{ #category : #building }
Ev3BrickCommand >> appendUInt32: anInteger [
 	
	self appendInt32: anInteger
]

{ #category : #accessing }
Ev3BrickCommand >> commandType [
	^ commandType
]

{ #category : #accessing }
Ev3BrickCommand >> commandType: anObject [
	commandType := anObject
]

{ #category : #accessing }
Ev3BrickCommand >> data [
	^ data
]

{ #category : #accessing }
Ev3BrickCommand >> data: anObject [
	data := anObject
]

{ #category : #accessing }
Ev3BrickCommand >> header [

	|headerBuild|
	headerBuild := Ev3Command new.
	headerBuild appendByte: ((self size / 2) & 16r00ff).
	headerBuild appendByte: (((self size / 2) & 16rff00) >> 8).
	^headerBuild data contents
]

{ #category : #initialization }
Ev3BrickCommand >> initialize [

	super initialize.
	data := String new writeStream.
	replyRequired := false.
]

{ #category : #building }
Ev3BrickCommand >> isDirectCommand [

	^ false
]

{ #category : #building }
Ev3BrickCommand >> isSystemCommand [

	^ false
]

{ #category : #accessing }
Ev3BrickCommand >> prepareToSend [

	|dataToSend |
	
	dataToSend:= String new writeStream.
	dataToSend nextPutAll: self header.
	dataToSend nextPutAll: self data contents.
	^ ByteArray readHexFrom: dataToSend contents
]

{ #category : #accessing }
Ev3BrickCommand >> replyRequired [
	^ replyRequired
]

{ #category : #accessing }
Ev3BrickCommand >> replyRequired: anObject [
	replyRequired := anObject
]

{ #category : #accessing }
Ev3BrickCommand >> sequenceNumber [
	^ sequenceNumber
]

{ #category : #accessing }
Ev3BrickCommand >> sequenceNumber: anObject [
	sequenceNumber := anObject
]

{ #category : #accessing }
Ev3BrickCommand >> size [ 
	^ data size
]
