"
This subclass of ScrollFrameMorph uses ScratchScrollBars.

"
Class {
	#name : #ScrollFrameMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'scrollBarStartInset',
		'scrollBarEndInset',
		'dragOffset',
		'contents',
		'hScrollbar',
		'vScrollbar',
		'cornerMorph',
		'hbarInset',
		'vbarInset',
		'contentsChanged',
		'growthFraction'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'scrollbar visibility' }
ScrollFrameMorph >> abortDelay [
	"private"

]

{ #category : #'scrollbar visibility' }
ScrollFrameMorph >> contents [
	"Answer my contents morph."

	^ contents

]

{ #category : #'scrollbar visibility' }
ScrollFrameMorph >> contents: aMorph [
	"Replace my contents morph. The argument can be any morph. Typically it is a BorderedMorph or a PasteUpMorph."

	contents ifNotNil: [contents delete].
	contents := aMorph.
	contents position: self topLeft + borderWidth.
	self addMorphBack: contents.
	self extent: self extent.

]

{ #category : #private }
ScrollFrameMorph >> contentsBounds [
	"Answer a rectangle that encloses the bounds of all my submorphs."

	| offset r |
	offset := contents topLeft negated.
	r := 0@0 extent: 1@1.
	contents submorphsDo: [:m |
		r := r quickMerge: (m fullBounds translateBy: offset) truncated].
	^ r

]

{ #category : #'scrolling by dragging' }
ScrollFrameMorph >> dragContentsTo: aPoint [
	|  hDiff vDiff |
	hDiff := aPoint x - contents left - dragOffset x.
	vDiff := aPoint y - contents top - dragOffset y.
	self hScrollPixels: self hScrollPixels - hDiff;
	vScrollPixels: self vScrollPixels - vDiff
]

{ #category : #drawing }
ScrollFrameMorph >> drawSubmorphsOn: aCanvas [
	"If my contents has changed, fix it's extent and update my scrollbar ranges. Clip submorph drawing to my bounds."

	| clipR |
	contentsChanged ifTrue: [
		self updateContentsExtent.
		self updateScrollbars.
		contentsChanged := false].

	"draw my contents morph clipped to my visible extent"
	clipR := self innerBounds topLeft extent: self visibleExtent.
	(aCanvas copyClipRect: clipR) fullDrawMorph: contents.

	"draw all my submorphs other than my contents"
	submorphs reverseDo:[:m |
		(m ~~ contents) ifTrue: [aCanvas fullDrawMorph: m]].



]

{ #category : #'scrolling by dragging' }
ScrollFrameMorph >> dropContents [
	World activeHand showTemporaryCursor: nil.
	dragOffset := nil
]

{ #category : #geometry }
ScrollFrameMorph >> extent: aPoint [
	"After setting my size, position and size my scrollbars and grow box. Also update my contents and scrollbar ranges."

	| inner w h |
	super extent: (aPoint truncated max: self minWidth @ self minHeight).
	scrollBarStartInset ifNil: [ scrollBarStartInset := scrollBarEndInset := 0 ].	"needed during initialization"
	inner := self innerBounds.
	w := inner width - scrollBarStartInset.
	w := vScrollbar owner = self
		ifTrue: [ w - vbarInset ]
		ifFalse: [ w - scrollBarEndInset ].
	hScrollbar position: (inner left + scrollBarStartInset) @ (inner bottom - hbarInset).
	hScrollbar width: w.
	hScrollbar extent: w @ hbarInset.
	h := inner height - scrollBarStartInset.
	h := hScrollbar owner = self
		ifTrue: [ h - hbarInset ]
		ifFalse: [ h - scrollBarEndInset ].
	PhratchTranslator isRTL
		ifTrue: [ vScrollbar position: (inner left + 9) @ (inner top + scrollBarStartInset) ]
		ifFalse: [ vScrollbar position: (inner right - vbarInset) @ (inner top + scrollBarStartInset) ].
	vScrollbar height: h.
	vScrollbar extent: vbarInset @ h.
	cornerMorph position: inner bottomRight - (vbarInset @ hbarInset).
	cornerMorph extent: vbarInset @ hbarInset.
	self updateContentsExtent.
	self updateScrollbars
]

{ #category : #'*Phratch-extensions' }
ScrollFrameMorph >> fieldsVersion [

	^ 1

]

{ #category : #'scrollbar visibility' }
ScrollFrameMorph >> fullBounds [
	"Overridden to clip submorph hit detection to my bounds."

	^ bounds

]

{ #category : #'scrolling by dragging' }
ScrollFrameMorph >> grabContentsAt: aPoint [
	self isScrollable
		ifFalse: [ ^ self ].
	World activeHand
		newKeyboardFocus: self;
		showTemporaryCursor: Cursor handClosed.
	dragOffset := aPoint - (contents left @ contents top)
]

{ #category : #'scrollbar visibility' }
ScrollFrameMorph >> growthFraction: aNumber [
	"Set the amount to grow when contents do not fit, expressed as a fraction of the current size. For example, 0.5 makes the contains pane 50% larger if any submorph extends over the edge."

	growthFraction := aNumber max: 0.0.

]

{ #category : #'scrollbar visibility' }
ScrollFrameMorph >> hBarInset: anInteger [

	hbarInset := anInteger.

]

{ #category : #layout }
ScrollFrameMorph >> hResizing [

	^  #spaceFill

]

{ #category : #scrolling }
ScrollFrameMorph >> hScrollPixels [
	"Answer the current horizontal scroll offset in pixels."

	^ (self left + borderWidth) - contents left


]

{ #category : #scrolling }
ScrollFrameMorph >> hScrollPixels: hOffset [
	"Scroll to the given horizontal offset in pixels. Zero is scrolled to the left and increasing values scroll right."

	| delta maxOffset |
	delta := (hOffset asInteger min: self maxScroll x) max: 0.
	contents left: ((self left + borderWidth) - delta) truncated.

	maxOffset := self maxScroll x.
	maxOffset > 0 ifTrue: [hScrollbar value: self hScrollPixels / maxOffset].

]

{ #category : #scrolling }
ScrollFrameMorph >> hScrollRelative: aFloat [
	"Sent by the horizontal scrollbar. Scroll to the given relative postion between 0.0 and 1.0."

	self hScrollPixels: aFloat * self maxScroll x.

]

{ #category : #'event handling' }
ScrollFrameMorph >> handlesMouseDown: evt [
	^ true
]

{ #category : #'event handling' }
ScrollFrameMorph >> handlesMouseOverDragging: evt [
	^true
]

{ #category : #initialization }
ScrollFrameMorph >> initialize [

	super initialize.
	
	self borderWidth: 0.

	self color: Color blue.
	hbarInset := 30.
	vbarInset := 25.
	scrollBarStartInset := 10.
	scrollBarEndInset := 14.
	contentsChanged := false.
	growthFraction := 0.6.  "amount to grow when contents do not fit as a fraction of the current size"

	contents := PasteUpMorph new
		color: (Color gray: 0.9);
		borderWidth: 0;
		enableDragNDrop: true;
		yourself.

	hScrollbar := PhratchScrollBar newHorizontal
		target: self;
		selector: #hScrollRelative:;
		yourself.
	vScrollbar := PhratchScrollBar newVertical
		target: self;
		selector: #vScrollRelative:;
		yourself.
	cornerMorph := BorderedMorph new
		borderRaised; borderWidth: 2;
		yourself.
		
	contents position: self position + borderWidth.
	self addMorph: contents.
	self addMorph: hScrollbar.
	self addMorph: vScrollbar.
	self extent: 160@120.

]

{ #category : #geometry }
ScrollFrameMorph >> invalidRect: damageRect [
	"Clip damage reports to my bounds, since drawing is clipped to my bounds."

	| r |
	r := damageRect intersect: self bounds.
	(r width > 0 and: [r height > 0]) ifTrue: [super invalidRect: r].

]

{ #category : #layout }
ScrollFrameMorph >> isAlignmentMorph [
	"Answer true, since I can be laid out as if I were an AlignmentMorph. I pretend to be an AlignmentMorph so that I can be resized when I'm inside another AlignmentMorph."

	^ true

]

{ #category : #'scrolling by dragging' }
ScrollFrameMorph >> isBeingDragged [
	"answer true if the receiver is currently being scrolled by means of dragging"
	^dragOffset notNil
]

{ #category : #'scrolling by dragging' }
ScrollFrameMorph >> isScrollable [
	"private - answer true if the receiver is partially hidden and thus can be scrolled"

	^(self findA: PhratchScrollBar) notNil and: [
		(self ownerThatIsA: OffscreenWorldMorph) isNil ]
]

{ #category : #geometry }
ScrollFrameMorph >> layoutChanged [
	"If my contents morph's layout has changed, record that fact."

	super layoutChanged.
	contents mayNeedLayout ifTrue: [contentsChanged := true].

]

{ #category : #scrolling }
ScrollFrameMorph >> maxScroll [
	"Answer a point representing the maximum horizontal and vertical scroll offsets in pixels."

	^ contents extent - self visibleExtent

]

{ #category : #layout }
ScrollFrameMorph >> minHeight [

	^ 45

]

{ #category : #layout }
ScrollFrameMorph >> minWidth [

	^ 60

]

{ #category : #'event handling' }
ScrollFrameMorph >> mouseDown: evt [ 
	(owner isKindOf: PhratchFilePicker) ifTrue: [^owner mouseDown: evt].
	evt redButtonPressed ifTrue: [ self grabContentsAt: evt cursorPoint ]
]

{ #category : #'event handling' }
ScrollFrameMorph >> mouseEnterDragging: evt [
	"Handle a mouseEnterDragging event. The mouse just entered my bounds with a button pressed or laden with submorphs."

	self abortDelay.

]

{ #category : #'event handling' }
ScrollFrameMorph >> mouseMove: evt [ 
	(owner isKindOf: PhratchFilePicker) ifTrue: [^owner mouseMove: evt].
	dragOffset ifNotNil: [self dragContentsTo: evt cursorPoint]
]

{ #category : #'event handling' }
ScrollFrameMorph >> mouseUp: evt [
	(owner isKindOf: PhratchFilePicker) ifTrue: [^owner mouseUp: evt].
	self dropContents
]

{ #category : #scrolling }
ScrollFrameMorph >> scrollMorphIntoView: aMorph [
	| offset |
	(self bounds containsRect: aMorph fullBounds)
		ifTrue: [ ^ self ].
	(aMorph fullBounds top < self top and: [ aMorph fullBounds top >= contents top ])
		ifTrue: [ 
			offset := aMorph fullBounds top - contents top.
			contents top: self top + 3 - offset ].
	(aMorph fullBounds left < self left and: [ aMorph fullBounds left >= contents left ])
		ifTrue: [ 
			offset := aMorph fullBounds left - contents left.
			contents left: self left + 3 - offset ].
	aMorph fullBounds right > self right
		ifTrue: [ 
			offset := aMorph fullBounds right - contents left.
			contents left: self right - 3 - offset ].
	aMorph fullBounds bottom > self bottom
		ifTrue: [ 
			offset := aMorph fullBounds bottom - contents top.
			contents top: self bottom - 3 - offset ].
	self updateContentsExtent.
	self updateScrollbars
]

{ #category : #scrolling }
ScrollFrameMorph >> scrollSubmorphIntoView: aMorph [

	| offset |
	(contents submorphs includes: aMorph) ifFalse: [^ self].
	(self bounds containsRect: aMorph fullBounds) ifTrue: [^ self].

	(aMorph fullBounds bottom > self bottom) ifTrue: [
		offset := aMorph fullBounds bottom - contents top.
		contents top: (self bottom - 3) - offset].

	(aMorph fullBounds top < self top) ifTrue: [
		offset := aMorph fullBounds top - contents top.
		contents top: (self top + 3) - offset].

	self updateScrollbars.

]

{ #category : #geometry }
ScrollFrameMorph >> scrollbarStartInset: startInset endInset: endInset [

	scrollBarStartInset := startInset.
	scrollBarEndInset := endInset.

]

{ #category : #'scrollbar visibility' }
ScrollFrameMorph >> showHorizontalScrollbar: aBoolean [
	"Show or hide my horizontal scrollbar."

	aBoolean = (hScrollbar owner = self) ifTrue: [^ self].

	aBoolean
		ifTrue: [self addMorph: hScrollbar]
		ifFalse: [hScrollbar delete].

	self extent: self extent.

]

{ #category : #'scrollbar visibility' }
ScrollFrameMorph >> showVerticalScrollbar: aBoolean [
	"Show or hide my vertical scrollbar."

	aBoolean = (vScrollbar owner = self) ifTrue: [^ self].

	aBoolean
		ifTrue: [self addMorph: vScrollbar]
		ifFalse: [vScrollbar delete].

	self extent: self extent.

]

{ #category : #private }
ScrollFrameMorph >> updateContentsExtent [
	"Make sure my content morph is large enough to both enclose all it's submorphs and to fill me. Adjust the scroll offsets if my bounds have shrunk."

	| r delta scrolledOff w h visible |
	r := self contentsBounds.
	((r left < 0) or: [r top < 0]) ifTrue: [
		"contents has morphs that stick out over its top or left edge"
		delta := (r topLeft truncated min: (0@0)) negated.
		contents submorphsDo: [:m | m position: m position + delta]].  "move all submorphs by delta"

	visible := self visibleExtent - (8@20).
	w := visible x. r width > w ifTrue: [w := (r width + (growthFraction * visible x)) rounded].
	h := visible y. r height > h ifTrue: [h := (r height + (growthFraction * visible y))  rounded].

	scrolledOff := ((self topLeft + borderWidth) - contents position) max: 0@0.
	contents extent: ((w@h) max: (self visibleExtent + scrolledOff)).
	contentsChanged := false.

]

{ #category : #private }
ScrollFrameMorph >> updateScrollbars [
	"Update my scrollbars based on my current contents."

	| visibleExtent currentScroll maxScroll |
	contents ifNil: [^ self].  "not fully initialized yet"

	visibleExtent := self visibleExtent.
	hScrollbar percentVisible: (visibleExtent x asFloat / contents width).

	contents height = 0 
		ifTrue: [ self showVerticalScrollbar: false]
		ifFalse: [ vScrollbar percentVisible: (visibleExtent y asFloat / contents height)].

	currentScroll := (self topLeft + borderWidth) - contents position.
	contents width > visibleExtent x
		ifTrue: [
			maxScroll := contents width - visibleExtent x.
			self showHorizontalScrollbar: true.
			hScrollbar
				scrollDelta: 4 / maxScroll asFloat 
				pageDelta: (visibleExtent x - 40) / maxScroll asFloat.
			hScrollbar value: currentScroll x / maxScroll]
		ifFalse: [
			self showHorizontalScrollbar: false.
			hScrollbar value: 0].

	contents height > visibleExtent y
		ifTrue: [
			maxScroll := contents height - visibleExtent y.
			self showVerticalScrollbar: true.
			vScrollbar
				scrollDelta: 4.0 / maxScroll asFloat 
				pageDelta: (visibleExtent y - 40) / maxScroll asFloat.
			vScrollbar value: currentScroll y / maxScroll]
		ifFalse: [
			self showVerticalScrollbar: false.
			vScrollbar value: 0].

]

{ #category : #accessing }
ScrollFrameMorph >> vBarInset: anInteger [

	vbarInset := anInteger.

]

{ #category : #layout }
ScrollFrameMorph >> vResizing [

		^  #spaceFill

]

{ #category : #scrolling }
ScrollFrameMorph >> vScrollPixels [
	"Answer the current vertical scroll offset in pixels."

	^ (self top + borderWidth) - contents top


]

{ #category : #scrolling }
ScrollFrameMorph >> vScrollPixels: vOffset [
	"Scroll to the given vertical offset in pixels. Zero is scrolled to the top and increasing values scroll down."

	| delta maxOffset |
	delta := (vOffset asInteger min: self maxScroll y) max: 0.
	contents top: ((self top + borderWidth) - delta) truncated.

	maxOffset := self maxScroll y.
	maxOffset > 0 ifTrue: [vScrollbar value: self vScrollPixels / maxOffset].

]

{ #category : #scrolling }
ScrollFrameMorph >> vScrollRelative: aFloat [
	"Sent by the vertical scrollbar. Scroll to the given relative postion between 0.0 and 1.0."

	self vScrollPixels: aFloat * self maxScroll y.

]

{ #category : #private }
ScrollFrameMorph >> visibleExtent [
	"Answer the extent of my visible area. That is, the area within my borders minus the space used for scrollbars."

	| clipToScrollBarEdge visibleW visibleH |
	clipToScrollBarEdge := false.
	clipToScrollBarEdge ifFalse: [^ self extent - (2 * borderWidth)].

	visibleW := self width - (2 * borderWidth).
	vScrollbar owner = self ifTrue: [visibleW := visibleW - vbarInset].
	visibleH := self height - (2 * borderWidth).
	hScrollbar owner = self ifTrue: [visibleH := visibleH - hbarInset].
	^ visibleW@visibleH

]
