Extension { #name : #SketchMorph }

{ #category : #'*Phratch-Extensions' }
SketchMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*Phratch-Extensions' }
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

{ #category : #'*Phratch-Extensions' }
SketchMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		originalForm
		rotationCenter
		rotationDegrees
		rotationStyle
		scalePoint
		offsetWhenRotated
	) on: anObjStream.

]
