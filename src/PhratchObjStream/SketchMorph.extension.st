Extension { #name : #SketchMorph }

{ #category : #'*PhratchObjStream' }
SketchMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
SketchMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		originalForm
		rotationCenter
		rotationDegrees
		rotationStyle
		scalePoint
		offsetWhenRotated
	) from: anObjStream.

]
