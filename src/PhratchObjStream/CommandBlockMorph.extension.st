Extension { #name : #CommandBlockMorph }

{ #category : #'*PhratchObjStream' }
CommandBlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
CommandBlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		commandSpec
		argMorphs
		titleMorph
		receiver
		selector
		isReporter
		isTimed
		wantsName
		wantsPossession
	) from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
CommandBlockMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		commandSpec
		argMorphs
		titleMorph
		receiver
		selector
		isReporter
		isTimed
		wantsName
		wantsPossession
	) on: anObjStream.

]
