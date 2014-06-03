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
		'lastLayoutTime',
		'originalColor',
		'phratchProc'
	],
	#classVars : [
		'CBlockBracketThickness',
		'Contrast',
		'DebugMenu',
		'LabelColor',
		'PuzzleInset',
		'PuzzleWidth'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #'class initialization' }
BlockMorph class >> contrastStrong [
	Contrast := #strong.
	ReporterBlockMorph allInstancesDo: [:b | b changed ].
]

{ #category : #'class initialization' }
BlockMorph class >> initBlock: aBlock on: aScriptablePhratchMorph withSpec: spec color: blockColor [

	|blockLabelSpec argPermutation selector defaultArgs rcvr|
	blockLabelSpec := PhratchTranslator translationFor: (spec at: 1).
	argPermutation := CommandBlockMorph argPermutationForSpec: (spec at: 1) withTranslation: blockLabelSpec.
	selector := (spec at: 3) asSymbol.
	defaultArgs := aScriptablePhratchMorph defaultArgsFor: spec.
	
	rcvr := (ScriptablePhratchMorph isSpriteSpecificTarget: aScriptablePhratchMorph selector: selector)
		ifTrue: [ aScriptablePhratchMorph ]
		ifFalse: [ aScriptablePhratchMorph ownerOrYourselfThatIsAPhratchStageMorph ].
		
	^ aBlock
		argPermutation: argPermutation;
		color: blockColor;
		selector: selector;
		commandSpec: blockLabelSpec;
		defaultArgs: defaultArgs;
		receiver: rcvr;
		yourself
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

{ #category : #'dropping/grabbing' }
BlockMorph >> aboutToBeGrabbedBy: aHandMorph [
	"If I'm being used as an argument, replace myself with an appropriate argument morph. Copied from WatcherMorph."

	"if I was being used as argument, replace myself with a generic argument morph"

	| m |
	(owner isCommandBlockMorph) | (owner isMultiArgMorph)
		ifFalse: [ ^ self ].
	m := owner argMorphToReplace: self.
	m ifNotNil: [ owner replaceArgMorph: self by: m ]
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
				with: (self topLeft + aPoint extent: 1@1)
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
	(self isHatBlockMorph)
		ifFalse: [ 
			result :=  result copyWith: self topLeft -> self ].
	nextB := self nextBlock.
	nextB
		ifNil: [ 
			self isStopOrForever
				ifFalse: [ 
					result :=  result copyWith: self bottomLeft -> self ] ].
	nextB ifNotNil: [ nextB blockAttachPoints: aSet ].
	aSet addAll: result
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
	[m nextBlock isBlockMorph] whileTrue: [m := m nextBlock].
	^ m

]

{ #category : #accessing }
BlockMorph >> canBecomeWatcher [
	"Answer true if this block can become a watcher when dropped onto the stage. False by default."

	^ false

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

	| xThresh yThresh attachPoints best bestDist targetP dist ref |
	xThresh := 65.
	yThresh := self yThresh.
	attachPoints := OrderedCollection new: 100.
	newOwner allMorphs reject: [ :m | m == newOwner ]
		thenDo: [ :m | 
			(m ~~ self
				and: [ 
					m ~~ self bottomBlock
						and: [ 
							m ~~ self topBlock
								and: [ m ~~ self owner and: [ (m isBlockMorph) and: [ m isReporter not | (m isCommandScriptBlockMorph) ] ] ] ] ])
				ifTrue: [ m blockAttachPoints: attachPoints ] ].
	((self isHatBlockMorph) or: [ (self ownerOrYourselfThatIsAHatBlockMorph) notNil ])
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
			ref :=  self left .
			(ref - targetP x) abs < xThresh
				ifTrue: [ 
					((self top - targetP y) abs < yThresh or: [ self nextBlock isNil and: [ (self bottom - targetP y) abs < yThresh ] ])
						ifTrue: [ 
							"targetP is within sticking range"
							dist :=(self position - targetP) r .
							dist < bestDist
								ifTrue: [ 
									"(self top - targetP y) abs < yThresh
										ifTrue: [ 
											topUsed := true.
											bottomUsed := false ].
									(self nextBlock isNil and: [ (self bottom - targetP y) abs < yThresh ])
										ifTrue: [ 
											topUsed := false.
											bottomUsed := true ]."
									best := assoc.
									bestDist := dist ] ] ] ].	"special case for the auto-wrapping of c-shaped/if-else blocks"
	
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
	sm := self ownerOrYourselfThatIsAPhratchScriptsMorph.
	sm ifNil: [^ nil].
	^ sm submorphs detect: [: m |
		(m isPhratchCommentMorph) and: [
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
							ob := (owner isMultiArgMorph)
								ifTrue: [ owner owner ]
								ifFalse: [ owner ] ]
						ifFalse: [ 
							((owner isProcedureHatBlockMorph) and: [ owner nextBlock ~= self ])
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
					color := color twiceLighter	" lighter slightlyLighter " ] ].
	submorphs
		do: [ :m | 
			(m isStringMorph)
				ifTrue: [ m color: self labelColor ]
				ifFalse: [ 
					(m isMultiArgMorph)
						ifTrue: [ m contrastColor ] ] ]
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
	(self ownerOrYourselfThatIsAPhratchBlockPaletteMorph)
		ifNil: [^ false].
	(self respondsTo: #selector) ifFalse: [
		^ false].
	sel := self selector.
	(self respondsTo: #receiver) ifFalse: [
		^ false].
	rcv := self receiver.
	(rcv isScriptablePhratchMorph) 
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

	aCanvas paintImage: c form at: self topLeft.

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

	aCanvas fillRectangle: (self topLeft + aPoint extent: 1@1) color: c.
	

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

{ #category : #'as yet unclassified' }
BlockMorph >> evaluatePhratchProcess: aProcess stage: aStageMorph [

	^ aProcess evaluateCommandFor: aStageMorph
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
	(owner isBlockMorph) ifTrue: [^ super fullDrawOn: aCanvas].  "only cache at top level"

	cachedForm ifNil: [self updateCachedForm].

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
	scriptsMorph := self ownerOrYourselfThatIsAPhratchScriptsMorph.
	editorMorph := self ownerOrYourselfThatIsABlockEditorFrameMorph.
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

	(argM isBlockMorph)
		ifTrue: [
			argOwner := argM owner.
			argOwner replaceArgMorph: argM by: self.
			((argM isCSlotMorph) or: [
			argM isOSlotMorph]) ifTrue: [
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
	toolName = 'CopyTool'
		ifTrue: [ 
			Sensor shiftPressed
				ifFalse: [ hand toolType: nil ].
			(owner isPhratchBlockPaletteMorph)
				ifTrue: [ ^ self ].	"ignore if in palette"
			^ self duplicate ].
	toolName = 'CutTool'
		ifFalse: [ ^ self ].
	Sensor shiftPressed
		ifFalse: [ hand toolType: nil ].
	(self topBlock owner isPhratchScriptsMorph)
		ifTrue: [ 
			myStack := self nextBlock.
			myOwner := self owner.
			myStack
				ifNotNil: [ 
					(myOwner isCBlockMorph)
						ifTrue: [ 
							myOwner attachBlock: myStack ]
						ifFalse: [ 
							(myOwner isPhratchScriptsMorph)
								ifTrue: [ myOwner addMorph: myStack ]
								ifFalse: [ 
									myOwner attachBlock: myStack ] ] ].
			self isReporter
				ifTrue: [ 
					owner
						ifNotNil: [ 
							(owner isCustomCommandBlockMorph)
								ifTrue: [ 
									owner isTemplate
										ifTrue: [ 
											owner removeParameter: self.
											^ self ] ] ].
					self aboutToBeGrabbedBy: hand ].
			PhratchFrameMorph putInClipboard: self.
			self delete.
			(myOwner isPhratchScriptsMorph)
				ifTrue: [ myOwner step ].
			^ self ]
		ifFalse: [ 
			sFrame := self ownerOrYourselfThatIsAPhratchFrameMorph.
			sFrame ifNil: [ ^ self ].
			((owner isPhratchBlockPaletteMorph) and: [ sFrame viewerPane currentCategory = #variables ])
				ifTrue: [ 
					(self isSetterBlockMorph)
						ifTrue: [ 
							self variable
								ifNotNil: [ 
									varToDelete := self variable.
									(self confirm: 'Really delete variable: ' , varToDelete , '?')
										ifFalse: [ ^ self ].
									self receiver deleteVariable: varToDelete ] ].
					(self isVariableBlockMorph)
						ifTrue: [ 
							varToDelete := self commandSpec.
							(self confirm: 'Really delete variable: ' , varToDelete , '?')
								ifFalse: [ ^ self ].
							self receiver deleteVariable: varToDelete ].
					(varToDelete notNil and: [ sFrame notNil ])
						ifTrue: [ 
							sFrame workPane deleteVariable: varToDelete.
							sFrame viewerPane categoryChanged: 'variables' ] ] ].
	^ self
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
	(self ownerOrYourselfThatIsAPhratchBlockPaletteMorph)
		ifNil: [^ false].
	(self respondsTo: #selector) ifFalse: [
		^ false].
	sel := self selector.
	(self respondsTo: #receiver) ifFalse: [
		^ false].
	rcv := self receiver.
	(rcv isScriptablePhratchMorph) 
		ifFalse: [^ false].
	oi := rcv objectInterface.
	oi keysDo: [:att |
		(oi at: att) second = sel ifTrue: [
			^ rcv deleteAttribute: att]].
	^ false
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
	self formerPosition: 0@0

]

{ #category : #'drawing-optimization' }
BlockMorph >> invalidRect: damageRect [
	"Flush my cachedForm if some submorph reports a change."

	super invalidRect: (damageRect expandBy: 3).  "allows for running feedback"
	cachedForm := nil.

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
BlockMorph >> isContrasted: bool [
]

{ #category : #byob }
BlockMorph >> isCustomBlock [
	^false
]

{ #category : #byob }
BlockMorph >> isDeletedAttribute [
	| sel rcv oi |
	(self ownerOrYourselfThatIsAPhratchBlockPaletteMorph) ifNil: [ ^ false ].
	(self respondsTo: #selector)
		ifFalse: [ ^ false ].
	sel := self selector.
	(self respondsTo: #receiver)
		ifFalse: [ ^ false ].
	rcv := self receiver.
	(rcv isScriptablePhratchMorph)
		ifFalse: [ ^ false ].
	((self isVariableBlockMorph) or: [ self isListContentsBlockMorph ])
		ifTrue: [ ^ (rcv allVarNames includes: self commandSpec) not ].
	self isCustomBlock
		ifTrue: [ ^ rcv inheritedBlockIds includes: self id ].
	sel = #get:
		ifTrue: [ ^ rcv deletedAttributes includes: (self argumentAt: 1) choice ].
	oi := rcv objectInterface.
	^ rcv deletedAttributes anySatisfy: [ :att | (oi at: att) second = sel ]
]

{ #category : #accessing }
BlockMorph >> isForever [
	"True only for forever command blocks."

	^ false

]

{ #category : #byob }
BlockMorph >> isInheritableAttribute [
	"indicate if my context menu lets me delete my attribute"

	| sel rcv oi |
	(self ownerOrYourselfThatIsAPhratchBlockPaletteMorph)
		ifNil: [^ false].
	(self respondsTo: #selector) ifFalse: [
		^ false].
	sel := self selector.
	(self respondsTo: #receiver) ifFalse: [
		^ false].
	rcv := self receiver.
	(rcv isScriptablePhratchMorph) 
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

	(frame := newOwner ownerOrYourselfThatIsAPhratchFrameMorph)
		ifNotNil: [frame projectModified].

	((self ownerOrYourselfThatIsAPhratchViewerMorph) notNil) ifTrue: [
		"delete myself when dropped in the blocks palette area"
		self delete.
		^ self].

	((self ownerOrYourselfThatIsAPhratchBlockPaletteMorph) notNil) ifTrue: [
		"delete myself when dropped in the blocks palette area of a Block Editor"
		self delete.
		^ self].

	"blocks cannot be dropped onto the stage"
	(owner isPhratchStageMorph) ifTrue: [
		^ evt hand rejectDropMorph: self event: evt].

	"okay to drop blocks into the world during development"
	((owner == World) and: [ScriptablePhratchMorph noviceMode not]) ifTrue: [^ self].

	((owner isPhratchScriptsMorph) or:
	 [(owner isBlockMorph) or:
	 [(owner isPhratchStageMorph) and: [self isReporter]]]) ifFalse: [
		^ evt hand rejectDropMorph: self event: evt].

	self isReporter ifTrue: [^ self handleReporterDrop].
	(newOwner isPhratchScriptsMorph) ifTrue: [
		newOwner recordDroppedBlock: self bottom: self bottomBlock kickedOut: nil].

	targetAssoc := self closestAttachTargetIn: newOwner.
	targetAssoc ifNil: [
		"(self bottomBlock isCBlockMorph) ifFalse: ["
			targetAssoc := self bottomBlock closestAttachTargetIn: newOwner.
			targetAssoc ifNotNil:[
				bottomBlockUsed := true.
				(targetAssoc value owner isBlockMorph) ifTrue:[
					targetAssoc := nil]]"]"].
	targetAssoc ifNil: [^ self].

	"make sure no processes are running"
	self = self topBlock ifTrue: [self stop].

	targetP := targetAssoc key.
	targetBlock := targetAssoc value.

	self allMorphsDo: [:m | m == targetBlock ifTrue: [^self ]].	"avoid infinite recursion, kludge"

	targetP y = targetBlock top
		ifTrue: [
			
			((bottomBlockUsed not) and: [(self isCBlockMorph)]) ifTrue:[
				self bottomBlock position: targetP x @ (targetP y - (self bottomBlock height) -4 ).
				upperBlock := self bottomBlock owner.
				[upperBlock isBlockMorph] whileTrue: [
					upperBlock nextBlock ifNotNil:[
						upperBlock position: targetP x @ (upperBlock nextBlock position y - (upperBlock height) -4 ).
						upperBlock := upperBlock owner]].
				self bottomBlock attachBlock: targetBlock. ^self].
			"for all other non-c-shaped blocks"
			(bottomBlockUsed or:[((targetBlock owner isBlockMorph) not) and: [(self isCBlockMorph) not]]) ifTrue:[
				self bottomBlock position: targetP x @ (targetP y - (self bottomBlock height - 4)).
				upperBlock := self bottomBlock owner.
				[upperBlock isBlockMorph] whileTrue: [
					upperBlock nextBlock ifNotNil:[
						upperBlock position: targetP x @ (upperBlock nextBlock position y - (upperBlock height - 4)).
						upperBlock := upperBlock owner]]].
			((bottomBlockUsed not) and: [targetBlock owner isBlockMorph]) ifTrue:[
				self position: targetP x @ (targetP y - (self height - 4))].
			(targetBlock owner isBlockMorph) ifTrue:[
				self topBlock position: targetP x @ targetP y.
				targetBlock owner attachBlock: self topBlock].
			targetBlock position: targetP x @ (self bottomBlock position y + self bottomBlock height + 4).
			((bottomBlockUsed not) and: [((targetBlock owner isBlockMorph) not) and: [(self isCBlockMorph)]]) ifFalse:[
				self bottomBlock attachBlock: targetBlock]]
		ifFalse: [
			self assert: [(self isHatBlockMorph) not].  "I am not a HatBlockMorph"
			self position: targetP.

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

{ #category : #byob }
BlockMorph >> nests: aBlock [
	^ false
]

{ #category : #accessing }
BlockMorph >> newScriptOwner: newOwner [
	"Update the receiver of all blocks to be the given morph. Used when moving scripts from one object to another."

	| rcvr |

	self allMorphsDo: [:m |
		((m isCustomCommandBlockMorph) or: [
		m isCustomReporterBlockMorph]) ifTrue: [
			newOwner ensureCustomBlockExists: m definition ].
		(m isBlockMorph) ifTrue: [
			rcvr := newOwner.
			(((m isVariableBlockMorph) | (m isSetterBlockMorph)) and: 
			[m isSpecialForm not]) ifTrue: [
				(m receiver isPhratchStageMorph) ifTrue: [rcvr := m receiver].
				newOwner ensureVariableExists: m variable.  "ensure that variable exists"
				m color: rcvr variableBlockColor].
			(((m isVariableBlockMorph) | (m isSetterBlockMorph)) and: 
			[m isSpecialForm]) ifFalse: [ 
				m receiver: rcvr ]].
		((m isCommandBlockMorph) and: [
		m isSpecialForm not]) ifTrue: [
			m argMorphs do: [:arg |
				((arg isChoiceArgMorph) and:
				 [arg getOptionsSelector = #listVarMenu]) ifTrue: [
					arg choice ifNotNil: [newOwner ensureListExists: arg choice]]]].
		(m isListContentsBlockMorph) ifTrue: [
			newOwner ensureListExists: m commandSpec].
		(m isHatBlockMorph) ifTrue: [m scriptOwner: newOwner]].

]

{ #category : #accessing }
BlockMorph >> newScriptOwnerPrivate: newOwner [
	"Update the receiver of all blocks to be the given morph. Supress ensuring whether a custom block exists.
	used when creating a new recursive block"

	| rcvr |

	self allMorphsDo: [:m |

" commented out from #newScriptOwner: 
for use in ScriptablePhratchMorph ->> #definitionFor:

		((m isCustomCommandBlockMorph) or: [
		m isCustomReporterBlockMorph]) ifTrue: [
			newOwner ensureCustomBlockExists: m definition ].
"
		(m isBlockMorph) ifTrue: [
			rcvr := newOwner.
			(((m isVariableBlockMorph) | (m isSetterBlockMorph)) and: 
			[m isSpecialForm not]) ifTrue: [
				(m receiver isPhratchStageMorph) ifTrue: [rcvr := m receiver].
				newOwner ensureVariableExists: m variable.  "ensure that variable exists"
				m color: rcvr variableBlockColor].
			(((m isVariableBlockMorph) | (m isSetterBlockMorph)) and: 
			[m isSpecialForm]) ifFalse: [ 
				m receiver: rcvr ]].
		((m isCommandBlockMorph) and: [
		m isSpecialForm not]) ifTrue: [
			m argMorphs do: [:arg |
				((arg isChoiceArgMorph) and:
				 [arg getOptionsSelector = #listVarMenu]) ifTrue: [
					arg choice ifNotNil: [newOwner ensureListExists: arg choice]]]].
		(m isListContentsBlockMorph) ifTrue: [
			newOwner ensureListExists: m commandSpec].
		(m isHatBlockMorph) ifTrue: [m scriptOwner: newOwner]].

]

{ #category : #'block enumerating' }
BlockMorph >> nextBlock [
	"Answer the block myself in the block sequence or nil if I am the last block in the sequence. Each block is a submorph of the previous block."

	^ self submorphs detect: [:m | m isBlockMorph] ifNone: [nil]

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
	all := self allOwners select: [:o | (o isBlockMorph) and: [o notNil and: [o isCShape]]].
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

	hadError ifNil:[hadError := false].
	hadError ifTrue: [cachedFeedbackForm := nil].
	hadError := false.
	phratchProc := aPhratchProcess.
	self changed.
]

{ #category : #accessing }
BlockMorph >> presentHelpScreen [
	"Answer the name of the help screen for this block, or nil if no help is available."

	| fr |
	fr := self ownerOrYourselfThatIsAPhratchFrameMorph.
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
	(aMorph isArgMorph)
		ifTrue: [ aMorph printArgOn: aStream ].
	(aMorph isBlockMorph)
		ifTrue: [ 
			aStream nextPut: $(.
			aMorph printCodeOn: aStream indent: 0.
			aStream skip: -1.	"remove carriage return"
			aStream nextPut: $) ].
	(aMorph isStringMorph)
		ifFalse: [ ^ self ].
	({'?' . '%'} includes: aMorph contents)
		ifTrue: [ aStream skip: -1 ].	"remove space before ? or %"
	aStream nextPutAll: aMorph contents
]

{ #category : #byob }
BlockMorph >> properties [
	self valueOfProperty: #properties
]

{ #category : #accessing }
BlockMorph >> receiver [
	"Overridden by blocks which have receivers."

	^ false

]

{ #category : #accessing }
BlockMorph >> receiver: anObject [
	"Set my receiver. Does nothing here, but overridden in blocks that have a receiver." 

]

{ #category : #byob }
BlockMorph >> refreshAttributeArgs [

	self allMorphsDo: [:m |
		(m isAttributeArgMorph) ifTrue: [
			m refresh ]]
]

{ #category : #'event handling' }
BlockMorph >> rejectDropEvent: evt [
	"we should only reject drops if they're not blocks, variables, etc. Should check it out better"
	^false
]

{ #category : #byob }
BlockMorph >> resumeProcess [
	"Called on the top block of a running stack when all processes are stopped."

	phratchProc ifNotNil: [phratchProc resume].

]

{ #category : #'event handling' }
BlockMorph >> rightButtonMenu [

	| menu choice |
	menu := MenuMorphNG new defaultTarget: self.
	menu add: 'help' value: #presentHelpScreen.

	(owner isPhratchBlockPaletteMorph) ifFalse: [
		menu addLine.
		menu add: 'duplicate' value: #duplicate.	
		(self owner isBlockMorph) ifFalse: [  "we can't yet delete a blocks inside a script"
			menu add: 'delete' value: #delete].
		menu add: 'show algorithm' value: #showCodeString.	
		].
	
	"DebugMenu ifTrue: [
		menu addLine.
		menu add: 'show tuples' value: #showTuples]."
	
	menu localize; invokeModal.
	choice := menu selectedValue ifNil: [^ self].
	self perform: choice.


]

{ #category : #'dropping/grabbing' }
BlockMorph >> rootForGrabOf: aMorph [
	"Allow myself to be extracted."

	(owner notNil and: [owner isPartsBin])

		ifTrue: [^ super rootForGrabOf: aMorph]
		ifFalse: [^ self].

]

{ #category : #accessing }
BlockMorph >> selector [
	"Overridden by blocks which have selector."

	^ false

]

{ #category : #'dropping/grabbing' }
BlockMorph >> shouldDropOnMouseUp [
	^true
]

{ #category : #accessing }
BlockMorph >> showCodeString [
	"Answer a human-readable string representing the code for this block sequence."

	(Workspace
		openContents:
			'"Generated code from your blocks"'
			, String cr ,
			self codeString
			)
		label: 'Generated from Phratch!'.
		
	
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

{ #category : #'dropping/grabbing' }
BlockMorph >> slideBackToFormerSituation: evt [

	| wasEmbedded o pane oldP slideForm startPoint s |
	wasEmbedded := false.
	(o := evt hand formerOwner) ifNil: [^ self].
	(o isBlockMorph) ifTrue: [
		wasEmbedded := true.
		(pane := o ownerOrYourselfThatIsAPhratchScriptsMorph) ifNotNil: [
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
	s := o ownerOrYourselfThatIsAScrollFrameMorph.
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

{ #category : #private }
BlockMorph >> tabFields [

	| fields nxt nxtFields |
	fields := OrderedCollection new.
	self nonControlFlowSubmorphs do: [:m |
		(m isExpressionArgMorph)
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
	[(m owner isBlockMorph) and: [(m owner isReporterBlockDropTargetMorph) not]] whileTrue: [m := m owner].
	^ m

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

	| c  |
	oldColor ifNotNil: [color := oldColor].
	c := FormCanvas extent: self fullBounds extent depth: 32.
	c := c copyOffset: self topLeft negated.
	self drawOn: c.
	self drawSubmorphsOn: c.
	cachedForm := c form.
	lastLayoutTime := Time millisecondClockValue.

]

{ #category : #accessing }
BlockMorph >> yThresh [
	
	^ 14
]
