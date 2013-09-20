Class {
	#name : #MessageElementMorph,
	#superclass : #SyntaxElementMorph,
	#instVars : [
		'receiver',
		'selector',
		'arguments',
		'labels',
		'cascade'
	],
	#category : #'Phratch-UI-Elements'
}

{ #category : #private }
MessageElementMorph class >> labelFont [
	^StrikeFont fontName: 'Verdana' size: 10
]

{ #category : #layout }
MessageElementMorph >> acceptDroppingMorph: aMorph event: evt [

	self addToCascade: aMorph
]

{ #category : #adding }
MessageElementMorph >> addLabel [
	label := StringMorph contents: '' font: self labelFont.
	label color: self labelColor.
	self addMorphFront: label.

]

{ #category : #adding }
MessageElementMorph >> addReceiver [
	receiver := ArgumentElementMorph new.
	self addMorphFront: receiver.
]

{ #category : #adding }
MessageElementMorph >> addToCascade: aMessageElement [
	cascade add: aMessageElement.
	self addMorph: aMessageElement.
	aMessageElement embedAsCascade
]

{ #category : #evaluation }
MessageElementMorph >> argumentCount [
	^arguments size
]

{ #category : #accessing }
MessageElementMorph >> arguments: anArray [

	1 to: anArray size do: [:i|
		(arguments size < i) ifFalse: [
			(arguments at: i) contents: (anArray at: i ) ]]
]

{ #category : #converting }
MessageElementMorph >> asSmalltalk [
	| ws |
	receiver isHidden
		ifTrue: [ ^ self keywordsAndArgs ].
	cascade isEmpty
		ifFalse: [ ^ self cascadeCode ].
	ws := WriteStream on: String new.
	^ ws
		nextPutAll: receiver asSmalltalk;
		nextPutAll: ' ';
		nextPutAll: self keywordsAndArgs;
		contents;
		yourself
]

{ #category : #converting }
MessageElementMorph >> assign [
	self selector: #_ arguments: { ObjectElementMorph new }.
	(arguments at: 1) contents delete. 
	(arguments at: 1) removeContents
]

{ #category : #'instance creation' }
MessageElementMorph >> beBinary [
	self binarySelector: selector
]

{ #category : #accessing }
MessageElementMorph >> binarySelector: aString [

	| lb arg |

	selector := aString.
	label ifNotNil: [label delete. label := nil].
	labels do: [:each| each delete ].
	arguments do: [:each| each delete ].
	labels := OrderedCollection new.
	arguments := OrderedCollection new.

	lb := ((StringMorph contents: aString font: self labelFont) color: self labelColor).
	labels add: lb.
	self addMorph: lb.
	arg := ArgumentElementMorph new.
	arguments add: arg.
	self addMorph: arg.
	self fit
]

{ #category : #other }
MessageElementMorph >> buildLabelsAndArgs [

	| tokens lb arg |
	label ifNotNil: [label delete. label := nil].
	labels do: [:each| each delete ].
	arguments do: [:each| each delete ].
	labels := OrderedCollection new.
	arguments := OrderedCollection new.

	((selector includes: $:) not | (selector = ':=')) ifTrue: [
		self label: (self wordsFrom: selector).
		^self ].

	tokens := selector findTokens: ':'.
	tokens do: [:each| 
		lb := ((StringMorph contents: (self wordsFrom: each) font: self labelFont) color: self labelColor).
		labels add: lb.
		self addMorph: lb.
		arg := ArgumentElementMorph new.
		arguments add: arg.
		self addMorph: arg].
		
]

{ #category : #other }
MessageElementMorph >> cascadeCode [
	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: receiver asSmalltalk.
	cascade
		do: [ :msg | 
			ws
				cr;
				nextPutAll: msg asSmalltalk;
				nextPutAll: ' ';
				nextPut: $; ].
	^ ws
		nextPutAll: self keywordsAndArgs;
		cr;
		contents;
		yourself
]

{ #category : #menu }
MessageElementMorph >> contextMenu [
	| m |
	m := MenuMorph new.	"	m add: 'duplicate' action: #duplicate. "
	m add: 'delete' translated action: #throwAway.
	self isRenameable
		ifTrue:
			[ 
			m add: 'rename...' translated action: #editSelector.
			arguments isEmpty
				ifTrue: [ m add: 'add argument' translated action: #beBinary ] ].
	m addLine.
	m add: 'show code...' translated action: #showGeneratedSmalltalk.
	m add: 'show result...' translated action: #showResult.
	m add: 'evaluate' translated action: #evaluate.
	^ m
]

{ #category : #'instance creation' }
MessageElementMorph >> editSelector [
	|ans|

	ans := UIManager default request: 'selector:' initialAnswer: selector.
	(ans size > 0) ifTrue: [self selector: ans]
]

{ #category : #other }
MessageElementMorph >> embedAsCascade [
	receiver isHidden: true.
	self fit
]

{ #category : #other }
MessageElementMorph >> extractFromCascade [
	receiver isHidden: false.
	self fit
]

{ #category : #private }
MessageElementMorph >> fit [
	receiver isHidden
		ifTrue: [ ^ self fitForCascade ].
	cascade isEmpty
		ifFalse: [ ^ self fitCascaded ].
	self isStacked
		ifTrue: [ self fitStacked ]
		ifFalse: [ self fitInLine ]
]

{ #category : #other }
MessageElementMorph >> fitCascaded [
	| cw bw bw2 x y arg lb maxHeight maxRight labelTop labelBottom cntr |
	cw := self labelFont widthOf: $ .
	bw := self borderWidth.
	bw2 := bw * 2.

	x := receiver right + bw2.
	maxRight := x.
	y := self top + bw2.

	cascade do: [:eachElement |
		eachElement position: x @ y.
		maxRight := maxRight max: eachElement right.
		y := eachElement bottom ].
	x := x + (bw * 3).
	labelTop := y + bw.

	labels isEmpty 
		ifTrue: [
			label position: x @ labelTop.
			maxRight := maxRight max: label right.
			maxHeight := label height.
			labelBottom := label bottom ]
		ifFalse: [
			maxHeight := labels anyOne height.
			1 to: labels size do: [:i |
				arg := arguments at: i.
				lb := labels at: i.
				maxHeight := maxHeight max: (arg height).

				lb position: x @ labelTop.
				x := x + lb width + cw.
				arg position: x @ labelTop.
				x := x + arg width + cw ].
			x := x - cw.
			maxRight := maxRight max: x.

			cntr := labelTop + (maxHeight // 2).

			arguments do: [:each|
				each position: (each position x @ (cntr - (each height // 2))) ].
			labels do: [:each|
				each position: (each position x @ (cntr - (each height // 2))) ]].

	labelBottom := labelTop + maxHeight.
	labelBottom := labelBottom max: receiver bottom.

	self extent: ((maxRight - self left) @ (labelBottom - self top)) + bw2.



	(owner respondsTo: #fit)
		ifTrue: [owner fit]
]

{ #category : #other }
MessageElementMorph >> fitForCascade [

	| cw bw bw2 x arg lb maxHeight |
	cw := self labelFont widthOf: $ .
	bw := self borderWidth.
	bw2 := bw * 2.

	x := self left + bw2.

	labels isEmpty 
		ifTrue: [^super fit]
		ifFalse: [
			maxHeight := labels anyOne height.
			1 to: labels size do: [:i |
				arg := arguments at: i.
				lb := labels at: i.
				maxHeight := maxHeight max: (arg height).

				lb position: x @ (lb position y).
				x := x + lb width + cw.
				arg position: x @ (arg position y).
				x := x + arg width + cw ].
			self extent: (x - self position x - cw - bw2) @ maxHeight + (bw2 * 2).
			receiver position: (receiver position x @ (bounds center y - (receiver height // 2))).
			arguments do: [:each|
				each position: (each position x @ (bounds center y - (each height // 2))) ].
			labels do: [:each|
				each position: (each position x @ (bounds center y - (each height // 2))) ].
].

	(owner respondsTo: #fit)
		ifTrue: [owner fit]
]

{ #category : #other }
MessageElementMorph >> fitInLine [

	| h w cw bw bw2 x arg lb maxHeight |
	cw := self labelFont widthOf: $ .
	bw := self borderWidth.
	bw2 := bw * 2.

	receiver position: (self left + bw2) @ (self top + bw2).
	x := receiver right + cw.

	labels isEmpty 
		ifTrue: [
			h := receiver height + (bw2 * 2).
			w := receiver width + (label width) + (cw * 1.5) + (bw2 * 2).

			self width: w.
			self height: h.

			label position: x @ (bounds center y - (label height // 2)).

			self isLabelFirst ifTrue: [
				label position: (receiver position x) @ (label position y).
				receiver position: (label right + cw) @ (receiver position y) ]]
		ifFalse: [
			maxHeight := receiver height.
			1 to: labels size do: [:i |
				arg := arguments at: i.
				lb := labels at: i.
				maxHeight := maxHeight max: (arg height).

				lb position: x @ (lb position y).
				x := x + lb width + cw.
				arg position: x @ (arg position y).
				x := x + arg width + cw ].
			self extent: (x - self position x - cw - bw2) @ maxHeight + (bw2 * 2).
			receiver position: (receiver position x @ (bounds center y - (receiver height // 2))).
			arguments do: [:each|
				each position: (each position x @ (bounds center y - (each height // 2))) ].
			labels do: [:each|
				each position: (each position x @ (bounds center y - (each height // 2))) ].
].

	(owner respondsTo: #fit)
		ifTrue: [owner fit]
]

{ #category : #other }
MessageElementMorph >> fitStacked [

	| h w cw bw bw2 x y arg lb maxRight |
	cw := self labelFont widthOf: $ .
	bw := self borderWidth.
	bw2 := bw * 2.

	receiver position: (self left + bw2) @ (self top + bw2).
	x := receiver right + cw.
	y := receiver bottom + bw.

	labels isEmpty 
		ifTrue: [
			h := receiver height + (bw2 * 2).
			w := receiver width + (label width) + (cw * 1.5) + (bw2 * 2).

			self width: w.
			self height: h.

			label position: x @ (bounds center y - (label height // 2)) ]
		ifFalse: [
			maxRight := receiver right.
			1 to: labels size do: [:i |
				arg := arguments at: i.
				lb := labels at: i.

				lb position: receiver left + cw @ (y + ((arg height - lb height) // 2)).
				arg position: (lb right + cw) @ y.

				y := y + arg height + bw.

				maxRight := maxRight max: (arg right) ].

			self extent: ((maxRight - self left) + bw2) @ ((y - self top) + bw)].

	(owner respondsTo: #fit)
		ifTrue: [owner fit]
]

{ #category : #'*Phratch-Extensions' }
MessageElementMorph >> fullCopy [
	|copy|
	copy := self class new selector: selector.
	(#ifTrue:ifFalse: = selector) 
		ifTrue: [copy yesNo ].
	(#_ = selector) 
		ifTrue: [copy assign ].
	copy position: self position.
	(copy argumentCount < self argumentCount)
		ifTrue: [copy beBinary].
	^copy
]

{ #category : #other }
MessageElementMorph >> hasCascade [
	^cascade isEmpty not
]

{ #category : #initialize }
MessageElementMorph >> initialize [
	super initialize.
	labels := OrderedCollection new.
	arguments := OrderedCollection new.
	cascade := OrderedCollection new.
	color := Color orange darker.
	self addLabel.
	self addReceiver.
	self fit.
]

{ #category : #testing }
MessageElementMorph >> isBinary [

	^(arguments size = 1) and: [
		selector asString last ~= ($:)]
]

{ #category : #testing }
MessageElementMorph >> isKeywords [
	^arguments size > 0 & self isBinary not
]

{ #category : #testing }
MessageElementMorph >> isLabelFirst [
	|firstWord disabled|
	disabled := true. "change this to experiment with swapped unaries"
	disabled ifTrue: [^false].

	selector ifNil: [^false].
	firstWord := (self label findTokens: ' ') first. 
		(#('is' 'as' 'has'	'wants') includes: firstWord)
			ifTrue: [ ^false].

	^arguments isEmpty & cascade isEmpty & receiver isHidden not
]

{ #category : #testing }
MessageElementMorph >> isStacked [
	^(#(
		'isNil:'
		'ifNil:'
		'ifNotNil:'
		'ifTrue:'
		'ifFalse:'
		'ifTrue:ifFalse:'
		'ifFalse:ifTrue:'
		'select:'
		'detect:'
		'detect:ifNone:'
		'collect:'
		'reject:'
		'select:'
		'do:'
		'to:do:'
		'whileTrue:'
		'or:'
		'and:'
	)
	includes: selector) or: [(
	(arguments select: [:arg | 
		arg contents isKindOf: BlockElementMorph])
			size > 0) or: [ selector notNil and: [
				(selector findTokens: ':') size > 3] ]]

]

{ #category : #testing }
MessageElementMorph >> isUnary [

	^arguments isEmpty
]

{ #category : #other }
MessageElementMorph >> keywordsAndArgs [
	| kw ws |
	kw := selector keywords.
	selector = ':='
		ifTrue: [ kw := #('_') ].
	ws := WriteStream on: String new.
	1 to: kw size do: [ :i | 
		ws nextPutAll: (kw at: i).
		arguments size < i
			ifFalse: [ 
				ws
					nextPutAll: ' ';
					nextPutAll: (arguments at: i) asSmalltalk;
					nextPutAll: ' ' ] ].
	^ ws contents
]

{ #category : #private }
MessageElementMorph >> labelFont [
	^self class labelFont
]

{ #category : #accessing }
MessageElementMorph >> receiver [
	^receiver contents
]

{ #category : #accessing }
MessageElementMorph >> receiver: anElement [
	receiver contents: anElement
]

{ #category : #other }
MessageElementMorph >> removeCascadedElement: element [

	cascade remove: element ifAbsent: [].
	self fit.
	element extractFromCascade.
	^self
]

{ #category : #'*Phratch-Extensions' }
MessageElementMorph >> rootForGrabOf: aMorph [
	"Answer the root of the morph structure to be picked up when the given morph is grabbed."

	aMorph == self ifTrue: [^super rootForGrabOf: aMorph ].
	(aMorph isKindOf: self class) ifTrue: [^self].
	^super rootForGrabOf: aMorph

]

{ #category : #accessing }
MessageElementMorph >> selector: aString [

	selector := aString.
	self buildLabelsAndArgs.
	self fit
]

{ #category : #'instance creation' }
MessageElementMorph >> selector: aString arguments: anArray [

	"for decompilation purposes only. Caution: this method assumes that the number of arguments matches the
	number of parameters required by the selector."

	| tokens lb arg |

	selector := aString.
	label ifNotNil: [label delete. label := nil].
	labels do: [:each| each delete ].
	arguments do: [:each| each delete ].
	labels := OrderedCollection new.
	arguments := OrderedCollection new.

	anArray isEmpty ifTrue: [
		self label: (self wordsFrom: selector).
		^self fit ].

	tokens := selector findTokens: ':'.
	1 to: tokens size do: [:i |
		lb := ((StringMorph 
				contents: (self wordsFrom: (tokens at: i)) 
				font: self labelFont) 
				color: self labelColor).
		labels add: lb.
		self addMorph: lb.
		arg := ArgumentElementMorph new.
		arguments add: arg.
		self addMorph: arg.
		arg contents: (anArray at: i)].

	self fit
]

{ #category : #'dropping/grabbing' }
MessageElementMorph >> wantsDroppedMorph: aMorph event: evt [

	(owner isKindOf: self class) ifTrue: [owner hasCascade ifTrue: [^false]].
	^(aMorph isKindOf: self class) and: [ (aMorph hasCascade not) & (aMorph receiver isNil) ]
]

{ #category : #other }
MessageElementMorph >> yesNo [
	^self selector: #ifTrue:ifFalse: arguments: { BlockElementMorph new. BlockElementMorph new }.

]
