Class {
	#name : #PhratchMenuTests,
	#superclass : #TestCase,
	#instVars : [
		'window'
	],
	#category : #'Phratch-Tests'
}

{ #category : #'as yet unclassified' }
PhratchMenuTests >> setUp [
	window := PhratchFrameMorph new startup .
	"window := PhratchFrameMorph open"
]

{ #category : #'as yet unclassified' }
PhratchMenuTests >> tearDown [
	"Close any open Phratch windows"
	"PhratchFrameMorph close."
	window projectDirectory allFiles do: [:e | e delete].
	window := nil.
	
]

{ #category : #'as yet unclassified' }
PhratchMenuTests >> testNewPhratchProject [
	"Test that newPhratchProject clears out changes"

	|sprite|
	window newPhratchProject.	
	sprite:= window workPane submorphs select:[:e |
		e  isKindOf: PhratchSpriteMorph].

	self assert: sprite size = 1.	
	
]

{ #category : #'as yet unclassified' }
PhratchMenuTests >> testOpenProject [
	"Test that newPhratchProject clears out changes"

	| sprite fileName |
	fileName := '_testNewProject.phr'.
	sprite := window workPane submorphs detect:[:e |
		e  isKindOf: PhratchSpriteMorph].
	
	"Make a change and save"
	sprite objName: 'A sprite'.
	window projectName: fileName.
	window writePhratchProject.
		
	"Now create new project and confirm all back to start"
	window openPhratchProjectNamed:  (window projectDirectory / fileName).
	sprite := window workPane submorphs detect:[:e |
		e  isKindOf: PhratchSpriteMorph]..
	self assert: sprite objName = 'A sprite'.	
	
]

{ #category : #'as yet unclassified' }
PhratchMenuTests >> testSaveProject [
	"Test that newPhratchProject clears out changes"

	| sprite |
	sprite := window workPane submorphs detect:[:e |
		e  isKindOf: PhratchSpriteMorph].
	
	"Make a change and save"
	sprite objName: 'A sprite'.
	window savePhratchProjectNoDialog.
	
	"Now create new project and confirm all back to start"
	self assert: (window projectDirectory /'default.phr') asFileReference exists.
]
