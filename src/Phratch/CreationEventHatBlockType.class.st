"
'C'
"
Class {
	#name : #CreationEventHatBlockType,
	#superclass : #HatType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
CreationEventHatBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	^ (CreationEventHatMorph new scriptOwner: aScriptablePhratchMorph) color: blockColor.
]
