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
	#category : #'Phratch-Paint'
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
	bic := Pen new sourceForm: Cursor normal.
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

{ #category : #initialization }
PhratchPen >> roundNib: diameter [ 
	"Makes this pen draw with a round dot of the given diameter."
	self sourceForm: (Form dotOfSize: diameter).
	combinationRule := Form paint
]

{ #category : #private }
PhratchPen >> sourceForm: aForm [
	colorMap := (aForm depth = 1 and: [ destForm depth > 1 ])
		ifTrue: [ Bitmap with: 0 with: 4294967295 ]
		ifFalse: [ nil ].	"Map 1-bit source to all ones for color mask"
	^ super sourceForm: aForm
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
