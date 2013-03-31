"
I am a slider with built-in fields for my miniumum and maximum values.

"
Class {
	#name : #ScratchSliderMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'slider',
		'sliderMin',
		'sliderMax',
		'variable'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #initialization }
ScratchSliderMorph >> buildNumberBox [

	| box m |
	box := BorderedMorph new
		borderWidth: 1;
		borderInset;
		color: Color paleBlue;
		extent: 20@17.
	m := UpdatingStringMorph new
		target: slider;
		floatPrecision: 0.01;
		useDefaultFormat.
	box addMorph: m.
	^ box

]

{ #category : #'object i/o' }
ScratchSliderMorph >> fieldsVersion [

	^ 1

]

{ #category : #private }
ScratchSliderMorph >> fixLayoutOf: numberBox [

	| stringMorph |
	stringMorph := numberBox firstSubmorph.
	numberBox width: stringMorph width + 6.
	stringMorph position: numberBox position + (3@2).

]

{ #category : #'object i/o' }
ScratchSliderMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		slider
		sliderMin
		sliderMax
		variable
	) from: anObjStream.

]

{ #category : #initialization }
ScratchSliderMorph >> initialize [

	super initialize.
	slider := SimpleSliderMorph new
		minVal: 0; maxVal: 100;
		setValue: 50;
		extent: 128@10.

	self orientation: #horizontal; cellPositioning: #leftCenter; centering: #center; hResizing: #shrinkWrap;
		borderWidth: 1; borderColor: (Color r: 0.0 g: 0.65 b: 0.0);
		addMorphBack: (sliderMin := self buildNumberBox);
		addMorphBack: (AlignmentMorph new width: 5; color: Color transparent; hResizing: #rigid);
		addMorphBack: slider;
		addMorphBack: (AlignmentMorph new width: 5; color: Color transparent; hResizing: #rigid);
		addMorphBack: (sliderMax := self buildNumberBox).

	sliderMin firstSubmorph
		putSelector: #minVal:;
		getSelector: #minVal.
	sliderMax firstSubmorph
		putSelector: #maxVal:;
		getSelector: #maxVal.

]

{ #category : #accessing }
ScratchSliderMorph >> slider [

	^ slider
]

{ #category : #stepping }
ScratchSliderMorph >> step [

	self updateSliderPosition.
	self fixLayoutOf: sliderMin.
	self fixLayoutOf: sliderMax.


]

{ #category : #stepping }
ScratchSliderMorph >> stepTime [

	^ 100
]

{ #category : #'object i/o' }
ScratchSliderMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		slider
		sliderMin
		sliderMax
		variable
	) on: anObjStream.

]

{ #category : #accessing }
ScratchSliderMorph >> target [

	^ slider target

]

{ #category : #accessing }
ScratchSliderMorph >> target: anObject [

	slider target: anObject.

]

{ #category : #private }
ScratchSliderMorph >> updateActionSelector [

	slider
		actionSelector: #setVar:to:;
		arguments: (Array with: variable).

]

{ #category : #private }
ScratchSliderMorph >> updateSliderPosition [
	"Set my slider position to the variable's current value"

	| value |
	self target ifNil: [^ self].
	value := self target perform: #setVar:to: with: variable.
	value ifNil: [^ self].  "can happen when variable has been deleted"
	slider adjustToValue: value.

]

{ #category : #accessing }
ScratchSliderMorph >> variable [

	^ variable

]

{ #category : #accessing }
ScratchSliderMorph >> variable: aVariable [

	variable := aVariable.

]
