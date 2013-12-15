Extension { #name : #Slider }

{ #category : #'*PhratchObjStream' }
Slider >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
Slider >> initFieldsFrom: anObjStream version: classVersion [
	super initFieldsFrom: anObjStream version: classVersion.
	self
		initFieldsNamed: #(
			slider
			value
			setValueSelector
			sliderShadow
			sliderColor
			descending
			model
		)from: anObjStream
]

{ #category : #'*PhratchObjStream' }
Slider >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		slider
		value
		setValueSelector
		sliderShadow
		sliderColor
		descending
		model
	) on: anObjStream.
]
