Extension { #name : #BorderedMorph }

{ #category : #'*Phratch-extensions' }
BorderedMorph >> fieldsVersion [

	^ 1
]

{ #category : #'*Phratch-extensions' }
BorderedMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		borderWidth
		borderColor
	) from: anObjStream.

]

{ #category : #'*Phratch-extensions' }
BorderedMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		borderWidth
		borderColor
	) on: anObjStream.

]
