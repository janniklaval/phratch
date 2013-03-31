Class {
	#name : #ScratchMenuTitleMorph,
	#superclass : #StringMorph,
	#instVars : [
		'target',
		'selector'
	],
	#classVars : [
		'MenuBarIsActive'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'as yet unclassified' }
ScratchMenuTitleMorph class >> closeAllMenus [

	self menuBarIsActive ifFalse: [^self ].
	World submorphs do: [:m |
		(m isKindOf: MenuMorph) ifTrue: [m deleteIfPopUp]].
	MenuBarIsActive := false.

]

{ #category : #'as yet unclassified' }
ScratchMenuTitleMorph class >> deactivateMenuBar [

	MenuBarIsActive := false.

]

{ #category : #'as yet unclassified' }
ScratchMenuTitleMorph class >> menuBarIsActive [

	^ MenuBarIsActive ifNil: [MenuBarIsActive := false].

]

{ #category : #'event handling' }
ScratchMenuTitleMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #'event handling' }
ScratchMenuTitleMorph >> handlesMouseOver: evt [

	^ true

]

{ #category : #accessing }
ScratchMenuTitleMorph >> highlightColor [

	^ Color white

]

{ #category : #initialization }
ScratchMenuTitleMorph >> initialize [

	super initialize.
	self
		font: (ScratchFrameMorph getFont: #MenuTitle);
		forceUnicodeRendering: true;
		color: self normalColor.

]

{ #category : #'event handling' }
ScratchMenuTitleMorph >> mouseDown: evt [

	target isNil | selector isNil ifTrue: [^ self].
	Cursor normal show.
	MenuBarIsActive := true.
	target perform: selector with: self.  "invoke my menu"

]

{ #category : #'event handling' }
ScratchMenuTitleMorph >> mouseEnter: evt [

	self color: self highlightColor.
	self class menuBarIsActive ifTrue: [
		self class closeAllMenus.
"		MenuBarIsActive := true.
		target perform: selector with: self "]  "invoke my menu"

]

{ #category : #'event handling' }
ScratchMenuTitleMorph >> mouseLeave: evt [

	self color: self normalColor.

]

{ #category : #accessing }
ScratchMenuTitleMorph >> normalColor [

	^ Color gray: 0.3

]

{ #category : #accessing }
ScratchMenuTitleMorph >> selector [

	^ selector

]

{ #category : #accessing }
ScratchMenuTitleMorph >> target: anObject selector: aSymbol [

	target := anObject.
	selector := aSymbol.

]
