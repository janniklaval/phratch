Class {
	#name : #LambdaBlockMorph,
	#superclass : #MultiArgReporterBlockMorph,
	#instVars : [
		'parameters',
		'variables',
		'initialFrame',
		'type',
		'declarations',
		'isAtomic'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #adding }
LambdaBlockMorph >> addVariable [

	| ans |
	ans := StringDialog askWithCancel: 'New Block Variable Name' initialAnswer: ''.
	ans isEmpty ifTrue: [^false].
	(self allVarNames includes: ans) ifTrue: [
		DialogBoxMorph warn: 'This block variable name already exists'.
		^false ].
	variables add: ans.
	initialFrame add: ans.
	self rightButtonMenu
]

{ #category : #variables }
LambdaBlockMorph >> allVarNames [
	^ (parameters, variables) asSortedCollection
]

{ #category : #accessing }
LambdaBlockMorph >> bind: varName to: varFrame as: alias [

	"for externalized local variables"

	self privateBody allMorphsDo: [:m |
		(m isKindOf: VariableBlockMorph) ifTrue: [
			m variable = varName ifTrue: [
				m
					receiver: varFrame;
					alias: alias ]]]
]

{ #category : #accessing }
LambdaBlockMorph >> body [
	self subclassResponsibility
]

{ #category : #byob }
LambdaBlockMorph >> checkBoxLabelled: aString marked: aBool width: anInt [
	"answer a form consisting of a checkbox and a label - used for the EDIT menu in BYOB"

	| box label pic line cnts |
	pic := aBool
		ifTrue: [ PhratchFrameMorph skinAt: #watcherButtonPressed ]
		ifFalse: [ PhratchFrameMorph skinAt: #watcherButton ].
	box := ImageMorph new form: pic.
	cnts := ' ' , aString localized.
	label := StringMorph contents: cnts font: PhratchFrameMorph standardMenuFont.
	line := Morph new color: Color transparent.
	line height: (box height max: label height).
	line width: (box width + label width max: anInt).
	box left: line left.
	box top: line top + ((line height - box height) // 2).
	label left: box right.
	label top: line top + ((line height - label height) // 2).
	line addMorph: box.
	line addMorph: label.
	^ line imageForm
]

{ #category : #accessing }
LambdaBlockMorph >> declarations [
	^declarations
]

{ #category : #accessing }
LambdaBlockMorph >> declarations: aDictionary [
	declarations := aDictionary
]

{ #category : #visualisation }
LambdaBlockMorph >> displayBlock [

	| top b ans|

	b := self optimized body.
	b ifNil: [^self fullCopy].

	parameters isEmpty ifTrue: [ 
		self optimized sequence first selector = #doAnswer ifTrue: [
			ans := self optimized sequence first argMorphs first fullCopy.
			(ans isKindOf: ArgMorph) ifTrue: [^self].
			(ans isKindOf: CommandScriptBlockMorph) ifFalse: [
				ans allMorphs do: [:m | (m isKindOf: BlockMorph) ifTrue: [
						m isContrasted: false; addLabel]].
					^ ans]].
			^b].

	top := self parameterTopBlock.
	top attachBlock: b.
	^top
]

{ #category : #visualisation }
LambdaBlockMorph >> displayForm [

	| block |

	block := self displayBlock.
	block allMorphs do: [:m |
		(m isKindOf: BlockMorph) ifTrue: [m fixBlockLayout ]].
	^ block imageForm withOutlineColor: PhratchFrameMorph scriptsPaneColor width: 4
]

{ #category : #evaluation }
LambdaBlockMorph >> evaluate [
	^self optimized
]

{ #category : #evaluation }
LambdaBlockMorph >> evaluateWithArgs: rawArgs [

	^self optimized
]

{ #category : #private }
LambdaBlockMorph >> fixInitialFrame [
	initialFrame := VariableFrame forNames: self allVarNames.
	self allMorphsDo: [:m |
		((m isKindOf: VariableBlockMorph) | (m isKindOf: SetterBlockMorph)
		and: [m isSpecialForm & (initialFrame scope includes: m variable)]) ifTrue: [
			m receiver: initialFrame ]]
]

{ #category : #initialization }
LambdaBlockMorph >> initialize [
	super initialize.
	type := #none.
	parameters := OrderedCollection new.
	variables := OrderedCollection new.
	declarations := Dictionary new.
	isAtomic := false.
	initialFrame := VariableFrame new
]

{ #category : #accessing }
LambdaBlockMorph >> isAtomic [
	^ isAtomic
]

{ #category : #accessing }
LambdaBlockMorph >> isAtomic: aBoolean [
	isAtomic := aBoolean
]

{ #category : #testing }
LambdaBlockMorph >> isBooleanFunction [
	self subclassResponsibility
]

{ #category : #testing }
LambdaBlockMorph >> isFunction [
	self subclassResponsibility
]

{ #category : #byob }
LambdaBlockMorph >> isLambdaForm [
	^true
]

{ #category : #'parts bin' }
LambdaBlockMorph >> isPartsBin [
	^true
]

{ #category : #visualisation }
LambdaBlockMorph >> morphToShow [
"	^ self body ifNil: [self]"

	^ImageMorph new form:  self displayForm
]

{ #category : #'instance-creation' }
LambdaBlockMorph >> newChangeVarBlock: varName [

	| block |
	block := SetterBlockMorph new
		initChangerForVar: varName;
		isSpecialForm: true;
		receiver: initialFrame;	
		selector: #changeBlockVar:by:;
		yourself ";
		color: (ScriptablePhratchMorph blockColorFor: 'variables')".
	block expressionArg stringExpression: '0'.
	^ block

]

{ #category : #'instance-creation' }
LambdaBlockMorph >> newSetVarBlock: varName [

	| block |
	block := SetterBlockMorph new
		initSetterForVar: varName;
		isSpecialForm: true;
		receiver: initialFrame;	
		selector: #setBlockVar:to:;
		yourself  ";
		color: (ScriptablePhratchMorph blockColorFor: 'variables')".
	block expressionArg stringExpression: '0'.
	^ block

]

{ #category : #'instance-creation' }
LambdaBlockMorph >> newVarBlock: varName [

	^ VariableBlockMorph new
		isSpecialForm: true;
		receiver: initialFrame;	
		selector: #getBlockVar:;
"		color: (ScriptablePhratchMorph blockColorFor: 'variables');"
		commandSpec: varName;
		yourself

]

{ #category : #accessing }
LambdaBlockMorph >> optimized [
	^ (self fullCopy)
		fixInitialFrame
]

{ #category : #accessing }
LambdaBlockMorph >> parameterNames [
	^ parameters
]

{ #category : #visualisation }
LambdaBlockMorph >> parameterTopBlock [
	"private - for display purposes only"

	| block arg |
	block := CommandBlockMorph new.
	block color: Color lightGray.
	block commandSpec: 'input names:' localized.

	parameters do: [:p |
		arg := ReporterBlockMorph new.
		arg color: VariableFrame variableBlockColor.
		arg commandSpec: p.
		block addArg: arg].

	^ block



]

{ #category : #accessing }
LambdaBlockMorph >> parameters [
	^ parameters
]

{ #category : #accessing }
LambdaBlockMorph >> parameters: anOrderedCollection [
	 parameters := anOrderedCollection
]

{ #category : #private }
LambdaBlockMorph >> privateBody [
	self subclassResponsibility
]

{ #category : #deleting }
LambdaBlockMorph >> removeLastArg [

	| idx |
	idx := argMorphs size.
	(argMorphs at: idx) delete.
	argMorphs at: idx put: nil.
	initialFrame remove: parameters last.
	parameters removeLast.

]

{ #category : #'events-processing' }
LambdaBlockMorph >> renameParm: old to: new [

	(self allVarNames includes: new) ifTrue: [
		DialogBoxMorph warn: 'This block variable name already exists'.
		^false ].
	initialFrame renameVar: old to: new.
	parameters at: (parameters indexOf: old) put: new.
	^true
]

{ #category : #byob }
LambdaBlockMorph >> rightButtonMenu [

	| menu choice block vn atomic |
	"first create the widest label"

	atomic := self checkBoxLabelled: 'atomic'
				marked: self isAtomic
				width: 0.

	menu := MenuMorphNG new defaultTarget: self.
	menu add: 'help' value: #presentHelpScreen.
	menu addLine.
	menu add: 'duplicate' value: #duplicate.
	(self owner isKindOf: BlockMorph) ifFalse: [  "can't yet delete a blocks inside a script"
		menu add: 'delete' value: #delete].
	menu addLine.

	menu addIcon: atomic
			tooltip: 'execute as single block'
			value: #toggleAtomicity.


"
	menu add: (isAtomic ifTrue: ['atomic -> interleafed'] ifFalse: ['interleafed -> atomic']) action: #toggleAtomicity.
"

	"menu add: 'make a block variable' action: #addVariable.
	variables isEmpty ifFalse: [
		menu add: 'delete a bock variable' action: #removeVariable.
		menu addLine.
		variables asSortedCollection do: [:vName |
			menu addIcon: (self newVarBlock: vName) imageForm toolTip: nil action: {vName} ]].
	initialFrame varNamesMenu isEmpty ifFalse: [
		menu addLine.
		
		menu addIcon: (self newSetVarBlock: vn) imageForm toolTip: nil action: #setVar.
		menu addIcon: (self newChangeVarBlock: vn) imageForm toolTip: nil action: #changeVar ]."
initialFrame varNamesMenu size = 0 ifFalse: [
vn := initialFrame varNamesMenu first.
	(choice := menu localize; popUpInWorld;
		yourself) selectedValue ifNil: [^ self].
	(choice isKindOf: Array) ifTrue: [
		block := self newVarBlock: choice first.
		World activeHand attachMorph: block.
		block center: World activeHand position.
		^ self ].
	#setVar = choice ifTrue: [
		block := self newSetVarBlock: vn.
		World activeHand attachMorph: block.
		block center: World activeHand position.
		^ self ].
	#changeVar = choice ifTrue: [
		block := self newChangeVarBlock: vn.
		World activeHand attachMorph: block.
		block center: World activeHand position.
		^ self ].
	self perform: choice.
]
]

{ #category : #'dropping/grabbing' }
LambdaBlockMorph >> rootForGrabOf: aMorph [

	| root |
	root := aMorph.
	[root = self] whileFalse: [
		root owner == self ifTrue: [
			self isPartsBin ifTrue: [
				root = self nestedBlock
					ifTrue: [^root]
					ifFalse: [^ root fullCopy]].
			self dragNDropEnabled ifTrue: [^ root]].
		root := root owner].

	^ super rootForGrabOf: aMorph

]

{ #category : #accessing }
LambdaBlockMorph >> sequence [
	^self body blockSequence
]

{ #category : #other }
LambdaBlockMorph >> showValue [

	| tooltip w worldBounds |

	tooltip := (PhratchReporterToolTipMorph string: self morphToShow imageForm for: self)
		left: self right;
		bottom: self top;
		yourself.
	PhratchTranslator isRTL ifTrue: [tooltip right: self left].

	w := self world.
	w addMorphFront: tooltip.
	((worldBounds := w bounds) containsRect: tooltip bounds) ifFalse:
		[tooltip bounds: (tooltip bounds translatedToBeWithin: worldBounds)].

	self setProperty: #toolTip toValue: tooltip.
	tooltip initialCursorPoint: Sensor cursorPoint.
	tooltip startStepping.

]

{ #category : #accessing }
LambdaBlockMorph >> toggleAtomicity [

	isAtomic := isAtomic not
]

{ #category : #accessing }
LambdaBlockMorph >> type [
	"currently BYOB supports the following first class types:

    #none		- a puzzle shaped command block
    #any		- a non-typed round reporter block (can be anything)
    #string		- a round reporter block that answers a string
    #number	- a round reporter block that answers a number
    #list			- a round reporter block that answers a number
    #boolean	- a hexagonal reporter block that answers a boolean
    #command	- a round reporter block that answers a procedure (a command block)
    #reporter	- a round reporter block that answers a function (a reporter block)

"

	^ type
]

{ #category : #accessing }
LambdaBlockMorph >> type: aSymbol [

	"currently BYOB supports the following first class types:

    #none		- a puzzle shaped command block
    #any		- a non-typed round reporter block (can be anything)
    #string		- a round reporter block that answers a string
    #number	- a round reporter block that answers a number
    #list			- a round reporter block that answers a number
    #boolean	- a hexagonal reporter block that answers a boolean
    #command	- a round reporter block that answers a procedure (a command block)
    #reporter	- a round reporter block that answers a function (a reporter block)
    #template	- a sunken variable blob that represents an externalized block variable
"

	type := aSymbol
]

{ #category : #private }
LambdaBlockMorph >> updateReferencesUsing: aDictionary [

	super updateReferencesUsing: aDictionary.
	parameters := parameters collect:
		[:old | aDictionary at: old ifAbsent: [old]].
	variables := variables collect:
		[:old | aDictionary at: old ifAbsent: [old]].
	declarations := declarations collect:
		[:old | aDictionary at: old ifAbsent: [old]].

]

{ #category : #accessing }
LambdaBlockMorph >> variables [
	^ variables
]

{ #category : #accessing }
LambdaBlockMorph >> variables: anOrderedCollection [
	 variables := anOrderedCollection
]

{ #category : #private }
LambdaBlockMorph >> veryDeepFixupWith: deepCopier [
	"If fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals."

	super veryDeepFixupWith: deepCopier.
	parameters := parameters collect: [:m | deepCopier references at: m ifAbsent: [m]].
	variables := variables collect: [:m | deepCopier references at: m ifAbsent: [m]].
	declarations := declarations collect: [:m | deepCopier references at: m ifAbsent: [m]]

]

{ #category : #private }
LambdaBlockMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

	super veryDeepInner: deepCopier.
	initialFrame := initialFrame veryDeepCopyWith: deepCopier.
	type := type veryDeepCopyWith: deepCopier.
	isAtomic := isAtomic veryDeepCopyWith: deepCopier.
]
