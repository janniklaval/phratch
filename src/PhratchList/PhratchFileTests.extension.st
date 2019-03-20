Extension { #name : #PhratchFileTests }

{ #category : #'*PhratchList' }
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
