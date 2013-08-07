Class {
	#name : #CArgSlotMorph,
	#superclass : #CSlotMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #private }
CArgSlotMorph >> blockAttachPoints: aSet [
	"Answer a collection of possible attachment points for me. Each entry is an Association mapping a point to the morph to which a dropping command block could be attached."

	| result |

	result := #().

	nestedBlock
		ifNil: [ result := result copyWith: ((self topLeft + (CBlockBracketThickness@(self topBarHeight + 3))) -> self)]
		ifNotNil: [nestedBlock blockAttachPoints: aSet].

	aSet addAll: result.


]

{ #category : #drawing }
CArgSlotMorph >> blockWidth [

	| bw |
	bw := 0.
	(owner isKindOf: BlockMorph) ifTrue: [
		bw := owner width].
	^ 50 max: bw
]

{ #category : #drawing }
CArgSlotMorph >> drawBottomBarOn: aCanvas [ 


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
CArgSlotMorph >> drawOn: aCanvas [ 

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
CArgSlotMorph >> drawTopBarOn: aCanvas [
	| left right y gapStart gapEnd |
	left := CBlockBracketThickness - 1.
	right := self width - 1.
	y := topBarBottom - self top.
	gapStart := left + PuzzleInset + 1.
	gapEnd := gapStart + PuzzleWidth.
	self
		drawHLineFrom: left
		to: right
		y: y
		color: color
		on: aCanvas.
	self
		drawHLineFrom: left
		to: right
		y: y + 1
		color: color
		on: aCanvas.
	self
		drawHLineFrom: left
		to: left + 2
		y: y + 2
		color: color
		on: aCanvas.
	self
		drawHLineFrom: left
		to: left + 1
		y: y + 3
		color: color
		on: aCanvas.
	self drawPoint: (left + 1) @ (y + 3) color: shadowColor on: aCanvas.
	self
		drawHLineFrom: gapStart
		to: gapEnd
		y: y + 2
		color: color
		on: aCanvas.
	self
		drawHLineFrom: gapStart + 1
		to: gapEnd - 1
		y: y + 3
		color: color
		on: aCanvas.
	self
		drawHLineFrom: gapStart + 1
		to: gapEnd - 1
		y: y + 4
		color: color
		on: aCanvas.
	self
		drawHLineFrom: gapStart + 2
		to: gapEnd - 2
		y: y + 5
		color: color
		on: aCanvas.
	self
		drawHLineFrom: left + 2
		to: gapStart
		y: y + 2
		color: shadowColor
		on: aCanvas.
	self
		drawHLineFrom: gapEnd
		to: right - 1
		y: y + 2
		color: shadowColor
		on: aCanvas.
	self
		drawHLineFrom: gapStart + 2
		to: gapEnd - 2
		y: y + 6
		color: shadowColor
		on: aCanvas.
	self drawPoint: gapStart @ (y + 3) color: shadowColor on: aCanvas.
	self drawPoint: gapStart @ (y + 4) color: shadowColor on: aCanvas.
	self drawPoint: (gapStart + 1) @ (y + 5) color: shadowColor on: aCanvas.
	self drawPoint: (gapEnd - 1) @ (y + 3) color: shadowColor on: aCanvas.
	self drawPoint: (gapEnd - 1) @ (y + 4) color: shadowColor on: aCanvas.
	self drawPoint: (gapEnd - 2) @ (y + 5) color: shadowColor on: aCanvas.
	(owner isKindOf: CustomReporterBlockMorph)
		ifTrue: [ ^ self ].
	self drawPoint: right @ y color: shadowColor on: aCanvas.	"- 1"
	self drawPoint: (right - 1) @ (y + 1) color: shadowColor on: aCanvas	"2"
]

{ #category : #drawing }
CArgSlotMorph >> drawVerticalBarOn: aCanvas [ 

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
CArgSlotMorph >> fixBlockLayout [
	"Update the positions of my submorphs."

	| newH |
	blockLayoutNeeded ifFalse: [^ self].
	owner ifNotNil: [
		color = owner color ifFalse: [self color: owner color]].

	"fix nestedBlock and nextBlock in case they've been removed from me"
	(nestedBlock notNil and: [nestedBlock owner ~~ self]) ifTrue: [nestedBlock := nil].

	newH := self topBarHeight + 14.

	nestedBlock
		ifNotNil: [
			stretchHeight := 0.
			nestedBlock fixBlockLayout.
			newH := nestedBlock fullBounds height + 2.
			nestedBlock position: self position + (CBlockBracketThickness @ (self topBarHeight)).
			nestedBlock blockSequence last isStopOrForever ifTrue: [newH := newH + 4]].

	self height: newH.


	(owner isKindOf: ReporterBlockMorph) 
		ifTrue: [nestedBlock ifNotNil: [
			self width: nestedBlock fullBounds width + CBlockBracketThickness]]


]

{ #category : #initialization }
CArgSlotMorph >> initialize [
	super initialize.
	isSpecialForm := true.
	selector := #loopLambda
]
