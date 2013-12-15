Extension { #name : #SpriteArgMorph }

{ #category : #'*PhratchObjStream' }
SpriteArgMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
SpriteArgMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		morph
	) from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
SpriteArgMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		morph
	) on: anObjStream.

]
