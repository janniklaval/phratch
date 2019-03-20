Extension { #name : #PhratchFileTests }

{ #category : #'*PhratchMotion' }
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
