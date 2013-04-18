"
I represent a literal value such as a number or string. I can be edited.

"
Class {
	#name : #ExpressionArgMorph,
	#superclass : #ArgMorph,
	#instVars : [
		'isNumber',
		'isText'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #queries }
ExpressionArgMorph >> acceptsDroppedReporters [

	^ true

]

{ #category : #queries }
ExpressionArgMorph >> acceptsTypeOf: aBlockMorph [
	"Answer true if I can accept a dropped reporter of the given type."

	aBlockMorph isReporter ifFalse: [^ false].
	(aBlockMorph isKindOf: ColorBlockMorph) ifTrue: [^ false].
	^ isNumber not or: [aBlockMorph isBooleanReporter not]

]

{ #category : #accessing }
ExpressionArgMorph >> defaultValue: anObject [

	(isNumber or: [anObject isNumber]) ifTrue: [^self numExpression: anObject].
	(anObject isKindOf: String) ifTrue: [self stringExpression: anObject].

]

{ #category : #accessing }
ExpressionArgMorph >> defaultValueFromSpec: anObject [
	"Like defaultValue:, but '-' in a block spec creates an empty number expression."

	'-' asUTF8 = anObject 
		ifTrue: [self numExpression: ' ']  "empty, evaluates to zero"
		ifFalse: [self defaultValue: anObject].


]

{ #category : #drawing }
ExpressionArgMorph >> drawOn: aCanvas [ 

	| darkerC right topY bottomY radius xInset c |
	isNumber ifFalse: [^ super drawOn: aCanvas].

	darkerC := Color gray.
	right := self width.
	topY := bottomY := radius := self height // 2.
	self height even ifTrue: [topY := bottomY - 1].
	[topY >= 0] whileTrue: [
		xInset := radius - (radius squared - (radius - topY - 1) squared) sqrt rounded.

		self drawHLineFrom: xInset to: (xInset + 1) y: topY color: darkerC on: aCanvas.
		c := (topY < 1) ifTrue: [darkerC] ifFalse: [Color white].
		self drawHLineFrom: xInset + 1 to: right - (xInset + 1) y: topY color: c on: aCanvas.
		self drawHLineFrom: (right - (xInset + 1)) to: (right - xInset) y: topY color: darkerC on: aCanvas.

		self drawHLineFrom: xInset to: right - xInset y: bottomY color: Color white on: aCanvas.

		xInset = 0 ifTrue: [
			self drawHLineFrom: xInset + 1 to: xInset + 2 y: topY color: Color white on: aCanvas.
			self drawHLineFrom: xInset to: xInset + 1 y: bottomY color: darkerC on: aCanvas.
			self drawHLineFrom: (right - (xInset + 1)) to: (right - xInset) y: bottomY color: darkerC on: aCanvas].

		bottomY := bottomY + 1.
		topY := topY - 1].

]

{ #category : #evaluation }
ExpressionArgMorph >> evaluate [
	"Answer the result of evaluating my expression in the context of the given PhratchProcess."

	| expr |

	(self isEmptySlot and: [implicitValue notNil])
		ifTrue: [^implicitValue].

	expr := labelMorph savedContents.
	isNumber
		ifTrue: [^ expr asNumberNoError]
		ifFalse: [^ expr].  

]

{ #category : #'object i/o' }
ExpressionArgMorph >> fieldsVersion [

	^ 1

]

{ #category : #private }
ExpressionArgMorph >> fixArgLayout [

	| top xInset extraW |
	top := self top.
	isNumber
		ifTrue: [
			self extent: labelMorph extent + (5 @ 0).
			"tiny vertical adjustment to account for differences in string rendering"
"SPFA			Smalltalk isWindows ifFalse: [top := top + 1]."
			"for tall fonts, add extra width"
			extraW := (self height - (1.3 * self width) rounded) max: 0.
			extraW > 0 ifTrue: [self width: self width + extraW].
			xInset := 4 + (extraW // 2)]
		ifFalse: [
			isText
				ifTrue: [
					self extent: labelMorph extent + (2 @ 0).
					self width: (self width max: 25).
					xInset := 3]
				ifFalse: [
					self extent: labelMorph extent + (2 @ 0).
					xInset := 3]].

	PhratchTranslator isRTL
		ifTrue: [labelMorph position: (self right - (xInset + labelMorph width)) @ top]
		ifFalse: [labelMorph position: (self left + xInset) @ top].

]

{ #category : #BYOB }
ExpressionArgMorph >> getExpression [

	^ labelMorph savedContents
]

{ #category : #'object i/o' }
ExpressionArgMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		isNumber
	) from: anObjStream.

]

{ #category : #initialization }
ExpressionArgMorph >> initialize [

	super initialize.
	isNumber := true.
	isText := false.
	self borderWidth: 1.
	self borderInset.
	self color: (Color gray: 0.95).
	self extent: 25@12.

	"To allow for editing in place."
	labelMorph := StringFieldMorph new
		forExpressionArg;
		doResizing: true;
		font: (PhratchFrameMorph getFont: #Arg);
		color: Color transparent.
	self addMorph: labelMorph.
	self numExpression: '10'.

]

{ #category : #queries }
ExpressionArgMorph >> isEmptySlot [

	isText ifTrue: [
		^ labelMorph savedContents = '' asUTF8].
	^ (Array with: '' asUTF8 with: ' ' asUTF8) includes: labelMorph savedContents

]

{ #category : #drawing }
ExpressionArgMorph >> isNumberExpression [

	^ isNumber

]

{ #category : #BYOB }
ExpressionArgMorph >> isNumberExpression: bool [

	isNumber := bool

]

{ #category : #drawing }
ExpressionArgMorph >> isRectangular [

	^ isNumber not

]

{ #category : #BYOB }
ExpressionArgMorph >> isText [

	^ isText ifNil: [isText := false ]
]

{ #category : #BYOB }
ExpressionArgMorph >> isText: bool [

	isText := bool.
	isNumber := bool not

]

{ #category : #accessing }
ExpressionArgMorph >> numExpression: aNumber [

	isNumber := true.
	labelMorph isNumeric: true.

	aNumber isFloat
		ifTrue: [labelMorph contents: aNumber printStringNoExponent]
		ifFalse: [labelMorph contents: aNumber asString].
	self fixArgLayout.

]

{ #category : #'object i/o' }
ExpressionArgMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		isNumber
	) on: anObjStream.

]

{ #category : #accessing }
ExpressionArgMorph >> stringExpression: aString [

	isNumber := false.
	labelMorph isNumeric: false.
	labelMorph contents: aString.
	self fixArgLayout.

]
