Class {
	#name : #SpecialBlockMorph,
	#superclass : #CommandBlockMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #'as yet unclassified' }
SpecialBlockMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block :=  super blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor.
	block isSpecialForm: true.
	^block
]
