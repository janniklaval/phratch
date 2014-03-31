Class {
	#name : #CommandScriptBlockMorph,
	#superclass : #ReporterScriptBlockMorph,
	#instVars : [
		'nestedBlock',
		'topBarBottom',
		'blockBottom',
		'stretchHeight'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #'as yet unclassified' }
CommandScriptBlockMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block :=  self new.
	block isSpecialForm: false.
	^block
]

{ #category : #other }
CommandScriptBlockMorph >> acceptsTypeOf: aBlockMorph [
	"Answer true if I can accept a dropped reporter of the given type. Answer false by default."

	((aBlockMorph isCommandBlockMorph) and: [
		(aBlockMorph isHatBlockMorph) not ])
			or: [ super acceptsTypeOf: aBlockMorph]
]

{ #category : #adding }
CommandScriptBlockMorph >> addItem [
	| quoted |
	quoted := nestedBlock.
	super addItem.
	quoted ifNotNil: [
		self attachBlock: quoted ]
]

{ #category : #private }
CommandScriptBlockMorph >> adjustInternals [
	"private"

	| newSelector sdict quoted newSpec |
	(#(#procedure #procedureWithArgs) includes: selector)
		ifFalse: [ ^ self ].
	sdict := argMorphs size > 0
		ifTrue: [ 
			Dictionary new
				at: #procedure put: #procedureWithArgs;
				yourself ]
		ifFalse: [ 
			Dictionary new
				at: #procedureWithArgs put: #procedure;
				yourself ].
	receiver ifNil: [ ^ self ].
	newSelector := sdict at: selector ifAbsent: [ selector ].
	newSelector = selector
		ifTrue: [ ^ self ].
	selector := newSelector.
	quoted := nestedBlock.
	newSpec := self receiver blockSpecForSelector: selector.
	newSpec := newSpec localized.
	self commandSpec: newSpec.
	quoted ifNotNil: [ self attachBlock: quoted ]
]

{ #category : #private }
CommandScriptBlockMorph >> attachBlock: aBlockMorph [
	"Attach the given block to me. Assume the block has been positioned correctly."

	self addMorph: aBlockMorph.
	nestedBlock := aBlockMorph.

]

{ #category : #private }
CommandScriptBlockMorph >> blockAttachPoints: aSet [
	"Answer a collection of possible attachment points for me. Each entry is an Association mapping a point to the morph to which a dropping command block could be attached."

	| result |
	result := #().
	nestedBlock
		ifNil: [ 
			result :=  result copyWith: self topLeft + (12 @ (self topBarHeight + 7)) -> self ]
		ifNotNil: [ nestedBlock blockAttachPoints: aSet ].
	aSet addAll: result
]

{ #category : #byob }
CommandScriptBlockMorph >> blockWidth [
	| maxWidth |
	maxWidth := 0.
	self firstBlockList do: [:b |
		maxWidth := maxWidth max: b blockWidth ].
	^self width max: self bracketThickness + maxWidth
]

{ #category : #accessing }
CommandScriptBlockMorph >> body [
	nestedBlock ifNil: [^nil].
	^nestedBlock fullCopy
]

{ #category : #'byob lambdas' }
CommandScriptBlockMorph >> bodyLeft [
	^self left
]

{ #category : #'byob lambdas' }
CommandScriptBlockMorph >> bodyRight [
	^self fullBounds right
]

{ #category : #accessing }
CommandScriptBlockMorph >> bracketThickness [

	^ CBlockBracketThickness

]

{ #category : #drawing }
CommandScriptBlockMorph >> canBecomeWatcher [
	^false

]

{ #category : #'geometry testing' }
CommandScriptBlockMorph >> containsPoint: aPoint [

	cachedForm ifNil: [self updateCachedForm].
	^ (cachedForm isTransparentAt: aPoint - self fullBounds origin) not 
		and: [self fullBounds containsPoint: aPoint]

]

{ #category : #deleting }
CommandScriptBlockMorph >> deleteVariableTemplate: aVarBlockMorph [

	| quoted |
	quoted := nestedBlock.
	super deleteVariableTemplate: aVarBlockMorph.
	quoted ifNotNil: [
		self attachBlock: quoted ]
]

{ #category : #drawing }
CommandScriptBlockMorph >> drawBottomBarOn: aCanvas [ 

	| left barTop barBottom |

	barBottom := self bottom - 3.
	self drawSmoothBottomEdgeOn: aCanvas.

	barTop := barBottom - (CBlockBracketThickness - 3).
	left := self left + CBlockBracketThickness - 1.

	aCanvas fillRectangle: (left@(barTop - 2) extent: 1@1) color: color.
	aCanvas fillRectangle: (left@(barTop - 1) extent: 2@1) color: color.
	aCanvas fillRectangle: (left@barTop extent: 3@1) color: color.

	aCanvas
		fillRectangle: ((left + 3)@barTop corner: (self right - 2)@(barTop + 1))
		color: highlightColor1.
	aCanvas
		fillRectangle: (self left@(barTop + 1) corner: (self right - 1)@barBottom)
		color: color.
	aCanvas
		fillRectangle: ((self right - 1)@(barTop + 2) corner: self right@barBottom)
		color: shadowColor.

]

{ #category : #drawing }
CommandScriptBlockMorph >> drawInnerTopY: y on: aCanvas [

	| left right gapStart gapEnd |
	left := CBlockBracketThickness - 1.
	right := self width - 1.
	gapStart := left + PuzzleInset + 1.
	gapEnd := gapStart + PuzzleWidth.

	self drawHLineFrom: left to: (right - 1) y: y color: color on: aCanvas.
	self drawHLineFrom: left to: (right - 2) y: y + 1 color: color on: aCanvas.

	"fill in upper-left inside corner"
	self drawHLineFrom: left to: (left + 2) y: y + 2 color: color on: aCanvas.
	self drawHLineFrom: left to: (left + 1) y: y + 3 color: color on: aCanvas.
	self drawPoint: (left + 1)@(y + 3) color: shadowColor on: aCanvas.

	self drawHLineFrom: gapStart to: gapEnd y: y + 2 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 1 to: gapEnd - 1 y: y + 3 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 1 to: gapEnd - 1 y: y + 4 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 2 to: gapEnd - 2 y: y + 5 color: color on: aCanvas.

	self drawHLineFrom: (left + 2) to: gapStart y: y + 2 color: shadowColor on: aCanvas.
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
CommandScriptBlockMorph >> drawOn: aCanvas [
	| c |
	topBarBottom := self top + self topBarHeight.
	blockBottom := self isForever
		ifTrue: [ self bottom - 3 ]
		ifFalse: [ self bottom - 7 ].
	self contrastColor.
	self computeHighlightColors.
	c := FormCanvas extent: self extent depth: 32.
	c := c copyOffset: self topLeft negated.
	self drawTopEdgeOn: c.
	self drawTopBarOn: c.
	self drawVerticalBarOn: c.
	self drawBottomBarOn: c.
	self drawFinalOn: aCanvas fromCanvas: c.
	self drawInlinePaletteOn: aCanvas
]

{ #category : #drawing }
CommandScriptBlockMorph >> drawTopBarOn: aCanvas [ 

	| left right y gapStart gapEnd |


	aCanvas
		fillRectangle: (self left@(self top + 5) corner: (self right - 1)@topBarBottom)
		color: color.
	aCanvas
		fillRectangle: ((self right - 1)@(self top + 3) corner: self right @topBarBottom)
		color: shadowColor.

	left := CBlockBracketThickness - 1.
	right := self width - 1.
	y := topBarBottom - self top.
	gapStart := left + PuzzleInset + 1.
	gapEnd := gapStart + PuzzleWidth.

	self drawHLineFrom: left to: (right - 1) y: y color: color on: aCanvas.
	self drawHLineFrom: left to: (right - 2) y: y + 1 color: color on: aCanvas.

	self drawHLineFrom: left to: (left + 2) y: y + 2 color: color on: aCanvas.
	self drawHLineFrom: left to: (left + 1) y: y + 3 color: color on: aCanvas.
	self drawPoint: (left + 1)@(y + 3) color: shadowColor on: aCanvas.

	self drawHLineFrom: gapStart to: gapEnd y: y + 2 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 1 to: gapEnd - 1 y: y + 3 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 1 to: gapEnd - 1 y: y + 4 color: color on: aCanvas.
	self drawHLineFrom: gapStart + 2 to: gapEnd - 2 y: y + 5 color: color on: aCanvas.

	self drawHLineFrom: (left + 2) to: gapStart y: y + 2 color: shadowColor on: aCanvas.
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
CommandScriptBlockMorph >> drawTopEdgeOn: aCanvas [

	| right |

	right := self width - 1.
	self drawHLineFrom: 2 to: right-2 y: 0 color: highlightColor1 on: aCanvas.
	self drawHLineFrom: 1 to: right-1 y: 1 color: highlightColor2 on: aCanvas.
	self drawHLineFrom: 0 to: right y: 2 color: color on: aCanvas.
	self drawHLineFrom: 0 to: right y: 3 color: color on: aCanvas.
	self drawHLineFrom: 0 to: right y: 4 color: color on: aCanvas.


]

{ #category : #drawing }
CommandScriptBlockMorph >> drawVerticalBarOn: aCanvas [ 

	| left top barRight |
	left := self left.
	barRight := (left + CBlockBracketThickness) - 1.
	top := self top.
	
	aCanvas
		fillRectangle: (left@(top + 5) corner: barRight@blockBottom)
		color: color.
	aCanvas
		fillRectangle: (left@(top + 2) corner: (left + 2)@blockBottom)
		color: highlightColor2.

	aCanvas
		fillRectangle: (barRight@(topBarBottom + 4) corner: (barRight + 1)@blockBottom)
		color: shadowColor.

]

{ #category : #'block enumerating' }
CommandScriptBlockMorph >> firstBlockList [
	"Answer an array containing the block sequence for my first (and only) nested block. (An if-then-else block would have a second block list.)"

	nestedBlock
		ifNil: [^ #()]
		ifNotNil: [^ nestedBlock blockSequence].



]

{ #category : #drawing }
CommandScriptBlockMorph >> fixBlockLayout [
	"Update the positions of my submorphs."

	self fixBlockLayoutNoWrap
]

{ #category : #drawing }
CommandScriptBlockMorph >> fixBlockLayoutNoWrap [
	"Update the positions of my submorphs."

	| oldExtent newW newH |
	blockLayoutNeeded ifFalse: [^ self].
	super fixBlockLayoutNoWrap.

	"fix nestedBlock and nextBlock in case they've been removed from me"
	(nestedBlock notNil and: [nestedBlock owner ~~ self]) ifTrue: [nestedBlock := nil].

	"color = owner color ifFalse: [self color: owner color]."

	oldExtent := self extent.
	newW := oldExtent x max: 60.
	"newW := newW max: self blockWidth."

	newH := self topBarHeight + CBlockBracketThickness.
	"self isForever ifFalse: [newH := newH + 4]."

	nestedBlock
		ifNil: [newH := newH + 14]
		ifNotNil: [
			stretchHeight := 0.
			nestedBlock fixBlockLayout.
			newH := newH + nestedBlock fullBounds height - 1.
			nestedBlock position: self position + (CBlockBracketThickness@(self topBarHeight + 3)).
			nestedBlock blockSequence last isStopOrForever ifTrue: [newH := newH + 4]].
	self extent: newW@newH + (0@stretchHeight).


]

{ #category : #accessing }
CommandScriptBlockMorph >> helpScreenName [
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	^'commandLambda'
]

{ #category : #initialization }
CommandScriptBlockMorph >> initialize [

	super initialize.
	type := #none.
	stretchHeight := 0.

]

{ #category : #testing }
CommandScriptBlockMorph >> isBooleanFunction [

	| reporter |
	reporter := self allMorphs anySatisfy: [:m|
		(m isCommandBlockMorph) and: [
			m selector = #doAnswer ]].
	^ (reporter argMorphs first isReporterBlockMorph) and: [
			reporter argMorphs first isBooleanReporter]

]

{ #category : #'class membership' }
CommandScriptBlockMorph >> isCBlockMorph [

	^true
]

{ #category : #'class membership' }
CommandScriptBlockMorph >> isCommandScriptBlockMorph [

	^ true
]

{ #category : #testing }
CommandScriptBlockMorph >> isFunction [
	self allMorphsDo: [:m|
		((m isCommandBlockMorph) and: [
			m selector = #doAnswer ]) ifTrue: [^ true]].
	^ false
]

{ #category : #'class membership' }
CommandScriptBlockMorph >> isKindOf: aClass [
	
	^ aClass = CBlockMorph
		or:[ super isKindOf: aClass]
]

{ #category : #drawing }
CommandScriptBlockMorph >> nestedBlock [
	^nestedBlock
]

{ #category : #accessing }
CommandScriptBlockMorph >> nestedBlockAt: aPoint [

	^ nestedBlock

]

{ #category : #private }
CommandScriptBlockMorph >> nextBlock [

	^nil
]

{ #category : #private }
CommandScriptBlockMorph >> nonControlFlowSubmorphs [
	"Answer a collection of submorphs minus any blocks that are part of the control flow. For example, command blocks omit their submorph that is the next block in the block sequence, C-blocks omit both their next block and the first block of their nested block list, etc."

	^ submorphs select: [:m | m ~~ nestedBlock ]

]

{ #category : #accessing }
CommandScriptBlockMorph >> optimized [
	^self fullCopy
]

{ #category : #private }
CommandScriptBlockMorph >> privateBody [
	"no copy"
	nestedBlock ifNil: [^nil].
	^nestedBlock
]

{ #category : #deleting }
CommandScriptBlockMorph >> removeItem [
	| quoted |
	quoted := nestedBlock.
	super removeItem.
	quoted ifNotNil: [
		self attachBlock: quoted ]
]

{ #category : #accessing }
CommandScriptBlockMorph >> stretchHeight: aNumber [
"
	(stretchHeight = aNumber) ifTrue: [^ self].
	stretchHeight := aNumber.
	blockLayoutNeeded := true.
	self fixBlockLayout.
"
]

{ #category : #other }
CommandScriptBlockMorph >> tabFields [

	| nst |

	nst := self nestedBlock.
	nst ifNotNil: [
		^ nst tabFields ].

	^ OrderedCollection new

]

{ #category : #drawing }
CommandScriptBlockMorph >> topBarHeight [
	"Answer the height of the top bar."

	| nonBlockSubmorphs |
	nonBlockSubmorphs := self submorphs select: [:m |
		(m isBlockMorph) not or: [argMorphs includes: m]].
	^ nonBlockSubmorphs inject: CBlockBracketThickness into: [:h :m | h max: (m height + 4)].


]
