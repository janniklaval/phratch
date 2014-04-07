Extension { #name : #ScriptablePhratchMorph }

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> asReferenceTuple [

	self subclassResponsibility 
]

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> blockFromOldFormTuple: tuple receiver: scriptOwner [
	"Answer a new block for the given tuple."

	| k spec blockColor block argCount arg argBlock userSpec csp |
	k := tuple first.
	(#(#readVariable #changeVariable) includes: k)
		ifTrue: [ ^ self variableBlockFromTuple: tuple receiver: scriptOwner ].
	(#(#readBlockVariable #changeBlockVariable) includes: k)
		ifTrue: [ ^ self blockVariableBlockFromTuple: tuple receiver: scriptOwner ].
	#listNamed: = k
		ifTrue: [ 
			^ ListContentsBlockMorph new
				color: ScriptablePhratchMorph listBlockColor;
				receiver: scriptOwner;
				commandSpec: tuple second;
				selector: #listNamed:;
		yourself ].
	#lambda: = k
		ifTrue: [ 
			block := ReporterBlockMorph new.
			block
				color: Color lightGray;
				receiver: scriptOwner;
				selector: k;
				commandSpec: 'the $BlockId$ block'.
			(block argumentAt: 1) defaultValue: (tuple at: 2).
			^ block ].
	#doCustomBlock = k
		ifTrue: [ 
			userSpec := tuple at: 2.
			(scriptOwner definitionFor: (CustomBlockDefinition idFromSpec: userSpec)) isReporter
				ifTrue: [ 
					block := CustomReporterBlockMorph new.
					block isBoolean: (scriptOwner definitionFor: (CustomBlockDefinition idFromSpec: userSpec)) isBoolean ]
				ifFalse: [ block := CustomCommandBlockMorph new ].
			block
				receiver: scriptOwner;
				userSpec: userSpec.
			block isSpecialForm: true.
			block selector: #doCustomBlock.
			argCount := block argumentCount min: tuple size - 2.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 2.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: scriptOwner.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			^ block ].
	#doMakeNewList = k
		ifTrue: [ 
			block := MultiArgReporterBlockMorph new
				color: ScriptablePhratchMorph listBlockColor;
				receiver: scriptOwner;
				isSpecialForm: true;
				selector: #doMakeNewList;
		yourself.
			spec := 'list'.
			argCount := tuple size - 1.
			argCount timesRepeat: [ spec := spec , ' $String$' ].
			block commandSpec: spec.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 1.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: scriptOwner.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			^ block ].
	(#(#doCallBlockWithArgs #doReport) includes: k)
		ifTrue: [ 
			block := MultiArgReporterBlockMorph new
				color: (PhratchCategory blockColorFor: 'control');
				receiver: scriptOwner;
				isSpecialForm: true;
				minArgs: 1;
				selector: k;
		yourself.
			spec := scriptOwner blockSpecForSelector: k.
			argCount := tuple size - 1.
			argCount - 2 timesRepeat: [ spec := spec , ' $String$' ].
			block commandSpec: spec.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 1.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: scriptOwner.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			^ block ].
	(#(#function #functionWithArgs) includes: k)
		ifTrue: [ 
			block := ReporterScriptBlockMorph new
				color: (PhratchCategory blockColorFor: 'operators');
				receiver: scriptOwner;
				isSpecialForm: false;
				minArgs: 1;
				selector: k;
		yourself.
			spec := scriptOwner blockSpecForSelector: k.
			argCount := tuple size - 1.
			argCount - 2 timesRepeat: [ spec := spec , ' $String$' ].
			block commandSpec: spec.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 1.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: scriptOwner.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			^ block ].
	(#(#EventHatMorph #KeyEventHatMorph #MouseClickEventHatMorph) includes: k)
		ifTrue: [ 
			block := self hatBlockFromTuple: tuple receiver: scriptOwner.
			^ block ].
	({#phratchComment . #scratchComment} includes: k) "for compatibility"
		ifTrue: [ 
			block := PhratchCommentMorph new.
			tuple size > 1
				ifTrue: [ block commentMorph contents: (tuple at: 2) ].
			tuple size > 2
				ifTrue: [ 
					(tuple at: 3)
						ifFalse: [ block toggleShowing ] ].
			tuple size > 3
				ifTrue: [ block width: (tuple at: 4) ].
			tuple size > 4
				ifTrue: [ block anchor: (self blockWithID: (tuple at: 5)) ].
			^ block ].
	#comment: = k
		ifTrue: [ 
			block := CommentBlockMorph new.
			tuple size > 1
				ifTrue: [ block comment: (tuple at: 2) ].
			tuple size > 2
				ifTrue: [ 
					(tuple at: 3)
						ifFalse: [ block toggleShowing ] ].
			block color: (Color r: 0.8 g: 0 b: 0).	"obsolete"
			^ block ].
	spec := self class blockSpecDict at: k ifAbsent: [ nil ].
	spec ifNil: [ ^ scriptOwner blockFromSpec: #('obsolete!' #- #yourself) color: Color red ].
	blockColor := BlockColorDict at: k ifAbsent: [ Color red ].
	block := scriptOwner blockFromSpec: spec color: blockColor.
	#procedureWithArgs = block selector
		ifTrue: [ 
			argCount := tuple size - 2.
			argCount > 1
				ifTrue: [ 
					csp := block commandSpec.
					argCount - 1 timesRepeat: [ csp := csp , ' $String$' ].
					block commandSpec: csp ] ].
	(block isKindOf: CommandBlockMorph)
		ifTrue: [ 
			argCount := block argumentCount min: tuple size - 1.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 1.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: scriptOwner.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) defaultValue: arg ] ].
			(block isKindOf: CBlockMorph) | (block isKindOf: CommandScriptBlockMorph)
				ifTrue: [ 
					(tuple last isKindOf: Array)
						ifTrue: [ block firstBlockList: (self stackFromTupleList: tuple last receiver: scriptOwner) ] ].
			(block isKindOf: IfElseBlockMorph)
				ifTrue: [ 
					arg := tuple at: tuple size - 1.
					(arg isKindOf: Array)
						ifTrue: [ block trueBlock: (self stackFromTupleList: arg receiver: scriptOwner) ].
					arg := tuple at: tuple size.
					(arg isKindOf: Array)
						ifTrue: [ block falseBlock: (self stackFromTupleList: arg receiver: scriptOwner) ] ].
			(block isKindOf: ReporterBlockMorph)
				ifTrue: [ 
					((spec at: 2) includes: $b)
						ifTrue: [ block isBoolean: true ] ] ].
	^ block
]

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> blockFromTuple: tuple receiver: scriptOwner [
	"Answer a new block for the given tuple."

	| k rcvr spec blockColor block argCount arg argBlock userSpec csp def |
	(#byob = tuple first or:[#phratch = tuple first]) 
		ifFalse: [ ^ self blockFromOldFormTuple: tuple receiver: scriptOwner ].
	'Stage' = tuple second
		ifTrue: [ rcvr := self ownerOrYourselfThatIsAPhratchStageMorph ]
		ifFalse: [ 
			(tuple second isKindOf: VariableFrame)
				ifFalse: [ rcvr := self coerceSpriteArg: tuple second ] ].
	rcvr ifNil: [ rcvr := scriptOwner ].
	k := tuple third.
	(#(#readVariable #changeVariable) includes: k)
		ifTrue: [ ^ self variableBlockFromTuple: tuple receiver: rcvr ].
	(#(#readBlockVariable #changeBlockVariable) includes: k)
		ifTrue: [ ^ self blockVariableBlockFromTuple: tuple receiver: rcvr ].
	#listNamed: = k
		ifTrue: [ 
			^ ListContentsBlockMorph new
				color: ScriptablePhratchMorph listBlockColor;
				receiver: rcvr;
				commandSpec: tuple fourth;
				selector: #listNamed:;
		yourself ].
	#lambda: = k
		ifTrue: [ 
			block := ReporterBlockMorph new.
			block
				color: Color lightGray;
				receiver: rcvr;
				selector: k;
				commandSpec: 'the $BlockId$ block'.
			(block argumentAt: 1) defaultValue: (tuple at: 4).
			^ block ].
	#autoLambda = k
		ifTrue: [ 
			block := CSlotMorph new.
			(tuple at: 9) ifNotNil: [ block attachBlockNested: (self stackFromTupleList: (tuple at: 9) receiver: scriptOwner) ].
			^ block ].
	#loopLambda = k
		ifTrue: [ 
			block := CArgSlotMorph new.
			(tuple at: 9) ifNotNil: [ block attachBlockNested: (self stackFromTupleList: (tuple at: 9) receiver: scriptOwner) ].
			^ block ].
	#autoBlock = k
		ifTrue: [ 
			block := OSlotMorph new type: #reporterslot.
			(tuple at: 4)
				ifNotNil: [ block replaceArgMorph: block argMorphs first by: (self stackFromTupleList: (tuple at: 4) receiver: scriptOwner) ].
			^ block ].
	#cLambda = k
		ifTrue: [ 
			block := CReporterSlotMorph new.
			(tuple at: 4)
				ifNotNil: [ block replaceArgMorph: block argMorphs first by: (self stackFromTupleList: (tuple at: 4) receiver: scriptOwner) ].
			^ block ].
	#typeInLambda = k
		ifTrue: [ 
			block := TypeInReporterSlotMorph new.
			((tuple at: 4) isKindOf: String)
				ifTrue: [ block argMorphs first defaultValue: (tuple at: 4) ]
				ifFalse: [ block replaceArgMorph: block argMorphs first by: (self stackFromTupleList: (tuple at: 4) receiver: scriptOwner) ].
			^ block ].
	#autoPredicate = k
		ifTrue: [ 
			block := OSlotMorph new type: #booleanslot.
			(tuple at: 4)
				ifNotNil: [ block replaceArgMorph: block argMorphs first by: (self stackFromTupleList: (tuple at: 4) receiver: scriptOwner) ].
			^ block ].
	#doCustomBlock = k
		ifTrue: [ 
			userSpec := tuple at: 4.
			def := rcvr definitionFor: (CustomBlockDefinition idFromSpec: userSpec).
			(def isNil or: [ #none = def type ])
				ifTrue: [ block := CustomCommandBlockMorph new ]
				ifFalse: [ 
					block := CustomReporterBlockMorph new.
					block isBoolean: def type = #boolean ].
			block
				receiver: rcvr;
				userSpec: userSpec.
			block isSpecialForm: true.
			block selector: #doCustomBlock.
			argCount := block argumentCount min: tuple size - 4.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 4.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: scriptOwner.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(arg isKindOf: PhratchListMorph)
							ifTrue: [ arg convertBlockTuplesToStacksFor: self ].
						(block argumentAt: i) defaultValue: arg ] ].
			^ block ].
	#doMakeNewList = k
		ifTrue: [ 
			block := MultiArgReporterBlockMorph new
				color: ScriptablePhratchMorph listBlockColor;
				receiver: rcvr;
				isSpecialForm: true;
				selector: #doMakeNewList;
		yourself.
			spec := 'list'.
			argCount := tuple size - 3.
			argCount timesRepeat: [ spec := spec , ' $String$' ].
			block commandSpec: spec.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 3.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: rcvr.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			^ block ].
	(#(#doCallBlockWithArgs #doReport #doCallBlockWithArgList) includes: k)
		ifTrue: [ 
			block := MultiArgReporterBlockMorph new
				color: (PhratchCategory blockColorFor: 'control');
				receiver: rcvr;
				isSpecialForm: true;
				minArgs: 1;
				selector: k;
		yourself.
			spec := rcvr blockSpecForSelector: k.
			argCount := tuple size - 3.
			argCount - 3 timesRepeat: [ spec := spec , ' $String$' ].
			block commandSpec: spec.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 3.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: rcvr.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						((block argumentAt: i) isKindOf: ChoiceArgMorph)
							ifTrue: [ (block argumentAt: i) privateSetChoice: arg asString ]
							ifFalse: [ 
								arg isNil
									ifFalse: [ (block argumentAt: i) stringExpression: arg asString ] ] ] ].
			^ block ].
	(#(#function #functionWithArgs) includes: k)
		ifTrue: [ 
			block := ReporterScriptBlockMorph new
				color: (PhratchCategory blockColorFor: 'operators');
				receiver: rcvr;
				isSpecialForm: false;
				minArgs: 1;
				selector: k;
				parameters: (tuple at: 4) asOrderedCollection;
				variables: (tuple at: 5) asOrderedCollection;
				type: (tuple at: 6);
				declarations: (tuple at: 7);
				isAtomic: (tuple at: 8);
		yourself.
			spec := scriptOwner blockSpecForSelector: k.
			argCount := tuple size - 9.
			argCount - 2 timesRepeat: [ spec := spec , ' $String$' ].
			block commandSpec: spec.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 8.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: rcvr.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			block fixInitialFrame.
			^ block ].
	#doDeclareVariables = k
		ifTrue: [ 
			block := VariableDeclarationBlockMorph new
				receiver: rcvr;
				color: Color gray;
				isSpecialForm: true;
				minArgs: 1;
				selector: k;
		yourself.
			argCount := tuple size - 3.
			spec := 'script variables' localized.
			argCount timesRepeat: [ spec := spec , ' $String$' ].
			block commandSpec: spec.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 3.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: rcvr.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			^ block ].
	(#(#EventHatMorph #KeyEventHatMorph #MouseClickEventHatMorph #CreationEventHatMorph #StartEventHatMorph) includes: k)
		ifTrue: [ 
			block := self hatBlockFromTuple: tuple receiver: rcvr.
			^ block ].
	({#phratchComment . #scratchComment} includes: k) "for compatibility"
		ifTrue: [ 
			block := PhratchCommentMorph new.
			tuple size > 3
				ifTrue: [ block commentMorph contents: (tuple at: 4) ].
			tuple size > 4
				ifTrue: [ 
					(tuple at: 5)
						ifFalse: [ block toggleShowing ] ].
			tuple size > 5
				ifTrue: [ block width: (tuple at: 6) ].
			tuple size > 6
				ifTrue: [ block anchor: (self blockWithID: (tuple at: 7)) ].
			block
				toggleShowing;
				toggleShowing.
			^ block ].
	#comment: = k
		ifTrue: [ 
			block := CommentBlockMorph new.
			tuple size > 1
				ifTrue: [ block comment: (tuple at: 2) ].
			tuple size > 2
				ifTrue: [ 
					(tuple at: 3)
						ifFalse: [ block toggleShowing ] ].
			block color: (Color r: 0.8 g: 0 b: 0).	"obsolete"
			^ block ].
	spec := self class blockSpecDict at: k ifAbsent: [ nil ].
	spec ifNil: [ ^ rcvr blockFromSpec: #('obsolete!' #- #yourself #()) color: Color red ].
	blockColor := BlockColorDict at: k ifAbsent: [ Color red ].
	block := rcvr blockFromSpec: spec color: blockColor.
	#procedure = block selector
		ifTrue: [ 
			block
				parameters: (tuple at: 4) asOrderedCollection;
				variables: (tuple at: 5) asOrderedCollection;
				type: (tuple at: 6);
				declarations: (tuple at: 7);
				isAtomic: (tuple at: 8).
			argCount := tuple size - 9.
			argCount > 1
				ifTrue: [ 
					csp := block commandSpec.
					argCount - 1 timesRepeat: [ csp := csp , ' $String$' ].
					block commandSpec: csp ].
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 8.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: rcvr.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			(tuple last isKindOf: Array)
				ifTrue: [ block firstBlockList: (self stackFromTupleList: tuple last receiver: rcvr) ].
			block fixInitialFrame.
			^ block ].
	#procedureWithArgs = block selector
		ifTrue: [ 
			block
				parameters: (tuple at: 4) asOrderedCollection;
				variables: (tuple at: 5) asOrderedCollection;
				type: (tuple at: 6);
				declarations: (tuple at: 7);
				isAtomic: (tuple at: 8).
			argCount := tuple size - 9.
			argCount > 1
				ifTrue: [ 
					csp := block commandSpec.
					argCount - 1 timesRepeat: [ csp := csp , ' $String$' ].
					block commandSpec: csp ].
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 8.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: rcvr.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			(tuple last isKindOf: Array)
				ifTrue: [ block firstBlockList: (self stackFromTupleList: tuple last receiver: rcvr) ].
			block fixInitialFrame.
			^ block ].
	(block isKindOf: CommandBlockMorph)
		ifTrue: [ 
			argCount := block argumentCount min: tuple size - 3.
			(block isKindOf: MultiArgCommandBlockMorph)
				ifTrue: [ 
					argCount := tuple size - 3.
					csp := block commandSpec.
					argCount - 3 timesRepeat: [ csp := csp , ' $String$' ].
					block commandSpec: csp.
					1 to: argCount do: [ :i | 
						arg := tuple at: i + 3.
						(arg isKindOf: Array)
							ifTrue: [ 
								"argument is a block"
								(arg size = 1 and: [ arg first isKindOf: Array ])
									ifTrue: [ arg := arg first ].
								argBlock := self blockFromTuple: arg receiver: rcvr.
								block replaceArgMorph: (block argumentAt: i) by: argBlock ]
							ifFalse: [ 
								"argument is a value"
								((block argumentAt: i) isKindOf: ChoiceArgMorph)
									ifTrue: [ (block argumentAt: i) privateSetChoice: arg asString ]
									ifFalse: [ (block argumentAt: i) stringExpression: arg asString ] ] ].
					^ block ].
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 3.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: scriptOwner.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(arg isKindOf: PhratchListMorph)
							ifTrue: [ arg convertBlockTuplesToStacksFor: self ].
						(block argumentAt: i) defaultValue: arg ] ].
			(block isKindOf: CBlockMorph)
				ifTrue: [ 
					(tuple last isKindOf: Array)
						ifTrue: [ block firstBlockList: (self stackFromTupleList: tuple last receiver: rcvr) ] ].
			(block isKindOf: IfElseBlockMorph)
				ifTrue: [ 
					arg := tuple at: tuple size - 1.
					(arg isKindOf: Array)
						ifTrue: [ block trueBlock: (self stackFromTupleList: arg receiver: rcvr) ].
					arg := tuple at: tuple size.
					(arg isKindOf: Array)
						ifTrue: [ block falseBlock: (self stackFromTupleList: arg receiver: rcvr) ] ].
			(block isKindOf: ReporterBlockMorph)
				ifTrue: [ 
					((spec at: 2) includes: $b)
						ifTrue: [ block isBoolean: true ] ] ].
	^ block
]

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> blockVariableBlockFromTuple: tuple receiver: scriptOwner [
	"Answer a new block for the given variable reference tuple."

	| varName rcvr selector block arg argBlock |
	(#byob = tuple first or:[#phratch = tuple first])
		ifFalse: [ ^ self blockVariableBlockFromTupleOldForm: tuple receiver: scriptOwner ].
	varName := tuple at: 4.
	rcvr := scriptOwner.
	tuple third = #readBlockVariable
		ifTrue: [ 
			rcvr := ((tuple at: 5) isKindOf: VariableFrame)
				ifTrue: [ (tuple at: 5) convertTuplesToStacks ]
				ifFalse: [ VariableFrame new	"definitionFor: (CustomBlockDefinition idFromSpec: (tuple at: 5))" ].
			^ VariableBlockMorph new
				receiver: rcvr;
				selector: #getVar:;
				commandSpec: varName;
				isSpecialForm: true;
		yourself ].
	tuple third = #changeBlockVariable
		ifTrue: [ 
			selector := tuple at: 5.
			rcvr := ((tuple at: 6) isKindOf: VariableFrame)
				ifTrue: [ (tuple at: 6) convertTuplesToStacks ]
				ifFalse: [ rcvr definitionFor: (CustomBlockDefinition idFromSpec: (tuple at: 6)) ].
			block := SetterBlockMorph new color: (PhratchCategory blockColorFor: 'variables').
			(#(#setVar:to: #setBlockVar:to:) includes: selector)
				ifTrue: [ block initSetterForVar: varName ]
				ifFalse: [ block initChangerForVar: varName ].
			block
				receiver: rcvr;
				isSpecialForm: true.
			arg := tuple at: 7.
			(arg isKindOf: Array)
				ifTrue: [ 
					"argument is a block"
					(arg size = 1 and: [ arg first isKindOf: Array ])
						ifTrue: [ arg := arg first ].
					argBlock := self blockFromTuple: arg receiver: scriptOwner.
					block replaceArgMorph: block expressionArg by: argBlock ]
				ifFalse: [ 
					"argument is a value"
					block expressionArg defaultValue: arg ].
			^ block ].
	self error: 'unknown block variable spec'
]

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> blockVariableBlockFromTupleOldForm: tuple receiver: scriptOwner [
	"Answer a new block for the given variable reference tuple."

	| varName rcvr selector block arg argBlock |
	varName := tuple at: 2.
	rcvr := scriptOwner.
	tuple first = #readBlockVariable
		ifTrue: [ 
			rcvr := (tuple third isKindOf: VariableFrame)
				ifTrue: [ tuple third convertTuplesToStacks ]
				ifFalse: [ rcvr definitionFor: (CustomBlockDefinition idFromSpec: tuple third) ].
			^ VariableBlockMorph new
				receiver: rcvr;
				selector: #getVar:;
				commandSpec: varName;
				isSpecialForm: true;
		yourself ].
	tuple first = #changeBlockVariable
		ifTrue: [ 
			selector := tuple at: 3.
			rcvr := (tuple fourth isKindOf: VariableFrame)
				ifTrue: [ tuple fourth convertTuplesToStacks ]
				ifFalse: [ rcvr definitionFor: (CustomBlockDefinition idFromSpec: tuple fourth) ].
			block := SetterBlockMorph new
				receiver: rcvr;
				color: (PhratchCategory blockColorFor: 'variables');
		yourself.
			(#(#setVar:to: #setBlockVar:to:) includes: selector)
				ifTrue: [ block initSetterForVar: varName ]
				ifFalse: [ block initChangerForVar: varName ].
			block isSpecialForm: true.
			arg := tuple at: 5.
			(arg isKindOf: Array)
				ifTrue: [ 
					"argument is a block"
					(arg size = 1 and: [ arg first isKindOf: Array ])
						ifTrue: [ arg := arg first ].
					argBlock := self blockFromTuple: arg receiver: scriptOwner.
					block replaceArgMorph: block expressionArg by: argBlock ]
				ifFalse: [ 
					"argument is a value"
					block expressionArg defaultValue: arg ].
			^ block ].
	self error: 'unknown block variable spec'
]

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> blockWithID: id [

	| topBlockList blockList|

	topBlockList := (blocksBin submorphs select: [:m | (m isKindOf: BlockMorph) ]) reversed.
	blockList := OrderedCollection new.
	topBlockList do: [:top | (top allMorphs select: [:b| b isKindOf: BlockMorph ]) do: [:m |
		blockList add: m ]].

	^ blockList at: id ifAbsent: [nil].

]

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> convertListVarReferencesToTuples [
	"format conventions:

		sprite:
					1 - #sprite
					2 - name

		stage:		#stage

		block: 
					1 - #block
					2 - receiver
					3 - tupleSequence

		named list reference:

					1 - #namedList
					2 - target obj name
					3 - list name

		variable-bound anonymous list reference:

					1 - #variableList
					2 - target obj name
					3 - var name

		anonymous list (either within a list or bound to a variable):

					converted to tuples in place"

	| obj ref rcvr |
	self varNames
		do: [ :varName | 
			obj := self getVar: varName.
			(obj isKindOf: BlockMorph)
				ifTrue: [ 
					rcvr := (obj receiver isKindOf: ScriptablePhratchMorph)
						ifTrue: [ 
							(obj receiver isKindOf: PhratchStageMorph)
								ifTrue: [ 'Stage' ]
								ifFalse: [ obj receiver objName ] ]
						ifFalse: [ '' ].
					vars at: varName put: (Array with: #block with: rcvr with: obj tupleSequence) ].
			(obj isKindOf: PhratchListMorph)
				ifTrue: [ 
					ref := obj asReferenceTuple.
					ref first = #variableList
						&
							({objName.
							'Stage'} includes: ref second) & (ref third = varName)
						ifTrue: [ obj convertStacksToTuples ]
						ifFalse: [ vars at: varName put: ref ] ].
			(obj isKindOf: ScriptablePhratchMorph)
				ifTrue: [ 
					ref := obj asReferenceTuple.
					vars at: varName put: ref ] ]
]

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> convertStacksToTuples [
	"Convert my blocks bin from a morph containing block stack into a collection of (<point>, <tuple>) pairs the represent the same stacks in compact, language-independent form."

	| stacks blocks comments |
	(blocksBin isKindOf: Array) ifTrue: [^ self].  "already converted"

	self lists do: [:l | l convertStacksToTuples ].
	self convertListVarReferencesToTuples.

	stacks := (blocksBin submorphs select: [:m | m respondsTo: #tupleSequence]).
	blocks := stacks select: [:m | m isKindOf: BlockMorph].
	comments := stacks select: [:m | m isKindOf: PhratchCommentMorph].

	blocks := blocks collect: [:blockM | 
		Array
			with: blockM position - blocksBin position
			with: blockM tupleSequence].

	comments := comments collect: [:blockM |
		Array
			with: blockM position - blocksBin position
			with: blockM tupleSequence].

	blocksBin := blocks, comments.

	customBlocks ifNil: [^self].
	customBlocks do: [:eachDef|
		eachDef fixBlockVarReporters.
		eachDef body ifNotNil: [
			eachDef body: eachDef body tupleSequence ].
		eachDef answer ifNotNil: [
			(eachDef answer isKindOf: ReporterBlockMorph) 
				ifTrue:[	eachDef answer: eachDef answer tupleSequence ]]].


]

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> convertTuplesToDefinitions [

	customBlocks ifNil: [^ self].
	customBlocks do: [:eachDef |
		eachDef body ifNotNil: [ 
			(eachDef body isKindOf: Array) ifTrue: [
				eachDef body: (self stackFromTupleList: eachDef body receiver: self)]].
		eachDef answer ifNotNil: [ 
			(eachDef answer isKindOf: Array)
				ifTrue: [eachDef answer: (self stackFromTupleList: eachDef answer receiver: self)]].
		eachDef migrateBlockVars].

]

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> convertTuplesToStacks [
	"Convert my blocks bin from a collection of (<point>, <tuple>) pairs into a morph containing a number of block stacks."

	| tuplesList stack |

	(blocksBin isKindOf: Array) ifFalse: [^ self].  "already converted"

	self lists do: [:l | l value convertTuplesToStacks ].
	self convertVarTuplesToListReferences.
	self convertTuplesToDefinitions.

	tuplesList := blocksBin.
	blocksBin := PhratchScriptsMorph new.
	tuplesList do: [:pair |
		stack := self stackFromTupleList: pair second receiver: self.
		stack position: pair first.
		blocksBin addMorph: stack].

	blocksBin allMorphsDo: [:m |
		(m isKindOf: AttributeArgMorph) ifTrue: [
			m refresh ]]


]

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> convertVarTuplesToListReferences [
	"format conventions:

		sprite:
					1 - #sprite
					2 - name

		stage:		#stage

		block: 
					1 - #block
					2 - receiver
					3 - tupleSequence

		named list reference:

					1 - #namedList
					2 - target obj name
					3 - list name

		variable-bound anonymous list reference:

					1 - #variableList
					2 - target obj name
					3 - var name

		anonymous list (either within a list or bound to a variable):

					converted to tuples in place"

	| obj rcvr stage block |
	self varNames
		do: [ :varName | 
			obj := self getVar: varName.
			(obj isKindOf: PhratchListMorph)
				ifTrue: [ obj convertTuplesToStacks ].
			(obj isKindOf: Array)
				ifTrue: [ 
					stage := self ownerOrYourselfThatIsAPhratchStageMorph.
					rcvr := obj second = 'Stage'
						ifTrue: [ stage ]
						ifFalse: [ stage coerceSpriteArg: obj second ].
					#block = obj first
						ifTrue: [ 
							block := stage stackFromTupleList: obj third receiver: rcvr.
							varName ifNotNil: [ vars at: varName put: block ] ].
					#namedList = obj first
						ifTrue: [ vars at: varName put: (stage listNamed: obj third targetName: obj second) ].
					#variableList = obj first
						ifTrue: [ vars at: varName put: (stage listInVarNamed: obj third targetName: obj second) ].
					#stage = obj first
						ifTrue: [ vars at: varName put: stage ].
					#sprite = obj first
						ifTrue: [ vars at: varName put: (stage coerceSpriteArg: obj second) ] ] ]
]

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph class >> currentEncoding [
		^ObjEncoding ifNil: [^#phratch ]
]

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> hatBlockFromTuple: tuple receiver: scriptOwner [
	"Answer a new block for the given variable reference tuple."

	| blockClass block eventName |

	(#byob = tuple first or:[#phratch = tuple first]) ifFalse: [
		^self hatBlockFromTupleOldForm: tuple receiver: scriptOwner ].

	blockClass := Smalltalk at: tuple third.
	block := blockClass new scriptOwner: scriptOwner.

	blockClass = StartEventHatMorph ifTrue: [
		eventName := tuple at: 4.
		block forStartEvent; scriptOwner: scriptOwner].
		
	blockClass = EventHatMorph ifTrue: [
		eventName := tuple at: 4.
		block eventName: eventName].

	blockClass = KeyEventHatMorph ifTrue: [
		block choice: (tuple at: 4)].

	^ block

]

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> hatBlockFromTupleOldForm: tuple receiver: scriptOwner [
	"Answer a new block for the given variable reference tuple."

	| blockClass block eventName |
	blockClass := Smalltalk at: tuple first.
	block := blockClass new scriptOwner: scriptOwner.

	blockClass = StartEventHatMorph ifTrue: [
		eventName := tuple at: 2.
		block forStartEvent; scriptOwner: scriptOwner].
	
	blockClass = EventHatMorph ifTrue: [
		eventName := tuple at: 2.
		block eventName: eventName].

	blockClass = KeyEventHatMorph ifTrue: [
		block choice: (tuple at: 2)].

	^ block

]

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
	(self class currentEncoding = #byob or: [self class currentEncoding = #phratch])
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
ScriptablePhratchMorph >> purgeVarsAndLists [

	vars keysDo: [:each |
		((vars at: each) isKindOf: BlockMorph)
			ifTrue: [vars at: each put: '']].

"
	vars keysDo: [:each |
		(((vars at: each) isKindOf: PhratchListMorph) or: [(vars at: each) isKindOf: BlockMorph ])
			ifTrue: [vars at: each put: '']].

"
]

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> stackFromTupleList: tupleList receiver: scriptOwner [
	"Answer a new block stack from the given sequence of tuples."
	"self stackFromTupleList: #() receiver: nil"

	| stackTop previousBlock block |
	stackTop := previousBlock := nil.
	tupleList do: [:tuple | 
		block := self blockFromTuple: tuple receiver: scriptOwner.
		previousBlock
			ifNil: [stackTop := block]
			ifNotNil: [previousBlock nextBlock: block].
		previousBlock := block].

	^ stackTop

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

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> variableBlockFromTuple: tuple receiver: scriptOwner [
	"Answer a new block for the given variable reference tuple."

	| varName rcvr bg selector block arg argBlock |

	(#byob = tuple first or:[#phratch = tuple first]) ifFalse: [
		^self variableBlockFromTupleOldForm: tuple receiver: scriptOwner ].

	varName := tuple at: 4.
	rcvr := scriptOwner.
	(varName isKindOf: Array) ifFalse: [
		varName = '' ifFalse: [
			(scriptOwner varNames includes: varName) ifFalse: [
				bg := scriptOwner ownerOrYourselfThatIsAPhratchStageMorph.
				bg
					ifNil: [scriptOwner addVariable: varName]
					ifNotNil: [
						bg addVariable: varName.
						"rcvr := bg"]]]].

	tuple third = #readVariable ifTrue: [
		^ VariableBlockMorph new
			commandSpec: varName;
			selector: #getVar:;
			receiver: rcvr;
		yourself].

	tuple third = #changeVariable ifTrue: [
		selector := tuple at: 5.
		"update selector if necessary (backward compatibility):"
		(selector = #set:to:) ifTrue: [selector := #setVar:to:].
		block := SetterBlockMorph new.
		block receiver: rcvr.
		selector = #setVar:to:
			ifTrue: [block initSetterForVar: varName]
			ifFalse: [block initChangerForVar: varName].

		block receiver: rcvr.

		arg := tuple at: 6.
		(arg isKindOf: Array)
			ifTrue: [  "argument is a block"
				((arg size = 1) and: [arg first isKindOf: Array]) ifTrue: [arg := arg first].
				argBlock := self blockFromTuple: arg receiver: scriptOwner.
				block replaceArgMorph: block expressionArg by: argBlock]
			ifFalse: [ "argument is a value"
				block expressionArg defaultValue: arg].

		^ block].

	self error: 'unknown variable spec'

]

{ #category : #'*PhratchObjStream' }
ScriptablePhratchMorph >> variableBlockFromTupleOldForm: tuple receiver: scriptOwner [
	"Answer a new block for the given variable reference tuple."

	| varName rcvr bg selector block arg argBlock |

	varName := tuple at: 2.
	rcvr := scriptOwner.
	(scriptOwner varNames includes: varName) ifFalse: [
		bg := scriptOwner ownerOrYourselfThatIsAPhratchStageMorph.
		bg
			ifNil: [scriptOwner addVariable: varName]
			ifNotNil: [
				bg addVariable: varName.
				"rcvr := bg"]].

	tuple first = #readVariable ifTrue: [
		^ VariableBlockMorph new
			commandSpec: varName;
			selector: #getVar:;
			receiver: rcvr;
		yourself].

	tuple first = #changeVariable ifTrue: [
		selector := tuple at: 3.
		"update selector if necessary (backward compatibility):"
		(selector = #set:to:) ifTrue: [selector := #setVar:to:].
		block := SetterBlockMorph new.
		selector = #setVar:to:
			ifTrue: [block initSetterForVar: varName]
			ifFalse: [block initChangerForVar: varName].

		block receiver: rcvr.

		arg := tuple at: 4.
		(arg isKindOf: Array)
			ifTrue: [  "argument is a block"
				((arg size = 1) and: [arg first isKindOf: Array]) ifTrue: [arg := arg first].
				argBlock := self blockFromTuple: arg receiver: scriptOwner.
				block replaceArgMorph: block expressionArg by: argBlock]
			ifFalse: [ "argument is a value"
				block expressionArg defaultValue: arg].

		^ block].

	self error: 'unknown variable spec'

]
