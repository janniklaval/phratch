"
'g'
"
Class {
	#name : #ColorBlockType,
	#superclass : #BlockType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
ColorBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block := ColorBlockMorph new.
	^block
]
