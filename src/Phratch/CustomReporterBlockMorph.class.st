Class {
	#name : #CustomReporterBlockMorph,
	#superclass : #ReporterBlockMorph,
	#instVars : [
		'userSpec',
		'isTemplate',
		'specParts',
		'isFrozen',
		'extraSpaces'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #'as yet unclassified' }
CustomReporterBlockMorph class >> template [
	^self new isTemplate: true
]

{ #category : #template }
CustomReporterBlockMorph >> addLabel [

	| tokens args nextArgIndex m next part frontSpace backSpace |
	commandSpec ifNil: [^ self].

	isTemplate ifFalse: [
		^ self addLabelToNonTemplate].

	"we make sure not to remove the next block."
	next := self nextBlock.
	self removeAllMorphsIn: (self submorphs reject: [:t | t = next]).

	tokens := commandSpec findTokens: ' '.
	args := tokens select: [:s | CommandBlockMorph isArgSpec: s].

	"remove any excess arg morphs from the list."
	[argMorphs size > args size] whileTrue: [
		m := argMorphs last.
		argMorphs remove: m.

		"if the argument we're throwing out is anything complicated, we'd like to keep it around in the world."
		(m isKindOf: BlockMorph) ifTrue: [m openInWorld]].

	"create new arg morphs."
	[argMorphs size < args size] whileTrue: [
		argMorphs addLast: (self argMorphFor: (args at: argMorphs size + 1))].

	nextArgIndex := 1.

	extraSpaces := Array new: 2.

	"insert a place holder on front"
	frontSpace := Morph new 
		color: Color transparent; 
		extent: ArgumentPlaceHolderMorph dimensions;
		yourself.
	extraSpaces at: 1 put: frontSpace.
	self addMorphBack: frontSpace.


	specParts := OrderedCollection new.
	part := ArgumentPlaceHolderMorph new.
	self addMorphBack: part.
	specParts add: part.
	tokens do: [:s |
		(CommandBlockMorph isArgSpec: s)
			ifTrue:	[
				m := argMorphs at: nextArgIndex.
				nextArgIndex := nextArgIndex + 1]
			ifFalse:	[
				m := self labelMorphFor: (String withAll: s)].
		self addMorphBack: m.
		specParts add: m.
		part := ArgumentPlaceHolderMorph new.
			self addMorphBack: part.
			specParts add: part ].

	"insert another place holder at the back"
	backSpace := Morph new 
		color: Color transparent; 
		extent: ArgumentPlaceHolderMorph dimensions;
		yourself.
	extraSpaces at: 2 put: backSpace.
	self addMorphBack: backSpace.

	self isReporter ifTrue: [
		m := submorphs first.
		((m isKindOf: ChoiceArgMorph) | (m isKindOf: SpriteArgMorph)) ifTrue: [  "add spacer"
			self addMorphFront: (Morph new color: Color transparent; extent: 2@5;
		yourself)].

		m := submorphs last.
		((m isKindOf: ChoiceArgMorph) | (m isKindOf: SpriteArgMorph)) ifTrue: [  "add spacer"
			self addMorphBack: (Morph new color: Color transparent; extent: 2@5;
		yourself)]].

	self addVariableTemplates.
	self hideArgumentPlaceHolders
]

{ #category : #template }
CustomReporterBlockMorph >> addLabelToNonTemplate [
	"Add a label for my command and arguments. This is the method that really creates the whole block."

	| tokens args nextArgIndex m next argValues eachArg eachValue pn pt def |
	commandSpec ifNil: [^ self].

	"remember the values of the arguments"
	argValues := OrderedCollection new.
	argMorphs do: [:a |
		(a isKindOf: BlockMorph)
			ifTrue: [argValues add: a]
			ifFalse: [(a isKindOf: MultiArgMorph)
				ifTrue: [argValues add: a listValue]
				ifFalse: [(a isKindOf: ExpressionArgMorph)
					ifTrue: [ a isNumberExpression
						ifTrue: [a getExpression = ' '
							ifTrue: [argValues add: a getExpression]
							ifFalse: [argValues add: a getExpression asNumberNoError]]
						ifFalse: [argValues add: a getExpression]]
					ifFalse: [a isEmptySlot
						ifFalse: [argValues add: a evaluate]]]]].

	"we make sure not to remove the next block."
	next := self nextBlock.
	self removeAllMorphsIn: (self submorphs reject: [:t | t = next]).

	tokens := CommandBlockMorph parseCommandSpec: commandSpec.
	args := tokens select: [:s | CommandBlockMorph isArgSpec: s].

	"remove all arg morphs from the list."
	[argMorphs size > 0 ] whileTrue: [
		m := argMorphs last.
		argMorphs remove: m].

	"create new arg morphs."
	[argMorphs size < args size] whileTrue: [
		def := self definition.
		def isNil
			ifTrue: [pt := #any]
			ifFalse: [ pt := def typeOfParameterIndex: argMorphs size + 1].
		#template = pt 
			ifTrue: [
				pn := def parameterNames at: argMorphs size + 1.
				argMorphs addLast: 	(VariableBlockMorph new 
					isSpecialForm: true; 
					selector: #getVar:;
					commandSpec: pn;
		yourself)]
			ifFalse: [argMorphs addLast: (self argMorphFor: (args at: argMorphs size + 1))]].

	nextArgIndex := 1.

	tokens do: [:s |
		(CommandBlockMorph isArgSpec: s)
			ifTrue:	[
				m := argMorphs at: nextArgIndex.
				nextArgIndex := nextArgIndex + 1]
			ifFalse:	[
				m := self labelMorphFor: (String withAll: s)].
		self addMorphBack: m].

	(self isReporter and: [submorphs isEmpty not]) ifTrue: [
		m := submorphs first.
		((m isKindOf: ChoiceArgMorph) | (m isKindOf: SpriteArgMorph)) ifTrue: [  "add spacer"
			self addMorphFront: (Morph new color: Color transparent; extent: 2@5;
		yourself)].

		m := submorphs last.
		((m isKindOf: ChoiceArgMorph) | (m isKindOf: SpriteArgMorph)) ifTrue: [  "add spacer"
			self addMorphBack: (Morph new color: Color transparent; extent: 2@5;
		yourself)]].

	"now try restoring the former arguments (jens)"
	1 to: argMorphs size do: [:i |
		eachArg := argMorphs at: i.
		eachValue := argValues at: i ifAbsent: [nil].
		eachValue ifNotNil: [(eachValue isKindOf: BlockMorph)
			ifTrue: [(eachArg acceptsTypeOf: eachValue)
				ifTrue: [ (({CSlotMorph. OSlotMorph. CArgSlotMorph. CReporterSlotMorph} includes: eachArg class) and: [eachArg class = eachValue class])
					ifTrue: [self replaceArgMorph: eachArg by: eachValue]
					ifFalse: [({CSlotMorph. OSlotMorph. CArgSlotMorph. CReporterSlotMorph} includes: eachValue class)
						ifTrue: [((eachArg respondsTo: #attachBlock:) and: [(eachValue respondsTo: #nestedBlock) and: [eachValue nestedBlock notNil]])
							ifTrue: [eachArg attachBlock: eachValue nestedBlock]]
						ifFalse: [self replaceArgMorph: eachArg by: eachValue]]]
				ifFalse: [((eachArg isKindOf: VariableBlockMorph) and: [
							eachValue isKindOf: VariableBlockMorph])
								ifTrue: [eachArg commandSpec: eachValue commandSpec]]]
			ifFalse: [ 
				((eachArg isKindOf: ExpressionArgMorph) and: [eachArg isNumberExpression])
					ifTrue: [eachArg defaultValue: eachValue "asNumberNoError"]
					ifFalse: [ (eachValue isKindOf: PhratchListMorph)
						ifTrue: [eachArg defaultValue: eachValue]
						ifFalse: [eachArg defaultValue: eachValue asString]]]]]



]

{ #category : #template }
CustomReporterBlockMorph >> addVariableTemplates [
	| parms varBlock idx |
	parms := self definition parameterNames.
	1 to: parms size do: [: i |
		varBlock := VariableBlockMorph new. 
		varBlock
			isSpecialForm: true;
			receiver: self definition;
			selector: #getBlockVar:;
			commandSpec: (parms at: i);
			updateFragment;
			parameterType: (self definition typeOf: (parms at: i));
			parameterDefaultValue: (self definition defaultOf: (parms at: i)).
		idx := specParts indexOf: (self argumentAt: i).
		idx > 0 ifTrue: [ specParts at: idx put: varBlock].
		self replaceArgMorph: (self argumentAt: i) by: varBlock.
		varBlock addLabel]


]

{ #category : #variables }
CustomReporterBlockMorph >> allVarNames [
	^self definition allVarNames
]

{ #category : #accessing }
CustomReporterBlockMorph >> answer [
	self definition answer
]

{ #category : #'stack/tuple conversion' }
CustomReporterBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	| blockTuple argList arg val eval |
	blockTuple := Array new: argMorphs size + 4.
	blockTuple
		at: 1 put: #byob;
		at: 2 put: self rcvr;
		at: 3 put: selector;
		at: 4 put: userSpec.

	argList := argMorphs.
	1 to: argList size do: [:i |
		arg := argList at: i.
		(arg isKindOf: ArgMorph) | (arg isKindOf: EventTitleMorph)
			ifTrue: [(arg isKindOf: MultiArgMorph)
				ifTrue: [ blockTuple at: i + 4 put: arg listValue convertStacksToTuples] "a list"
				ifFalse: [ ((arg isKindOf: CSlotMorph) or: [arg isKindOf: OSlotMorph])
					ifTrue: [blockTuple at: i + 4 put: arg asBlockTuple]
					ifFalse: [(arg isKindOf: ExpressionArgMorph)
						ifTrue: [
							val := arg getExpression.
							arg isNumberExpression
								ifTrue: [val = ' '
									ifTrue: [eval := val]
									ifFalse: [eval := val asNumberNoError]]
								ifFalse: [eval := arg getExpression]]
						ifFalse: [eval := arg evaluate].
						blockTuple at: i + 4 put: eval]]]
			ifFalse: [blockTuple at: i + 4 put: arg asBlockTuple]].
	^ blockTuple

]

{ #category : #private }
CustomReporterBlockMorph >> canBecomeWatcher [

	^ false

]

{ #category : #accessing }
CustomReporterBlockMorph >> category [

	^ self definition category
]

{ #category : #accessing }
CustomReporterBlockMorph >> defaultArgs: defaultValues [
	"Set the default values of my arguments from the given list."

	self setDefaultArgs
]

{ #category : #accessing }
CustomReporterBlockMorph >> definition [
	^receiver definitionFor: self id
]

{ #category : #'as yet unclassified' }
CustomReporterBlockMorph >> deleteDefinition [
	receiver deleteDefinitionId: self id
]

{ #category : #'as yet unclassified' }
CustomReporterBlockMorph >> editScript [
	receiver editScriptId: self id
]

{ #category : #'as yet unclassified' }
CustomReporterBlockMorph >> editSpec [
	(World allMorphs detect: [:m| m isKindOf: BlockDialog] ifNone: [nil])
		ifNotNil: [^self].
	receiver editSpecId: self id
]

{ #category : #evaluation }
CustomReporterBlockMorph >> evaluateWithArgs: rawArgs [
	"Evalue this block with the given argument list."

	self start.
	phratchProc stepUntilDoneFor: (receiver ownerOrYourselfThatIsA: PhratchStageMorph).
	^phratchProc answer	
]

{ #category : #'object i/o' }
CustomReporterBlockMorph >> fieldsVersion [

	^ 1

]

{ #category : #'block enumerating' }
CustomReporterBlockMorph >> firstBlockList [

	| list |
	self script
		ifNil: [list := Array with: self definition answerBlock]
		ifNotNil: [list := self script blockSequence, (Array with: self definition answerBlock)].
	^ list 

		"collect: [:each| each fullCopy]"  "old code taken out for speed, now the copying is done in #doApplyEval"


]

{ #category : #template }
CustomReporterBlockMorph >> getDnDSpec [
	| s |
	s := ''.
	specParts do: [:part | 
		s := s, ' ', (part labelFragment spec)].
	^s withoutLeadingBlanks
]

{ #category : #template }
CustomReporterBlockMorph >> handleTool: toolName hand: hand [
	isTemplate ifFalse: [super handleTool: toolName hand: hand ]
]

{ #category : #template }
CustomReporterBlockMorph >> hideArgumentPlaceHolders [

	isFrozen ifTrue: [^ self].
	extraSpaces ifNotNil: [
		extraSpaces do: [:each |
			each extent: ArgumentPlaceHolderMorph dimensions ]].
	submorphs do: [:m |
		(m isKindOf: ArgumentPlaceHolderMorph)
			ifTrue: [m vanish]]
]

{ #category : #identification }
CustomReporterBlockMorph >> id [
	^CustomBlockDefinition idFromSpec: userSpec
]

{ #category : #'object i/o' }
CustomReporterBlockMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		userSpec
	) from: anObjStream.


]

{ #category : #initialization }
CustomReporterBlockMorph >> initialize [
	super initialize.
	isTemplate := false.
	isFrozen := false.
	isSpecialForm := true.
	self color: Color lightGray
]

{ #category : #testing }
CustomReporterBlockMorph >> isAtomic [
	^self definition isAtomic
]

{ #category : #byob }
CustomReporterBlockMorph >> isCustomBlock [
	^true
]

{ #category : #template }
CustomReporterBlockMorph >> isFrozen [
	^ isFrozen
]

{ #category : #template }
CustomReporterBlockMorph >> isFrozen: bool [
	isFrozen := bool
]

{ #category : #testing }
CustomReporterBlockMorph >> isFunction [
	^ true
]

{ #category : #template }
CustomReporterBlockMorph >> isInterestedIn: aMorph [

	isTemplate ifFalse: [^ false].
	^(aMorph isKindOf: VariableBlockMorph) and: [aMorph isSpecialForm and: [
		(self parameterNames includes: aMorph variable) not]]
]

{ #category : #template }
CustomReporterBlockMorph >> isPartsBin [
	^isTemplate
]

{ #category : #other }
CustomReporterBlockMorph >> isReporter [
	^true
]

{ #category : #template }
CustomReporterBlockMorph >> isTemplate [
	^isTemplate
]

{ #category : #template }
CustomReporterBlockMorph >> isTemplate: aBoolean [
	isTemplate := aBoolean
]

{ #category : #template }
CustomReporterBlockMorph >> labelMorphFor: aString [

	| s |

	isTemplate ifFalse: [^super labelMorphFor: aString].

	s := aString.
	^ (BlockLabelFragmentMorph contents: s font: (PhratchFrameMorph getFont: #Label))
		color: self labelColor;
		updateFragment;
		yourself

]

{ #category : #accessing }
CustomReporterBlockMorph >> parameterNames [
	^self definition parameterNames
]

{ #category : #'as yet unclassified' }
CustomReporterBlockMorph >> privateSetUserSpec: aString [

	userSpec := aString.

]

{ #category : #accessing }
CustomReporterBlockMorph >> remove [

	self aboutToBeGrabbedBy: nil.
	self delete
]

{ #category : #template }
CustomReporterBlockMorph >> removeParameter: varBlock [

	| idx |
	idx := specParts indexOf: varBlock.
	idx = 0 ifTrue: [^self].
	specParts at: idx put: ArgumentPlaceHolderMorph new.
	self updateSpecWithDnDSpec
]

{ #category : #template }
CustomReporterBlockMorph >> removeVariableTemplates [
	argMorphs do: [:each| each delete ].
	argMorphs := OrderedCollection new
]

{ #category : #'menu - change set' }
CustomReporterBlockMorph >> rename [

	| def defs choice menu |
	def := self definition.
	defs := receiver customBlocks select: [:eachDef |
		eachDef ~= def and: [
			eachDef type = def type and: [
				eachDef category = def category ]]].
	menu := MenuMorph new defaultTarget: self.
	defs do: [:eachDef |
		menu addIcon: (receiver lambda: eachDef id) imageForm toolTip: nil action: eachDef].
	choice := menu popUpAt: self topRight inWorld: World.
	choice ifNil: [^ self].
	self userSpec: choice userSpec
]

{ #category : #private }
CustomReporterBlockMorph >> replaceArgMorph: argMorph by: newMorph [

	| def typ pname i val |
	super replaceArgMorph: argMorph by: newMorph.
	(newMorph isKindOf: ExpressionArgMorph) ifTrue: [
		def := self definition.
		i := argMorphs indexOf: newMorph.
		pname := def parameterNames at: i.
		typ := def typeOf: pname.
		val := def defaultOf: pname.
		#number = typ
			ifTrue: [newMorph numExpression: val] 
			ifFalse: [newMorph defaultValue: val]]
]

{ #category : #byob }
CustomReporterBlockMorph >> rightButtonMenu [

	| menu choice |
	self isTemplate ifTrue: [^ self].
	menu := MenuMorphNG new defaultTarget: self.
	menu add: 'help' value: #presentHelpScreen.
	menu addLine.
	menu add: 'edit' value: #editScript.

	(owner isKindOf: PhratchBlockPaletteMorph) ifFalse: [

		menu add: 'relabel' value: #rename.
		menu addLine.
		menu add: 'duplicate' value: #duplicate.
		(self owner isKindOf: BlockMorph) ifFalse: [  "can't yet delete a blocks inside a script"
			menu add: 'delete' value: #delete]].

	(owner isKindOf: PhratchBlockPaletteMorph) ifTrue: [
		menu add: 'delete block definition' value: #deleteDefinition ].

	"^ (menu localize; invokeModal) selectedValue"
	menu localize; invokeModal.
	choice := menu selectedValue ifNil: [^ self].
	self perform: choice.
]

{ #category : #template }
CustomReporterBlockMorph >> rootForGrabOf: aMorph [

	| root |
	root := aMorph.
	[root = self] whileFalse: [
		root owner == self ifTrue: [
			self isPartsBin ifTrue: [
				root = self nextBlock
					ifTrue: [^root]
					ifFalse: [^ root fullCopy]].
			self dragNDropEnabled ifTrue: [^ root]].
		root := root owner].
	(isTemplate and: [ owner isKindOf: ProcedureHatBlockMorph]) ifTrue: [^nil].

	^ super rootForGrabOf: aMorph

]

{ #category : #accessing }
CustomReporterBlockMorph >> script [
	^self definition body
]

{ #category : #accessing }
CustomReporterBlockMorph >> sequence [
	^self firstBlockList
]

{ #category : #'as yet unclassified' }
CustomReporterBlockMorph >> setDefaultArgs [

	| a def parms typ |

	def := self definition.
	parms := def parameterNames.
	1 to: argMorphs size do: [:i |
		a := argMorphs at: i.
		(a isKindOf: ArgMorph) ifTrue: [
			(a isKindOf: MultiArgMorph)
				ifTrue: [a addArgSlot]
				ifFalse: [
					typ := def typeOf: (parms at: i).
					#number = typ
						ifTrue: [a numExpression: (def defaultOf: (parms at: i))]
						ifFalse: [a defaultValue: (def defaultOf: (parms at: i))]]]]
]

{ #category : #template }
CustomReporterBlockMorph >> showArgumentPlaceHolders [

	submorphs do: [:m |
		(m isKindOf: ArgumentPlaceHolderMorph)
			ifTrue: [m appear]]
]

{ #category : #template }
CustomReporterBlockMorph >> showEdgePlaceHolders [

	isFrozen ifTrue: [^ self].
	self hideArgumentPlaceHolders.
	extraSpaces ifNil: [^ self].
	extraSpaces do: [:each |
		each extent: 0@0].
	
	specParts first appear.
	specParts last appear.

]

{ #category : #template }
CustomReporterBlockMorph >> showPlaceHoldersNear: aLabelFragment [

	| idx |
	isFrozen ifTrue: [^ self].
	self hideArgumentPlaceHolders.
	extraSpaces do: [:each |
		each extent: 0@0].
	
	idx := submorphs indexOf: aLabelFragment.
	(submorphs at: idx - 1) appear.
	(submorphs at: idx + 1) appear.

	(aLabelFragment isKindOf: VariableBlockMorph)
		ifFalse: [aLabelFragment color: color twiceDarker]



]

{ #category : #other }
CustomReporterBlockMorph >> showValue [

	| gotError msg tooltip w worldBounds |
	gotError := false.

	[self start.
	phratchProc stepUntilDoneFor: (receiver ownerOrYourselfThatIsA: PhratchStageMorph).
	msg := phratchProc answer] ifError: [
		gotError := true.
		msg := 'Error!'].

	(msg isKindOf: Morph)
		ifTrue: [(msg respondsTo: #displayForm)
			ifTrue: [msg := msg displayForm ]
			ifFalse: [msg := msg imageForm ]]
		ifFalse: [msg := msg asString ].

	((self isBooleanReporter or: [msg = 'Error!']) and: [msg isKindOf: String]) ifTrue: [
		msg := msg localized].
	tooltip := (PhratchReporterToolTipMorph string: msg for: self)
		left: self right;
		bottom: self top;
		yourself.
	PhratchTranslator isRTL ifTrue: [tooltip right: self left].
	gotError ifTrue: [tooltip messageColor: Color red darker].

	w := self world.
	w ifNil: [^self].
	w addMorphFront: tooltip.
	((worldBounds := w bounds) containsRect: tooltip bounds) ifFalse:
		[tooltip bounds: (tooltip bounds translatedToBeWithin: worldBounds)].

	self setProperty: #toolTip toValue: tooltip.
	tooltip initialCursorPoint: Sensor cursorPoint.
	tooltip startStepping.


]

{ #category : #'object i/o' }
CustomReporterBlockMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		userSpec
	) on: anObjStream.

]

{ #category : #template }
CustomReporterBlockMorph >> updateSpecWithDnDSpec [
	"the spec has been changed by way of drag'n'drop (Jens' design) 
	or direct editing (Brian's design).

	We need to:

	1.	determine the new command spec
	2. 	check for input constraints
	3.	determine the new parameters and their types (declarations) and defaults
	4. 	update the definition's parameters declaration dictionary
	5. 	update every instance of the definition if it is global
	6.	update the definition's userSpec -> update every instance of the definition
	7.	update the Block Editor
	8.	update the Phratch Window
"

	| newSpec parms defaults oldid newid types def  stage affected eachDef be sf |

	"1.	determine the new command spec"

	def := self definition.
	def ifNil: [^self].
	oldid := self id.

	newSpec := self getDnDSpec. 
	newSpec isEmpty ifTrue: [
		self addLabel.
		^ self ].	

	newid := CustomBlockDefinition idFromSpec: newSpec. 

	"2. 	check for input constraints"

	parms := def parameterNamesInSpec: newSpec.
	parms size > parms asSet size ifTrue: [
		DialogBoxMorph warn: 'a parameter with that label already exists'.
		self addLabel.
		^ self ].	

	((newid ~= oldid) and: [receiver existsBlockId: newid global: def isGlobal]) ifTrue: [
		DialogBoxMorph warn: 'a block with that label already exists'.
		self addLabel.
		^ self ].	

	"3.	determine the new parameters and their types (declarations) and defaults"

	types := Dictionary new.
	defaults := Dictionary new.
	(specParts select: [:part | part labelFragment isInput ]) do: [:m |
		types at: m labelFragment label put: m labelFragment type.
		defaults at: m labelFragment label put: m labelFragment default ].

	"4. 	update the definition's parameters declaration dictionary
	5. 	update every instance of the definition if it is global
	6.	update the definition's userSpec -> update every instance of the definition"

	stage := receiver ownerOrYourselfThatIsA: PhratchStageMorph.

	def isGlobal not | stage isNil
		ifTrue: [
			def
				declarations: types;
				defaults: defaults.
			affected := receiver instancesOf: oldid.
			def userSpec: newSpec.
			affected do: [:eachBlock|
				eachBlock
					privateSetUserSpec: newSpec;
					commandSpec: def commandSpec]]
		ifFalse: [
			stage sprites, {stage} do: [:obj | 
				eachDef :=  obj definitionFor: oldid.
				eachDef ifNotNil: [
					eachDef
						declarations: types copy;
						defaults: defaults copy.
					affected := obj instancesOf: oldid.
					eachDef userSpec: newSpec.
					affected do: [:eachBlock|
						eachBlock
							privateSetUserSpec: newSpec;
							commandSpec: eachDef commandSpec]]]].

	"7.	update the Block Editor"

	be := self ownerOrYourselfThatIsA: BlockEditorFrameMorph.

	be definition
		declarations: types copy;
		defaults: defaults copy;
		userSpec: newSpec.

	affected := be instancesOf: oldid.
	affected do: [:eachBlock|
		eachBlock
			privateSetUserSpec: newSpec;
			commandSpec: def commandSpec].

	"8.	update the Phratch Window"

	sf := receiver ownerOrYourselfThatIsA: PhratchFrameMorph.
	sf viewerPane categoryChanged: 'variables'.
	#none = def category ifFalse: [
		sf viewerPane categoryChanged: def category asString ]

]

{ #category : #accessing }
CustomReporterBlockMorph >> userSpec [
	^userSpec
]

{ #category : #accessing }
CustomReporterBlockMorph >> userSpec: aString [
	| cat |

	userSpec := aString.
	isTemplate ifTrue: [self removeVariableTemplates].
	cat := self category.
	cat ifNotNil: [
		self color: (ScriptablePhratchMorph blockColorFor: cat asString) ].
	self commandSpec: (receiver definitionFor: self id) commandSpec.
	self addLabel
]

{ #category : #copying }
CustomReporterBlockMorph >> veryDeepFixupWith: deepCopier [
	"If fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals."

	super veryDeepFixupWith: deepCopier.
	specParts ifNotNil: [
		specParts := specParts collect: [:m | deepCopier references at: m ifAbsent: [m]]].
]

{ #category : #copying }
CustomReporterBlockMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

	super veryDeepInner: deepCopier.
	userSpec := userSpec veryDeepCopyWith: deepCopier.
	isTemplate := isTemplate veryDeepCopyWith: deepCopier.
	isFrozen := isFrozen veryDeepCopyWith: deepCopier.
	extraSpaces := extraSpaces veryDeepCopyWith: deepCopier.
]
