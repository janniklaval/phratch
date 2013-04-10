Extension { #name : #HandMorph }

{ #category : #'*Phratch-Extensions' }
HandMorph >> clearUnclaimedKeystrokes [

	self unclaimedKeystrokes: OrderedCollection new.
]

{ #category : #'*Phratch-Extensions' }
HandMorph >> firstClickEvent [

	^ nil
]

{ #category : #'*Phratch-Extensions' }
HandMorph >> gridPointRaw [
	"Private! Returns the nearest grid point to the cursor to be used as the coordinate for the current event. Do not include a cursor offset."
	
	^ Sensor lastMousePosition
"
	grid
		ifNil: [^ Sensor cursorPoint]
		ifNotNil: [^ self griddedPoint: Sensor cursorPoint].
"
]

{ #category : #'*Phratch-Extensions' }
HandMorph >> gridTo: gridSpacingPoint origin: originPoint [
	"Turn on gridding. This causes the hand an any morphs carried by it to be aligned to a grid point. Both the grid spacing and the grid offset (starting point) can be set. For example, in a painting tool, it may be useful to make the origin be the top-left corner of the paint window. This grids to exact multiples of the grid spacing relative to the paint window's origin, even if that window is not positioned on a grid point relative the origin of the Display."
"
	grid := gridSpacingPoint.
	gridOffset := originPoint \\ gridSpacingPoint.
"
]

{ #category : #'*Phratch-Extensions' }
HandMorph >> hasMouseFocus: aMorph [

	^ mouseFocus  == aMorph
]

{ #category : #'*Phratch-Extensions' }
HandMorph >> nextUnclaimedKeystrokeOrNil [
	"Answer the next unclaimed keystroke from the buffer or nil if there isn't one."

	(self unclaimedKeystrokes isNil or: [self unclaimedKeystrokes size = 0])
		ifTrue: [^ nil]
		ifFalse: [^ self unclaimedKeystrokes removeFirst]

]

{ #category : #'*Phratch-Extensions' }
HandMorph >> recordUnclaimedKeystroke: evt [

	self unclaimedKeystrokes ifNil: [self unclaimedKeystrokes: OrderedCollection new].
	self unclaimedKeystrokes addLast: evt.
	[self unclaimedKeystrokes size > 10] 
		whileTrue: [self unclaimedKeystrokes removeFirst].  "keep only most recent N keystrokes"

]

{ #category : #'*Phratch-Extensions' }
HandMorph >> rejectDropMorph: aMorph event: evt [
	"aMorph has been rejected, and must be put back somewhere.  There are three cases:
	(1)  It remembers its former owner and position, and goes right back there
	(2)  It remembers its former position only, in which case it was torn off from a parts bin, and the UI is that it floats back to its donor position and then vanishes.
	(3)  Neither former owner nor position is remembered, in which case it is just deleted"

	(aMorph formerOwner notNil and: [aMorph formerOwner isPartsBin not]) ifTrue:
		[^ aMorph slideBackToFormerSituation: evt].

	aMorph formerPosition ifNotNil:  "Position but no owner -- can just make it vanish"
		[^ aMorph vanishAfterSlidingTo: aMorph formerPosition event: evt].
		
	aMorph delete.

]

{ #category : #'*Phratch-Extensions' }
HandMorph >> toolType [

	^ self valueOfProperty: #ScratchToolType
]

{ #category : #'*Phratch-Extensions' }
HandMorph >> toolType: aStringOrNil [

	self setProperty: #ScratchToolType toValue: aStringOrNil.
	aStringOrNil ifNil: [self showTemporaryCursor: nil].
]

{ #category : #'*Phratch-Extensions' }
HandMorph class >> translucentWhenDragging [

	^ (World activeHand valueOfProperty: #translucentWhenDragging) ifNil: [false]
]

{ #category : #'*Phratch-Extensions' }
HandMorph class >> translucentWhenDragging: aBoolean [

	World activeHand setProperty: #translucentWhenDragging toValue: aBoolean
]

{ #category : #'*Phratch-Extensions' }
HandMorph >> turnOffGridding [
	"Turn off gridding."

"	grid :=  nil."
]

{ #category : #'*Phratch-Extensions' }
HandMorph >> unclaimedKeystrokes [

	^ self valueOfProperty: #unclaimedKeystrokes
]

{ #category : #'*Phratch-Extensions' }
HandMorph >> unclaimedKeystrokes: aCollection [

	^ self setProperty: #unclaimedKeystrokes toValue: aCollection
]
