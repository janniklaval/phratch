Class {
	#name : #ArgumentElementMorph,
	#superclass : #SyntaxElementMorph,
	#instVars : [
		'contents',
		'oldColor'
	],
	#category : #'Phratch-BYOB-Elements'
}

{ #category : #'as yet unclassified' }
ArgumentElementMorph >> acceptDroppingMorph: aMorph event: evt [

	self contentsForced: aMorph
]

{ #category : #'as yet unclassified' }
ArgumentElementMorph >> asSmalltalk [

	contents ifNil: [^'nil '].
	((#(	BlockElementMorph
		LiteralElementMorph
		ObjectElementMorph
	) includes: contents class printString asSymbol)
		or: [owner isKindOf: StepElementMorph])
		ifTrue: [^contents asSmalltalk].

	(contents isKindOf: MessageElementMorph) ifTrue: [
		contents isUnary ifTrue: [^contents asSmalltalk].

		contents isBinary ifTrue: [
			owner isKeywords ifTrue: [ ^contents asSmalltalk]]

	].

	^'(', contents asSmalltalk, ')'
]

{ #category : #'as yet unclassified' }
ArgumentElementMorph >> contents [
	^contents
]

{ #category : #'as yet unclassified' }
ArgumentElementMorph >> contents: anElement [
	contents ifNotNil: [contents delete].
	anElement representsNil ifFalse: [
		contents := anElement.
		self addMorphFront: contents ].
	self fit.
	self unHilite

]

{ #category : #'as yet unclassified' }
ArgumentElementMorph >> contentsForced: anElement [
	contents ifNotNil: [contents delete].
	contents := anElement.
	contents position: self position.
	self addMorphFront: contents.
	self fit.
	self unHilite

]

{ #category : #'as yet unclassified' }
ArgumentElementMorph >> drawOn: aCanvas [ 

	|r bw|

	bw := self borderWidth.

	"border"
	"top"
	r := Rectangle origin: ((self left + bw) @ self top) corner: (self right @ (self top + bw)).
	aCanvas fillRectangle: r color: self borderColorVeryDark.

	"left"
	r := Rectangle origin: (self topLeft) corner: (self left + bw) @ (self bottom - bw).
	aCanvas fillRectangle: r color: self borderColorDark.

	"right"
	r := Rectangle origin: ((self right - bw) @ (self top + bw)) corner: self bottomRight.
	aCanvas fillRectangle: r color: self borderColorLight.

	"bottom"
	r := Rectangle origin: (self left @ (self bottom - bw)) corner: (self right - bw) @ self bottom.
	aCanvas fillRectangle: r color: self borderColorVeryLight.

	"body"
	aCanvas fillRectangle: (Rectangle origin: (self topLeft + bw) corner: (self bottomRight - bw)) color: color

]

{ #category : #'as yet unclassified' }
ArgumentElementMorph >> fit [
	| h |
	contents isNil
		ifTrue: [
			h := MessageElementMorph labelFont height.
			self extent: h @ h]
		ifFalse: [
			self extent: contents extent " + (self borderWidth * 2)".
			"(owner isKindOf: StepElementMorph)
				ifTrue: [self extent: self extent + (self borderWidth * 2)]."
			contents position: bounds center - (contents extent // 2) ].
	(owner respondsTo: #fit)
		ifTrue: [owner fit]
]

{ #category : #'as yet unclassified' }
ArgumentElementMorph >> handlesMouseOverDragging: evt [
	"Return true if I want to receive mouseEnterDragging: and mouseLeaveDragging: when the hand drags something over me (button up or button down), or when the mouse button is down but there is no mouseDown recipient. The default response is false; subclasses that implement mouse mouseEnterDragging messages should override this to return true."

	"NOTE:  If the hand state matters in these cases, it may be tested by constructs such as
		event anyButtonPressed
		event hand hasSubmorphs"

	^ true

]

{ #category : #'as yet unclassified' }
ArgumentElementMorph >> hilite [
	oldColor := color.
	self color: Color white
]

{ #category : #'as yet unclassified' }
ArgumentElementMorph >> initialize [
	super initialize.
	color := Color veryVeryLightGray.
	self fit
]

{ #category : #'as yet unclassified' }
ArgumentElementMorph >> mouseEnterDragging: evt [
	"Handle a mouseEnterDragging event. The mouse just entered my bounds with a button pressed or laden with submorphs. This default implementation does nothing."

	| m |
	evt hand hasSubmorphs ifFalse: [^self].
	m := evt hand submorphs first.
	(self wantsDroppedMorph: m event: evt)
		ifTrue: [
			self extent: m extent  + (self borderWidth * 2).
			self hilite ].
	(owner respondsTo: #fit)
		ifTrue: [owner fit]
]

{ #category : #'as yet unclassified' }
ArgumentElementMorph >> mouseLeaveDragging: evt [
	"Handle a mouseLeaveLaden event. The mouse just left my bounds with a button pressed or laden with submorphs. This default implementation does nothing."

	self fit.
	self unHilite
]

{ #category : #'as yet unclassified' }
ArgumentElementMorph >> removeContents [
	contents ifNotNil: [ contents := nil ].
	self fit.

]

{ #category : #'as yet unclassified' }
ArgumentElementMorph >> rootForGrabOf: aMorph [
	"Answer the root of the morph structure to be picked up when the given morph is grabbed."

	owner ifNotNil: [^owner rootForGrabOf: aMorph].
	^nil

"	(self isSticky and: [self isPartsDonor not])
		ifTrue: [^ nil]
		ifFalse: [
			(owner isNil or: [owner isWorldOrHandMorph])
				ifTrue: [^ self]
				ifFalse: [
					owner allowSubmorphExtraction
						ifTrue: [^ self]
						ifFalse: [^ owner rootForGrabOf: aMorph]]].
"
]

{ #category : #'as yet unclassified' }
ArgumentElementMorph >> unHilite [

	oldColor ifNotNil: [
		self color: oldColor]
]

{ #category : #'as yet unclassified' }
ArgumentElementMorph >> wantsDroppedMorph: aMorph event: evt [

	^contents isNil 
		& (self ownerThatIsA: ElementPaletteMorph) isNil
		& ((aMorph isKindOf: ObjectElementMorph) 
		| (aMorph isKindOf: LiteralElementMorph) 
		| (aMorph isKindOf: BlockElementMorph) 
		| (aMorph isKindOf: MessageElementMorph))
]
