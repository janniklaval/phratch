Class {
	#name : #ElementsMethodEditorMorph,
	#superclass : #Morph,
	#instVars : [
		'classChooser',
		'methodChooser',
		'sideChooser',
		'palette',
		'editor',
		'saver',
		'fillScreenOn',
		'currentMethod',
		'currentClass'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #menu }
ElementsMethodEditorMorph >> about [
	self inform: '- Elements -

a graphical Smalltalk
------------------------------
experimental release of Aug. 24 2009
 
written by Jens Mönig (jens@moenig.org)
all rights reserved
 
inspired by Scratch from the MIT Media Lab
and based in part on the Scratch Source Code.
Implemented in Squeak and in itself.'
]

{ #category : #actions }
ElementsMethodEditorMorph >> arrangeElements [
	| current x y spacing |
	spacing := 5.
	current := self currentMethodElement.
	x := editor contents left + spacing.
	y := current stackBottom + spacing.
	editor contents submorphsDo: [:element |
		(element == current) ifFalse:[
			element position: x @ y.
			y := element bottom + spacing ]]
		
]

{ #category : #private }
ElementsMethodEditorMorph >> arrangePanes [
	classChooser position: self topLeft + 2.
	sideChooser position: classChooser bottomLeft.
	methodChooser position: sideChooser bottomLeft.
	editor position: (self left + 4) @ (methodChooser bottom + 4);
		extent: (self width - 180 - 8) @ (self bottom - editor top - 4).
	palette position: editor right @ (classChooser bottom);
		height: self bottom - palette top - 4;
		arrangePanes.
	saver position: (self position x + (palette left - methodChooser right - saver width // 2) ) @ (methodChooser bottom - saver height)

]

{ #category : #initialization }
ElementsMethodEditorMorph >> buildPanes [
	| p m |
	classChooser := ClassChooserMorph new frame: self; class: Object;
		yourself.
	sideChooser := InstanceClassSwitchMorph new frame: self.
	methodChooser := MethodChooserMorph new frame: self; class: Object; selector: #yourself;
		yourself.
	editor := ElementsScrollFrameMorph new
				color: Color gray;
				borderColor: Color gray;
		yourself.
	p := PasteUpMorph new borderWidth: 0; color: Color gray darker;
		yourself.
	m := MethodElementMorph new selector: '' arguments: #().
	editor contents: p.
	p addMorph: m.

	palette := ElementsPaletteFrameMorph new editorFrame: self; height: self height; arrangePanes; 
		yourself.
	saver := ElementsToggleButtonMorph new flat; label: 'save'; onColor: color offColor: color; target: self; selector: #saveCurrentMethod;
		yourself.
	self
		addMorph: classChooser;
		addMorph: sideChooser;
		addMorph: methodChooser;
		addMorph: editor;
		addMorph: palette;
		addMorph: saver.
	saver isHidden: true
]

{ #category : #menu }
ElementsMethodEditorMorph >> contextMenu [
	| m |
	m := MenuMorph new.
	m add: 'clean up' translated action: #arrangeElements.
	m addLine.
	fillScreenOn
		ifTrue: [ m add: 'switch to development mode' translated action: #developmentMode ]
		ifFalse: [ 
			m add: 'switch to user mode' translated action: #userMode.
			m add: 'save image in user mode' translated action: #saveImage ].
	m addLine.
	m add: 'about...' translated action: #about.
	^ m
]

{ #category : #accessing }
ElementsMethodEditorMorph >> currentClass [
	^currentClass
]

{ #category : #accessing }
ElementsMethodEditorMorph >> currentMethodElement [
	^editor contents findA: MethodElementMorph
	
]

{ #category : #accessing }
ElementsMethodEditorMorph >> currentSide [
	sideChooser ifNil: [^#instance ].
	^sideChooser choice
]

{ #category : #actions }
ElementsMethodEditorMorph >> developmentMode [
	fillScreenOn := false.
	self
		position: World topLeft;
		extent: World extent - 50;
		arrangePanes.
	palette arrangePanes.	
	ScriptablePhratchMorph noviceMode: false.
	
	self flag:'need to be removed after Pharo2.0 version'.
	SystemVersion current major >= 3 ifTrue:[
		"Smalltalk tools userManager canShowMorphHalo: true. "
	] ifFalse: [ 
		(Smalltalk at: #UsersManager) default currentUser canShowMorphHalo: true.
	].


]

{ #category : #'event handling' }
ElementsMethodEditorMorph >> handlesMouseDown: evt [
	"Return true if this morph wants to receive mouseDown events (i.e., mouseDown:, mouseMove:, mouseUp:). The default response is false; subclasses that implement mouse messages should override this to return true." 

	^ true

]

{ #category : #initialize }
ElementsMethodEditorMorph >> initialize [
	fillScreenOn := false.
	currentClass := Object.
	currentMethod := #yourself.
	super initialize.
	self extent: 600 @ 400.
	color := Color gray.
	self buildPanes.
	self arrangePanes.
	self refresh
]

{ #category : #menu }
ElementsMethodEditorMorph >> invokeContextMenu [
	|m choice|
	m := self contextMenu.
	m ifNotNil: [
		choice := m startUp.
		choice ifNotNil: [self perform: choice] ]
]

{ #category : #actions }
ElementsMethodEditorMorph >> maximize [
	((self position = World position) and: [
		self extent = World extent])
		ifTrue: [^self].
	self
		position: World topLeft;
		extent: World extent;
		arrangePanes.
	palette arrangePanes.
	self comeToFront

]

{ #category : #accessing }
ElementsMethodEditorMorph >> methodModified [
	saver isHidden: false.
	saver position: (self position x + (palette left - methodChooser right - saver width // 2) ) @ (methodChooser bottom - saver height)
]

{ #category : #accessing }
ElementsMethodEditorMorph >> methodTemplate [
	| m |
	m := MethodElementMorph new selector: '' arguments: #().
	self currentMethodElement delete.
	m position: editor contents position.
	editor contents addMorph: m fitMethod.
	self isInWorld ifFalse: [^self].
	methodChooser selector: nil.
	self methodUnmodified
]

{ #category : #accessing }
ElementsMethodEditorMorph >> methodUnmodified [
	saver isHidden: true
]

{ #category : #'event handling' }
ElementsMethodEditorMorph >> mouseDown: evt [
	"Handle a mouse down event."

	evt rightButtonPressed
		ifTrue: [ ^self invokeContextMenu].
	ScriptablePhratchMorph noviceMode ifTrue: [^self].
	self startDrag: evt

]

{ #category : #accessing }
ElementsMethodEditorMorph >> onMethod: aSelector ofClass: aClass [
	currentClass := aClass.
	classChooser class: aClass.
	currentMethod := #aSelector.
	methodChooser selector: aSelector.
	methodChooser class: aClass.
	palette class: aClass.
"	self refresh"
]

{ #category : #private }
ElementsMethodEditorMorph >> refresh [
	self methodTemplate
]

{ #category : #actions }
ElementsMethodEditorMorph >> saveCurrentMethod [
	| se sel|
	se := self currentMethodElement.
	sel := se selector.

	currentClass compile: se asSmalltalk
					classified: ClassOrganizer nullCategory
					notifying: nil.

	methodChooser selector: sel.
	self selectMethod: sel.
	palette refresh
]

{ #category : #actions }
ElementsMethodEditorMorph >> saveImage [

	self userMode.
	self maximize.
	World allMorphsDo: [:m|
		(m isKindOf: SystemWindow)
			ifTrue: [m delete ]].
	World activeHand saveAndQuit
]

{ #category : #'class list' }
ElementsMethodEditorMorph >> selectClass: aClass [
	editor ifNil: [^self].
	(currentClass = aClass)
		ifTrue: [^self].

	currentClass := aClass.
	classChooser class: currentClass.
	methodChooser class: currentClass.
	palette class: currentClass.
	self methodTemplate
	
]

{ #category : #private }
ElementsMethodEditorMorph >> selectMethod: aSelector [
	| myMethod temps se |

	currentMethod := aSelector.
	editor ifNil: [^self].
	currentMethod ifNil: [^self].
	currentClass ifNotNil:
		[myMethod := currentClass compiledMethodAt: currentMethod ifAbsent: [^self methodTemplate].
		temps := (currentClass compilerClass new
						parse: myMethod getSourceFromFile asString in: currentClass notifying: nil)
						tempNames.

	se := ((currentClass decompilerClass new withTempNames: temps)
		decompile: currentMethod in: currentClass method: myMethod) asSyntaxElement.

	self currentMethodElement delete.
	se position: editor contents position.
	editor contents addMorph: se fitMethod.

	^self methodUnmodified.
		].

	^self methodTemplate


]

{ #category : #'stepping and presenter' }
ElementsMethodEditorMorph >> step [
	fillScreenOn 
		ifTrue: [self maximize]
		ifFalse: [^self arrangePanes].
]

{ #category : #testing }
ElementsMethodEditorMorph >> stepTime [
	^0
]

{ #category : #actions }
ElementsMethodEditorMorph >> switchToClassSide [

	self selectClass: currentClass class
]

{ #category : #actions }
ElementsMethodEditorMorph >> switchToInstanceSide [

	self selectClass: currentClass allInstances first.
]

{ #category : #actions }
ElementsMethodEditorMorph >> userMode [

	fillScreenOn := true.
	ScriptablePhratchMorph noviceMode: true.
	
	self flag:'need to be removed after Pharo2.0 version'.
	SystemVersion current major >= 3 ifTrue:[
		"Smalltalk tools userManager canShowMorphHalo: false. "
	] ifFalse: [ 
		(Smalltalk at: #UsersManager) default currentUser canShowMorphHalo: false.
	].


]
