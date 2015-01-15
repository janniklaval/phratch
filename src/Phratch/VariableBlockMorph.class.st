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

	(' ' = dflt or: [dflt isEmpty]) ifFalse: [
		self addMorphBack: (self labelMorphFor: '=', labelFragment default asString)].


]

{ #category : #'byob lambdas' }
VariableBlockMorph >> alias: aString [

	alias := aString
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

	(owner isPhratchBlockPaletteMorph)
		ifTrue: [^ super click: evt].

	((owner isBlockMorph) and: [owner isCustomBlock and: [owner isTemplate]])
		ifFalse: [^self "editName"].
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

	alias ifNotNil: [ ^ receiver getVar: alias]. "special case for externalized local variables"
	receiver ifNotNil: [ ^ receiver getVar: commandSpec block: self ].
	^ 0

]

{ #category : #'byob lambdas' }
VariableBlockMorph >> handlesMouseOver: evt [

	^ (owner isBlockMorph) and: [
		owner isCustomBlock and: [
			owner isTemplate]]

]

{ #category : #'byob lambdas' }
VariableBlockMorph >> handlesMouseOverDragging: evt [
	"Return true if this morph wants to receive mouseDown events (i.e., mouseDown:, mouseMove:, mouseUp:). The default response is false; subclasses that implement mouse messages should override this to return true." 

	^ (owner isBlockMorph) and: [
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

	((owner isBlockMorph) and: [
		owner isCustomBlock]) ifTrue: [
			def := owner definition.
			def ifNotNil: [
				(def typeOfParameterIndex: (owner argMorphs indexOf: self)) = #template
						ifTrue: [^true]]].


	^ super isBlockTemplate

]

{ #category : #'byob lambdas' }
VariableBlockMorph >> isPrototypeTemplate [

	^(owner isCommandBlockMorph)
		and:[(owner isCustomBlock and: [owner isTemplate])].

]

{ #category : #initialization }
VariableBlockMorph >> isSpecialForm: bool [

	super isSpecialForm: bool.
	isSpecialForm
		ifTrue: [self color: VariableFrame new variableBlockColor]
		ifFalse: [self color: (PhratchCategory blockColorFor: 'variables')].

]

{ #category : #testing }
VariableBlockMorph >> isVariableBlockMorph [

	^ true
]

{ #category : #'byob lambdas' }
VariableBlockMorph >> labelFragment [
	^ labelFragment
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

	((owner isBlockMorph) and: [owner isCustomBlock and: [owner isTemplate]])
		ifTrue: [^ self click: nil].

	(((owner isKindOf: MultiArgReporterBlockMorph) and: [owner isLambdaForm])
		or: [owner isVariableDeclarationBlockMorph])
		ifFalse: [ ^super rightButtonMenu ].
	menu := MenuMorph new defaultTarget: self.
	menu add: 'help' value: #presentHelpScreen.
	menu addLine.
	menu add: 'edit...' value: #editName.
	menu addLine.
	menu add: 'delete' value: #deleteTemplate.
	menu add: 'duplicate' value: #duplicate.
	menu localize; invokeModal.
	choice := menu selectedValue ifNil: [^ self].
	self perform: choice.

]

{ #category : #'byob lambdas' }
VariableBlockMorph >> rootForGrabOf: aMorph [

	((owner isBlockMorph) and: [
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
