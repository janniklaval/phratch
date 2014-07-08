Class {
	#name : #Ev3SystemCommand,
	#superclass : #Ev3BrickCommand,
	#instVars : [
		'systemCommand'
	],
	#category : #EV3Bricks
}

{ #category : #'instance creation' }
Ev3SystemCommand class >> newCommand: aSysCommand sequence: anIntSeq reply: aBool [

	|newCmd|
	newCmd := self new.
	newCmd systemCommand: aSysCommand.	
	newCmd commandType: (Ev3BrickCommand commandType at: #SystemCommand).
	newCmd sequenceNumber: anIntSeq.
	newCmd appendInt16: anIntSeq.
	
	aBool ifTrue:[
		newCmd replyRequired: true.
		newCmd appendByte: newCmd commandType.
	] ifFalse:[
		newCmd replyRequired: false.
		newCmd appendByte: (newCmd commandType | 16r80).
	].
	newCmd appendByte: aSysCommand.
	
	^newCmd
]

{ #category : #accessing }
Ev3SystemCommand class >> systemCommand [
	^ {	#None -> 16r00.
		#BeginDownload -> 16r92.
		#ContinueDownload -> 16r93.
		#BeginUpload -> 16r94.
		#ContinueUpload -> 16r95.
		#BeginGetFile -> 16r96.
		#ContinueGetFile -> 16r97.
		#CloseFileHandle -> 16r98.
		#ListFiles -> 16r99.
		#ContinueListFiles -> 16r9a.
		#CreateDirectory -> 16r9b.
		#DeleteFile -> 16r9c.
		#ListOpenHandles -> 16r9d.
		#WriteMailbox -> 16r9e.
		#BluetoothPin -> 16r9f.
		#EnterFirmwareUpdate -> 16ra0} asDictionary.
]

{ #category : #accessing }
Ev3SystemCommand >> isDirectCommand [

	^ false
]

{ #category : #accessing }
Ev3SystemCommand >> isSystemCommand [

	^ true
]

{ #category : #accessing }
Ev3SystemCommand >> systemCommand [
	^ systemCommand
]

{ #category : #accessing }
Ev3SystemCommand >> systemCommand: anObject [
	systemCommand := anObject
]
