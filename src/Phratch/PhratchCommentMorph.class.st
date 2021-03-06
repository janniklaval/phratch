Class {
	#name : #PhratchCommentMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'labelMorph',
		'commentMorph',
		'showHideMorph',
		'isShowing',
		'isResizing',
		'resizeOffset',
		'connector',
		'anchor',
		'anchorOffset',
		'oldAnchorPos',
		'lastLayoutTime'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'dropping/grabbing' }
PhratchCommentMorph >> aboutToBeGrabbedBy: aHand [
	"The receiver is being grabbed by a hand. Perform necessary adjustments (if any) and return the morph that should be added to the hand. This default implementation just returns the reciver."

	self detach.
	^ self

]

{ #category : #initialization }
PhratchCommentMorph >> addTopBar [

	| topBarMorph |
	topBarMorph := AlignmentMorph newRow
		extent: (160@12);
		vResizing: #rigid;
		color: self topBarColor;
		borderWidth: 0;
		inset: 0;
		cellPositioning: #leftCenter;
		centering: #center;
		yourself.

	labelMorph := StringMorph new
		color: (Color gray: 0.33);
		contents: '';
		font: (PhratchFrameMorph getFont: #Label);
		yourself.

	showHideMorph := ImageMorph new image: (PhratchFrameMorph skinAt: #arrowOpenComment).
	showHideMorph form colors: (Array
		with: self topBarColor;
		with: (self color mixed: 0.5 with: Color black)).

	topBarMorph
		addMorphBack: (Morph new extent: 5@5; color: Color transparent;
		yourself);
		addMorphBack: showHideMorph;
		addMorphBack: (Morph new extent: 3@5; color: Color transparent;
		yourself);
		addMorphBack: labelMorph;
		addMorphBack: (AlignmentMorph newSpacer: Color transparent).

	self addMorphBack: topBarMorph.

]

{ #category : #accessing }
PhratchCommentMorph >> anchor [

	^ anchor

]

{ #category : #accessing }
PhratchCommentMorph >> anchor: aBlock [

	self detach.
	anchor := aBlock.
	aBlock ifNotNil: [
		aBlock topBlock commentLayoutChanged].

]

{ #category : #'dropping/grabbing' }
PhratchCommentMorph >> attachTargetIn: newOwner [
	"Answer a CommandBlockMorph that is overlapped by the receiver, nil if none."

	| candidates target overlap ratio |

	(newOwner isPhratchScriptsMorph) ifFalse: [^ nil].

	candidates := newOwner allMorphs select: [:each |
		(each isBlockMorph) and:
"		[each isReporter not and:"
		[each hasComment not and:
		[self bounds intersects: each bounds]]]"]".

	candidates isEmpty ifTrue: [^ nil].

	target := candidates first.
	ratio := (self bounds intersect: target bounds) area / target bounds area.
	candidates do: [:each |
		overlap := ((self bounds intersect: each bounds) area / (each bounds area)).
		overlap > ratio ifTrue: [
			ratio := overlap.
			target := each]].

	^ target

]

{ #category : #accessing }
PhratchCommentMorph >> commentMorph [

	^ commentMorph

]

{ #category : #accessing }
PhratchCommentMorph >> commentMorphColor [

	^ Color r: 1 g: 1 b: (210/255).

]

{ #category : #private }
PhratchCommentMorph >> commentsAfterMe: blocksInStack [
	"Return a collection of comment morphs in my owner that are attached to blocks after me in the given list of blocks. Assumes anchor is not nil."

	| result allComments |
	owner ifNil: [^ #()].
	allComments := owner submorphs select: [:m |
		m isPhratchCommentMorph].

	result := OrderedCollection new.
	blocksInStack reversed do: [:b |
		b == anchor ifTrue: [^ result asArray].
		allComments do: [:c | c anchor = b ifTrue: [result add: c]]].

	^ result asArray

]

{ #category : #private }
PhratchCommentMorph >> commentsBeforeMe: blocksInStack [
	"Return a collection of comment morphs in my owner that are attached to blocks before me in the given list of blocks. Assumes anchor is not nil."

	| allComments result |
	owner ifNil: [^ #()].
	allComments := owner submorphs select: [:m | m isPhratchCommentMorph].

	result := OrderedCollection new.
	blocksInStack do: [:b |
		b == anchor ifTrue: [^ result asArray].
		allComments do: [:c | c anchor = b ifTrue: [result add: c]]].

	^ result asArray

]

{ #category : #private }
PhratchCommentMorph >> defaultWidth [

	^ 150

]

{ #category : #accessing }
PhratchCommentMorph >> delete [

	self detach.
	PhratchFrameMorph putInClipboard: self.
	super delete

]

{ #category : #private }
PhratchCommentMorph >> detach [

	| oldAnchor |
	oldAnchor := anchor.
	anchor := nil.
	connector ifNotNil: [
		connector delete.
		connector := nil].
	oldAnchor ifNotNil: [
		oldAnchor topBlock commentLayoutChanged].

]

{ #category : #'event handling' }
PhratchCommentMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #initialization }
PhratchCommentMorph >> initialize [

	| bottomBar |
	super initialize.
	anchorOffset := 5.

	self vResizing: #shrinkWrap;
		hResizing: #rigid;
		orientation: #vertical;
		centering: #bottomRight;
		inset: 0;
		borderWidth: 0;
		color: self commentMorphColor;
		useRoundedCorners;
		width: self defaultWidth.
	isShowing := true.

	self addTopBar.

	bottomBar := AlignmentMorph newRow
		color: Color transparent;
		cellPositioning: #leftCenter;
		centering: #center;
		yourself.
	commentMorph := TextMorph new
		color: self commentMorphColor;
		contents: 'add comment here' localized, '...';
		borderWidth: 0;
		font: (PhratchFrameMorph getFont: #CommentBlock);		
		width: self defaultWidth;
		yourself.
	
	bottomBar addMorphBack: commentMorph.

	self addMorphBack: bottomBar.
	isResizing := false.
	resizeOffset := 0@0.

]

{ #category : #testing }
PhratchCommentMorph >> isPhratchCommentMorph [

	^ true
]

{ #category : #accessing }
PhratchCommentMorph >> isShowing [


	^ isShowing

]

{ #category : #'dropping/grabbing' }
PhratchCommentMorph >> justDroppedInto: newOwner event: evt [
	"Handle being dropped into a new situation."

	| frame target |
	(frame := newOwner ownerOrYourselfThatIsAPhratchFrameMorph)
		ifNotNil: [frame projectModified].

	((self ownerOrYourselfThatIsAPhratchViewerMorph) notNil) ifTrue: [
		"delete myself when dropped in the blocks palette area"
		self delete.
		^ self].

	"comments cannot be dropped onto the stage"
	(owner isPhratchStageMorph) ifTrue: [
		^ evt hand rejectDropMorph: self event: evt].

	"okay to drop comments into the world during development"
	((owner == World) and: [ScriptablePhratchMorph noviceMode not]) ifTrue: [^ self].

	(owner isPhratchScriptsMorph) ifFalse: [
		^ evt hand rejectDropMorph: self event: evt].

	target := self attachTargetIn: newOwner.
	target ifNotNil: [self anchor: target]

]

{ #category : #private }
PhratchCommentMorph >> labelWhenClosed [
	"Answer the label string to used when the comment is closed."

	| maxW firstLine ellipses s w |
	maxW := (self width - 40)/3.
	firstLine := commentMorph text string lineNumber: 1.
	"self halt."
	(labelMorph stringWidth: firstLine) < maxW ifTrue: [^ firstLine].
	ellipses := '...'.

	1 to: firstLine size do: [:i |
		s := firstLine copyFrom: 1 to: i.
		w := labelMorph stringWidth: s, ellipses.
		w > maxW ifTrue: [
			^ (firstLine copyFrom: 1 to: i - 1), ellipses]].

	^ firstLine
]

{ #category : #private }
PhratchCommentMorph >> layoutChanged [

	super layoutChanged.
	anchor ifNotNil: [anchor topBlock commentLayoutChanged].

]

{ #category : #'event handling' }
PhratchCommentMorph >> mouseDown: evt [
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	| p |
	World activeHand showTemporaryCursor: nil.
	evt hand newKeyboardFocus: nil.
	isResizing := false.
	p := evt cursorPoint.

	((showHideMorph bounds expandBy: 4) containsPoint: p) ifTrue: [^ self toggleShowing].
	(isShowing and: [commentMorph containsPoint: p])
		ifTrue: [^ commentMorph mouseDown: evt].

	evt rightButtonPressed
		ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu]
		ifFalse:	[((commentMorph topRight corner: commentMorph bottomRight + (10@0)) containsPoint: p)
			ifFalse: [evt hand grabMorph: self]
			ifTrue: [isResizing := true.
				resizeOffset := self bottomRight - p]].

]

{ #category : #'event handling' }
PhratchCommentMorph >> mouseMove: evt [
	| p |
	evt hand newKeyboardFocus: nil.
	p := evt cursorPoint.
	isResizing
		ifFalse: [ ^ self ].
	self width: (self defaultWidth max: (p - self topLeft + resizeOffset) x).
	commentMorph width: self width
]

{ #category : #private }
PhratchCommentMorph >> refreshConnector [

	| y |
	owner ifNil: [^ self].

	connector ifNil: [
		connector := PhratchConnectorMorph new color: self topBarColor].

	connector owner isNil ifTrue: [
		owner addMorph: connector.
		connector goBehind].

	y := self top + 7.
	connector
		from: (anchor right - 1) @ y
		to: self left @ y


]

{ #category : #'dropping/grabbing' }
PhratchCommentMorph >> rejectDropEvent: evt [
	"Reject being dropped by the given event."

	evt hand rejectDropMorph: self event: evt.

]

{ #category : #private }
PhratchCommentMorph >> resetAnchorOffset [
	
	anchorOffset := 5.
	self updatePosition.

]

{ #category : #'event handling' }
PhratchCommentMorph >> rightButtonMenu [
	| menu |
	menu := MenuMorph new defaultTarget: self.
	menu addLine.
	menu add: 'delete' localized selector: #delete.
	menu
		localize;
		invokeModal
]

{ #category : #'dropping/grabbing' }
PhratchCommentMorph >> rootForGrabOf: aMorph [
	"Allow myself to be extracted."

	(owner notNil and: [owner isPartsBin])
		ifTrue: [^ super rootForGrabOf: aMorph]
		ifFalse: [^ self].

]

{ #category : #'dropping/grabbing' }
PhratchCommentMorph >> slideBackToFormerSituation: evt [

	| wasEmbedded o pane oldP slideForm startPoint s |
	wasEmbedded := false.
	(o := evt hand formerOwner) ifNil: [^ self].
	(o isBlockMorph) ifTrue: [
		wasEmbedded := true.
		(pane := o ownerOrYourselfThatIsAPhratchScriptsMorph) ifNotNil: [
			o := pane]].

	"restore the old position relative to the old owner,
	in case the old owner has been scrolled or moved in the meantime"
	oldP := (self formerPosition ifNil: [0@0]) + o position.

	slideForm := self imageForm offset: 0@0.
	startPoint := evt hand fullBounds origin.
	owner privateRemoveMorph: self.
	self world displayWorld.
	slideForm slideFrom: startPoint to: oldP nSteps: 12 delay: 15.
	self position: oldP.
	o addMorph: self.
	wasEmbedded ifTrue: [self justDroppedInto: o event: evt].

	"scroll the dropped morph into view in case the owner has been
	scrolled in the meantime"
	s := o ownerOrYourselfThatIsAScrollFrameMorph.
	s ifNotNil: [s scrollMorphIntoView: self ]

]

{ #category : #stepping }
PhratchCommentMorph >> step [
	"Follow the anchor block"

	| t |
	anchor ifNil: [ ^ self ].
	anchor isInWorld
		ifFalse: [ ^ self detach ].	"anchor block was deleted"	"check for layout change and fix offset if needed"
	(t := anchor topBlock lastLayoutTime) = lastLayoutTime
		ifFalse: [ 
			self updateAnchorOffset.
			oldAnchorPos := nil.	"force position update"
			lastLayoutTime := t ].
	anchor position ~= oldAnchorPos
		ifFalse: [ ^ self ].
	self updatePosition.
	oldAnchorPos := anchor position
]

{ #category : #stepping }
PhratchCommentMorph >> stepTime [

	^ 0

]

{ #category : #private }
PhratchCommentMorph >> toggleShowing [

	| colors |
	isShowing := isShowing not.
	colors := showHideMorph form colors.
	isShowing
		ifTrue: [
			showHideMorph form: (PhratchFrameMorph skinAt: #arrowOpenComment).
			showHideMorph form colors: colors.
			(self submorphs at: 2) addMorphBack: commentMorph.
			commentMorph startStepping.
			labelMorph contents: ''.
			self comeToFront.
			self color: self commentMorphColor]
		ifFalse: [
			showHideMorph form: (PhratchFrameMorph skinAt: #arrowClosedComment).
			showHideMorph form colors: colors.
			commentMorph delete.
			labelMorph contents: self labelWhenClosed.
			self color: self topBarColor].

	anchor ifNotNil: [anchor topBlock commentLayoutChanged].


]

{ #category : #private }
PhratchCommentMorph >> topBarColor [

	^ Color r: 1 g: 1 b: (165/255)

]

{ #category : #private }
PhratchCommentMorph >> updateAnchorOffset [
	"Update the horizontal offset from my anchor block."

	| extraSpace blocksInStack rects allObstacles touching before after collapsed |
	anchor ifNil: [ ^ self ].
	self resetAnchorOffset.
	isShowing
		ifFalse: [ ^ self ].
	extraSpace := 5.
	blocksInStack := anchor topBlock allMorphs reversed select: [ :m | (m isBlockMorph) and: [ m isReporter not ] ].
	before := self commentsBeforeMe: blocksInStack.
	after := self commentsAfterMe: blocksInStack.
	collapsed := after reject: [ :c | c isShowing ].
	before , collapsed do: [ :c | c resetAnchorOffset ].
	before do: [ :c | c updateAnchorOffset ].
	allObstacles := blocksInStack , before , collapsed.
	rects := allObstacles
		collect: [ :m | 
			(m isBlockMorph)
				ifTrue: [ m bounds origin extent: m bounds extent - (0 @ 4) ]
				ifFalse: [ m bounds ] ].
	[ 
	touching := rects detect: [ :r | r intersects: self bounds ] ifNone: [ nil ].
	touching isNil ]
		whileFalse: [ 
			 self left: (self left max: touching right + extraSpace) ].
	anchorOffset :=  self left - anchor right.
	self updatePosition
]

{ #category : #private }
PhratchCommentMorph >> updatePosition [

	| vOffset |
	anchor ifNil: [^ self].

	vOffset := (anchor isHatBlockMorph) ifTrue: [19] ifFalse: [3].
	self position: (anchor right + anchorOffset) @ (anchor top + vOffset).

	self refreshConnector.
	oldAnchorPos := anchor position.

]

{ #category : #accessing }
PhratchCommentMorph >> width: aNumber [

	super width: (self defaultWidth max: aNumber).
	commentMorph notNil ifTrue: [
		commentMorph width: self width].

]
