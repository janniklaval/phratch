"
I represent a color argument for a command block. Clicking on me allows the user to change my color value.

"
Class {
	#name : #ColorArgMorph,
	#superclass : #ArgMorph,
	#instVars : [
		'showPalette'
	],
	#classVars : [
		'ColorPalette'
	],
	#category : #PhratchColor
}

{ #category : #'class initialization' }
ColorArgMorph class >> colorPaletteExtent: extent [
	"Answer a form containing a palette of colors sorted horizontally by hue and vertically by lightness."
	"(self colorPaletteExtent: 180@100) display"

	| palette grayWidth startHue vSteps hSteps x basicHue y c |
	palette := Form extent: extent depth: 32.
	grayWidth := 10.
	startHue := 338.0.
	vSteps := palette height // 2.
	hSteps := palette width - grayWidth.
	x := 0.
	startHue to: startHue + 360.0 by: 360.0 / hSteps do: [:h |
		basicHue := Color h: h asFloat s: 1.0 v: 1.0.
		y := 1.
		0 to: vSteps do: [:n |
 			c := basicHue mixed: (n asFloat / vSteps asFloat) with: Color white.
			palette fill: (x@y extent: 1@1) fillColor: c.
			y := y + 1].
		1 to: vSteps do: [:n |
 			c := Color black mixed: (n asFloat / vSteps asFloat) with: basicHue.
			palette fill: (x@y extent: 1@1) fillColor: c.
			y := y + 1].
		x := x + 1].

	y := 1.
	1 to: vSteps * 2 do: [:n |
 		c := Color black mixed: (n asFloat / (2 * vSteps) asFloat) with: Color white.
		palette fill: (x@y extent: 10@1) fillColor: c.
		y := y + 1].

	^ palette

]

{ #category : #'class initialization' }
ColorArgMorph class >> initialize [
	"self initialize. ColorPalette display"

	ColorPalette := self colorPaletteExtent: 150@100.

]

{ #category : #other }
ColorArgMorph >> acceptsTypeOf: aBlockMorph [
	"Answer true if I can accept a dropped reporter of the given type. Answer false by default."

	^ (aBlockMorph isColorBlockMorph).
]

{ #category : #other }
ColorArgMorph >> defaultValue: aColor [

	self setColor: aColor.

]

{ #category : #other }
ColorArgMorph >> evaluate [
	"Answer my color."

	^ color

]

{ #category : #'event handling' }
ColorArgMorph >> handlesMouseDown: evt [

	^ evt hand toolType isNil

]

{ #category : #other }
ColorArgMorph >> hexFor: aNumber [
	"Answer a string representing the given number, rounded, in hexadecimal."

	| s |
	s := (255.0 * aNumber) rounded hex.
	s := s copyFrom: 4 to: s size.
	s := (String new: 2 - s size withAll: $0), s.  "pad to two digits"
	^ s

]

{ #category : #initialization }
ColorArgMorph >> initialize [

	super initialize.
	self borderColor: (Color gray: 0.4).
	self borderWidth: 1.
	self extent: 13@13.
	showPalette := true.

]

{ #category : #testing }
ColorArgMorph >> isColorArgMorph [

	^ true
]

{ #category : #BYOB }
ColorArgMorph >> isEmptySlot [
	^false
]

{ #category : #'event handling' }
ColorArgMorph >> mouseUp: evt [

	| w palette |
	showPalette ifNil: [showPalette := true].
	
	(w := self world) ifNil: [^ self].
	showPalette ifTrue: [
		palette := ImageMorph new form: ColorPalette.
		palette position: self bounds bottomLeft + (0@5).
		w addMorph: palette.
		w displayWorldSafely].

	Cursor eyeDropper showWhile: [
		"Listen for two events here: the first click, then any further ones if the button held down"
		self color: (Display colorAt: Sensor waitButton).
		[Sensor anyButtonPressed] whileTrue: [
			self color: (Display colorAt: Sensor cursorPoint) ].
		w displayWorldSafely ].

	palette ifNotNil: [palette delete].

]

{ #category : #other }
ColorArgMorph >> printArgOn: aStream [
	"Print this argument morph on the given stream."

	aStream
		nextPutAll: 'c[';
		nextPutAll: (self hexFor: color red);
		nextPutAll: (self hexFor: color green);
		nextPutAll: (self hexFor: color blue);
		nextPutAll: ']'
]

{ #category : #other }
ColorArgMorph >> setColor: aColor [
	"Make sure the color is not translucent."

	self color: (aColor alpha: 1.0).

]

{ #category : #other }
ColorArgMorph >> showPalette: aBoolean [

	showPalette := aBoolean.

]
