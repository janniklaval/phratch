"
I am a block for setting a variable.

"
Class {
	#name : #SetterBlockMorph,
	#superclass : #CommandBlockMorph,
	#instVars : [
		'variable'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #private }
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

{ #category : #byob }
SetterBlockMorph >> contrastColor [
	| newColor |
	newColor := isSpecialForm
		ifTrue: [ VariableFrame variableBlockColor ]
		ifFalse: [ ScriptablePhratchMorph blockColorFor: 'variables' ].
	color = newColor
		ifFalse: [ self color: newColor ].
	super contrastColor
]

{ #category : #byob }
SetterBlockMorph >> determineIfSpecialForm [

	"also rebind my receiver to the sprite or stage that has my variable
	if it's not a temporay one"

	isSpecialForm := (self scriptVars includes: self variable).
	isSpecialForm ifFalse: [
		receiver := self phratchObject ]. 

	isSpecialForm
		ifTrue: [self color: VariableFrame variableBlockColor]
		ifFalse: [self color: (ScriptablePhratchMorph blockColorFor: 'variables')].


]

{ #category : #accessing }
SetterBlockMorph >> expressionArg [

	submorphs do: [:m |
		(m isKindOf: ExpressionArgMorph) ifTrue: [^ m]].

	^ nil
]

{ #category : #accessing }
SetterBlockMorph >> helpScreenName [
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	#setVar:to: = selector
		ifTrue: [^ 'variableSet']
		ifFalse: [^ 'variableChangeBy']

]

{ #category : #initialization }
SetterBlockMorph >> initChangerForVar: varName [

	| var |
	var := varName.
	(var isKindOf: Array) ifTrue: [
		var := receiver blockFromTuple: var receiver: receiver].

	self commandSpec: (PhratchTranslator translationFor: 'change $Variable$ by $String$').
	argPermutation := CommandBlockMorph argPermutationForSpec: 'set $Variable$ to $String$' withTranslation: commandSpec.
	self selector: #changeVar:by:.
	self variable: var.

]

{ #category : #initialization }
SetterBlockMorph >> initSetterForVar: varName [

	| var |
	var := varName.
	(var isKindOf: Array) ifTrue: [
		var := receiver blockFromTuple: var receiver: receiver].
	
	self commandSpec: (PhratchTranslator translationFor: 'set $Variable$ to $String$').
	argPermutation := CommandBlockMorph argPermutationForSpec: 'set $Variable$ to $String$' withTranslation: commandSpec.
	self selector: #setVar:to:.
	self variable: var.

]

{ #category : #initialization }
SetterBlockMorph >> initialize [

	super initialize.
	isSpecialForm := false.
	isTimed := false.

]

{ #category : #accessing }
SetterBlockMorph >> receiver: anObject [
	"Set my receiver object and, if possible, my block color."

	receiver := anObject.
	(receiver respondsTo: #variableBlockColor)
		ifTrue: [self color: receiver variableBlockColor].

]

{ #category : #byob }
SetterBlockMorph >> replaceArgMorph: oldMorph by: newMorph [
	"Replace oldMorph with newMorph in my argMorphs and submorphs lists. This is done when dropping a reporter block onto one of my arguments."


	super replaceArgMorph: oldMorph by: newMorph.
	oldMorph = argMorphs first ifTrue: [
		self determineIfSpecialForm]
]

{ #category : #accessing }
SetterBlockMorph >> variable [

	submorphs do: [:m |
		(m isKindOf: ChoiceArgMorph) ifTrue: [^ m choice]].
	^ ''


]

{ #category : #accessing }
SetterBlockMorph >> variable: aVar [

	(aVar isKindOf: CommandBlockMorph) ifTrue: [
		^ self replaceArgMorph: self argMorphs first by: aVar].
	submorphs do: [:m |
		(m isKindOf: ChoiceArgMorph) ifTrue: [^ m choice: aVar]].


]
