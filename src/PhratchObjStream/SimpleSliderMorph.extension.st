Extension { #name : #SimpleSliderMorph }

{ #category : #'*PhratchObjStream' }
SimpleSliderMorph >> fieldsVersion [

	^ 1


]

{ #category : #'*PhratchObjStream' }
SimpleSliderMorph >> initFieldsFrom: anObjStream version: classVersion [
	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		target
		arguments
		minVal
		maxVal
		truncate
	) from: anObjStream.
]

{ #category : #'*PhratchObjStream' }
SimpleSliderMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		target
		arguments
		minVal
		maxVal
		truncate
	) on: anObjStream.

]
