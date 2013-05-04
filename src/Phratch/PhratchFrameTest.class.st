"
A PhratchFrameTest tests things such as opening and closing Phratch.

Instance Variables

"
Class {
	#name : #PhratchFrameTest,
	#superclass : #TestCase,
	#category : #'Phratch-Tests'
}

{ #category : #'as yet unclassified' }
PhratchFrameTest >> tearDown [
	"Close any open Phratch windows"
	PhratchFrameMorph close
]

{ #category : #'as yet unclassified' }
PhratchFrameTest >> testOpen [
	| window |
	PhratchFrameMorph open.
	window := World submorphs detect: [ :m | m isKindOf: PhratchFrameMorph ].
	self assert: window isNil not
	
]

{ #category : #'as yet unclassified' }
PhratchFrameTest >> testOpenAndClose [
	PhratchFrameMorph open.
	PhratchFrameMorph close.
	self should: [  
		World submorphs detect: [ :m | m isKindOf: PhratchFrameMorph ]
	]
	raise: NotFound.
	
]
