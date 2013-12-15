Extension { #name : #MorphExtension }

{ #category : #'*PhratchObjStream' }
MorphExtension >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
MorphExtension >> initFieldsFrom: anObjStream version: classVersion [
	self
		initFieldsNamed: #(
			
		)from: anObjStream
]

{ #category : #'*PhratchObjStream' }
MorphExtension >> storeFieldsOn: anObjStream [

	self storeFieldsNamed: #(
		 
	) on: anObjStream.
]
