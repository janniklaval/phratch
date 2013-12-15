Extension { #name : #SetterBlockMorph }

{ #category : #'*PhratchObjStream' }
SetterBlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
SetterBlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		variable
	) from: anObjStream.
	self variable: variable.

]

{ #category : #'*PhratchObjStream' }
SetterBlockMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	variable := self variable.
	self storeFieldsNamed: #(
		variable
	) on: anObjStream.

]
