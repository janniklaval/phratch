Class {
	#name : #WatcherSliderMorph,
	#superclass : #PhratchSimpleSliderMorph,
	#instVars : [
		'forms'
	],
	#category : #'Phratch-UI-Watchers'
}

{ #category : #'as yet unclassified' }
WatcherSliderMorph >> click: evt [

	| delta |
	delta := (evt cursorPoint x - slider center x) sign.
	truncate ifFalse: [delta := delta * ((maxVal - minVal) / 100.0)].
	self setScaledValue: self getScaledValue + delta.

]

{ #category : #'as yet unclassified' }
WatcherSliderMorph >> dragOffset [

	^ self valueOfProperty: #dragOffset ifAbsent:[nil].
]

{ #category : #'as yet unclassified' }
WatcherSliderMorph >> dragOffset: anOffset [

	^ self setProperty: #dragOffset toValue: anOffset
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
WatcherSliderMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
WatcherSliderMorph >> initializeSlider [

	slider := ImageMorph new form: (forms at: 4).
	self addMorph: slider.

]

{ #category : #'as yet unclassified' }
WatcherSliderMorph >> mouseDown: evt [

	(slider containsPoint: evt cursorPoint) ifTrue: [
		self dragOffset: (slider position - evt cursorPoint).
		^ self].

	self dragOffset: nil.
	evt hand waitForClicksOrDrag: self event: evt.

]

{ #category : #'as yet unclassified' }
WatcherSliderMorph >> mouseMove: evt [

	self dragOffset ifNotNil: [self scrollAbsolute: evt].

]

{ #category : #'as yet unclassified' }
WatcherSliderMorph >> mouseUp: evt [
	"Overidden to do nothing."

]

{ #category : #'as yet unclassified' }
WatcherSliderMorph >> sliderExtent [

	^ slider extent

]

{ #category : #'as yet unclassified' }
WatcherSliderMorph >> sliderThickness [

	^ 0
]

{ #category : #'as yet unclassified' }
WatcherSliderMorph >> sliderThickness: ignored [
]

{ #category : #'as yet unclassified' }
WatcherSliderMorph >> startDrag: evt [

	self dragOffset: (slider extent // 2) negated.

]

{ #category : #'as yet unclassified' }
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
