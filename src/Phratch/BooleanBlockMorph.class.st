Class {
	#name : #BooleanBlockMorph,
	#superclass : #ReporterBlockMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #utilities }
BooleanBlockMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec [
	
	|block|
	block :=  super blockTypeOn: aScriptablePhratchMorph spec: spec.
	block isBoolean: true.
	^block
]
