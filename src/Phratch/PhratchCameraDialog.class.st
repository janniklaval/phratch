Class {
	#name : #PhratchCameraDialog,
	#superclass : #DialogBoxMorph,
	#instVars : [
		'viewFinderMorph',
		'frameForm',
		'client'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #intialization }
PhratchCameraDialog >> cameraButton [

	| onForm offForm button overForm |
	onForm := PhratchFrameMorph skinAt: #dialogButtonFrameOver.
	offForm := PhratchFrameMorph skinAt: #dialogButtonFrame.
	overForm := PhratchFrameMorph skinAt: #dialogButtonFrame.

	button := ResizableToggleButton new
		offForm: offForm
		onForm: onForm
		overForm: overForm.

	^ button
		padding: 39@22;
		icon: (PhratchFrameMorph skinAt: #camera);
		target: self;
		actionSelector: #savePhoto;
		setLabelColor: (Color gray: 0.15); 
		yourself

]

{ #category : #accessing }
PhratchCameraDialog >> client: anObject [

	client := anObject.

]

{ #category : #'button ops' }
PhratchCameraDialog >> close [

	CameraPlugin closeCamera: 1.
	self cancelled.

]

{ #category : #intialization }
PhratchCameraDialog >> createButtons [
"Replace my current buttons with the ones specified."
	"Note: The button row morph was created by initialize; I just replace its contents with a new collection of buttons."

	| spacer |
	spacer := Morph new extent: 10@5; color: Color transparent; 
		yourself.
	buttonRow removeAllMorphs.

	buttonRow addMorphBack: (AlignmentMorph newSpacer: Color transparent).
	buttonRow addMorphBack: spacer.
	
	buttonRow addMorphBack: self cameraButton.
	buttonRow addMorphBack: spacer fullCopy.

	buttonRow addMorphBack: (self buttonLabel: 'Done' localized action: #close).
	buttonRow addMorphBack: spacer fullCopy.

	buttonRow submorphs do: [:b |
		(b isResizableToggleButton) ifTrue: [tabFields add: b]].

]

{ #category : #intialization }
PhratchCameraDialog >> initialize [
	super initialize.
	self title: 'Camera' translated.
	self createButtons.
	viewFinderMorph := ImageMorph new form: (Form extent: 320 @ 240 depth: 2) fillBlack.
	mainColumn
		addMorph:
			(Morph new
				extent: 10 @ 12;
				color: Color transparent;
		yourself).
	mainColumn addMorph: viewFinderMorph.
	mainColumn
		addMorph:
			(Morph new
				extent: 10 @ 18;
				color: Color transparent;
		yourself)
]

{ #category : #'event handling' }
PhratchCameraDialog >> keyStroke: evt [
	"	ch := evt unicodeChar.
	ch = 0 ifTrue: [ch := evt keyValue]."

	"escape key"

	| ch |
	ch := evt keyValue.
	ch = 32
		ifTrue: [ 
			"space key"
			self savePhoto.
			^ self ].
	ch = 27
		ifFalse: [ ^ self ].
	self escapeKeyPressed: evt.
	^ self
]

{ #category : #accessing }
PhratchCameraDialog >> openCamera [

	| desiredExtent w |
	desiredExtent := 320@240.
	(CameraPlugin openCamera: 1 width: desiredExtent x height: desiredExtent y) ifNotNil: [
		CameraPlugin waitForCameraStart.
		frameForm := Form extent: (CameraPlugin frameExtent: 1) depth: 32].

	viewFinderMorph form: (Form extent: 320@240 depth: 32) fillBlack.
	self step.
	self extent: self extent.

	(w := self world) ifNotNil: [w activeHand newKeyboardFocus: self].

]

{ #category : #'button ops' }
PhratchCameraDialog >> savePhoto [

	client ifNil: [^ self].

	frameForm
		ifNil: [client savePhoto: viewFinderMorph form deepCopy]
		ifNotNil: [client savePhoto: frameForm deepCopy].

]

{ #category : #stepping }
PhratchCameraDialog >> step [
	| w n outF |
	(w := self world) ifNotNil: [ w activeHand newKeyboardFocus: self ].
	frameForm ifNil: [ ^ self ].
	n := CameraPlugin getFrameForCamera: 1 into: frameForm bits.
	n > 0
		ifFalse: [ ^ self ].
	outF := viewFinderMorph form.
	(WarpBlt toForm: outF)
		sourceForm: frameForm;
		cellSize: 1;
		combinationRule: Form over;
		copyQuad: frameForm boundingBox innerCorners toRect: outF boundingBox.	"installs a new colormap if cellSize > 1"
	viewFinderMorph changed
]

{ #category : #stepping }
PhratchCameraDialog >> stepTime [

	^ 0

]
