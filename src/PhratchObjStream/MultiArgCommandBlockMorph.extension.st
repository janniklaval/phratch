Extension { #name : #MultiArgCommandBlockMorph }

{ #category : #'*PhratchObjStream' }
MultiArgCommandBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	| blockTuple arg val eval |
	blockTuple := Array new: argMorphs size + 3.
	blockTuple
		at: 1 put: #phratch;
		at: 2 put: self rcvr;
		at: 3 put: selector.
	1 to: argMorphs size do: [ :i | 
		arg := argMorphs at: i.
		(arg isKindOf: ArgMorph) | (arg isKindOf: EventTitleMorph)
			ifTrue: [ 
				((arg isKindOf: CSlotMorph) or: [ arg isKindOf: OSlotMorph ])
					ifTrue: [ blockTuple at: i + 3 put: arg asBlockTuple ]
					ifFalse: [ 
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
						blockTuple at: i + 3 put: eval ] ]
			ifFalse: [ blockTuple at: i + 3 put: arg asBlockTuple ] ].
	^ blockTuple
]
