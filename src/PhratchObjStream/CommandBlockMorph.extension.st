Extension { #name : #CommandBlockMorph }

{ #category : #'*PhratchObjStream' }
CommandBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	| blockTuple argList arg val eval |
	blockTuple := Array new: argMorphs size + 3.
	blockTuple
		at: 1 put: #phratch;
		at: 2 put: self rcvr;
		at: 3 put: selector.
	argList := argMorphs.
	argList := self organizeArgs: argList.
	1 to: argList size do: [ :i | 
		arg := argList at: i.
		(arg isKindOf: ArgMorph) | (arg isKindOf: EventTitleMorph)
			ifTrue: [ 
				(arg isKindOf: MultiArgMorph)
					ifTrue: [ blockTuple at: i + 3 put: arg listValue convertStacksToTuples ]
					ifFalse: [ 
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
													ifFalse: [ 
														(arg evaluate isKindOf: Symbol)
															ifTrue: [ arg evaluate ]
															ifFalse: [ val asNumberNoError ]	" special case for special values in list blocks (first, last, any)" ] ]
											ifFalse: [ arg evaluate ] ]
									ifFalse: [ 
										eval := (arg isKindOf: SpriteArgMorph)
											ifTrue: [ arg getChoice ]
											ifFalse: [ arg evaluate ] ].
								blockTuple at: i + 3 put: eval ] ]	"a list" ]
			ifFalse: [ blockTuple at: i + 3 put: arg asBlockTuple ] ].
	^ blockTuple
]

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
CommandBlockMorph >> rcvr [
	"answer a String description of my receiver which can be used in a tuple"

	| rcvr |
	rcvr := (receiver isKindOf: ScriptablePhratchMorph)
		ifTrue: [ 
			(receiver isKindOf: PhratchStageMorph)
				ifTrue: [ 'Stage' ]
				ifFalse: [ receiver objName ] ]
		ifFalse: [ '' ].
	^ rcvr
]
