Extension { #name : #CustomBlockDefinition }

{ #category : #'*PhratchObjStream' }
CustomBlockDefinition >> fieldsVersion [

	^ 4

]

{ #category : #'*PhratchObjStream' }
CustomBlockDefinition >> initFieldsFrom: anObjStream version: classVersion [

	self initFieldsNamed: #(
		userSpec
		blockVars
		isAtomic
		isBoolean
		body
		answer
	) from: anObjStream.

	classVersion = 1 ifTrue: [
		^ self deduceType ].

	"fields added in version 2:"
	self initFieldsNamed: #(
		type
		category
		declarations
	) from: anObjStream.

	"fields added in version 3:"
	self initFieldsNamed: #(
		defaults
	) from: anObjStream.

	"fields added in version 4:"
	self initFieldsNamed: #(
		isGlobal
	) from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
CustomBlockDefinition >> storeFieldsOn: anObjStream [

	self storeFieldsNamed: #(
		userSpec
		blockVars
		isAtomic
		isBoolean
		body
		answer
		type
		category
		declarations
		defaults
		isGlobal
	) on: anObjStream.

]
