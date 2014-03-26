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
		e  isPhratchSpriteMorph].
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
	window projectDirectory allFiles do: [:e | e delete].
	window := nil.
	
]

{ #category : #tests }
PhratchFileTests >> testNewProject [
	"Test that newPhratchProject clears out changes"

	| sprite fileName |
	fileName := '_testNewProject.phr'.
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

{ #category : #tests }
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
	window writePhratchProject.
	self assert: window projectName = projectName.
		
	"Make another change"
	sprite objName: 'TopCat'.
	window writePhratchProject.
	self assert: window projectName = projectName.
	
	"Now make some changes that will get overwritten when we reload the project"
	sprite objName: 'Another Name'.
	self openProject: projectName, '.phr'.
	
	sprite := self firstSprite.
	self assert: sprite objName = 'TopCat'.
]

{ #category : #tests }
PhratchFileTests >> testSaveAllBlocks [
	"Create a few blocks and check they can be saved and loaded.
	To create blocks we use sprite blockFromSpec: passing in a array of symbols from the blockSpec class method."

	| fileName allPragmasStage commandBlocksStage allPragmasSprite commandBlocksSprite blocksSprite blocksStage |
	fileName := '_testSaveAllBlocks.phr'.
	
	allPragmasStage := Pragma allNamed: #phratchItem:kind:category:defaultValues:subCategory:special: from: self stage class to:  ScriptablePhratchMorph  sortedByArgument: 5.
	commandBlocksStage := OrderedCollection new.
	allPragmasStage do:[:aP |
		|prov|
		prov := { aP arguments at: 1 . aP arguments at: 2 . aP method selector . aP arguments at: 6},  (aP arguments at: 4).
		commandBlocksStage add: (self addBlock: prov toSprite: self stage).
	].
	self assert: commandBlocksStage size > 0.

	allPragmasSprite := Pragma allNamed: #phratchItem:kind:category:defaultValues:subCategory:special: from: self firstSprite class to:  ScriptablePhratchMorph  sortedByArgument: 5.
	commandBlocksSprite := OrderedCollection new.
	allPragmasSprite do:[:aP |
		|prov|
		prov := { aP arguments at: 1 . aP arguments at: 2 . aP method selector . aP arguments at: 6}.
		(aP arguments at: 4) ifNotEmpty: [prov := prov,  (aP arguments at: 4)].
		commandBlocksSprite add: (self addBlock: prov toSprite: self firstSprite).
	].
	self assert: commandBlocksSprite size > 0.
	
	self saveProject: fileName.
	window newPhratchProject.
	self openProject: fileName.
	
	"Use codeString to compare blocks, to check that they are equivalent"
	blocksSprite := self firstSprite blocksBin submorphs.
	self assert: commandBlocksSprite size = blocksSprite size.
	blocksSprite do: [:a | self assert:(commandBlocksSprite anySatisfy: [:b | a codeString = b codeString] ) ].
	
	blocksStage := self stage blocksBin submorphs.
	self assert: commandBlocksStage size = blocksStage size.
	blocksStage do: [:a | self assert:(commandBlocksStage anySatisfy: [:b | a codeString = b codeString] ) ].
]

{ #category : #tests }
PhratchFileTests >> testSaveAllBlocksSprite [
	"Create a few blocks and check they can be saved and loaded.
	To create blocks we use sprite blockFromSpec: passing in a array of symbols from the blockSpec class method."

	| fileName allPragmasSprite commandBlocksSprite blocksSprite |
	fileName := '_testSaveAllBlocksSprite.phr'.


	allPragmasSprite := Pragma allNamed: #phratchItem:kind:category:defaultValues:subCategory:special: from: self firstSprite class to:  ScriptablePhratchMorph  sortedByArgument: 5.
	commandBlocksSprite := OrderedCollection new.
	allPragmasSprite do:[:aP |
		|prov|
		prov := { aP arguments at: 1 . aP arguments at: 2 . aP method selector . aP arguments at: 6}.
		(aP arguments at: 4) ifNotEmpty: [prov := prov,  (aP arguments at: 4)].
		commandBlocksSprite add: (self addBlock: prov toSprite: self firstSprite).
	].
	self assert: commandBlocksSprite size > 0.
	
	self saveProject: fileName.
	window newPhratchProject.
	self openProject: fileName.
	"Use codeString to compare blocks, to check that they are equivalent"
	blocksSprite := self firstSprite blocksBin submorphs.
	self assert: commandBlocksSprite size = blocksSprite size.
	blocksSprite do: [:a | self assert:(commandBlocksSprite anySatisfy: [:b | a codeString = b codeString] ) ].
	
]

{ #category : #tests }
PhratchFileTests >> testSaveAllBlocksStage [
	"Create a few blocks and check they can be saved and loaded.
	To create blocks we use sprite blockFromSpec: passing in a array of symbols from the blockSpec class method."

	| fileName allPragmasStage commandBlocksStage blocksStage |
	fileName := '_testSaveAllBlocks.phr'.
	
	allPragmasStage := Pragma allNamed: #phratchItem:kind:category:defaultValues:subCategory:special: from: self stage class to:  ScriptablePhratchMorph  sortedByArgument: 5.
	commandBlocksStage := OrderedCollection new.
	allPragmasStage do:[:aP |
		|prov|
		prov := { aP arguments at: 1 . aP arguments at: 2 . aP method selector . aP arguments at: 6},  (aP arguments at: 4).
		commandBlocksStage add: (self addBlock: prov toSprite: self stage).
	].
	self assert: commandBlocksStage size > 0.
	
	self saveProject: fileName.
	window newPhratchProject.
	self openProject: fileName.
	
	"Use codeString to compare blocks, to check that they are equivalent"
	
	blocksStage := self stage blocksBin submorphs.
	self assert: commandBlocksStage size = blocksStage size.
	blocksStage do: [:a | self assert:(commandBlocksStage anySatisfy: [:b | a codeString = b codeString] ) ].

]

{ #category : #tests }
PhratchFileTests >> testSaveBlocks [
	"Create a few blocks and check they can be saved and loaded.
	To create blocks we use sprite blockFromSpec: passing in a array of symbols from the blockSpec class method."

	| fileName commandBlock1 commandBlock2 blocks |
	fileName := '_testSaveBlocks.phr'.
	commandBlock1 := self addBlock: #('move $Number$ steps' #- #forward: #()) toSprite: self firstSprite.
	commandBlock2 := self addBlock: #('turn $Number$ degrees' #- #turnRight: #() 15) toSprite: self firstSprite.

	self saveProject: fileName.
	window newPhratchProject.
	self openProject: fileName.
	
	"Use codeString to compare blocks, to check that they are equivalent"
	blocks := self firstSprite blocksBin submorphs.
	self assert: (blocks anySatisfy:[:e | e codeString = commandBlock1 codeString]).
	self assert: (blocks anySatisfy:[:e | e codeString = commandBlock2 codeString]).
	
]

{ #category : #tests }
PhratchFileTests >> testSaveTenBlocks [
	"Create a few blocks and check they can be saved and loaded.
	To create blocks we use sprite blockFromSpec: passing in a array of symbols from the blockSpec class method."

	| fileName allPragmasStage commandBlocksStage commandBlocksSprite allPragmasSprite blocksSprite blocksStage |
	fileName := '_testSaveTenBlocks.phr'.
	
	allPragmasStage := Pragma allNamed: #phratchItem:kind:category:defaultValues:subCategory:special: from: self stage class to:  ScriptablePhratchMorph  sortedByArgument: 5.
	commandBlocksStage := OrderedCollection new.
	allPragmasStage from:1 to:5 do:[:aP |
		|prov|
		prov := { aP arguments at: 1 . aP arguments at: 2 . aP method selector . aP arguments at: 6}.
		(aP arguments at: 4) ifNotEmpty: [prov := prov,  (aP arguments at: 4)].
		commandBlocksStage add: (self addBlock: prov toSprite: self stage).
	].
	self assert: commandBlocksStage size > 0.

	allPragmasSprite := Pragma allNamed: #phratchItem:kind:category:defaultValues:subCategory:special: from: self firstSprite class to:  ScriptablePhratchMorph  sortedByArgument: 5.
	commandBlocksSprite := OrderedCollection new.
	allPragmasSprite from:1 to:5  do:[:aP |
		|prov|
		prov := { aP arguments at: 1 . aP arguments at: 2 . aP method selector . aP arguments at: 6}.
		(aP arguments at: 4) ifNotEmpty: [prov := prov,  (aP arguments at: 4)].
		commandBlocksSprite add: (self addBlock: prov toSprite: self firstSprite).
	].
	self assert: commandBlocksSprite size > 0.
	
	self saveProject: fileName.
	window newPhratchProject.
	self openProject: fileName.
	
	"Use codeString to compare blocks, to check that they are equivalent"
	blocksSprite := self firstSprite blocksBin submorphs.
	self assert: commandBlocksSprite size = blocksSprite size.
	
	blocksSprite do: [:a | self assert:(commandBlocksSprite anySatisfy: [:b | a codeString = b codeString] ) ].
	
	blocksStage := self stage blocksBin submorphs.
	self assert: commandBlocksStage size = blocksStage size.
	
	blocksStage do: [:a | self assert:(commandBlocksStage anySatisfy: [:b | a codeString = b codeString] ) ].

]

{ #category : #tests }
PhratchFileTests >> testSaveWithBroadcast [
	"Test that saving scripts with variables works. 
	Currently this fails as variables are loaded back with name replaced by int."

	| sprite fileName commandBlock1 commandBlock2 blocks |
	fileName := '_testSaveScriptWithBroadcast.phr'.
	sprite := self firstSprite.
	self assert: sprite objName = 'Sprite1'.
	
	
	commandBlock1 := self addBlock: #('broadcast $Event$' - broadcast: #() 'aBroadcast' ) toSprite: self firstSprite.
	commandBlock1 defaultArgs: #('aBroadcast').
	commandBlock2 := self addBlock: #('when I receive $Event$' #EventHatMorph whenEventReceived #()) toSprite: self firstSprite.
	commandBlock2 eventName: 'aBroadcast'.

	self saveProject: fileName.
	window newPhratchProject.
	self openProject: fileName.
	
	"Use codeString to compare blocks, to check that they are equivalent"
	blocks := self firstSprite blocksBin submorphs.
	self assert: blocks second codeString = commandBlock1 codeString.
	self assert: blocks first codeString = commandBlock2 codeString.

]

{ #category : #tests }
PhratchFileTests >> testSaveWithList [
	"Test that saving scripts with variables works. 
	Currently this fails as variables are loaded back with name replaced by int."

	| sprite fileName |
	fileName := '_testSaveScriptWithVariable.phr'.
	sprite := self firstSprite.
	self assert: sprite objName = 'Sprite1'.
	
	sprite createListNamed: 'aList'.
	self assert: (sprite lists includesKey: 'aList').
	
	sprite append: '42' toList: 'aList'.
	self assert: (sprite getLine: 1 ofList:  'aList') = '42'.
	
	self saveProject: fileName.
	window newPhratchProject.
	sprite := self firstSprite.
	self assert: (sprite lists includesKey: 'aList') not.
	
	self openProject: fileName.
	sprite := self firstSprite.
	self assert: (sprite lists includesKey: 'aList'). "fails"
	self assert: (sprite getLine: 1 ofList:  'aList') = '42'.
	
]

{ #category : #tests }
PhratchFileTests >> testSaveWithVariable [
	"Test that saving scripts with variables works. 
	Currently this fails as variables are loaded back with name replaced by int."

	| sprite fileName |
	fileName := '_testSaveScriptWithVariable.phr'.
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

{ #category : #tests }
PhratchFileTests >> testSaveWithVariableValued [
	"Test that saving scripts with variables works. 
	Currently this fails as variables are loaded back with name replaced by int."

	| sprite fileName |
	fileName := '_testSaveScriptWithVariable.phr'.
	sprite := self firstSprite.
	self assert: sprite objName = 'Sprite1'.
	
	sprite addVariable: 'aNumber' value: 42.
	self assert: (sprite varNames includes: 'aNumber').
	
	self saveProject: fileName.
	window newPhratchProject.
	sprite := self firstSprite.
	self assert: (sprite varNames includes: 'aNumber') not.
	
	self openProject: fileName.
	sprite := self firstSprite.
	self assert: (sprite varNames includes: 'aNumber'). "fails"
	self assert: (sprite getVar: 'aNumber') = 42.
	
]
