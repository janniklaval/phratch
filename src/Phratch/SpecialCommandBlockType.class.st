Class {
	#name : #SpecialCommandBlockType,
	#superclass : #CommandBlockType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
SpecialCommandBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block :=  super blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor.
	block isSpecialForm: true.
	^block
]
