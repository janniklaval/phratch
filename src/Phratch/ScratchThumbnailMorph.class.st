"
I show an updating thumbnail picture of my target morph. I allow the direction of my target to be set by dragging.

"
Class {
	#name : #ScratchThumbnailMorph,
	#superclass : #ImageMorph,
	#instVars : [
		'target',
		'showDirection',
		'lastUpdateMSecs',
		'lastRotationDegrees',
		'draggingDirection'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'event handling' }
ScratchThumbnailMorph >> doubleClick: evt [
	"Set my target to it's normal orientation."

	(target respondsTo: #rotationDegrees:) ifFalse: [^ self].
	target rotationDegrees: 0.
	self updateThumbnail.

]

{ #category : #drawing }
ScratchThumbnailMorph >> drawOn: aCanvas [

	| offset |
	super drawOn: aCanvas.
	(target respondsTo: #rotationDegrees:) ifFalse: [^ self].  "nil or background"
	showDirection ifTrue: [
		offset := Point r: (self width / 2) - 1 degrees: target rotationDegrees.
		aCanvas line: self center to: self center + offset width: 1 color: Color blue].


]

{ #category : #accessing }
ScratchThumbnailMorph >> extent: aPoint [
"Only use squares"
	self form: (ColorForm extent: aPoint depth: 16).
	self form fillColor: Color transparent.
	self form border: self form boundingBox width: 1.
	showDirection := true.
	lastUpdateMSecs := -1.
]

{ #category : #'event handling' }
ScratchThumbnailMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #initialization }
ScratchThumbnailMorph >> initialize [

	super initialize.
	self form: (Form extent: 46@46 depth: 16).
	self form fillColor: Color transparent.
	self form border: self form boundingBox width: 1.
	showDirection := true.
	lastUpdateMSecs := -1.

]

{ #category : #'event handling' }
ScratchThumbnailMorph >> mouseDown: evt [

	draggingDirection := false.
	evt shiftPressed ifTrue: [
		target ifNotNil: [target makeVisible].
		^ self].

	evt hand waitForClicksOrDrag: self event: evt.

]

{ #category : #'event handling' }
ScratchThumbnailMorph >> mouseMove: evt [

	| p |
	draggingDirection ifFalse: [^ self].
	(target respondsTo: #rotationDegrees:) ifFalse: [^ self].
	p := evt cursorPoint - self center.
	p r > 0 ifTrue: [target heading: p theta radiansToDegrees rounded + 90].
	self updateThumbnail.

]

{ #category : #accessing }
ScratchThumbnailMorph >> showDirection: aBoolean [

	showDirection := aBoolean.

]

{ #category : #'event handling' }
ScratchThumbnailMorph >> startDrag: evt [

	draggingDirection := true.

]

{ #category : #stepping }
ScratchThumbnailMorph >> step [
	"Optimization: Don't update unless the costume has changed."

	| delta |
	((target respondsTo: #rotationDegrees) and:
	 [lastRotationDegrees ~= target rotationDegrees]) ifTrue: [
		self changed.  "update the direction marker"
		lastRotationDegrees := target rotationDegrees].

	(target notNil and:
	 [lastUpdateMSecs = target costumeChangeMSecs])
		ifTrue: [^ self].

	delta := Time millisecondClockValue - lastUpdateMSecs.
	(delta < 0) | (delta > 100) ifTrue: [self updateThumbnail].

]

{ #category : #stepping }
ScratchThumbnailMorph >> stepTime [

	^ 100

]

{ #category : #accessing }
ScratchThumbnailMorph >> target [

	^ target

]

{ #category : #accessing }
ScratchThumbnailMorph >> target: aMorph [

	target := aMorph.
	self updateThumbnail.

]

{ #category : #stepping }
ScratchThumbnailMorph >> updateThumbnail [

	| f e r |
	self form fillColor: Color transparent.
	target ifNil: [^ self].

	f := target imageForm.

	((f width <= self form width) & (f height <= self form height)) ifTrue: [
		"target's image fits without shrinking"
		f displayOn: self form at: ((self form extent - f extent) // 2).
		^ self changed].

	f width > f height 
		ifTrue: [e := self form width @ ((f height *self  form width) // f width)]
		ifFalse: [e := ((f width * self form height) // f height) @ self form height].
	e := e max: (8@8).
	r := Rectangle center: (self form extent // 2) extent: e.

	(WarpBlt toForm: self form)
		sourceForm: f;
		cellSize: 2;  "do smoothing; this also installs a colormap"
		combinationRule: Form paint;
		copyQuad: f boundingBox innerCorners toRect: (r insetBy: 2).

	lastUpdateMSecs := target costumeChangeMSecs.
	self changed.

]
