Class {
	#name : #PaintColorPicker,
	#superclass : #ImageFrameMorph,
	#instVars : [
		'selectedColor',
		'target',
		'selector',
		'selector2',
		'shadePickerContainer',
		'colorPickerImage',
		'colorPickerContainer',
		'shadePickerImage'
	],
	#category : #'Phratch-Paint'
}

{ #category : #initialization }
PaintColorPicker >> createColorPickers [

	colorPickerContainer := BorderedMorph new.
	colorPickerImage := ImageMorph new.
	colorPickerContainer
		borderWidth: 1;
		borderColor: (Color r: 0.505 g: 0.505 b: 0.505);
		extent: 500@500;
		addMorph: colorPickerImage.
	self addMorph: colorPickerContainer.
	colorPickerImage position: colorPickerImage position + (1@1).

	shadePickerContainer := BorderedMorph new.
	shadePickerImage := ImageMorph new.
	shadePickerContainer
		borderWidth: 1;
		borderColor: (Color r: 0.505 g: 0.505 b: 0.505);
		addMorph: shadePickerImage.
	self addMorph: shadePickerContainer.
	shadePickerImage position: shadePickerImage position + (1@1).

]

{ #category : #initialization }
PaintColorPicker >> createColorWheels [

	| f h c f2 fx fy fx2 fy2 |
	fx := colorPickerContainer width - 2.
	fy := colorPickerContainer height - 2.
	f := Form extent: fx@fy depth: 32.
	fx2 := shadePickerContainer width - 2.
	fy2 := shadePickerContainer height - 2.
	f2 := Form extent: fx2@fy2 depth: 32.

	0 to: fx do: [:x |
		h := x * 360 // fx.
		0 to: (fy // 2) do: [:y |
			c := Color h: h s: (y / (fy // 2)) v: 1.0.
			f fill: (x@y extent: 1) fillColor: c].
		((fy // 2) + 1) to: fy do: [:y |
			c := Color h: h s: 1.0 v: (fy - y) / (fy // 2).
			f fill: (x@y extent: 1) fillColor: c]].
	0 to: fx2 do: [:x |
		c := Color gray: (x / fx2).
		f2 fill: ((x@0) extent: (1@fy2)) fillColor: c].

	colorPickerImage form: f.
	shadePickerImage form: f2.

]

{ #category : #geometry }
PaintColorPicker >> extent: newExtent [
	newExtent = self extent
		ifTrue: [ ^ self ].
	super extent: newExtent.
	(colorPickerContainer notNil and: [ shadePickerContainer notNil ])
		ifFalse: [ ^ self ].
	colorPickerContainer
		extent: (newExtent x - 8) @ (newExtent y - 22);
		position: (self left + 4) @ (self top + 4).
	shadePickerContainer
		extent: (newExtent x - 8) @ 9;
		position: (self left + 4) @ (self bottom - 15).
	self createColorWheels
]

{ #category : #'event handling' }
PaintColorPicker >> handlesMouseDown: evt [

	^ true

]

{ #category : #'event handling' }
PaintColorPicker >> handlesMouseOver: evt [

	^ true

]

{ #category : #initialization }
PaintColorPicker >> initialize [

	super initialize.
	selectedColor := Color black.
	target := selector := nil.
	self createColorPickers.
	self extent: 20@20.

]

{ #category : #'event handling' }
PaintColorPicker >> mouseDown: evt [

	self mouseMove: evt.

]

{ #category : #'event handling' }
PaintColorPicker >> mouseEnter: evt [

	evt hand showTemporaryCursor: Cursor eyeDropper.

]

{ #category : #'event handling' }
PaintColorPicker >> mouseLeave: evt [

	evt hand showTemporaryCursor: nil.

]

{ #category : #'event handling' }
PaintColorPicker >> mouseMove: evt [

	target ifNil: [^ self].

	((colorPickerImage bounds containsPoint: evt cursorPoint) or: [
	 (shadePickerImage bounds containsPoint: evt cursorPoint)]) ifTrue: [
		selectedColor := Display colorAt: evt cursorPoint].

	evt shiftPressed | evt rightButtonPressed
		ifTrue: [selector2 ifNotNil: [target perform: selector2 with: selectedColor]]
		ifFalse: [selector ifNotNil: [target perform: selector with: selectedColor]].

]

{ #category : #'event handling' }
PaintColorPicker >> mouseUp: evt [
	'do nothing'

]

{ #category : #accessing }
PaintColorPicker >> selectedColor [

	^ selectedColor

]

{ #category : #accessing }
PaintColorPicker >> selector [

	^ selector

]

{ #category : #accessing }
PaintColorPicker >> selector2: sel [
	selector2 := (sel isNil or: [ sel = 'nil' or: [ sel isEmpty ] ])
		ifTrue: [ nil ]
		ifFalse: [ sel asSymbol ]
]

{ #category : #accessing }
PaintColorPicker >> selector: sel [
	selector := (sel isNil or: [ sel = 'nil' or: [ sel isEmpty ] ])
		ifTrue: [ nil ]
		ifFalse: [ sel asSymbol ]
]

{ #category : #accessing }
PaintColorPicker >> target [

	^ target

]

{ #category : #accessing }
PaintColorPicker >> target: anObject [

	target := anObject.

]
