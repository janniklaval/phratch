"
I present the Scratch stage all by itself on the screen in presentation mode.

"
Class {
	#name : #PhratchPresenterMorph,
	#superclass : #Morph,
	#instVars : [
		'frame',
		'stage',
		'buttons',
		'flagButton',
		'pauseButton',
		'offscreenWorld',
		'doubleSize',
		'mouseFocus',
		'mouseDownPoint',
		'dragOffset',
		'clickWasHandled',
		'mouseMoved',
		'lastStepTime'
	],
	#category : #'Phratch-UI-Panes'
}

{ #category : #initialization }
PhratchPresenterMorph >> beDoubleSize [

	doubleSize := true.
	ScriptablePhratchMorph doubleSize: true.

]

{ #category : #initialization }
PhratchPresenterMorph >> buttons [

	^ buttons

]

{ #category : #drawing }
PhratchPresenterMorph >> drawOn: aCanvas [
	| stageRect |
	stageRect := Rectangle
		center: stage center
		extent:
			(doubleSize
				ifTrue: [ 2 * stage extent ]
				ifFalse: [ stage extent ]).
	(self bounds areasOutside: stageRect) do: [ :r | aCanvas fillRectangle: r color: color ].
	(aCanvas clipRect intersects: stageRect)
		ifFalse: [ ^ self ].
	offscreenWorld invalidRect: aCanvas clipRect.
	offscreenWorld incrRedrawDouble: doubleSize
]

{ #category : #'button actions' }
PhratchPresenterMorph >> exitPresentation [

	self delete.
	frame exitPresentationMode.

]

{ #category : #geometry }
PhratchPresenterMorph >> extent: aPoint [

	super extent: aPoint.
	self fixLayout.

]

{ #category : #geometry }
PhratchPresenterMorph >> fixLayout [

	| stageExtent stageBox y totalW x |
	stageExtent := doubleSize ifTrue: [2 * stage extent] ifFalse: [stage extent].
	stageBox := Rectangle center: self center extent: stageExtent.
	stage owner center: self center.
	y := stageBox top - 24.
	buttons first position: (stageBox left + 5) @ y.  "exit presentation button"

	"other buttons"
	totalW := (buttons collect: [:b | b width] from: 2 to: buttons size) sum.
	x := stageBox right - totalW - (2 * (buttons size - 2)) - 5.
	buttons allButFirst do: [:b |
		b position: x@y.
		x := x + b width + 2].

	offscreenWorld redrawAll.

]

{ #category : #BYOB }
PhratchPresenterMorph >> frame [
	^ frame
]

{ #category : #initialization }
PhratchPresenterMorph >> frame: aPhratchFrameMorph [

	frame := aPhratchFrameMorph.
	stage := aPhratchFrameMorph workPane.

	"insert stage in an OffscreenWorldMorph to detect damage"
	offscreenWorld := OffscreenWorldMorph new on: stage.
	offscreenWorld frame: aPhratchFrameMorph.

]

{ #category : #'event handling' }
PhratchPresenterMorph >> handlesKeyboard: evt [
	^ true
]

{ #category : #'event handling' }
PhratchPresenterMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #initialization }
PhratchPresenterMorph >> initialize [

	| button |
	super initialize.
	self color: Color black.
	doubleSize := false.
	lastStepTime := IdentityDictionary new.

	buttons := #(
		(presentationExit	exitPresentation		'Exit presentation')
		(go					shoutGo				'Start green flag scripts')
		(pause				togglePause			'Pause/resume everything')
		(stop				stopAll				'Stop everything')
	) collect: [:spec |
		button := ToggleButton
			onForm: (PhratchFrameMorph skinAt: (spec first, 'ButtonBlackPressed'))
			offForm: (PhratchFrameMorph skinAt: (spec first, 'ButtonBlack'))
			overForm: (PhratchFrameMorph skinAt: (spec first, 'ButtonBlackPressed')).
		button
			target: self;
			actionSelector: spec second;
			isMomentary: true;
			actWhen: #buttonUp;
			setProperty: #balloonText toValue: spec third localized;
			drawToolTipAbove: true;
			off.
		#togglePause = spec second ifTrue: [pauseButton := button].
		#shoutGo = spec second ifTrue: [flagButton := button].
		button].

	buttons do: [:b | self addMorph: b].

]

{ #category : #'event handling' }
PhratchPresenterMorph >> keyStroke: evt [
	| prompter ch |
	prompter := stage submorphs detect: [ :m | m isKindOf: PhratchPrompterMorph ] ifNone: [ nil ].
	ch := evt keyValue.
	ch = 27
		ifTrue: [ ^ self exitPresentation ].	"escape"
	prompter
		ifNotNil: [ prompter dispatchKeyStroke: evt ]
		ifNil: [ 
			({3 . 13} includes: ch)
				ifTrue: [ ^ self shoutGo ].
			stage broadcastEventNamed: 'Phratch-KeyPressedEvent' with: evt ]
]

{ #category : #'event handling' }
PhratchPresenterMorph >> mouseDown: evt [
	"There are three possible cases: drag a sprite, and adjust a slider, and do nothing. To drag a sprite, set mouseFocus to the sprite and dragOffset to the cursor offset the sprite's position. To adjust a slider, set the mouseFocus to the slider and dragOffset to nil. To do nothing, set both to nil."

	| p adjustedEvt rootM |
	mouseFocus := nil.
	dragOffset := nil.
	clickWasHandled := false.
	mouseMoved := false.
	evt hand toolType: nil.

	p := mouseDownPoint := stage adjustedCursorPoint.
	adjustedEvt := evt copy cursorPoint: p.

	rootM := stage submorphs
		detect: [:m | (m containsPoint: p) & m isVisible]
		ifNone: [
			(stage containsPoint: p) ifTrue: [stage click: adjustedEvt].
			clickWasHandled := true.
			^ self].

	(rootM isKindOf: PhratchSpriteMorph) ifTrue: [
		rootM draggable
			ifTrue: [
				rootM holdSubsprites.
				rootM comeToFront.
				mouseFocus := rootM.
				dragOffset := rootM position - p]
			ifFalse: [
				rootM click: adjustedEvt.
				clickWasHandled := true].
		^ self].

	(rootM unlockedMorphsAt: p) do: [:m |
		(m handlesMouseDown: adjustedEvt) ifTrue: [
			mouseFocus := m.
			dragOffset := nil.
			mouseFocus mouseDown: adjustedEvt.
			^ self]].



]

{ #category : #'event handling' }
PhratchPresenterMorph >> mouseMove: evt [

	| p |
	p := stage adjustedCursorPoint.
	p = mouseDownPoint ifFalse: [mouseMoved := true].
	mouseFocus ifNotNil: [
		dragOffset
			ifNil: [mouseMoved ifTrue: [mouseFocus mouseMove: (evt copy cursorPoint: p)]]
			ifNotNil: [mouseFocus position: p + dragOffset]].


]

{ #category : #'event handling' }
PhratchPresenterMorph >> mouseUp: evt [

	| p |

	self mouseMove: evt.

	stage allMorphsDo: [:m | 
		(m isKindOf: PhratchSpriteMorph) ifTrue: [
			m releaseSubsprites.
			m xpos: m xpos.
			m ypos: m ypos ]].

	clickWasHandled ifTrue: [^ self].

	p := stage adjustedCursorPoint.
	mouseFocus ifNotNil: [
		mouseMoved ifFalse: [mouseFocus click: (MorphicEvent new cursorPoint: p)]].

	mouseFocus := nil.
	dragOffset := nil.


]

{ #category : #'event handling' }
PhratchPresenterMorph >> processKeyboardEvents [

	| prompter evt ch |
	prompter := stage submorphs detect: [:m | m isKindOf: PhratchPrompterMorph] ifNone: [nil].
	World hands do: [:h |
		[(evt := h nextUnclaimedKeystrokeOrNil) notNil] whileTrue: [
			ch := evt keyValue.
			ch = 27 ifTrue: [^ self exitPresentation].  "escape"
			prompter
				ifNotNil: [
					prompter dispatchKeyStroke: evt]
				ifNil: [
					({3 . 13} includes: ch) ifTrue: [^ self shoutGo].
					stage broadcastEventNamed: 'Phratch-KeyPressedEvent' with: evt]]].

]

{ #category : #'button actions' }
PhratchPresenterMorph >> shoutGo [

	frame ifNotNil: [frame shoutGo].
	flagButton on.
	self showPause.
	World displayWorldSafely.  "force button flash"
	(Delay forMilliseconds:  20) wait.

]

{ #category : #'button actions' }
PhratchPresenterMorph >> showPause [

	pauseButton
		onForm: (PhratchFrameMorph skinAt: #pauseButtonBlackPressed)
		offForm: (PhratchFrameMorph skinAt: #pauseButtonBlack)
		overForm: (PhratchFrameMorph skinAt: #pauseButtonBlackPressed)

]

{ #category : #'button actions' }
PhratchPresenterMorph >> showPlay [

	pauseButton
		onForm: (PhratchFrameMorph skinAt: #playButtonBlackPressed)
		offForm: (PhratchFrameMorph skinAt: #playButtonBlack)
		overForm: (PhratchFrameMorph skinAt: #playButtonBlackPressed)

]

{ #category : #BYOB }
PhratchPresenterMorph >> stage [
	^ stage
]

{ #category : #stepping }
PhratchPresenterMorph >> step [
	"Run each process until it gives up control, then filter out any processes that have terminated."

	| screenExtent |
	screenExtent := DisplayScreen actualScreenSize.
	((self position = (0@0)) and: [self extent = screenExtent]) ifFalse: [
		self position: 0@0.
		^ self extent: screenExtent].

	ScriptablePhratchMorph phratchOrigin: stage center.

	self processKeyboardEvents.
	stage stepProcesses.
	stage step.
	self stepSubmorphs.
	offscreenWorld incrRedrawDouble: doubleSize.
	
	World fullRepaintNeeded.
	
	stage processesToRun size > 0
		ifTrue: [flagButton on]
		ifFalse: [flagButton off. self showPause].

]

{ #category : #stepping }
PhratchPresenterMorph >> stepSubmorphs [
	"Run my submorph 'step' methods if their time has come."

	| now lastTime |
	now := Time millisecondClockValue.
	stage submorphsDo: [:topM |
		topM allMorphsDo: [:m |
			lastTime := lastStepTime at: m ifAbsent: [-1000000].
			((now - lastTime) > m stepTime) ifTrue: [
				m step.
				lastStepTime at: m put: now]]].

]

{ #category : #stepping }
PhratchPresenterMorph >> stepTime [
	"Every screen update cycle."

	^ 0

]

{ #category : #'button actions' }
PhratchPresenterMorph >> stopAll [

	frame ifNotNil: [frame stopAll].


]

{ #category : #'button actions' }
PhratchPresenterMorph >> togglePause [

	stage togglePause.
	stage isPaused
		ifTrue: [self showPlay]
		ifFalse: [self showPause]

]
