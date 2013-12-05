"
'u'
"
Class {
	#name : #MultiArgCommandBlockType,
	#superclass : #BlockType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
MultiArgCommandBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block := MultiArgCommandBlockMorph new.
	block minArgs: 1.
	block isSpecialForm: true.
	^block
]
