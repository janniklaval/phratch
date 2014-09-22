"
I represent a literal value such as a number or string. I can be edited by typing or a value can be chosen from a pull-down menu.

"
Class {
	#name : #ExpressionArgMorphWithMenu,
	#superclass : #ExpressionArgMorph,
	#instVars : [
		'menuMorph',
		'getMenuSelector',
		'specialValue'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #accessing }
ExpressionArgMorphWithMenu >> defaultValue: anObject [

	((#(listIndexMenu listIndexForDeleteMenu) includes: getMenuSelector) and:
	 [anObject isString])
		ifTrue: [self specialValue: anObject]
		ifFalse: [super defaultValue: anObject].


]

{ #category : #menus }
ExpressionArgMorphWithMenu >> directionMenu [
	"Provides a drop-down menu for setting the sprite direction."

	| menu |
	menu := MenuMorph new defaultTarget: nil.
	#(	('right' 90)
		('left' -90)
		('up' 0)
		('down' 180)
	) do: [:pair |
		menu
			add: '(' "asUTF8", pair second printString, ') ', pair first localized
			target: self
			selector: #stringExpression:
			argument: pair second asString].
	^ menu

]

{ #category : #evaluation }
ExpressionArgMorphWithMenu >> evaluate [
	| expr |
	"Answer the result of evaluating my expression in the context of the given PhratchProcess."

	(self isEmptySlot and: [implicitValue notNil])
		ifTrue: [^implicitValue].

	specialValue ifNotNil: [^ specialValue].


"	^ super evaluate"

	expr := labelMorph savedContents.
	isNumber
		ifTrue: [ ^ expr asNumberNoError]
		ifFalse: [^ expr]. 





]

{ #category : #private }
ExpressionArgMorphWithMenu >> fixArgLayout [

	| dx |
	dx := 9.
	super fixArgLayout.
	menuMorph ifNil: [^ self].
	self width: self width + dx.
	menuMorph position: (self right - dx - 2)@(self top + (self height // 3)).
	(thisContext sender receiver isStringFieldMorph) ifTrue: [
		"clear only when user edit my label, but not on other arg layout changes"
		specialValue := nil].

]

{ #category : #'event handling' }
ExpressionArgMorphWithMenu >> handlesMouseDown: evt [

	^ menuMorph notNil

]

{ #category : #BYOB }
ExpressionArgMorphWithMenu >> isEmptySlot [
	specialValue ifNotNil: [
		^ specialValue = ' '].
	^super isEmptySlot
]

{ #category : #menus }
ExpressionArgMorphWithMenu >> listIndexForDeleteMenu [

	| menu |
	menu := MenuMorph new .
	#('1' last) do: [:s | menu add: s  printString 
			value: s  asString].
	menu addLine.
	menu add: #all  printString 
			value: #all  asString.
	menu localize.
	^ menu

]

{ #category : #menus }
ExpressionArgMorphWithMenu >> listIndexMenu [

	| menu |
	menu := MenuMorph new defaultTarget: nil.
	#('1' last any) do: [:s | menu add: s  printString 
			target: self
			selector: #stringExpression:
			argument: s  asString].
	menu localize.
	^ menu

]

{ #category : #menus }
ExpressionArgMorphWithMenu >> menuSelector [

	^ getMenuSelector


]

{ #category : #menus }
ExpressionArgMorphWithMenu >> menuSelector: menuSelector [
	"Add a drop-down menu button with the given selector. The selector should result in a menu whose action items are values that can be put into this type argument, typically numbers or strings."

	menuMorph := ImageMorph new form: DropDownMenuForm.
	getMenuSelector := menuSelector.
	self addMorphFront: menuMorph.
	self fixArgLayout.

]

{ #category : #'event handling' }
ExpressionArgMorphWithMenu >> mouseDown: evt [

	| rcvr menu choice |
	menuMorph ifNil: [^ super mouseDown: evt].
	(evt cursorPoint x < (menuMorph left - 1)) ifTrue: [^ super mouseDown: evt].

	(getMenuSelector notNil and:
	 [(owner isBlockMorph) and: 
	 [(rcvr := owner receiver) notNil]]) ifFalse: [^ PhratchError error: 'beep'.].
	menu := rcvr perform: getMenuSelector.
	(Smalltalk at: #PhratchCategorySound ifPresent:[(menu isKindOf: PhratchNoteSelector) ifTrue: [
		menu position: owner bottomLeft + (((owner width - menu width) // 2) @ -4).
		]]).
	menu ifNil:[^self].
	choice := menu selectedValue.
	choice ifNil: [^ self].
	evt hand newKeyboardFocus: nil.  "close mini-editor, if any"
	(#(listIndexMenu listIndexForDeleteMenu) includes: getMenuSelector) ifTrue: [
		^ self specialValue: choice].

	isNumber
		ifTrue: [self numExpression: choice]
		ifFalse: [self stringExpression: choice].


]

{ #category : #accessing }
ExpressionArgMorphWithMenu >> specialValue: aString [
	"A special value is a menu selection such as 'last' for a list index that appears as a string in a number if field. If the user edits the field, then it only accepts numeric input. The argumet is retained in the specialValue instance variable."

	isNumber := true.
	labelMorph contents: aString localized.
	labelMorph
		isNumeric: true;
		position: self position + (0@1).
	self fixArgLayout.
	specialValue := aString.

]
