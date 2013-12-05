"
'q'
"
Class {
	#name : #CommandScriptBlockType,
	#superclass : #BlockType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
CommandScriptBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block :=  CommandScriptBlockMorph new.
	block isSpecialForm: false.
	^block
]
