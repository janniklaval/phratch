Extension { #name : #ImageMorph }

{ #category : #'*PhratchObjStream' }
ImageMorph >> fieldsVersion [

	^ 1
]

{ #category : #'*PhratchObjStream' }
ImageMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
	) from: anObjStream.

]
