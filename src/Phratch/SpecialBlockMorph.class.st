Class {
	#name : #SpecialBlockMorph,
	#superclass : #CommandBlockMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #utilities }
SpecialBlockMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec [
	
	|block|
	block :=  super blockTypeOn: aScriptablePhratchMorph spec: spec.
	block isSpecialForm: true.
	^block
]
