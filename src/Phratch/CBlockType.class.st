"
'c'
"
Class {
	#name : #CBlockType,
	#superclass : #BlockType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
CBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block :=  CBlockMorph new isSpecialForm: true.
	^block
]
