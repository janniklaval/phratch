Extension { #name : #CustomCommandBlockMorph }

{ #category : #'*PhratchObjStream' }
CustomCommandBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	| blockTuple argList arg val eval |
	blockTuple := Array new: argMorphs size + 4.
	blockTuple
		at: 1 put: #phratch;
		at: 2 put: self rcvr;
		at: 3 put: selector;
		at: 4 put: userSpec.
	argList := argMorphs.
	1 to: argList size do: [ :i | 
		arg := argList at: i.
		(arg isKindOf: ArgMorph) | (arg isKindOf: EventTitleMorph)
			ifTrue: [ 
				(arg isKindOf: MultiArgMorph)
					ifTrue: [ blockTuple at: i + 4 put: arg listValue convertStacksToTuples ]
					ifFalse: [ 
						((arg isKindOf: CSlotMorph) or: [ arg isKindOf: OSlotMorph ])
							ifTrue: [ blockTuple at: i + 4 put: arg asBlockTuple ]
							ifFalse: [ 
								(arg isKindOf: ExpressionArgMorph)
									ifTrue: [ 
										val := arg getExpression.
										eval := arg isNumberExpression
											ifTrue: [ 
												val = ' '
													ifTrue: [ val ]
													ifFalse: [ val asNumberNoError ] ]
											ifFalse: [ arg getExpression ] ]
									ifFalse: [ eval := arg evaluate ].
								blockTuple at: i + 4 put: eval ] ]	"a list" ]
			ifFalse: [ blockTuple at: i + 4 put: arg asBlockTuple ] ].
	^ blockTuple
]

{ #category : #'*PhratchObjStream' }
CustomCommandBlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
CustomCommandBlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		userSpec
	) from: anObjStream.


]

{ #category : #'*PhratchObjStream' }
CustomCommandBlockMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		userSpec
	) on: anObjStream.

]
