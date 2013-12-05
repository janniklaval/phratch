"
'S'
"
Class {
	#name : #StartEventHatBlockType,
	#superclass : #HatType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
StartEventHatBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	^( EventHatMorph new forStartEvent scriptOwner: aScriptablePhratchMorph) color: blockColor
]
