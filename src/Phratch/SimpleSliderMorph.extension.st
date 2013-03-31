Extension { #name : #SimpleSliderMorph }

{ #category : #'*Phratch-extensions' }
SimpleSliderMorph >> fieldsVersion [

	^ 1


]

{ #category : #'*Phratch-extensions' }
SimpleSliderMorph >> initFieldsFrom: anObjStream version: classVersion [
	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		target
		arguments
		minVal
		maxVal
		truncate
		sliderThickness
	) from: anObjStream.
]

{ #category : #'*Phratch-extensions' }
SimpleSliderMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		target
		arguments
		minVal
		maxVal
		truncate
		sliderThickness
	) on: anObjStream.

]
