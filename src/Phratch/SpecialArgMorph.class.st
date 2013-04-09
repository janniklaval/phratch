Class {
	#name : #SpecialArgMorph,
	#superclass : #ArgMorph,
	#instVars : [
		'type',
		'skin'
	],
	#category : #'Phratch-BYOB'
}

{ #category : #'as yet unclassified' }
SpecialArgMorph class >> example [
	| script dict block |
	"self example"

	script := nil.
	dict := Dictionary new.
	dict
		at: 'Any type' put: '%s';
		at: 'Number' put: '%n';
		at: 'Boolean (T/F)' put: '%b';
		at: 'Text' put: '%T';
		at: 'List' put: '%t';
		at: 'Command' put: '%o';
		at: 'Reporter' put: '%r';
		at: 'Predicate (Reporter of Boolean)' put: '%p'.

	dict keysDo: [:key |
		block := CommandBlockMorph new
			commandSpec: key, ': ', (dict at: key).
		script
			ifNil: [script := block]
			ifNotNil: [script bottomBlock attachBlock: block]].
	script openInWorld
]

{ #category : #'as yet unclassified' }
SpecialArgMorph >> acceptsDroppedReporters [

	^ true

]

{ #category : #'as yet unclassified' }
SpecialArgMorph >> acceptsTypeOf: aBlockMorph [
	"Answer true if I can accept a dropped reporter of the given type. Answer false by default."

	^ true

]

{ #category : #'as yet unclassified' }
SpecialArgMorph >> drawOn: aCanvas [

	(owner isKindOf: CReporterSlotMorph)
		ifTrue: [^ self].

	skin ifNil: [
		(owner isKindOf: BlockMorph) ifTrue: [
			#reporterslot = type
				ifTrue: [^ aCanvas fillOval: self bounds color: Color lightGray " (owner color mixed: 0.6 with: Color darkGray)" ]
				ifFalse: [

	| h s v darkerC lighterC right topY bottomY xInset c |

	color := (owner color mixed: 0.6 with: Color darkGray).
	h := color hue.
	s := color saturation.
	v := color brightness.
	darkerC := Color h: h s: (s - 0.3) v: (v - 0.3).
	lighterC := Color h: h s: (s - 0.2) v: (v + 0.2).

	color := Color lightGray.

	right := self width.
	topY := bottomY := self height // 2.
	self height even ifTrue: [topY := bottomY - 1].
	xInset := 0.
	[topY >= 0] whileTrue: [
		self drawHLineFrom: xInset to: (xInset + 2) y: topY color: darkerC on: aCanvas.
		c := (topY <= 1) ifTrue: [darkerC] ifFalse: [color].
		self drawHLineFrom: xInset + 2 to: right - (xInset + 1) y: topY color: c on: aCanvas.
		self drawHLineFrom: (right - (xInset + 1)) to: (right - xInset) y: topY color: darkerC on: aCanvas.

		self drawHLineFrom: xInset to: (xInset + 1) y: bottomY color: lighterC on: aCanvas.
		c := (bottomY >= (self height - 2)) ifTrue: [lighterC] ifFalse: [color].
		self drawHLineFrom: xInset + 1 to: right - (xInset + 1) y: bottomY color: c on: aCanvas.
		self drawHLineFrom: (right - (xInset + 2)) to: (right - xInset) y: bottomY color: lighterC on: aCanvas.

		xInset := xInset + 1.	
		bottomY := bottomY + 1.
		topY := topY - 1].
^self

]
		]].

	aCanvas paintImage: skin at: self position
]

{ #category : #'as yet unclassified' }
SpecialArgMorph >> evaluate [

	implicitValue notNil
		ifTrue: [^implicitValue].
	^nil

]

{ #category : #'as yet unclassified' }
SpecialArgMorph >> stringExpression: obj [

	"default is not to do anything"
]

{ #category : #'as yet unclassified' }
SpecialArgMorph >> type [
	^type
]

{ #category : #'as yet unclassified' }
SpecialArgMorph >> type: aSymbol [

	"currently BYOB supports the following first class types:

    #none		- a puzzle shaped command block
    #any		- a non-typed round reporter block (can be anything)
*    #string		- a round reporter block that answers a string
    #number	- a round reporter block that answers a number
*    #list			- a round reporter block that answers a number
    #boolean	- a hexagonal reporter block that answers a boolean
*    #command	- a round reporter block that answers a procedure (a command block)
*    #reporter	- a round reporter block that answers a function (a reporter block)
*    #predicate	- a hexagonal reporter block that answers a reporter of a boolean 
    #template	- a sunken variable blob that represents an externalized block variable
*   #reporterslot
*	#booleanslot
*	*objSlot

the ones marked by asterix (*) are represented by this class
"
	type := aSymbol.
	#objSlot = type ifTrue: [
		skin := PhratchFrameMorph skinAt: #objSlot].
	(#(reporterslot booleanslot objSlot) includes: type) ifFalse: [
		skin := PhratchFrameMorph skinAt: ('type', type asString capitalized) asSymbol].
	self 
		borderWidth: 0;
		cornerStyle: #square;
		extent: (skin ifNil: [type = #reporterslot ifTrue: [18@12] ifFalse: [23@14]] ifNotNil: [skin extent]).
]