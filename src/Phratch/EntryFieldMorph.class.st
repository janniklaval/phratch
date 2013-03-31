"
I'm a morphic entry field, i present for edition the aspect of my target, and when accepted ( 
pressing cmd-s),i send acceptingSelector to my target.

I only provide behavior for overall font or fontColor modification.


self example1
a simple example with a target and aspect.

self example2 
a more complex example with a target and aspect and acceptingSelector .
When the morph is accepted, pressing Cmd-S, the Transcript shows it's name'
When the morph is escaped the Transcript is closed.
"
Class {
	#name : #EntryFieldMorph,
	#superclass : #EditableTextMorph,
	#instVars : [
		'contents',
		'foreColor',
		'font'
	],
	#category : #'Phratch-Compatibility'
}

{ #category : #testing }
EntryFieldMorph >> acceptOnCR [
	^ true
]

{ #category : #private }
EntryFieldMorph >> characterIndexAtPoint: aPoint [
	| line block blockScanner |
	line := TextLine 
		start: 1
		stop: contents size
		internalSpaces: 0
		paddingWidth: 0.
	line
		rectangle: bounds;
		lineHeight: font height baseline: font ascent.
	blockScanner := CharacterBlockScanner new.
	blockScanner text: contents asText  textStyle: TextStyle default copy.
	block := blockScanner characterBlockAtPoint: aPoint index: nil	in: line.
	^ block stringIndex
]

{ #category : #accessing }
EntryFieldMorph >> contents [ 
	^ contents 
]

{ #category : #updating }
EntryFieldMorph >> contents: aString [ 
	| oldContents |
	oldContents := contents.
	contents := aString.
	contents = oldContents ifFalse: [
		self activeHand keyboardFocus == self ifTrue: [ self activeHand newKeyboardFocus: nil ].
		editor := nil ].
	self selectAll. 
	self updateView.
]

{ #category : #drawing }
EntryFieldMorph >> drawCaretOn: aCanvas [
	| top delta caretRectangle |
	top := self innerBounds topLeft.
	contents isEmpty
		ifTrue:[ delta := 0 ]
		ifFalse:[ delta := (font widthOfString: contents from: 1 to: editor startIndex-1)].
	caretRectangle := top + (delta @0) extent: 1 @ font height .
	aCanvas fillRectangle: caretRectangle color:  self cursorColor.
]

{ #category : #drawing }
EntryFieldMorph >> drawInitialContentsOn: aCanvas [
	aCanvas drawString: initialContents
		in: self innerBounds 
		font: font
		color: Color lightGray	
]

{ #category : #drawing }
EntryFieldMorph >> drawOn: aCanvas [
	super drawOn: aCanvas .
	self isDirty not ifTrue:[ self drawInitialContentsOn: aCanvas ].
	self hasSelection ifTrue: [ self drawSelectionOn: aCanvas ].
	self hasVisibleCaret ifTrue: [ self drawCaretOn: aCanvas].
	aCanvas drawString: contents
		in: self innerBounds 
		font: font
		color: self foreColor	
]

{ #category : #drawing }
EntryFieldMorph >> drawSelectionOn: aCanvas [
	| rightX leftX top bottom  deltaX |
	top :=self innerBounds top .
	bottom := top + font height.
	deltaX := self innerBounds left.
	leftX := (font widthOfString: contents from: 1 to: editor startIndex-1) + deltaX.
	rightX := (font widthOfString: contents from: 1 to: editor stopIndex-1) + deltaX.
	aCanvas
		fillRectangle: (leftX @ top corner: rightX @ bottom)
		color: self selectionColor 
]

{ #category : #accessing }
EntryFieldMorph >> editedContents [
	^ editor string.

]

{ #category : #accessing }
EntryFieldMorph >> editorClass [
	^SimpleEditor
]

{ #category : #updating }
EntryFieldMorph >> fitHeightToFont [
	| fittedHeight |
	fittedHeight := self borderWidth + padding * 2 + font height .
	self extent: bounds width @ fittedHeight
]

{ #category : #updating }
EntryFieldMorph >> fitWidthToContents [
	| width |
	width := font widthOfString: contents.
	self extent: width + ( self borderWidth + padding  * 2) @ self height .
]

{ #category : #accessing }
EntryFieldMorph >> font [
	^ font 
]

{ #category : #accessing }
EntryFieldMorph >> font: aFont [
	font := aFont. 
	self fitHeightToFont.
]

{ #category : #accessing }
EntryFieldMorph >> foreColor [
	^self hasKeyboardFocus
		ifTrue: [ foreColor]
		ifFalse: [ foreColor duller ]
]

{ #category : #accessing }
EntryFieldMorph >> foreColor: aColor [ 
	 foreColor := aColor 
]

{ #category : #editing }
EntryFieldMorph >> handleInteraction: interactionBlock [
	| oldEditor oldContents |
	oldEditor := editor.
	oldContents := contents.
	interactionBlock value.
	oldContents == contents ifTrue: [ editor := oldEditor	].
	self changed
]

{ #category : #'event handling' }
EntryFieldMorph >> handlesMouseDown: evt [
	^ ( super handlesMouseOver: evt ) and:[ 
	 	bounds containsPoint: evt cursorPoint]
]

{ #category : #'as yet unclassified' }
EntryFieldMorph >> hasSelection [
	^editor notNil and: [editor hasSelection]
]

{ #category : #updating }
EntryFieldMorph >> hasUnacceptedEdits: aBoolean [
	super hasUnacceptedEdits: aBoolean.
	aBoolean ifTrue:[ 	self updateFromContents ]. 
]

{ #category : #accessing }
EntryFieldMorph >> initialContents [
	^ initialContents
]

{ #category : #accessing }
EntryFieldMorph >> initialContents: aString [
	initialContents := aString
]

{ #category : #initialization }
EntryFieldMorph >> initialize [
	super initialize.
	bounds := 10@10 extent: 200@30.
	padding :=  self borderWidth + 1.
	initialContents := 'type something here'.
	contents := ''.
	font := self theme listFont.
	self fitHeightToFont .
	foreColor := Color black.
	

]

{ #category : #accessing }
EntryFieldMorph >> installEditorToReplace: priorEditor [ 
	"Install an editor for my contents. This constitutes 'hasFocus'.	If
	priorEditor is not nil, then initialize the new editor from its state.	We
	may want to rework this so it actually uses the prior editor." 
	editor := (self editorClass basicNew morph: self) initialize.
	editor changeString: contents.
	self changed.
	^ editor
]

{ #category : #testing }
EntryFieldMorph >> isDirty [
	^ contents notEmpty
]

{ #category : #'event handling' }
EntryFieldMorph >> keyStroke: aKeyboardEvent [
	self handleInteraction: [ editor processKeyStroke: aKeyboardEvent ]. 
	
]

{ #category : #'event handling' }
EntryFieldMorph >> keyboardFocusChange: aBoolean [ 
	aBoolean ifTrue: [ self installEditor ].
	self updateView
]

{ #category : #'event handling' }
EntryFieldMorph >> mouseDown: evt [
	self takesKeyboardFocus not ifTrue:[ ^ self ].
	evt hand newKeyboardFocus: self.
	self handleInteraction: [ editor mouseDown: evt index: (self characterIndexAtPoint: evt cursorPoint) ]
]

{ #category : #'event handling' }
EntryFieldMorph >> mouseMove: evt [
	self flag:#reallyNeededthinkAboutitmore.
	self takesKeyboardFocus not ifTrue:[ ^ self ].
	evt redButtonPressed ifFalse: [^ self].
	self handleInteraction: [ editor mouseMove: evt index: (self characterIndexAtPoint: evt cursorPoint) ]
]

{ #category : #accessing }
EntryFieldMorph >> updateFromContents [
	| c |
	c := editor string.
	c = contents ifFalse: [
		contents := c.
		self changed ]
]
