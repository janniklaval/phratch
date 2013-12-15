Extension { #name : #SimpleButtonMorph }

{ #category : #'*PhratchObjStream' }
SimpleButtonMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
SimpleButtonMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		target
		actionSelector
		arguments
		actWhen
	) from: anObjStream.
]

{ #category : #'*PhratchObjStream' }
SimpleButtonMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		target
		actionSelector
		arguments
		actWhen
	) on: anObjStream.

]
