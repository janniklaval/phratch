Class {
	#name : #DebuggerFrameMorph,
	#superclass : #DialogBoxMorph,
	#instVars : [
		'resizeMorph',
		'resizeOffset',
		'contentsFrame',
		'contentsMorph',
		'scroller',
		'thread',
		'varButton',
		'returnValue'
	],
	#classVars : [
		'UserPos',
		'UserSize'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #'initialize-release' }
DebuggerFrameMorph class >> initialize [
	"DebuggerFrameMorph initialize"
	self resetDimensions
]

{ #category : #accessing }
DebuggerFrameMorph class >> minExtent [
	^350 @ 180.
]

{ #category : #'initialize-release' }
DebuggerFrameMorph class >> resetDimensions [
	UserPos := nil.
	UserSize := self minExtent.
]

{ #category : #'initialize-release' }
DebuggerFrameMorph class >> setUserPos: aPoint size: anExtent [
	UserPos := aPoint.
	UserSize := anExtent.
]

{ #category : #geometry }
DebuggerFrameMorph >> centerOnScreen [
	super centerOnScreen.
	self updateResizeMorph
]

{ #category : #initialization }
DebuggerFrameMorph >> createButtons [
	"Replace my current buttons with the ones specified."
	"Note: The button row morph was created by initialize; I just replace its contents with a new collection of buttons."

	| spacer jump cb |
	spacer := Morph new extent: 10@5; color: Color transparent;
		yourself.
	buttonRow removeAllMorphs.

	buttonRow addMorphBack: (self buttonLabel: '>' action: #resume).

	buttonRow addMorphBack: (self buttonLabel: '>|' action: #stepNext).

	buttonRow addMorphBack: (jump := (self buttonLabel: '>>' action: #jumpOver)).
	buttonRow addMorphBack: spacer fullCopy.

	buttonRow addMorphBack: (varButton := (self buttonLabel: 'variables' localized action: #varMenu)).
	buttonRow addMorphBack: spacer fullCopy.

	buttonRow submorphs do: [:b |
		(b isKindOf: ResizableToggleButton) ifTrue: [tabFields add: b]].

	cb := thread currentBlock.
	cb nextBlock ifNil: [^jump isHidden: true].
	({CBlockMorph. IfElseBlockMorph. CustomCommandBlockMorph. CustomReporterBlockMorph} 
		includes: cb class) 
			ifFalse: [jump isHidden: true]
]

{ #category : #geometry }
DebuggerFrameMorph >> extent: aPoint [
	
	| newExtent min|

	min := self class minExtent.
"	contentsMorph ifNotNil: [
		min := min + contentsMorph extent + (0 @ 5)]."

	newExtent := aPoint max: min.

	bounds extent = newExtent ifFalse: [
		self changed.
		bounds := bounds topLeft extent: newExtent.
		self layoutChanged.
		self changed].

	self fixLayoutForExtent: newExtent.

	self keepOnScreen

]

{ #category : #geometry }
DebuggerFrameMorph >> fixLayoutForExtent: aPoint [

	super fixLayoutForExtent: aPoint.

	titleBin ifNotNil: [ titleBin width: aPoint x - 40 ].


	contentsFrame ifNil: [^self ].

	contentsFrame extent: aPoint - (65 @ 105).
	scroller extent: contentsFrame extent.
"
	contentsMorph position: contentsFrame position + (contentsFrame extent - contentsMorph extent // 2).
"

	self updateResizeMorph
]

{ #category : #interaction }
DebuggerFrameMorph >> getUserResponse [
	"Wait for the user to respond, then report their response. The symbol #cancel is returned if the user wishes to cancel the operation. True/false is returned if they respond yes/no, and a string is returned if this this a string input dialog and they don't cancel."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop."

	| w |
	self openInWorld.
	UserPos isNil 
		ifTrue: [ self centerOnScreen ]
		ifFalse: [self snapToUserDimensions ].
		
	w := self world.
	self buttons size > 0 ifTrue: [
		w activeHand newKeyboardFocus: self buttons last].
	tabFields size > 0 ifTrue: [
		w activeHand newKeyboardFocus: (tabFields at: 1)].

	done := false.
	[done] whileFalse: [w doOneCycle].  "wait for user to press a button, this effectively pauses all other threads as well -jens"

	^ response

]

{ #category : #'event handling' }
DebuggerFrameMorph >> handlesMouseDown: evt [
	^true
]

{ #category : #testing }
DebuggerFrameMorph >> hasVars [
	| vars env |
	returnValue ifNotNil: [ ^ true ].
	vars := (thread currentBlock receiver isKindOf: VariableFrame)
		ifTrue: [ thread currentBlock receiver ]
		ifFalse: [ thread temporaryVariables ].
	vars vars keys size > 0
		ifTrue: [ ^ true ].
	env := thread currentEnvironment.
	env
		ifNotNil: [ 
			env = vars
				ifFalse: [ 
					env vars keys size > 0
						ifTrue: [ ^ true ] ] ].
	^ false
]

{ #category : #initialization }
DebuggerFrameMorph >> initialize [
	super initialize.
	self title: 'Debugger' translated.
	resizeMorph := PhratchResizeMorph ofType: #corner.
	scroller := ScrollFrameMorph new
		growthFraction: 0.0;
		color: Color transparent;
		yourself.	"PhratchFrameMorph scriptsPaneColor"
	contentsMorph := ImageMorph new.
	contentsFrame := Morph new
		color: Color transparent;
		extent: 150 @ 80;
		yourself.
	scroller extent: contentsFrame extent.
	contentsFrame addMorph: scroller.
	scroller contents: contentsMorph.
	mainColumn addMorph: contentsFrame.
	self addMorph: resizeMorph
]

{ #category : #'BYOB-pause/resume' }
DebuggerFrameMorph >> jumpOver [
	thread jumpOver.
	self yes
]

{ #category : #'dropping/grabbing' }
DebuggerFrameMorph >> justDroppedInto: aMorph event: evt [
	"Never embed myself in a morph (e.g. the Stage)."

	super justDroppedInto: aMorph event: evt.
	self keepOnScreen

]

{ #category : #nesting }
DebuggerFrameMorph >> keepOnScreen [

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
DebuggerFrameMorph >> mouseDown: evt [
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	| p |
	p := evt cursorPoint.
	((resizeMorph bounds expandBy: 4) containsPoint: p)
		ifFalse: [evt hand grabMorph: self]
		ifTrue: [resizeOffset := self bottomRight - p]

]

{ #category : #'event handling' }
DebuggerFrameMorph >> mouseMove: evt [

	resizeOffset ifNotNil: [
		self extent: (evt cursorPoint - self topLeft) + resizeOffset ]


]

{ #category : #'event handling' }
DebuggerFrameMorph >> mouseUp: evt [

	resizeOffset := nil.

]

{ #category : #'instance creation' }
DebuggerFrameMorph >> on: aPhratchProcess [

	thread := aPhratchProcess.

	self 
		createButtons;
		updateContents;
		getUserResponse


]

{ #category : #handling }
DebuggerFrameMorph >> on: aPhratchProcess returnValue: obj [

	thread := aPhratchProcess.
	returnValue := obj.

	self 
		createButtons;
		updateContents;
		getUserResponse


]

{ #category : #build }
DebuggerFrameMorph >> rememberUserDimensions [
	self class setUserPos: self position size: self extent
]

{ #category : #handling }
DebuggerFrameMorph >> resume [
	thread resume.
	self yes
]

{ #category : #interaction }
DebuggerFrameMorph >> snapToUserDimensions [

	self extent: UserSize.
	UserPos ifNotNil: [
		self position: UserPos ].

]

{ #category : #'stepping and presenter' }
DebuggerFrameMorph >> step [
	resizeOffset notNil | (owner isKindOf: HandMorph)
		ifTrue: [^self ].
	self keepOnScreen 

]

{ #category : #stepping }
DebuggerFrameMorph >> stepNext [
	thread nextStep.
	self yes
]

{ #category : #initialization }
DebuggerFrameMorph >> updateContents [

	| block rcvr lbl |
	block := thread currentBlock.

	contentsMorph ifNil: [^self].
	block ifNotNil: [
		rcvr := block receiver.
		(rcvr respondsTo: #objName)
			ifTrue: [lbl := rcvr objName]
			ifFalse: [ 
				lbl := 'Debugger' localized.
				(block respondsTo: #variable) ifTrue: [
					lbl := block variable]].
		returnValue isNil
			ifTrue: [ self title: lbl]
			ifFalse: [ self title: lbl, ' ^'].
		contentsMorph form: block imageForm ].

	self hasVars ifFalse: [
		varButton isHidden: true ]

]

{ #category : #stepping }
DebuggerFrameMorph >> updateResizeMorph [
	resizeMorph ifNotNil: [
		resizeMorph position: self bottomRight - "resizeMorph extent - " bottomRightForm width ]

]

{ #category : #interaction }
DebuggerFrameMorph >> varMenu [
	| menu vars env mh mw |
	menu := MenuMorph new defaultTarget: self.
	returnValue
		ifNotNil: [ 
			menu add: 'report value' localized action: nil.
			menu addLine ].
	vars := (thread currentBlock receiver isKindOf: VariableFrame)
		ifTrue: [ thread currentBlock receiver ]
		ifFalse: [ thread temporaryVariables ].
	vars vars keys asSortedCollection do: [ :vname | menu add: vname  action: nil ].
	menu addLine.
	env := thread currentEnvironment.
	env
		ifNotNil: [ 
			env = vars
				ifFalse: [ env vars keys asSortedCollection do: [ :vname | menu add: vname action: nil ] ] ].
	menu build.
	mh := menu  height.
	mw := menu  width.
	menu popUpAt: (varButton left + ((varButton width - mw) // 2)) @ (varButton top - mh) inWorld: World
]

{ #category : #interaction }
DebuggerFrameMorph >> yes [
	"Yes button was pressed."

	self rememberUserDimensions.
	super yes.
]
