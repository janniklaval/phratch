Class {
	#name : #ReporterBlockMorph,
	#superclass : #CommandBlockMorph,
	#instVars : [
		'isBoolean',
		'stepTimeForWatcher'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #other }
ReporterBlockMorph >> acceptsTypeOf: aBlockMorph [
	"Answer true if I can accept a dropped reporter of the given type. Answer false by default."

	aBlockMorph isReporter ifFalse: [^ false].
	self isBlockTemplate ifTrue: [^ false ].
	(owner isCustomCommandBlockMorph) ifTrue: [
		owner isTemplate ifTrue: [^false]].
	^ (aBlockMorph isBooleanReporter = self isBooleanReporter  and: [(aBlockMorph isColorBlockMorph) not]) or: [
		aBlockMorph isAbstractFunctionCall ]
]

{ #category : #'byob lambdas' }
ReporterBlockMorph >> asLambda [

	| lambda |
	lambda := ReporterScriptBlockMorph new
		receiver: ScriptablePhratchMorph new;
		isSpecialForm: false;
		minArgs: 1;
		commandSpec: '$String$';
		selector: #function;
		yourself.
	lambda replaceArgMorph: (lambda argumentAt: 1) by: self fullCopy.
	^lambda evaluate
]

{ #category : #'byob lambdas' }
ReporterBlockMorph >> bodyLeft [

	^ self left + (self height // 2)

]

{ #category : #'byob lambdas' }
ReporterBlockMorph >> bodyRight [

	^ self right - (self height // 2)

]

{ #category : #'byob lambdas' }
ReporterBlockMorph >> bodyRight: x [
	"change my width, don't move"

	self width: self width + (x - self bodyRight)

]

{ #category : #other }
ReporterBlockMorph >> computeHighlightColors [

	| h s v |
	h := color hue.
	s := color saturation.
	v := color brightness.
	highlightColor1 := Color h: h s: (s - 0.13) v: (v + 0.17).
	highlightColor2 := Color h: h s: s v: (v + 0.06).
	shadowColor := color mixed: 0.8 with: Color black.

]

{ #category : #watcher }
ReporterBlockMorph >> createWatcher [
	"Return a new watcher for me."

	| newWatcher |
	newWatcher := WatcherMorph new setCategoryColor: self color.
	newWatcher stepTime: self stepTimeForWatcher.
	self argumentCount = 1
		ifTrue: [newWatcher target: receiver selector: selector parameter: self args first]
		ifFalse: [newWatcher target: receiver selector: selector parameter: nil].

	^ newWatcher

]

{ #category : #'byob lambdas' }
ReporterBlockMorph >> declaredType [

	(owner isCommandBlockMorph) ifTrue: [
		^ owner typeOfArg: self ].
	^ nil
]

{ #category : #drawing }
ReporterBlockMorph >> drawBooleanOn: aCanvas [ 

	| right topY bottomY xInset c l t cArgs relevant |
	self computeHighlightColors.

	l := OrderedCollection new.

	right := self width.
	topY := bottomY := self height // 2.
	self height even ifTrue: [topY := bottomY - 1].
	xInset := 0.
	[topY >= 0] whileTrue: [
		topY = 0 ifTrue: [c := highlightColor1].
		topY = 1 ifTrue: [c := highlightColor2].
		topY > 1 ifTrue: [c := color].
		self addHLineFrom: xInset to: right - xInset y: topY color: c to: l.
		(topY > 1) & (xInset > 0) ifTrue: [
			self addPoint: xInset@topY color: highlightColor1 to: l.
			self addPoint: (right - xInset - 1)@topY color: shadowColor to: l.].

		c := bottomY = (self height - 1) ifTrue: [shadowColor] ifFalse: [color].
		self addHLineFrom: xInset to: right - xInset y: bottomY color: c to: l.
		xInset > 0 ifTrue: [
			self addPoint: xInset@bottomY color: shadowColor to: l.
			self addPoint: (right - xInset - 1)@bottomY color: shadowColor to: l].

		xInset := xInset + 1.	
		bottomY := bottomY + 1.
		topY := topY - 1].

	cArgs := self nonControlFlowSubmorphs select: [:s | 
		(s isCArgSlotMorph) 
		or: [(s isCReporterSlotMorph)
		or: [(s isMultiArgMorph) 
			and: [#(loop reporterSlot) includes: s type]]]].

			cArgs do: [:ca |
				relevant := ca bounds.
				(ca isMultiArgMorph) ifTrue: [
					relevant := ca transparentRect].
				t := OrderedCollection new.
				l do: [:pair |
					self addAreasOf: pair first outside: (relevant insetBy: 3) color: pair second to: t].
			l := t].
	
	l do: [:pair |
		aCanvas fillRectangle: pair first color: pair second ].

]

{ #category : #drawing }
ReporterBlockMorph >> drawNumericOn: aCanvas [ 

	| right topY bottomY radius xInset c l t cArgs relevant |
	self computeHighlightColors.

	l := OrderedCollection new.

	right := self width.
	topY := bottomY := radius := self height // 2.
	self height even ifTrue: [topY := bottomY - 1].
	[topY >= 0] whileTrue: [
		xInset := radius - (radius squared - (radius - topY - 1) squared) sqrt rounded.

		topY = 0 ifTrue: [c := highlightColor1].
		topY = 1 ifTrue: [c := highlightColor2].
		topY > 1 ifTrue: [c := color].
		self addHLineFrom: xInset to: right - xInset y: topY color: c to: l.
		(xInset > 0) & (topY > 1) ifTrue: [
			self addPoint: xInset@topY color: highlightColor1 to: l.
			self addPoint: (right - xInset - 1)@topY color: highlightColor1 to: l].

		c := bottomY = (self height - 1) ifTrue: [shadowColor] ifFalse: [color].
		self addHLineFrom: xInset to: right - xInset y: bottomY color: c to: l.
		xInset > 0 ifTrue: [
			self addPoint: xInset@bottomY color: shadowColor to: l.
			self addPoint: (right - xInset - 1)@bottomY color: shadowColor to: l].

		bottomY := bottomY + 1.
		topY := topY - 1].
	
	cArgs := self nonControlFlowSubmorphs select: [:s | 
		(s isCArgSlotMorph) 
		or: [(s isCReporterSlotMorph)
		or: [(s isMultiArgMorph) 
			and: [#(loop reporterSlot) includes: s type]]]].

			cArgs do: [:ca |
				relevant := ca bounds.
				(ca isMultiArgMorph) ifTrue: [
					relevant := ca transparentRect].
				t := OrderedCollection new.
				l do: [:pair |
					self addAreasOf: pair first outside: (relevant insetBy: 3) color: pair second to: t].
			l := t].
	
	l do: [:pair |
		aCanvas fillRectangle: pair first color: pair second ].

]

{ #category : #drawing }
ReporterBlockMorph >> drawOn: aCanvas [ 

	self contrastColor.

	self computeHighlightColors.
	isBoolean
		ifTrue: [self drawBooleanOn: aCanvas]
		ifFalse: [self drawNumericOn: aCanvas].

	self drawInlinePaletteOn: aCanvas

]

{ #category : #other }
ReporterBlockMorph >> fixBlockLayout [
	"Update the positions of my submorphs."

	| mList maxH h x y |
	blockLayoutNeeded ifFalse: [^ self].
	cachedForm := nil.
	cachedFeedbackForm := nil.

	mList := self nonControlFlowSubmorphs.
	maxH := 0.
	mList do: [:m |
		(m isArgMorph) ifTrue: [m fixArgLayout].
		(m isBlockMorph) ifTrue: [m fixBlockLayout].
		maxH := maxH max: m height].
	h := (maxH + 4) max: 17.

	x := isBoolean ifTrue: [8] ifFalse: [4].
	(mList size > 0 and: [mList first isStringMorph]) ifTrue: [x := x + 2].

	mList do: [:m |
		(m isStringMorph) ifTrue: [m color: self labelColor].
		y := (h - m height) // 2.
		m position: self position + (x@y).
		x := x + m width + 3].
	x := x + (isBoolean ifTrue: [1] ifFalse: [-3]).

	self extent: (x + 4) @ h.
	(self ownerThatIsA: PhratchBlockPaletteMorph) ifNotNil: [
		(self ownerThatIsA: PhratchBlockPaletteMorph) fixLayout].

]

{ #category : #'byob lambdas' }
ReporterBlockMorph >> fixBlockLayoutNoWrap [
	"Update the positions of my submorphs."

	| mList maxH h x y argH |

	(#(function functionWithArgs doReport doCallWithArgs doCallBlockWithArgs) includes: selector) ifTrue: [
		self updateIsBoolean; layoutChanged].

	blockLayoutNeeded ifFalse: [^ self].
	cachedForm := nil.
	cachedFeedbackForm := nil.

	mList := self nonControlFlowSubmorphs.
	maxH := 0.
	mList do: [:m |
		argH := nil.
		(m isArgMorph) ifTrue: [
			m fixArgLayout.
			argH := m height].
		(m isBlockMorph) ifTrue: [
			m fixBlockLayout.
			argH := m height.
			m isBlockTemplate ifTrue: [
				argH := argH + 4]].
			argH ifNil: [argH := m height].
		
		maxH := maxH max: argH].
	h := (maxH + 4) max: 17.

	x := isBoolean ifTrue: [8] ifFalse: [4].
	(mList size > 0 and: [mList first isStringMorph]) ifTrue: [x := x + 2].

	mList do: [:m |
		(m isStringMorph) 
			ifTrue: [(m isBlockLabelFragmentMorph) 
				ifFalse: [m color: self labelColor]].

		y := (h - m height) // 2.
		m position: self position + (x@y).
		x := x + m width + 3].
	x := x + (isBoolean ifTrue: [1] ifFalse: [-3]).

	self extent: (x + 4) @ h.
	(self ownerOrYourselfThatIsAPhratchBlockPaletteMorph) ifNotNil: [
		(self ownerOrYourselfThatIsAPhratchBlockPaletteMorph) fixLayout].


]

{ #category : #'byob lambdas' }
ReporterBlockMorph >> fixBlockLayoutWrap [
	"Update the positions of my submorphs."

	| parts lines line h x y minXForArgs w space left maxX maxHeight extraSpace mh |
	(#(#function #functionWithArgs #doReport #doCallWithArgs #doCallBlockWithArgs) includes: selector)
		ifTrue: [ 
			self
				updateIsBoolean;
				layoutChanged ].
	(self isCustomBlock and: [ self isTemplate ])
		ifTrue: [ ^ self fixBlockLayoutNoWrap ].
	blockLayoutNeeded
		ifFalse: [ ^ self ].
	cachedForm := nil.
	cachedFeedbackForm := nil.
	parts := self nonControlFlowSubmorphs.
	parts isEmpty
		ifTrue: [ ^ self ].
	lines := OrderedCollection new.	"distribute parts horizontally and cut up into lines"
	line := OrderedCollection new.
	x := self left + 5.
	left := x.
	maxX := x.
	minXForArgs := self left.
	space := 4.
	parts
		do: [ :m | 
			((m isCArgSlotMorph)
				or: [ (m isCReporterSlotMorph) or: [ (m isMultiArgMorph) and: [ m isWrapping ] ] ])
				ifTrue: [ 
					line isEmpty
						ifFalse: [ lines add: line ].
					m left: self left - 5.
					lines add: (OrderedCollection with: m).
					(m isMultiArgMorph)
						ifTrue: [ m fixArgLayout ]
						ifFalse: [ m fixBlockLayout ].
					((m isCArgSlotMorph) or: [ m isCReporterSlotMorph ])
						ifTrue: [ m width: 40 ].
					line := OrderedCollection new.
					maxX := maxX max: left + m width.
					x := left ]
				ifFalse: [ 
					x - left > 300
						ifTrue: [ 
							lines add: line.
							line := OrderedCollection new.
							x := left ].
					(m isBlockMorph)
						ifTrue: [ m fixBlockLayout ].
					(m isArgMorph)
						ifTrue: [ m fixArgLayout ].
					(m isStringMorph)
						ifTrue: [ m color: self labelColor ]
						ifFalse: [ x := x max: minXForArgs ].
					m left: x.
					(m right - left > 300 and: [ line isEmpty not ])
						ifTrue: [ 
							lines add: line.
							line := OrderedCollection new.
							m left: left.
							line add: m.
							x := left ]
						ifFalse: [ line add: m ].
					x := x + m fullBounds width + space.
					maxX := maxX max: x ] ].
	x = left
		ifFalse: [ lines add: line ].
	w := maxX - self left max: 4.	"distribute lines vertically"
	space := 1.
	y := self top.	"+ 2"	"+ space"
	lines
		do: [ :eachLine | 
			maxHeight := 14.
			eachLine
				do: [ :m | 
					mh := ((m isReporterBlockMorph)
						and: [ 
							m isBlockTemplate
								or: [ 
									((m isCArgSlotMorph) or: [ m isOSlotMorph ])
										and: [ (m isCReporterSlotMorph) not and: [ m isEmptySlot not ] ] ] ])
						ifTrue: [ m height + 10 ]
						ifFalse: [ 
							((m isCArgSlotMorph) or: [ (m isOSlotMorph) and: [ (m isCReporterSlotMorph) not ] ])
								ifTrue: [ m height + 4 ]
								ifFalse: [ m height + 2 ] ].
					maxHeight := mh max: maxHeight ].
			eachLine do: [ :m | m top: y + ((maxHeight - m height) // 2) + 1 ].
			y := y + maxHeight + space ].
	h := y - self top + space.	"adjust lines to round / hex shape"
	extraSpace := 0.
	lines size > 1
		ifTrue: [ extraSpace := h // 2 ]
		ifFalse: [ 
			isBoolean
				ifTrue: [ extraSpace := h // 3 ] ].
	parts do: [ :m | m left: m left + extraSpace ].
	w := w + (extraSpace * 2).	"adjust CArgSlots"
	parts
		do: [ :m | 
			((m isCArgSlotMorph) or: [ m isCReporterSlotMorph ])
				ifTrue: [ m width: w - (extraSpace * 2) + 6 ] ].
	((parts last isCArgSlotMorph) or: [ parts last isCReporterSlotMorph ])
		ifTrue: [ h := h + space + 5 ].	"stack nested Reporters more efficiently:"
	lines size > 1
		ifTrue: [ 
			self height: h.
			lines
				do: [ :l | 
					| offset |
					offset := ((l first respondsTo: #bodyLeft) and: [ (isBoolean and: [ l first isBooleanReporter not ]) not ])
						ifTrue: [ l first bodyLeft - self bodyLeft ]
						ifFalse: [ l first left - self bodyLeft ].
					l
						do: [ :m | 
							self isBooleanReporter
								ifTrue: [ m left: m left - offset + 2 ]
								ifFalse: [ m left: m left - offset ] ] ].
			maxX := self left + 5.
			lines
				do: [ :l | 
					maxX := ((l last respondsTo: #bodyRight) and: [ (isBoolean and: [ l last isBooleanReporter not ]) not ])
						ifTrue: [ maxX max: l last bodyRight ]
						ifFalse: [ maxX max: l last right ] ].
			self isBooleanReporter
				ifTrue: [ self bodyRight: maxX + 2 ]
				ifFalse: [ self bodyRight: maxX ].	"adjust Multi-CArgSlots"
			parts
				do: [ :m | 
					(m isMultiArgMorph)
						ifTrue: [ m loopsWidth: self bodyRight - self bodyLeft ] ] ]
		ifFalse: [ self extent: w @ h ].
	(self ownerOrYourselfThatIsAPhratchBlockPaletteMorph)
		ifNotNil: [ (self ownerOrYourselfThatIsAPhratchBlockPaletteMorph) fixLayout ]
]

{ #category : #watcher }
ReporterBlockMorph >> getAssociatedSprite [
	"Return my receiver."

	^ receiver

]

{ #category : #initialization }
ReporterBlockMorph >> initialize [

	super initialize.
	isBoolean := false.
	stepTimeForWatcher := 100.
	self extent: 80@20.

]

{ #category : #'byob lambdas' }
ReporterBlockMorph >> isAbstractFunctionCall [

	^ #(doCustomBlock doReport doCallWithArgs doCallBlockWithArgs doCallBlockWithArgList getLine:ofList: get:) includes: selector

]

{ #category : #other }
ReporterBlockMorph >> isBoolean: aBoolean [

	isBoolean := aBoolean.

]

{ #category : #other }
ReporterBlockMorph >> isBooleanReporter [

	^ isBoolean

]

{ #category : #other }
ReporterBlockMorph >> isReporter [
	"Answer true if this block reports a value."

	^ true

]

{ #category : #testing }
ReporterBlockMorph >> isReporterBlockMorph [

	^ true
]

{ #category : #'byob lambdas' }
ReporterBlockMorph >> lambdaMenu [
	| menu choice |
	menu := MenuMorph new defaultTarget: self.
	(owner isPhratchBlockPaletteMorph)
		ifTrue: [ ^ self ].
	(owner isReporterScriptBlockMorph)
		ifFalse: [ menu add: 'quote' translated action: #lambdafied ].
	(choice := menu
		localize;
		popUpInWorld;
		yourself) ifNotNil: [ self perform: choice ].
	World activeHand showTemporaryCursor: nil
]

{ #category : #'byob lambdas' }
ReporterBlockMorph >> lambdafied [

	| lambda |
	lambda := (ReporterScriptBlockMorph new
		color: (ScriptablePhratchMorph blockColorFor: 'operators');
		receiver: receiver;
		isSpecialForm: false;
		minArgs: 1;
		selector: #function;
		isAtomic: false;
		commandSpec: 'the $String$ block';
		yourself).

	(owner isBlockMorph) ifTrue: [
		owner replaceArgMorph: self by: lambda.
		lambda replaceArgMorph: lambda argMorphs first by: self.
		^lambda].

	owner ifNil: [^lambda].

	lambda position: self position.
	owner addMorph: lambda.
	lambda replaceArgMorph: lambda argMorphs first by: self.
	^lambda
	
	

]

{ #category : #'byob lambdas' }
ReporterBlockMorph >> mouseDown: evt [
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	evt hand newKeyboardFocus: nil.
	evt shiftPressed ifTrue: [
		^ self lambdaMenu].
	super mouseDown: evt
]

{ #category : #'byob lambdas' }
ReporterBlockMorph >> showLambdaValue [
	| gotError msg tooltip w worldBounds zombie |
	gotError := false.
	[ 
	self start.
	zombie := phratchProc.
	phratchProc stepUntilDoneFor: (receiver ownerOrYourselfThatIsAPhratchStageMorph).
	msg := zombie answer ]
		ifError: [ 
			gotError := true.
			msg := 'Error!' ].
	msg := (msg isMorph)
		ifTrue: [ 
			(msg respondsTo: #displayForm)
				ifTrue: [ msg displayForm ]
				ifFalse: [ msg imageForm ] ]
		ifFalse: [ msg asString ].
	(self isBooleanReporter or: [ msg = 'Error!' ])
		ifTrue: [ msg := msg localized ].
	tooltip := (PhratchReporterToolTipMorph string: msg for: self)
		left: self right;
		bottom: self top;
		yourself.
	gotError
		ifTrue: [ tooltip messageColor: Color red darker ].
	w := self world.
	w addMorphFront: tooltip.
	((worldBounds := w bounds) containsRect: tooltip bounds)
		ifFalse: [ tooltip bounds: (tooltip bounds translatedToBeWithin: worldBounds) ].
	self setProperty: #toolTip toValue: tooltip.
	tooltip initialCursorPoint: Sensor cursorPoint.
	tooltip startStepping
]

{ #category : #other }
ReporterBlockMorph >> showValue [
	| gotError msg tooltip w worldBounds |
	(#(#doReport #doMakeNewList #doCallWithArgs #doPauseThreadReporter) includes: selector)
		ifTrue: [ ^ self showLambdaValue ].	"
	(self allMorphs detect: [:m | (m isReporterBlockMorph) and: [m isSpecialForm]] ifNone: [nil])
		isNil ifFalse: [ receiver ifNotNil: [^ self showLambdaValue]].
"
	gotError := false.
	[ msg := self evaluate ]
		ifError: [ 
			gotError := true.
			msg := 'Error!'. PhratchError error ].
	msg := (msg isMorph)
		ifTrue: [ 
			(msg respondsTo: #thumbnailImageForm)
				ifTrue: [ msg thumbnailImageForm ]
				ifFalse: [ msg imageForm ] ]
		ifFalse: [ msg asString ].
	(self isBooleanReporter or: [ msg = 'Error!' ])
		ifTrue: [ msg := msg localized ].
	tooltip := (PhratchReporterToolTipMorph string: msg for: self)
		left: self right;
		bottom: self top;
		yourself.
	gotError
		ifTrue: [ tooltip messageColor: Color red darker ].
	w := self world.
	w ifNil: [ ^ self ].
	w addMorphFront: tooltip.
	((worldBounds := w bounds) containsRect: tooltip bounds)
		ifFalse: [ tooltip bounds: (tooltip bounds translatedToBeWithin: worldBounds) ].
	self setProperty: #toolTip toValue: tooltip.
	tooltip initialCursorPoint: Sensor cursorPoint.
	tooltip startStepping
]

{ #category : #accessing }
ReporterBlockMorph >> stepTimeForWatcher [

	^ stepTimeForWatcher
]

{ #category : #accessing }
ReporterBlockMorph >> stepTimeForWatcher: aValue [

	stepTimeForWatcher := aValue
]

{ #category : #other }
ReporterBlockMorph >> tabFields [

	| fields |
	fields := OrderedCollection new.
	submorphs do: [:m |
		((m isReporterBlockMorph) or: [m isMultiArgMorph]) 
			ifTrue: [fields addAll: m tabFields ]
			ifFalse: [(m isExpressionArgMorph)
				ifTrue: [fields add: m]]].
	^ fields
]

{ #category : #other }
ReporterBlockMorph >> toggleProcess [

	| toolTip |
	toolTip := self valueOfProperty: #toolTip.
	toolTip ifNotNil: [
		toolTip delete.
		self setProperty: #toolTip toValue: nil.
		^ self].

	self showValue.

]

{ #category : #watcher }
ReporterBlockMorph >> toggleWatcher [
	"Toggle between hiding and showing a watcher for this block."

	| frame w palette |
	(frame := self ownerOrYourselfThatIsAPhratchFrameMorph) ifNil: [^ self].
	(w := frame watcherForBlock: self)
		ifNil: [frame showWatcher: self createWatcher]
		ifNotNil: [w delete].
			
	palette := self ownerOrYourselfThatIsAPhratchBlockPaletteMorph.
	palette ifNotNil: [palette updateWatcherButtonsForFrame: frame].

]

{ #category : #'byob lambdas' }
ReporterBlockMorph >> updateIsBoolean [

	| arg |
	argMorphs size < 1 ifTrue: [^ self ].
	arg := argMorphs first.

	(arg isReporterBlockMorph) ifFalse: [
		isBoolean := false. ^self].

	arg isBooleanReporter ifTrue: [isBoolean := true. ^self ].

	isBoolean := false

	
]
