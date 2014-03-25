Class {
	#name : #ReporterScriptBlockMorph,
	#superclass : #LambdaBlockMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #'as yet unclassified' }
ReporterScriptBlockMorph class >> blockTypeOn: aScriptablePhratchMorph spec: spec color: blockColor [
	
	|block|
	block :=  self new minArgs: 1.
	block isSpecialForm: false.
	^block
]

{ #category : #adding }
ReporterScriptBlockMorph >> addItem [
	| varBlock pos pname |
	super addItem.
	pos := (argMorphs reject: [:m | m == self nextBlock]) size.
	(self isCommandScriptBlockMorph)
		ifFalse: [pos := pos - 1 ].
	pname := ('#', pos printString).
	varBlock := VariableBlockMorph new.
	varBlock 
		isSpecialForm: true;
		receiver: initialFrame;	
		selector: #getVar:;
		commandSpec: pname.
	(self isCommandScriptBlockMorph)
		ifTrue: [ self replaceArgMorph: (self argumentAt: pos) by: varBlock ]
		ifFalse: [ self replaceArgMorph: (self argumentAt: pos + 1) by: varBlock].
	parameters add: pname.
	initialFrame add: pname

]

{ #category : #private }
ReporterScriptBlockMorph >> adjustInternals [
	"private"

	| newSelector sdict newSpec |
	(#(#function #functionWithArgs) includes: selector)
		ifFalse: [ ^ self ].
	sdict := argMorphs size > 1
		ifTrue: [ 
			Dictionary new
				at: #function put: #functionWithArgs;
				yourself ]
		ifFalse: [ 
			Dictionary new
				at: #functionWithArgs put: #function;
				yourself ].
	receiver ifNil: [ ^ self ].
	newSelector := sdict at: selector ifAbsent: [ selector ].
	newSelector = selector
		ifTrue: [ ^ self ].
	selector := newSelector.
	newSpec := self receiver blockSpecForSelector: selector.
	newSpec := newSpec localized.
	self commandSpec: newSpec
]

{ #category : #accessing }
ReporterScriptBlockMorph >> args [
	^argMorphs
]

{ #category : #accessing }
ReporterScriptBlockMorph >> body [
	(argMorphs first isBlockMorph)
		ifTrue: [^ argMorphs first fullCopy].
	^ nil
]

{ #category : #deleting }
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

{ #category : #accessing }
ReporterScriptBlockMorph >> helpScreenName [
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	^'reporterLambda'
]

{ #category : #initialization }
ReporterScriptBlockMorph >> initialize [

	super initialize.
	type := #any

]

{ #category : #testing }
ReporterScriptBlockMorph >> isBooleanFunction [
	^ isBoolean
]

{ #category : #testing }
ReporterScriptBlockMorph >> isFunction [
	^ true
]

{ #category : #'argument slot behavior' }
ReporterScriptBlockMorph >> nestedBlock [
	^self args first
]

{ #category : #accessing }
ReporterScriptBlockMorph >> optimized [
	| newBlock reportBlock sel body a rcv |
	rcv := self receiver.
	rcv ifNil: [ rcv := ScriptablePhratchMorph new ].
	sel := (#(#function #autoBlock) includes: selector)
		ifTrue: [ #procedure ]
		ifFalse: [ #procedureWithArgs ].
	newBlock := rcv
		blockFromSpec: (rcv wholeBlockSpecForSelector: sel)
		color: (ScriptablePhratchMorph blockColorFor: 'operators').
	newBlock isAtomic: (isAtomic or: [ self isOSlotMorph ]).
	reportBlock := rcv
		blockFromSpec: (rcv wholeBlockSpecForSelector: #doAnswer)
		color: (ScriptablePhratchMorph blockColorFor: 'control').
	body := self body.
	body ifNotNil: [ reportBlock replaceArgMorph: reportBlock argMorphs first by: body ].
	2 to: argMorphs size - 1 do: [ :i | newBlock addItem ].
	2 to: argMorphs size do: [ :i | 
		a := (argMorphs at: i) fullCopy.
		newBlock replaceArgMorph: (newBlock argMorphs at: i - 1) by: a ].
	newBlock attachBlock: reportBlock.
	newBlock parameters: parameters.
	newBlock variables: variables.
	newBlock fixInitialFrame.
	^ newBlock
]

{ #category : #private }
ReporterScriptBlockMorph >> privateBody [
	"no copy"
	(argMorphs first isBlockMorph)
		ifTrue: [^ argMorphs first].
	^ nil
]

{ #category : #deleting }
ReporterScriptBlockMorph >> removeItem [
	argMorphs size > self minArgs
		ifFalse: [ ^ self ].
	self removeLastArg.
	self commandSpec: (commandSpec copyFrom: 1 to: commandSpec size - 3)
]
