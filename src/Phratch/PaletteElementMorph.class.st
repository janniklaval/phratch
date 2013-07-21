Class {
	#name : #PaletteElementMorph,
	#superclass : #SyntaxElementMorph,
	#instVars : [
		'variables'
	],
	#category : #'Phratch-UI-Elements'
}

{ #category : #'as yet unclassified' }
PaletteElementMorph >> addVarNames: aCollectionOfSymbols [
	aCollectionOfSymbols do: [:each|
		self addVariableNamed: each asSymbol ]
]

{ #category : #'as yet unclassified' }
PaletteElementMorph >> addVariableNamed: aSymbol [

	| v |
	v := ObjectElementMorph new label: aSymbol asString.
	v color: self varColor.
	variables at: aSymbol put: v.
	self addMorph: v.
	self fit
]

{ #category : #'as yet unclassified' }
PaletteElementMorph >> drawOn: aCanvas [ 

^self
]

{ #category : #'as yet unclassified' }
PaletteElementMorph >> fit [
	| x y bw2|
	bw2 := self borderWidth * 2.

	variables isEmpty ifTrue: [
		self extent: 0@0.
		(owner respondsTo: #fit)
			ifTrue: [^owner fit]
			ifFalse: [^self]].

	self height: variables anyOne height + (bw2 * 2).
	x := self left + bw2.
	y := (self center - (variables anyOne extent // 2)) y.
	variables keys asSortedCollection do: [:vn |
		(variables at: vn) position: x @ y.
		x := (variables at: vn) right + bw2.
		].
	self width: (x - self position x).

	(owner respondsTo: #fit)
		ifTrue: [^owner fit]
]

{ #category : #'as yet unclassified' }
PaletteElementMorph >> initialize [
	super initialize.
	variables := Dictionary new.
	color := Color transparent.
	self fit
]

{ #category : #'as yet unclassified' }
PaletteElementMorph >> isPartsBin [

	^ true

]

{ #category : #'as yet unclassified' }
PaletteElementMorph >> ownerColor [
	owner ifNotNil: [^owner color].
	^Color gray
]

{ #category : #'as yet unclassified' }
PaletteElementMorph >> removeVariable: element [

	element delete.
	variables removeKey: element name asSymbol.
	self fit
]

{ #category : #'as yet unclassified' }
PaletteElementMorph >> rootForGrabOf: aMorph [
	"I act like a parts bin; answer a new copy of the morph being extracted."

	| v |
	v := aMorph ownerThatIsA: ObjectElementMorph.
	v ifNotNil: [^v fullCopy].

	(owner isKindOf: MethodElementMorph)
		ifTrue: [^owner rootForGrabOf: aMorph].
	^owner
]

{ #category : #'as yet unclassified' }
PaletteElementMorph >> varColor [
	| oc |
	oc := owner color.
	^Color
		h: oc hue s: 0.5 v: 0.5
"	^owner color mixed: 0.93 with: Color black"
]

{ #category : #'as yet unclassified' }
PaletteElementMorph >> variableNames [
	^variables collect: [:m| m name ]
]
