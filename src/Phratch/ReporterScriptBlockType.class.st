"
'Q'
"
Class {
	#name : #ReporterScriptBlockType,
	#superclass : #BlockType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
ReporterScriptBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block :=  ReporterScriptBlockMorph new minArgs: 1.
	block isSpecialForm: false.
	^block
]
