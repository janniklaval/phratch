Extension { #name : #PhratchStageMorph }

{ #category : #'*PhratchObjStream' }
PhratchStageMorph >> asReferenceTuple [

	" answer an array describing the receiver in an abstract way
	format conventions:"

	^ Array with: #stage

]

{ #category : #'*PhratchObjStream' }
PhratchStageMorph >> fieldsVersion [

	^ 5

]

{ #category : #'*PhratchObjStream' }
PhratchStageMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		zoom
		hPan
		vPan
	) from: anObjStream.
	classVersion = 1 ifTrue: [^ self].

	"fields added in version 2"
	self initFieldsNamed: #(
		obsoleteSavedState
	) from: anObjStream.
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
PhratchStageMorph >> listInVarNamed: varName targetName: targetName [

	targetName = 'Stage' ifTrue: [
		^self getVar: varName].

	sprites do: [:sprite |
		(sprite varNames includes: varName)
			ifTrue: [^sprite getVar: varName]].

	^ nil
]

{ #category : #'*PhratchObjStream' }
PhratchStageMorph >> listNamed: listName targetName: targetName [

	targetName = 'Stage' ifTrue: [
		^self listNamed: listName ].

	sprites do: [:sprite |
		(sprite listVarNames includes: listName)
			ifTrue: [^sprite listNamed: listName ]].

	^ nil
]

{ #category : #'*PhratchObjStream' }
PhratchStageMorph >> referenceToList: aPhratchList [

	"answer an Array describing the variable which holds an anonymous list, nil
	if there isn't any.

	format:

		1 - target obj name
		2 - var name"

	self varNames do: [:key |
		aPhratchList == (vars at: key)
			ifTrue: [^ Array with: 'Stage' with: key ]].

	sprites do: [:sprite |
		sprite varNames do: [:vname |
			aPhratchList == (sprite getVar: vname)
				ifTrue: [^ Array with: sprite objName with: vname ]]].

	^ nil
]
