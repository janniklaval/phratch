Class {
	#name : #FormMenuItemMorph,
	#superclass : #MenuItemMorph,
	#instVars : [
		'form'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #drawing }
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

{ #category : #geometry }
FormMenuItemMorph >> extent: aPoint [

	super extent: (aPoint truncated max: self minWidth@self minHeight).
]

{ #category : #accessing }
FormMenuItemMorph >> form: aForm [

	form := aForm
]

{ #category : #layout }
FormMenuItemMorph >> minHeight [

	form ifNotNil: [^ form height + 2].
	^ super minHeight

]

{ #category : #layout }
FormMenuItemMorph >> minWidth [

	form ifNotNil: [^form width + 2].
	^ (self stringWidth: contents) + (subMenu == nil ifTrue: [0] ifFalse: [10])

]
