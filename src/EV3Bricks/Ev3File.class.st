Class {
	#name : #Ev3File,
	#superclass : #Ev3Block,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3File class >> fileExtension [
	^ { 
	#Firmware -> 0.
	#Program -> '.rbf'.
	#OnBrickProgram -> 0.
	#TryMeProgram -> 0.
	#Sound -> '.rsf'.
	#Graphics -> '.rgf'.
	#Datalog -> '.rdf'.
	#Unknown -> 0
	} asDictionary.
]

{ #category : #'as yet unclassified' }
Ev3File class >> fileType [
	^ { 
	#Firmware -> 0.
	#Program -> 1.
	#OnBrickProgram -> 2.
	#TryMeProgram -> 3.
	#Sound -> 4.
	#Graphics -> 5.
	#Datalog -> 6.
	#Unknown -> 7
	} asDictionary.
]

{ #category : #'as yet unclassified' }
Ev3File >> closeFile: aHandle reply: aBool [

	|command reply|
	command := Ev3SystemCommand newCommand: (Ev3SystemCommand systemCommand at: #CloseFileHandle)  sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: aHandle.
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3File >> createDirectory: aPath reply: aBool [

	|command reply|
	command := Ev3SystemCommand newCommand: (Ev3SystemCommand systemCommand at: #CreateDirectory)  sequence: (self currentSequenceNumber) reply: aBool.
	
	command appendString: aPath.
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3File >> deletFile: aFileName reply: aBool [

	|command reply|
	command := Ev3SystemCommand newCommand: (Ev3SystemCommand systemCommand at: #DeleteFile)  sequence: (self currentSequenceNumber) reply: aBool.
	
	command appendString: aFileName.
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3File >> getFile: aFileName [

	|command reply  chunkSize handle fileSize data bytesRead fileData bytesToWrite |
	chunkSize := 65534.
	command := Ev3SystemCommand newCommand: (Ev3SystemCommand systemCommand at: #BeginGetFile)  sequence: (self currentSequenceNumber) reply: true.
	command appendUInt16: chunkSize.
	command appendString: aFileName.
	
	reply := self brick sendCommand: command withReply: true.
	
	fileSize := (reply getInt32At: 4).
	handle := reply getByteAt: 8.
	data := reply getDataFrom: 9.
	bytesRead := data size.
	bytesToWrite := 1.
	fileData := ByteArray new: fileSize.
	data do:[:a |
		fileData byteAt: bytesToWrite put: a.
		bytesToWrite := bytesToWrite + 1.
	].

	[bytesRead < fileSize] whileTrue:[
		|sizeToRead|
		sizeToRead := chunkSize min: (fileSize - bytesRead).
		
		command := Ev3SystemCommand newCommand: (Ev3SystemCommand systemCommand at: #ContinueGetFile)  sequence: 100 reply: true.
		command appendByte: handle.
		command appendUInt16: sizeToRead.
		reply := self brick sendCommand: command withReply: true.
		data := reply getDataFrom: 5.
		bytesRead := bytesRead + sizeToRead.
		data do:[:a |
			fileData byteAt: bytesToWrite put: a.
			bytesToWrite := bytesToWrite + 1.
		].
	].
	fileData inspect.
	^fileData asByteArray
]

{ #category : #'as yet unclassified' }
Ev3File >> listFilesFromPath: aPath length: aSize Reply: aBool [

	|command reply|
	command := Ev3SystemCommand newCommand: (Ev3SystemCommand systemCommand at: #ListFiles)  sequence: (self currentSequenceNumber) reply: aBool.
	command appendUInt16: aSize.
	command appendString: aPath.
	
	reply := self brick sendCommand: command withReply: aBool.
	
	self flag: 'add a continue List file'.
	
	^ reply getDataStringFrom: 7
	
	
]

{ #category : #'as yet unclassified' }
Ev3File >> listOpenHandlesReply: aBool [

	|command reply|
	command := Ev3SystemCommand newCommand: (Ev3SystemCommand systemCommand at: #ListOpenHandles)  sequence: (self currentSequenceNumber) reply: aBool.
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3File >> readFile: aFileName [

	|command reply  chunkSize handle fileSize data bytesRead fileData bytesToWrite |
	chunkSize := 65534.
	command := Ev3SystemCommand newCommand: (Ev3SystemCommand systemCommand at: #BeginUpload)  sequence: (self currentSequenceNumber) reply: true.
	command appendUInt16: chunkSize.
	command appendString: aFileName.
	
	reply := self brick sendCommand: command withReply: true.
	
	fileSize := (reply getInt32At: 4).
	handle := reply getByteAt: 8.
	data := reply getDataFrom: 9.
	bytesRead := data size.
	bytesToWrite := 1.
	fileData := ByteArray new: fileSize.
	data do:[:a |
		fileData byteAt: bytesToWrite put: a.
		bytesToWrite := bytesToWrite + 1.
	].
self halt.
	[bytesRead < fileSize] whileTrue:[
		|sizeToRead|
		sizeToRead := chunkSize min: (fileSize - bytesRead).
		
		command := Ev3SystemCommand newCommand: (Ev3SystemCommand systemCommand at: #ContinueUpload)  sequence: 100 reply: true.
		command appendByte: handle.
		command appendUInt16: sizeToRead.
		reply := self brick sendCommand: command withReply: true.
		data := reply getDataFrom: 5.
		bytesRead := bytesRead + sizeToRead.
		data do:[:a |
			fileData byteAt: bytesToWrite put: a.
			bytesToWrite := bytesToWrite + 1.
		].
	].
	fileData inspect.
	^fileData asByteArray
]

{ #category : #'as yet unclassified' }
Ev3File >> writeFile: aFileName content: data [

	|command reply sizeSent chunkSize handle |
	chunkSize := 960.
	command := Ev3SystemCommand newCommand: (Ev3SystemCommand systemCommand at: #BeginDownload)  sequence: (self currentSequenceNumber) reply: true.
	command appendUInt32: data size.
	command appendString: aFileName.
	
	reply := self brick sendCommand: command withReply: true.
	
	sizeSent := 0.
	handle := (reply at: 3).
	[sizeSent < data size] whileTrue:[
		|sizeToSend|
		sizeToSend := chunkSize min: (data size - sizeSent).
		
		command := Ev3SystemCommand newCommand: (Ev3SystemCommand systemCommand at: #ContinueDownload)  sequence: 100 reply: true.
		command appendByte: handle.
		command appendByteArray: data offSet: sizeSent + 1 size: sizeToSend.
		
		sizeSent := sizeSent + sizeToSend.
		reply := self brick sendCommand: command withReply: true.
	].
	
	^reply
]
