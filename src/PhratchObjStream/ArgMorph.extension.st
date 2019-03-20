Extension { #name : #ArgMorph }

{ #category : #'*PhratchObjStream' }
ArgMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
ArgMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		labelMorph
	) from: anObjStream.

]
