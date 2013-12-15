Extension { #name : #ChoiceArgMorph }

{ #category : #'*PhratchObjStream' }
ChoiceArgMorph >> fieldsVersion [

	^ 2

]

{ #category : #'*PhratchObjStream' }
ChoiceArgMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		options
		choice
	) from: anObjStream.
	classVersion = 1 ifTrue: [^ self].

	"fields added in version 2"
	self initFieldsNamed: #(
		getOptionsSelector
	) from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
ChoiceArgMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		options
		choice
		getOptionsSelector
	) on: anObjStream.

]
