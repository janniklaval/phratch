Class {
	#name : #StartEventHatMorph,
	#superclass : #EventHatMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #'as yet unclassified' }
StartEventHatMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	^( self new forStartEvent scriptOwner: aScriptablePhratchMorph) color: blockColor
]
