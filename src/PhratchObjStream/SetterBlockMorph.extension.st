Extension { #name : #SetterBlockMorph }

{ #category : #'*PhratchObjStream' }
SetterBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments.
	variable accessor blocks come in two flavors: Those onces statically accessing sprite or stage variables, and those ones dynamically bound to other environments. The latter ones are marked as special forms.  To stay compatible with Scratch (which doesn't have temporaries or block vars) the isSpecialForm flag is not put into the file format, instead the distinction is made via an explanatory symbol:

	isSpecialForm 	 	=	#changeBlockVariable
	isSpecialForm not	=	#changeVariable

this symbol is *not* the selector!. Instead the selector goes into slot 5. The information to be gathered from the selector is, whether the block is a *setter* or a *getter*

"

	| arg rcvr blockTuple val eval var |
	isSpecialForm
		ifTrue: [ 
			rcvr := (receiver isKindOf: VariableFrame)
				ifTrue: [ receiver convertStacksToTuples ]
				ifFalse: [ nil ].
			blockTuple := Array new: 7.
			blockTuple
				at: 1 put: #phratch;
				at: 2 put: self rcvr;
				at: 3 put: #changeBlockVariable;
				at: 4 put: self variable;
				at: 5 put: selector;
				at: 6 put: rcvr;
				at: 7 put: nil.	"not really needed for this block. late-bound. JM"
			arg := (argMorphs first isKindOf: ChoiceArgMorph)
				ifTrue: [ argMorphs last ]
				ifFalse: [ argMorphs first ].
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
					blockTuple at: 7 put: eval ]
				ifFalse: [ blockTuple at: 7 put: arg asBlockTuple ] ]
		ifFalse: [ 
			var := self variable.
			(var isKindOf: CommandBlockMorph)
				ifTrue: [ var := var asBlockTuple ].
			blockTuple := Array new: 6.
			blockTuple
				at: 1 put: #phratch;
				at: 2 put: self rcvr;
				at: 3 put: #changeVariable;
				at: 4 put: var;
				at: 5 put: selector;
				at: 6 put: nil.	"not really needed for this block. late-bound. JM"	"determine if the block is a getter or a setter:"
			arg := ((argMorphs first isKindOf: ChoiceArgMorph) or: [ argMorphs first isKindOf: ReporterBlockMorph ])
				ifTrue: [ argMorphs last ]
				ifFalse: [ argMorphs first ].
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
					blockTuple at: 6 put: eval ]
				ifFalse: [ blockTuple at: 6 put: arg asBlockTuple ] ].
	^ blockTuple
]

{ #category : #'*PhratchObjStream' }
SetterBlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
SetterBlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		variable
	) from: anObjStream.
	self variable: variable.

]

{ #category : #'*PhratchObjStream' }
SetterBlockMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	variable := self variable.
	self storeFieldsNamed: #(
		variable
	) on: anObjStream.

]
