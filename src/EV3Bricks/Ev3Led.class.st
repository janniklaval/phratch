"
An Ev3BrickButton is xxxxxxxxx.

"
Class {
	#name : #Ev3Led,
	#superclass : #Ev3Block,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3Led class >> ledPattern [
	^ { #Black -> 0 . #Green -> 1 . #Red -> 2 . #Orange -> 3.
	#GreenFlash -> 4.
	#RedFlash -> 5.
	#OrangeFlash -> 6.
	#GreenPulse -> 7.
	#RedPulse -> 8.
	#OrangePulse -> 9.
	} asDictionary.
]

{ #category : #'as yet unclassified' }
Ev3Led >> setLedPattern: aLedPattern [ 

	^ self setLedPattern: aLedPattern reply: false
]

{ #category : #'as yet unclassified' }
Ev3Led >> setLedPattern: aLedPattern reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #UIWrite).
	command appendByte: (Ev3Command uiWriteSubCodes at: #Led).
	command appendByte: (Ev3Led ledPattern at: aLedPattern).
					
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]
