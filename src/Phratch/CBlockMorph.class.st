"
I am a command block that contains a nested sequence of command blocks, such as a loop.

"
Class {
	#name : #CBlockMorph,
	#superclass : #CommandBlockMorph,
	#instVars : [
		'nestedBlock',
		'nextBlock',
		'topBarBottom',
		'blockBottom',
		'loopMorph',
		'stretchHeight'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #'as yet unclassified' }
CBlockMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block :=  self new isSpecialForm: true.
	^block
]

{ #category : #private }
CBlockMorph >> addCommandIcons [
	"Add additional icons to certain blocks. Do nothing if this isn't one of those blocks."

	| f |
	super addCommandIcons.
	(#(#doForever #doForeverIf #doRepeat #doUntil) includes: selector)
		ifFalse: [ ^ self ].
	f := PhratchFrameMorph skinAt: #loopIcon ifAbsent: [ ^ self ].
	loopMorph := ImageMorph new form: f.
	self addMorphBack: loopMorph
]

{ #category : #private }
CBlockMorph >> attachBlock: aBlockMorph [
	"Attach the given block to me. Assume the block has been positioned correctly."
	self addMorph: aBlockMorph.
	aBlockMorph top >= (self bottom - CBlockBracketThickness)
		ifTrue: [nextBlock := aBlockMorph]
		ifFalse: [nestedBlock := aBlockMorph].
	
]

{ #category : #private }
CBlockMorph >> attachBlockNested: aBlockMorph [
	"Attach the given block to me. Assume the block has been positioned correctly."
	
	(stretchHeight = 0)
			ifTrue: [self position: (aBlockMorph left)@(aBlockMorph top - self height + 4)].
	self addMorph: aBlockMorph.
	(stretchHeight = 0)
		ifTrue: [self bottomBlock nextBlock: aBlockMorph]
		ifFalse: [nestedBlock := aBlockMorph].

	PhratchFrameMorph allInstancesDo: [:a | a fixNestedBlocks]
]

{ #category : #private }
CBlockMorph >> blockAttachPoints: aSet [
	"Answer a collection of possible attachment points for me. Each entry is an Association mapping a point to the morph to which a dropping command block could be attached."

	| result |
	result := #().
	result :=  result copyWith: self topLeft -> self.
	nestedBlock
		ifNil: [ 
			result :=  result copyWith: self topLeft + (12 @ (self topBarHeight + 7)) -> self  ]
		ifNotNil: [ nestedBlock blockAttachPoints: aSet ].
	nextBlock
		ifNil: [ 
			self isStopOrForever
				ifFalse: [ 
					result :=  result copyWith: self bottomLeft -> self  ] ]
		ifNotNil: [ nextBlock blockAttachPoints: aSet ].
	aSet addAll: result
]

{ #category : #'encapsulated scripts' }
CBlockMorph >> blockWidth [
	| maxWidth |
	maxWidth := 0.
	self firstBlockList do: [:b |
		maxWidth := maxWidth max: b blockWidth ].
	^self width max: self bracketThickness + maxWidth
]

{ #category : #accessing }
CBlockMorph >> bracketThickness [

	^ CBlockBracketThickness

]

{ #category : #geometry }
CBlockMorph >> containsPoint: aPoint [

	cachedForm ifNil: [self updateCachedForm].
	^ (self fullBounds containsPoint: aPoint) and:
	  [cachedForm notNil and: [(cachedForm isTransparentAt: aPoint - self fullBounds origin) not]]

]

{ #category : #drawing }
CBlockMorph >> drawBottomBarOn: aCanvas [ 

	| left barTop barBottom |
	self isForever
		ifTrue: [
			barBottom := self bottom - 3.
			self drawSmoothBottomEdgeOn: aCanvas]
		ifFalse: [
			barBottom := self bottom - 7.
			self drawBottomEdgeOn: aCanvas].

	barTop := barBottom - (CBlockBracketThickness - 3).
	left := self left + CBlockBracketThickness - 1.

	"fill in bottom-left corner"
	aCanvas fillRectangle: (left@(barTop - 2) extent: 1@1) color: color.
	aCanvas fillRectangle: (left@(barTop - 1) extent: 2@1) color: color.
	aCanvas fillRectangle: (left@barTop extent: 3@1) color: color.

	aCanvas
		fillRectangle: ((left + 3)@barTop corner: (self right - 2)@(barTop + 1))
		color: highlightColor1.
	aCanvas
		fillRectangle: (left@(barTop + 1) corner: (self right - 1)@barBottom)
		color: color.
	aCanvas
		fillRectangle: ((self right - 1)@(barTop + 2) corner: self right@barBottom)
		color: shadowColor.



]

{ #category : #drawing }
CBlockMorph >> drawInnerTopY: y on: aCanvas [

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
CBlockMorph >> drawOn: aCanvas [
	| c |
	self contrastColor.
	topBarBottom := self top + self topBarHeight.
	blockBottom := self isForever
		ifTrue: [ self bottom - 3 ]
		ifFalse: [ self bottom - 7 ].
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
CBlockMorph >> drawTopBarOn: aCanvas [ 

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
CBlockMorph >> drawVerticalBarOn: aCanvas [ 

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

{ #category : #private }
CBlockMorph >> firstBlockList [
	"Answer an array containing the block sequence for my first (and only) nested block. (An if-then-else block would have a second block list.)"

	nestedBlock
		ifNil: [^ #()]
		ifNotNil: [^ nestedBlock blockSequence].


]

{ #category : #drawing }
CBlockMorph >> fixBlockLayout [
	"Update the positions of my submorphs."

	| oldExtent newW newH f |
	blockLayoutNeeded ifFalse: [^ self].
	super fixBlockLayout.

	"fix nestedBlock and nextBlock in case they've been removed from me"
	(nestedBlock notNil and: [nestedBlock owner ~~ self]) ifTrue: [nestedBlock := nil].
	(nextBlock notNil and: [nextBlock owner ~~ self]) ifTrue: [nextBlock := nil].

	oldExtent := self extent.
	newW := oldExtent x max: 40.
	newH := self topBarHeight + CBlockBracketThickness.
	self isForever ifFalse: [newH := newH + 4].

	nestedBlock
		ifNil: [newH := newH + 14]
		ifNotNil: [
			stretchHeight := 0.
			nestedBlock fixBlockLayout.
			newH := newH + nestedBlock fullBounds height - 1.
			nestedBlock position: self position + (CBlockBracketThickness@(self topBarHeight + 3)).
			nestedBlock blockSequence last isStopOrForever ifTrue: [newH := newH + 4]].
	self extent: newW@newH + (0@stretchHeight).

	"position loop morph"
	loopMorph ifNotNil: [
		f := PhratchFrameMorph skinAt: #loopIcon.
		loopMorph form: f.
		self isForever
			ifTrue: [loopMorph position: self bottomRight - loopMorph extent - (4@2)]
			ifFalse: [loopMorph position: self bottomRight - loopMorph extent - (4@6)]].

	nextBlock ifNotNil: [
		nextBlock position: self left@(self bottom - 4)].

]

{ #category : #initialization }
CBlockMorph >> initialize [

	super initialize.
	self color: (Color r: 1.0 g: 0.581 b: 0.194).
	stretchHeight := 0.

]

{ #category : #private }
CBlockMorph >> isCShape [

	^ true
]

{ #category : #private }
CBlockMorph >> litUp: aBoolean [
	"Overridden to suppress highlighting of control structures. Do nothing."
]

{ #category : #accessing }
CBlockMorph >> nestedBlockAt: aPoint [

	^ nestedBlock

]

{ #category : #private }
CBlockMorph >> nests: aCommandBlock [

	^ (nestedBlock isKindOf: BlockMorph) and: [  nestedBlock blockSequence includes: aCommandBlock]
]

{ #category : #private }
CBlockMorph >> nextBlock [
	"Answer the block myself in the block sequence or nil if I am the last block in the sequence. Each block is a submorph of the previous block."

	^ nextBlock

]

{ #category : #private }
CBlockMorph >> nextBlock: aBlockMorph [
	"Add the given block as the block following me. Delete old nextBlock, if any."

	self nextBlock ifNotNil: [self nextBlock delete].
	nextBlock := aBlockMorph.
	aBlockMorph ifNotNil: [self addMorph: aBlockMorph].

]

{ #category : #private }
CBlockMorph >> nonControlFlowSubmorphs [
	"Answer a collection of submorphs minus any blocks that are part of the control flow. For example, command blocks omit their submorph that is the next block in the block sequence, C-blocks omit both their next block and the first block of their nested block list, etc."

	^ submorphs select: [:m | (m ~~ nestedBlock) & (m ~~ nextBlock)]

]

{ #category : #private }
CBlockMorph >> printCodeOn: aStream indent: indent [
	"Append a human-readable string for this block on the given stream."

	indent timesRepeat: [aStream nextPutAll: '    '].
	submorphs do: [:m |
		(m ~~ nestedBlock) & (m ~~ nextBlock) ifTrue: [
			self printCodeSubmorph: m on: aStream.
			aStream space]].
	aStream cr.
	nestedBlock ifNotNil: [nestedBlock printCodeOn: aStream indent: indent + 1].
	nextBlock ifNotNil: [nextBlock printCodeOn: aStream indent: indent].

]

{ #category : #geometry }
CBlockMorph >> stretchHeight: aNumber [

	(stretchHeight = aNumber) ifTrue: [^ self].
	stretchHeight := aNumber.
	blockLayoutNeeded := true.
	self fixBlockLayout.

]

{ #category : #private }
CBlockMorph >> tabFields [

	| nst nstfields fields nxt nxtFields |
	fields := OrderedCollection new.
	nxtFields := OrderedCollection new.

	fields := OrderedCollection new.
	self nonControlFlowSubmorphs do: [:m |
		(m isKindOf: ExpressionArgMorph)
			ifTrue: [fields add: m ]
			ifFalse: [(m respondsTo: #tabFields)
				ifTrue: [fields addAll: m tabFields ]]]. 

	nst := nestedBlock.
	nst ifNotNil: [
		nstfields := nst tabFields ].

	nxt := self nextBlock.
	nxt ifNotNil: [
		nxtFields := nxt tabFields ].

	nstfields ifNotNil: [
		fields := fields, nstfields ].
	nxtFields ifNotNil: [
		fields := fields, nxtFields ].

	^  fields
]

{ #category : #accessing }
CBlockMorph >> topBarHeight [
	"Answer the height of the top bar."

	| nonBlockSubmorphs |
	nonBlockSubmorphs := self submorphs select: [:m |
		(m isKindOf: BlockMorph) not or: [argMorphs includes: m]].
	^ nonBlockSubmorphs inject: CBlockBracketThickness into: [:h :m | h max: (m height + 4)].


]

{ #category : #accessing }
CBlockMorph >> yThresh [

	(self nestedBlockAt: self top + self topBarHeight) 
		ifNil: [ ^ 25 ].
	^ 14
]
