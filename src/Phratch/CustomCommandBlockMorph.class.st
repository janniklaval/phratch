"
some code which could be useful:

| hat template |
hat := WhenHatBlockMorph new.
hat submorphs do: [:m | (m isKindOf: StringMorph) ifTrue: [m delete]].
template := CommandBlockMorph new commandSpec: 'this is a long, long road to go down'.
hat replaceArgMorph: hat argMorph by: template.
hat openInWorld



"
Class {
	#name : #CustomCommandBlockMorph,
	#superclass : #CommandBlockMorph,
	#instVars : [
		'userSpec',
		'isTemplate',
		'specParts',
		'isFrozen',
		'extraSpaces'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #accessing }
CustomCommandBlockMorph class >> owner [
	^ 'jens'
]

{ #category : #accessing }
CustomCommandBlockMorph class >> template [
	^self new isTemplate: true
]

{ #category : #template }
CustomCommandBlockMorph >> addLabel [

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
		argMorphs remove: m].

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
		((m isChoiceArgMorph) | (m isSpriteArgMorph)) ifTrue: [  "add spacer"
			self addMorphFront: (Morph new color: Color transparent; extent: 2@5;
		yourself)].

		m := submorphs last.
		((m isChoiceArgMorph) | (m isSpriteArgMorph)) ifTrue: [  "add spacer"
			self addMorphBack: (Morph new color: Color transparent; extent: 2@5;
		yourself)]].

	self addVariableTemplates.
	self hideArgumentPlaceHolders
]

{ #category : #template }
CustomCommandBlockMorph >> addLabelToNonTemplate [
	"Add a label for my command and arguments. This is the method that really creates the whole block."

	| tokens args nextArgIndex m next argValues eachArg eachValue pn pt def |
	commandSpec ifNil: [ ^ self ].	"remember the values of the arguments"
	argValues := OrderedCollection new.
	argMorphs
		do: [ :a | 
			(a isBlockMorph)
				ifTrue: [ argValues add: a ]
				ifFalse: [ 
					(a isMultiArgMorph)
						ifTrue: [ argValues add: a listValue ]
						ifFalse: [ 
							(a isExpressionArgMorph)
								ifTrue: [ 
									a isNumberExpression
										ifTrue: [ 
											a getExpression = ' '
												ifTrue: [ argValues add: a getExpression ]
												ifFalse: [ argValues add: a getExpression asNumberNoError ] ]
										ifFalse: [ argValues add: a getExpression ] ]
								ifFalse: [ 
									a isEmptySlot
										ifFalse: [ argValues add: a evaluate ] ] ] ] ].	"we make sure not to remove the next block."
	next := self nextBlock.
	self removeAllMorphsIn: (self submorphs reject: [ :t | t = next ]).
	tokens := CommandBlockMorph parseCommandSpec: commandSpec.
	args := tokens select: [ :s | CommandBlockMorph isArgSpec: s ].	"remove all arg morphs from the list."
	[ argMorphs size > 0 ]
		whileTrue: [ 
			m := argMorphs last.
			argMorphs remove: m ].	"create new arg morphs."
	[ argMorphs size < args size ]
		whileTrue: [ 
			def := self definition.
			pt := def isNil
				ifTrue: [ #any ]
				ifFalse: [ def typeOfParameterIndex: argMorphs size + 1 ].
			#template = pt
				ifTrue: [ 
					pn := def parameterNames at: argMorphs size + 1.
					argMorphs
						addLast:
							(VariableBlockMorph new
								isSpecialForm: true;
								selector: #getVar:;
								commandSpec: pn;
								yourself) ]
				ifFalse: [ argMorphs addLast: (self argMorphFor: (args at: argMorphs size + 1)) ] ].
	nextArgIndex := 1.
	tokens
		do: [ :s | 
			(CommandBlockMorph isArgSpec: s)
				ifTrue: [ 
					m := argMorphs at: nextArgIndex.
					nextArgIndex := nextArgIndex + 1 ]
				ifFalse: [ m := self labelMorphFor: (String withAll: s) ].
			self addMorphBack: m ].
	(self isReporter and: [ submorphs isEmpty not ])
		ifTrue: [ 
			m := submorphs first.
			(m isChoiceArgMorph) | (m isSpriteArgMorph)
				ifTrue: [ 
					"add spacer"
					self
						addMorphFront:
							(Morph new
								color: Color transparent;
								extent: 2 @ 5;
								yourself) ].
			m := submorphs last.
			(m isChoiceArgMorph) | (m isSpriteArgMorph)
				ifTrue: [ 
					"add spacer"
					self
						addMorphBack:
							(Morph new
								color: Color transparent;
								extent: 2 @ 5;
								yourself) ] ].	"now try restoring the former arguments (jens)"
	1 to: argMorphs size do: [ :i | 
		eachArg := argMorphs at: i.
		eachValue := argValues at: i ifAbsent: [ nil ].
		eachValue
			ifNotNil: [ 
				(eachValue isBlockMorph)
					ifTrue: [ 
						(eachArg acceptsTypeOf: eachValue)
							ifTrue: [ 
								(({CSlotMorph.
								OSlotMorph.
								CArgSlotMorph} includes: eachArg class) and: [ eachArg class = eachValue class ])
									ifTrue: [ self replaceArgMorph: eachArg by: eachValue ]
									ifFalse: [ 
										({CSlotMorph.
										OSlotMorph.
										CArgSlotMorph} includes: eachValue class)
											ifTrue: [ 
												((eachArg respondsTo: #attachBlock:) and: [ (eachValue respondsTo: #nestedBlock) and: [ eachValue nestedBlock notNil ] ])
													ifTrue: [ eachArg attachBlock: eachValue nestedBlock ] ]
											ifFalse: [ self replaceArgMorph: eachArg by: eachValue ] ] ]
							ifFalse: [ 
								((eachArg isVariableBlockMorph) and: [ eachValue isVariableBlockMorph ])
									ifTrue: [ eachArg commandSpec: eachValue commandSpec ] ] ]
					ifFalse: [ 
						((eachArg isExpressionArgMorph) and: [ eachArg isNumberExpression ])
							ifTrue: [ eachArg defaultValue: eachValue	"asNumberNoError" ]
							ifFalse: [ 
								(eachValue isPhratchListMorph)
									ifTrue: [ eachArg defaultValue: eachValue ]
									ifFalse: [ eachArg defaultValue: eachValue asString ] ] ] ] ]
]

{ #category : #template }
CustomCommandBlockMorph >> addVariableTemplates [
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
CustomCommandBlockMorph >> allVarNames [
	^self definition allVarNames
]

{ #category : #private }
CustomCommandBlockMorph >> blockAttachPoints: aSet [
	"Answer a collection of possible attachment points for me. Each entry is an Association mapping a point to the morph to which a dropping block could be attached."

	isTemplate
		ifTrue: [^#()]
		ifFalse: [ super blockAttachPoints: aSet ]
		
]

{ #category : #accessing }
CustomCommandBlockMorph >> category [

	| def |
	def := self definition.
	def ifNil: [^#none].
	^ def category
]

{ #category : #accessing }
CustomCommandBlockMorph >> defaultArgs: defaultValues [
	"Set the default values of my arguments from the given list."

	self setDefaultArgs
]

{ #category : #accessing }
CustomCommandBlockMorph >> definition [
	^receiver definitionFor: self id
]

{ #category : #editing }
CustomCommandBlockMorph >> deleteDefinition [
	receiver deleteDefinitionId: self id
]

{ #category : #editing }
CustomCommandBlockMorph >> editScript [
	receiver editScriptId: self id
]

{ #category : #editing }
CustomCommandBlockMorph >> editSpec [
	(World allMorphs detect: [:m| m isBlockDialog] ifNone: [nil])
		ifNotNil: [^self].
	receiver editSpecId: self id
]

{ #category : #'block enumerating' }
CustomCommandBlockMorph >> firstBlockList [

	self script
		ifNil: [^ #()]
		ifNotNil: [^ self script blockSequence "collect: [:each | each fullCopy]"]. "added #fullCopy for lambda variable support. -JM"

	 "old code taken out for speed, now the copying is done in #doApplyEval"
]

{ #category : #template }
CustomCommandBlockMorph >> getDnDSpec [
	| s |
	s := ''.
	specParts do: [:part | 
		s := s, ' ', (part labelFragment spec)].
	^s withoutLeadingBlanks
]

{ #category : #template }
CustomCommandBlockMorph >> handleTool: toolName hand: hand [
	isTemplate ifFalse: [super handleTool: toolName hand: hand ]
]

{ #category : #template }
CustomCommandBlockMorph >> hideArgumentPlaceHolders [

	isFrozen ifTrue: [^ self].
	extraSpaces ifNotNil: [
		extraSpaces do: [:each |
			each extent: ArgumentPlaceHolderMorph dimensions ]].
	submorphs do: [:m |
		(m isKindOf: ArgumentPlaceHolderMorph)
			ifTrue: [m vanish]]
]

{ #category : #identification }
CustomCommandBlockMorph >> id [
	^CustomBlockDefinition idFromSpec: userSpec
]

{ #category : #initialization }
CustomCommandBlockMorph >> initialize [
	super initialize.
	isTemplate := false.
	isFrozen := false.
	isSpecialForm := true.
	self color: Color lightGray
]

{ #category : #testing }
CustomCommandBlockMorph >> isAtomic [
	^self definition isAtomic
]

{ #category : #byob }
CustomCommandBlockMorph >> isCustomBlock [
	^true
]

{ #category : #testing }
CustomCommandBlockMorph >> isCustomCommandBlockMorph [
	^true
]

{ #category : #template }
CustomCommandBlockMorph >> isFrozen [
	^ isFrozen
]

{ #category : #template }
CustomCommandBlockMorph >> isFrozen: bool [
	isFrozen := bool
]

{ #category : #testing }
CustomCommandBlockMorph >> isFunction [
	^ false
]

{ #category : #template }
CustomCommandBlockMorph >> isPartsBin [
	^isTemplate
]

{ #category : #template }
CustomCommandBlockMorph >> isTemplate [
	^isTemplate
]

{ #category : #template }
CustomCommandBlockMorph >> isTemplate: aBoolean [
	isTemplate := aBoolean
]

{ #category : #template }
CustomCommandBlockMorph >> labelMorphFor: aString [
	| s |
	isTemplate
		ifFalse: [ ^ super labelMorphFor: aString ].
	s := PhratchTranslator IsRTL
		ifTrue: [ aString reverse ]
		ifFalse: [ aString ].
	^ (BlockLabelFragmentMorph contents: s font: (PhratchFrameMorph getFont: #Label))
		color: self labelColor;
		updateFragment;
		yourself
]

{ #category : #accessing }
CustomCommandBlockMorph >> parameterNames [
	^self definition parameterNames
]

{ #category : #private }
CustomCommandBlockMorph >> privateSetUserSpec: aString [

	userSpec := aString.

]

{ #category : #accessing }
CustomCommandBlockMorph >> remove [
	|nb sm|
	nb := self nextBlock.
	(self ownerOrYourselfThatIsABlockEditorFrameMorph) isNil
		ifTrue: [
			sm := self ownerOrYourselfThatIsAPhratchScriptsMorph.
			(nb notNil & sm notNil) ifTrue: [sm addMorph: nb]]
		ifFalse: [
			sm := self owner.
			(nb notNil & sm notNil) ifTrue: [sm nextBlock: nb]].
	self delete
]

{ #category : #template }
CustomCommandBlockMorph >> removeParameter: varBlock [

	| idx |
	idx := specParts indexOf: varBlock.
	idx = 0 ifTrue: [^self].
	specParts at: idx put: ArgumentPlaceHolderMorph new.
	self updateSpecWithDnDSpec
]

{ #category : #template }
CustomCommandBlockMorph >> removeVariableTemplates [
	argMorphs do: [:each| each delete ].
	argMorphs := OrderedCollection new
]

{ #category : #'menu - change set' }
CustomCommandBlockMorph >> rename [

	| def defs choice menu |
	def := self definition.
	defs := receiver customBlocks select: [:eachDef |
		eachDef ~= def and: [
			eachDef type = def type and: [
				eachDef category = def category ]]].
	defs := defs asSortedCollection: [:x :y |
		x id <= y id].
	menu := MenuMorph new defaultTarget: self.
	defs do: [:eachDef |
		menu addIcon: (receiver lambda: eachDef id) imageForm toolTip: nil action: eachDef].
	choice := menu popUpAt: self topRight inWorld: World.
	choice ifNil: [^ self].
	self userSpec: choice userSpec
]

{ #category : #private }
CustomCommandBlockMorph >> replaceArgMorph: argMorph by: newMorph [
	| def typ pname i val |
	super replaceArgMorph: argMorph by: newMorph.
	(newMorph isExpressionArgMorph)
		ifFalse: [ ^ self ].
	def := self definition.
	i := argMorphs indexOf: newMorph.
	pname := def parameterNames at: i.
	typ := def typeOf: pname.
	val := def defaultOf: pname.
	#number = typ
		ifTrue: [ newMorph numExpression: val ]
		ifFalse: [ newMorph defaultValue: val ]
]

{ #category : #byob }
CustomCommandBlockMorph >> rightButtonMenu [

	| menu choice |
	menu := MenuMorph new defaultTarget: self.
	menu add: 'help' localized value: #presentHelpScreen.
	menu addLine.
	isTemplate 
		ifTrue: [menu add: 'change category' localized value: #editSpec ]
		ifFalse: [menu add: 'edit' localized value: #editScript].

	((owner isPhratchBlockPaletteMorph) or: [isTemplate]) ifFalse: [
		menu addLine.
		menu add: 'duplicate' localized value: #duplicate.

		(self owner isBlockMorph) ifFalse: [  "can't yet delete a blocks inside a script"
			menu add: 'delete' localized value: #delete]].

	(owner isPhratchBlockPaletteMorph) ifTrue: [
		menu add: 'delete block definition' localized value: #deleteDefinition ].

	menu localize; invokeModal.
	choice := menu selectedValue ifNil: [^ self].
	self perform: choice.

]

{ #category : #template }
CustomCommandBlockMorph >> rootForGrabOf: aMorph [

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
	(isTemplate and: [ 
		owner isProcedureHatBlockMorph]) 
			ifTrue: [^nil].

	^ super rootForGrabOf: aMorph

]

{ #category : #accessing }
CustomCommandBlockMorph >> script [
	^self definition body
]

{ #category : #accessing }
CustomCommandBlockMorph >> sequence [
	^self firstBlockList
]

{ #category : #editing }
CustomCommandBlockMorph >> setDefaultArgs [

	| a def parms typ |

	def := self definition.
	parms := def parameterNames.
	1 to: argMorphs size do: [:i |
		a := argMorphs at: i.
		(a isArgMorph) ifTrue: [
			(a isMultiArgMorph)
				ifTrue: [a addArgSlot]
				ifFalse: [
					typ := def typeOf: (parms at: i ifAbsent: [nil]).
					#number = typ
						ifTrue: [a numExpression: (def defaultOf: (parms at: i ifAbsent: [nil]))]
						ifFalse: [a defaultValue: (def defaultOf: (parms at: i ifAbsent: [nil]))]]]]
]

{ #category : #template }
CustomCommandBlockMorph >> showEdgePlaceHolders [

	isFrozen ifTrue: [^ self].
	self hideArgumentPlaceHolders.
	extraSpaces ifNil: [^ self].
	extraSpaces do: [:each |
		each extent: 0@0].
	
	specParts first appear.
	specParts last appear.

]

{ #category : #template }
CustomCommandBlockMorph >> showPlaceHoldersNear: aLabelFragment [

	| idx |
	isFrozen ifTrue: [^ self].
	self hideArgumentPlaceHolders.
	extraSpaces do: [:each |
		each extent: 0@0].
	
	idx := submorphs indexOf: aLabelFragment.
	(submorphs at: idx - 1) appear.
	(submorphs at: idx + 1) appear.

	(aLabelFragment isVariableBlockMorph)
		ifFalse: [aLabelFragment color: color twiceDarker]



]

{ #category : #byob }
CustomCommandBlockMorph >> start [
	isTemplate ifTrue: [^self].
	super start
]

{ #category : #template }
CustomCommandBlockMorph >> updateSpecWithDnDSpec [
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

	stage := receiver ownerOrYourselfThatIsAPhratchStageMorph.

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

	be := self ownerOrYourselfThatIsABlockEditorFrameMorph.

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

	sf := receiver ownerOrYourselfThatIsAPhratchFrameMorph.
	sf viewerPane categoryChanged: 'variables'.
	#none = def category ifFalse: [
		sf viewerPane categoryChanged: def category asString ]

]

{ #category : #accessing }
CustomCommandBlockMorph >> userSpec [
	^userSpec
]

{ #category : #accessing }
CustomCommandBlockMorph >> userSpec: aString [
	| cat def |

	userSpec := aString.
	isTemplate ifTrue: [self removeVariableTemplates].
	cat := self category.
	cat ifNotNil: [
		self color: (PhratchCategory blockColorFor: cat asString) ].
	def := receiver definitionFor: self id.
	def ifNil: [^ self].
	self commandSpec: def commandSpec.
	self addLabel
]
