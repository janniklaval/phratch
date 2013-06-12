"
I am a hat block for stacks triggered by clicking on an object with the mouse.

"
Class {
	#name : #MouseClickEventHatMorph,
	#superclass : #EventHatMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #other }
MouseClickEventHatMorph >> eventName [

	^ 'Phratch-MouseClickEvent'

]

{ #category : #initialization }
MouseClickEventHatMorph >> initialize [

	| parts s |
	super initialize.
	self removeAllMorphs.

	parts := PhratchTranslator labelPartsFor: 'when $Sprite$ clicked'.

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

{ #category : #other }
MouseClickEventHatMorph >> printHatNameOn: aStream [
	"Append a human-readable string for this hat block's name to the given stream."

	aStream nextPutAll: 'when ', self receiverName, ' clicked'; cr.

]

{ #category : #other }
MouseClickEventHatMorph >> receiverName [

	(scriptOwner respondsTo: #objName)
		ifTrue: [^ scriptOwner objName]
		ifFalse: [^ 'I''m'].

]
