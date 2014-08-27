Class {
	#name : #StartEventHatMorph,
	#superclass : #EventHatMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #settings }
StartEventHatMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	^( self new forStartEvent scriptOwner: aScriptablePhratchMorph) color: blockColor
]
