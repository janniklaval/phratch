Extension { #name : #VariableBlockMorph }

{ #category : #'*PhratchObjStream' }
VariableBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments.

	variable accessor blocks come in two flavors: Those onces statically accessing sprite or stage variables, and those ones dynamically bound to other environments. The latter ones are marked as special forms.  To stay compatible with Scratch (which doesn't have temporaries or block vars) the isSpecialForm flag is not put into the file format, instead the distinction is made via an explanatory symbol:

	isSpecialForm 	 	=	#readBlockVariable
	isSpecialForm not	=	#readVariable
"

	| blockTuple rcvr |

	isSpecialForm 
		ifTrue: [ 
			(receiver isKindOf: VariableFrame)
				ifTrue: [ rcvr := receiver convertStacksToTuples ]
				ifFalse: [ receiver ifNotNil: [rcvr := receiver userSpec ]].
			blockTuple := Array new: 5.
			blockTuple
				at: 1 put: #phratch;
				at: 2 put: self rcvr;			"not really needed for this block. JM"
				at: 3 put: #readBlockVariable;
				at: 4 put: commandSpec;
				at: 5 put: rcvr ]
		ifFalse: [

			self evaluate. "ensure desparate re-binding of orphaned and rescoped variable getters"

			blockTuple := Array new: 4.
			blockTuple
				at: 1 put: #phratch;
				at: 2 put: self rcvr;			"not really needed for this block. JM"
				at: 3 put: #readVariable;
				at: 4 put: commandSpec ].
	^ blockTuple
]

{ #category : #'*PhratchObjStream' }
VariableBlockMorph >> fieldsVersion [

	^ 1

]
