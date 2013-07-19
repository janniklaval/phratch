Class {
	#name : #CustomBlockDefinition,
	#superclass : #Object,
	#instVars : [
		'userSpec',
		'blockVars',
		'body',
		'isReporter',
		'isAtomic',
		'isBoolean',
		'answer',
		'category',
		'type',
		'declarations',
		'defaults',
		'isGlobal'
	],
	#category : #'Phratch-BYOB'
}

{ #category : #'as yet unclassified' }
CustomBlockDefinition class >> idFromSpec: aUserSpecOrCommandSpec [

	|cmd out|
	cmd := PhratchServer new parse: aUserSpecOrCommandSpec.
	out := WriteStream on: String new.
	cmd do: [:each|
		(each asString beginsWith: '$')
			ifTrue: [out nextPutAll: '$String$' ]
			ifFalse: [out nextPutAll: each asString].
		out space ].
	^out contents withoutTrailingBlanks
]

{ #category : #accessing }
CustomBlockDefinition >> addBlockVariable [

	| ans |
	ans := StringDialog askWithCancel: 'New Block Variable Name' initialAnswer: ''.
	ans isEmpty ifTrue: [^false].
	(self allVarNames includes: ans) ifTrue: [
		DialogBoxMorph warn: 'This block variable name already exists'.
		^false ].
	blockVars add: ans.
	^true
]

{ #category : #accessing }
CustomBlockDefinition >> allBlocks [
	| all |

	body
		ifNil: [ all := OrderedCollection new]
		ifNotNil: [
			all := body allMorphs select: [:m|
				m isKindOf: BlockMorph ]].

	(answer isKindOf: BlockMorph) ifTrue: [
		all := all, answer allMorphs select: [:m |
		m isKindOf: BlockMorph ]].

	^all
]

{ #category : #accessing }
CustomBlockDefinition >> allVarNames [
	^(self varNames, self parameterNames) asSortedCollection
]

{ #category : #accessing }
CustomBlockDefinition >> answer [
	(answer respondsTo: #fullCopy)
		ifTrue: [^answer fullCopy].
	^answer
]

{ #category : #accessing }
CustomBlockDefinition >> answer: aBlockOrNumber [
	answer := aBlockOrNumber
]

{ #category : #accessing }
CustomBlockDefinition >> answerBlock [
	| spec block |

	#boolean = type
		ifTrue: [spec := 'answer $Boolean$']
		ifFalse: [spec := 'answer $String$'].
	
	block := CommandBlockMorph new
		commandSpec: spec;
		isSpecialForm: true;
		selector: #doAnswer.

	(answer isKindOf: ReporterBlockMorph) ifTrue: [
		^block replaceArgMorph: (block argumentAt: 1) by: answer ].

	#boolean = type ifTrue: [^block].

	answer ifNil: [answer := ''].

	(answer isKindOf: Array)
		ifTrue: [ block argMorphs first stringExpression: '']
		ifFalse: [block argMorphs first stringExpression: answer ].
	^block
]

{ #category : #accessing }
CustomBlockDefinition >> blockColor [
	#none = category
		ifTrue: [^ Color lightGray]
		ifFalse: [^ ScriptablePhratchMorph blockColorFor: category]
]

{ #category : #accessing }
CustomBlockDefinition >> blockVars: aCollection [

	blockVars := aCollection asSet
]

{ #category : #accessing }
CustomBlockDefinition >> body [
	^body
]

{ #category : #accessing }
CustomBlockDefinition >> body: aBlock [
	body := aBlock.
]

{ #category : #accessing }
CustomBlockDefinition >> category [

	"categories can be:

		#none	- a gray block in the variables palette (BYOB legacy)
		#motion
		#looks
		#sound
		#pen
		#control
		#sensing
		#operators
		#variables
	"

	^ category
]

{ #category : #accessing }
CustomBlockDefinition >> category: aSymbol [

	"categories can be:

		#none	- a gray block in the variables palette (BYOB legacy)
		#motion
		#looks
		#sound
		#pen
		#control
		#sensing
		#operators
		#variables
	"

	category := aSymbol
]

{ #category : #accessing }
CustomBlockDefinition >> commandSpec [

	^self commandSpecFrom: userSpec
]

{ #category : #accessing }
CustomBlockDefinition >> commandSpecFrom: aUserSpec [
	|cmd out pname ptype|
	cmd := PhratchServer new parse: aUserSpec.
	out := WriteStream on: String new. 
	cmd do: [:each|
		(each asString beginsWith: '$')
			ifTrue: [
				pname := each asString allButFirst allButLast.
				ptype := declarations at: pname ifAbsent: [#any].
				out nextPutAll: (self specFor: ptype) ]
			ifFalse: [out nextPutAll: each asString].
		out space ].
	^out contents withoutTrailingBlanks
]

{ #category : #accessing }
CustomBlockDefinition >> declarations [
	^declarations
]

{ #category : #accessing }
CustomBlockDefinition >> declarations: aDictionary [
	declarations := aDictionary
]

{ #category : #private }
CustomBlockDefinition >> deduceType [
	"private - set my return type from the BYOB deprecated legacy attributes #isReporter and #isBoolean.
	use this when reading an old block from file"

	isReporter ifFalse: [ ^ type := #none ].
	isBoolean ifTrue: [ ^ type := #boolean ].
	^ type := #any
]

{ #category : #accessing }
CustomBlockDefinition >> defaultOf: parameterName [

	defaults ifNil: [defaults := Dictionary new ].
	^ defaults at: parameterName ifAbsent: ['']
]

{ #category : #accessing }
CustomBlockDefinition >> defaults [
	defaults ifNil: [defaults := Dictionary new].
	^defaults
]

{ #category : #accessing }
CustomBlockDefinition >> defaults: aDictionary [
	defaults := aDictionary
]

{ #category : #accessing }
CustomBlockDefinition >> deleteBlockVariable [
	| ans |
	ans := MenuMorph new defaultTarget: self.
	self varNames do:[:aVarName |
		ans add: aVarName
			target: blockVars 
			selector: #remove:
			argument: aVarName
	].
	ans localize; popUpInWorld.
]

{ #category : #'object i/o' }
CustomBlockDefinition >> fieldsVersion [

	^ 4

]

{ #category : #private }
CustomBlockDefinition >> fixBlockVarReporters [


	body ifNotNil: [
		body allMorphs do: [:m|
			((m isKindOf: VariableBlockMorph) | (m isKindOf: SetterBlockMorph) 
				and: [m isSpecialForm]) ifTrue: [
					m receiver: self ]]].
	answer ifNotNil: [ (answer isKindOf: ReporterBlockMorph)
		ifTrue: [answer allMorphs do: [:m|
			((m isKindOf: VariableBlockMorph) | (m isKindOf: SetterBlockMorph) 
				and: [m isSpecialForm]) ifTrue: [
					m receiver: self ]]]].


]

{ #category : #private }
CustomBlockDefinition >> getVar: vName [
	^0
]

{ #category : #accessing }
CustomBlockDefinition >> id [
	^self class idFromSpec: userSpec
]

{ #category : #'object i/o' }
CustomBlockDefinition >> initFieldsFrom: anObjStream version: classVersion [

	self initFieldsNamed: #(
		userSpec
		blockVars
		isAtomic
		isReporter
		isBoolean
		body
		answer
	) from: anObjStream.

	classVersion = 1 ifTrue: [
		^ self deduceType ].

	"fields added in version 2:"
	self initFieldsNamed: #(
		type
		category
		declarations
	) from: anObjStream.

	"fields added in version 3:"
	self initFieldsNamed: #(
		defaults
	) from: anObjStream.

	"fields added in version 4:"
	self initFieldsNamed: #(
		isGlobal
	) from: anObjStream.

]

{ #category : #initializing }
CustomBlockDefinition >> initialize [
	super initialize.
	category := #none.	"this will be a gray block in the variables palette (jens)"
	type := #none.
	declarations := Dictionary new.
	defaults := Dictionary new.
	isAtomic := true.
	isReporter := false.
	isBoolean := false.
	blockVars := Set new.
	isGlobal := true
]

{ #category : #accessing }
CustomBlockDefinition >> isAtomic [
	^isAtomic
]

{ #category : #accessing }
CustomBlockDefinition >> isAtomic: aBoolean [
	isAtomic := aBoolean.
]

{ #category : #deprecated }
CustomBlockDefinition >> isBoolean [
	"deprecated, kept for BYOB legacy support (jens)"

	^isBoolean
]

{ #category : #deprecated }
CustomBlockDefinition >> isBoolean: aBoolean [
	"deprecated, kept for BYOB legacy support"

	isBoolean := aBoolean
]

{ #category : #accessing }
CustomBlockDefinition >> isGlobal [
	^isGlobal ifNil: [isGlobal := false]
]

{ #category : #accessing }
CustomBlockDefinition >> isGlobal: bool [
	isGlobal := bool
]

{ #category : #deprecated }
CustomBlockDefinition >> isReporter [
	"deprecated, kept for BYOB legacy support"

	^isReporter
]

{ #category : #deprecated }
CustomBlockDefinition >> isReporter: aBoolean [
	"deprecated, kept for BYOB legacy support"

	isReporter := aBoolean
]

{ #category : #migrating }
CustomBlockDefinition >> migrateBlockVars [
	"turn my block vars into a VariableDeclarationBlockMorph"

	| dec vars vn spec blob rest |
	blockVars size > 0 ifFalse: [^self].
	dec := VariableDeclarationBlockMorph new
			color: Color gray;
			isSpecialForm: true;
			minArgs: 1;
			selector: #doDeclareVariables.

	vars := self varNames.
		spec := 'script variables' localized.
	vars size timesRepeat: [ spec := spec, ' $String$' ].
	dec commandSpec: spec.
	1 to: vars size do: [:i |
		vn := vars at: i.
		blob := VariableBlockMorph new 
				isSpecialForm: true;
				commandSpec: vn  ";
				color: (ScriptablePhratchMorph blockColorFor: 'variables')".
		dec replaceArgMorph: (dec argMorphs at: i) by: blob.
		blockVars remove: vn ].

	rest := body.
	body := dec.
	rest ifNotNil: [
		body nextBlock: rest ]
]

{ #category : #private }
CustomBlockDefinition >> ownerOrYourselfThatIsA: aClassName [
	^nil
]

{ #category : #private }
CustomBlockDefinition >> ownerThatIsA: aClassName [
	^nil
]

{ #category : #accessing }
CustomBlockDefinition >> parameterNames [

	^self parameterNamesInSpec: userSpec
]

{ #category : #accessing }
CustomBlockDefinition >> parameterNamesInSpec: aString [

	| cmd out |
	cmd := PhratchServer new parse: aString.
	out := OrderedCollection new.
	cmd do: [:each|
		(each asString beginsWith: '$')
			ifTrue: [out add: (each asString allButFirst allButLast)]].
	^out asArray
]

{ #category : #accessing }
CustomBlockDefinition >> specFor: typeSym [
	 | specs |
	specs := Dictionary new.
	specs
		at: #command put: '$CSlot$';
		at: #commandList put: '$MACommand$';
		at: #reporter put: '$OSReporter$';
		at: #reporterList put: '$MAReporter$';

"+++++++ deprecated experimental slots    -jens +++++++++++++

		at: #reporterSlot put: '$MAUnEBool$';
		at: #reporterSlotList put: '$UnEBool$';
		at: #typeInReporter put: '$UnEExp$';
		at: #typeInReporterList put: '$MAUneval$';

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

		at: #unevaluated put: '$UnEExp$';
		at: #unevaluatedList put: '$MAUneval$';
		at: #unevaluatedBoolean put: '$UnEBool$';
		at: #unevaluatedBooleanList put: '$MAUnEBool$';

		at: #predicate put: '$OSBoolean$';
		at: #predicateList put: '$MAPredicate$';
		at: #list put: '$SAList$';
		at: #listList put: '$MAList$';
		at: #text put: '$Text$';
		at: #textList put: '$MAText$';
		at: #any put: '$String$';
		at: #anyList put:  '$MAAny$';
		at: #boolean put: '$Boolean$';
		at: #booleanList put: '$MABoolean$';
		at: #number put: '$Number$';
		at: #numberList put: '$MANumber$';
		at: #template put: '$SpecialVar$';
		at: #loop put: '$CArgSlot$';
		at: #loopList put: '$Loop$';

		at: #object put: '$SAObjS$';
		at: #objectList put: '$MAObjS$'.

	^specs at: typeSym ifAbsent: ['$String$']
]

{ #category : #'object i/o' }
CustomBlockDefinition >> storeFieldsOn: anObjStream [

	self storeFieldsNamed: #(
		userSpec
		blockVars
		isAtomic
		isReporter
		isBoolean
		body
		answer
		type
		category
		declarations
		defaults
		isGlobal
	) on: anObjStream.

]

{ #category : #accessing }
CustomBlockDefinition >> templates [

	"answer a Dictionary of externalized local variables"

	| templates parms |
	templates := Dictionary new.
	parms := self parameterNames.
	1 to: parms size do: [:i |
		#template = (self typeOfParameterIndex: i) ifTrue: [
			templates at: i put: (parms at: i)]].
	templates keys size > 0 ifFalse: [
		^nil].
	^templates

]

{ #category : #accessing }
CustomBlockDefinition >> toggleAtomicity [
	self isAtomic: isAtomic not
]

{ #category : #accessing }
CustomBlockDefinition >> type [
	"currently BYOB supports the following first class types:

    #none		- a puzzle shaped command block
    #any		- a non-typed round reporter block (can be anything)
    #string		- a round reporter block that answers a string
    #number	- a round reporter block that answers a number
    #list			- a round reporter block that answers a number
    #boolean	- a hexagonal reporter block that answers a boolean
    #command	- a round reporter block that answers a procedure (a command block)
    #reporter	- a round reporter block that answers a function (a reporter block)
    #predicate	- a (round?) reporter reporting boolean function

"

	^ type
]

{ #category : #accessing }
CustomBlockDefinition >> type: aSymbol [

	"currently BYOB supports the following first class types:

    #none		- a puzzle shaped command block
    #any		- a non-typed round reporter block (can be anything)
    #string		- a round reporter block that answers a string
    #number	- a round reporter block that answers a number
    #list			- a round reporter block that answers a number
    #boolean	- a hexagonal reporter block that answers a boolean
    #command	- a round reporter block that answers a procedure (a command block)
    #reporter	- a round reporter block that answers a function (a reporter block)
    #predicate	- a hexagonal reporter block that answers a reporter of a boolean 
    #template	- a sunken variable blob that represents an externalized block variable
"

	type := aSymbol
]

{ #category : #accessing }
CustomBlockDefinition >> typeOf: parameterName [

	^ declarations at: parameterName ifAbsent: [#any]
]

{ #category : #accessing }
CustomBlockDefinition >> typeOfParameterIndex: parmIdx [

	^ declarations at: (self parameterNames at: parmIdx ifAbsent: [^ #any])
		ifAbsent: [#any]
]

{ #category : #accessing }
CustomBlockDefinition >> userSpec [
	^userSpec
]

{ #category : #accessing }
CustomBlockDefinition >> userSpec: aString [

	userSpec := aString.

"
--- this code used to keep deleted parameters around as block vars that could be
----reused -deprecated now (2010-09-15) -jens

	userSpec ifNotNil: [
		blockVars addAll: (self parameterNamesInSpec: userSpec)].
	userSpec := aString.
	(self parameterNamesInSpec: userSpec) do: [:var |
		blockVars remove: var ifAbsent: []]
"
]

{ #category : #accessing }
CustomBlockDefinition >> varNames [

	^blockVars asSortedCollection
]

{ #category : #accessing }
CustomBlockDefinition >> varNamesMenu [
	^self allVarNames asArray
]
