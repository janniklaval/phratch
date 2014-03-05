Class {
	#name : #AttributeArgMorph,
	#superclass : #ChoiceArgMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #accessing }
AttributeArgMorph >> choice: aSymbol [
	"Update the toggle button when an argument is changed within a block."

	| frame palette block doLocalization label target |

	(ScriptablePhratchMorph new objectInterface keys includes: aSymbol)
		ifTrue: [^ self universalAttributeChoice: aSymbol].

	frame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	((#soundNames = getOptionsSelector) and:
	 [aSymbol = ('record' localized, '...')]) ifTrue: [
		frame ifNotNil: [^ frame newSound]].

	((#sceneNames = getOptionsSelector) and:
	 [aSymbol = ('record' localized, '...')]) ifTrue: [
		frame ifNotNil: [^ frame workPane newScene]].

	((#sceneNames = getOptionsSelector) and:
	 [aSymbol = ('re-record' localized, '...')]) ifTrue: [
		frame ifNotNil: [^ frame workPane rerecordScene]].

	choice := label := aSymbol.
	aSymbol = #null ifTrue: [
		label := ''].

	target := self target.
	((target isKindOf: ScriptablePhratchMorph) and: [target allLocalBlockIds includes: aSymbol])
		ifTrue: [
			labelMorph isHidden: true.
			self extent: (target lambda: aSymbol) imageForm extent + (14@2)]
		ifFalse: [
			labelMorph isHidden: false.
			label := label asString.
			doLocalization := (#(costumeNames soundNames varNamesMenu listVarMenu) includes: getOptionsSelector) not.
			doLocalization
				ifTrue:[labelMorph contents: label localized]
				ifFalse:[labelMorph contents: label].
			labelMorph position: self position + borderWidth + (3 @ -1).
			self extent: (labelMorph extent + (16@2) + borderWidth) ].

	menuIconMorph position: (self right - borderWidth - 10)@(self top + borderWidth + 4).

	(owner isKindOf: BlockMorph) ifTrue: [
		(owner respondsTo: #addLabel)
			ifTrue: [owner addLabel]
			ifFalse: [owner fixBlockLayout]].

	(palette := self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph) ifNil: [^ self].
	(block := self ownerOrYourselfThatIsA: BlockMorph) ifNil: [^ self].

	block isReporter ifTrue: [palette updateWatcherButtonsForFrame: frame].

]

{ #category : #drawing }
AttributeArgMorph >> drawOn: aCanvas [

	| target |
	super drawOn: aCanvas.
	self isBYOBattributeArg
		ifTrue: [^ self].
	target := self target.
	(target respondsTo: #allLocalBlockIds)
		ifFalse: [^ self ].
	(target allLocalBlockIds includes: choice)
		ifFalse: [^self ]
		ifTrue: [
			aCanvas paintImage: (target lambda: choice) imageForm at: self position + (1@1) ]
]

{ #category : #byob }
AttributeArgMorph >> isBYOBattributeArg [
	^ (owner isKindOf: CommandBlockMorph) and:
	 [#(attribute:of: get: set:to:) includes: owner selector]

]

{ #category : #accessing }
AttributeArgMorph >> options [
	"Answer my set of attributes."

	| target list blockIds |
	((owner isKindOf: CommandBlockMorph) and: [ owner selector = #getAttribute:of: ])
		ifFalse: [ ^ #() ].
	((owner argumentAt: 2) isKindOf: SpriteArgMorph)
		ifFalse: [ ^ #() ].
	(target := (owner argumentAt: 2) evaluate) ifNil: [ ^ #() ].
	(target isKindOf: ScriptablePhratchMorph)
		ifFalse: [ ^ #() ].
	list := target varNames size > 0
		ifTrue: [ target attributeNames , #(#-) , target varNames ]
		ifFalse: [ target attributeNames ].
	blockIds := target allLocalBlockIds.
	blockIds isEmpty
		ifFalse: [ list := list , #(#-) , blockIds ].
	^ list
]

{ #category : #byob }
AttributeArgMorph >> presentAttributesMenu [
	"Pop up a menu of built-in choices for every sprite/stage object."

	| optionList menu option advancedOptions |

	(#(get: set:to:) includes: owner selector) ifTrue: [
		^ self presentUniversalAttributesMenu].

	optionList := #('x position' 'y position' 'direction' 'costume #' 'size' 'volume').
	menu := MenuMorph new defaultTarget: self.
	optionList do: [:sym |
		option := sym localized.
		menu add: (String withAll: option)
			target: self 
			selector: #choice:
			argument: sym].

	menu addLine.
	advancedOptions :=  #('name' 'prototype' 'owner' 'parts').
	advancedOptions do: [:sym |
		option := sym localized.
		menu add: (String withAll: option)
			target: self 
			selector: #choice:
			argument: sym].

	menu popUpInWorld
]

{ #category : #accessing }
AttributeArgMorph >> presentMenu [
	"Pop up a menu of choices."

	| optionList doLocalization menu option target blockIds |
	self isBYOBattributeArg
		ifTrue: [ ^ self presentAttributesMenu ].
	optionList := #('') , self options.
	optionList size = 0
		ifTrue: [ ^ self ].
	doLocalization := (#(#costumeNames #soundNames #varNamesMenu #listVarMenu) includes: getOptionsSelector) not.
	menu := MenuMorph new defaultTarget: self.
	target := self target.
	target ifNil: [ ^ self ].
	blockIds := target allLocalBlockIds.
	optionList
		do: [ :sym | 
			'-' = sym
				ifTrue: [ menu addLine ]
				ifFalse: [ 
					option := doLocalization
						ifTrue: [ sym localized ]
						ifFalse: [ sym ].
							(blockIds includes: sym)
								ifTrue: [ menu addIcon: (target lambda: sym) imageForm toolTip: nil action: sym ]
								ifFalse: [ 
									menu
										add: (String withAll: option)
										target: self
										selector: #choice:
										argument: sym ]  ] ].
	menu popUpInWorld
]

{ #category : #byob }
AttributeArgMorph >> presentUniversalAttributesMenu [
	"Pop up a menu of built-in choices for every sprite/stage object."

	| oi menu entry option catz actions pairs val |

	catz := #(sprite motion looks effects sound pen relationship).
	oi := owner receiver objectInterface.
	actions := Dictionary new.

	catz do: [:cat |
		pairs := OrderedCollection new.
		oi keysDo: [:key |
			val := (oi at: key) value.
			val first = cat ifTrue: [
				pairs add: {val fourth. key}]].
		actions at: cat put: (pairs asSortedCollection:[:x :y |
					x first <= y first])].

	menu := MenuMorph new defaultTarget: self.

	"first, add empty slot"
	menu add: ''
		target: self 
		selector: #universalAttributeChoice:
		argument: #null.

	catz do: [:cat |
		cat = catz first ifFalse: [
			menu addLine].
		(actions at: cat) do: [:tuple |
			entry := tuple first.
			option := entry localized.
			menu add: (String withAll: option)
				target: self 
				selector: #universalAttributeChoice:
				argument: tuple second]].
		
	menu popUpInWorld
]

{ #category : #byob }
AttributeArgMorph >> refresh [
	self choice: choice
]

{ #category : #accessing }
AttributeArgMorph >> target [
	owner ifNil: [^nil].
	(#(attribute:of: get: set:to:) includes: owner selector)
		ifTrue: [^ nil].

	owner selector = #getAttribute:of: ifTrue: [
		((owner argumentAt: 2) isKindOf: SpriteArgMorph) ifFalse: [
			^ nil]].

	^(owner argumentAt: 2) evaluate.

]

{ #category : #byob }
AttributeArgMorph >> universalAttributeChoice: aSymbol [
	"Update the toggle button when an argument is changed within a block."

	| oi frame palette block label |
	frame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	oi := owner receiver objectInterface.
	choice := aSymbol.
	label := choice = #null
		ifTrue: [ '' ]
		ifFalse: [ (oi at: aSymbol) value fourth ].
	labelMorph isHidden: false.
	label := label asString.
	labelMorph contents: label localized.
	labelMorph position: self position + borderWidth + (3 @ -1).
	self extent: labelMorph extent + (16 @ 2) + borderWidth.
	menuIconMorph position: (self right - borderWidth - 10) @ (self top + borderWidth + 4).
	(owner isKindOf: BlockMorph)
		ifTrue: [ 
			(owner respondsTo: #addLabel)
				ifTrue: [ owner addLabel ]
				ifFalse: [ owner fixBlockLayout ] ].
	(palette := self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph) ifNil: [ ^ self ].
	(block := self ownerOrYourselfThatIsA: BlockMorph) ifNil: [ ^ self ].
	block isReporter
		ifTrue: [ palette updateWatcherButtonsForFrame: frame ]
]
