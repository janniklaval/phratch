Extension { #name : #IfElseBlockMorph }

{ #category : #'*PhratchObjStream' }
IfElseBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	| blockTuple arg argList |
	blockTuple := Array new: argMorphs size + 5.
	blockTuple
		at: 1 put: #phratch;
		at: 2 put: self rcvr;
		at: 3 put: selector.

	argList := argMorphs.
	argList := self organizeArgs: argList.
	1 to: argList size do: [:i |
		arg := argList at: i.
		(arg isKindOf: ArgMorph)
			ifTrue: [blockTuple at: i + 3 put: arg evaluate]
			ifFalse: [blockTuple at: i + 3 put: arg asBlockTuple]].

	trueBlock
		ifNil: [blockTuple at: blockTuple size - 1 put: nil]
		ifNotNil: [blockTuple at: blockTuple size - 1 put: trueBlock tupleSequence].

	falseBlock
		ifNil: [blockTuple at: blockTuple size put: nil]
		ifNotNil: [blockTuple at: blockTuple size put: falseBlock tupleSequence].

	^ blockTuple

]

{ #category : #'*PhratchObjStream' }
IfElseBlockMorph >> falseBlock: aBlockMorph [
	"Add the given block as my false nested block sequence. Delete the old nested blocks, if any."

	falseBlock ifNotNil: [falseBlock delete].
	falseBlock := aBlockMorph.
	aBlockMorph ifNotNil: [self addMorph: aBlockMorph].

]

{ #category : #'*PhratchObjStream' }
IfElseBlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
IfElseBlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		trueBlock
		falseBlock
		nextBlock
	) from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
IfElseBlockMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		trueBlock
		falseBlock
		nextBlock
	) on: anObjStream.

]

{ #category : #'*PhratchObjStream' }
IfElseBlockMorph >> trueBlock: aBlockMorph [
	"Add the given block as my true nested block sequence. Delete the old nested blocks, if any."

	trueBlock ifNotNil: [trueBlock delete].
	trueBlock := aBlockMorph.
	aBlockMorph ifNotNil: [self addMorph: aBlockMorph].

]
