Class {
	#name : #CreationEventHatMorph,
	#superclass : #EventHatMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #'as yet unclassified' }
CreationEventHatMorph >> eventName [

	^ 'Phratch-CreationEvent'
]

{ #category : #'as yet unclassified' }
CreationEventHatMorph >> initialize [

	| parts s |
	super initialize.
	self removeAllMorphs.

	parts := PhratchTranslator labelPartsFor: 'when %m created'.

	s := StringMorph new contents: parts first; font: (PhratchFrameMorph getFont: #Label); color: Color white.
	self addMorphBack: s.

	self addMorphBack:
		(UpdatingStringMorph new useStringFormat
			font: (PhratchFrameMorph getFont: #Label);
			color: Color white;
			target: self;
			getSelector: #receiverName).

	s := s fullCopy contents: parts second.
	self addMorphBack: s.
]

{ #category : #'as yet unclassified' }
CreationEventHatMorph >> printHatNameOn: aStream [
	"Append a human-readable string for this hat block's name to the given stream."

	aStream nextPutAll: 'when ', self receiverName, ' created'; cr.
]

{ #category : #'as yet unclassified' }
CreationEventHatMorph >> receiverName [

	(scriptOwner respondsTo: #objName)
		ifTrue: [^ scriptOwner objName]
		ifFalse: [^ 'I''m'].
]
