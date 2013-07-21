Class {
	#name : #ClassChooserMorph,
	#superclass : #Morph,
	#instVars : [
		'class',
		'label',
		'button',
		'frame'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'as yet unclassified' }
ClassChooserMorph >> chooseClass [

	|menu list packages pkg pkgMenu catMenu |
	packages := Dictionary new.
	SystemOrganization categories asSortedCollection do: [:cat |
		pkg := (cat asString findTokens: #( $- )) first.
		(packages includesKey: pkg)
			ifFalse: [ packages at: pkg put: OrderedCollection new].
		(packages at: pkg) add: cat].

	menu := MenuMorph new.
	packages keys asSortedCollection do: [:eachPkg |
		pkgMenu := MenuMorph new.
		(packages at: eachPkg) asSortedCollection do: [: cat |
			catMenu := self menuForCategory: cat.
			pkgMenu add: (self wordsFrom: cat asString)
					subMenu: catMenu ].
		"pkgMenu add: (self wordsFrom: eachPkg asString)
				subMenu: pkgMenu."
		menu add: eachPkg subMenu: pkgMenu ].



"
	list := SystemOrganization categories asSortedCollection.
	list do: [:each|
		menu add: (self wordsFrom: each asString) subMenu: (self menuForCategory: each)].
"
	menu popUpAt: button center x @ (self bottom + 5) forHand: World activeHand
]

{ #category : #'as yet unclassified' }
ClassChooserMorph >> class: aClass [
	| classToSet |
	classToSet := aClass.

	frame ifNotNil: [
		(frame currentSide = #class)
		& (aClass isKindOf: Metaclass) not
			ifTrue: [ classToSet := aClass class ]].

	class = classToSet ifTrue: [^self].
	class := classToSet.
	label ifNil: [
		label := StringMorph contents: '' font: self labelFont.
		label color: self labelColor.
		self addMorphFront: label ].
	label contents: (self wordsFrom: class name asString).
	self fitMorphs.

	frame ifNotNil: [
		frame selectClass: class]
]

{ #category : #'as yet unclassified' }
ClassChooserMorph >> fitMorphs [
	button extent: (label height @ label height) * 2//3.
	button position: self left @ self top + (label height - button height // 2).
	label position: (button right + (button width // 3)) @ self top.
	self extent: label bottomRight - self position
]

{ #category : #'as yet unclassified' }
ClassChooserMorph >> frame: aMorph [
	frame := aMorph
]

{ #category : #'as yet unclassified' }
ClassChooserMorph >> handlesMouseDown: evt [
	^ true

]

{ #category : #'as yet unclassified' }
ClassChooserMorph >> initialize [
	super initialize.
	self color: Color gray.
	self addMorph: (button := TriangleButtonMorph new
				target: self;
				selector: #chooseClass)
	
]

{ #category : #'as yet unclassified' }
ClassChooserMorph >> labelColor [
	^Color white
]

{ #category : #'as yet unclassified' }
ClassChooserMorph >> labelFont [
	^StrikeFont fontName: 'VerdanaBold' size: 12
]

{ #category : #'as yet unclassified' }
ClassChooserMorph >> menuForCategory: categoryName [

	|menu list |
	menu := MenuMorph new
				defaultTarget: self.
	list := SystemOrganization listAtCategoryNamed: categoryName.
	list asSortedCollection do: [:each|
		menu add: (self wordsFrom: each asString) selector: #class: argument: (Smalltalk classNamed: each)].
	^menu

]

{ #category : #'as yet unclassified' }
ClassChooserMorph >> mouseDown: evt [
	self chooseClass
]

{ #category : #'as yet unclassified' }
ClassChooserMorph >> selectedClass [
	^class
]

{ #category : #'as yet unclassified' }
ClassChooserMorph >> wordsFrom: camelCase [
	^SyntaxElementMorph wordsFrom: camelCase

]
