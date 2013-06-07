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
	#category : #'Phratch-BYOB'
}

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> allVarNames [
	^ (parameters, variables) asSortedCollection
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> bind: varName to: varFrame as: alias [

	"for externalized local variables"

	self privateBody allMorphsDo: [:m |
		(m isKindOf: VariableBlockMorph) ifTrue: [
			m variable = varName ifTrue: [
				m
					receiver: varFrame;
					alias: alias ]]]
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> body [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> checkBoxLabelled: aString marked: aBool width: anInt [
	"answer a form consisting of a checkbox and a label - used for the EDIT menu in BYOB"

	| box label pic line cnts |
	aBool
		ifTrue: [pic := PhratchFrameMorph skinAt: #watcherButtonPressed]
		ifFalse: [pic := PhratchFrameMorph skinAt: #watcherButton].
	box := ImageMorph new form: pic. 
	
	PhratchTranslator useSqueakRendering
		ifTrue: [cnts := ' ', aString localized asMacRoman]
		ifFalse: [cnts := ' ' asUTF8, aString localized].

	label := StringMorph contents: cnts font: PhratchFrameMorph standardMenuFont.
	line := Morph new color: Color transparent.
	line height: (box height max: label height).
	line width: (box width + label width max: anInt).
	box left: line left.
	box top: line top + (line height - box height // 2).
	label left: box right.
	label top: line top + (line height - label height // 2).
	line addMorph: box.
	line addMorph: label.
	^ line imageForm


]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> declarations [
	^declarations
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> evaluate [
	^self optimized
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> evaluateWithArgs: rawArgs [

	^self optimized
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> fixInitialFrame [
	initialFrame := VariableFrame forNames: self allVarNames.
	self allMorphsDo: [:m |
		((m isKindOf: VariableBlockMorph) | (m isKindOf: SetterBlockMorph)
		and: [m isSpecialForm & (initialFrame scope includes: m variable)]) ifTrue: [
			m receiver: initialFrame ]]
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> initialFrame: aVariableFrame [
	initialFrame := aVariableFrame
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> initialize [
	super initialize.
	type := #none.
	parameters := OrderedCollection new.
	variables := OrderedCollection new.
	declarations := Dictionary new.
	isAtomic := false.
	initialFrame := VariableFrame new
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> isAtomic [
	^ isAtomic
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> isAtomic: aBoolean [
	isAtomic := aBoolean
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> isBooleanFunction [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> isFunction [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> isLambdaForm [
	^true
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> isPartsBin [
	^true
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> morphToShow [
"	^ self body ifNil: [self]"

	^ImageMorph new form:  self displayForm
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> newChangeVarBlock: varName [

	| block |
	block := SetterBlockMorph new
		initChangerForVar: varName;
		isSpecialForm: true;
		receiver: initialFrame;	
		selector: #changeBlockVar:by: ";
		color: (ScriptablePhratchMorph blockColorFor: 'variables')".
	block expressionArg stringExpression: '0'.
	^ block

]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> newSetVarBlock: varName [

	| block |
	block := SetterBlockMorph new
		initSetterForVar: varName;
		isSpecialForm: true;
		receiver: initialFrame;	
		selector: #setBlockVar:to:  ";
		color: (ScriptablePhratchMorph blockColorFor: 'variables')".
	block expressionArg stringExpression: '0'.
	^ block

]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> newVarBlock: varName [

	^ VariableBlockMorph new
		isSpecialForm: true;
		receiver: initialFrame;	
		selector: #getBlockVar:;
"		color: (ScriptablePhratchMorph blockColorFor: 'variables');"
		commandSpec: varName

]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> optimized [
	^ (self fullCopy)
		fixInitialFrame
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> parameters [
	^ parameters
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> parameters: anOrderedCollection [
	 parameters := anOrderedCollection
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> privateBody [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> removeLastArg [

	| idx |
	idx := argMorphs size.
	(argMorphs at: idx) delete.
	argMorphs at: idx put: nil.
	initialFrame remove: parameters last.
	parameters removeLast.

]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> removeVariable [
	| menu |
	menu := MenuMorph new defaultTarget: self.
	variables asSortedCollection do:[:aVarName |
		menu add: aVarName
			target: self 
			selector: #removeVariable:
			argument: aVarName.	
	].
	menu localize; popUpInWorld.
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> removeVariable: aVariable [
	variables remove: aVariable.
	initialFrame remove: aVariable.
	variables isEmpty ifFalse: [
		self rightButtonMenu]

]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> renameParm: old to: new [

	(self allVarNames includes: new) ifTrue: [
		DialogBoxMorph warn: 'This block variable name already exists'.
		^false ].
	initialFrame renameVar: old to: new.
	parameters at: (parameters indexOf: old) put: new.
	^true
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> rightButtonMenu [

	| menu choice block vn atomic |
self haltOnce.
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

vn := initialFrame varNamesMenu first.
	(choice := menu localize; popUpInWorld) selectedValue ifNil: [^ self].
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

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> sequence [
	^self body blockSequence
]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> showValue [

	| tooltip w worldBounds |

	tooltip := (PhratchReporterToolTipMorph string: self morphToShow imageForm for: self)
		left: self right;
		bottom: self top.
	PhratchTranslator isRTL ifTrue: [tooltip right: self left].

	w := self world.
	w addMorphFront: tooltip.
	((worldBounds := w bounds) containsRect: tooltip bounds) ifFalse:
		[tooltip bounds: (tooltip bounds translatedToBeWithin: worldBounds)].

	self setProperty: #toolTip toValue: tooltip.
	tooltip initialCursorPoint: Sensor cursorPoint.
	tooltip startStepping.

]

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> toggleAtomicity [

	isAtomic := isAtomic not
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
LambdaBlockMorph >> variables [
	^ variables
]

{ #category : #'as yet unclassified' }
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
