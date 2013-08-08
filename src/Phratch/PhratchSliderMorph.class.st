"
I am a slider with built-in fields for my miniumum and maximum values.

"
Class {
	#name : #PhratchSliderMorph,
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
PhratchSliderMorph >> buildNumberBox [

	| box m |
	box := BorderedMorph new
		borderWidth: 1;
		borderInset;
		color: Color paleBlue;
		extent: 20@17;
		yourself.
	m := UpdatingStringMorph new
		target: slider;
		floatPrecision: 0.01;
		useDefaultFormat;
		yourself.
	box addMorph: m.
	^ box

]

{ #category : #'object i/o' }
PhratchSliderMorph >> fieldsVersion [

	^ 1

]

{ #category : #private }
PhratchSliderMorph >> fixLayoutOf: numberBox [

	| stringMorph |
	stringMorph := numberBox firstSubmorph.
	numberBox width: stringMorph width + 6.
	stringMorph position: numberBox position + (3@2).

]

{ #category : #'object i/o' }
PhratchSliderMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		slider
		sliderMin
		sliderMax
		variable
	) from: anObjStream.

]

{ #category : #initialization }
PhratchSliderMorph >> initialize [

	super initialize.
	slider := SimpleSliderMorph new
		minVal: 0; maxVal: 100;
		setValue: 50;
		extent: 128@10;
		yourself.

	self orientation: #horizontal; cellPositioning: #leftCenter; centering: #center; hResizing: #shrinkWrap;
		borderWidth: 1; borderColor: (Color r: 0.0 g: 0.65 b: 0.0);
		addMorphBack: (sliderMin := self buildNumberBox);
		addMorphBack: (AlignmentMorph new width: 5; color: Color transparent; hResizing: #rigid;
		yourself);
		addMorphBack: slider;
		addMorphBack: (AlignmentMorph new width: 5; color: Color transparent; hResizing: #rigid;
		yourself);
		addMorphBack: (sliderMax := self buildNumberBox).

	sliderMin firstSubmorph
		putSelector: #minVal:;
		getSelector: #minVal.
	sliderMax firstSubmorph
		putSelector: #maxVal:;
		getSelector: #maxVal.

]

{ #category : #accessing }
PhratchSliderMorph >> slider [

	^ slider
]

{ #category : #stepping }
PhratchSliderMorph >> step [

	self updateSliderPosition.
	self fixLayoutOf: sliderMin.
	self fixLayoutOf: sliderMax.


]

{ #category : #stepping }
PhratchSliderMorph >> stepTime [

	^ 100
]

{ #category : #'object i/o' }
PhratchSliderMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		slider
		sliderMin
		sliderMax
		variable
	) on: anObjStream.

]

{ #category : #accessing }
PhratchSliderMorph >> target [

	^ slider target

]

{ #category : #accessing }
PhratchSliderMorph >> target: anObject [

	slider target: anObject.

]

{ #category : #private }
PhratchSliderMorph >> updateSliderPosition [
	"Set my slider position to the variable's current value"

	| value |
	self target ifNil: [^ self].
	value := self target perform: #setVar:to: with: variable.
	value ifNil: [^ self].  "can happen when variable has been deleted"
	slider adjustToValue: value.

]

{ #category : #accessing }
PhratchSliderMorph >> variable [

	^ variable

]

{ #category : #accessing }
PhratchSliderMorph >> variable: aVariable [

	variable := aVariable.

]
