"
I show an updating thumbnail picture of my target morph. I allow the direction of my target to be set by dragging.

"
Class {
	#name : #PhratchThumbnailMorph,
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
PhratchThumbnailMorph >> doubleClick: evt [
	"Set my target to it's normal orientation."

	(target respondsTo: #rotationDegrees:) ifFalse: [^ self].
	target rotationDegrees: 0.
	self updateThumbnail.

]

{ #category : #drawing }
PhratchThumbnailMorph >> drawOn: aCanvas [
	| offset |
	super drawOn: aCanvas.
	(target respondsTo: #rotationDegrees:)
		ifFalse: [ ^ self ].	"nil or background"
	showDirection
		ifFalse: [ ^ self ].
	offset := Point r: self width / 2 - 1 degrees: target rotationDegrees.
	aCanvas
		line: self center
		to: self center + offset
		width: 1
		color: Color blue
]

{ #category : #accessing }
PhratchThumbnailMorph >> extent: aPoint [
"Only use squares"
	self form: (ColorForm extent: aPoint depth: 16).
	self form fillColor: Color transparent.
	self form border: self form boundingBox width: 1.
	showDirection := true.
	lastUpdateMSecs := -1.
]

{ #category : #'event handling' }
PhratchThumbnailMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #initialization }
PhratchThumbnailMorph >> initialize [

	super initialize.
	self form: (Form extent: 46@46 depth: 16).
	self form fillColor: Color transparent.
	self form border: self form boundingBox width: 1.
	showDirection := true.
	lastUpdateMSecs := -1.

]

{ #category : #'event handling' }
PhratchThumbnailMorph >> mouseDown: evt [

	draggingDirection := false.
	evt shiftPressed ifTrue: [
		target ifNotNil: [target makeVisible].
		^ self].

	evt hand waitForClicksOrDrag: self event: evt.

]

{ #category : #'event handling' }
PhratchThumbnailMorph >> mouseMove: evt [

	| p |
	draggingDirection ifFalse: [^ self].
	(target respondsTo: #rotationDegrees:) ifFalse: [^ self].
	p := evt cursorPoint - self center.
	p r > 0 ifTrue: [target heading: p theta radiansToDegrees rounded + 90].
	self updateThumbnail.

]

{ #category : #accessing }
PhratchThumbnailMorph >> showDirection: aBoolean [

	showDirection := aBoolean.

]

{ #category : #'event handling' }
PhratchThumbnailMorph >> startDrag: evt [

	draggingDirection := true.

]

{ #category : #stepping }
PhratchThumbnailMorph >> step [
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
PhratchThumbnailMorph >> stepTime [

	^ 10

]

{ #category : #accessing }
PhratchThumbnailMorph >> target [

	^ target

]

{ #category : #accessing }
PhratchThumbnailMorph >> target: aMorph [

	target := aMorph.
	self updateThumbnail.

]

{ #category : #stepping }
PhratchThumbnailMorph >> updateThumbnail [
	| f e r |
	self form fillColor: Color transparent.
	target ifNil: [ ^ self ].
	f := target imageForm.
	f width <= self form width & (f height <= self form height)
		ifTrue: [ 
			"target's image fits without shrinking"
			f displayOn: self form at: (self form extent - f extent) // 2.
			^ self changed ].
	e := f width > f height
		ifTrue: [ self form width @ (f height * self form width // f width) ]
		ifFalse: [ (f width * self form height // f height) @ self form height ].
	e := e max: 8 @ 8.
	r := Rectangle center: self form extent // 2 extent: e.
	(WarpBlt toForm: self form)
		sourceForm: f;
		cellSize: 2;
		combinationRule: Form paint;
		copyQuad: f boundingBox innerCorners toRect: (r insetBy: 2).	"do smoothing; this also installs a colormap"
	lastUpdateMSecs := target costumeChangeMSecs.
	self changed
]
