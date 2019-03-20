Extension { #name : #BorderedMorph }

{ #category : #'*PhratchObjStream' }
BorderedMorph >> fieldsVersion [

	^ 1
]

{ #category : #'*PhratchObjStream' }
BorderedMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		borderWidth
		borderColor
	) from: anObjStream.

]
