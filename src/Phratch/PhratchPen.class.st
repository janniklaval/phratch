"
My instances can scribble on the screen or some other Form, drawing and printing at any angle. Since I am a BitBlt, the drawing can be done with an arbitary source Form.

"
Class {
	#name : #PhratchPen,
	#superclass : #BitBlt,
	#instVars : [
		'location',
		'direction',
		'penDown'
	],
	#category : #'Phratch-Compatibility'
}

{ #category : #examples }
PhratchPen class >> example [
	"Draw a spiral with a pen that is 2 pixels wide."
	"Display restoreAfter: [Pen example]"
	| bic |
	bic := self new.
	bic defaultNib: 2.
	bic color: Color blue.
	bic combinationRule: Form over.
	1 
		to: 100
		do: 
			[ :i | 
			bic go: i * 4.
			bic turn: 89 ]
]

{ #category : #'tablet drawing examples' }
PhratchPen class >> feltTip: width cellSize: cellSize [ 
	"Warning: This example potentially uses a large amount of memory--it creates a Form with cellSize squared bits for every Display pixel."
	"In this example, all drawing is done into a large, monochrome Form and then scaled down onto the Display using smoothing. The larger the cell size, the more possible shades of gray can be generated, and the smoother the resulting line appears. A cell size of 8 yields 64 possible grays, while a cell size of 16 gives 256 levels, which is about the maximum number of grays that the human visual system can distinguish. The width parameter determines the maximum line thickness. Requires the optional tablet support primitives which may not be supported on all platforms. Works best in full screen mode. Shift-mouse to exit."
	"Pen feltTip: 2.7 cellSize: 8"
	| tabletScale bitForm pen warp p srcR dstR nibSize startP r |
	tabletScale := self tabletScaleFactor.
	bitForm := Form 
		extent: Display extent * cellSize
		depth: 1.
	pen := PhratchPen newOnForm: bitForm.
	pen color: Color black.
	warp := (WarpBlt current toForm: Display)
		sourceForm: bitForm;
		colorMap: (bitForm colormapIfNeededFor: Display);
		cellSize: cellSize;
		combinationRule: Form over.
	Display fillColor: Color white.
	Display restoreAfter: 
		[ [ Sensor shiftPressed and: [ Sensor anyButtonPressed ] ] whileFalse: 
			[ p := (Sensor tabletPoint * cellSize * tabletScale) rounded.
			nibSize := (Sensor tabletPressure * (cellSize * width)) rounded.
			nibSize > 0 
				ifTrue: 
					[ pen squareNib: nibSize.
					startP := pen location.
					pen goto: p.
					r := startP rect: pen location.
					dstR := r origin // cellSize corner: (r corner + nibSize + (cellSize - 1)) // cellSize.
					srcR := dstR origin * cellSize corner: dstR corner * cellSize.
					warp 
						copyQuad: srcR innerCorners
						toRect: dstR ]
				ifFalse: [ pen place: p ] ] ]
]

{ #category : #'tablet drawing examples' }
PhratchPen class >> inkBrush [
	"Similar to simplePressurePen, but this example uses the average of the recent pen pressure values. The effect is that of a Japanese ink brush that comes up gradually off the paper as the brush is lifted, causing end (and beginning) of each stroke to taper. Requires the optional tablet support primitives which may not be supported on all platforms. Works best in full screen mode. Shift-mouse to exit."
	"Pen inkBrush"
	| tabletScale historyMSecs pressureHistory pen now currentPressure sum averagePressure p |
	tabletScale := self tabletScaleFactor.
	historyMSecs := 120.
	pressureHistory := OrderedCollection new.
	pen := PhratchPen newOnForm: Display.
	pen color: Color black.
	Display fillColor: Color white.
	Display restoreAfter: 
		[ [ Sensor shiftPressed and: [ Sensor anyButtonPressed ] ] whileFalse: 
			[ "compute the average pressure over last historyMSecs milliseconds"
			now := Time millisecondClockValue.
			currentPressure := (20.0 * Sensor tabletPressure) rounded.
			pressureHistory addLast: (Array 
					with: now
					with: currentPressure).
			
			[ pressureHistory size > 0 and: [ pressureHistory first first + historyMSecs < now ] ] whileTrue: [ pressureHistory removeFirst ].	"prune old entries"
			sum := pressureHistory 
				inject: 0
				into: [ :t :e | t + e last ].
			averagePressure := sum // pressureHistory size.
			p := (Sensor tabletPoint * tabletScale) rounded.
			averagePressure > 0 
				ifTrue: 
					[ pen roundNib: averagePressure.
					pen goto: p ]
				ifFalse: [ pen place: p ] ] ]
]

{ #category : #'instance creation' }
PhratchPen class >> new [
	^ self newOnForm: Display
]

{ #category : #'instance creation' }
PhratchPen class >> newOnForm: aForm [ 
	| pen |
	pen := super new.
	pen setDestForm: aForm.
	pen sourceOrigin: 0 @ 0.
	pen home.
	pen defaultNib: 1.
	pen north.
	pen down.
	^ pen
]

{ #category : #'tablet drawing examples' }
PhratchPen class >> simplePressurePen [
	"An example of using a pressure sensitive pen to control the thickness of the pen. This requires the optional tablet support primitives which may not be supported on all platforms. Works best in full screen mode. Shift-mouse to exit."
	"Pen simplePressurePen"
	| tabletScale pen pressure p |
	tabletScale := self tabletScaleFactor.
	pen := PhratchPen newOnForm: Display.
	pen color: Color black.
	Display fillColor: Color white.
	Display restoreAfter: 
		[ [ Sensor shiftPressed and: [ Sensor anyButtonPressed ] ] whileFalse: 
			[ p := (Sensor tabletPoint * tabletScale) rounded.
			pressure := (15.0 * Sensor tabletPressure) rounded.
			pressure > 0 
				ifTrue: 
					[ pen roundNib: pressure.
					pen goto: p ]
				ifFalse: [ pen place: p ] ] ]
]

{ #category : #'tablet drawing examples' }
PhratchPen class >> tabletScaleFactor [
	"Answer a Point that scales tablet coordinates to Display coordinates, where the full extent of the tablet maps to the extent of the entire Display."
	| tabletExtent |
	tabletExtent := Sensor tabletExtent.
	^ (Display width asFloat / tabletExtent x) @ (Display height asFloat / tabletExtent y)
]

{ #category : #'tablet drawing examples' }
PhratchPen class >> testMouseTracking [
	"A very simple example of drawing using the mouse. Compare the tracking speed of this example with that of testTabletTracking. Mouse down to draw a stroke, shift-mouse to exit."
	"Pen testMouseTracking"
	| pen p |
	pen := PhratchPen newOnForm: Display.
	pen roundNib: 8.
	pen color: Color black.
	Display fillColor: Color white.
	Display restoreAfter: 
		[ [ Sensor shiftPressed and: [ Sensor anyButtonPressed ] ] whileFalse: 
			[ p := Sensor cursorPoint.
			Sensor anyButtonPressed 
				ifTrue: [ pen goto: p ]
				ifFalse: 
					[ pen color: Color random.
					pen place: p ] ] ]
]

{ #category : #'tablet drawing examples' }
PhratchPen class >> testTabletTracking [
	"A very simple example of drawing using the pen of a digitizing tablet such as a Wacom ArtZ tablet. This requires the optional tablet support primitives which may not be supported on all platforms. Compare the tracking speed of this example with that of testMouseTracking. On a Macintosh, the tablet primitives provide roughly 120 samples/second versus only 60 mouse samples/second, and the difference is noticable. Works best in full screen mode. Mouse down to draw a stroke, shift-mouse to exit."
	"Pen testTabletTracking"
	| tabletScale pen p |
	tabletScale := self tabletScaleFactor.
	pen := PhratchPen newOnForm: Display.
	pen roundNib: 8.
	pen color: Color black.
	Display fillColor: Color white.
	Display restoreAfter: 
		[ [ Sensor shiftPressed and: [ Sensor anyButtonPressed ] ] whileFalse: 
			[ p := (Sensor tabletPoint * tabletScale) rounded.
			Sensor tabletPressure > 0 
				ifTrue: [ pen goto: p ]
				ifFalse: 
					[ pen color: Color random.
					pen place: p ] ] ]
]

{ #category : #operations }
PhratchPen >> arrowHead [
	"Put an arrowhead on the previous pen stroke"
	" | pen | pen := Pen new. 20 timesRepeat: [pen turn: 360//20; go: 20; arrowHead]."

	penDown ifTrue:
		[self arrowHeadFrom: (direction degreeCos @ direction degreeSin) * -40 + location 
			to: location
			arrowSpec: (5 @ 4)]
]

{ #category : #operations }
PhratchPen >> arrowHeadForArrowSpec: anArrowSpec [
	"Put an arrowhead on the previous pen stroke"
"
	 | pen aPoint |
	aPoint _ Point fromUser.
	pen _ Pen new.
	20 timesRepeat: [pen turn: 360//20; go: 20; arrowHeadForArrowSpec: aPoint].
"


	penDown ifTrue:
		[self arrowHeadFrom: (direction degreeCos @ direction degreeSin) * -40 + location 
			to: location
			arrowSpec: anArrowSpec]
]

{ #category : #operations }
PhratchPen >> arrowHeadFrom: prevPt to: newPt arrowSpec: anArrowSpec [ 
	"Put an arrowhead on the pen stroke from oldPt to newPt"
	| pm af myColor finalPt delta |
	myColor := self color.
	delta := newPt - prevPt.
	delta r <= 2 ifTrue: 
		[ "pixels"
		^ self ].
	finalPt := newPt + (Point 
			r: sourceForm width
			degrees: delta degrees).	"in same direction"
	pm := PolygonMorph 
		vertices: (Array 
				with: prevPt asIntegerPoint
				with: finalPt asIntegerPoint)
		color: myColor
		borderWidth: sourceForm width
		borderColor: myColor.	"not used"
	pm
		makeOpen;
		makeForwardArrow.
	anArrowSpec ifNotNil: [ pm arrowSpec: anArrowSpec ].
	af := pm arrowForms first.
	"render it onto the destForm"
	(FormCanvas on: destForm) 
		stencil: af
		at: af offset + (1 @ 1)
		color: myColor	"Display"
]

{ #category : #operations }
PhratchPen >> color: aColorOrInteger [ 
	"Set the pen to the given color or to a color chosen from a fixed set of colors."
	| count c |
	aColorOrInteger isInteger 
		ifTrue: 
			[ destForm depth = 1 ifTrue: [ ^ self fillColor: Color black ].
			count := 19.	"number of colors in color wheel"
			c := (Color red wheel: count) at: aColorOrInteger * 7 \\ count + 1 ]
		ifFalse: [ c := aColorOrInteger ].	"assume aColorOrInteger is a Color"
	self fillColor: c
]

{ #category : #initialization }
PhratchPen >> defaultNib: widthInteger [ 
	"Nib is the tip of a pen. This sets up the pen, with a nib of width widthInteger. You can also set the shape of the pen nib using:
		roundNib: widthInteger, or
		squareNib: widthInteger, or
		sourceForm: aForm"
"Example:
	| bic |
	bic _ Pen new sourceForm: Cursor normal.
	bic combinationRule: Form paint; turn: 90.
	10 timesRepeat: [bic down; go: 3; up; go: 10]."

	self color: Color black.
	self squareNib: widthInteger.

]

{ #category : #accessing }
PhratchPen >> direction [
	"Answer the receiver's current direction. 0 is towards the top of the
	screen."

	^direction
]

{ #category : #operations }
PhratchPen >> down [
	"Set the state of the receiver's pen to down (drawing)."
	penDown := true
]

{ #category : #'geometric designs' }
PhratchPen >> dragon: n [  "Display restoreAfter: [Display fillWhite. Pen new dragon: 10]."
	"Display restoreAfter: [Display fillWhite. 1 to: 4 do:
				[:i | Pen new color: i; turn: 90*i; dragon: 10]]"
	"Draw a dragon curve of order n in the center of the screen."
	n = 0
		ifTrue: [self go: 5]
		ifFalse: [n > 0
				ifTrue: [self dragon: n - 1; turn: 90; dragon: 1 - n]
				ifFalse: [self dragon: -1 - n; turn: -90; dragon: 1 + n]]

]

{ #category : #operations }
PhratchPen >> go: distance [ 
	"Move the pen in its current direction a number of bits equal to the 
	argument, distance. If the pen is down, a line will be drawn using the 
	receiver's form source as the shape of the drawing brush."

	self goto: (direction degreeCos @ direction degreeSin) * distance + location
]

{ #category : #operations }
PhratchPen >> goto: aPoint [ 
	"Move the receiver to position aPoint. If the pen is down, a line will be 
	drawn from the current position to the new one using the receiver's 
	form source as the shape of the drawing brush. The receiver's set 
	direction does not change."
	| old |
	old := location.
	location := aPoint.
	penDown ifTrue: 
		[ self 
			drawFrom: old rounded
			to: location rounded

		"NOTE:  This should be changed so it does NOT draw the first point, so as
	not to overstrike at line junctions.  At the same time, place should draw
	a single dot if the pen is down, as should down (put-pen-down) if it
	was not down before." ]
]

{ #category : #'geometric designs' }
PhratchPen >> hilbert: n side: s [ 
	"Draw an nth level Hilbert curve with side length s in the center of the 
	screen. Write directly into the display's bitmap only. A Hilbert curve is 
	a space-filling curve."
	| a m |
	n = 0 ifTrue: [ ^ self turn: 180 ].
	n > 0 
		ifTrue: 
			[ a := 90.
			m := n - 1 ]
		ifFalse: 
			[ a := -90.
			m := n + 1 ].
	self turn: a.
	self 
		hilbert: 0 - m
		side: s.
	self
		turn: a;
		go: s.
	self 
		hilbert: m
		side: s.
	self
		turn: 0 - a;
		go: s;
		turn: 0 - a.
	self 
		hilbert: m
		side: s.
	self
		go: s;
		turn: a.
	self 
		hilbert: 0 - m
		side: s.
	self turn: a
	" 
	(Pen new) hilbert: 3 side: 8. 
	(Pen new sourceForm: Cursor wait) combinationRule: Form under; 
	hilbert: 3 side: 25.
	"
]

{ #category : #'geometric designs' }
PhratchPen >> hilberts: n [ 
	"Display restoreAfter: [Display fillWhite.  Pen new hilberts: 5]"
	"Draws n levels of nested Hilbert curves"
	| s |
	self
		up;
		turn: 90;
		go: 128;
		down.
	1 
		to: n
		do: 
			[ :i | 
			s := 256 bitShift: 0 - i.
			self defaultNib: (n - i) * 2 + 1.
			self color: i + 1.
			self
				up;
				go: (0 - s) / 2;
				turn: -90;
				go: s / 2;
				turn: 90;
				down.
			self 
				hilbert: i
				side: s.
			self go: s.
			self 
				hilbert: i
				side: s.
			self go: s ]
]

{ #category : #operations }
PhratchPen >> home [
	"Place the receiver at the center of its frame."
	location := destForm boundingBox center
]

{ #category : #accessing }
PhratchPen >> location [
	"Answer where the receiver is currently located."

	^location
]

{ #category : #private }
PhratchPen >> location: aPoint direction: aFloat penDown: aBoolean [ 
	location := aPoint.
	direction := aFloat.
	penDown := aBoolean
]

{ #category : #'geometric designs' }
PhratchPen >> mandala: npoints [ 
	"Display restoreAfter: [Pen new mandala: 30]"
	"On a circle of diameter d, place npoints number of points. Draw all 	possible connecting lines between the circumferential points."
	| l points d |
	Display fillWhite.
	d := Display height - 50.
	l := 3.14 * d / npoints.
	self
		home;
		up;
		turn: -90;
		go: d // 2;
		turn: 90;
		go: (0 - l) / 2;
		down.
	points := Array new: npoints.
	1 
		to: npoints
		do: 
			[ :i | 
			points 
				at: i
				put: location rounded.
			self
				go: l;
				turn: 360.0 / npoints ].
	npoints // 2 
		to: 1
		by: -1
		do: 
			[ :i | 
			self color: i.
			1 
				to: npoints
				do: 
					[ :j | 
					self place: (points at: j).
					self goto: (points at: (j + i - 1) \\ npoints + 1) ] ]
]

{ #category : #operations }
PhratchPen >> north [
	"Set the receiver's direction to facing toward the top of the display screen."
	direction := 270
]

{ #category : #operations }
PhratchPen >> place: aPoint [ 
	"Set the receiver at position aPoint. No lines are drawn."
	location := aPoint
]

{ #category : #operations }
PhratchPen >> print: str withFont: font [ 
	"Print the given string in the given font at the current heading"
	| lineStart form charStart rowStart scale wasDown bb pix |
	scale := sourceForm width.
	wasDown := penDown.
	lineStart := location.
	str do: 
		[ :char | 
		char = Character cr 
			ifTrue: 
				[ self
					place: lineStart;
					up;
					turn: 90;
					go: font height * scale;
					turn: -90;
					down ]
			ifFalse: 
				[ form := font characterFormAt: char.
				charStart := location.
				wasDown ifTrue: 
					[ self
						up;
						turn: -90;
						go: font descent * scale;
						turn: 90;
						down.
					0 
						to: form height - 1
						do: 
							[ :y | 
							rowStart := location.
							bb := BitBlt current bitPeekerFromForm: form.
							pix := RunArray newFrom: ((0 to: form width - 1) collect: [ :x | bb pixelAt: x @ y ]).
							pix runs 
								with: pix values
								do: 
									[ :run :value | 
									value = 0 
										ifTrue: 
											[ self
												up;
												go: run * scale;
												down ]
										ifFalse: [ self go: run * scale ] ].
							self
								place: rowStart;
								up;
								turn: 90;
								go: scale;
								turn: -90;
								down ] ].
				self
					place: charStart;
					up;
					go: form width * scale;
					down ] ].
	wasDown ifFalse: 
		[ self up
		"
Display restoreAfter:
[Pen new squareNib: 2; color: Color red; turn: 45;
	print: 'The owl and the pussycat went to sea
in a beautiful pea green boat.' withFont: TextStyle defaultFont]
" ]
]

{ #category : #operations }
PhratchPen >> putDotOfDiameter: aDiameter at: aPoint [
 	"Put a dot of the given size at the given point, using my colot"
 
 	(FormCanvas on: destForm) 
 			fillOval: (Rectangle center: aPoint extent: (aDiameter @ aDiameter))
 			color: self color
]

{ #category : #initialization }
PhratchPen >> roundNib: diameter [ 
	"Makes this pen draw with a round dot of the given diameter."
	self sourceForm: (Form dotOfSize: diameter).
	combinationRule := Form paint
]

{ #category : #private }
PhratchPen >> sourceForm: aForm [ 
	(aForm depth = 1 and: [ destForm depth > 1 ]) 
		ifTrue: 
			[ "Map 1-bit source to all ones for color mask"
			colorMap := Bitmap 
				with: 0
				with: 4294967295 ]
		ifFalse: [ colorMap := nil ].
	^ super sourceForm: aForm
]

{ #category : #'geometric designs' }
PhratchPen >> spiral: n angle: a [ 
	"Draw a double squiral (see Papert, MindStorms), where each design is made
	by moving the receiver a distance of n after turning the amount + or -a."

	1 to: n do: 
		[:i | 
		self color: i * 2.
		self go: i; turn: a]
"
	Display restoreAfter: [
		Display fillWhite. Pen new spiral: 200 angle: 89; home; spiral: 200 angle: -89].
"
]

{ #category : #initialization }
PhratchPen >> squareNib: widthInteger [ 
	"Makes this pen draw with a square nib of the given width."

	self sourceForm: (Form extent: widthInteger @widthInteger) fillBlack.
	self combinationRule: Form over.  "a bit faster than paint mode"

]

{ #category : #operations }
PhratchPen >> turn: degrees [ 
	"Change the direction that the receiver faces by an amount equal to the 
	argument, degrees."
	direction := direction + degrees
]

{ #category : #operations }
PhratchPen >> up [
	"Set the state of the receiver's pen to up (no drawing)."
	penDown := false
]

{ #category : #'geometric designs' }
PhratchPen >> web [
	"Display restoreAfter: [Pen new web]"
	"Draw pretty web-like patterns from the mouse movement on the screen.
	Press the mouse button to draw, option-click to exit.
	By Dan Ingalls and Mark Lentczner. "
	"self erase."
	| history newPoint ancientPoint lastPoint filter color |
	color := 1.
	[ true ] whileTrue: 
		[ history := OrderedCollection new.
		Sensor waitButton.
		Sensor yellowButtonPressed ifTrue: [ ^ self ].
		filter := lastPoint := Sensor cursorPoint.
		20 timesRepeat: [ history addLast: lastPoint ].
		self color: (color := color + 1).
		[ Sensor redButtonPressed ] whileTrue: 
			[ newPoint := Sensor cursorPoint.
			newPoint = lastPoint ifFalse: 
				[ ancientPoint := history removeFirst.
				filter := (filter * 4 + newPoint) // 5.
				self place: filter.
				self goto: ancientPoint.
				lastPoint := newPoint.
				history addLast: filter ] ] ]
]
