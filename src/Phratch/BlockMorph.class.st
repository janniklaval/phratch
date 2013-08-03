"
I and my subclasses represent statements in a block-based graphical programming language.

"
Class {
	#name : #BlockMorph,
	#superclass : #Morph,
	#instVars : [
		'isSpecialForm',
		'oldColor',
		'highlightColor1',
		'highlightColor2',
		'shadowColor',
		'hadError',
		'blockLayoutNeeded',
		'cachedForm',
		'cachedFeedbackForm',
		'copyTooltip',
		'lastLayoutTime',
		'originalColor',
		'isContrasted',
		'phratchProc'
	],
	#classVars : [
		'ArgFont',
		'CBlockBracketThickness',
		'Contrast',
		'DebugMenu',
		'LabelColor',
		'LabelFont',
		'PuzzleInset',
		'PuzzleWidth'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #'class initialization' }
BlockMorph class >> contrast [
	^ Contrast
]

{ #category : #'class initialization' }
BlockMorph class >> contrastNormal [
	Contrast := #normal.
	BlockMorph allInstancesDo: [:b | b changed ].
]

{ #category : #'class initialization' }
BlockMorph class >> contrastOff [
	Contrast := #off.
	BlockMorph allInstancesDo: [:b | b changed ].
]

{ #category : #'class initialization' }
BlockMorph class >> contrastSlight [
	Contrast := #slight.
	BlockMorph allInstancesDo: [:b | b changed ].
]

{ #category : #'class initialization' }
BlockMorph class >> contrastStrong [
	Contrast := #strong.
	ReporterBlockMorph allInstancesDo: [:b | b changed ].
]

{ #category : #'class initialization' }
BlockMorph class >> initialize [
	"self initialize"

	LabelColor := Color white.
	PuzzleInset := 11.
	PuzzleWidth := 14.
	CBlockBracketThickness := 12.
	DebugMenu := true.
]

{ #category : #'class initialization' }
BlockMorph class >> setLabelFont [
	"BlockMorph setLabelFont"

	| menu |
	menu := MenuMorph new defaultTarget: self.
	StrikeFont fontNames do: [:fn | 
		menu add: fn 
			target: self  
			selector: #setLabelSize:
			argument: fn.
		menu add: fn action: fn].
	menu addLine.
	menu add: 'normal' 
		target: self  
		selector: #setLabelSize:
		argument: #normal.
	menu popUpInWorld.
]

{ #category : #'class initialization' }
BlockMorph class >> setLabelSize: aSelectedFontLabel [
	"BlockMorph setLabelFont"

	| menu |
	
		menu := MenuMorph new defaultTarget: self.
		(StrikeFont sizesForFontName: aSelectedFontLabel) do: [:sz | 
			menu add: sz printString 
				target: self  
				selector: #setfont:size:
				argumentList: (Array with: aSelectedFontLabel with: sz)
		].
	menu popUpInWorld.

]

{ #category : #'class initialization' }
BlockMorph class >> setfont:fName size: fSize [

	LabelFont := StrikeFont fontName: fName size: fSize.
]

{ #category : #'dropping/grabbing' }
BlockMorph >> aboutToBeGrabbedBy: aHandMorph [
	"If I'm being used as an argument, replace myself with an appropriate argument morph. Copied from WatcherMorph."

	| m |
	(owner isKindOf: CommandBlockMorph) 
	| (owner isKindOf: WhenHatBlockMorph)
	| (owner isKindOf: MultiArgMorph) ifTrue: [
		"if I was being used as argument, replace myself with a generic argument morph"
		m := owner argMorphToReplace: self. 
		m ifNotNil: [owner replaceArgMorph: self by: m]].

]

{ #category : #accessing }
BlockMorph >> acceptsDroppedReporters [

	^ true

]

{ #category : #accessing }
BlockMorph >> acceptsTypeOf: aBlockMorph [
	"Answer true if I can accept a dropped reporter of the given type. Answer false by default."

	^ false

]

{ #category : #byob }
BlockMorph >> addAreasOf: outerRect outside: innerRect color: col to: coll [

	coll addAll: (((outerRect areasOutside: innerRect) 
		collect: [:r | Array with: r with: col])
		reject: [:pair | ((pair first intersects: innerRect) 
					and: [(pair first right > innerRect left) 
					and: [(pair first left > innerRect left)
					and: [pair first top < innerRect bottom]]])
					or: [pair first left > innerRect right]])
]

{ #category : #accessing }
BlockMorph >> addCopyTooltip: aMorph [

	copyTooltip := aMorph.
	self addMorph: copyTooltip.

]

{ #category : #byob }
BlockMorph >> addHLineFrom: startX to: endX y: yOffset color: c to: coll [

	| y |
	y := self top + yOffset.
	coll add: (Array
				with: ((self left + startX)@y corner: (self left + endX)@(y + 1))
				with: c)
]

{ #category : #byob }
BlockMorph >> addPoint: aPoint color: c to: coll [

	coll add: (Array 
				with: (self topLeft + aPoint extent: 1)
				with: c)

]

{ #category : #private }
BlockMorph >> attachBlock: aBlockMorph [
	"Attach the given block to me. Assume the block has been positioned correctly."

	self addMorph: aBlockMorph.

]

{ #category : #private }
BlockMorph >> blockAttachPoints: aSet [
	"Answer a collection of possible attachment points for me. Each entry is an Association mapping a point to the morph to which a dropping command block could be attached."

	| nextB result |
	result := #().
	(self isKindOf: HatBlockMorph)
		ifFalse: [ 
			result := PhratchTranslator isRTL
				ifTrue: [ result copyWith: self topRight -> self ]
				ifFalse: [ result copyWith: self topLeft -> self ] ].
	nextB := self nextBlock.
	nextB
		ifNil: [ 
			self isStopOrForever
				ifFalse: [ 
					result := PhratchTranslator isRTL
						ifTrue: [ result copyWith: self bottomRight -> self ]
						ifFalse: [ result copyWith: self bottomLeft -> self ] ] ].
	nextB ifNotNil: [ nextB blockAttachPoints: aSet ].
	aSet addAll: result
]

{ #category : #accessing }
BlockMorph >> blockID [
	"answer a temporary (!) id for the receiver
	which can be used for tuple conversion of
	sticky comments"

	| sm |
	sm := self ownerOrYourselfThatIsA: PhratchScriptsMorph.
	sm ifNil: [^ nil].
	^ (sm allMorphs select: [:m |
		m isKindOf: BlockMorph]) indexOf: self

]

{ #category : #'block enumerating' }
BlockMorph >> blockSequence [
	"Answer the sequence of blocks starting with myself. Each block is a submorph of the previous block."

	| result this |
	result := OrderedCollection new: 20.
	this := self.
	[this isNil] whileFalse: [
		result addLast: this.
		this := this nextBlock].
	^ result asArray

]

{ #category : #'block enumerating' }
BlockMorph >> bottomBlock [
	"Answer the bottom Block of this stack. The top block may be a CommandBlockMorph, or perhaps some other kind of BlockMorph."

	| m |
	m := self.
	[m nextBlock isKindOf: BlockMorph] whileTrue: [m := m nextBlock].
	^ m

]

{ #category : #accessing }
BlockMorph >> canBecomeWatcher [
	"Answer true if this block can become a watcher when dropped onto the stage. False by default."

	^ false

]

{ #category : #'drawing-optimization' }
BlockMorph >> changed [
	"Don't flush my cachedForm when I do 'self changed'."

	owner ifNotNil: [owner invalidRect: (self fullBounds expandBy: 3)].
]

{ #category : #processes }
BlockMorph >> clearProcess [
	"Called on the top block of a running stack when all processes are stopped."

	phratchProc ifNotNil: [self phratchProc: nil].

]

{ #category : #'event handling' }
BlockMorph >> click: evt [
	"If a tool is selected, handle a click with that tool. Otherwise, toggle my process."

	evt hand toolType ifNotNil: [
		"handle mouse clicks when the mouse is in different modes"
		^ self handleTool: evt hand toolType hand: evt hand].

	self topBlock toggleProcess.

]

{ #category : #accessing }
BlockMorph >> closestAttachTargetIn: newOwner [
	"Answer the closest block attachment point among the blocks and stack submorphs of the given morph. Answer nil if there are no blocks close enough to attach myself to."

	| xThresh yThresh attachPoints best bestDist targetP dist ref topUsed bottomUsed |
	xThresh := 65.
	yThresh := ((self isKindOf: CBlockMorph) and: [ (self nestedBlockAt: self top + self topBarHeight) isNil ])
		ifTrue: [ 25 ]
		ifFalse: [ 14 ].
	topUsed := false.
	bottomUsed := false.
	attachPoints := OrderedCollection new: 100.
	(newOwner allMorphs reject: [ :m | m == newOwner ])
		do: [ :m | 
			(m ~~ self
				and: [ 
					m ~~ self bottomBlock
						and: [ 
							m ~~ self topBlock
								and: [ m ~~ self owner and: [ (m isKindOf: BlockMorph) and: [ m isReporter not | (m isKindOf: CommandScriptBlockMorph) ] ] ] ] ])
				ifTrue: [ m blockAttachPoints: attachPoints ] ].
	((self isKindOf: HatBlockMorph) or: [ (self ownerOrYourselfThatIsA: HatBlockMorph) ~= nil ])
		ifTrue: [ 
			"if I am a HatBlock or the bottom block of a HatBlock stack, I can only attach to the top block of a stack"
			attachPoints := attachPoints select: [ :assoc | assoc value owner = newOwner and: [ assoc key y = assoc value top ] ] ].
	(self isStop or: [ self bottomBlock isStop ])
		ifTrue: [ 
			"I am a stop block; I can't attach to the top of a stack"
			attachPoints := attachPoints select: [ :assoc | assoc key y ~= assoc value top ] ].
	(self topBlock isForever not and: [ self bottomBlock isForever ])
		ifTrue: [ 
			"My bottom block is a forever; I can't attach to the top of a stack"
			attachPoints := attachPoints select: [ :assoc | assoc key y ~= assoc value top ] ].
	best := nil.
	bestDist := 10000.
	attachPoints
		do: [ :assoc | 
			targetP := assoc key.
			ref := PhratchTranslator isRTL
				ifTrue: [ self right ]
				ifFalse: [ self left ].
			(ref - targetP x) abs < xThresh
				ifTrue: [ 
					((self top - targetP y) abs < yThresh or: [ self nextBlock isNil and: [ (self bottom - targetP y) abs < yThresh ] ])
						ifTrue: [ 
							"targetP is within sticking range"
							dist := PhratchTranslator isRTL
								ifTrue: [ (self topRight - targetP) r ]
								ifFalse: [ (self position - targetP) r ].
							dist < bestDist
								ifTrue: [ 
									(self top - targetP y) abs < yThresh
										ifTrue: [ 
											topUsed := true.
											bottomUsed := false ].
									(self nextBlock isNil and: [ (self bottom - targetP y) abs < yThresh ])
										ifTrue: [ 
											topUsed := false.
											bottomUsed := true ].
									best := assoc.
									bestDist := dist ] ] ] ].	"special case for the auto-wrapping of c-shaped/if-else blocks"
	(self isKindOf: CBlockMorph)
		ifTrue: [ 
			best
				ifNotNil: [ 
					bottomUsed
						ifTrue: [ 
							(best value owner isKindOf: BlockMorph)
								ifTrue: [ 
									self stretchHeight: 0.
									^  nil ] ].
					(self isStopOrForever or: [ self bottomBlock isStopOrForever ])
						ifTrue: [ 
							bottomUsed
								ifTrue: [ 
									self stretchHeight: 0.
									^  nil ] ].
					(best key y = best value top
						and: [ (self isForever or: [ self bottomBlock isForever ]) and: [ (self nestedBlockAt: best key y) isNil not ] ])
						ifTrue: [ 
							self stretchHeight: 0.
							^  nil ].
					(self nestedBlockAt: best key y)
						ifNil: [ 
							bottomUsed
								ifTrue: [ 
									self stretchHeight: 0.
									best key y = best value bottom
										ifTrue: [ ^  nil ].
									(best key y = best value top and: [ best value owner isKindOf: BlockMorph ])
										ifTrue: [ ^ nil ].
									(best key y = best value bottom and: [ (best value owner isKindOf: BlockMorph) not ])
										ifTrue: [ ^ nil ] ].
							topUsed
								ifTrue: [ 
									(best key y = best value bottom and: [ best value nextBlock isNil not ])
										ifTrue: [ 
											self stretchHeight: 0.
											^  nil ].	"((best key y = best value top) and: [(best value owner isKindOf: BlockMorph)]) ifTrue: [self stretchHeight: 0. ^ best := nil]."
									best key y = best value top
										ifTrue: [ 
											self stretchHeight: best value fullBounds height - 17.
											^ best ] ].
							self stretchHeight: 0 ] ].
			best ifNil: [ self stretchHeight: 0 ] ].
	^ best
]

{ #category : #accessing }
BlockMorph >> codeString [
	"Answer a human-readable string representing the code for this block sequence."

	| s |
	s := WriteStream on: (String new: 5000).
	self printCodeOn: s indent: 0.
	^ s contents


]

{ #category : #accessing }
BlockMorph >> color: aColor [
	"Remember the color of this block, for lighting-up purposes."

	super color: aColor.
	oldColor := aColor.
]

{ #category : #private }
BlockMorph >> commentLayoutChanged [

	lastLayoutTime := Time millisecondClockValue.


]

{ #category : #accessing }
BlockMorph >> commentMorph [
	"answer a comment which has been sticked to the receiver, if any"

	| sm |
	sm := self ownerOrYourselfThatIsA: PhratchScriptsMorph.
	sm ifNil: [^ nil].
	^ sm submorphs detect: [: m |
		(m isKindOf: PhratchCommentMorph) and: [
			m anchor == self]] ifNone: [nil].

]

{ #category : #drawing }
BlockMorph >> computeHighlightColors [

	| h s v |
	h := color hue.
	s := color saturation.
	v := color brightness.
	highlightColor1 := Color h: h s: (s - 0.13) v: (v + 0.1).
	highlightColor2 := Color h: h s: s v: (v + 0.07).
	shadowColor := color mixed: 0.7 with: Color black. 

]

{ #category : #byob }
BlockMorph >> contrastColor [
	| ob |
	isContrasted := false.
	originalColor ifNotNil: [ color := originalColor ].
	Contrast = #off
		ifTrue: [ 
			self isDeletedAttribute
				ifFalse: [ ^ self ] ].
	self isDeletedAttribute
		ifTrue: [ ^ color := color twiceLighter ]
		ifFalse: [ 
			ob := self outerLoop.
			ob
				ifNil: [ 
					self isReporter
						ifTrue: [ 
							ob := (owner isKindOf: MultiArgMorph)
								ifTrue: [ owner owner ]
								ifFalse: [ owner ] ]
						ifFalse: [ 
							((owner isKindOf: ProcedureHatBlockMorph) and: [ owner nextBlock ~= self ])
								ifTrue: [ ob := owner ] ] ] ].
	ob ifNil: [ ^ self ].
	ob color = color
		ifTrue: [ 
			originalColor := color.
			#slight = Contrast
				ifTrue: [ ^ color := color slightlyLighter ].
			#normal = Contrast
				ifTrue: [ ^ color := color lighter ].
			#strong = Contrast
				ifTrue: [ 
					isContrasted := true.
					color := color twiceLighter	" lighter slightlyLighter " ] ].
	submorphs
		do: [ :m | 
			(m isKindOf: StringMorph)
				ifTrue: [ m color: self labelColor ]
				ifFalse: [ 
					(m isKindOf: MultiArgMorph)
						ifTrue: [ m contrastColor ] ] ]
]

{ #category : #copying }
BlockMorph >> copyReceiver: aReceiver [

	self allMorphsDo: [:each | (each isKindOf: CommandBlockMorph)  ifTrue:[each receiver: aReceiver ]  ]  
]

{ #category : #private }
BlockMorph >> copyRecordingIn: aDict [

		^ (super copyRecordingIn: aDict) clearProcess.
	
]

{ #category : #'event handling' }
BlockMorph >> delete [
	self topBlock stop.
	PhratchFrameMorph putInClipboard: self.
	super delete

]

{ #category : #byob }
BlockMorph >> disinheritAttribute [

	| sel rcv oi |
	(self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph)
		ifNil: [^ false].
	(self respondsTo: #selector) ifFalse: [
		^ false].
	sel := self selector.
	(self respondsTo: #receiver) ifFalse: [
		^ false].
	rcv := self receiver.
	(rcv isKindOf: ScriptablePhratchMorph) 
		ifFalse: [^ false].
	oi := rcv objectInterface.
	oi keysDo: [:att |
		(oi at: att) second = sel ifTrue: [
			^ rcv undeleteAttribute: att]].
	^ false
]

{ #category : #'event handling' }
BlockMorph >> doubleClick: evt [
	"If I'm a block with a receiver that's in a Phratch window, execute me."

	self topBlock toggleProcess.

]

{ #category : #drawing }
BlockMorph >> drawBodyOn: aCanvas [ 

	aCanvas
		fillRectangle: (self left@(self top + 5) corner: (self right - 1)@(self bottom - 7))
		color: color.
	aCanvas
		fillRectangle: (self left@(self top + 2) corner: (self left + 2)@(self bottom - 7))
		color: highlightColor2.

	aCanvas
		fillRectangle: ((self right - 1)@(self top + 3) corner: self right@(self bottom - 7))
		color: shadowColor.

]

{ #category : #drawing }
BlockMorph >> drawBottomEdgeOn: aCanvas [

	| right y gapStart gapEnd |
	right := self width - 1.
	y := self height - 7.
	gapStart := PuzzleInset.
	gapEnd := PuzzleInset + PuzzleWidth.

	self drawHLineFrom: 1 to: right - 1 y: y color: color on: aCanvas.
	self drawHLineFrom: 2 to: right - 2 y: y + 1 color: color on: aCanvas.

	self drawHLineFrom: gapStart to: gapEnd y: y + 2 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 1 to: gapEnd - 1 y: y + 3 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 1 to: gapEnd - 1 y: y + 4 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 2 to: gapEnd - 2 y: y + 5 color: color on: aCanvas.

	self drawHLineFrom: 3 to: gapStart y: y + 2 color: shadowColor on: aCanvas.
	self drawHLineFrom: gapEnd to: right - 2 y: y + 2 color: shadowColor on: aCanvas.
	self drawHLineFrom: gapStart + 2 to: gapEnd - 2 y: y + 6 color: shadowColor on: aCanvas.

	self drawPoint: gapStart@(y + 3) color: shadowColor on: aCanvas.
	self drawPoint: gapStart@(y + 4) color: shadowColor on: aCanvas.
	self drawPoint: (gapStart + 1)@(y + 5) color: shadowColor on: aCanvas.

	self drawPoint: (gapEnd - 1)@(y + 3) color: shadowColor on: aCanvas.
	self drawPoint: (gapEnd - 1)@(y + 4) color: shadowColor on: aCanvas.
	self drawPoint: (gapEnd - 2)@(y + 5) color: shadowColor on: aCanvas.

	self drawPoint: (right - 1)@y color: shadowColor on: aCanvas.
	self drawPoint: (right - 2)@(y + 1) color: shadowColor on: aCanvas.

]

{ #category : #drawing }
BlockMorph >> drawFinalOn: aCanvas fromCanvas: c [

	| flipped |
	
	PhratchTranslator isRTL 
		ifTrue: [flipped := c form flipBy: #horizontal centerAt: c form center.
			aCanvas paintImage: flipped at: self topLeft]
		ifFalse:[aCanvas paintImage: c form at: self topLeft].

]

{ #category : #drawing }
BlockMorph >> drawHLineFrom: startX to: endX y: yOffset color: c on: aCanvas [

	| y |
	y := self top + yOffset.
	aCanvas
		fillRectangle: ((self left + startX)@y corner: (self left + endX)@(y + 1))
		color: c.

]

{ #category : #byob }
BlockMorph >> drawInlinePaletteOn: aCanvas [
	^self
]

{ #category : #drawing }
BlockMorph >> drawOn: aCanvas [ 

	| c |

	self contrastColor.

	self computeHighlightColors.
	c := FormCanvas extent: self extent depth: 32.
	c := c copyOffset: self topLeft negated.
	self isReporter ifTrue: [
		self drawSmoothTopEdgeOn: c.
		self drawReporterBodyOn: c.
		self drawSmoothBottomEdgeOn: c.
		^ self].

	self isStop ifTrue: [
		self drawTopEdgeOn: c.
		self drawStopBodyOn: c.
		self drawSmoothBottomEdgeOn: c.
		self drawFinalOn: aCanvas fromCanvas: c.
		^ self].

	self drawTopEdgeOn: c.
	self drawBodyOn: c.
	self drawBottomEdgeOn: c.

	self drawFinalOn: aCanvas fromCanvas: c.

	self drawInlinePaletteOn: aCanvas.

]

{ #category : #drawing }
BlockMorph >> drawPoint: aPoint color: c on: aCanvas [

	aCanvas fillRectangle: (self topLeft + aPoint extent: 1) color: c.

]

{ #category : #drawing }
BlockMorph >> drawReporterBodyOn: aCanvas [ 

	aCanvas
		fillRectangle: (self left@(self top + 3) corner: (self right - 1)@(self bottom - 3))
		color: color.
	aCanvas
		fillRectangle: (self left@(self top + 2) corner: (self left + 2)@(self bottom - 3))
		color: highlightColor2.

	aCanvas
		fillRectangle: ((self right - 1)@(self top + 2) corner: self right@(self bottom - 3))
		color: shadowColor.

]

{ #category : #drawing }
BlockMorph >> drawSmoothBottomEdgeOn: aCanvas [

	| right y |
	right := self width - 1.
	y := self height - 3.

	self drawHLineFrom: 1 to: right - 1 y: y color: color on: aCanvas.
	self drawHLineFrom: 2 to: right - 2 y: y + 1 color: color on: aCanvas.
	self drawHLineFrom: 3 to: right - 2 y: y + 2 color: shadowColor on: aCanvas.

	self drawPoint: (right - 1)@y color: shadowColor on: aCanvas.
	self drawPoint: (right - 2)@(y + 1) color: shadowColor on: aCanvas.

]

{ #category : #drawing }
BlockMorph >> drawSmoothTopEdgeOn: aCanvas [

	| right |
	right := self width - 1.

	self drawHLineFrom: 2 to: right - 2 y: 0 color: highlightColor1 on: aCanvas.
	self drawHLineFrom: 1 to: right - 1 y: 1 color: highlightColor2 on: aCanvas.
	self drawHLineFrom: 0 to: right y: 2 color: color on: aCanvas.

]

{ #category : #drawing }
BlockMorph >> drawStopBodyOn: aCanvas [ 

	aCanvas
		fillRectangle: (self left@(self top + 5) corner: (self right - 1)@(self bottom - 3))
		color: color.

	aCanvas
		fillRectangle: (self left@(self top + 2) corner: (self left + 2)@(self bottom - 3))
		color: highlightColor2.

	aCanvas
		fillRectangle: ((self right - 1)@(self top + 2) corner: self right@(self bottom - 3))
		color: shadowColor.

]

{ #category : #drawing }
BlockMorph >> drawTopEdgeOn: aCanvas [

	| right gapStart gapEnd |
	right := self width - 1.
	gapStart := PuzzleInset.
	gapEnd := PuzzleInset + PuzzleWidth.

	self drawHLineFrom: 2 to: gapStart y: 0 color: highlightColor1 on: aCanvas.
	self drawHLineFrom: gapEnd to: right - 2 y: 0 color: highlightColor1 on: aCanvas.

	self drawHLineFrom: 1 to: gapStart y: 1 color: highlightColor2 on: aCanvas.
	self drawHLineFrom: gapEnd to: right - 1 y: 1 color: highlightColor2 on: aCanvas.

	self drawHLineFrom: 0 to: gapStart + 1 y: 2 color: color on: aCanvas.
	self drawHLineFrom: gapEnd - 1 to: right y: 2 color: color on: aCanvas.

	self drawHLineFrom: 0 to: gapStart + 2 y: 3 color: color on: aCanvas.
	self drawHLineFrom: gapEnd - 2 to: right y: 3 color: color on: aCanvas.

	self drawHLineFrom: 0 to: right y: 4 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 2 to: gapEnd - 2 y: 4 color: highlightColor1 on: aCanvas.

]

{ #category : #'event handling' }
BlockMorph >> duplicate [

	World activeHand attachMorph: self veryDeepCopy.

]

{ #category : #byob }
BlockMorph >> fastCopy [

	"copies only the receiver without the nextBlock and its parts"

	| dict new |
	dict := IdentityDictionary new: 100.
	new := self fastCopyRecordingIn: dict.
	new allMorphsDo: [:m | m updateReferencesUsing: dict].
	^ new	
]

{ #category : #byob }
BlockMorph >> fastCopyRecordingIn: dict [

	"copies just the receiver withoug the nextBlock and its parts"

	| new parts |
	new := self copy.
	dict at: self put: new.
	parts := self nonControlFlowSubmorphs.
	parts size > 0 ifTrue: [
		new privateSubmorphs:
			(parts collect: [:m |
				(m copyRecordingIn: dict) privateOwner: new])].

	self properties ifNotNil: [new privateProperties: self properties copyAll].
	^ new

]

{ #category : #byob }
BlockMorph >> fastDuplicate [

	"for debugging"

	World activeHand attachMorph: self fastCopy.

]

{ #category : #'object i/o' }
BlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #'block enumerating' }
BlockMorph >> firstBlockList [
	"If I am a control block, answer an array containing the block sequences for my first nested block (i.e., the blocks for the 'true' case of an if-then-else block). If I'm not a control structure block, just answer an empty array."

	^ #()

]

{ #category : #private }
BlockMorph >> fixBlockLayout [
	"This default implementation just clears my cached forms."

	blockLayoutNeeded ifFalse: [^ self].
	cachedForm := nil.
	cachedFeedbackForm := nil.

]

{ #category : #private }
BlockMorph >> flushCachedForm [

	cachedForm := nil.
	cachedFeedbackForm := nil.

]

{ #category : #'dropping/grabbing' }
BlockMorph >> formerPosition: formerPosition [

	formerPosition ifNil: [^ self "we need a formerPosition somehow (SPFA)"].

	super formerPosition: formerPosition
]

{ #category : #'drawing-optimization' }
BlockMorph >> fullBounds [
	"This is the hook that triggers lazy re-layout. It works because layoutChanged clears the fullBounds cache. Once per cycle, the fullBounds is requested from every morph in the world, and that request gets propagated through the entire submorph hierarchy, causing re-layout where needed. Note that multiple layoutChanges to the same morph can be done with little cost, since the layout is only done when the morph needs to be displayed."
	"Detail: Expands by 3 pixels if I have a process to allow for the running/error feedback."

	fullBounds ifNil: [
		"do layout here"
		blockLayoutNeeded ifTrue: [
			super fullBounds.
			self fixBlockLayout.
			fullBounds := nil.
			super fullBounds.  "recompute after layout"
			self changed].
		blockLayoutNeeded := false].

	phratchProc ifNotNil: [^ super fullBounds expandBy: 3].  "allow for running/error feedback"

	^ super fullBounds

]

{ #category : #'drawing-optimization' }
BlockMorph >> fullDrawOn: aCanvas [
	"Optimization: To speed up redisplay, especially when giving feedback that a stack is running, we create a cached form of the stack in the top block of the stack and simply display that. We also keep a cached image of the running/error feedback outline. This allows the running feedback to be turned on and off quickly. The caches are flushed whenever the layout of the stack changes."

	| offset |
	self isHidden ifTrue: [^ self].
	(self hasProperty: #errorOnDraw) ifTrue:[^ self drawErrorOn: aCanvas].
	(owner isKindOf: BlockMorph) ifTrue: [^ super fullDrawOn: aCanvas].  "only cache at top level"

	cachedForm ifNil: [self updateCachedForm].
	cachedForm ifNil: [^ super fullDrawOn: aCanvas].  "should not happen"

	offset := 0@0.
	phratchProc ifNotNil: [
		offset := 3@3.
		cachedFeedbackForm ifNil: [self updateCachedFeedbackForm].
		cachedFeedbackForm ifNotNil: [
			aCanvas paintImage: cachedFeedbackForm at: self fullBounds topLeft]].

	cachedForm ifNil: [^ self].
	aCanvas paintImage: cachedForm at: self fullBounds topLeft + offset.

]

{ #category : #'dropping/grabbing' }
BlockMorph >> handleReporterDrop [
	"This block, a reporter, has just been dropped. Try to embed it in a command block."

	| scriptsMorph editorMorph argM argOwner trgt|
	scriptsMorph := self ownerOrYourselfThatIsA: PhratchScriptsMorph.
	editorMorph := self ownerOrYourselfThatIsA: BlockEditorFrameMorph.
	trgt := scriptsMorph ifNil: [editorMorph].

	self isReporter ifTrue: [
		(#(
			#PhratchScriptsMorph
			'BlockEditorFrameMorph'
			'ReporterBlockDropTargetMorph'
		) includes: owner class printString) ifFalse: [^self ]].

	argM := owner topArgMorphAt: self bounds exclude: self.
	(argM notNil and: [argM acceptsTypeOf: self]) ifFalse: [
		scriptsMorph ifNotNil: [
			scriptsMorph recordDroppedBlock: self bottom: nil kickedOut: nil ].
		^ self].

	"tp := argM owner typeOfArg: argM."

	(argM isKindOf: BlockMorph)
		ifTrue: [
			argOwner := argM owner.
			argOwner replaceArgMorph: argM by: self.
			((argM isKindOf: CSlotMorph) or: [
			argM isKindOf: OSlotMorph]) ifTrue: [
				argM := argM body ].
			trgt ifNotNil: [ argM ifNotNil: [
				trgt addMorph: argM.
				argM position: (argOwner left+90)@(argM top - 20)]].
			scriptsMorph ifNotNil: [
				scriptsMorph recordDroppedBlock: self bottom: nil kickedOut: argM]]
		ifFalse: [
			argM owner replaceArgMorph: argM by: self.
			scriptsMorph ifNotNil: [
				scriptsMorph recordDroppedBlock: self bottom: nil kickedOut: nil]].

"
	#reporter = tp ifTrue: [
		self lambdaMenu ]

"
]

{ #category : #'event handling' }
BlockMorph >> handleTool: toolName hand: hand [

	| myStack myOwner sFrame varToDelete |
	toolName = 'CopyTool' ifTrue: [
		Sensor shiftPressed ifFalse: [hand toolType: nil].
		(owner isKindOf: PhratchBlockPaletteMorph) ifTrue: [^ self].  "ignore if in palette"
		^ self duplicate].

	toolName = 'CutTool' ifTrue: [
		Sensor shiftPressed ifFalse: [hand toolType: nil].
		(self topBlock owner isKindOf: PhratchScriptsMorph) ifTrue: [
			myStack := self nextBlock.
			myOwner := self owner.
			myStack ifNotNil: [
				(myOwner isKindOf: CBlockMorph)
					ifTrue: [ 
					"	copiedStack := myStack shallowCopy.
						self topBlock owner addMorph: copiedStack.
						[myStack top > myOwner bottom] whileTrue: [
							myStack position: (myStack left)@(myStack top - 1).
							self world displayWorldSafely].
						copiedStack delete."
						myOwner attachBlock: myStack]
					ifFalse: [
						(myOwner isKindOf: PhratchScriptsMorph)
							ifTrue: [myOwner addMorph: myStack]
							ifFalse: [
							"	copiedStack := myStack shallowCopy.
								(self topBlock owner) addMorph: copiedStack.
								[myStack top > myOwner bottom] whileTrue: [
									myStack position: (myStack left)@(myStack top - 1).
									self world displayWorldSafely].
								copiedStack delete."
								myOwner attachBlock: myStack]]].

				self isReporter ifTrue: [
					owner ifNotNil: [(owner isKindOf: CustomCommandBlockMorph)
						ifTrue: [ owner isTemplate ifTrue: [
							owner removeParameter: self.
							^self]]].
					self aboutToBeGrabbedBy: hand].
				PhratchFrameMorph putInClipboard: self.
				self delete.
				(myOwner isKindOf: PhratchScriptsMorph) ifTrue: [myOwner step].
				^ self]
		ifFalse: [
			sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
			sFrame ifNil: [^self].
			((owner isKindOf: PhratchBlockPaletteMorph) and:
			 [sFrame viewerPane currentCategory = #variables]) ifTrue: [
				(self isKindOf: SetterBlockMorph) ifTrue: [
					self variable ifNotNil: [
						varToDelete := self variable.
						(self confirm: 'Really delete variable: ', varToDelete, '?') ifFalse: [^ self].
						self receiver deleteVariable: varToDelete]].
				(self isKindOf: VariableBlockMorph) ifTrue: [
					varToDelete := self commandSpec.
					(self confirm: 'Really delete variable: ', varToDelete, '?') ifFalse: [^ self].
					self receiver deleteVariable: varToDelete].
				((varToDelete notNil) and: [sFrame notNil]) ifTrue: [
					sFrame workPane deleteVariable: varToDelete.
					sFrame viewerPane categoryChanged: 'variables']]].
	^ self].


]

{ #category : #'event handling' }
BlockMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #accessing }
BlockMorph >> hasComment [
	"answer true if a comment is sticked to the receiver"

	^ self commentMorph notNil

]

{ #category : #processes }
BlockMorph >> hasRunningProcess [

	^ phratchProc notNil and: [phratchProc isRunning]

]

{ #category : #accessing }
BlockMorph >> helpScreenName [
	"Answer the name of the help screen for this block, or nil if no help is available."

	^ nil

]

{ #category : #byob }
BlockMorph >> inheritAttribute [

	| sel rcv oi |
	(self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph)
		ifNil: [^ false].
	(self respondsTo: #selector) ifFalse: [
		^ false].
	sel := self selector.
	(self respondsTo: #receiver) ifFalse: [
		^ false].
	rcv := self receiver.
	(rcv isKindOf: ScriptablePhratchMorph) 
		ifFalse: [^ false].
	oi := rcv objectInterface.
	oi keysDo: [:att |
		(oi at: att) second = sel ifTrue: [
			^ rcv deleteAttribute: att]].
	^ false
]

{ #category : #'object i/o' }
BlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		isSpecialForm
		oldColor
	) from: anObjStream.

]

{ #category : #initialization }
BlockMorph >> initialize [

	super initialize.
	blockLayoutNeeded := true.
	isSpecialForm := false.
	color := Color r: 0.4 g: 0.7 b: 0.8.
	oldColor := color.
	phratchProc := nil.
	hadError := false.
	lastLayoutTime := 0.
	isContrasted := false.
	self formerPosition: 0@0

]

{ #category : #'drawing-optimization' }
BlockMorph >> invalidRect: damageRect [
	"Flush my cachedForm if some submorph reports a change."

	super invalidRect: (damageRect expandBy: 3).  "allows for running feedback"
	cachedForm := nil.

]

{ #category : #accessing }
BlockMorph >> isArgMorph [
	"True only for ArgMorphs."

	^ false

]

{ #category : #accessing }
BlockMorph >> isBlockMorph [
	"True only for BlockMorphs."

	^ true

]

{ #category : #byob }
BlockMorph >> isBlockTemplate [

	^ (self rootForGrabOf: self) ~= self
]

{ #category : #accessing }
BlockMorph >> isBooleanReporter [
	"Answer true if this block reports a boolean value. Answer false by default."

	^ false

]

{ #category : #byob }
BlockMorph >> isCShape [

	^ false
]

{ #category : #byob }
BlockMorph >> isContrasted [
	^isContrasted ifNil: [isContrasted := false]
]

{ #category : #byob }
BlockMorph >> isContrasted: bool [
	isContrasted := bool
]

{ #category : #byob }
BlockMorph >> isCustomBlock [
	^false
]

{ #category : #byob }
BlockMorph >> isDeletedAttribute [

	| sel rcv oi |
	(self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph)
		ifNil: [^ false].
	(self respondsTo: #selector) ifFalse: [
		^ false].
	sel := self selector.
	(self respondsTo: #receiver) ifFalse: [
		^ false].
	rcv := self receiver.
	(rcv isKindOf: ScriptablePhratchMorph) 
		ifFalse: [^ false].

	((self isKindOf: VariableBlockMorph) 
	or: [self isKindOf: ListContentsBlockMorph]) ifTrue: [
		^ (rcv allVarNames includes: self commandSpec) not].

	self isCustomBlock ifTrue: [
		^ rcv inheritedBlockIds includes: self id].

	sel = #get: ifTrue: [
		 ^ rcv deletedAttributes includes: (self argumentAt: 1) choice].
		
	oi := rcv objectInterface.
	rcv deletedAttributes do: [:att |
		(oi at: att) second = sel ifTrue: [
			^ true]].
	^ false
]

{ #category : #accessing }
BlockMorph >> isForever [
	"True only for forever command blocks."

	^ false

]

{ #category : #accessing }
BlockMorph >> isHatBlock [

	^ false

]

{ #category : #byob }
BlockMorph >> isInheritableAttribute [
	"indicate if my context menu lets me delete my attribute"

	| sel rcv oi |
	(self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph)
		ifNil: [^ false].
	(self respondsTo: #selector) ifFalse: [
		^ false].
	sel := self selector.
	(self respondsTo: #receiver) ifFalse: [
		^ false].
	rcv := self receiver.
	(rcv isKindOf: ScriptablePhratchMorph) 
		ifFalse: [^ false].
	rcv prototype ifNil: [
		^ false].
	oi := rcv objectInterface.
	oi keysDo: [:att |
		(oi at: att) second = sel ifTrue: [
			^ true]].
	^ false
]

{ #category : #byob }
BlockMorph >> isLambdaForm [
	^false
]

{ #category : #byob }
BlockMorph >> isNestedCShape [

	^ self outerLoop notNil

]

{ #category : #accessing }
BlockMorph >> isReporter [
	"Answer true if this block reports a value. False by default."

	^ false

]

{ #category : #accessing }
BlockMorph >> isSpecialForm [

	^isSpecialForm.
]

{ #category : #accessing }
BlockMorph >> isSpecialForm: aBoolean [
	"Sets a flag indicating that this block has a special evaluation rule."

	isSpecialForm := aBoolean.
]

{ #category : #accessing }
BlockMorph >> isStop [
	"True for only stop command blocks."

	^ false

]

{ #category : #accessing }
BlockMorph >> isStopOrForever [
	"True for stop or forever command blocks."

	^ self isStop or: [self isForever]

]

{ #category : #'dropping/grabbing' }
BlockMorph >> justDroppedInto: newOwner event: evt [
	"Handle being dropped into a new situation."

	| frame targetAssoc targetP targetBlock bottomBlockUsed upperBlock |
	bottomBlockUsed := false.

	owner ifNil:	[^self].

	(frame := newOwner ownerOrYourselfThatIsA: PhratchFrameMorph)
		ifNotNil: [frame projectModified].

	((self ownerOrYourselfThatIsA: PhratchViewerMorph) notNil) ifTrue: [
		"delete myself when dropped in the blocks palette area"
		self delete.
		^ self].

	((self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph) notNil) ifTrue: [
		"delete myself when dropped in the blocks palette area of a Block Editor"
		self delete.
		^ self].

	"blocks cannot be dropped onto the stage"
	(owner isKindOf: PhratchStageMorph) ifTrue: [
		^ evt hand rejectDropMorph: self event: evt].

	"okay to drop blocks into the world during development"
	((owner == World) and: [ScriptablePhratchMorph noviceMode not]) ifTrue: [^ self].

	((owner isKindOf: PhratchScriptsMorph) or:
	 [(owner isKindOf: BlockMorph) or:
	 [(owner isKindOf: PhratchStageMorph) and: [self isReporter]]]) ifFalse: [
		^ evt hand rejectDropMorph: self event: evt].

	self isReporter ifTrue: [^ self handleReporterDrop].
	(newOwner isKindOf: PhratchScriptsMorph) ifTrue: [
		newOwner recordDroppedBlock: self bottom: self bottomBlock kickedOut: nil].

	targetAssoc := self closestAttachTargetIn: newOwner.
	targetAssoc ifNil: [
		(self bottomBlock isKindOf: CBlockMorph) ifFalse: [
			targetAssoc := self bottomBlock closestAttachTargetIn: newOwner.
			targetAssoc ifNotNil:[
				bottomBlockUsed := true.
				(targetAssoc value owner isKindOf: BlockMorph) ifTrue:[
					targetAssoc := nil]]]].
	targetAssoc ifNil: [^ self].

	"make sure no processes are running"
	self = self topBlock ifTrue: [self stop].

	targetP := targetAssoc key.
	targetBlock := targetAssoc value.

	self allMorphsDo: [:m | m == targetBlock ifTrue: [^self ]].	"avoid infinite recursion, kludge for BYOB"

	targetP y = targetBlock top
		ifTrue: [
			"c-shaped block should nest the target block"
			((bottomBlockUsed not) and: [(self isKindOf: CBlockMorph)]) ifTrue:[
				(targetBlock owner isKindOf: BlockMorph)
					ifTrue: [(targetBlock owner) attachBlock: self]
					ifFalse: [self position: (targetP x - self bracketThickness)@(targetP y - self topBarHeight - 3)].
				(newOwner respondsTo: #recordNestedStack:) ifTrue: [
					newOwner recordNestedStack: targetBlock ].
				self attachBlockNested: targetBlock. ^ self].
			"for all other non-c-shaped blocks"
			(bottomBlockUsed or:[((targetBlock owner isKindOf: BlockMorph) not) and: [(self isKindOf: CBlockMorph) not]]) ifTrue:[
				PhratchTranslator isRTL
					ifTrue: [self bottomBlock position: (targetP x - self bottomBlock width) @ (targetP y - (self bottomBlock height - 4))]
					ifFalse: [self bottomBlock position: targetP x @ (targetP y - (self bottomBlock height - 4))].
				upperBlock := self bottomBlock owner.
				[upperBlock isKindOf: BlockMorph] whileTrue: [
					upperBlock nextBlock ifNotNil:[
						PhratchTranslator isRTL
							ifTrue: [upperBlock position: (targetP x - upperBlock width) @ (upperBlock nextBlock position y - (upperBlock height - 4))]
							ifFalse: [upperBlock position: targetP x @ (upperBlock nextBlock position y - (upperBlock height - 4))].
						upperBlock := upperBlock owner]]].
			((bottomBlockUsed not) and: [targetBlock owner isKindOf: BlockMorph]) ifTrue:[
				PhratchTranslator isRTL
					ifTrue: [self position: (targetP x - self width) @ (targetP y - (self height - 4))]
					ifFalse: [self position: targetP x @ (targetP y - (self height - 4))]].
			(targetBlock owner isKindOf: BlockMorph) ifTrue:[
				PhratchTranslator isRTL
					ifTrue: [self topBlock position: (targetP x - self topBlock width) @ targetP y]
					ifFalse: [self topBlock position: targetP x @ targetP y].
				targetBlock owner attachBlock: self topBlock].
			PhratchTranslator isRTL
				ifTrue: [targetBlock position: (targetP x - targetBlock width) @ (self bottomBlock position y + self bottomBlock height + 4)]
				ifFalse: [targetBlock position: targetP x @ (self bottomBlock position y + self bottomBlock height + 4)].
			((bottomBlockUsed not) and: [((targetBlock owner isKindOf: BlockMorph) not) and: [(self isKindOf: CBlockMorph)]]) ifFalse:[
				self bottomBlock attachBlock: targetBlock]]
		ifFalse: [
			self assert: [(self isKindOf: HatBlockMorph) not].  "I am not a HatBlockMorph"
			PhratchTranslator isRTL
				ifTrue: [self position: (targetP - (self width @0))]
				ifFalse: [self position: targetP].

			targetBlock attachBlock: self].

]

{ #category : #accessing }
BlockMorph >> lastLayoutTime [
	"Return the millisecond clock value the last time I was sent layoutChanged. This value can be used by other morphs to detect when layout changes have occured."

	^ lastLayoutTime

]

{ #category : #private }
BlockMorph >> layoutChanged [

	blockLayoutNeeded ifFalse: [super layoutChanged].
	blockLayoutNeeded := true.


]

{ #category : #accessing }
BlockMorph >> litUp: aBoolean [
	"If the argument true, light up this block. Otherwise, revert to it's old color."
	"Note: We use super color: so we don't overwrite oldColor. We also force a world update to ensure that the highlighting is seen by the user."

	aBoolean
		ifTrue:	[super color: (Color h: 60 s: 0.9 v: 0.89)]
		ifFalse:	[oldColor ifNotNil: [super color: oldColor]].

	aBoolean ifTrue: [
		World
			cycleWhileWaitingMSecs: PhratchProcess blockHighlightMSecs
			doInput: true
			doSteps: false].

]

{ #category : #'event handling' }
BlockMorph >> mouseDown: evt [
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	evt hand newKeyboardFocus: nil.
	evt rightButtonPressed
		ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu]
		ifFalse:	[evt hand waitForClicksOrDrag: self event: evt].

]

{ #category : #'event handling' }
BlockMorph >> mouseHold: evt [

	self rightButtonMenu.

]

{ #category : #byob }
BlockMorph >> nests: aBlock [
	^ false
]

{ #category : #accessing }
BlockMorph >> newScriptOwner: newOwner [
	"Update the receiver of all blocks to be the given morph. Used when moving scripts from one object to another."

	| rcvr |

	self allMorphsDo: [:m |
		((m isKindOf: CustomCommandBlockMorph) or: [
		m isKindOf: CustomReporterBlockMorph]) ifTrue: [
			newOwner ensureCustomBlockExists: m definition ].
		(m isKindOf: BlockMorph) ifTrue: [
			rcvr := newOwner.
			(((m isKindOf: VariableBlockMorph) | (m isKindOf: SetterBlockMorph)) and: 
			[m isSpecialForm not]) ifTrue: [
				(m receiver isKindOf: PhratchStageMorph) ifTrue: [rcvr := m receiver].
				newOwner ensureVariableExists: m variable.  "ensure that variable exists"
				m color: rcvr variableBlockColor].
			(((m isKindOf: VariableBlockMorph) | (m isKindOf: SetterBlockMorph)) and: 
			[m isSpecialForm]) ifFalse: [ 
				m receiver: rcvr ]].
		((m isKindOf: CommandBlockMorph) and: [
		m isSpecialForm not]) ifTrue: [
			m argMorphs do: [:arg |
				((arg isKindOf: ChoiceArgMorph) and:
				 [arg getOptionsSelector = #listVarMenu]) ifTrue: [
					arg choice ifNotNil: [newOwner ensureListExists: arg choice]]]].
		(m isKindOf: ListContentsBlockMorph) ifTrue: [
			newOwner ensureListExists: m commandSpec].
		(m isKindOf: HatBlockMorph) ifTrue: [m scriptOwner: newOwner]].

]

{ #category : #accessing }
BlockMorph >> newScriptOwnerPrivate: newOwner [
	"Update the receiver of all blocks to be the given morph. Supress ensuring whether a custom block exists.
	used when creating a new recursive block"

	| rcvr |

	self allMorphsDo: [:m |

" commented out from #newScriptOwner: 
for use in ScriptablePhratchMorph ->> #definitionFor:

		((m isKindOf: CustomCommandBlockMorph) or: [
		m isKindOf: CustomReporterBlockMorph]) ifTrue: [
			newOwner ensureCustomBlockExists: m definition ].
"
		(m isKindOf: BlockMorph) ifTrue: [
			rcvr := newOwner.
			(((m isKindOf: VariableBlockMorph) | (m isKindOf: SetterBlockMorph)) and: 
			[m isSpecialForm not]) ifTrue: [
				(m receiver isKindOf: PhratchStageMorph) ifTrue: [rcvr := m receiver].
				newOwner ensureVariableExists: m variable.  "ensure that variable exists"
				m color: rcvr variableBlockColor].
			(((m isKindOf: VariableBlockMorph) | (m isKindOf: SetterBlockMorph)) and: 
			[m isSpecialForm]) ifFalse: [ 
				m receiver: rcvr ]].
		((m isKindOf: CommandBlockMorph) and: [
		m isSpecialForm not]) ifTrue: [
			m argMorphs do: [:arg |
				((arg isKindOf: ChoiceArgMorph) and:
				 [arg getOptionsSelector = #listVarMenu]) ifTrue: [
					arg choice ifNotNil: [newOwner ensureListExists: arg choice]]]].
		(m isKindOf: ListContentsBlockMorph) ifTrue: [
			newOwner ensureListExists: m commandSpec].
		(m isKindOf: HatBlockMorph) ifTrue: [m scriptOwner: newOwner]].

]

{ #category : #'block enumerating' }
BlockMorph >> nextBlock [
	"Answer the block myself in the block sequence or nil if I am the last block in the sequence. Each block is a submorph of the previous block."

	^ self submorphs detect: [:m | m isKindOf: BlockMorph] ifNone: [nil]

]

{ #category : #'block enumerating' }
BlockMorph >> nextBlock: aBlockMorph [
	"Add the given block to this stack."

	self addMorph: aBlockMorph.

]

{ #category : #private }
BlockMorph >> nonControlFlowSubmorphs [
	"Answer a collection of submorphs minus any blocks that are part of the control flow. For example, command blocks omit their submorph that is the next block in the block sequence, C-blocks omit both their next block and the first block of their nested block list, etc."

	^ submorphs select: [:m | (m ~~ self nextBlock)]

]

{ #category : #byob }
BlockMorph >> outerLoop [

	| all |
	all := self allOwners select: [:o | (o isKindOf: BlockMorph) and: [o notNil and: [o isCShape]]].
	all size < 1 ifTrue: [^ nil].
	^ all detect: [:o | o nests: self] ifNone: [nil]
]

{ #category : #byob }
BlockMorph >> pauseProcess [
	"Called on the top block of a running stack when all processes are stopped."

	phratchProc ifNotNil: [phratchProc pause].

]

{ #category : #processes }
BlockMorph >> phratchProc [
	"Answer my process or nil if I'm not currently the top of a running stack."

	^ phratchProc

]

{ #category : #processes }
BlockMorph >> phratchProc: aPhratchProcess [

	hadError == true ifTrue: [cachedFeedbackForm := nil].
	hadError := false.
	phratchProc := aPhratchProcess.
	self changed.
]

{ #category : #accessing }
BlockMorph >> presentHelpScreen [
	"Answer the name of the help screen for this block, or nil if no help is available."

	| fr |
	fr := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	fr
		ifNil: [^ nil]
		ifNotNil: [fr presentHelpScreen: self helpScreenName]

]

{ #category : #private }
BlockMorph >> printCodeOn: aStream indent: indent [
	"Append a human-readable string for this block on the given stream."

	indent timesRepeat: [aStream nextPutAll: '    '].
	aStream nextPutAll: self class name; cr.
	self nextBlock ifNotNil: [self nextBlock printCodeOn: aStream indent: indent].

]

{ #category : #private }
BlockMorph >> printCodeSubmorph: aMorph on: aStream [

	(aMorph isKindOf: ArgMorph) ifTrue: [aMorph printArgOn: aStream].
	(aMorph isKindOf: BlockMorph) ifTrue: [
		aStream nextPut: $(.
		aMorph printCodeOn: aStream indent: 0.
		aStream skip: -1.  "remove carriage return"
		aStream nextPut: $)].
	(aMorph isKindOf: StringMorph) ifTrue: [
		((aMorph contents = '?') | (aMorph contents = '%'))
			ifTrue: [aStream skip: -1].	"remove space before ? or %"
		aStream nextPutAll: aMorph contents].

]

{ #category : #byob }
BlockMorph >> privateProperties: collectionOfProperties [

	self setProperty: #properties toValue: collectionOfProperties
]

{ #category : #byob }
BlockMorph >> properties [
	self valueOfProperty: #properties
]

{ #category : #accessing }
BlockMorph >> receiver [
	"Overridden by blocks which have receivers."

	^ nil

]

{ #category : #accessing }
BlockMorph >> receiver: anObject [
	"Set my receiver. Does nothing here, but overridden in blocks that have a receiver." 

]

{ #category : #byob }
BlockMorph >> refreshAttributeArgs [

	self allMorphsDo: [:m |
		(m isKindOf: AttributeArgMorph) ifTrue: [
			m refresh ]]
]

{ #category : #'event handling' }
BlockMorph >> rejectDropEvent: evt [
	"we should only reject drops if they're not blocks, variables, etc. Should check it out better"
	^false
]

{ #category : #accessing }
BlockMorph >> removeCopyTooltip [

	copyTooltip delete.
	copyTooltip := nil.

]

{ #category : #byob }
BlockMorph >> resumeProcess [
	"Called on the top block of a running stack when all processes are stopped."

	phratchProc ifNotNil: [phratchProc resume].

]

{ #category : #'event handling' }
BlockMorph >> rightButtonMenu [

	| menu |
	menu := MenuMorphNG new defaultTarget: self.
	menu add: 'help' value: #presentHelpScreen.

	(owner isKindOf: PhratchBlockPaletteMorph) ifFalse: [
		menu addLine.
		menu add: 'duplicate' value: #duplicate.	
		(self owner isKindOf: BlockMorph) ifFalse: [  "we can't yet delete a blocks inside a script"
			menu add: 'delete' value: #delete]].

	DebugMenu ifTrue: [
		menu addLine.
		menu add: 'show tuples' value: #showTuples].
	
	menu localize; invokeModal" popUpAt: World activeHand position inWorld:  World"  "localize; invokeOn: self"

]

{ #category : #'dropping/grabbing' }
BlockMorph >> rootForGrabOf: aMorph [
	"Allow myself to be extracted."

	(owner notNil and: [owner isPartsBin])

		ifTrue: [^ super rootForGrabOf: aMorph]
		ifFalse: [^ self].

]

{ #category : #'dropping/grabbing' }
BlockMorph >> shouldDropOnMouseUp [
	^true
]

{ #category : #accessing }
BlockMorph >> showError [
	"Make this block to show an error."

	super color: (Color r: 0.831 g: 0.156 b: 0.156).
]

{ #category : #accessing }
BlockMorph >> showErrorFeedback [
	"Show that this stack encountered an error."

	hadError := true.
	cachedFeedbackForm := nil.
	self changed.

]

{ #category : #'event handling' }
BlockMorph >> showTuples [

	(StringHolder new contents: self tupleSequence printString)
		openLabel: 'Tuple'
]

{ #category : #'dropping/grabbing' }
BlockMorph >> slideBackToFormerSituation: evt [

	| wasEmbedded o pane oldP slideForm startPoint s |
	wasEmbedded := false.
	(o := evt hand formerOwner) ifNil: [^ self].
	(o isKindOf: BlockMorph) ifTrue: [
		wasEmbedded := true.
		(pane := o ownerOrYourselfThatIsA: PhratchScriptsMorph) ifNotNil: [
			o := pane]].

	"restore the old position relative to the old owner,
	in case the old owner has been scrolled in the meantime"
	oldP := (self formerPosition ifNil: [0@0]) + o position.

	slideForm := self imageForm offset: 0@0.
	startPoint := evt hand fullBounds origin.
	owner isNil ifFalse: [owner privateRemoveMorph: self].
	self world isNil ifFalse: [self world displayWorld ].
	slideForm slideFrom: startPoint to: oldP nSteps: 12 delay: 15.
	self position: oldP.
	o addMorph: self.
	wasEmbedded ifTrue: [self justDroppedInto: o event: evt].

	"scroll the dropped morph into view in case the owner has been
	scrolled in the meantime"
	s := o ownerOrYourselfThatIsA: ScrollFrameMorph.
	s ifNotNil: [s scrollMorphIntoView: self ]


]

{ #category : #processes }
BlockMorph >> start [
	"Start a process running this block stack. This default implementation does nothing."

]

{ #category : #'event handling' }
BlockMorph >> startDrag: evt [
	
	| startEvt rootForGrab |

	evt hand toolType ifNil: [
		startEvt := evt hand firstClickEvent.
		startEvt ifNil: [startEvt := evt].
		rootForGrab := self rootForGrabOf: self.
		rootForGrab ifNil: [^ self].
		evt hand grabMorph: rootForGrab.
		rootForGrab position: evt hand position + (rootForGrab topLeft - startEvt cursorPoint)].

	self handleTool: evt hand toolType hand: evt hand.

]

{ #category : #processes }
BlockMorph >> stop [

	phratchProc ifNotNil: [
		self changed.
		phratchProc stop.
		phratchProc := nil].

]

{ #category : #'object i/o' }
BlockMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		isSpecialForm
		oldColor
	) on: anObjStream.

]

{ #category : #private }
BlockMorph >> tabFields [

	| fields nxt nxtFields |
	fields := OrderedCollection new.
	self nonControlFlowSubmorphs do: [:m |
		(m isKindOf: ExpressionArgMorph)
			ifTrue: [fields add: m ]
			ifFalse: [(m respondsTo: #tabFields)
				ifTrue: [fields addAll: m tabFields ]]]. 

	nxt := self nextBlock.
	nxt ifNil: [^ fields].
	nxtFields := nxt tabFields.
	nxtFields size = 0 ifTrue: [
		^ fields ].
	^ fields, nxtFields 

]

{ #category : #processes }
BlockMorph >> toggleProcess [

	(phratchProc isNil or: [phratchProc errorFlag])
		ifTrue: [self start]
		ifFalse: [self stop].

]

{ #category : #'block enumerating' }
BlockMorph >> topBlock [
	"Answer the top Block of this stack. The top block may be a HatBlockMorph, a CommandBlockMorph, or perhaps some other kind of BlockMorph."

	| m |
	m := self.
	[(m owner isKindOf: BlockMorph) and: [(m owner isKindOf: ReporterBlockDropTargetMorph) not]] whileTrue: [m := m owner].
	^ m

]

{ #category : #'block enumerating' }
BlockMorph >> tupleSequence [
	"Answer a sequence of tuples (Array) describing this stack of blocks."

	^ self blockSequence collect: [:b | b asBlockTuple]

]

{ #category : #'drawing-optimization' }
BlockMorph >> updateCachedFeedbackForm [
	"Create a cached feedback Form to show this stack's running (or error) status."

	| outlineColor |
	cachedForm ifNil: [^ self].
	outlineColor := (phratchProc notNil and: [phratchProc errorFlag])
		ifTrue: [Color r: 0.831 g: 0.156 b: 0.156]
		ifFalse: [Color gray: 0.953].

	cachedFeedbackForm := cachedForm
		outlineWidth: 3
		color: outlineColor
		depth: 8.

]

{ #category : #'drawing-optimization' }
BlockMorph >> updateCachedForm [
	"Create a cached Form of this stack's appearance."

	| c offset |
	oldColor ifNotNil: [color := oldColor].
	c := FormCanvas extent: self fullBounds extent depth: 32.
	PhratchTranslator isRTL
		ifTrue: [
			offset := phratchProc ifNil: [0@0] ifNotNil: [3@3].
			c := c copyOffset: (self fullBounds topLeft + offset) negated]
		ifFalse: [c := c copyOffset: self topLeft negated].
	self drawOn: c.
	self drawSubmorphsOn: c.
	cachedForm := c form.
	lastLayoutTime := Time millisecondClockValue.

]

{ #category : #'event handling' }
BlockMorph >> wantsKeyboardFocusFor: aSubmorph [
	"Don't allow shift-click editing of block labels."

	^ false

]
