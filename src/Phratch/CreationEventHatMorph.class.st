Class {
	#name : #CreationEventHatMorph,
	#superclass : #EventHatMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #'as yet unclassified' }
CreationEventHatMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	^ (self new scriptOwner: aScriptablePhratchMorph) color: blockColor.
]

{ #category : #other }
CreationEventHatMorph >> eventName [

	^ 'Phratch-CreationEvent'
]

{ #category : #initialization }
CreationEventHatMorph >> initialize [

	| parts s |
	super initialize.
	self removeAllMorphs.

	parts := PhratchTranslator labelPartsFor: 'when $Sprite$ created'.

	s := StringMorph new contents: parts first; font: (PhratchFrameMorph getFont: #Label); color: Color white;
		yourself.
	self addMorphBack: s.

	self addMorphBack:
		(PhratchUpdatingStringMorph new useStringFormat
			font: (PhratchFrameMorph getFont: #Label);
			color: Color white;
			target: self;
			getSelector: #receiverName;
		yourself).

	s := s fullCopy contents: parts second.
	self addMorphBack: s.
]

{ #category : #other }
CreationEventHatMorph >> printHatNameOn: aStream [
	"Append a human-readable string for this hat block's name to the given stream."

	aStream
		nextPutAll: 'when ';
		nextPutAll: self receiverName;
		nextPutAll: ' created';
		cr
]

{ #category : #other }
CreationEventHatMorph >> receiverName [

	(scriptOwner respondsTo: #objName)
		ifTrue: [^ scriptOwner objName]
		ifFalse: [^ 'I''m'].
]
