Class {
	#name : #MultiArgReporterBlockMorph,
	#superclass : #ReporterBlockMorph,
	#instVars : [
		'addElementMorph',
		'removeElementMorph',
		'minArgs',
		'maxArgs'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #utilities }
MultiArgReporterBlockMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec [
	
	|block selector|
	selector := (spec at: 3) asSymbol.
	
	block := self new.
	(#(#doCallBlockWithArgs #doReport) includes: selector)
		ifTrue: [ block minArgs: 1 ].
	block isSpecialForm: true.
	^block
]

{ #category : #adding }
MultiArgReporterBlockMorph >> addItem [
	self stop.
	self commandSpec: commandSpec, ' $String$'
]

{ #category : #private }
MultiArgReporterBlockMorph >> addLabel [

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
MultiArgReporterBlockMorph >> adjustInputParadigm: choice [
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
MultiArgReporterBlockMorph >> adjustInternals [
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
MultiArgReporterBlockMorph >> evaluate [
	"Evalue this block with the given argument list."

	self start.
	phratchProc stepUntilDoneFor: (receiver ownerOrYourselfThatIsAPhratchStageMorph).
	^phratchProc answer	
]

{ #category : #evaluation }
MultiArgReporterBlockMorph >> evaluateWithArgs: rawArgs [
	"Evalue this block with the given argument list."

	self start.
	phratchProc stepUntilDoneFor: (receiver ownerOrYourselfThatIsAPhratchStageMorph).
	^phratchProc answer	
]

{ #category : #'byob lambdas' }
MultiArgReporterBlockMorph >> fixBlockLayoutWrap [
	"Update the positions of my submorphs."

	| parts lines line h x y minXForArgs w space left maxX maxHeight extraSpace mh |
	(#(#function #functionWithArgs #doReport #doCallWithArgs #doCallBlockWithArgs) includes: selector)
		ifTrue: [ 
			self
				updateIsBoolean;
				layoutChanged ].
	blockLayoutNeeded
		ifFalse: [ ^ self ].
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
					(x - left > 300 and: [ m ~~ parts last ])
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
					(m right - left > 300 and: [ line isEmpty not and: [ m ~~ parts last ] ])
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
						and: [ m isBlockTemplate or: [ ((m isCArgSlotMorph) or: [ m isOSlotMorph ]) and: [ m isEmptySlot not ] ] ])
						ifTrue: [ m height + 10 ]
						ifFalse: [ m height + 2 ].
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
			(m isCArgSlotMorph)
				ifTrue: [ m width: w - (extraSpace * 2) + 6 ] ].
	(parts last isCArgSlotMorph)
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

{ #category : #accessing }
MultiArgReporterBlockMorph >> helpScreenName [
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	selector ifNil: [^nil].
	(selector beginsWith: 'doCall')
		ifTrue: [^'doCall'].
	(selector beginsWith: 'doReport')
		ifTrue: [^'doCall'].
	^super helpScreenName

]

{ #category : #accessing }
MultiArgReporterBlockMorph >> minArgs [
	^minArgs ifNil: [minArgs := 0]
]

{ #category : #accessing }
MultiArgReporterBlockMorph >> minArgs: anInteger [
	minArgs := anInteger
]

{ #category : #'byob lambdas' }
MultiArgReporterBlockMorph >> mouseDown: evt [
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
MultiArgReporterBlockMorph >> removeItem [
	self stop.
	argMorphs size > self minArgs ifTrue: [
		self commandSpec: (commandSpec copyFrom: 1 to: commandSpec size - 3) ]
]

{ #category : #other }
MultiArgReporterBlockMorph >> showValue [
	| gotError msg tooltip w worldBounds |
	gotError := false.
	[ 
	self start.
	phratchProc stepUntilDoneFor: (receiver ownerOrYourselfThatIsAPhratchStageMorph).
	msg := phratchProc answer ]
		ifError: [ 
			gotError := true.
			msg := 'Error!'. PhratchError error ].
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
