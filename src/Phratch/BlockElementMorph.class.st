Class {
	#name : #BlockElementMorph,
	#superclass : #SyntaxElementMorph,
	#instVars : [
		'palette',
		'steps'
	],
	#category : #'Phratch-BYOB-Elements'
}

{ #category : #'as yet unclassified' }
BlockElementMorph >> addStep: aStepElement [
	steps contents isNil 
		ifTrue: [steps contents: aStepElement]
		ifFalse: [steps contents addToLast: aStepElement]
]

{ #category : #'as yet unclassified' }
BlockElementMorph >> addVarNames: aCollection [
	palette addVarNames: aCollection

]

{ #category : #'as yet unclassified' }
BlockElementMorph >> addVariable [
	|ans|

	ans := UIManager request: 'add variable:'.
	(ans size > 0) ifTrue: [self addVarNames: (Array with: (SyntaxElementMorph objectNameFrom: ans))]
]

{ #category : #'as yet unclassified' }
BlockElementMorph >> addVariableNamed: aSymbol [
	palette addVariableNamed: aSymbol
]

{ #category : #'as yet unclassified' }
BlockElementMorph >> addVariables [
	|ans|

	ans := UIManager request: 'add variables:'.
	(ans size > 0) ifTrue: [self addVarNames: (ans findTokens: ' ')]
]

{ #category : #'as yet unclassified' }
BlockElementMorph >> allVariableNames [
	^self variableNames
]

{ #category : #'as yet unclassified' }
BlockElementMorph >> asSmalltalk [
	| ws vn|
	ws := WriteStream on: String new.
	ws nextPut: $[.
	(vn := self variableNames) isEmpty ifFalse: [
		vn do: [:n|
			ws nextPut: $:.
			ws nextPutString: n, ' ' ].
		ws nextPutString: '| '].
	ws nextPutString: steps asSmalltalk, ']'.
	^ws contents
]

{ #category : #'as yet unclassified' }
BlockElementMorph >> contextMenu [
	|m|
	m := MenuMorph new.
"	m add: 'duplicate' action: #duplicate. "
	m add: 'delete' action: #throwAway.
	m add: 'add variable...' action: #addVariable.
	m addLine.
	m add: 'show code...' action: #showGeneratedSmalltalk.
	m add: 'show result...' action: #showResult.
	m add: 'evaluate' action: #evaluate.
	^m
]

{ #category : #'as yet unclassified' }
BlockElementMorph >> evaluate [
	^Compiler evaluate: self asSmalltalk, ' value'
]

{ #category : #'as yet unclassified' }
BlockElementMorph >> fit [
	| bw bw2 cw handle x y|
	bw := self borderWidth.
	bw2 := bw * 2.
	cw := self labelFont widthOf: $ .
	handle := cw * 2.

	palette position: (self left + handle) @ (self top).
	(palette height = 0)
		ifTrue: [y := self top + (bw * 3)]
		ifFalse: [y := palette bottom].
	

	steps position: (self left + bw2 + handle) @ y.

	x := (steps right + bw2) max: palette right.

	self width: x - self left.
	(palette height = 0)
		ifTrue: [ self height: steps height + (self borderWidth * 5) ]
		ifFalse: [self height: steps height + palette height + (bw2) ].

	self refreshVarColors.

	(owner respondsTo: #fit)
		ifTrue: [owner fit]

]

{ #category : #'as yet unclassified' }
BlockElementMorph >> initialize [
	super initialize.
	color := Color paleBlue darker.
	palette := PaletteElementMorph new.
	self addMorph: palette.
	steps := StepHolderElementMorph new.
	steps color: color slightlyDarker.
	self addMorph: steps.
	self fit.
]

{ #category : #'as yet unclassified' }
BlockElementMorph >> refreshVarColors [

	self allMorphsDo: [:m|
		((m isMemberOf: ObjectElementMorph) and: [
			self allVariableNames includes: m name]) ifTrue: [
				m color: self varColor ]]
]

{ #category : #'as yet unclassified' }
BlockElementMorph >> rootForGrabOf: aMorph [
	"Allow myself to be extracted."

	(self ownerThatIsA: ElementPaletteMorph) ifNotNil: [
		(self ownerThatIsA: MessageElementMorph)
			ifNotNil: [^owner rootForGrabOf: owner ]].
	^super rootForGrabOf: aMorph
]

{ #category : #'as yet unclassified' }
BlockElementMorph >> steps [
	^steps contents
]

{ #category : #'as yet unclassified' }
BlockElementMorph >> varColor [
	^palette varColor
]

{ #category : #'as yet unclassified' }
BlockElementMorph >> variableNames [
	^palette variableNames
]
