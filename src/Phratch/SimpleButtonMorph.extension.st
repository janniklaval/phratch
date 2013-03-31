Extension { #name : #SimpleButtonMorph }

{ #category : #'*Phratch' }
SimpleButtonMorph >> drawToolTipAbove: ignored [
]

{ #category : #'*Phratch-Extensions' }
SimpleButtonMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*Phratch-Extensions' }
SimpleButtonMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		target
		actionSelector
		arguments
		actWhen
	) from: anObjStream.
]

{ #category : #'*Phratch-Extensions' }
SimpleButtonMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		target
		actionSelector
		arguments
		actWhen
	) on: anObjStream.

]
