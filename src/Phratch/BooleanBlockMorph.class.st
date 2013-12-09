Class {
	#name : #BooleanBlockMorph,
	#superclass : #ReporterBlockMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #'as yet unclassified' }
BooleanBlockMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block :=  super blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor.
	block isBoolean: true.
	^block
]
