Class {
	#name : #PaintColorSwitcher,
	#superclass : #ImageMorph,
	#instVars : [
		'foreground',
		'background',
		'switcher',
		'transparentMorph'
	],
	#category : #'Phratch-Paint'
}

{ #category : #accessing }
PaintColorSwitcher >> background [

	^ background color

]

{ #category : #accessing }
PaintColorSwitcher >> background: aColor [

	| t |
	background color: aColor.
	background removeAllMorphs.
	aColor = Color transparent ifTrue: [
		t := transparentMorph fullCopy.
		background addMorph:t.
		t position: (background position + (1@1))].

]

{ #category : #initialization }
PaintColorSwitcher >> createForegroundBackground [

	foreground := BorderedMorph new
		width: 24;
		height: 24;
		borderColor: Color white;
		borderWidth: 1.
	background := foreground fullCopy.

	self addMorphBack: foreground.
	self addMorphBack: background.

	foreground position: 8@7.
	background position: 25@23.

	self foreground: Color black.
	self background: Color white.

]

{ #category : #initialization }
PaintColorSwitcher >> createSwitcher [

	switcher := IconicButton new.
	switcher
		labelGraphic: (ScratchFrameMorph skinAt: #paintColorSwitcher) borderWidth: 0;
		actionSelector: #switchColors;
		target: self;
		actWhen: #buttonDown.
	self addMorph: switcher.
	switcher position: 36@(self top + 5).

]

{ #category : #accessing }
PaintColorSwitcher >> foreground [

	^ foreground color

]

{ #category : #accessing }
PaintColorSwitcher >> foreground: aColor [

	| t |
	foreground color: aColor.
	foreground removeAllMorphs.
	aColor = Color transparent ifTrue: [
		t := transparentMorph fullCopy.
		foreground addMorph: t.
		t position: (foreground position + (1@1))].

	self owner ifNotNil: [
		(self owner isKindOf: PaintPalette) ifTrue: [self owner updateOptionsPane]].

]

{ #category : #'event handling' }
PaintColorSwitcher >> handlesMouseDown: evt [

	^ true

]

{ #category : #initialization }
PaintColorSwitcher >> initialize [

	super initialize.
	self form: (ScratchFrameMorph skinAt: #paintColorSwitcherPane).
	transparentMorph := ImageMorph new form: (ScratchFrameMorph skinAt: #transparentColorSwitchPanel).
	self createSwitcher.
	self createForegroundBackground.

]

{ #category : #'event handling' }
PaintColorSwitcher >> mouseDown: evt [

	self switchColors.

]

{ #category : #'event handling' }
PaintColorSwitcher >> mouseLeave: evt [

	ScratchToolTipMorph clearToolTips.

]

{ #category : #'event handling' }
PaintColorSwitcher >> showBalloon: msg [

	| w worldBounds tooltip |

	w := self world.
	tooltip := (ScratchToolTipMorph string: msg for: self).
	w addMorphFront: (tooltip position: self bottomLeft + (0@8)).
	((worldBounds := w bounds) containsRect: tooltip bounds) ifFalse:
		[tooltip bounds: (tooltip bounds translatedToBeWithin: worldBounds)].
]

{ #category : #accessing }
PaintColorSwitcher >> switchColors [

	| storedColor |
	storedColor := foreground color.
	self owner color1: background color.
	self owner color2: storedColor.
	self owner ifNotNil: [
		(self owner isKindOf: PaintPalette) ifTrue: [self owner updateOptionsPane]].

]
