Class {
	#name : #CReporterSlotMorph,
	#superclass : #OSlotMorph,
	#instVars : [
		'topBarBottom',
		'blockBottom'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #drawing }
CReporterSlotMorph >> computeHighlightColors [

	| h s v |
	owner ifNotNil: [
		color = owner color ifFalse: [
			self color: owner color]].
	h := color hue.
	s := color saturation.
	v := color brightness.
	highlightColor1 := Color h: h s: (s - 0.13) v: (v + 0.1).
	highlightColor2 := Color h: h s: s v: (v + 0.07).
	shadowColor := color mixed: 0.55 with: Color black.

]

{ #category : #'as yet unclassified' }
CReporterSlotMorph >> displayForm [
	^Form dotOfSize: 1
]

{ #category : #drawing }
CReporterSlotMorph >> drawBottomBarOn: aCanvas [ 


	| left barTop barBottom |

	barBottom := self bottom.


	barTop := barBottom - 3.
	left := self left + CBlockBracketThickness - 1.

	aCanvas fillRectangle: (left@(barTop - 2) extent: 1@1) color: color.
	aCanvas fillRectangle: (left@(barTop - 1) extent: 2@1) color: color.
	aCanvas fillRectangle: (left@barTop extent: 3@1) color: color.

	aCanvas
		fillRectangle: ((left + 3)@barTop corner: (self right - 2)@(barTop + 1))
		color: highlightColor1.
	aCanvas
		fillRectangle: (self left@(barTop + 1) corner: (self right - 1)@barBottom)
		color: color.

	(owner isKindOf: CustomReporterBlockMorph) ifFalse: [
		aCanvas
			fillRectangle: ((self right - 1)@(barTop + 2) corner: self right@barBottom)
			color: shadowColor]


]

{ #category : #drawing }
CReporterSlotMorph >> drawOn: aCanvas [ 

	| c |
	topBarBottom := self top.
	blockBottom := self bottom.
	self computeHighlightColors.
	c := FormCanvas extent: self extent depth: 32.
	c := c copyOffset: self topLeft negated.

	self drawTopBarOn: c.
	self drawVerticalBarOn: c.
	self drawBottomBarOn: c.

	self drawFinalOn: aCanvas fromCanvas: c.

	self drawInlinePaletteOn: aCanvas



]

{ #category : #drawing }
CReporterSlotMorph >> drawTopBarOn: aCanvas [ 

	| left right y |

	left := CBlockBracketThickness - 1.
	right := self width - 1.
	y := topBarBottom - self top.

	self drawHLineFrom: left to: right y: y color: color on: aCanvas.
	self drawHLineFrom: left to: right y: y + 1 color: color on: aCanvas.

	self drawHLineFrom: left to: (left + 2) y: y + 2 color: color on: aCanvas.
	self drawHLineFrom: left to: (left + 1) y: y + 3 color: color on: aCanvas.
	self drawPoint: (left + 1)@(y + 3) color: shadowColor on: aCanvas.

	self drawHLineFrom: (left + 2) to: right - 1 "gapStart" y: y + 2 color: shadowColor on: aCanvas.

	(owner isKindOf: CustomReporterBlockMorph) ifFalse: [
		self drawPoint: (right "- 1")@y color: shadowColor on: aCanvas.
		self drawPoint: (right - 1 "2")@(y + 1) color: shadowColor on: aCanvas]

]

{ #category : #drawing }
CReporterSlotMorph >> drawVerticalBarOn: aCanvas [ 

	| left barRight |
	left := self left.
	barRight := (left + CBlockBracketThickness) - 1.

	aCanvas

		fillRectangle: (self topLeft corner: (barRight @ self bottom))
		color: color;

		fillRectangle: (barRight@(topBarBottom + 4) corner: (barRight + 1)@blockBottom)
		color: shadowColor.
]

{ #category : #drawing }
CReporterSlotMorph >> fixBlockLayout [
	"Update the positions of my submorphs."

	| newH |
	blockLayoutNeeded ifFalse: [^ self].
	owner ifNotNil: [
		color = owner color ifFalse: [self color: owner color]].

	newH := 14.

	self nestedBlock
		ifNotNil: [ (self nestedBlock respondsTo: #fixBlockLayout)
			ifTrue: [ self nestedBlock fixBlockLayout].
			self nestedBlock position: self position + (12@3).
			(self nestedBlock isKindOf: SpecialArgMorph) ifFalse: [
				newH := self nestedBlock fullBounds height + 6]].

	self height: newH.


	(owner isKindOf: ReporterBlockMorph) 
		ifTrue: [self nestedBlock ifNotNil: [
			self width: self nestedBlock fullBounds width + CBlockBracketThickness]]


]

{ #category : #'as yet unclassified' }
CReporterSlotMorph >> initialize [
	super initialize.
	isSpecialForm := true.
	selector := #cLambda.
	self commandSpec: '$SAReporter$'.
	self addLabel.

	removeElementMorph ifNotNil: [
		removeElementMorph delete]

]

{ #category : #'as yet unclassified' }
CReporterSlotMorph >> isEmptySlot [
	^ self nestedBlock isNil
]

{ #category : #'as yet unclassified' }
CReporterSlotMorph >> nestedBlock [
	self args ifNil: [^ nil].
	self args size < 1 ifTrue: [^ nil].
	^ super nestedBlock
]
