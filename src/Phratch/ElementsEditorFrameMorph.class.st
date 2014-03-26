Class {
	#name : #ElementsEditorFrameMorph,
	#superclass : #DialogBoxMorph,
	#instVars : [
		'editor',
		'initialClass',
		'initialMethod',
		'resizeMorph',
		'resizeOffset'
	],
	#classVars : [
		'UserPos',
		'UserSize'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #'initialize-release' }
ElementsEditorFrameMorph class >> initialize [
	"BlockEditorFrameMorph initialize"
	self resetDimensions
]

{ #category : #accessing }
ElementsEditorFrameMorph class >> minExtent [
	^500 @ 400.
]

{ #category : #'initialize-release' }
ElementsEditorFrameMorph class >> resetDimensions [
	UserPos := nil.
	UserSize := self minExtent.
]

{ #category : #'initialize-release' }
ElementsEditorFrameMorph class >> setUserPos: aPoint size: anExtent [
	UserPos := aPoint.
	UserSize := anExtent.
]

{ #category : #geometry }
ElementsEditorFrameMorph >> centerOnScreen [
	super centerOnScreen.
	self updateResizeMorph
]

{ #category : #accessing }
ElementsEditorFrameMorph >> definition: aCustomBlockDefinition [

	| definition template | 
	definition := aCustomBlockDefinition.
	template := CustomCommandBlockMorph template.
	template userSpec: definition userSpec. 

]

{ #category : #geometry }
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

{ #category : #geometry }
ElementsEditorFrameMorph >> fixLayoutForExtent: aPoint [

	super fixLayoutForExtent: aPoint.

	titleBin ifNotNil: [ titleBin width: aPoint x - 40 ].

	editor ifNil: [^self ].

	editor extent: aPoint - (65 @ 105).

	self updateResizeMorph
]

{ #category : #interaction }
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

{ #category : #'event handling' }
ElementsEditorFrameMorph >> handlesMouseDown: evt [
	^true
]

{ #category : #initialization }
ElementsEditorFrameMorph >> initialize [
	super initialize.
	self title: 'Elements Editor' translated.
	resizeMorph := PhratchResizeMorph ofType: #corner.
	editor := PluggableTextMorph new.
	mainColumn addMorph: editor.
	self addMorph: resizeMorph
]

{ #category : #'dropping/grabbing' }
ElementsEditorFrameMorph >> justDroppedInto: aMorph event: evt [
	"Never embed myself in a morph (e.g. the Stage)."

	super justDroppedInto: aMorph event: evt.
	self keepOnScreen

]

{ #category : #nesting }
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

{ #category : #'event handling' }
ElementsEditorFrameMorph >> mouseDown: evt [
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	| p |
	p := evt cursorPoint.
	((resizeMorph bounds expandBy: 4) containsPoint: p)
		ifFalse: [evt hand grabMorph: self]
		ifTrue: [resizeOffset := self bottomRight - p]

]

{ #category : #'event handling' }
ElementsEditorFrameMorph >> mouseMove: evt [

	resizeOffset ifNotNil: [
		self extent: (evt cursorPoint - self topLeft) + resizeOffset ]


]

{ #category : #'event handling' }
ElementsEditorFrameMorph >> mouseUp: evt [

	resizeOffset := nil.

]

{ #category : #accessing }
ElementsEditorFrameMorph >> onMethod: sel ofClass: cls [

	initialClass := cls.
	initialMethod := sel.
	self 
		withButtonsForYes: false no: false okay: true cancel: false;
		getUserResponse

]

{ #category : #build }
ElementsEditorFrameMorph >> rememberUserDimensions [
	self class setUserPos: self position size: self extent
]

{ #category : #interaction }
ElementsEditorFrameMorph >> snapToUserDimensions [

	self extent: UserSize.
	UserPos ifNotNil: [
		self position: UserPos ].

]

{ #category : #'stepping and presenter' }
ElementsEditorFrameMorph >> step [
	resizeOffset notNil | (owner isHandMorph)
		ifTrue: [^self ].
	self keepOnScreen 

]

{ #category : #stepping }
ElementsEditorFrameMorph >> updateResizeMorph [
	resizeMorph ifNotNil: [
		resizeMorph position: self bottomRight - "resizeMorph extent - " bottomRightForm width ]

]

{ #category : #interaction }
ElementsEditorFrameMorph >> yes [
	"Yes button was pressed."
	self rememberUserDimensions.
	super yes.
]
