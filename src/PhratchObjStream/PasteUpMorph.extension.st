Extension { #name : #PasteUpMorph }

{ #category : #'*PhratchObjStream' }
PasteUpMorph >> fieldsVersion [

	^ 1
]

{ #category : #'*PhratchObjStream' }
PasteUpMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		backgroundMorph 
	) from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
PasteUpMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		backgroundMorph 
	) on: anObjStream.

]
