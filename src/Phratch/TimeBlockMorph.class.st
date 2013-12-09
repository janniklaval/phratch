Class {
	#name : #TimeBlockMorph,
	#superclass : #CommandBlockMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #'as yet unclassified' }
TimeBlockMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block :=  super blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor.
	block isTimed: true.
	^block
]
