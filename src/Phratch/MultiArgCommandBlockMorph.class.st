Class {
	#name : #MultiArgCommandBlockMorph,
	#superclass : #CommandBlockMorph,
	#instVars : [
		'addElementMorph',
		'removeElementMorph',
		'minArgs',
		'maxArgs'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #utilities }
MultiArgCommandBlockMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block := self new.
	block minArgs: 1.
	block isSpecialForm: true.
	^block
]

{ #category : #adding }
MultiArgCommandBlockMorph >> addItem [
	self stop.
	self commandSpec: commandSpec, ' $String$'.



]

{ #category : #private }
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

{ #category : #evaluation }
MultiArgCommandBlockMorph >> adjustInputParadigm: choice [
	"private"

	| newSpec |
	(#(#doRunBlockWithArgs #doRunBlockWithArgList #doForkBlockWithArgs #doForkBlockWithArgList #doCallBlockWithArgs #doCallBlockWithArgList)
		includes: selector)
		ifFalse: [ ^ self ].
	'with inputs' localized = choice
		ifTrue: [ 
			(selector endsWith: 'List')
				ifTrue: [ selector := ((selector copyFrom: 1 to: selector size - 'List' size) , 's') asSymbol ] ].
	'with input list' localized = choice
		ifTrue: [ 
			(selector endsWith: 'List')
				ifFalse: [ selector := ((selector copyFrom: 1 to: selector size - 1) , 'List') asSymbol ] ].
	maxArgs := (selector endsWith: 'List')
		ifTrue: [ 3 ]
		ifFalse: [ nil ].
	newSpec := self receiver blockSpecForSelector: selector.
	newSpec := newSpec localized.
	self commandSpec: newSpec
]

{ #category : #private }
MultiArgCommandBlockMorph >> adjustInternals [
	"private"

	| newSelector sdict newSpec |
	(#(#doRun #doRunBlockWithArgs #doRunBlockWithArgList #doFork #doForkBlockWithArgs #doForkBlockWithArgList #doReport #doCallBlockWithArgs #doCallBlockWithArgList)
		includes: selector)
		ifFalse: [ ^ self ].
	sdict := Dictionary new.
	argMorphs size = 2
		ifTrue: [ 
			((selector endsWith: 'Args') | (selector endsWith: 'List')) not
				ifTrue: [ 
					sdict
						at: #doRun put: #doRunBlockWithArgs;
						at: #doFork put: #doForkBlockWithArgs;
						at: #doReport put: #doCallBlockWithArgs ]
				ifFalse: [ 
					sdict
						at: #doRunBlockWithArgs put: #doRun;
						at: #doRunBlockWithArgList put: #doRun;
						at: #doForkBlockWithArgs put: #doFork;
						at: #doForkBlockWithArgList put: #doFork;
						at: #doCallBlockWithArgs put: #doReport;
						at: #doCallBlockWithArgList put: #doReport ] ].
	receiver ifNil: [ ^ self ].
	newSelector := sdict at: selector ifAbsent: [ selector ].
	newSelector = selector
		ifTrue: [ ^ self ].
	selector := newSelector.
	maxArgs := (selector endsWith: 'List')
		ifTrue: [ 3 ]
		ifFalse: [ nil ].
	newSpec := self receiver blockSpecForSelector: selector.
	newSpec := newSpec localized.
	self commandSpec: newSpec
]

{ #category : #evaluation }
MultiArgCommandBlockMorph >> argumentAt: index [
	"Returns the argument morph at the given index."

	^argMorphs at: index.	"custom blocks don't need argPermutations"


]

{ #category : #byob }
MultiArgCommandBlockMorph >> fixBlockLayoutWrap [
	"Update the positions of my submorphs."

	| parts lines line h x y minXForArgs nextB w space left maxX maxHeight mh |
	blockLayoutNeeded
		ifFalse: [ ^ self ].
	parts := self nonControlFlowSubmorphs.
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
					m left: left.	"self"
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
					(x - left > 400 and: [ m ~~ parts last ])
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
					(m fullBounds right - left > 400 and: [ line isEmpty not and: [ m ~~ parts last ] ])
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
	w := maxX - self left max: 37.	"distribute lines vertically"
	space := 2.
	y := self top + 2.	"4"	"space"
	lines
		do: [ :eachLine | 
			maxHeight := 14.
			eachLine
				do: [ :m | 
					mh := ((m isReporterBlockMorph)
						and: [ m isBlockTemplate or: [ ((m isCArgSlotMorph) or: [ m isOSlotMorph ]) and: [ m isEmptySlot not ] ] ])
						ifTrue: [ m height + 5 ]
						ifFalse: [ m height ].
					maxHeight := mh max: maxHeight.
					(m isCArgSlotMorph)
						ifTrue: [ maxHeight := m height - 4 ] ].
			eachLine do: [ :m | m top: y + ((maxHeight - m height) // 2) + 1 ].
			y := y + maxHeight + space ].	"adjust CArgSlots"
	parts
		do: [ :m | 
			((m isCArgSlotMorph) or: [ m isCReporterSlotMorph ])
				ifTrue: [ m width: w - 5 ] ].
	h := self isStop
		ifTrue: [ y - self top + space ]
		ifFalse: [ y - self top + space + 4 ].
	(parts last isCArgSlotMorph)
		ifTrue: [ h := h + space + 5 ].
	self extent: w @ h.	"adjust Multi-CArgSlots"
	parts
		do: [ :m | 
			(m isMultiArgMorph)
				ifTrue: [ m loopsWidth: w - 5 ] ].
	(nextB := self nextBlock)
		ifNotNil: [ 
			nextB position: self left @ (self bottom - 4).
			nextB fixBlockLayout ]
]

{ #category : #accessing }
MultiArgCommandBlockMorph >> helpScreenName [
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	selector ifNil: [^nil].
	(selector beginsWith: 'doRun')
		ifTrue: [^'doRun'].
	(selector beginsWith: 'doFork')
		ifTrue: [^'doFork'].
	^super helpScreenName

]

{ #category : #testing }
MultiArgCommandBlockMorph >> isMultiArgCommandBlockMorph [

	^ true
]

{ #category : #accessing }
MultiArgCommandBlockMorph >> minArgs [
	^minArgs ifNil: [minArgs := 0]
]

{ #category : #accessing }
MultiArgCommandBlockMorph >> minArgs: anInteger [
	minArgs := anInteger
]

{ #category : #'event handling' }
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

{ #category : #deleting }
MultiArgCommandBlockMorph >> removeItem [
	self stop.
	argMorphs size > self minArgs ifTrue: [
		self commandSpec: (commandSpec copyFrom: 1 to: commandSpec size - 3) ].

]
