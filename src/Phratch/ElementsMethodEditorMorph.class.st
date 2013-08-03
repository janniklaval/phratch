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
		'currentClass',
		'methodModified'
	],
	#classVars : [
		'WarnIfNoChangesFile',
		'WarnIfNoSourcesFile'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #accessing }
ElementsMethodEditorMorph class >> warnIfNoChangesFile [
	^ WarnIfNoChangesFile ifNil: [ WarnIfNoChangesFile := false ]
]

{ #category : #accessing }
ElementsMethodEditorMorph class >> warnIfNoChangesFile: anObject [
	WarnIfNoChangesFile := anObject
]

{ #category : #accessing }
ElementsMethodEditorMorph class >> warnIfNoSourcesFile [
	^ WarnIfNoSourcesFile ifNil: [ WarnIfNoSourcesFile := false ]
]

{ #category : #accessing }
ElementsMethodEditorMorph class >> warnIfNoSourcesFile: anObject [
	WarnIfNoSourcesFile := anObject
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> buildPanes [
	| p m |
	classChooser := ClassChooserMorph new frame: self; class: Object.
	sideChooser := InstanceClassSwitchMorph new frame: self.
	methodChooser := MethodChooserMorph new frame: self; class: Object; selector: #yourself.
	editor := ElementsScrollFrameMorph new
				color: Color gray;
				borderColor: Color gray.
	p := PasteUpMorph new borderWidth: 0; color: Color gray darker.
	m := MethodElementMorph new selector: '' arguments: #().
	editor contents: p.
	p addMorph: m.

	palette := ElementsPaletteFrameMorph new editorFrame: self; height: self height; arrangePanes.
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

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> contextMenu [
	|m|
	m := MenuMorph new.
	m add: 'clean up' action: #arrangeElements.

	m addLine.
	fillScreenOn
		ifTrue: [
			m add: 'switch to development mode' action: #developmentMode.
]
		ifFalse: [m add: 'switch to user mode' action: #userMode.
			m add: 'save image in user mode' action: #saveImage ].

	m addLine.
	m add: 'about...' action: #about.

	^m
]

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> currentClass [
	^currentClass
]

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> currentMethodElement [
	^editor contents findA: MethodElementMorph
	
]

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> currentSide [
	sideChooser ifNil: [^#instance ].
	^sideChooser choice
]

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> developmentMode [
	fillScreenOn := false.
	self
		position: World topLeft;
		extent: World extent - 50;
		arrangePanes.
	palette arrangePanes.	
	ScriptablePhratchMorph noviceMode: false.
	ElementsMethodEditorMorph warnIfNoSourcesFile: true.
	ElementsMethodEditorMorph warnIfNoChangesFile: true.
	UsersManager default currentUser canShowMorphHalo: true.


]

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> handlesMouseDown: evt [
	"Return true if this morph wants to receive mouseDown events (i.e., mouseDown:, mouseMove:, mouseUp:). The default response is false; subclasses that implement mouse messages should override this to return true." 

	^ true

]

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> initialize [
	fillScreenOn := false.
	methodModified := false.
	currentClass := Object.
	currentMethod := #yourself.
	super initialize.
	self extent: 600 @ 400.
	color := Color gray.
	self buildPanes.
	self arrangePanes.
	self refresh
]

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> invokeContextMenu [
	|m choice|
	m := self contextMenu.
	m ifNotNil: [
		choice := m startUp.
		choice ifNotNil: [self perform: choice] ]
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> methodModified [
	methodModified := true.
	saver isHidden: false.
	saver position: (self position x + (palette left - methodChooser right - saver width // 2) ) @ (methodChooser bottom - saver height)
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> methodUnmodified [
	methodModified := false.
	saver isHidden: true
]

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> mouseDown: evt [
	"Handle a mouse down event."

	evt rightButtonPressed
		ifTrue: [ ^self invokeContextMenu].
	ScriptablePhratchMorph noviceMode ifTrue: [^self].
	self startDrag: evt

]

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> onMethod: aSelector ofClass: aClass [
	methodModified := false.
	currentClass := aClass.
	classChooser class: aClass.
	currentMethod := #aSelector.
	methodChooser selector: aSelector.
	methodChooser class: aClass.
	palette class: aClass.
"	self refresh"
]

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> refresh [
	self methodTemplate
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> saveImage [

	self userMode.
	self maximize.
	World allMorphsDo: [:m|
		(m isKindOf: SystemWindow)
			ifTrue: [m delete ]].
	World activeHand saveAndQuit
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> step [
	fillScreenOn 
		ifTrue: [self maximize]
		ifFalse: [^self arrangePanes].
]

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> stepTime [
	^0
]

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> switchToClassSide [

	self selectClass: currentClass class
]

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> switchToInstanceSide [

	self selectClass: currentClass allInstances first.
]

{ #category : #'as yet unclassified' }
ElementsMethodEditorMorph >> userMode [

	fillScreenOn := true.
	ScriptablePhratchMorph noviceMode: true.
	ElementsMethodEditorMorph warnIfNoSourcesFile: false.
	ElementsMethodEditorMorph warnIfNoChangesFile: false.
	UsersManager default currentUser canShowMorphHalo: false.


]
