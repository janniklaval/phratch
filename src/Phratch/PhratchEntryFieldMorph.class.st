Class {
	#name : #PhratchEntryFieldMorph,
	#superclass : #EntryFieldMorph,
	#instVars : [
		'isNumeric',
		'isKeyboardFocus',
		'lastContents'
	],
	#category : #'Phratch-System Subclasses'
}

{ #category : #'as yet unclassified' }
PhratchEntryFieldMorph class >> authoringPrototype [
	"
	self authoringPrototype 
	"
	| e |
	e := PhratchEntryFieldMorph new.
	e position: 80@200.
	e borderWidth: 0.
	e padding: 0.  
	e width: 20.
	e height:13.
	e isNumeric: true.  
	"e onAcceptSend: #flash to: e.
	e onEscapeSend: #delete to: e. 
	e onEditionSend: # updadeFromcontents to: e."
	e isKeyboardFocus: true.
	
	e openInWorld.
	^ e
]

{ #category : #'as yet unclassified' }
PhratchEntryFieldMorph >> contents [
	(contents allSatisfy: [ :eachChar | #($0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $.) includes: eachChar ])
		ifTrue: [ ^ contents asNumberNoError ].
	^ contents
]

{ #category : #'as yet unclassified' }
PhratchEntryFieldMorph >> drawOn: aCanvas [

	aCanvas fillRectangle: self bounds fillStyle: self fillStyle borderStyle: self borderStyle.

	self isDirty not ifTrue:[ self drawInitialContentsOn: aCanvas ].
	self hasSelection ifTrue: [ self drawSelectionOn: aCanvas ].
	self hasVisibleCaret ifTrue: [ self drawCaretOn: aCanvas].
	aCanvas drawString: contents
		in: self innerBounds 
		font: font
		color: self foreColor	
]

{ #category : #'as yet unclassified' }
PhratchEntryFieldMorph >> fillStyle [
	^ Color white 
	"self isReadOnly ifTrue:[ ^ self color].
	self isDirty & self hasKeyboardFocus ifTrue:[^ Color red muchLighter mixed: 0.7 with: self color   ].
	self isDirty & self hasKeyboardFocus not ifTrue:[^ Color white ].
	self hasKeyboardFocus
		ifTrue:[ ^ self color   ] 
		ifFalse:[ ^ Color white   ]."
]

{ #category : #'as yet unclassified' }
PhratchEntryFieldMorph >> fitWidthToContents [
	| width |
	width := font widthOfString: contents.
	self extent: width + 10 + ( self borderWidth + padding  * 2) @ self height .
]

{ #category : #'as yet unclassified' }
PhratchEntryFieldMorph >> handlesMouseDown: evt [
	^ true
]

{ #category : #accessing }
PhratchEntryFieldMorph >> handlesMouseOver: evt [
	^false
]

{ #category : #'as yet unclassified' }
PhratchEntryFieldMorph >> initialize [
	super initialize.
	initialContents := ' '.
]

{ #category : #'as yet unclassified' }
PhratchEntryFieldMorph >> invalidRect: aRect [
	super invalidRect: aRect.
	(self ownerThatIsA: BlockMorph)
		ifNotNil: [ (self ownerThatIsA: BlockMorph) invalidRect: (self ownerThatIsA: BlockMorph) fullBounds ]
]

{ #category : #accessing }
PhratchEntryFieldMorph >> isKeyboardFocus [
	^ isKeyboardFocus
]

{ #category : #accessing }
PhratchEntryFieldMorph >> isKeyboardFocus: anObject [
	isKeyboardFocus := anObject
]

{ #category : #accessing }
PhratchEntryFieldMorph >> isNumeric [
	^ isNumeric
]

{ #category : #accessing }
PhratchEntryFieldMorph >> isNumeric: anObject [
	isNumeric := anObject
]

{ #category : #accessing }
PhratchEntryFieldMorph >> manageCursor [
	self flag:'to implement'.
	^self haltOnce.
	
]

{ #category : #'as yet unclassified' }
PhratchEntryFieldMorph >> mouseDown: evt [ 
	super mouseDown: evt.
]

{ #category : #'as yet unclassified' }
PhratchEntryFieldMorph >> mouseLeave: evt [
	"self doNothing"
]

{ #category : #'as yet unclassified' }
PhratchEntryFieldMorph >> mouseMove: evt [
	"self doNothing"
]

{ #category : #accessing }
PhratchEntryFieldMorph >> savedContents [
	"If the user is editing, return the last contents before editing. Otherwise, return my contents."

	(isKeyboardFocus and: [lastContents notNil]) ifTrue: [^ lastContents].
	^ self contents

]

{ #category : #'as yet unclassified' }
PhratchEntryFieldMorph >> selectionColor [
	^ Color transparent .
]

{ #category : #'as yet unclassified' }
PhratchEntryFieldMorph >> updateFromContents [

	self fitWidthToContents.
	super updateFromContents .

]
