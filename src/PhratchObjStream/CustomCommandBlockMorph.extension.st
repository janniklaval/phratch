Extension { #name : #CustomCommandBlockMorph }

{ #category : #'*PhratchObjStream' }
CustomCommandBlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
CustomCommandBlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		userSpec
	) from: anObjStream.


]

{ #category : #'*PhratchObjStream' }
CustomCommandBlockMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		userSpec
	) on: anObjStream.

]
