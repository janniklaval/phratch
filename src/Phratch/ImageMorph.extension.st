Extension { #name : #ImageMorph }

{ #category : #'*Phratch-Extensions' }
ImageMorph >> colorform: anImage [

	self image: anImage as8BitColorForm
]

{ #category : #'*Phratch-Extensions' }
ImageMorph >> fieldsVersion [

	^ 1
]

{ #category : #'*Phratch-Extensions' }
ImageMorph >> form: anImage [

	self image: anImage
]

{ #category : #'*Phratch-Extensions' }
ImageMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		form
		transparency
	) from: anObjStream.

]

{ #category : #'*Phratch-Extensions' }
ImageMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		form
		transparency
	) on: anObjStream.

]
