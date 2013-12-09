Extension { #name : #AlignmentMorph }

{ #category : #'*Phratch-extensions' }
AlignmentMorph >> fieldsVersion [

	^ 6
]

{ #category : #'*Phratch-extensions' }
AlignmentMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
	) from: anObjStream.

]

{ #category : #'*Phratch-extensions' }
AlignmentMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
	) on: anObjStream.

]
