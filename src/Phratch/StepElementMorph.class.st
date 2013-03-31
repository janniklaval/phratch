Class {
	#name : #StepElementMorph,
	#superclass : #SyntaxElementMorph,
	#instVars : [
		'expression',
		'next',
		'oldColor'
	],
	#category : #'Phratch-BYOB-Elements'
}

{ #category : #'as yet unclassified' }
StepElementMorph >> acceptDroppingMorph: aMorph event: evt [

	self next: aMorph
]

{ #category : #'as yet unclassified' }
StepElementMorph >> addExpression [
	expression := ArgumentElementMorph new.
"	expression color: color muchLighter."
	self addMorphFront: expression.
]

{ #category : #'as yet unclassified' }
StepElementMorph >> addToLast: anElement [
	self stack last next: anElement
]

{ #category : #'as yet unclassified' }
StepElementMorph >> asSmalltalk [
	expression ifNotNil: [^expression asSmalltalk]
]

{ #category : #'as yet unclassified' }
StepElementMorph >> borderWidth [
	^1

]

{ #category : #'as yet unclassified' }
StepElementMorph >> contextMenu [
	|m|
	m := MenuMorph new.
"	m add: 'duplicate' action: #duplicate. "
	m add: 'delete' action: #throwAway.
	m addLine.
	m add: 'show code...' action: #showGeneratedSmalltalk.
	m add: 'show result...' action: #showResult.
	m add: 'evaluate' action: #evaluate.
	^m
]

{ #category : #'as yet unclassified' }
StepElementMorph >> drawOn: aCanvas [ 

	|r bw indent dent bw2 bw3 |
	bw := self borderWidth.
	bw2 := bw * 2.
	bw3 := bw * 3.
	indent := bw * 5.
	dent := bw * 5.

	"border"
	"top"
	r := Rectangle origin: ((self left + bw) @ self top) corner: (self left + indent) @ (self top + bw).
	aCanvas fillRectangle: r color: self borderColorVeryLight.

	r := Rectangle origin: ((self left + indent - bw) @ (self top + bw)) corner: (self left + indent) @ (self top + bw3).
	aCanvas fillRectangle: r color: self borderColorDark.

	r := Rectangle origin: ((self left + indent) @ (self top + bw2)) corner: (self left + indent + dent + bw) @ (self top + bw3).
	aCanvas fillRectangle: r color: self borderColorVeryLight.

	r := Rectangle origin: ((self left + indent + dent) @ (self top)) corner: (self left + indent + dent + bw) @ (self top + bw2).
	aCanvas fillRectangle: r color: self borderColorLight.

	r := Rectangle origin: ((self left + indent + dent + bw) @ (self top)) corner: (self right) @ (self top + bw).
	aCanvas fillRectangle: r color: self borderColorVeryLight.

	"left"
	r := Rectangle origin: (self topLeft) corner: (self left + bw) @ (self bottom - bw3).
	aCanvas fillRectangle: r color: self borderColorLight.

	"right"
	r := Rectangle origin: ((self right - bw) @ (self top + bw)) corner: (self right @ (self bottom - bw2)).
	aCanvas fillRectangle: r color: self borderColorDark.

	"bottom"
	r := Rectangle origin: (self left @ (self bottom - bw3)) corner: (self left + indent) @ (self bottom - bw2).
	aCanvas fillRectangle: r color: self borderColorVeryDark.

	r := Rectangle origin: (self left + indent) @ (self bottom - bw3) corner: (self left + indent + bw) @ (self bottom - bw).
	aCanvas fillRectangle: r color: self borderColorLight.

	r := Rectangle origin: (self left + indent) @ (self bottom - bw) corner: (self left + indent + dent - bw) @ (self bottom).
	aCanvas fillRectangle: r color: self borderColorVeryDark.

	r := Rectangle origin: (self left + indent + dent - bw) @ (self bottom - bw2) corner: (self left + indent + dent) @ (self bottom).
	aCanvas fillRectangle: r color: self borderColorDark.

	r := Rectangle origin: (self left + indent + dent - bw) @ (self bottom - bw3) corner: (self right - bw) @ (self bottom - bw2).
	aCanvas fillRectangle: r color: self borderColorVeryDark.

	"body"
"	aCanvas fillRectangle: (Rectangle origin: (self left + bw) @ (self top + bw3) corner: (self right - bw) @ (self bottom - bw3)) color: color."

	aCanvas fillRectangle: (Rectangle origin: (self left + bw) @ (self top + bw3) corner: (self right - bw) @ (self center y - bw)) color: color twiceLighter.

	aCanvas fillRectangle: (Rectangle origin: (self left + bw) @ (self center y - bw) corner: (self right - bw) @ (self center y)) color: color lighter.

	aCanvas fillRectangle: (Rectangle origin: (self left + bw) @ (self center y) corner: (self right - bw) @ (self bottom - bw3)) color: color.


	aCanvas fillRectangle: (Rectangle origin: (self left + bw) @ (self top + bw) corner: (self left + indent - bw) @ (self top + bw3)) color: color twiceLighter.

	aCanvas fillRectangle: (Rectangle origin: (self left + indent + dent + bw) @ (self top + bw) corner: (self right - bw) @ (self top + bw3)) color: color twiceLighter.

	aCanvas fillRectangle: (Rectangle origin: (self left + indent + bw) @ (self bottom - bw3) corner: (self left + indent + dent - bw) @ (self bottom - bw)) color: color.

]

{ #category : #'as yet unclassified' }
StepElementMorph >> expression [
	^expression contents
]

{ #category : #'as yet unclassified' }
StepElementMorph >> expression: anElement [
	expression contents: anElement
]

{ #category : #'as yet unclassified' }
StepElementMorph >> fit [

	| cw handle bw x y|
	bw := self borderWidth.
	cw := self labelFont widthOf: $ .
	handle := cw * 3.

	self width: expression width  + handle + (bw * 3).
	self height: expression height + (bw * 7).


	x := self left + bw + handle.
	y := (bounds center - (expression extent // 2)) y.

	expression position: x @ y.

	next isNil ifFalse:[
		next position: self left @ (self bottom - (self borderWidth * 2))].

	(owner respondsTo: #fit)
		ifTrue: [owner fit]
]

{ #category : #'as yet unclassified' }
StepElementMorph >> handlesMouseOverDragging: evt [
	"Return true if I want to receive mouseEnterDragging: and mouseLeaveDragging: when the hand drags something over me (button up or button down), or when the mouse button is down but there is no mouseDown recipient. The default response is false; subclasses that implement mouse mouseEnterDragging messages should override this to return true."

	"NOTE:  If the hand state matters in these cases, it may be tested by constructs such as
		event anyButtonPressed
		event hand hasSubmorphs"

	^ true

]

{ #category : #'as yet unclassified' }
StepElementMorph >> hilite [

	oldColor := color.
	self color: Color white.
	self allOwners do: [:each|
		(each isKindOf: StepElementMorph)
			ifTrue: [each unHilite ]]
]

{ #category : #'as yet unclassified' }
StepElementMorph >> initialize [
	super initialize.
	color := Color lightGreen twiceDarker.
	self addExpression.
	self fit.
]

{ #category : #'as yet unclassified' }
StepElementMorph >> isLast [
	^next isNil
]

{ #category : #'as yet unclassified' }
StepElementMorph >> labelFont [
	^StrikeFont fontName: 'Verdana' size: 10
]

{ #category : #'as yet unclassified' }
StepElementMorph >> last [
	self isLast
		ifTrue: [^self]
		ifFalse: [^next last]
]

{ #category : #'as yet unclassified' }
StepElementMorph >> mouseEnterDragging: evt [
	"Handle a mouseEnterDragging event. The mouse just entered my bounds with a button pressed or laden with submorphs. This default implementation does nothing."

	| m |
	evt hand hasSubmorphs ifFalse: [^self].
	m := evt hand submorphs first.
	(self wantsDroppedMorph: m event: evt)
		ifTrue: [
			self hilite ].
]

{ #category : #'as yet unclassified' }
StepElementMorph >> mouseLeaveDragging: evt [
	"Handle a mouseLeaveLaden event. The mouse just left my bounds with a button pressed or laden with submorphs. This default implementation does nothing."

	self unHilite
]

{ #category : #'as yet unclassified' }
StepElementMorph >> next [
	^next
]

{ #category : #'as yet unclassified' }
StepElementMorph >> next: anElement [
	next := anElement.
	self addMorphFront: next.
	self fit.
	self unHilite
]

{ #category : #'as yet unclassified' }
StepElementMorph >> removeNext [
	| holder |
	next ifNotNil: [next := nil ].
	holder := self ownerThatIsA: StepHolderElementMorph.
	holder ifNotNil: [holder fit]
]

{ #category : #'as yet unclassified' }
StepElementMorph >> representsNil [

	^self isLast & expression contents isNil
]

{ #category : #'as yet unclassified' }
StepElementMorph >> stack [
	| list step |
	list := OrderedCollection with: self.
	step := self.
	[step next notNil] whileTrue: [
		step := step next.
		list add: step ].
	^list
	
]

{ #category : #'as yet unclassified' }
StepElementMorph >> stackExtent [
	| w h |
	w := self width.
	h := 0.
	self stack do: [:each|
		w := w max: each width.
		h := h + each height].
	h := h - ((self borderWidth * 2) * (self stack size -1)).
	^w@h
]

{ #category : #'as yet unclassified' }
StepElementMorph >> unHilite [

	oldColor ifNotNil: [
		self color: oldColor]
]

{ #category : #'as yet unclassified' }
StepElementMorph >> wantsDroppedMorph: aMorph event: evt [

	^next isNil & (aMorph isKindOf: self class) & (self ownerThatIsA: ElementPaletteMorph) isNil

]
