"
'W'
"
Class {
	#name : #WhenHatBlockType,
	#superclass : #HatType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
WhenHatBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	^ (WhenHatBlockMorph new scriptOwner: aScriptablePhratchMorph) color: blockColor
]
