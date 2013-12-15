Extension { #name : #CBlockMorph }

{ #category : #'*PhratchObjStream' }
CBlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
CBlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		nestedBlock
		nextBlock
	) from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
CBlockMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		nestedBlock
		nextBlock
	) on: anObjStream.

]
