Extension { #name : #CBlockMorph }

{ #category : #'*PhratchObjStream' }
CBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	| blockTuple arg argList val eval |
	blockTuple := Array new: argMorphs size + 4.
	blockTuple
		at: 1 put: #phratch;
		at: 2 put: self rcvr;
		at: 3 put: selector.
	argList := argMorphs.
	argList := self organizeArgs: argList.
	1 to: argList size do: [ :i | 
		arg := argList at: i.
		(arg isKindOf: ArgMorph)
			ifTrue: [ 
				(arg isKindOf: ExpressionArgMorph)
					ifTrue: [ 
						val := arg getExpression.
						eval := arg isNumberExpression
							ifTrue: [ 
								val = ' '
									ifTrue: [ val ]
									ifFalse: [ val asNumberNoError ] ]
							ifFalse: [ arg evaluate ] ]
					ifFalse: [ eval := arg evaluate ].
				blockTuple at: i + 3 put: eval ]
			ifFalse: [ blockTuple at: i + 3 put: arg asBlockTuple ] ].
	nestedBlock
		ifNil: [ blockTuple at: blockTuple size put: nil ]
		ifNotNil: [ blockTuple at: blockTuple size put: nestedBlock tupleSequence ].
	^ blockTuple
]

{ #category : #'*PhratchObjStream' }
CBlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
CBlockMorph >> firstBlockList: aBlockMorph [
	"Add the given block as my first nested block sequence. Delete the old nested blocks, if any."

	nestedBlock ifNotNil: [nestedBlock delete].
	nestedBlock := aBlockMorph.
	aBlockMorph ifNotNil: [self addMorph: aBlockMorph].

]

{ #category : #'*PhratchObjStream' }
CBlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		nestedBlock
		nextBlock
	) from: anObjStream.

]

{ #category : #'*PhratchObjStream' }
CBlockMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		nestedBlock
		nextBlock
	) on: anObjStream.

]
