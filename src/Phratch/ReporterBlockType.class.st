"
'r b R'
"
Class {
	#name : #ReporterBlockType,
	#superclass : #BlockType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
ReporterBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block :=  ReporterBlockMorph new.
	^block
]
