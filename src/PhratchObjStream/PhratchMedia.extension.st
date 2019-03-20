Extension { #name : #PhratchMedia }

{ #category : #'*PhratchObjStream' }
PhratchMedia >> initFieldsFrom: anObjStream version: classVersion [

	self initFieldsNamed: #(
		mediaName
	) from: anObjStream.

]
