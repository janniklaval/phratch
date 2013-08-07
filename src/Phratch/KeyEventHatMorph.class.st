"
I am a hat block for stacks triggered by Scratch keyboard events.

"
Class {
	#name : #KeyEventHatMorph,
	#superclass : #EventHatMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #other }
KeyEventHatMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	^ Array
		with: #byob
		with: ''
		with: self class name
		with: scriptNameMorph choice

]

{ #category : #other }
KeyEventHatMorph >> choice: aString [

	scriptNameMorph choice: aString.
	self fixBlockLayout.
	self changed.

]

{ #category : #other }
KeyEventHatMorph >> eventName [

	^ 'Phratch-KeyPressedEvent'

]

{ #category : #initialization }
KeyEventHatMorph >> initialize [

	| parts s |
	super initialize.
	self removeAllMorphs.

	parts := PhratchTranslator labelPartsFor: 'when $Keys$ key pressed'.

	s := StringMorph new
		contents: parts first; font: (PhratchFrameMorph getFont: #Label);
		color: Color white;
		yourself.
	self addMorphBack: s.

	scriptNameMorph := ChoiceArgMorph new
		getOptionsSelector: #keyNames;
		options: ScriptablePhratchMorph new keyNames;
		choice: 'space';
		yourself.
	self addMorphBack: scriptNameMorph.

	s := s fullCopy contents: parts second.
	self addMorphBack: s.

]

{ #category : #other }
KeyEventHatMorph >> printHatNameOn: aStream [
	"Append a human-readable string for this hat block's name to the given stream."

	aStream
		nextPutAll: 'when ';
		nextPutAll: scriptNameMorph choice;
		nextPutAll: ' key pressed';
		cr
]

{ #category : #other }
KeyEventHatMorph >> respondsToKeyEvent: aMorphicKeyEvent [

	| evtAscii |
	evtAscii := aMorphicKeyEvent keyCharacter asLowercase asciiValue.
	evtAscii = Character enter asciiValue ifTrue: [
		evtAscii := Character cr asciiValue].

	^ evtAscii = (ScriptablePhratchMorph new asciiFor: scriptNameMorph choice asString)

]
