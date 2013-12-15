Extension { #name : #ExpressionArgMorphWithMenu }

{ #category : #'*PhratchObjStream' }
ExpressionArgMorphWithMenu >> fieldsVersion [

	^ 2

]

{ #category : #'*PhratchObjStream' }
ExpressionArgMorphWithMenu >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		menuMorph
		getMenuSelector
	) from: anObjStream.

	classVersion = 1 ifTrue: [^ self].

	"field added in version 2"
	self initFieldsNamed: #(
		specialValue
	) from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
ExpressionArgMorphWithMenu >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		menuMorph
		getMenuSelector
		specialValue
	) on: anObjStream.

]
