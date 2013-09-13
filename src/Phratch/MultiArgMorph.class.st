Class {
	#name : #MultiArgMorph,
	#superclass : #ArgMorph,
	#instVars : [
		'text',
		'type',
		'isWrapping'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #accessing }
MultiArgMorph class >> type: aSymbol [
	^ self new
		type: aSymbol;
		text: '';
		buildControls; 
		yourself
]

{ #category : #adding }
MultiArgMorph >> addArg: aBlockOrValue [
	| newMorph newSubs |
	newMorph := ((aBlockOrValue isKindOf: CommandBlockMorph) or: [ aBlockOrValue isKindOf: ArgMorph ])
		ifTrue: [ aBlockOrValue ]
		ifFalse: [ self newSlot ].
	newMorph owner ifNotNil: [ newMorph owner privateRemoveMorph: newMorph ].
	newMorph layoutChanged.
	newMorph privateOwner: self.
	newSubs := Array new: submorphs size + 1.
	1 to: submorphs size - 2 do: [ :i | newSubs at: i put: (submorphs at: i) ].
	newSubs at: submorphs size - 1 put: newMorph.
	newSubs at: submorphs size put: self lessButton.
	newSubs at: submorphs size + 1 put: self moreButton.
	submorphs := newSubs.
	newMorph changed.
	self layoutChanged
]

{ #category : #adding }
MultiArgMorph >> addArgSlot [

	(owner isKindOf: BlockMorph) ifTrue: [
		owner stop].

	self addArg: self newSlot;
	fixArgLayout
]

{ #category : #other }
MultiArgMorph >> argMorphToReplace: aBlock [
	^ self newSlot
]

{ #category : #other }
MultiArgMorph >> buildControls [

	submorphs do: [:sm | sm delete].

	self addMorphBack: ((StringMorph contents: text font: (PhratchFrameMorph getFont: #Label))
		color: ((owner respondsTo: #labelColor) ifTrue: [owner labelColor] ifFalse: [Color white])).

	self addMorphBack: (ImageMorph new form: (ArgMorph dropDownMenuForm rotateBy: 90)).

	self addMorphBack: (ImageMorph new form: (ArgMorph dropDownMenuForm rotateBy: -90)).

	self fixArgLayout

]

{ #category : #accessing }
MultiArgMorph >> color [
	(owner respondsTo: #color) ifTrue: [
		^owner color]
]

{ #category : #byob }
MultiArgMorph >> contrastColor [
	submorphs do: [:m |	(m isKindOf: BlockMorph)
		ifTrue: [ m contrastColor ]]
]

{ #category : #other }
MultiArgMorph >> defaultValue: aPhratchListMorph [
	"Set my default value"

	| element |

	(aPhratchListMorph isKindOf: PhratchListMorph)
		ifFalse: [^ self].
	1 to: aPhratchListMorph lineCount do: [:i |
		element := aPhratchListMorph lineAt: i.
		((element isKindOf: ReporterBlockMorph)
		and: [(element isKindOf: ArgMorph) not])
			ifTrue: [self addArg: element]
			ifFalse: [
				self addArgSlot.
				(element isKindOf: ReporterBlockMorph)
					ifTrue: [((element respondsTo: #body) and: [element body notNil])
						ifTrue: [
							self replaceSubmorph: self elements last by: element 
							"self elements last replaceArgMorph: self elements last args first by: element body"]]
					ifFalse: [ 
						element = 'nil'
							ifTrue: [element := nil].
						self elements last defaultValue: element ]]]
		
]

{ #category : #protocol }
MultiArgMorph >> elements [
	^ submorphs reject: [:sm |
		(sm isKindOf: ImageMorph)
		or: [sm isKindOf: StringMorph]]
]

{ #category : #evaluation }
MultiArgMorph >> evaluate [
	 | list |

	(self isEmptySlot and: [implicitValue notNil])
		ifTrue: [^implicitValue].

	list := PhratchListMorph new.
	list listName: '' target: nil.
	self elements do: [:each |
		list insertLine:  (ScriptablePhratchMorph new asListElement: each evaluate) at: (list lineCount + 1) ].
	list updateCountMorph.
	list fixLayout.
	list startStepping.
	^list	
]

{ #category : #other }
MultiArgMorph >> fixArgLayout [
	| maxHeight x space shouldHide lines line left maxX parts w y mh h isMultiC |
	shouldHide := submorphs size - 3 <= 0.
	self lessButton isHidden: shouldHide.
	self label isHidden: shouldHide.
	isMultiC := #(#loop #reporterSlot) includes: type.
	lines := OrderedCollection new.	"distribute parts horizontally and cut up into lines"
	line := OrderedCollection new.
	x := self left.
	left := x.
	maxX := x.
	space := 4.
	isMultiC
		ifTrue: [ self width: 50 ].
	parts := submorphs select: [ :sm | sm isVisible and: [ (sm isKindOf: StringMorph) not ] ].
	parts
		do: [ :m | 
			(m isKindOf: ReporterBlockMorph) & isMultiC
				ifTrue: [ 
					"in this case just break up into lines, don't distribute yet"
					m left: self left.
					lines add: (OrderedCollection with: m).
					m fixBlockLayout.
					((m isKindOf: CArgSlotMorph) or: [ m isKindOf: CReporterSlotMorph ])
						ifTrue: [ m width: self width ].
					maxX := maxX max: left + m width.
					x := left ]
				ifFalse: [ 
					(x - left > 300 and: [ m ~~ submorphs last ])
						ifTrue: [ 
							lines add: line.
							line := OrderedCollection new.
							x := left ].
					(m isKindOf: BlockMorph)
						ifTrue: [ m fixBlockLayout ].
					(m isKindOf: ArgMorph)
						ifTrue: [ m fixArgLayout ].
					m left: x.
					(m right - left > 300 and: [ line isEmpty not and: [ m ~~ submorphs last ] ])
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
	w := maxX - self left max: 4.
	isWrapping := lines size > 1.	"distribute lines vertically"
	space := 0.
	y := self top.
	isWrapping & isMultiC not
		ifTrue: [ 
			space := 1.
			y := self top + 2 ].
	lines
		do: [ :eachLine | 
			maxHeight := 10.
			eachLine
				do: [ :m | 
					mh := ((m isKindOf: ReporterBlockMorph) and: [ m isBlockTemplate and: [ m isEmptySlot not ] ])
						ifTrue: [ m height + 7 ]
						ifFalse: [ m height ].
					maxHeight := mh max: maxHeight ].
			eachLine do: [ :m | m top: y + ((maxHeight - m height) // 2) ].
			y := y + maxHeight + space ].
	h := y - self top + space.
	self extent: w @ h.
	self layoutChanged.
	owner ifNotNil: [ owner layoutChanged ]
]

{ #category : #'event handling' }
MultiArgMorph >> handlesMouseDown: evt [

	| more less |
	more := self moreButton.
	less := self lessButton.
	^ (more isVisible & (more containsPoint: evt cursorPoint))
		or: [less isVisible & (less containsPoint: evt cursorPoint)]

]

{ #category : #initialization }
MultiArgMorph >> initialize [

	super initialize.
	isWrapping := false.
	self color: Color transparent.
	self borderWidth: 0.
	text := ''.
	type := #any.
	self buildControls.

]

{ #category : #byob }
MultiArgMorph >> isEmptySlot [


	^self elements isEmpty
]

{ #category : #testing }
MultiArgMorph >> isLambdaForm [
	^false
]

{ #category : #accessing }
MultiArgMorph >> isWrapping [
	^isWrapping

]

{ #category : #accessing }
MultiArgMorph >> label [
	^ submorphs first
]

{ #category : #other }
MultiArgMorph >> lessButton [
	^ submorphs at: submorphs size - 1
]

{ #category : #accessing }
MultiArgMorph >> listValue [
	| list item |
	list := PhratchListMorph new.
	list listName: '' target: nil.
	self elements
		do: [ :each | 
			item := (each isKindOf: ReporterBlockMorph)
				ifTrue: [ each ]
				ifFalse: [ 
					each isEmptySlot
						ifTrue: [ nil ]
						ifFalse: [ each evaluate ] ].
			list insertLine: (ScriptablePhratchMorph new asListElement: item) at: list lineCount + 1 ].
	list updateCountMorph.
	^ list
]

{ #category : #other }
MultiArgMorph >> loopsWidth: anInteger [

	| parts |

	type = #loop ifFalse: [^ self].
	self width: (anInteger max: 50).
	parts := submorphs select: [:sm | (sm isKindOf: CArgSlotMorph) or: [sm isKindOf: CReporterSlotMorph]].
	parts do: [:m |
		m width: self width ]

]

{ #category : #accessing }
MultiArgMorph >> moreButton [
	^ submorphs at: submorphs size
]

{ #category : #'event handling' }
MultiArgMorph >> mouseDown: evt [
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	evt hand newKeyboardFocus: nil.
	evt anyButtonPressed ifTrue: [
		(self moreButton containsPoint: evt cursorPoint)
			ifTrue: [^self addArgSlot ].
		(self lessButton containsPoint: evt cursorPoint)
			ifTrue: [^self removeArgSlot ]].
	^super mouseDown: evt

]

{ #category : #'instance-creation' }
MultiArgMorph >> newSlot [

	| specs slot |
	specs := Dictionary new.
	specs
		at: #command put: '$CSlot$';
		at: #reporter put: '$OSReporter$';
		at: #predicate put: '$OSBoolean$';
		at: #list put: '$SAList$';
		at: #text put: '$Text$';
		at: #any put: '$String$';
		at: #boolean put: '$Boolean$';
		at: #number put: '$Number$';
		at: #loop put: '$CArgSlot$';
		at: #unevaluated put: '$UnEExp$';
		at: #unevaluatedBoolean put: '$UnEBool$';
		at: #objSlot put: '$SAObjS$'.

" +++ deprecated experimental slots    -jens ++++++

		at: #reporterSlot put: '$MAUnEBool$';
		at: #typeInReporter put: '$UnEExp$'.

+++++++++++++++++++++++++++++++++++++++++++++++"

	slot := CommandBlockMorph new uncoloredArgMorphFor: (specs at: type ifAbsent: [ '$String$']).
	slot defaultValue: ''.
	^slot
]

{ #category : #'error handling' }
MultiArgMorph >> receiver [

	"needed for error handling"
	(owner isKindOf: BlockMorph) ifTrue: [
		^owner receiver].
	^nil


]

{ #category : #'block enumerating' }
MultiArgMorph >> removeArgSlot [

	| oldArg  |

	(owner isKindOf: BlockMorph) ifTrue: [
		owner stop].

	oldArg := submorphs at: submorphs size - 2.
	((oldArg isKindOf: BlockMorph) and: [(oldArg isKindOf: ArgMorph) not])
		ifTrue: [World addMorph: oldArg]
		ifFalse: [oldArg delete].
	self fixArgLayout
]

{ #category : #private }
MultiArgMorph >> replaceArgMorph: oldArg by: newArg [

	self replaceSubmorph: oldArg by: newArg

]

{ #category : #'error handling' }
MultiArgMorph >> showError [
	"Make this block to show an error."

	(owner isKindOf: BlockMorph) ifTrue: [
		owner showError]
]

{ #category : #private }
MultiArgMorph >> tabFields [

	| fields |
	fields := OrderedCollection new.
	submorphs do: [:m |
		(m isKindOf: ReporterBlockMorph)
			ifTrue: [fields addAll: m tabFields ]
			ifFalse: [(m isKindOf: ExpressionArgMorph)
				ifTrue: [fields add: m]]].
	^ fields
]

{ #category : #accessing }
MultiArgMorph >> text [
	^ text
]

{ #category : #accessing }
MultiArgMorph >> text: aString [
	text := aString
]

{ #category : #'block enumerating' }
MultiArgMorph >> topBlock [

	(owner isKindOf: BlockMorph) ifTrue: [
		^owner topBlock].
	^nil

]

{ #category : #accessing }
MultiArgMorph >> transparentRect [
	^ self position corner: (self right@submorphs last top)
]

{ #category : #accessing }
MultiArgMorph >> type [
	^type
]

{ #category : #accessing }
MultiArgMorph >> type: aSymbol [

	"currently BYOB supports the following first class types:

    #none			- a puzzle shaped command block
    #any			- a non-typed round reporter block (can be anything)
    #string			- a round reporter block that answers a string
    #number		- a round reporter block that answers a number
    #list				- a round reporter block that answers a number
    #boolean		- a hexagonal reporter block that answers a boolean
    #command		- a round reporter block that answers a procedure (a command block)
    #reporter		- a round reporter block that answers a function (a reporter block)
    #predicate		- a hexagonal reporter block that answers a reporter of a boolean 
    #template		- a sunken variable blob that represents an externalized block variable
    #loop			- a C-shaped slot
    #reporterSlot		- a C-shaped reporter slot
    #typeInReporter	- a rectangular reporter slot that can be typed into
    #unevaluated	- a rectangular type-in slot that auto-lambdafies
    #unevaluatedBoolean
    #objSlot

"

	type := aSymbol
]
