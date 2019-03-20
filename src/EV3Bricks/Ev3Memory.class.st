Class {
	#name : #Ev3Memory,
	#superclass : #Ev3Block,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3Memory >> createArray: code size: anInt reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 4 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #Array).
	command appendByte: (Ev3Command memorySubCodes at: code).
	
	command addInt32Value: anInt.
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply getByteAt: 2
]

{ #category : #'as yet unclassified' }
Ev3Memory >> createArrayAt: handle type: codeType size: anInt reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 4 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #Array).
	command appendByte: (Ev3Command memorySubCodes at: codeType).
	
	command addInt32Value: handle.
	command addInt32Value: 0.
	command addInt32Value: anInt.
	command addInt32Value: 0.
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Memory >> delete: handle [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: false.
	command appendByte: (Ev3Command byteCodes at: #Array).
	command appendByte: (Ev3Command memorySubCodes at: #Delete).
	
	command addInt32Value: handle.
	
	reply := self brick sendCommand: command withReply: false.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Memory >> fill: handle Reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #Array).
	command appendByte: (Ev3Command memorySubCodes at: #Fill).
	
	command addInt32Value: handle.
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Memory >> getSize: handle [

	|command reply|
	command := Ev3Command newGlobal: 4 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #Array).
	command appendByte: (Ev3Command memorySubCodes at: #Size).
	
	command addInt32Value: handle.
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: true.
	^reply getInt32At: 2
]

{ #category : #'as yet unclassified' }
Ev3Memory >> read: handle atIndex: anInt type: aType [

	|command reply |
	command := Ev3Command newGlobal: 4 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #ArrayRead).
	command addInt32Value: handle.
	command addInt32Value: anInt.
	command addShortByteGlobalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: true.
	
	aType = #byte ifTrue:[
		^reply getByteAt: 2.
	].
	aType = #int16 ifTrue:[
		^reply getInt16At: 2.
	].
	aType = #int32 ifTrue:[
		^reply getInt32At: 2.
	].
	aType = #float ifTrue:[
		^reply getFloatAt: 2.
	].
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Memory >> readTable: handle atIndex: anInt length: size type: aType [

	| values memoryIndex |
	values := OrderedCollection new.
	memoryIndex := anInt.
	1 to: size do:[:i |
		values add: (self read: handle atIndex: (memoryIndex + i) type: aType).
	]
]

{ #category : #'as yet unclassified' }
Ev3Memory >> write: handle value: aVal type: aType atIndex: anInt [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #ArrayWrite).
	command addInt32Value: handle.
	command addInt32Value: anInt.
	
	aType = #byte ifTrue:[
		command appendByte: aVal.
	].
	aType = #int16 ifTrue:[
		command appendInt16: aVal.
	].
	aType = #int32 ifTrue:[
		command appendInt32: aVal.
	].
	aType = #float ifTrue:[
		command appendFloat: aVal.
	].
	reply := self brick sendCommand: command withReply: false.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Memory >> writeSlot: aSlot value: aValArray [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 5 sequence: (self currentSequenceNumber) reply: true.
	command appendByte: (Ev3Command byteCodes at: #InitBytes).
	command addShortByteLocalVariableAtAddress: 0.
	
	command addLongByteValue: aValArray size.
	command appendByteArray: aValArray.
	command appendByte: (Ev3Command byteCodes at: #MemoryWrite).
	
	command addShortValue: aSlot.
	command addShortValue: 0.
	command addShortValue: 4.
	command addShortValue: 5.
	command addShortByteLocalVariableAtAddress: 0.
	
	reply := self brick sendCommand: command withReply: false.
	^reply
]
