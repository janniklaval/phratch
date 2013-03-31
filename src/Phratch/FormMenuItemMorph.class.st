Class {
	#name : #FormMenuItemMorph,
	#superclass : #MenuItemMorph,
	#instVars : [
		'form'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #'as yet unclassified' }
FormMenuItemMorph >> drawOn: aCanvas [
	| selectionColor px py |
	isSelected & isEnabled
		ifTrue:
			[selectionColor := Display depth <= 2
				ifTrue: [Color gray]
				ifFalse: [owner color darker].
			aCanvas fillRectangle: self bounds color: selectionColor].
	super drawOn: aCanvas.
	subMenu ifNotNil:
		[aCanvas
			paintImage: SubMenuMarker
			at: self right - 8 @ (self top + self bottom - SubMenuMarker height // 2)].
	form ifNotNil: [
		px := self width - form width // 2.
		py := self height - form height // 2.
		aCanvas
			paintImage: form
			at: self position + (px @ py )]
		
]

{ #category : #'as yet unclassified' }
FormMenuItemMorph >> extent: aPoint [

	super extent: (aPoint truncated max: self minWidth@self minHeight).
]

{ #category : #'as yet unclassified' }
FormMenuItemMorph >> form: aForm [

	form := aForm
]

{ #category : #'as yet unclassified' }
FormMenuItemMorph >> minHeight [

	form ifNotNil: [^ form height + 2].
	^ super minHeight

]

{ #category : #'as yet unclassified' }
FormMenuItemMorph >> minWidth [

	form ifNotNil: [^form width + 2].
	^ (self stringWidth: contents) + (subMenu == nil ifTrue: [0] ifFalse: [10])

]
