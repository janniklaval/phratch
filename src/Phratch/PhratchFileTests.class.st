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

{ #category : #'as yet unclassified' }
PhratchFileTests >> addBlock: blockSpec toSprite: aSprite [
	"blockSpec is something like: #('move %n steps' - forward:)"
	| block |
	block := aSprite blockFromSpec: blockSpec color: Color black.
	aSprite addStack: block.
	^ block
]

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
	self assert: sprite objName = 'A sprite'.
]

{ #category : #'as yet unclassified' }
PhratchFileTests >> testSaveAgain [
	"Test repeated saves, with a sprite name change, and that reloading the saved file works. 
	
	We use savePhratchProjectNoDialog instead of writePhratchProject as this mirrors the menu 
	actions (and at the time of writing is buggy)."

	| sprite projectName |
	projectName := '_testSaveAgain'.
	window projectName: projectName.
	
	sprite := self firstSprite.
	self assert: sprite objName = 'Sprite1'.	
	
	"Make a change and save"
	sprite objName: 'Cat'.
	window savePhratchProjectNoDialog.
	self assert: window projectName = projectName.
		
	"Make another change"
	sprite objName: 'TopCat'.
	window savePhratchProjectNoDialog.
	self assert: window projectName = projectName.
	
	"Now make some changes that will get overwritten when we reload the project"
	sprite objName: 'Another Name'.
	self openProject: projectName.
	
	sprite := self firstSprite.
	self assert: sprite objName = 'TopCat'.
]

{ #category : #'as yet unclassified' }
PhratchFileTests >> testSaveBlocks [
	"Create a few blocks and check they can be saved and loaded.
	To create blocks we use sprite blockFromSpec: passing in a array of symbols from the blockSpec class method."

	| fileName commandBlock1 commandBlock2 blocks |
	fileName := '_testSaveBlocks.ypr'.
	commandBlock1 := self addBlock: #('move %n steps' - forward:) toSprite: self firstSprite.
	commandBlock2 := self addBlock: #('turn %n degrees' - turnRight: 15) toSprite: self firstSprite.

	self saveProject: fileName.
	window newPhratchProject.
	self openProject: fileName.
	
	"Use codeString to compare blocks, to check that they are equivalent"
	blocks := self firstSprite blocksBin submorphs.
	self assert: blocks first codeString = commandBlock1 codeString.
	self assert: blocks second codeString = commandBlock2 codeString.
	
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
