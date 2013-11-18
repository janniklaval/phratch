"
Tests loading and saving Phratch scripts.

Instance Variables
	window:		The PhratchFrameMorph. setUp opens this for you before your tests run, and tearDown closes it.

New failing tests TODO (for defects):
- Saving over existing file doesn't seem to work (nothing is saved), using either Save or Save As. See testSaveAgain.

New failing tests written -- fixes needed:
- After Save filename changes to default or Phratch Project.

"
Class {
	#name : #PhratchFileTests,
	#superclass : #TestCase,
	#instVars : [
		'window'
	],
	#category : #'Phratch-Tests'
}

{ #category : #adding }
PhratchFileTests >> addBlock: blockSpec toSprite: aSprite [
	"blockSpec is something like: #('move $Number$ steps' - forward:)"
	| block |
	block := aSprite blockFromSpec: blockSpec color: Color black.
	aSprite addStack: block.
	^ block
]

{ #category : #useful }
PhratchFileTests >> firstSprite [
	^ window workPane submorphs detect:[:e |
		e  isKindOf: PhratchSpriteMorph].
]

{ #category : #useful }
PhratchFileTests >> openProject: fileName [
	window openSilentlyPhratchProjectNamed: window projectDirectory / fileName
]

{ #category : #useful }
PhratchFileTests >> saveProject: fileName [
	window projectName: fileName.
	window writePhratchProject
]

{ #category : #running }
PhratchFileTests >> setUp [
	window := PhratchFrameMorph new startup .
	"window := PhratchFrameMorph open"
]

{ #category : #useful }
PhratchFileTests >> stage [
	^ window workPane.
]

{ #category : #running }
PhratchFileTests >> tearDown [
	"Close any open Phratch windows"
	"PhratchFrameMorph close."
	window := nil
]

{ #category : #tests }
PhratchFileTests >> testSave [
	"Test a simple save, with a sprite name change, and that reloading the saved file works."

	| sprite fileName |
	fileName := '_testSave.phr'.
	sprite := self firstSprite.
	self assert: sprite objName = 'Sprite1'.	
	
	"Make a change and save"
	sprite objName: 'A sprite'.
	self saveProject: fileName.	
		
	"Now make some changes that will get overwritten when we reload the project"
	sprite objName: 'Another Name'.
	self openProject: fileName.
	
	sprite := self firstSprite.
	self assert: sprite objName = 'A sprite'.
]
