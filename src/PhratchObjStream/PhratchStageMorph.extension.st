Extension { #name : #PhratchStageMorph }

{ #category : #'*PhratchObjStream' }
PhratchStageMorph >> fieldsVersion [

	^ 5

]

{ #category : #'*PhratchObjStream' }
PhratchStageMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		"zoom"
		hPan
		vPan
	) from: anObjStream.
	classVersion = 1 ifTrue: [^ self].

	"fields added in version 2"
	"self initFieldsNamed: #(
		obsoleteSavedState
	) from: anObjStream."
	classVersion = 2 ifTrue: [^ self].

	"fields added in version 3"
	self initFieldsNamed: #(
		sprites
	) from: anObjStream.
	classVersion = 3 ifTrue: [^ self].

	"fields added in version 4"
	self initFieldsNamed: #(
		volume
		tempoBPM
	) from: anObjStream.
	classVersion = 4 ifTrue: [^ self].

	"fields added in version 5"
	self initFieldsNamed: #(
		sceneStates
		lists
	) from: anObjStream.
	lists ifNil: [lists := Dictionary new].  "work around"

]

{ #category : #'*PhratchObjStream' }
PhratchStageMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		"zoom"
		hPan
		vPan
		"obsoleteSavedState"
		sprites
		volume
		tempoBPM
		sceneStates
		lists
	) on: anObjStream.

]
