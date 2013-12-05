"
'K'
"
Class {
	#name : #KeyEventHatBlockType,
	#superclass : #HatType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
KeyEventHatBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	^ (KeyEventHatMorph new scriptOwner: aScriptablePhratchMorph) color: blockColor
]
