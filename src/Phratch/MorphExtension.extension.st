Extension { #name : #MorphExtension }

{ #category : #'*Phratch-Extensions' }
MorphExtension >> fieldsVersion [

	^ 1

]

{ #category : #'*Phratch-Extensions' }
MorphExtension >> initFieldsFrom: anObjStream version: classVersion [
	self
		initFieldsNamed: #(
			
		)from: anObjStream
]

{ #category : #'*Phratch-Extensions' }
MorphExtension >> storeFieldsOn: anObjStream [

	self storeFieldsNamed: #(
		 
	) on: anObjStream.
]
