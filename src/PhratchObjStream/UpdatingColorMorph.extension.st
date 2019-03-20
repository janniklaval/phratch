Extension { #name : #UpdatingColorMorph }

{ #category : #'*PhratchObjStream' }
UpdatingColorMorph >> fieldsVersion [

	^ 1
]

{ #category : #'*PhratchObjStream' }
UpdatingColorMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		target
		selector
		parameter
		stepTime
	) from: anObjStream.

]
