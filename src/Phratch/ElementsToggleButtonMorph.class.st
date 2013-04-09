Class {
	#name : #ElementsToggleButtonMorph,
	#superclass : #ElementsButtonMorph,
	#instVars : [
		'onColor',
		'offColor',
		'label',
		'on',
		'specialEffect'
	],
	#category : #'Phratch-BYOB-Elements-UI'
}

{ #category : #'as yet unclassified' }
ElementsToggleButtonMorph >> drawOn: aCanvas [ 

	|r bw |
	bw := self borderWidth.

	"border"
	"top"
	r := Rectangle origin: ((self left + bw) @ self top) corner: (self right @ (self top + bw)).
	aCanvas fillRectangle: r color: self borderColorVeryLight.

	"left"
	r := Rectangle origin: (self topLeft) corner: (self left + bw) @ (self bottom - bw).
	aCanvas fillRectangle: r color: self borderColorLight.

	"right"
	r := Rectangle origin: ((self right - bw) @ (self top + bw)) corner: self bottomRight.
	aCanvas fillRectangle: r color: self borderColorDark.

	"bottom"
	r := Rectangle origin: (self left @ (self bottom - bw)) corner: (self right - bw) @ self bottom.
	aCanvas fillRectangle: r color: self borderColorVeryDark.

	"body"
	aCanvas fillRectangle: (Rectangle origin: (self topLeft + bw) corner: (self bottomRight - bw)) color: color.
"
	aCanvas fillRectangle: (Rectangle origin: (self topLeft + bw) corner: (self right - bw) @ (self center y - bw)) color: color twiceLighter.

	aCanvas fillRectangle: (Rectangle origin: (self left + bw) @ (self center y - bw) corner: (self right - bw) @ (self center y)) color: color lighter.

	aCanvas fillRectangle: (Rectangle origin: (self left + bw @ (self center y)) corner: (self bottomRight - bw)) color: color.

"

specialEffect ifTrue: [

	aCanvas fillRectangle: (Rectangle origin: (self topLeft + bw) corner: (self left + self height) @ (self center y - bw)) color: onColor twiceLighter.

	aCanvas fillRectangle: (Rectangle origin: (self left + bw) @ (self center y - bw) corner: (self left + self height) @ (self center y)) color: onColor lighter.

	aCanvas fillRectangle: (Rectangle origin: (self left + bw @ (self center y)) corner: (self left + self height) @ (self bottom - bw)) color: onColor


]
]

{ #category : #'as yet unclassified' }
ElementsToggleButtonMorph >> fitMorphs [
	| bw x y |
	bw := self borderWidth.
	self height: label height + (bw * 2).
	x := self left + ((self width - label width) // 2).
	y := self top + bw.
	label position: x@ y 
]

{ #category : #'as yet unclassified' }
ElementsToggleButtonMorph >> flat [
	specialEffect := false
]

{ #category : #'as yet unclassified' }
ElementsToggleButtonMorph >> initialize [
	super initialize.
	specialEffect := true.
	on := true.
	target := self.
	selector := #toggle.
	onColor := Color blue.
	offColor := Color gray.
	self label: 'Elements Toggle Button'.
	self toggle
]

{ #category : #'as yet unclassified' }
ElementsToggleButtonMorph >> isOn [
	^on
]

{ #category : #'as yet unclassified' }
ElementsToggleButtonMorph >> label: aString [

	label ifNil: [
		label := StringMorph contents: '' font: self labelFont.
		label color: self labelColor.
		self addMorphFront: label ].
	label contents: aString.
	self fitMorphs

]

{ #category : #'as yet unclassified' }
ElementsToggleButtonMorph >> labelFont [
	^StrikeFont fontName: 'VerdanaBold' size: 10
]

{ #category : #'as yet unclassified' }
ElementsToggleButtonMorph >> off [
	on := false.
	self color: offColor
]

{ #category : #'as yet unclassified' }
ElementsToggleButtonMorph >> on [
	on := true.
	self color: onColor
]

{ #category : #'as yet unclassified' }
ElementsToggleButtonMorph >> onColor: onc offColor: offc [
	onColor := onc.
	offColor := offc
]

{ #category : #'as yet unclassified' }
ElementsToggleButtonMorph >> toggle [
	self fitMorphs.
	on ifTrue: [^self off].
	self on
]