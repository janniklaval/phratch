Class {
	#name : #ReturnElementMorph,
	#superclass : #StepElementMorph,
	#category : #'Phratch-UI-Elements'
}

{ #category : #adding }
ReturnElementMorph >> addLabel [
	label := StringMorph contents: ' ^' font: self labelFont.
	label color: self labelColor.
	self addMorphFront: label.

]

{ #category : #converting }
ReturnElementMorph >> asSmalltalk [
	^'^ ',super asSmalltalk
]

{ #category : #drawing }
ReturnElementMorph >> drawOn: aCanvas [ 

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
	r := Rectangle origin: (self left @ (self bottom - bw3)) corner: (self right - bw) @ (self bottom - bw2).
	aCanvas fillRectangle: r color: self borderColorVeryDark.

	"body"
"	aCanvas fillRectangle: (Rectangle origin: (self left + bw) @ (self top + bw3) corner: (self right - bw) @ (self bottom - bw)) color: Color red."

	aCanvas fillRectangle: (Rectangle origin: (self left + bw) @ (self top + bw3) corner: (self right - bw) @ (self center y - bw)) color: color twiceLighter.

	aCanvas fillRectangle: (Rectangle origin: (self left + bw) @ (self center y - bw) corner: (self right - bw) @ (self center y)) color: color lighter.

	aCanvas fillRectangle: (Rectangle origin: (self left + bw) @ (self center y) corner: (self right - bw) @ (self bottom - bw3)) color: color.


	aCanvas fillRectangle: (Rectangle origin: (self left + bw) @ (self top + bw) corner: (self left + indent - bw) @ (self top + bw3)) color: color twiceLighter.

	aCanvas fillRectangle: (Rectangle origin: (self left + indent + dent + bw) @ (self top + bw) corner: (self right - bw) @ (self top + bw3)) color: color twiceLighter.


]

{ #category : #private }
ReturnElementMorph >> fit [

	| cw bw |
	label ifNil: [^self].
	bw := self borderWidth.
	cw := self labelFont widthOf: $ .

	self width: expression width + label width + cw + (bw * 3).
	self height: expression height + (bw * 7).


	label position: (self left + bw) @ (bounds center - (label extent // 2)) y.

	expression position: (label right + cw) @ (bounds center - (expression extent // 2)) y.

	(owner respondsTo: #fit)
		ifTrue: [owner fit]
]

{ #category : #initialize }
ReturnElementMorph >> initialize [
	super initialize.
	color := Color red twiceDarker.
	self addLabel.
	self fit.
]

{ #category : #'dropping/grabbing' }
ReturnElementMorph >> wantsDroppedMorph: aMorph event: evt [

	^false
]
