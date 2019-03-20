Class {
	#name : #TimeBlockMorph,
	#superclass : #CommandBlockMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #utilities }
TimeBlockMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec [
	
	|block|
	block :=  super blockTypeOn: aScriptablePhratchMorph spec: spec.
	block isTimed: true.
	^block
]
