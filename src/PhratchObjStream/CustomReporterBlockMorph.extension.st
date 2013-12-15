Extension { #name : #CustomReporterBlockMorph }

{ #category : #'*PhratchObjStream' }
CustomReporterBlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
CustomReporterBlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		userSpec
	) from: anObjStream.


]

{ #category : #'*PhratchObjStream' }
CustomReporterBlockMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		userSpec
	) on: anObjStream.

]
