Class {
	#name : #PaletteFrameHeadMorph,
	#superclass : #Morph,
	#instVars : [
		'basics',
		'variables',
		'classes',
		'messages',
		'choice',
		'lastMsgChoice',
		'frame',
		'methodsClass'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'as yet unclassified' }
PaletteFrameHeadMorph >> adjustToClass: aClass [
	(aClass isKindOf: Metaclass)
		ifTrue: [
			(#instanceVars = choice)
				ifTrue: [choice := #variables]]
]

{ #category : #'to clean later' }
PaletteFrameHeadMorph >> allClasses [
	choice := #allClasses.
	self refresh
]

{ #category : #private }
PaletteFrameHeadMorph >> arrangePanes [

	| toggleWidth |
	toggleWidth := self width - 6 // 2.

	basics 
		width: toggleWidth;
		position: self topLeft + 2;
		fitMorphs.

	messages 
		width: toggleWidth;
		position: basics left @ (basics bottom + 2);
		fitMorphs.

	variables 
		width: toggleWidth;
		position: (basics right + 2) @ (basics top);
		fitMorphs.

	classes 
		width: toggleWidth;
		position: (basics right + 2) @ (variables bottom + 2);
		fitMorphs.

	self height: messages bottom + 2 - self top
]

{ #category : #accessing }
PaletteFrameHeadMorph >> basics [
	choice := #basics.
	self refresh
]

{ #category : #initialization }
PaletteFrameHeadMorph >> buildPanes [

	basics := ElementsToggleButtonMorph new
				target: self;
				selector: #basics;
				label: 'Basics';
				onColor: Color green twiceDarker darker offColor: color; 
		yourself.

	variables := ElementsDoubleToggleMorph new
				target: self;
				selector: #variables;
				chooser: #varMenu;
				label: 'Variables';
				onColor: Color blue darker offColor: color; 
		yourself.

	classes := ElementsDoubleToggleMorph new
				target: self;
				selector: #classes;
				chooser: #classMenu;
				label: 'Classes';
				onColor: Color magenta darker darker darker offColor: color; 
		yourself.

	messages := ElementsDoubleToggleMorph new
				target: self;
				selector: #messages;
				chooser: #chooseClassForMethods;
				label: 'Messages';
				onColor: Color orange darker darker offColor: color; 
		yourself.

	self
		addMorph: basics;
		addMorph: variables;
		addMorph: classes;
		addMorph: messages

]

{ #category : #accessing }
PaletteFrameHeadMorph >> choice [
	^choice
]

{ #category : #'as yet unclassified' }
PaletteFrameHeadMorph >> chooseClassForMethods [
	| menu packages pkg pkgMenu catMenu superc subc smenu currentClass |
	self messages.
	packages := Dictionary new.
	SystemOrganization categories asSortedCollection
		do: [ :cat | 
			pkg := (cat asString findTokens: #-) first.
			(packages includesKey: pkg)
				ifFalse: [ packages at: pkg put: OrderedCollection new ].
			(packages at: pkg) add: cat ].
	currentClass := self currentMethodsClass.
	superc := currentClass allSuperclasses.
	subc := currentClass allSubclasses.
	menu := MenuMorph new.
	menu defaultTarget: self.
	menu add: 'current class' translated action: #currentMessages.
	currentClass isMeta
		ifTrue: [ menu add: 'instance side' selector: #setMethodsClass: argument: currentClass theNonMetaClass ]
		ifFalse: [ menu add: 'class side' selector: #setMethodsClass: argument: currentClass class ].
	superc isEmpty
		ifFalse: [ 
			smenu := MenuMorph new defaultTarget: self.
			superc do: [ :eachClass | smenu add: eachClass printString selector: #setMethodsClass: argument: eachClass ].
			menu add: 'superclasses' translated subMenu: smenu ].
	subc isEmpty
		ifFalse: [ 
			smenu := MenuMorph new defaultTarget: self.
			subc do: [ :eachClass | smenu add: eachClass printString selector: #setMethodsClass: argument: eachClass ].
			menu add: 'subclasses' translated subMenu: smenu ].
	menu addLine.
	packages keys asSortedCollection
		do: [ :eachPkg | 
			pkgMenu := MenuMorph new.
			(packages at: eachPkg) asSortedCollection
				do: [ :cat | 
					catMenu := self menuForCategory: cat.
					pkgMenu add: (SyntaxElementMorph wordsFrom: cat asString) subMenu: catMenu ].
			menu add: eachPkg subMenu: pkgMenu ].
	menu popUpInWorld 
]

{ #category : #'as yet unclassified' }
PaletteFrameHeadMorph >> classMenu [
	| menu |
	menu := MenuMorph new.
	menu defaultTarget: self.
	menu defaultTarget: self.
	menu add: 'in package' translated action: #currentPackageClasses.
	menu add: 'all' translated action: #allClasses.
	menu popUpInWorld 
]

{ #category : #'as yet unclassified' }
PaletteFrameHeadMorph >> classVars [
	choice := #classVars.
	self refresh
]

{ #category : #accessing }
PaletteFrameHeadMorph >> classes [
	choice := #currentPackageClasses.
	self refresh
]

{ #category : #'as yet unclassified' }
PaletteFrameHeadMorph >> currentMessages [
	choice := #currentMessages.
	lastMsgChoice := choice.
	self refresh
]

{ #category : #'as yet unclassified' }
PaletteFrameHeadMorph >> currentMethodsClass [

	^(self ownerThatIsA: ElementsPaletteFrameMorph) currentMethodsClass.
	
]

{ #category : #'as yet unclassified' }
PaletteFrameHeadMorph >> currentPackageClasses [
	choice := #currentPackageClasses.
	self refresh
]

{ #category : #accessing }
PaletteFrameHeadMorph >> frame: aMorph [
	frame := aMorph
]

{ #category : #'as yet unclassified' }
PaletteFrameHeadMorph >> globalVars [
	choice := #globalVars.
	self refresh
]

{ #category : #initialize }
PaletteFrameHeadMorph >> initialize [
	super initialize.
	choice := #basics.
	lastMsgChoice := #currentMessages.
	color := Color gray.
	self width: 180.
	self buildPanes.
	self arrangePanes.
	self refresh
]

{ #category : #'as yet unclassified' }
PaletteFrameHeadMorph >> instanceVars [
	choice := #instanceVars.
	self refresh
]

{ #category : #'as yet unclassified' }
PaletteFrameHeadMorph >> menuForCategory: categoryName [

	|menu list submenu |
	menu := MenuMorph new
				defaultTarget: self.
	list := SystemOrganization listAtCategoryNamed: categoryName.
	list asSortedCollection do: [:eachClass|
		submenu := MenuMorph new defaultTarget: self.
		submenu add: 'instance' selector: #setMethodsClass: argument: (Smalltalk classNamed: eachClass).
		submenu add: 'class' selector: #setMethodsClass: argument: (Smalltalk classNamed: eachClass) class.
		menu add: (SyntaxElementMorph wordsFrom: eachClass asString) subMenu: submenu].
	^menu

]

{ #category : #accessing }
PaletteFrameHeadMorph >> messages [
	choice := lastMsgChoice.
	self refresh
]

{ #category : #accessing }
PaletteFrameHeadMorph >> methodsClass [
	^methodsClass
]

{ #category : #private }
PaletteFrameHeadMorph >> refresh [
	basics off.
	classes off.
	messages off.
	variables off.

	(#basics = choice) ifTrue: [
		basics on ].
	(#(allClasses currentPackageClasses) includes: choice) ifTrue: [
		classes on ].
	(#(variables instanceVars classVars globalVars) includes: choice) ifTrue: [
		variables on ].
	(#(currentMessages methodsClass) includes: choice) ifTrue: [
		messages on ].

	frame ifNotNil: [frame refresh]
]

{ #category : #'as yet unclassified' }
PaletteFrameHeadMorph >> setMethodsClass: aClass [
	choice := #methodsClass.
	lastMsgChoice := choice.
	methodsClass := aClass.
	self refresh	
]

{ #category : #'as yet unclassified' }
PaletteFrameHeadMorph >> varMenu [
	| menu isClassSide |
	menu := MenuMorph new.
	menu defaultTarget: self.
	isClassSide := frame currentClass isKindOf: Metaclass.
	isClassSide
		ifFalse: [ menu add: 'instance' translated action: #instanceVars ].
	menu add: 'class' translated action: #classVars.
	menu add: 'globals' translated action: #globalVars.
	menu popUpInWorld
]

{ #category : #accessing }
PaletteFrameHeadMorph >> variables [
	choice := #variables.
	self refresh
]
