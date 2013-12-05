Class {
	#name : #BooleanReporterBlockType,
	#superclass : #ReporterBlockType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
BooleanReporterBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block :=  super blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor.
	block isBoolean: true.
	^block
]
