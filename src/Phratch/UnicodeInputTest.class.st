"
Useful for testing Unicode input. Open a transcript, click on this morph, then type or enter Unicode. The Unicode character values will be displayed in Transcript.

	UnicodeInputTest open

"
Class {
	#name : #UnicodeInputTest,
	#superclass : #Morph,
	#instVars : [
		'key',
		'uchar'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #drawing }
UnicodeInputTest >> drawOn: aCanvas [

	| f |
	super drawOn: aCanvas.
	self drawString: 'keyValue: ', key printString at: self topLeft + (10@7) on: aCanvas.
	self drawString: 'unicodeChar: ', uchar printString at: self topLeft + (10@30) on: aCanvas.

	f := ScratchTranslator
		formFor: (UTF32 with: uchar)
		font: (StrikeFont fontName: 'VerdanaBold' size: 24)
		fgColor: Color black
		bgColor: color
		suppressAntiAliasing: false.
	f ifNotNil: [aCanvas paintImage: f at: self topLeft + (95@60)].

]

{ #category : #drawing }
UnicodeInputTest >> drawString: s at: aPoint on: aCanvas [

	aCanvas
		text: s
		bounds: (aPoint corner: self bottomRight)
		font: (StrikeFont fontName: 'VerdanaBold' size: 18)
		kern: 0
		color: Color black.

]

{ #category : #'event handling' }
UnicodeInputTest >> handlesMouseDown: evt [

	^ true

]

{ #category : #initialization }
UnicodeInputTest >> initialize [

	super initialize.
	key := uchar := 0.
	color := Color gray.
	self extent: 220@100.
]

{ #category : #'event handling' }
UnicodeInputTest >> keyStroke: evt [

	key := evt keyValue.
	uchar := evt unicodeChar.
	self changed.


]

{ #category : #'event handling' }
UnicodeInputTest >> keyboardFocusChange: aBoolean [

	aBoolean
		ifTrue: [self color: Color yellow]
		ifFalse: [self color: Color gray].

]

{ #category : #'event handling' }
UnicodeInputTest >> mouseDown: evt [

	evt hand newKeyboardFocus: self.
	evt hand grabMorph: self.

]
