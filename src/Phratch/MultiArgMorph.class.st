Class {
	#name : #MultiArgMorph,
	#superclass : #ArgMorph,
	#instVars : [
		'text',
		'type',
		'minArgCount',
		'defaultArgCount',
		'isWrapping'
	],
	#category : #'Phratch-BYOB'
}

{ #category : #'as yet unclassified' }
MultiArgMorph class >> type: aSymbol [
	^ self new
		type: aSymbol;
		text: '';
		buildControls
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> addArg: aBlockOrValue [

	| newMorph newSubs |
	((aBlockOrValue isKindOf: CommandBlockMorph) or: [
		aBlockOrValue isKindOf: ArgMorph])
		ifTrue: [newMorph := aBlockOrValue]
		ifFalse: [newMorph := self newSlot].
	newMorph owner ifNotNil: [
		newMorph owner privateRemoveMorph: newMorph].
	newMorph layoutChanged.
	newMorph privateOwner: self.
	newSubs := Array new: submorphs size + 1.
	1 to: submorphs size - 2 do: [:i |
		newSubs at: i put: (submorphs at: i) ].
	newSubs at: submorphs size - 1 put: newMorph.
	newSubs at: submorphs size put: self lessButton.
	newSubs at: submorphs size + 1 put: self moreButton.
	submorphs := newSubs.
	newMorph changed.
	self layoutChanged	
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> addArgSlot [

	(owner isKindOf: BlockMorph) ifTrue: [
		owner stop].

	self addArg: self newSlot;
	fixArgLayout
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> argMorphToReplace: aBlock [
	^ self newSlot
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> buildControls [

	submorphs do: [:sm | sm delete].

	self addMorphBack: ((ScratchStringMorph contents: text font: (ScratchFrameMorph getFont: #Label))
		color: ((owner respondsTo: #labelColor) ifTrue: [owner labelColor] ifFalse: [Color white])).

	self addMorphBack: (ImageMorph new form: (ArgMorph dropDownMenuForm rotateBy: 90)).

	self addMorphBack: (ImageMorph new form: (ArgMorph dropDownMenuForm rotateBy: -90)).

	self fixArgLayout

]

{ #category : #'as yet unclassified' }
MultiArgMorph >> color [
	(owner respondsTo: #color) ifTrue: [
		^owner color]
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> contrastColor [
	submorphs do: [:m |	(m isKindOf: BlockMorph)
		ifTrue: [ m contrastColor ]]
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> defaultArgCount [
	^ defaultArgCount
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> defaultArgCount: anInt [
	defaultArgCount := anInt
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> defaultValue: aScratchListMorph [
	"Set my default value"

	| element |

	(aScratchListMorph isKindOf: ScratchListMorph)
		ifFalse: [^ self].
	1 to: aScratchListMorph lineCount do: [:i |
		element := aScratchListMorph lineAt: i.
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
						element = 'nil' asUTF8
							ifTrue: [element := nil].
						self elements last defaultValue: element ]]]
		
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> elements [
	^ submorphs reject: [:sm |
		(sm isKindOf: ImageMorph)
		or: [sm isKindOf: ScratchStringMorph]]
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> evaluate [
	 | list |

	(self isEmptySlot and: [implicitValue notNil])
		ifTrue: [^implicitValue].

	list := ScratchListMorph new.
	list listName: '' target: nil.
	self elements do: [:each |
		list insertLine:  (ScriptableScratchMorph new asListElement: each evaluate) at: (list lineCount + 1) ].
	list updateCountMorph.
	list fixLayout.
	list startStepping.
	^list	
]

{ #category : #'-- all --' }
MultiArgMorph >> fixArgLayout [

	| maxHeight x space shouldHide lines line left maxX parts w y mh h isMultiC |

	shouldHide := (submorphs size - 3 > minArgCount) not.
	self lessButton isHidden: shouldHide.
	self label isHidden: shouldHide.
	isMultiC := #(loop reporterSlot) includes: type.
	lines := OrderedCollection new.


	"distribute parts horizontally and cut up into lines"

	line := OrderedCollection new.
	x := self left.
	left := x.
	maxX := x.
	space := 4.

	isMultiC ifTrue: [
		self width: 50 ].

	parts := submorphs select: [:sm| sm isVisible and: [(sm isKindOf: ScratchStringMorph) not]].

	parts do: [:m |
	(m isKindOf: ReporterBlockMorph) & isMultiC
		ifTrue: [ "in this case just break up into lines, don't distribute yet"
			m left: self left.
			lines add: (OrderedCollection with: m).
			m fixBlockLayout.
			((m isKindOf: CArgSlotMorph) or: [m isKindOf: CReporterSlotMorph]) ifTrue: [
				m width: self width].
			maxX := maxX max: left + m width.
			x := left ]
		ifFalse: [
			(x - left > 300 and: [m ~~ submorphs last]) ifTrue: [
				lines add: line.
				line := OrderedCollection new.
				x := left].
			(m isKindOf: BlockMorph) ifTrue: [m fixBlockLayout].
			(m isKindOf: ArgMorph) ifTrue: [m fixArgLayout].

			m left: x.
			(m right - left > 300 and: [line isEmpty not and: [m ~~ submorphs last]])
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
	w := maxX - self left max: 4.

	isWrapping := lines size > 1.

	"distribute lines vertically"

	space := 0.
	y := self top.
	isWrapping & isMultiC not ifTrue: [
		space := 1.
		y := self top + 2].
	lines do: [:eachLine |
		maxHeight := 10.
		eachLine do: [:m |
			((m isKindOf: ReporterBlockMorph)
			and: [m isBlockTemplate and: [m isEmptySlot not]])
				ifTrue: [mh := m height + 7]
				ifFalse: [mh := m height].
			maxHeight := mh max: maxHeight].
		eachLine do: [:m |
			m top: y + (maxHeight - m height // 2)].
		y := y + maxHeight + space].
	h := y - self top + space.

	self extent: w @ h.

	self layoutChanged.
	owner ifNotNil: [owner layoutChanged].


]

{ #category : #'as yet unclassified' }
MultiArgMorph >> fixArgLayoutNoWrap [

	| maxHeight newWidth x space shouldHide visible |

	x := self left.
	space := 4.
	shouldHide := (submorphs size - 3 > minArgCount) not.
	self lessButton isHidden: shouldHide.
	self label isHidden: shouldHide.
	visible := submorphs select: [:sm| sm isVisible].
	maxHeight := (visible collect: [:sm | sm height]) max.
	visible do: [: sm |
		(sm = self label or: [| e | e := self elements. e isEmpty or: [sm = e first]]) 
			ifTrue: [ x := x - 2]
			ifFalse: [ x := x + space].
		sm position: x @ (self top + (maxHeight - sm height // 2)).
		sm changed.
		x := x + sm width].
	newWidth := x - self left.
	self extent: newWidth @ maxHeight.
	self layoutChanged.
	owner ifNotNil: [owner layoutChanged].


]

{ #category : #'as yet unclassified' }
MultiArgMorph >> handlesMouseDown: evt [

	| more less |
	more := self moreButton.
	less := self lessButton.
	^ (more isVisible & (more containsPoint: evt cursorPoint))
		or: [less isVisible & (less containsPoint: evt cursorPoint)]

]

{ #category : #'as yet unclassified' }
MultiArgMorph >> initialize [

	super initialize.
	isWrapping := false.
	self color: Color transparent.
	self borderWidth: 0.
	text := ''.
	type := #any.
	minArgCount := 0.
	defaultArgCount := 1.
	self buildControls.

]

{ #category : #'as yet unclassified' }
MultiArgMorph >> isEmptySlot [


	^self elements isEmpty
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> isLambdaForm [
	^false
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> isWrapping [
	^isWrapping

]

{ #category : #'as yet unclassified' }
MultiArgMorph >> label [
	^ submorphs first
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> lessButton [
	^ submorphs at: submorphs size - 1
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> listValue [
	 | list item |
	list := ScratchListMorph new.
	list listName: '' target: nil.
	self elements do: [:each |
		(each isKindOf: ReporterBlockMorph)
			ifTrue: [item := each]
			ifFalse: [each isEmptySlot
				ifTrue: [item := nil]
				ifFalse: [item := each evaluate]].
		list insertLine: (ScriptableScratchMorph new asListElement: item) at: (list lineCount + 1) ].
	list updateCountMorph.
	^list	
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> loopsWidth: anInteger [

	| parts |

	type = #loop ifFalse: [^ self].
	self width: (anInteger max: 50).
	parts := submorphs select: [:sm | (sm isKindOf: CArgSlotMorph) or: [sm isKindOf: CReporterSlotMorph]].
	parts do: [:m |
		m width: self width ]

]

{ #category : #'as yet unclassified' }
MultiArgMorph >> minArgCount [
	^ minArgCount
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> minArgCount: anInt [
	minArgCount := anInt
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> moreButton [
	^ submorphs at: submorphs size
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
MultiArgMorph >> newSlot [

	| specs slot |
	specs := Dictionary new.
	specs
		at: #command put: '%o';
		at: #reporter put: '%r';
		at: #predicate put: '%p';
		at: #list put: '%t';
		at: #text put: '%T';
		at: #any put: '%s';
		at: #boolean put: '%b';
		at: #number put: '%n';
		at: #loop put: '%G';
		at: #unevaluated put: '%j';
		at: #unevaluatedBoolean put: '%Q';
		at: #objSlot put: '%1'.

" +++ deprecated experimental slots    -jens ++++++

		at: #reporterSlot put: '%K';
		at: #typeInReporter put: '%j'.

+++++++++++++++++++++++++++++++++++++++++++++++"

	slot := CommandBlockMorph new uncoloredArgMorphFor: (specs at: type ifAbsent: [ '%s']).
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

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
MultiArgMorph >> replaceArgMorph: oldArg by: newArg [

	self replaceSubmorph: oldArg by: newArg

]

{ #category : #'error handling' }
MultiArgMorph >> showError [
	"Make this block to show an error."

	(owner isKindOf: BlockMorph) ifTrue: [
		owner showError]
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> tabFields [

	| fields |
	fields _	OrderedCollection new.
	submorphs do: [:m |
		(m isKindOf: ReporterBlockMorph)
			ifTrue: [fields addAll: m tabFields ]
			ifFalse: [(m isKindOf: ExpressionArgMorph)
				ifTrue: [fields add: m]]].
	^ fields
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> text [
	^ text
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> text: aString [
	text := aString
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> topBlock [

	(owner isKindOf: BlockMorph) ifTrue: [
		^owner topBlock].
	^nil

]

{ #category : #'as yet unclassified' }
MultiArgMorph >> transparentRect [
	^ self position corner: (self right@submorphs last top)
]

{ #category : #'as yet unclassified' }
MultiArgMorph >> type [
	^type
]

{ #category : #'as yet unclassified' }
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
