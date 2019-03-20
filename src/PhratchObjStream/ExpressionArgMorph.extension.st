Extension { #name : #ExpressionArgMorph }

{ #category : #'*PhratchObjStream' }
ExpressionArgMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
ExpressionArgMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		isNumber
	) from: anObjStream.

]
