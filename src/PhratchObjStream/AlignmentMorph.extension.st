Extension { #name : #AlignmentMorph }

{ #category : #'*PhratchObjStream' }
AlignmentMorph >> fieldsVersion [

	^ 6
]

{ #category : #'*PhratchObjStream' }
AlignmentMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
	) from: anObjStream.

]
