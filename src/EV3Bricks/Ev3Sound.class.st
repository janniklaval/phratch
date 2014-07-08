Class {
	#name : #Ev3Sound,
	#superclass : #Ev3Block,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3Sound >> beep: vol time: duration [ 
	
	^ self beep: vol time: duration reply: false
]

{ #category : #'as yet unclassified' }
Ev3Sound >> beep: vol time: duration reply: aBool [

	^ self playToneVolume: vol frequency: 1000 duration: duration reply: aBool
]

{ #category : #'as yet unclassified' }
Ev3Sound >> playSoundFile: name volume: vol [

	^ self playSoundFile: name volume: vol repeat: false reply: false
]

{ #category : #'as yet unclassified' }
Ev3Sound >> playSoundFile: name volume: vol repeat: repeatBool reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #Sound).
	repeatBool ifTrue: [ 
		command appendByte: (Ev3Command soundSubCodes at: #Repeat).
	] ifFalse: [ 
		command appendByte: (Ev3Command soundSubCodes at: #Play).
	].
	command addLongByteValue: vol.
	command appendString: name constantParameterType: (Ev3Command constantParameterType at: #Value).
	command appendByte: (Ev3Command byteCodes at: #SoundReady).
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Sound >> playToneVolume: vol frequency: freq duration: intTimeMs [

	^ self playToneVolume: vol frequency: freq duration: intTimeMs reply: false.
]

{ #category : #'as yet unclassified' }
Ev3Sound >> playToneVolume: vol frequency: freq duration: intTimeMs reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #Sound).
	command appendByte: (Ev3Command soundSubCodes at: #Tone).
	command addLongByteValue: vol.
	command addInt16Value: freq.
	command addInt16Value: intTimeMs.
		
	reply := self brick sendCommand: command withReply: aBool.	
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Sound >> stopSoundPlayback [
	
	^ self stopSoundPlaybackReply: false
]

{ #category : #'as yet unclassified' }
Ev3Sound >> stopSoundPlaybackReply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #Sound).
	command appendByte: (Ev3Command soundSubCodes at: #Break).
		
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]
