"
A PhratchFrameTest tests things such as opening and closing Phratch.

Instance Variables

"
Class {
	#name : #PhratchFrameTest,
	#superclass : #TestCase,
	#category : #'Phratch-Tests'
}

{ #category : #running }
PhratchFrameTest >> tearDown [
	"Close any open Phratch windows"
	PhratchFrameMorph close
]

{ #category : #tests }
PhratchFrameTest >> testOpen [
	| window |
	PhratchFrameMorph open.
	window := World submorphs detect: [ :m | m isKindOf: PhratchFrameMorph ].
	self assert: window isNil not
	
]

{ #category : #tests }
PhratchFrameTest >> testOpenAndClose [
	PhratchFrameMorph open.
	PhratchFrameMorph close.
	self should: [  
		World submorphs detect: [ :m | m isKindOf: PhratchFrameMorph ]
	]
	raise: NotFound.
	
]
