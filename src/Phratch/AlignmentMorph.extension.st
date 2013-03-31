Extension { #name : #AlignmentMorph }

{ #category : #'*Phratch-extensions' }
AlignmentMorph >> fieldsVersion [

	^ 6
]

{ #category : #'*Phratch-extensions' }
AlignmentMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		orientation
		centering
		hResizing
		vResizing
		inset
	) from: anObjStream.

]

{ #category : #'*Phratch-extensions' }
AlignmentMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		orientation
		centering
		hResizing
		vResizing
		inset
	) on: anObjStream.

]
