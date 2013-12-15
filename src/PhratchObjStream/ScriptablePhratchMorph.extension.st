Extension { #name : #ScriptablePhratchMorph }

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> initFieldsFrom: anObjStream version: classVersion [

	| fields |

	fields := #(
		objName
		vars
		blocksBin
		isClone
		media
		costume
	).
	self class currentEncoding = #byob
		ifTrue: [
	fields := #(
		objName
		vars
		blocksBin
		customBlocks
		isClone
		media
		costume
	) ].

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: fields from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> storeFieldsOn: anObjStream [

	| oldBlockBinOwner |
	super storeFieldsOn: anObjStream.
	(blocksBin isKindOf: Morph) ifTrue: [
		oldBlockBinOwner := blocksBin owner.
		blocksBin delete].

	self purgeVarsAndLists.

	self storeFieldsNamed: #(
		objName
		vars
		blocksBin
		customBlocks
		isClone
		media
		costume
	) on: anObjStream.

	oldBlockBinOwner ifNotNil: [oldBlockBinOwner addMorph: blocksBin].

]
