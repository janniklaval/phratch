Class {
	#name : #EditableTextMorph,
	#superclass : #Morph,
	#instVars : [
		'announcer',
		'initialContents',
		'editor',
		'padding'
	],
	#category : #'Phratch-Compatibility'
}

{ #category : #accessing }
EditableTextMorph >> acceptContents [ 
	"The message is sent when the user hits enter or Cmd-S.
	Accept the current contents and end editing"
	self announceAccepted 
]

{ #category : #accessing }
EditableTextMorph >> acceptOnCR [ 
	^ false
	
]

{ #category : #announcements }
EditableTextMorph >> announceAccepted [
	announcer announce: ( AcceptedContentsAnnouncement on: self  ).
	
]

{ #category : #announcements }
EditableTextMorph >> announceEdition [ 
	self announcesEditions ifTrue:[ announcer announce: ( EditedContentsAnnouncement on: self )  ].
	
]

{ #category : #announcements }
EditableTextMorph >> announceEscape [ 
	announcer announce: ( EscapedPressedAnnouncement on: self ) .
	
]

{ #category : #accessing }
EditableTextMorph >> announcesEditions [
	^ self valueOfProperty: #announcesEditions
]

{ #category : #accessing }
EditableTextMorph >> announcesEditions: aBoolean [
	^ self setProperty: #announcesEditions toValue: aBoolean 
]

{ #category : #accessing }
EditableTextMorph >> autoFit: aBoolean [ 
	self setProperty: #autoFitContents toValue: aBoolean .
]

{ #category : #testing }
EditableTextMorph >> canChangeText [
	^ self enabled
]

{ #category : #accessing }
EditableTextMorph >> cursorColor [
	^ Color blue 
]

{ #category : #private }
EditableTextMorph >> defaultBorderStyle [ 
	^ BorderStyle color: Color black width: 1.
]

{ #category : #drawing }
EditableTextMorph >> drawOn: aCanvas [
	super drawOn: aCanvas.
	self isDirty
		ifTrue: [self theme
				drawTextAdornmentFor: self
				color: Color orange
				on: aCanvas ].
	self hasErrors
		ifTrue:[ 
			self theme
				drawTextAdornmentFor: self
				color: Color red
				on: aCanvas ]
]

{ #category : #accessing }
EditableTextMorph >> editor [
	"Return my current editor, or install a new one."
	editor ifNotNil: [^ editor].
	^ self installEditorToReplace: nil
]

{ #category : #accessing }
EditableTextMorph >> escapePressed [ 
	"The message is sent when the user hits esc"
	self announceEscape
	 
]

{ #category : #accessing }
EditableTextMorph >> escapePressed: aKeyboardEvent [ 
	"The message is sent when the user hits esc"
	self announceEscape
	 
]

{ #category : #accessing }
EditableTextMorph >> fillStyle [
	self isReadOnly ifTrue:[ ^ super fillStyle].
	self hasKeyboardFocus
		ifTrue:[ ^ super fillStyle   ] 
		ifFalse:[ ^ super fillStyle slightlyDarker   ].
]

{ #category : #'event handling' }
EditableTextMorph >> handlesKeyboard: evt [
	^ self visible and:[ self takesKeyboardFocus ].
]

{ #category : #'event handling' }
EditableTextMorph >> handlesMouseDown: evt [
	^ self visible and:[ self takesKeyboardFocus ].
]

{ #category : #'event handling' }
EditableTextMorph >> handlesMouseOver: evt [
	^ self visible and:[ self takesKeyboardFocus ].
]

{ #category : #testing }
EditableTextMorph >> hasErrors [
	^ self editor hasError
]

{ #category : #testing }
EditableTextMorph >> hasSelection [
	^editor notNil and: [editor hasSelection]
]

{ #category : #testing }
EditableTextMorph >> hasUnacceptedEdits: aBoolean [
	"Set the hasUnacceptedEdits flag to the given value. "
	aBoolean ifTrue:[ self announceEdition ]. 
]

{ #category : #testing }
EditableTextMorph >> hasVisibleCaret [
	^ self hasKeyboardFocus and: [editor hasCaret]
]

{ #category : #initialization }
EditableTextMorph >> initialize [ 
	super initialize .
	self borderStyle: self defaultBorderStyle.
	color := Color white.
	announcer := Announcer new.
	padding := 0.
	self readOnly: false .
	self announcesEditions: false. 
]

{ #category : #accessing }
EditableTextMorph >> innerBounds [ 
	^  bounds insetBy: self borderWidth +  padding  
]

{ #category : #private }
EditableTextMorph >> installEditor [
	editor isNil ifTrue:[ self installEditorToReplace: nil].
]

{ #category : #testing }
EditableTextMorph >> isAutoFit [ 
	^ self valueOfProperty: #autoFitContents ifAbsent: [ false ]

]

{ #category : #testing }
EditableTextMorph >> isReadOnly [
	^ self valueOfProperty: #readOnly
]

{ #category : #'event handling' }
EditableTextMorph >> mouseDown: evt [ 
	self takesKeyboardFocus not ifTrue:[ ^ self ].
	evt yellowButtonPressed ifTrue: [ ^ self yellowButtonActivity: evt shiftPressed].
	evt hand newKeyboardFocus: self .
	self handleInteraction: [editor mouseDown: evt]
		
]

{ #category : #'event handling' }
EditableTextMorph >> mouseEnter: evt [
	self takesKeyboardFocus not ifTrue:[ ^ self ].
	evt hand newKeyboardFocus: self.
]

{ #category : #'event handling' }
EditableTextMorph >> mouseLeave: evt [
	evt hand newKeyboardFocus: nil.
]

{ #category : #'event handling' }
EditableTextMorph >> mouseMove: evt [
	self takesKeyboardFocus not ifTrue:[ ^ self ].
	self handleInteraction: [editor mouseMove: evt] 
]

{ #category : #'event handling' }
EditableTextMorph >> onAcceptDo: aBlock [ 
	self readOnly: false.
	announcer on: AcceptedContentsAnnouncement do: aBlock
]

{ #category : #'event handling' }
EditableTextMorph >> onAcceptSend: aSelector to: anObject [
	self readOnly: false.
	announcer on: AcceptedContentsAnnouncement do: [:ann | 
		aSelector isUnary
			ifTrue:[ anObject perform: aSelector]
			ifFalse:[anObject perform: aSelector withArguments:{ann textMorph }]]
]

{ #category : #'event handling' }
EditableTextMorph >> onEditionSend: aSelector to: anObject [
	announcer on: EditedContentsAnnouncement do: [:ann | 
		aSelector isUnary
			ifTrue:[ anObject perform: aSelector]
			ifFalse:[anObject perform: aSelector withArguments:{ann textMorph }]]
]

{ #category : #'event handling' }
EditableTextMorph >> onEscapeSend: aSelector to: anObject [
	announcer on: EscapedPressedAnnouncement do: [:ann | 
		aSelector isUnary
			ifTrue:[ anObject perform: aSelector]
			ifFalse:[anObject perform: aSelector withArguments:{ann textMorph }]]
]

{ #category : #'find-replace' }
EditableTextMorph >> openFindDialog [
	self flash
]

{ #category : #accessing }
EditableTextMorph >> padding [
	^ padding 
]

{ #category : #accessing }
EditableTextMorph >> padding: aNumber [ 
	padding := aNumber .
	
]

{ #category : #testing }
EditableTextMorph >> readOnly: aBoolean [ 
	self setProperty: #readOnly toValue: aBoolean.
]

{ #category : #accessing }
EditableTextMorph >> selectAll [ 
	self editor selectAll .
]

{ #category : #accessing }
EditableTextMorph >> selectionColor [
	^ self theme selectionColor alpha: 0.5
]

{ #category : #'find-replace' }
EditableTextMorph >> sharesFindReplace [
	^ false
]

{ #category : #testing }
EditableTextMorph >> takesKeyboardFocus [
	^ self visible and:[ self isReadOnly not ]
]

{ #category : #updating }
EditableTextMorph >> updateView [ 
	self changed.
]

{ #category : #testing }
EditableTextMorph >> wantsKeyboardFocusNavigation [
	"Answer whether the receiver wants to be navigated to."
	^false
]
