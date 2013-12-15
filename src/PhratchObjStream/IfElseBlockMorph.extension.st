Extension { #name : #IfElseBlockMorph }

{ #category : #'*PhratchObjStream' }
IfElseBlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
IfElseBlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		trueBlock
		falseBlock
		nextBlock
	) from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
IfElseBlockMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		trueBlock
		falseBlock
		nextBlock
	) on: anObjStream.

]
