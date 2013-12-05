"
'M'
"
Class {
	#name : #MooseClickEventHatBlockType,
	#superclass : #HatType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
MooseClickEventHatBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	^ (MouseClickEventHatMorph new scriptOwner: aScriptablePhratchMorph) color: blockColor
]
