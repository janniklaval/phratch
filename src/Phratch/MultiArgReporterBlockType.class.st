"
'd'
"
Class {
	#name : #MultiArgReporterBlockType,
	#superclass : #BlockType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
MultiArgReporterBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block selector|
	selector := (spec at: 3) asSymbol.
	
	block := MultiArgReporterBlockMorph new.
	(#(#doCallBlockWithArgs #doReport) includes: selector)
		ifTrue: [ block minArgs: 1 ].
	block isSpecialForm: true.
	^block
]
