Class {
	#name : #MethodChooserMorph,
	#superclass : #ClassChooserMorph,
	#instVars : [
		'selector'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'as yet unclassified' }
MethodChooserMorph >> addCategory [
	| ans |
	ans := UIManager default request: 'new category:' initialAnswer: ''.
	(ans size > 0) ifFalse: [^self].
	class organization addCategory: ans
]

{ #category : #'as yet unclassified' }
MethodChooserMorph >> chooseMethod [

	|menu list|
	menu := MenuMorph new.
	menu defaultTarget: self.
	selector ifNotNil: [
		menu add: 'put method into category...' action: #reclassify.
		menu add: 'add category...' action: #addCategory.
		menu add: 'remove empty categories' action: #removeEmptyCategories.
		menu addLine ].
	list := class organization categories asSortedCollection.
	list do: [:each|
		menu add: each asString subMenu: (self menuForCategory: each)].
	menu popUpAt: button center x @ (self bottom + 5) forHand: World activeHand
]

{ #category : #'as yet unclassified' }
MethodChooserMorph >> class: aClass [
	class := aClass. 
]

{ #category : #'as yet unclassified' }
MethodChooserMorph >> initialize [
	super initialize.
	class := Object.
	selector := #yourself.
	button selector: #chooseMethod
	
]

{ #category : #'as yet unclassified' }
MethodChooserMorph >> menuForCategory: categoryName [

	|menu list |
	menu := MenuMorph new
				defaultTarget: self.
	list := class organization listAtCategoryNamed: categoryName.
	list isEmpty ifTrue: [
		menu add: 'yourself' selector: #selector: argument: #yourself.
		^menu ].
	list asSortedCollection do: [:each|
		menu add: (self wordsFrom: each asString) selector: #selector: argument: each].
	^menu

]

{ #category : #'as yet unclassified' }
MethodChooserMorph >> mouseDown: evt [
	self chooseMethod
]

{ #category : #'as yet unclassified' }
MethodChooserMorph >> reclassify [
	class organization letUserReclassify: selector
]

{ #category : #'as yet unclassified' }
MethodChooserMorph >> removeEmptyCategories [

	class organization removeEmptyCategories
]

{ #category : #'as yet unclassified' }
MethodChooserMorph >> selector [
	^selector
]

{ #category : #'as yet unclassified' }
MethodChooserMorph >> selector: aSelector [

	selector := aSelector.
	label ifNil: [
		label := StringMorph contents: '' font: self labelFont.
		label color: self labelColor.
		self addMorphFront: label ].
	aSelector isNil
		ifTrue: [ label contents: '' ]
		ifFalse: [ label contents: (self wordsFrom: selector asString)].
	self fitMorphs.

	frame ifNotNil: [frame selectMethod: aSelector]

]
