"
A slider for a variable watcher.

"
Class {
	#name : #WatcherSliderMorph,
	#superclass : #SimpleSliderMorph,
	#instVars : [
		'forms'
	],
	#category : #'Phratch-UI-Watchers'
}

{ #category : #'event handling' }
WatcherSliderMorph >> click: evt [

	| delta |
	delta := (evt cursorPoint x - slider center x) sign.
	truncate ifFalse: [delta := delta * ((maxVal - minVal) / 100.0)].
	self setScaledValue: self getScaledValue + delta.

]

{ #category : #'event handling' }
WatcherSliderMorph >> dragOffset [

	^ self valueOfProperty: #dragOffset ifAbsent:[nil].
]

{ #category : #'event handling' }
WatcherSliderMorph >> dragOffset: anOffset [

	^ self setProperty: #dragOffset toValue: anOffset
]

{ #category : #drawing }
WatcherSliderMorph >> drawOn: aCanvas [
	"Draw my normalLeft/normalEdge/normalRight forms and extend the normalEdgeForm to the width of my bounds."

	| formLeft formEdge formRight startPoint p clipC lastX |
	formLeft := forms at: 1.
	formEdge := forms at: 2.
	formRight := forms at: 3.

	startPoint := self bounds origin + (formLeft width@0).
	p := startPoint.
	clipC := aCanvas copyClipRect: self bounds.
	lastX := self bounds right - (formRight width) - 1.

	clipC translucentImage: formLeft at: self bounds origin.
	[p x <= lastX] whileTrue: [
		clipC translucentImage: formEdge at: p.
		p := (p x + formEdge width) @ p y].
	clipC translucentImage: formRight at: p.

]

{ #category : #'event handling' }
WatcherSliderMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #initialization }
WatcherSliderMorph >> initialize [

	"setup forms before calling super initialize"
	forms := Array new: 4.
	forms at: 1 put: (PhratchFrameMorph skinAt: #watcherSliderLeft).
	forms at: 2 put: (PhratchFrameMorph skinAt: #watcherSliderMiddle).
	forms at: 3 put: (PhratchFrameMorph skinAt: #watcherSliderRight).
	forms at: 4 put: (PhratchFrameMorph skinAt: #watcherSliderButton).

	super initialize.
	self minVal: 0;
		maxVal: 100;
		setValue: 50;
		borderWidth: 0.

]

{ #category : #initialization }
WatcherSliderMorph >> initializeSlider [

	slider := ImageMorph new form: (forms at: 4).
	self addMorph: slider.

]

{ #category : #'event handling' }
WatcherSliderMorph >> mouseDown: evt [

	(slider containsPoint: evt cursorPoint) ifTrue: [
		self dragOffset: (slider position - evt cursorPoint).
		^ self].

	self dragOffset: nil.
	evt hand waitForClicksOrDrag: self event: evt.

]

{ #category : #'event handling' }
WatcherSliderMorph >> mouseMove: evt [

	self dragOffset ifNotNil: [self scrollAbsolute: evt].

]

{ #category : #'event handling' }
WatcherSliderMorph >> mouseUp: evt [
	"Overidden to do nothing."

]

{ #category : #private }
WatcherSliderMorph >> sliderExtent [

	^ slider extent

]

{ #category : #'hacking - SPFA' }
WatcherSliderMorph >> sliderThickness [

	^ 0
]

{ #category : #'hacking - SPFA' }
WatcherSliderMorph >> sliderThickness: ignored [
]

{ #category : #'event handling' }
WatcherSliderMorph >> startDrag: evt [

	self dragOffset: (slider extent // 2) negated.

]

{ #category : #private }
WatcherSliderMorph >> updateSliderPosition [
	"Set my slider position to the variable's current value"

	| watcher val |
	self target ifNil: [^ self].
	(watcher := self ownerOrYourselfThatIsAWatcherMorph) ifNil: [^ self].

	val := self target getVar: watcher getVariable.
	val ifNil: [^ self].  "can happen when variable has been deleted"
	val := val asNumberNoError.
	self adjustToValue: (val within: minVal and: maxVal).

]
