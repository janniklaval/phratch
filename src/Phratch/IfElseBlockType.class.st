"
'c'
"
Class {
	#name : #IfElseBlockType,
	#superclass : #BlockType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
IfElseBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block :=  IfElseBlockMorph new isSpecialForm: true.
	^block
]
