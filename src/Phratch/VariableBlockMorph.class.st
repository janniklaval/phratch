"
I am a block that reports the value of either a built-in or a user variable. When dropped into the workspace, I turn into a WatcherMorph for that variable with an optional slider.

"
Class {
	#name : #VariableBlockMorph,
	#superclass : #ReporterBlockMorph,
	#instVars : [
		'labelFragment',
		'alias'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #'byob lambdas' }
VariableBlockMorph >> aboutToBeGrabbedBy: aHandMorph [

	super aboutToBeGrabbedBy: aHandMorph.
	self addLabel
]

{ #category : #'byob lambdas' }
VariableBlockMorph >> addLabel [
	"Add a label for my command and arguments. 
	This is the method that really creates the whole block."
	"Details: This overrides the superclass method to allow 
	using percent character in variable/list names"

	| dflt |

	commandSpec ifNil: [^ self].
	self removeAllMorphs.

	self isPrototypeTemplate
		ifFalse: [
			self addMorphBack: (self labelMorphFor: commandSpec).
			^ self].

	self addMorphBack: (self labelMorphFor: commandSpec).

	dflt := labelFragment default asString.

	labelFragment isMultipleInput ifTrue: [
		self addMorphBack: (self labelMorphFor: '...') ].

	labelFragment isTemplate ifTrue: [
		self addMorphBack: ((StringMorph contents: '^') color: self labelColor) ].

	labelFragment isLoop ifTrue: [
		self addMorphBack: ((StringMorph contents: '[') color: self labelColor) ].

	labelFragment isUnevaluated ifTrue: [
		self addMorphBack: ((StringMorph contents: '*') color: self labelColor) ].

	(' ' asUTF8 = dflt or: [dflt isEmpty]) ifFalse: [
		self addMorphBack: (self labelMorphFor: '=', labelFragment default asString)].


]

{ #category : #'byob lambdas' }
VariableBlockMorph >> alias: aString [

	alias := aString
]

{ #category : #private }
VariableBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments.

	variable accessor blocks in BYOB come in two flavors: Those onces statically accessing sprite or stage variables, and those ones dynamically bound to other environments. The latter ones are marked as special forms.  To stay compatible with Scratch (which doesn't have temporaries or block vars) the isSpecialForm flag is not put into the file format, instead the distinction is made via an explanatory symbol:

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
				at: 1 put: #byob;
				at: 2 put: self rcvr;			"not really needed for this block. JM"
				at: 3 put: #readBlockVariable;
				at: 4 put: commandSpec;
				at: 5 put: rcvr ]
		ifFalse: [

			self evaluate. "ensure desparate re-binding of orphaned and rescoped variable getters"

			blockTuple := Array new: 4.
			blockTuple
				at: 1 put: #byob;
				at: 2 put: self rcvr;			"not really needed for this block. JM"
				at: 3 put: #readVariable;
				at: 4 put: commandSpec ].
	^ blockTuple
]

{ #category : #watcher }
VariableBlockMorph >> canBecomeWatcher [
	"All variable blocks can become watchers when dragged onto the stage."

	^ true
]

{ #category : #private }
VariableBlockMorph >> click: evt [

	| old frag |

	self isBlockTemplate
		ifFalse: [^ super click: evt]. 

	(owner isKindOf: PhratchBlockPaletteMorph)
		ifTrue: [^ super click: evt].

	((owner isKindOf: BlockMorph) and: [owner isCustomBlock and: [owner isTemplate]])
		ifFalse: [^self editName].
	owner hideArgumentPlaceHolders.

	owner isFrozen 
		ifTrue: [ ^ self]
		ifFalse: [ 
			owner isFrozen: true.
			submorphs first color: Color white slightlyDarker].

	old := labelFragment deepCopy.
	frag := BlockLabelFragmentDialog on: labelFragment category: owner category.

	owner isFrozen: false.
	submorphs first color: Color white.

	frag = #cancelled ifTrue: [
		labelFragment := old.
		^ self].
	owner updateSpecWithDnDSpec
]

{ #category : #watcher }
VariableBlockMorph >> createWatcher [
	"Return a new watcher for me."

	| newWatcher |
	newWatcher := WatcherMorph new setCategoryColor: self color.
	newWatcher target: receiver selector: #getVar: parameter: commandSpec.

	^ newWatcher

]

{ #category : #'byob lambdas' }
VariableBlockMorph >> defaultValue: something [
	"no op"
]

{ #category : #'byob lambdas' }
VariableBlockMorph >> deleteTemplate [

	owner deleteVariableTemplate: self
]

{ #category : #'byob lambdas' }
VariableBlockMorph >> duplicate [

	World activeHand attachMorph: self veryDeepCopy addLabel

]

{ #category : #'byob lambdas' }
VariableBlockMorph >> editName [
	| old new lambda |
	lambda := self owner.
	old := self commandSpec.
	new := StringDialog askWithCancel: 'Name' localized initialAnswer: commandSpec.
	(new isEmpty or: [old = new])
		ifTrue: [^ self].
	lambda isCustomBlock ifTrue: [
		self commandSpec: new.
		^ self].
	(lambda renameParm: old to: new) 
		ifTrue: [ self commandSpec: new ]

]

{ #category : #evaluation }
VariableBlockMorph >> evaluateWithArgs: args [
	"Overridden to read my variable value."

	alias ifNotNil: [ ^ receiver getVar: alias]. "special case for externalized local variables in BYOB"
	receiver ifNotNil: [ ^ receiver getVar: commandSpec block: self ].
	^ 0

]

{ #category : #'object i/o' }
VariableBlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #'byob lambdas' }
VariableBlockMorph >> handlesMouseOver: evt [

	^ (owner isKindOf: BlockMorph) and: [
		owner isCustomBlock and: [
			owner isTemplate]]

]

{ #category : #'byob lambdas' }
VariableBlockMorph >> handlesMouseOverDragging: evt [
	"Return true if this morph wants to receive mouseDown events (i.e., mouseDown:, mouseMove:, mouseUp:). The default response is false; subclasses that implement mouse messages should override this to return true." 

	^ (owner isKindOf: BlockMorph) and: [
		owner isCustomBlock and: [
			owner isTemplate]]

]

{ #category : #accessing }
VariableBlockMorph >> helpScreenName [
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	^ 'variable'

]

{ #category : #initialization }
VariableBlockMorph >> initialize [

	super initialize.
	commandSpec := ''.
	self color: (Color r: 0.4 g: 1.0 b: 0.4).
	labelFragment := BlockLabelFragment new

]

{ #category : #'byob lambdas' }
VariableBlockMorph >> isAbstractFunctionCall [
	"allow me to be dropped onto boolean args, as in the IF block"

	^true
]

{ #category : #'byob lambdas' }
VariableBlockMorph >> isBlockTemplate [

	| def |

	((owner isKindOf: BlockMorph) and: [
		owner isCustomBlock]) ifTrue: [
			def := owner definition.
			def ifNotNil: [
				(def typeOfParameterIndex: (owner argMorphs indexOf: self)) = #template
						ifTrue: [^true]]].


	^ super isBlockTemplate

]

{ #category : #'byob lambdas' }
VariableBlockMorph >> isPrototypeTemplate [

	(owner isKindOf: CommandBlockMorph)
		ifFalse: [^ false].
	(owner isCustomBlock and: [owner isTemplate])
		ifFalse: [^ false].
	^ true
]

{ #category : #accessing }
VariableBlockMorph >> isReporter [

	^ true

]

{ #category : #initialization }
VariableBlockMorph >> isSpecialForm: bool [

	super isSpecialForm: bool.
	isSpecialForm
		ifTrue: [self color: VariableFrame new variableBlockColor]
		ifFalse: [self color: (ScriptablePhratchMorph blockColorFor: 'variables')].

]

{ #category : #'byob lambdas' }
VariableBlockMorph >> labelFragment [
	^ labelFragment
]

{ #category : #'byob lambdas' }
VariableBlockMorph >> labelFragment: aBlockLabelFragment [
	labelFragment := aBlockLabelFragment
]

{ #category : #'byob lambdas' }
VariableBlockMorph >> mouseEnter: evt [

	owner isFrozen 
		ifTrue: [^ self].
	owner showPlaceHoldersNear: self.
	"owner hideArgumentPlaceHolders."
	submorphs first color: color twiceDarker

]

{ #category : #'byob lambdas' }
VariableBlockMorph >> mouseEnterDragging: evt [

	World activeHand submorphs size < 1 ifTrue: [
		^ self].

	owner isFrozen 
		ifTrue: [^ self].
	owner showPlaceHoldersNear: self
]

{ #category : #'byob lambdas' }
VariableBlockMorph >> mouseLeave: evt [

	(owner notNil and: [owner isFrozen]) 
		ifTrue: [^ self].
	submorphs first color: Color white
]

{ #category : #'byob lambdas' }
VariableBlockMorph >> mouseLeaveDragging: evt [

	World activeHand submorphs size < 1 ifTrue: [
		^self ].

	owner isFrozen 
		ifTrue: [^ self].
	submorphs first color: Color white
]

{ #category : #'byob lambdas' }
VariableBlockMorph >> parameterDefaultValue: aString [

	labelFragment default: aString
]

{ #category : #'byob lambdas' }
VariableBlockMorph >> parameterType: aSymbol [

	labelFragment type: aSymbol
]

{ #category : #accessing }
VariableBlockMorph >> receiver: anObject [
	"Set my receiver object and, if possible, my block color."

	alias ifNotNil: [^ self].
	receiver := anObject.
	alias := nil.

	(receiver respondsTo: #variableBlockColor)
		ifTrue: [self color: receiver variableBlockColor].

]

{ #category : #accessing }
VariableBlockMorph >> rename [

	| blockVars objVars obj list choice | 
	obj := self phratchObject.
	obj ifNil: [^#()].
	blockVars := self scriptVars asSortedCollection asArray.
	objVars := obj varNamesMenu asOrderedCollection.
	objVars removeAllSansError: blockVars.

	list := OrderedCollection new.
	objVars do: [:vname |
		vname = #-
			ifTrue: [list add: vname]
			ifFalse: [list add: {vname. {vname. false}}]].

	list add: #-.

	blockVars do: [:vname |
		list add: {vname. {vname. true}}].

	list size > 1 
		ifFalse: [^ self]. "the menu is empty"

	choice := MenuMorph new defaultTarget: self.
	list asArray do:[:aVarName |
		choice add: aVarName action: nil.	
	].
	choice localize; popUpAt: self topRight inWorld: World.
	
	
	choice selectedItem contents ifNil: [^ self].

	self isSpecialForm: choice second.
	isSpecialForm
		ifTrue: [self receiver: nil]
		ifFalse: [self receiver: obj].
	self commandSpec: choice first
]

{ #category : #'byob lambdas' }
VariableBlockMorph >> rightButtonMenu [

	| menu choice |

	((owner isKindOf: BlockMorph) and: [owner isCustomBlock and: [owner isTemplate]])
		ifTrue: [^ self click: nil].

	(((owner isKindOf: MultiArgReporterBlockMorph) and: [owner isLambdaForm])
		or: [owner isKindOf: VariableDeclarationBlockMorph])
		ifFalse: [ ^super rightButtonMenu ].
	menu := MenuMorphNG new defaultTarget: self.
	menu add: 'help' value: #presentHelpScreen.
	menu addLine.
	menu add: 'edit...' value: #editName.
	menu addLine.
	menu add: 'delete' value: #deleteTemplate.
	menu add: 'duplicate' value: #duplicate.
	(choice := menu localize; invokeModal) selectedValue ifNil: [^ self].
	self perform: choice.

]

{ #category : #'byob lambdas' }
VariableBlockMorph >> rootForGrabOf: aMorph [

	((owner isKindOf: BlockMorph) and: [
		owner isCustomBlock and: [owner isTemplate not and: [owner definition notNil]]]) ifTrue: [
			(owner definition typeOfParameterIndex: (owner argMorphs indexOf: aMorph)) = #template
				ifTrue: [^self fullCopy]].


	(owner notNil and: [owner isPartsBin])
		ifTrue: [ ^ super rootForGrabOf: aMorph]
		ifFalse: [^ self].


]

{ #category : #watcher }
VariableBlockMorph >> selectorAndArg [
	"Answer an array containing my selector and argument (if any)."

	^ Array with: #getVar: with: self variable

]

{ #category : #'byob lambdas' }
VariableBlockMorph >> updateFragment [

	labelFragment
		isInput: true;
		label: self variable
]

{ #category : #accessing }
VariableBlockMorph >> variable [

	^ commandSpec

]
