Extension { #name : #PhratchMedia }

{ #category : #'*PhratchObjStream' }
PhratchMedia >> initFieldsFrom: anObjStream version: classVersion [

	self initFieldsNamed: #(
		mediaName
	) from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
PhratchMedia >> storeFieldsOn: anObjStream [

	self storeFieldsNamed: #(
		mediaName
	) on: anObjStream.

]
