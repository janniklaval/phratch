Class {
	#name : #ReporterScriptBlockMorph,
	#superclass : #LambdaBlockMorph,
	#category : #'Phratch-BYOB'
}

{ #category : #'as yet unclassified' }
ReporterScriptBlockMorph >> addItem [
	| varBlock pos pname |
	super addItem.
	pos := (argMorphs reject: [:m | m == self nextBlock]) size.
	(self isKindOf: CommandScriptBlockMorph)
		ifFalse: [pos := pos - 1 ].
	pname := ('#', pos printString) asUTF8.
	varBlock := VariableBlockMorph new.
	varBlock 
		isSpecialForm: true;
		receiver: initialFrame;	
		selector: #getVar:;
		commandSpec: pname.
	(self isKindOf: CommandScriptBlockMorph)
		ifTrue: [ self replaceArgMorph: (self argumentAt: pos) by: varBlock ]
		ifFalse: [ self replaceArgMorph: (self argumentAt: pos + 1) by: varBlock].
	parameters add: pname.
	initialFrame add: pname

]

{ #category : #'as yet unclassified' }
ReporterScriptBlockMorph >> addRemove [
	| varBlock pos |
	super removeItem.

	pos := (argMorphs reject: [:m | m == self nextBlock]) size.
	(self isKindOf: CommandScriptBlockMorph)
		ifFalse: [pos := pos - 1 ].
	varBlock := VariableBlockMorph new.
	varBlock 
		isSpecialForm: true;
		receiver: nil;	
		selector: #getBlockVar:;
		commandSpec: '#', pos printString.
	(self isKindOf: CommandScriptBlockMorph)
		ifTrue: [ self replaceArgMorph: (self argumentAt: pos) by: varBlock ]
		ifFalse: [ self replaceArgMorph: (self argumentAt: pos + 1) by: varBlock]
]

{ #category : #'as yet unclassified' }
ReporterScriptBlockMorph >> adjustInternals [
	"private"

	| newSelector sdict newSpec |
	(#(function functionWithArgs) includes: selector) ifFalse: [^ self ].

	argMorphs size > 1 
		ifTrue: [
			sdict := Dictionary new
				at: #function put: #functionWithArgs;
				yourself]
		ifFalse: [
			sdict := Dictionary new
				at: #functionWithArgs put: #function;
				yourself].

	receiver ifNil: [^ self ].
	newSelector := sdict at: selector ifAbsent: [selector].
	newSelector = selector ifTrue: [^ self].
	selector := newSelector.

	newSpec := self receiver blockSpecForSelector: selector.
	newSpec := newSpec asMacRoman localized.

	self commandSpec: newSpec.

]

{ #category : #'as yet unclassified' }
ReporterScriptBlockMorph >> args [
	^argMorphs
]

{ #category : #'as yet unclassified' }
ReporterScriptBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	| blockTuple arg argList |
	blockTuple := Array new: argMorphs size + 9.
	blockTuple
		at: 1 put: #byob;
		at: 2 put: self rcvr;
		at: 3 put: selector;
		at: 4 put: parameters asArray;
		at: 5 put: variables asArray;
		at: 6 put: type;
		at: 7 put: declarations;
		at: 8 put: isAtomic.

	argList := argMorphs.
	argList := self organizeArgs: argList.
	1 to: argList size do: [:i |
		arg := argList at: i.
		(arg isKindOf: ArgMorph)
			ifTrue: [blockTuple at: i + 8 put: arg evaluate]
			ifFalse: [blockTuple at: i + 8 put: arg asBlockTuple]].

	^ blockTuple

]

{ #category : #'as yet unclassified' }
ReporterScriptBlockMorph >> body [
	(argMorphs first isKindOf: BlockMorph)
		ifTrue: [^ argMorphs first fullCopy].
	^ nil
]

{ #category : #'as yet unclassified' }
ReporterScriptBlockMorph >> deleteVariableTemplate: aVarBlockMorph [

	aVarBlockMorph delete.
	argMorphs remove: aVarBlockMorph.
	self commandSpec: (commandSpec copyFrom: 1 to: commandSpec size - 3)
]

{ #category : #drawing }
ReporterScriptBlockMorph >> drawOn: aCanvas [

	super drawOn: aCanvas.
	self drawSlotBorderOn: aCanvas
]

{ #category : #drawing }
ReporterScriptBlockMorph >> drawSlotBorderOn: aCanvas [

	(argMorphs first isKindOf: SpecialArgMorph)
		ifFalse: [^ self].

	aCanvas paintImage: (argMorphs first imageForm outlineEmbeddedAdjustedColor: color)
				at: argMorphs first position - 1



]

{ #category : #'as yet unclassified' }
ReporterScriptBlockMorph >> helpScreenName [
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	^'reporterLambda'
]

{ #category : #'as yet unclassified' }
ReporterScriptBlockMorph >> initialize [

	super initialize.
	type := #any

]

{ #category : #'as yet unclassified' }
ReporterScriptBlockMorph >> isBooleanFunction [
	^ isBoolean
]

{ #category : #'as yet unclassified' }
ReporterScriptBlockMorph >> isFunction [
	^ true
]

{ #category : #'as yet unclassified' }
ReporterScriptBlockMorph >> nestedBlock [
	^self args first
]

{ #category : #'as yet unclassified' }
ReporterScriptBlockMorph >> optimized [
	| newBlock reportBlock sel body a rcv |

	rcv := self receiver.
	rcv ifNil: [rcv := ScriptablePhratchMorph new].
	(#(function #autoBlock) includes: selector)
		ifTrue: [sel := #procedure]
		ifFalse: [sel := #procedureWithArgs].
	newBlock := rcv blockFromSpec: (rcv wholeBlockSpecForSelector: sel) 
							color: (ScriptablePhratchMorph blockColorFor: 'operators').

	newBlock isAtomic: (isAtomic or: [self isKindOf: OSlotMorph]).

	reportBlock := rcv blockFromSpec: (rcv wholeBlockSpecForSelector: #doAnswer) 
							color: (ScriptablePhratchMorph blockColorFor: 'control').

	body := self body.
	body ifNotNil:[
		reportBlock replaceArgMorph: (reportBlock argMorphs first) by: body].

	2 to: argMorphs size - 1 do: [:i |
		newBlock addItem ].

	2 to: argMorphs size do: [:i |
		a := (argMorphs at: i) fullCopy.
		newBlock replaceArgMorph: (newBlock argMorphs at: i - 1) by: a ].

	newBlock attachBlock: reportBlock.
	newBlock parameters: parameters.
	newBlock variables: variables.
	newBlock fixInitialFrame.
	^newBlock
]

{ #category : #'as yet unclassified' }
ReporterScriptBlockMorph >> privateBody [
	"no copy"
	(argMorphs first isKindOf: BlockMorph)
		ifTrue: [^ argMorphs first].
	^ nil
]

{ #category : #'as yet unclassified' }
ReporterScriptBlockMorph >> removeItem [
	argMorphs size > self minArgs ifTrue: [
		self removeLastArg.
		self commandSpec: (commandSpec copyFrom: 1 to: commandSpec size - 3) ]
]