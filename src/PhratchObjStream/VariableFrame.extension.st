Extension { #name : #VariableFrame }

{ #category : #'*PhratchObjStream' }
VariableFrame >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
VariableFrame >> initFieldsFrom: anObjStream version: classVersion [
	"Set my instance variables from the given object stream."

	self initFieldsNamed: #(
		vars
	) from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
VariableFrame >> storeFieldsOn: anObjStream [

	self storeFieldsNamed: #(
		vars
	) on: anObjStream.


]
