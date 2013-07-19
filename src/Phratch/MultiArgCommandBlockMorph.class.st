Class {
	#name : #MultiArgCommandBlockMorph,
	#superclass : #CommandBlockMorph,
	#instVars : [
		'addElementMorph',
		'removeElementMorph',
		'minArgs',
		'maxArgs'
	],
	#category : #'Phratch-BYOB'
}

{ #category : #'as yet unclassified' }
MultiArgCommandBlockMorph >> addItem [
	self stop.
	self commandSpec: commandSpec, ' $String$'.



]

{ #category : #'as yet unclassified' }
MultiArgCommandBlockMorph >> addLabel [

	super addLabel.
	removeElementMorph := ImageMorph new form: (ArgMorph dropDownMenuForm rotateBy: 90).
	argMorphs size > self minArgs ifTrue: [
		self addMorphBack: removeElementMorph].	
	addElementMorph := ImageMorph new form: (ArgMorph dropDownMenuForm rotateBy: -90).

	(selector = #doMakeNewList or: [
		((selector notNil and: [selector endsWith: 'List']) not
			and: [ maxArgs isNil or: [argMorphs size < maxArgs]])]) 
				ifTrue: [ self addMorphBack: addElementMorph].

	self adjustInternals
]

{ #category : #'as yet unclassified' }
MultiArgCommandBlockMorph >> adjustInputParadigm: choice [
	"private"

	| newSpec |

	(#(doRunBlockWithArgs doRunBlockWithArgList doForkBlockWithArgs doForkBlockWithArgList doCallBlockWithArgs doCallBlockWithArgList)
		includes: selector) ifFalse: [^ self ].

	'with inputs' localized = choice ifTrue: [ 
		(selector endsWith: 'List') ifTrue: [
			selector := ((selector copyFrom: 1 to: selector size - 'List' size), 's') asSymbol]].
	'with input list' localized = choice ifTrue: [
		(selector endsWith: 'List') ifFalse: [
			selector := ((selector copyFrom: 1 to: selector size - 1), 'List') asSymbol ]].
	(selector endsWith: 'List') 
		ifTrue: [maxArgs := 3]
		ifFalse: [maxArgs := nil].		
	newSpec := self receiver blockSpecForSelector: selector.
	newSpec := newSpec localized. 
	self commandSpec: newSpec.






]

{ #category : #'as yet unclassified' }
MultiArgCommandBlockMorph >> adjustInternals [
	"private"

	| newSelector sdict newSpec |
	(#(		
			doRun
			doRunBlockWithArgs 
			doRunBlockWithArgList 
			doFork doForkBlockWithArgs 
			doForkBlockWithArgList 
			doReport 
			doCallBlockWithArgs 
			doCallBlockWithArgList)
		includes: selector) ifFalse: [^ self ].

	sdict := Dictionary new.
	argMorphs size = 2  ifTrue: [ 
		((selector endsWith: 'Args') |  (selector endsWith: 'List')) not 
			ifTrue: [
				sdict
					at: #doRun put: #doRunBlockWithArgs;
					at: #doFork put: #doForkBlockWithArgs;
					at: #doReport put: #doCallBlockWithArgs;
					yourself]
			ifFalse: [
				sdict
					at: #doRunBlockWithArgs put: #doRun;
					at: #doRunBlockWithArgList put: #doRun;
					at: #doForkBlockWithArgs put: #doFork;
					at: #doForkBlockWithArgList put: #doFork;
					at: #doCallBlockWithArgs put: #doReport;
					at: #doCallBlockWithArgList put: #doReport;
					yourself]].

	receiver ifNil: [^ self ].
	newSelector := sdict at: selector ifAbsent: [ selector].
	newSelector = selector ifTrue: [^ self].
	selector := newSelector.
	(selector endsWith: 'List') 
		ifTrue: [ maxArgs := 3]
		ifFalse: [maxArgs := nil].		
	newSpec := self receiver blockSpecForSelector: selector.
	newSpec := newSpec localized.
	self commandSpec: newSpec.

]

{ #category : #'as yet unclassified' }
MultiArgCommandBlockMorph >> argumentAt: index [
	"Returns the argument morph at the given index."

	^argMorphs at: index.	"BYOB custom blocks don't need argPermutations"


]

{ #category : #'as yet unclassified' }
MultiArgCommandBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	| blockTuple arg val eval |
	
	blockTuple := Array new: argMorphs size + 3.
	blockTuple
		at: 1 put: #byob;
		at: 2 put: self rcvr;
		at: 3 put: selector.

	1 to: argMorphs size do: [:i |
		arg := argMorphs at: i.
		(arg isKindOf: ArgMorph) | (arg isKindOf: EventTitleMorph)
			ifTrue: [((arg isKindOf: CSlotMorph) or: [arg isKindOf: OSlotMorph])
				ifTrue: [blockTuple at: i + 3 put: arg asBlockTuple]
				ifFalse: [(arg isKindOf: ExpressionArgMorph)
					ifTrue: [
						val := arg getExpression.
						arg isNumberExpression
							ifTrue: [val = ' '
								ifTrue: [eval := val]
								ifFalse: [eval := val asNumberNoError]]
							ifFalse: [eval := arg evaluate]]
					ifFalse: [eval := arg evaluate].
					blockTuple at: i + 3 put: eval]]
			ifFalse: [blockTuple at: i + 3 put: arg asBlockTuple]].
	^ blockTuple

]

{ #category : #'as yet unclassified' }
MultiArgCommandBlockMorph >> fixBlockLayoutWrap [
	"Update the positions of my submorphs."

	| parts lines line h x y minXForArgs nextB w space left maxX maxHeight mh |

	blockLayoutNeeded ifFalse: [^ self].

	cachedForm := nil.
	cachedFeedbackForm := nil.

	parts := self nonControlFlowSubmorphs.
	lines := OrderedCollection new.


	"distribute parts horizontally and cut up into lines"

	line := OrderedCollection new.
	x := self left + 5.
	left := x.
	maxX := x.
	minXForArgs := self left.
	space := 4.

	parts do: [:m |
	((m isKindOf: CArgSlotMorph) or: [(m isKindOf: CReporterSlotMorph) or: [(m isKindOf: MultiArgMorph) and: [m isWrapping]]])
		ifTrue: [ 
			line isEmpty ifFalse: [
				lines add: line].
			m left: "self" left.
			lines add: (OrderedCollection with: m).
			(m isKindOf: MultiArgMorph)
				ifTrue: [m fixArgLayout]
				ifFalse: [m fixBlockLayout].
			((m isKindOf: CArgSlotMorph) or: [m isKindOf: CReporterSlotMorph])
				ifTrue: [m width: 40].
			line := OrderedCollection new.
			maxX := maxX max: left + m width.
			x := left ]
		ifFalse: [
			(x - left > 400 and: [m ~~ parts last]) ifTrue: [
				lines add: line.
				line := OrderedCollection new.
				x := left].
			(m isKindOf: BlockMorph) ifTrue: [m fixBlockLayout].
			(m isKindOf: ArgMorph) ifTrue: [m fixArgLayout].
			(m isKindOf: StringMorph)
				ifTrue: [m color: self labelColor]
				ifFalse: [x := x max: minXForArgs].

			m left: x.
			(m fullBounds right - left > 400 and: [line isEmpty not and: [m ~~ parts last]])
				ifTrue: [
					lines add: line.
					line := OrderedCollection new.
					m left: left.
					line add: m.
					x := left]
				ifFalse: [ line add: m].
				x := x + m fullBounds width + space.
			maxX := maxX max: x]].
	x = left ifFalse: [
		lines add: line].
	w := maxX - self left max: 37.

	"distribute lines vertically"

	space := 2.
	y := self top + 2 "4" "space".
	lines do: [:eachLine |
		maxHeight := 14.
		eachLine do: [:m |
			((m isKindOf: ReporterBlockMorph)
			and: [m isBlockTemplate 
			or: [((m isKindOf: CArgSlotMorph) or: [m isKindOf: OSlotMorph]) and: [m isEmptySlot not]] ])
				ifTrue: [mh := m height + 5]
				ifFalse: [mh := m height].
			maxHeight := mh max: maxHeight.
			(m isKindOf: CArgSlotMorph) ifTrue: [
				maxHeight := m height - 4]].
		eachLine do: [:m |
			m top: y + (maxHeight - m height // 2) + 1].
		y := y + maxHeight + space].

	"adjust CArgSlots"

	parts do: [:m |
		((m isKindOf: CArgSlotMorph) or: [m isKindOf: CReporterSlotMorph])
			ifTrue: [m width: w - 5]].

	self isStop
		ifTrue: [h := y - self top + space]
		ifFalse: [h := y - self top + space + 4.].

	(parts last isKindOf: CArgSlotMorph) ifTrue: [
		h := h + space + 5].
	
	self extent: w @ h.

	"adjust Multi-CArgSlots"

	parts do: [:m | (m isKindOf: MultiArgMorph)
		ifTrue: [m loopsWidth: w - 5]].

	(nextB := self nextBlock) ifNotNil: [
		nextB position: self left@(self bottom - 4).
		nextB fixBlockLayout].

]

{ #category : #'as yet unclassified' }
MultiArgCommandBlockMorph >> helpScreenName [
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	selector ifNil: [^nil].
	(selector beginsWith: 'doRun')
		ifTrue: [^'doRun'].
	(selector beginsWith: 'doFork')
		ifTrue: [^'doFork'].
	^super helpScreenName

]

{ #category : #'as yet unclassified' }
MultiArgCommandBlockMorph >> maxArgs [
	^ maxArgs
]

{ #category : #'as yet unclassified' }
MultiArgCommandBlockMorph >> maxArgs: anInteger [
	maxArgs := anInteger
]

{ #category : #'as yet unclassified' }
MultiArgCommandBlockMorph >> minArgs [
	^minArgs ifNil: [minArgs := 0]
]

{ #category : #'as yet unclassified' }
MultiArgCommandBlockMorph >> minArgs: anInteger [
	minArgs := anInteger
]

{ #category : #'as yet unclassified' }
MultiArgCommandBlockMorph >> mouseDown: evt [
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	evt hand newKeyboardFocus: nil.
	evt anyButtonPressed ifTrue: [
		(addElementMorph containsPoint: evt cursorPoint)
			ifTrue: [^self addItem ].
		(removeElementMorph containsPoint: evt cursorPoint)
			ifTrue: [^self removeItem ]].
	^super mouseDown: evt
]

{ #category : #'as yet unclassified' }
MultiArgCommandBlockMorph >> removeItem [
	self stop.
	argMorphs size > self minArgs ifTrue: [
		self commandSpec: (commandSpec copyFrom: 1 to: commandSpec size - 3) ].

]
