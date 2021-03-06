Class {
	#name : #CreationEventHatMorph,
	#superclass : #EventHatMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #settings }
CreationEventHatMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec [
	
	^ (self new scriptOwner: aScriptablePhratchMorph).
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

	commandSpec := 'when $Sprite$ created'.
	parts := PhratchTranslator labelPartsFor: commandSpec.

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
		nextPutAll: 'when' localized;
		nextPutAll: ' ';
		nextPutAll: self receiverName localized;
		nextPutAll: ' ';
		nextPutAll: 'created' localized;
		cr
]

{ #category : #other }
CreationEventHatMorph >> receiverName [

	(scriptOwner respondsTo: #objName)
		ifTrue: [^ scriptOwner objName]
		ifFalse: [^ 'I''m'].
]
