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
