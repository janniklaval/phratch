Class {
	#name : #PhratchFileTests,
	#superclass : #TestCase,
	#instVars : [
		'window'
	],
	#category : #'Phratch-Tests'
}

{ #category : #'as yet unclassified' }
PhratchFileTests >> firstSprite [
	^ window workPane submorphs first.
]

{ #category : #'as yet unclassified' }
PhratchFileTests >> openProject: fileName [
	window openPhratchProjectNamed: (window projectDirectory / fileName)
]

{ #category : #'as yet unclassified' }
PhratchFileTests >> saveProject: fileName [
	window projectName: fileName.
	window writePhratchProject
]

{ #category : #'as yet unclassified' }
PhratchFileTests >> setUp [
	window := PhratchFrameMorph open
]

{ #category : #'as yet unclassified' }
PhratchFileTests >> tearDown [
	"Close any open Phratch windows"
	PhratchFrameMorph close.
	window := nil
]

{ #category : #'as yet unclassified' }
PhratchFileTests >> testNewProject [
	"Test that newPhratchProject clears out changes"

	| sprite fileName |
	fileName := '_testNewProject.ypr'.
	sprite := self firstSprite.
	self assert: sprite objName = 'Sprite1'.	
	
	"Make a change and save"
	sprite objName: 'A sprite'.
	self saveProject: fileName.	
		
	"Now create new project and confirm all back to start"
	window newPhratchProject.
	sprite := self firstSprite.
	self assert: sprite objName = 'Sprite1'.	
	
]

{ #category : #'as yet unclassified' }
PhratchFileTests >> testSave [
	"Test a simple save, with a sprite name change, and that reloading the saved file works."

	| sprite fileName |
	fileName := '_testSave.ypr'.
	sprite := self firstSprite.
	self assert: sprite objName = 'Sprite1'.	
	
	"Make a change and save"
	sprite objName: 'A sprite'.
	self saveProject: fileName.	
		
	"Now make some changes that will get overwritten when we reload the project"
	sprite objName: 'Another Name'.
	self openProject: fileName.
	
	sprite := self firstSprite.
	self assert: sprite objName = 'A sprite'
]

{ #category : #'as yet unclassified' }
PhratchFileTests >> testSaveWithVariable [
	"Test that saving scripts with variables works. 
	Currently this fails as variables are loaded back with name replaced by int."

	| sprite fileName |
	fileName := '_testSaveScriptWithVariable.ypr'.
	sprite := self firstSprite.
	self assert: sprite objName = 'Sprite1'.
	
	sprite addVariable: 'name'.
	self assert: (sprite varNames includes: 'name').
	
	self saveProject: fileName.
	window newPhratchProject.
	sprite := self firstSprite.
	self assert: (sprite varNames includes: 'name') not.
	
	self openProject: fileName.
	sprite := self firstSprite.
	self assert: (sprite varNames includes: 'name'). "fails"
	
	
]
