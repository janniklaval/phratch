Class {
	#name : #ElementsPaletteFrameMorph,
	#superclass : #Morph,
	#instVars : [
		'header',
		'palette',
		'editorFrame',
		'currentClass'
	],
	#category : #'Phratch-BYOB-Elements-UI'
}

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> acceptDroppingMorph: aMorph event: evt [
	"This message is sent when a morph is dropped onto a morph that has agreed to accept the dropped morph by responding 'true' to the wantsDroppedMorph:Event: message. This default implementation just adds the given morph to the receiver."

	aMorph delete

]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> arrangePanes [
	header position: self position;
		width: self width;
		arrangePanes.
	palette position: self left @ header bottom;
		extent: self width @ (self height - header height)
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> buildPanes [
	header := PaletteFrameHeadMorph new frame: self.
	palette := ElementsScrollFrameMorph new
				color: Color gray;
				borderColor: Color gray.
	self
		addMorph: header;
		addMorph: palette.
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> class: aClass [
	currentClass := aClass.
	header adjustToClass: currentClass.
	self refresh
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> classMenu [
	|menu|
	menu := MenuMorph new defaultTarget: self.
	menu add: 'create a subclass...' action: #createSubclass.
	menu add: 'remove a class...' action: #removeClass.
	^menu
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> classVarMenu [
	|menu|
	menu := MenuMorph new defaultTarget: self.
	menu add: 'add a class variable...' action: #createClassVar.
	menu add: 'remove a variable...' action: #removeClassVar.
	^menu
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> contextMenu [
	| choice |
	choice := header choice.
	(#basics = choice) ifTrue: [^nil ].

	(#(allClasses #currentPackageClasses) includes: choice) ifTrue: [
		^self classMenu].

	(#variables = choice) ifTrue: [
		(currentClass isMeta)
			ifTrue: [ ^self classVarMenu]
			ifFalse: [ ^self instanceVarMenu ]].

	(#instanceVars = choice) ifTrue: [^self instanceVarMenu].

	(#classVars = choice) ifTrue: [^self classVarMenu].

	(#globalVars = choice) ifTrue: [ ^self globalVarMenu].

	(#currentMessages = choice) ifTrue: [^self methodMenu].

	(#methodsClass = choice) ifTrue: [^nil ].
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> createClassVar [
	|varName current|
	currentClass isMeta
		ifTrue: [current := currentClass theNonMetaClass ]
		ifFalse: [current := currentClass ].

	varName := UIManager request: 'variable name:' initialAnswer: ''.
	varName isEmpty ifTrue: [^self].
	current addClassVarName: varName.
	self refresh		
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> createGlobalVar [
	|varName |

	varName := UIManager request: 'variable name:' initialAnswer: ''.
	varName isEmpty ifTrue: [^self].
	varName := SyntaxElementMorph classNameFrom: varName.
	(Smalltalk includesKey: varName asSymbol)
		ifTrue: [^self inform: varName, ' is already in use'].
	Smalltalk at: varName asSymbol put: nil.
	self refresh		
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> createInstVar [
	|varName current|
	currentClass isMeta
		ifTrue: [current := currentClass theNonMetaClass ]
		ifFalse: [current := currentClass ].

	varName := UIManager request: 'variable name:' initialAnswer: ''.
	varName isEmpty ifTrue: [^self].
	varName := SyntaxElementMorph objectNameFrom: varName.
	current addInstVarName: varName.
	self refresh		
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> createSubclass [
	|className categoryName current newClass|
	currentClass isMeta
		ifTrue: [current := currentClass theNonMetaClass ]
		ifFalse: [current := currentClass ].

	className := UIManager request: 'class name:' initialAnswer: ''.
	className isEmpty ifTrue: [^self].
	categoryName := UIManager request: 'category:' initialAnswer: 'UserObjects'.
	categoryName isEmpty ifTrue: [^self].

	className := SyntaxElementMorph classNameFrom: className.

	newClass := current subclass: className asSymbol
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: categoryName.

	editorFrame selectClass: newClass

		
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> currentClass [
	^currentClass
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> currentMethodsClass [
	
	| name |
	name := palette contents submorphs last contents.
	(name endsWith: ' class') ifTrue: [
		name := (name reversed copyFrom: 6 to: name size) reversed.
		name := name reject: [:c| c = $ ].
		^(Smalltalk at: name asSymbol) class ].

	name := name reject: [:c| c = $ ].
	^Smalltalk at: name asSymbol
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> editorFrame: aMorph [
	editorFrame := aMorph
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> globalVarMenu [
	|menu|
	menu := MenuMorph new defaultTarget: self.
	menu add: 'add a global variable...' action: #createGlobalVar.
	menu add: 'remove a variable...' action: #removeGlobalVar.
	^menu
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> handlesMouseDown: evt [
	"Return true if this morph wants to receive mouseDown events (i.e., mouseDown:, mouseMove:, mouseUp:). The default response is false; subclasses that implement mouse messages should override this to return true." 

	^ true
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> initialize [
	super initialize.
	currentClass := Object.
	self extent: 180 @ 400.
	self buildPanes.
	self arrangePanes.
	self refresh
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> instanceVarMenu [
	|menu|
	menu := MenuMorph new defaultTarget: self.
	menu add: 'add an instance variable...' action: #createInstVar.
	menu add: 'remove a variable...' action: #removeInstVar.
	^menu
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> invokeContextMenu [
	|m |
	m := self contextMenu.
	m ifNotNil: [m popUpNearHand]
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> methodMenu [
	|menu|
	menu := MenuMorph new defaultTarget: self.
	menu add: 'remove a method...' action: #removeMethod.
	^menu
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> mouseDown: evt [
	"Handle a mouse down event."

	evt rightButtonPressed
		ifTrue: [ ^self invokeContextMenu].

]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> refresh [
	| choice |
	choice := header choice.
	(#basics = choice) ifTrue: [
		palette contents: ElementPaletteMorph basics ].

	(#allClasses = choice) ifTrue: [
		palette contents: ElementPaletteMorph classes ].

	(#currentPackageClasses = choice) ifTrue: [
		(currentClass isKindOf: Metaclass)
			ifTrue: [ palette contents: (ElementPaletteMorph currentPackageClasses: currentClass allInstances first) ]
			ifFalse: [palette contents: (ElementPaletteMorph currentPackageClasses: currentClass) ]].


	(#variables = choice) ifTrue: [
		(currentClass isKindOf: Metaclass)
			ifTrue: [ palette contents: (ElementPaletteMorph classVarsFor: currentClass allInstances first) ]
			ifFalse: [palette contents: (ElementPaletteMorph instVarsFor: currentClass) ]].

	(#instanceVars = choice) ifTrue: [
		(currentClass isKindOf: Metaclass)
			ifTrue: [palette contents: (ElementPaletteMorph instVarsFor: currentClass allInstances first) ]
			ifFalse: [palette contents: (ElementPaletteMorph instVarsFor: currentClass) ]].

	(#classVars = choice) ifTrue: [
		(currentClass isKindOf: Metaclass)
			ifTrue: [palette contents: (ElementPaletteMorph classVarsFor: currentClass allInstances first) ]
			ifFalse: [palette contents: (ElementPaletteMorph classVarsFor: currentClass) ]].

	(#globalVars = choice) ifTrue: [
		palette contents: (ElementPaletteMorph globals) ].



	(#currentMessages = choice) ifTrue: [
		palette contents: (ElementPaletteMorph messagesFor: currentClass) ].

	(#methodsClass = choice) ifTrue: [
		palette contents: (ElementPaletteMorph messagesFor: header methodsClass) ].
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> removeClass [
	| class |
	class := self selectClass.
	class ifNotNil: [
		class := Smalltalk at: class.
		self removeClass: class ]
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> removeClass: aClass [

		(editorFrame currentClass = aClass)
			ifTrue: [editorFrame selectClass: Object ].
		aClass removeFromSystem.
		self refresh 
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> removeClassVar [
	| var |
	var := self selectClassVar.
	var ifNotNil: [
		self currentClass removeClassVarName: var.
		self refresh ]
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> removeGlobalVar [
	| var |
	var := self selectGlobalVar.
	var ifNotNil: [
		Smalltalk removeKey: var.
		self refresh ]
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> removeInstVar [
	| var |
	var := self selectInstVar.
	var ifNotNil: [
		self currentClass removeInstVarName: var.
		self refresh ]
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> removeMethod [
	| sel |
	sel := self selectSelector.
	sel ifNotNil: [
		self currentClass removeSelector: sel.
		self refresh ]
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> selectClass [

	| menu |
	menu := MenuMorphNG new defaultTarget: self.
	Smalltalk classNames do: [:each |
		menu add: each printString value: each].
	menu popUpInWorld.
	^ menu selectedValue.
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> selectClassVar [

	| menu |
	menu := MenuMorphNG new defaultTarget: self.
	currentClass classVarNames asSortedCollection do: [:each |
		menu add: each printString value: each].
	menu popUpInWorld.
	^ menu selectedValue.

]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> selectGlobalVar [

	| menu |
	menu := MenuMorphNG new defaultTarget: self.
	(Smalltalk keys reject: [:key| Smalltalk classNames includes: key]) asSortedCollection do: [:each |
		menu add: each printString value: each].
	menu popUpInWorld.
	^ menu selectedValue.
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> selectInstVar [

	| menu |
	menu := MenuMorphNG new defaultTarget: self.
	currentClass instVarNames asSortedCollection do: [:each |
		menu add: each printString value: each].
	menu popUpInWorld.
	^ menu selectedValue.

]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> selectSelector [

	| menu |
	menu := MenuMorphNG new defaultTarget: self.
	currentClass selectors asSortedCollection do: [:each |
		menu add: each printString value: each].
	menu popUpInWorld.
	^ menu selectedValue.
]

{ #category : #'as yet unclassified' }
ElementsPaletteFrameMorph >> wantsDroppedMorph: aMorph event: evt [
	"Return true if the receiver wishes to accept the given morph, which is being dropped by a hand in response to the given event. The default implementation returns false.
NOTE: the event is assumed to be in global (world) coordinates."

	^aMorph isKindOf: SyntaxElementMorph
]
