"
This subclass of ScrollFrameMorph uses ScratchScrollBars.

"
Class {
	#name : #ScrollFrameMorph2,
	#superclass : #ScrollFrameMorph,
	#instVars : [
		'scrollBarStartInset',
		'scrollBarEndInset',
		'dragOffset'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'scrolling by dragging' }
ScrollFrameMorph2 >> dragContentsTo: aPoint [
	|  hDiff vDiff |
	hDiff := aPoint x - contents left - dragOffset x.
	vDiff := aPoint y - contents top - dragOffset y.
	self hScrollPixels: self hScrollPixels - hDiff;
	vScrollPixels: self vScrollPixels - vDiff
]

{ #category : #drawing }
ScrollFrameMorph2 >> drawSubmorphsOn: aCanvas [
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
ScrollFrameMorph2 >> dropContents [
	World activeHand showTemporaryCursor: nil.
	dragOffset := nil
]

{ #category : #geometry }
ScrollFrameMorph2 >> extent: aPoint [
	"After setting my size, position and size my scrollbars and grow box. Also update my contents and scrollbar ranges."

	| inner w h |
	super extent: (aPoint truncated max: self minWidth@self minHeight).

	scrollBarStartInset ifNil: [
		scrollBarStartInset := scrollBarEndInset := 0].  "needed during initialization"

	inner := self innerBounds.

	w := inner width - scrollBarStartInset.
	vScrollbar owner = self
		ifTrue: [w := w - vbarInset]
		ifFalse: [w := w - scrollBarEndInset].
	hScrollbar position: (inner left + scrollBarStartInset)@(inner bottom - hbarInset).
	hScrollbar width: w.

	h := inner height - scrollBarStartInset.
	hScrollbar owner = self
		ifTrue: [h := h - hbarInset]
		ifFalse: [h := h - scrollBarEndInset].
	ScratchTranslator isRTL
		ifTrue: [vScrollbar position: (inner left + 9)@(inner top + scrollBarStartInset)]
		ifFalse: [vScrollbar position: (inner right - vbarInset)@(inner top + scrollBarStartInset)].
	vScrollbar height: h.

	self updateContentsExtent.
	self updateScrollbars.

]

{ #category : #'scrolling by dragging' }
ScrollFrameMorph2 >> grabContentsAt: aPoint [
	self isScrollable ifTrue: [
		World activeHand
			newKeyboardFocus: self;
			showTemporaryCursor: Cursor handClosed asXOCursorForm.
		dragOffset := aPoint - (contents left @ contents top)]

]

{ #category : #'event handling' }
ScrollFrameMorph2 >> handlesMouseDown: evt [
	^ true
]

{ #category : #initialization }
ScrollFrameMorph2 >> initialize [

	super initialize.
	self borderWidth: 0.
	self removeAllMorphs.

	self color: Color blue.
	hbarInset := 30.
	vbarInset := 25.
	scrollBarStartInset := 10.
	scrollBarEndInset := 14.
	contentsChanged := false.

	contents := PasteUpMorph new
		color: (Color gray: 0.9);
		borderWidth: 0;
		enableDragNDrop: true.

	hScrollbar := ScratchScrollBar newHorizontal
		target: self;
		selector: #hScrollRelative:.
	vScrollbar := ScratchScrollBar newVertical
		target: self;
		selector: #vScrollRelative:.

	contents position: self position + borderWidth.
	self addMorph: contents.
	self addMorph: hScrollbar.
	self addMorph: vScrollbar.
	self extent: 160@120.

]

{ #category : #'scrolling by dragging' }
ScrollFrameMorph2 >> isBeingDragged [
	"answer true if the receiver is currently being scrolled by means of dragging"
	^dragOffset notNil
]

{ #category : #'scrolling by dragging' }
ScrollFrameMorph2 >> isScrollable [
	"private - answer true if the receiver is partially hidden and thus can be scrolled"

	^(self findA: ScratchScrollBar) notNil and: [
		(self ownerThatIsA: OffscreenWorldMorph) isNil ]
]

{ #category : #'event handling' }
ScrollFrameMorph2 >> mouseDown: evt [ 
	(owner isKindOf: ScratchFilePicker) ifTrue: [^owner mouseDown: evt].
	evt redButtonPressed ifTrue: [ self grabContentsAt: evt cursorPoint ]
]

{ #category : #'event handling' }
ScrollFrameMorph2 >> mouseMove: evt [ 
	(owner isKindOf: ScratchFilePicker) ifTrue: [^owner mouseMove: evt].
	dragOffset ifNotNil: [self dragContentsTo: evt cursorPoint]
]

{ #category : #'event handling' }
ScrollFrameMorph2 >> mouseUp: evt [
	(owner isKindOf: ScratchFilePicker) ifTrue: [^owner mouseUp: evt].
	self dropContents
]

{ #category : #scrolling }
ScrollFrameMorph2 >> scrollMorphIntoView: aMorph [

	| offset |
	(self bounds containsRect: aMorph fullBounds) ifTrue: [^ self].

	((aMorph fullBounds top < self top) and: [(aMorph fullBounds top < contents top) not]) ifTrue: [
		offset := aMorph fullBounds top - contents top.
		contents top: (self top + 3) - offset].

	((aMorph fullBounds left < self left) and: [(aMorph fullBounds left < contents left) not]) ifTrue: [
		offset := aMorph fullBounds left - contents left.
		contents left: (self left + 3) - offset].

	(aMorph fullBounds right > self right) ifTrue: [
		offset := aMorph fullBounds right - contents left.
		contents left: (self right - 3) - offset].

	(aMorph fullBounds bottom > self bottom) ifTrue: [
		offset := aMorph fullBounds bottom - contents top.
		contents top: (self bottom - 3) - offset].

	self updateContentsExtent.
	self updateScrollbars.

]

{ #category : #geometry }
ScrollFrameMorph2 >> scrollbarStartInset: startInset endInset: endInset [

	scrollBarStartInset := startInset.
	scrollBarEndInset := endInset.

]

{ #category : #'scrollbar visibility' }
ScrollFrameMorph2 >> showHorizontalScrollbar: aBoolean [
	"Show or hide my horizontal scrollbar."

	aBoolean = (hScrollbar owner = self) ifTrue: [^ self].

	aBoolean
		ifTrue: [self addMorph: hScrollbar]
		ifFalse: [hScrollbar delete].

	self extent: self extent.

]

{ #category : #'scrollbar visibility' }
ScrollFrameMorph2 >> showVerticalScrollbar: aBoolean [
	"Show or hide my vertical scrollbar."

	aBoolean = (vScrollbar owner = self) ifTrue: [^ self].

	aBoolean
		ifTrue: [self addMorph: vScrollbar]
		ifFalse: [vScrollbar delete].

	self extent: self extent.

]
