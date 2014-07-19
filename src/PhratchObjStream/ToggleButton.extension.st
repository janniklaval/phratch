Extension { #name : #ToggleButton }

{ #category : #'*PhratchObjStream' }
ToggleButton >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
ToggleButton >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		onForm
		offForm
		overForm
		disabledForm
		isMomentary
		toggleMode
		isOn
		isDisabled
	) from: anObjStream.

]
