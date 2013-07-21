Class {
	#name : #ElementsEditorFrameMorph,
	#superclass : #DialogBoxMorph,
	#instVars : [
		'editor',
		'initialClass',
		'initialMethod',
		'resizeMorph',
		'resizeOffset',
		'definition',
		'template',
		'receiver',
		'bin'
	],
	#classVars : [
		'UserPos',
		'UserSize'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph class >> initialize [
	"BlockEditorFrameMorph initialize"
	self resetDimensions
]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph class >> minExtent [
	^500 @ 400.
]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph class >> resetDimensions [
	UserPos := nil.
	UserSize := self minExtent.
]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph class >> setUserPos: aPoint size: anExtent [
	UserPos := aPoint.
	UserSize := anExtent.
]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> centerOnScreen [
	super centerOnScreen.
	self updateResizeMorph
]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> definition: aCustomBlockDefinition [

	definition := aCustomBlockDefinition.
	template := CustomCommandBlockMorph template.
	template receiver: receiver.
	template userSpec: definition userSpec.
	bin addMorph:(template position: bin position + (10@10)).
	self buildScript.
	self buildVariables.
	self buildAtomicityToggle.
	self buildAnswerField.
]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> extent: aPoint [
	
	| w newExtent min|

	min := self class minExtent.

	newExtent := aPoint max: min.

	bounds extent = newExtent ifFalse: [
		self changed.
		bounds := bounds topLeft extent: newExtent.
		self layoutChanged.
		self changed].

	self fixLayoutForExtent: newExtent.

	UserPos isNil & resizeOffset isNil ifTrue: [
		w := self world.
		w ifNotNil: [self position: w center - (self extent // 2)]].  "center on screen"

	self keepOnScreen

]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> fixLayoutForExtent: aPoint [

	super fixLayoutForExtent: aPoint.

	titleBin ifNotNil: [ titleBin width: aPoint x - 40 ].

	editor ifNil: [^self ].

	editor extent: aPoint - (65 @ 105).

	self updateResizeMorph
]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> getUserResponse [
	"Wait for the user to respond, then report their response. The symbol #cancel is returned if the user wishes to cancel the operation. True/false is returned if they respond yes/no, and a string is returned if this this a string input dialog and they don't cancel."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop."

	| w |
	self openInWorld.

	editor on: (initialClass methods detect: [:e | e selector = initialMethod  ])
							text: #sourceCode
							accept: nil
							readSelection: nil
							menu: nil.
	
	" onMethod: initialMethod ofClass: initialClass."

	UserPos isNil 
		ifTrue: [ self centerOnScreen ]
		ifFalse: [self snapToUserDimensions ].
		
	w := self world.
	self buttons size > 0 ifTrue: [
		w activeHand newKeyboardFocus: self buttons last].
	tabFields size > 0 ifTrue: [
		w activeHand newKeyboardFocus: (tabFields at: 1)].

	done := false.
	[done] whileFalse: [w doOneCycle].  "wait for user to press a button"

	^ response

]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> handlesMouseDown: evt [
	^true
]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> initialize [
	super initialize.
	self title: 'Elements Editor'.
	resizeMorph := PhratchResizeMorph ofType: #corner.
	
	editor := PluggableTextMorph new.

	mainColumn addMorph: editor.

	self addMorph: resizeMorph.



]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> justDroppedInto: aMorph event: evt [
	"Never embed myself in a morph (e.g. the Stage)."

	super justDroppedInto: aMorph event: evt.
	self keepOnScreen

]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> keepOnScreen [

	| min |
	min := self class minExtent.

	self left < 0 ifTrue: [ self left: 0].
	self top < 0 ifTrue: [ self top: 0].

	self right > Display extent x
		ifTrue: [ resizeOffset 
			ifNil: [ 
				self left: ((Display extent x - self width) max: 0).
				(self right > Display extent x and: [self width > min x])
					ifTrue: [self width: Display extent x - self left ]]
			ifNotNil: [self width: Display extent x - self left]].

	self bottom > Display extent y
		ifTrue: [ resizeOffset 
			ifNil: [	
				self top: ((Display extent y - self height) max: 0). 
				(self bottom > Display extent y and: [self height > min y])
					ifTrue: [self height: Display extent y - self top]]
			ifNotNil: [self height: Display extent y - self top]].


]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> mouseDown: evt [
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	| p |
	p := evt cursorPoint.
	((resizeMorph bounds expandBy: 4) containsPoint: p)
		ifFalse: [evt hand grabMorph: self]
		ifTrue: [resizeOffset := self bottomRight - p]

]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> mouseMove: evt [

	resizeOffset ifNotNil: [
		self extent: (evt cursorPoint - self topLeft) + resizeOffset ]


]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> mouseUp: evt [

	resizeOffset := nil.

]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> onMethod: sel ofClass: cls [

	initialClass := cls.
	initialMethod := sel.
	self 
		withButtonsForYes: false no: false okay: true cancel: false;
		getUserResponse

]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> rememberUserDimensions [
	self class setUserPos: self position size: self extent
]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> snapToUserDimensions [

	self extent: UserSize.
	UserPos ifNotNil: [
		self position: UserPos ].

]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> step [
	resizeOffset notNil | (owner isKindOf: HandMorph)
		ifTrue: [^self ].
	self keepOnScreen 

]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> updateResizeMorph [
	resizeMorph ifNotNil: [
		resizeMorph position: self bottomRight - "resizeMorph extent - " bottomRightForm width ]

]

{ #category : #'as yet unclassified' }
ElementsEditorFrameMorph >> yes [
	"Yes button was pressed."
	SyntaxElementMorph allSubInstances do: [:element |
		(element ownerThatIsA: ElementsMethodEditorMorph)
			ifNil: [element delete]].
	self rememberUserDimensions.
	super yes.
]
