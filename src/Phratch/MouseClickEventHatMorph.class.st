"
I am a hat block for stacks triggered by clicking on an object with the mouse.

"
Class {
	#name : #MouseClickEventHatMorph,
	#superclass : #EventHatMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #settings }
MouseClickEventHatMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec [
	
	^ (self new scriptOwner: aScriptablePhratchMorph)
]

{ #category : #other }
MouseClickEventHatMorph >> eventName [

	^ 'Phratch-MouseClickEvent'

]

{ #category : #initialization }
MouseClickEventHatMorph >> initialize [

	| parts s |
	super initialize.
	self removeAllMorphs.

	commandSpec := 'when $Sprite$ clicked'.
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
MouseClickEventHatMorph >> printHatNameOn: aStream [
	"Append a human-readable string for this hat block's name to the given stream."

	aStream
		nextPutAll: 'when' localized;
		nextPutAll: ' ';
		nextPutAll: self receiverName localized;
		nextPutAll: ' ';
		nextPutAll: 'clicked' localized;
		cr
]

{ #category : #other }
MouseClickEventHatMorph >> receiverName [

	(scriptOwner respondsTo: #objName)
		ifTrue: [^ scriptOwner objName]
		ifFalse: [^ 'I''m'].

]
