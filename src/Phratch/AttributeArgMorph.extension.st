Extension { #name : #AttributeArgMorph }

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd' }
AttributeArgMorph >> isBYOBattributeArg [
	^ (owner isKindOf: CommandBlockMorph) and:
	 [#(attribute:of: get: set:to:) includes: owner selector]

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

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd' }
AttributeArgMorph >> universalAttributeChoice: aSymbol [
	"Update the toggle button when an argument is changed within a block."

	| oi frame palette block label |
	frame := self ownerOrYourselfThatIsA: ScratchFrameMorph.
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
