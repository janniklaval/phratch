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
	 [aSymbol = ('record' localized, PhratchTranslator ellipsesSuffix)]) ifTrue: [
		frame ifNotNil: [^ frame newSound]].

	((#sceneNames = getOptionsSelector) and:
	 [aSymbol = ('record' localized, PhratchTranslator ellipsesSuffix)]) ifTrue: [
		frame ifNotNil: [^ frame workPane newScene]].

	((#sceneNames = getOptionsSelector) and:
	 [aSymbol = ('re-record' localized, PhratchTranslator ellipsesSuffix)]) ifTrue: [
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
			label isUnicode ifFalse: [label := label asString].
			doLocalization := (#(costumeNames soundNames varNamesMenu listVarMenu) includes: getOptionsSelector) not.
			doLocalization & label isUnicode not
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

{ #category : #accessing }
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

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd' }
AttributeArgMorph >> isBYOBattributeArg [
	^ (owner isKindOf: CommandBlockMorph) and:
	 [#(attribute:of: get: set:to:) includes: owner selector]

]

{ #category : #accessing }
AttributeArgMorph >> options [
	"Answer my set of attributes."

	| target list blockIds |
	((owner isKindOf: CommandBlockMorph) and:
	 [owner selector = #getAttribute:of:]) ifFalse: [^ #()].

	((owner argumentAt: 2) isKindOf: SpriteArgMorph)
		ifFalse: [^ #()].

	(target := (owner argumentAt: 2) evaluate) ifNil: [^ #()].
	(target isKindOf: ScriptablePhratchMorph) ifFalse: [^ #()].
	target varNames size > 0
		ifTrue: [list := target attributeNames, #(-), target varNames]
		ifFalse: [list := target attributeNames].
	blockIds := target allLocalBlockIds.
	blockIds isEmpty ifFalse: [
		list := list,  #(-), blockIds ].
	^ list

]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd' }
AttributeArgMorph >> presentAttributesMenu [
	"Pop up a menu of built-in choices for every sprite/stage object."

	| optionList menu selection option advancedOptions |

	(#(get: set:to:) includes: owner selector) ifTrue: [
		^ self presentUniversalAttributesMenu].

	optionList := #('x position' 'y position' 'direction' 'costume #' 'size' 'volume').
	menu := MenuMorph new defaultTarget: self.
	optionList do: [:sym |
		sym isUnicode not
			ifTrue: [option := sym localized asUTF8]
			ifFalse: [option := sym].
		menu add: (UTF8 withAll: option) asMacRoman
			target: self 
			selector: #choice:
			argument: sym].

	menu addLine.
	advancedOptions :=  #('name' 'prototype' 'owner' 'parts').
	advancedOptions do: [:sym |
		sym isUnicode not
			ifTrue: [option := sym localized asUTF8]
			ifFalse: [option := sym].
		menu add: (UTF8 withAll: option) asMacRoman
			target: self 
			selector: #choice:
			argument: sym].

	menu popUpInWorld
]

{ #category : #accessing }
AttributeArgMorph >> presentMenu [
	"Pop up a menu of choices."

	| optionList doLocalization menu selection option target blockIds |
	self isBYOBattributeArg
		ifTrue: [^ self presentAttributesMenu].
	optionList := #(''), self options.
	optionList size = 0 ifTrue: [^ self].
	doLocalization := (#(costumeNames soundNames varNamesMenu listVarMenu) includes: getOptionsSelector) not.
	menu := MenuMorph new defaultTarget: self.
	target := self target.
	target ifNil: [^ self].
	blockIds := target allLocalBlockIds.
	optionList do: [:sym |
		'-' = sym
			ifTrue: [menu addLine]
			ifFalse: [
				doLocalization & sym isUnicode not
					ifTrue: [option := sym localized asUTF8]
					ifFalse: [option := sym].
				((#(hookupSensorNames hookupBooleanSensorNames) includes: getOptionsSelector) and:
				 [(#(connected resistance) includes: sym)])
					ifTrue: [#(A B C D) do: [:c |
						self owner isBooleanReporter
							ifFalse: [
								menu
								 	add: (option, '-', c)
									target: self 
									selector: #choice:
									argument: (option, '-', c)]
							ifTrue: [
								menu
								 	add: (c asUTF8, ' ', option)
									target: self 
									selector: #choice:
									argument: (c, ' ' ,sym)]
								]]
					ifFalse: [ 
						(blockIds includes: sym)
							ifTrue: [ menu addIcon: (target lambda: sym) imageForm
										toolTip: nil
										action: sym ]
							ifFalse: [
								menu
								 	add: (UTF8 withAll: option)
									target: self 
									selector: #choice:
									argument: (sym)]]]].
	menu popUpInWorld
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd' }
AttributeArgMorph >> presentUniversalAttributesMenu [
	"Pop up a menu of built-in choices for every sprite/stage object."

	| oi menu entry option selection catz actions pairs val |

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
			entry isUnicode not
				ifTrue: [option := entry localized asUTF8]
				ifFalse: [option := entry].
			menu add: (UTF8 withAll: option) asMacRoman
				target: self 
				selector: #universalAttributeChoice:
				argument: tuple second]].
		
	menu popUpInWorld
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd' }
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

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd' }
AttributeArgMorph >> universalAttributeChoice: aSymbol [
	"Update the toggle button when an argument is changed within a block."

	| oi frame palette block label |
	frame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	oi := owner receiver objectInterface.

	choice := aSymbol.
	choice = #null
		ifTrue: [label := '']
		ifFalse: [label := (oi at: aSymbol) value fourth].

	labelMorph isHidden: false.
	label isUnicode ifFalse: [label := label asString].
	label isUnicode not
		ifTrue:[labelMorph contents: label localized]
		ifFalse:[labelMorph contents: label].
	labelMorph position: self position + borderWidth + (3 @ -1).
	self extent: (labelMorph extent + (16@2) + borderWidth).

	menuIconMorph position: (self right - borderWidth - 10)@(self top + borderWidth + 4).

	(owner isKindOf: BlockMorph) ifTrue: [
		(owner respondsTo: #addLabel)
			ifTrue: [owner addLabel]
			ifFalse: [owner fixBlockLayout]].

	(palette := self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph) ifNil: [^ self].
	(block := self ownerOrYourselfThatIsA: BlockMorph) ifNil: [^ self].

	block isReporter ifTrue: [palette updateWatcherButtonsForFrame: frame].

]
