Class {
	#name : #PhratchMenuTitleMorph,
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
PhratchMenuTitleMorph class >> closeAllMenus [

	self menuBarIsActive ifFalse: [^self ].
	World submorphs do: [:m |
		(m isKindOf: MenuMorph) ifTrue: [m deleteIfPopUp]].
	MenuBarIsActive := false.

]

{ #category : #'as yet unclassified' }
PhratchMenuTitleMorph class >> deactivateMenuBar [

	MenuBarIsActive := false.

]

{ #category : #'as yet unclassified' }
PhratchMenuTitleMorph class >> menuBarIsActive [

	^ MenuBarIsActive ifNil: [MenuBarIsActive := false].

]

{ #category : #'event handling' }
PhratchMenuTitleMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #'event handling' }
PhratchMenuTitleMorph >> handlesMouseOver: evt [

	^ true

]

{ #category : #accessing }
PhratchMenuTitleMorph >> highlightColor [

	^ Color white

]

{ #category : #initialization }
PhratchMenuTitleMorph >> initialize [

	super initialize.
	self
		font: (PhratchFrameMorph getFont: #MenuTitle);
		forceUnicodeRendering: true;
		color: self normalColor.

]

{ #category : #'event handling' }
PhratchMenuTitleMorph >> mouseDown: evt [

	target isNil | selector isNil ifTrue: [^ self].
	Cursor normal show.
	MenuBarIsActive := true.
	target perform: selector with: self.  "invoke my menu"

]

{ #category : #'event handling' }
PhratchMenuTitleMorph >> mouseEnter: evt [

	self color: self highlightColor.
	self class menuBarIsActive ifTrue: [
		self class closeAllMenus.
"		MenuBarIsActive := true.
		target perform: selector with: self "]  "invoke my menu"

]

{ #category : #'event handling' }
PhratchMenuTitleMorph >> mouseLeave: evt [

	self color: self normalColor.

]

{ #category : #accessing }
PhratchMenuTitleMorph >> normalColor [

	^ Color gray: 0.3

]

{ #category : #accessing }
PhratchMenuTitleMorph >> selector [

	^ selector

]

{ #category : #accessing }
PhratchMenuTitleMorph >> target: anObject selector: aSymbol [

	target := anObject.
	selector := aSymbol.

]
