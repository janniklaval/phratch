Class {
	#name : #NokiaTestPlugin,
	#superclass : #InterpreterPlugin,
	#category : #'Phratch-Primitives-Plugins'
}

{ #category : #'as yet unclassified' }
NokiaTestPlugin class >> primSndPlayOne [
	"Play one buffer."

	<primitive: 'primitiveSndPlayOne' module: 'NokiaTestPlugin'>
	self primitiveFailed

]

{ #category : #'as yet unclassified' }
NokiaTestPlugin class >> primSndPlayStart: samplingRate [
	"Start the sound player."

	<primitive: 'primitiveSndPlayStart' module: 'NokiaTestPlugin'>
	self primitiveFailed

]

{ #category : #'as yet unclassified' }
NokiaTestPlugin class >> primSndPlayStop [
	"Stop the sound player."

	<primitive: 'primitiveSndPlayStop' module: 'NokiaTestPlugin'>
	self primitiveFailed

]

{ #category : #'as yet unclassified' }
NokiaTestPlugin class >> test [
	"NokiaTestPlugin test"
	"self translate"

	self primSndPlayStart: 22050.
	self primSndPlayOne.
	(Delay forMilliseconds: 1000) wait.
	self primSndPlayStop.


]

{ #category : #'as yet unclassified' }
NokiaTestPlugin >> primitiveSndPlayOne [
	"Player a buffer."

	self export: true.

	self cCode: 'snd:=playOne()'.

	^ nil

]

{ #category : #'as yet unclassified' }
NokiaTestPlugin >> primitiveSndPlayStart [
	"Start the sound player"

	| samplingRate |
	self export: true.

	samplingRate := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed ifTrue: [^ nil].

	self cCode: 'snd:=startPlaying(samplingRate)'.

	interpreterProxy pop: 1.  "pop arg, leave rcvr on stack"
	^ nil

]

{ #category : #'as yet unclassified' }
NokiaTestPlugin >> primitiveSndPlayStop [
	"Stop the sound player"

	self export: true.

	self cCode: 'snd:=stopPlaying()'.

	^ nil

]
