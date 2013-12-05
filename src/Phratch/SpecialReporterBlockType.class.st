Class {
	#name : #SpecialReporterBlockType,
	#superclass : #ReporterBlockType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
SpecialReporterBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block :=  super blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor.
	block isSpecialForm: true.
	^block
]
