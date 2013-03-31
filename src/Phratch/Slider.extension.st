Extension { #name : #Slider }

{ #category : #'*Phratch-Extensions' }
Slider >> fieldsVersion [

	^ 1

]

{ #category : #'*Phratch' }
Slider >> hasMenuButton: ignored [
]

{ #category : #'*Phratch-Extensions' }
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

{ #category : #'*Phratch' }
Slider >> setValueSelector: aSymbol [
	"Directly set the selector to make more flexible."
	
	setValueSelector := aSymbol
]

{ #category : #'*Phratch-Extensions' }
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
