Class {
	#name : #TimeCommandBlockType,
	#superclass : #CommandBlockType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
TimeCommandBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block :=  super blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor.
	block isTimed: true.
	^block
]
