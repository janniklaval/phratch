Extension { #name : #CommandScriptBlockMorph }

{ #category : #'*PhratchObjStream' }
CommandScriptBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	| blockTuple arg argList val eval |
	blockTuple := Array new: argMorphs size + 9.
	blockTuple
		at: 1 put: #phratch;
		at: 2 put: self rcvr;
		at: 3 put: selector;
		at: 4 put: parameters asArray;
		at: 5 put: variables asArray;
		at: 6 put: type;
		at: 7 put: declarations;
		at: 8 put: isAtomic.
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
				blockTuple at: i + 8 put: eval ]
			ifFalse: [ blockTuple at: i + 8 put: arg asBlockTuple ] ].
	nestedBlock
		ifNil: [ blockTuple at: blockTuple size put: nil ]
		ifNotNil: [ blockTuple at: blockTuple size put: nestedBlock tupleSequence ].
	^ blockTuple
]
