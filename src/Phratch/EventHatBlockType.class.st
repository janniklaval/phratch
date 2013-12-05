"
'E'
"
Class {
	#name : #EventHatBlockType,
	#superclass : #HatType,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
EventHatBlockType class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|stage evtName|
	
	evtName := ''.
	(stage := aScriptablePhratchMorph ownerOrYourselfThatIsA: PhratchStageMorph)
		ifNotNil: [evtName := stage defaultEventName].
	^ (EventHatMorph new 
		scriptOwner: aScriptablePhratchMorph; 
		eventName: evtName;
		yourself) color: blockColor
]
