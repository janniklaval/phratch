Class {
	#name : #SpecialBlockMorph,
	#superclass : #CommandBlockMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #utilities }
SpecialBlockMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block :=  super blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor.
	block isSpecialForm: true.
	^block
]
