Extension { #name : #BlockMorph }

{ #category : #'*PhratchObjStream' }
BlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
BlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		isSpecialForm
		oldColor
	) from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
BlockMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		isSpecialForm
		oldColor
	) on: anObjStream.

]
