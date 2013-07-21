Class {
	#name : #ObjectElementMorph,
	#superclass : #SyntaxElementMorph,
	#category : #'Phratch-UI-Elements'
}

{ #category : #'as yet unclassified' }
ObjectElementMorph >> asSmalltalk [ 

	^name ifNil: ['undefined']
]

{ #category : #'as yet unclassified' }
ObjectElementMorph >> contextMenu [
	|m|
	m := MenuMorph new.
"	m add: 'duplicate' action: #duplicate. "
	m add: 'delete' action: #throwAway.
	(owner class == PaletteElementMorph)
		ifTrue: [m add: 'remove' action: #removeFromPalette ]
		ifFalse: [
		 	self isRenameable ifTrue: [
				m add: 'rename...' action: #editLabel ]].
	m addLine.
	m add: 'show code...' action: #showGeneratedSmalltalk.

	^m
]

{ #category : #'as yet unclassified' }
ObjectElementMorph >> editLabel [
	|ans|

	ans := UIManager request: 'rename:' initialAnswer: label contents.
	(ans size > 0) ifTrue: [self label: ans]
]

{ #category : #'as yet unclassified' }
ObjectElementMorph >> initialize [
	super initialize.
	color := Color blue darker.

]

{ #category : #'as yet unclassified' }
ObjectElementMorph >> isRenameable [
	| editor method |
	editor := (self ownerThatIsA: ElementsMethodEditorMorph).
	editor isNil ifTrue: [^true].
	method := (self ownerThatIsA: MethodElementMorph).
	method ifNotNil: [
		^(self ownerThatIsA: StepHolderElementMorph) isNil].
	^false

]

{ #category : #'as yet unclassified' }
ObjectElementMorph >> label [
	^label contents
]

{ #category : #'as yet unclassified' }
ObjectElementMorph >> label: aString [

	super label: aString.

	(owner isKindOf: PaletteElementMorph)
		ifTrue: [^self color: owner ownerColor twiceDarker ].

	(#('self' 'super' 'nil' 'true' 'false' 'thisContext') includes: aString)
		ifTrue: [^self color: Color red darker].

	aString first isUppercase
		ifTrue: [
			(Smalltalk classNames includes: aString asSymbol)
				ifTrue: [^self color: Color magenta darker darker].
			(Smalltalk keys includes: aString asSymbol)
				ifTrue: [^self color: Color magenta twiceDarker darker].

			^self color: Color blue twiceDarker ].

	self color: Color blue darker..


]

{ #category : #'as yet unclassified' }
ObjectElementMorph >> labelFont [
	^StrikeFont fontName: 'Verdana' size: 10
]

{ #category : #'as yet unclassified' }
ObjectElementMorph >> removeFromPalette [
	owner removeVariable: self
]

{ #category : #'as yet unclassified' }
ObjectElementMorph >> representsNil [
	^name = 'nil'
]
