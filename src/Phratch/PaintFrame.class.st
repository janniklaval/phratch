"
I am the top-level of the paint editor. I have the following morphic compontents:

	canvasMorph			the area in which drawing is done
	paletteMorph			a palette of painting controls
	hScrollbar				horizontal scrollbar
	vScrollbar				vertical scrollbar
	transformButtons		an Array of button morphs for image transforms (flip, etc.)
	canvasButtons			an Array of button morphs for image transforms (flip, etc.)
	fileButtons				an Array of button morphs for import/export
	colorSquarePicker		an array of color squares
	colorPicker				a continuous color palette
	scaleMorph				string showing the current scale
	scaleMenuBar			menu bar frame round the scaleMorph

My other instance variables are:

	canvasFrame			the frame around canvasMorph
	scratchFrame			the ScratchFrame that created me (optional)
	originalObject			the source of the form being edited; informed if ok button pressed
	oldCostumeName			name of the Scratch costume being edited (optional)
	deleteSpriteOnCancel		true if operation is ""paint a new sprite"" (optional)

The optional values are not needed when editing a non-Scratch object such as an ImageMorph.

"
Class {
	#name : #PaintFrame,
	#superclass : #DialogBoxMorph,
	#instVars : [
		'canvasMorph',
		'paletteMorph',
		'hScrollbar',
		'vScrollbar',
		'transformButtons',
		'fileButtons',
		'colorSquarePicker',
		'colorPicker',
		'zoomBar',
		'canvasFrame',
		'originalObject',
		'oldCostumeName',
		'deleteSpriteOnCancel',
		'setRotationCenterMorph',
		'setRotationCenterButton',
		'colorPickerButton',
		'phratchFrame'
	],
	#classVars : [
		'ColorPicker',
		'SquareColorPicker'
	],
	#category : #'Phratch-Paint'
}

{ #category : #'instance creation' }
PaintFrame class >> new [

	^ super new
		withButtonsForYes: false
			no: false
			okay: true
			cancel: true;
		title: 'Paint Editor' localized;
		extent: 800 @ 490;
		fixLayout;
		yourself

]

{ #category : #initialization }
PaintFrame >> addButtons [

	| b |
	fileButtons := AlignmentMorph newRow
		color: Color transparent;
		vResizing: #rigid;
		width: 233;
		inset: 0; 
		yourself.

	b := self makeButtonLabel: 'Import' selector:  #import.
	b setProperty: #balloonText toValue: 'Import an image on top of your current canvas' localized.
	fileButtons addMorphBack: b.

	b := ResizableToggleButton new
		offForm: (PhratchFrameMorph skinAt: #paintUtilityButton)
			onForm: (PhratchFrameMorph skinAt: #paintUtilityButtonPressed);
		label: 'Clear' localized font: (PhratchFrameMorph getFont: #PaintUtilityButton);
		target: canvasMorph;
		actionSelector: #eraseAll;
		setProperty: #balloonText toValue: 'Clear canvas' localized; 
		yourself.
	fileButtons addMorphBack: b.

	b := self makeButtonLabel: 'Undo' selector:  #undo.
	b setProperty: #balloonText toValue: 'Undo' localized.
	fileButtons addMorphBack: (AlignmentMorph newSpacer: Color transparent).
	fileButtons addMorphBack: b.

	b := self makeButtonLabel: 'Redo' selector:  #redo.
	b setProperty: #balloonText toValue: 'Redo' localized.
	fileButtons addMorphBack: b.

	self addMorph: fileButtons.
	self addMorph: self makeZoomBar.

]

{ #category : #initialization }
PaintFrame >> addColorChoosers [
	"ColorPicker := SquareColorPicker := nil"

	"color picker is somewhat slow to create, so cache one and copy it"
	(ColorPicker isNil or:
	 [ColorPicker extent ~= (112@108)]) ifTrue: [
		ColorPicker := PaintColorPicker new initFromForm: (PhratchFrameMorph skinAt: #paintCanvasFrame);
			selector: #color1:;
			selector2: #color2:;
			extent: 120@108; 
		yourself].
	colorPicker := ColorPicker fullCopy target: canvasMorph palette.

	SquareColorPicker ifNil: [
		SquareColorPicker := PaintColorSquarePicker new initFromForm: (PhratchFrameMorph skinAt: #paintCanvasFrame);
			selector: #color1:;
			selector2: #color2:;
			extent: 120@108; 
		yourself].
	colorSquarePicker := SquareColorPicker fullCopy target: canvasMorph palette.

	colorPickerButton := ToggleButton
		onForm: (PhratchFrameMorph skinAt: #squareColorSquare)
		offForm: (PhratchFrameMorph skinAt: #colorSquare).
	colorPickerButton
		color: Color transparent;
		target: self;
		borderWidth: 0;
		actionSelector: #presentColorPicker;
		actWhen: #buttonUp.

	self addMorph: colorPickerButton.
	self addMorph: colorSquarePicker.

]

{ #category : #initialization }
PaintFrame >> addScrollbarsAndBevel [

	self addMorph: (
		hScrollbar := PhratchScrollBar newHorizontal
			target: canvasMorph;
			selector: #scrollFractionX:; 
		yourself).
	self addMorph: (
		vScrollbar := PhratchScrollBar newVertical
			target: canvasMorph;
			selector: #scrollFractionY:; 
		yourself).
	self addMorphBack: (
		canvasFrame := ImageFrameMorph new
			initFromForm: (PhratchFrameMorph skinAt: #paintCanvasFrame);
			extent: canvasMorph extent + (8@8); 
		yourself).

]

{ #category : #initialization }
PaintFrame >> addSetRotationCenterButton [

	| setRotationLabel spacer font |

	setRotationCenterMorph := AlignmentMorph newRow
		cellPositioning: #leftCenter;
		color: Color transparent;
		hResizing: #shrinkWrap;
		centering: #center; 
		yourself.

	"make components"
	setRotationCenterButton := ToggleButton
		onForm: (PhratchFrameMorph skinAt: #paintSetRotCenterButtonPressed)
		offForm: (PhratchFrameMorph skinAt: #paintSetRotCenterButton).
	setRotationCenterButton
		target: paletteMorph;
		actionSelector: #toggleRotationPoint;
		setProperty: #balloonText toValue: 'Position the cross-hair to set the rotation center' localized.
	spacer := Morph new extent: 6@3; color: Color transparent; 
		yourself.
	setRotationLabel := StringMorph contents: 'Set costume center' localized.
	font := (PhratchFrameMorph getFont: #PaintSetRotationCenter).
	setRotationLabel font: font; color: Color gray darker.

	"add components"
	setRotationCenterMorph
		addMorphBack: setRotationCenterButton;
		addMorphBack: spacer;
		addMorphBack: setRotationLabel.

	setRotationCenterMorph privateFullBounds: nil.

	"add bar to frame"
	self addMorph: setRotationCenterMorph.

]

{ #category : #initialization }
PaintFrame >> addTransformButtons [

	| specs b |
	specs := #(
		(paintGrow				enlarge		'Grow')
		(paintShrink			shrink		'Shrink')
		-
		(paintRotateLeft			rotateCCW	'Rotate counter-clock-wise')
		(paintRotateRight		rotateCW	'Rotate clock-wise')
		-
		(paintFlipVertical		flipH		'Flip horizontally')
		(paintFlipHorizontal		flipV		'Flip vertically')
	).

	transformButtons := AlignmentMorph newRow
		cellPositioning: #leftCenter;
		color: Color transparent;
		inset: 0;
		vResizing: #shrinkWrap;
		centering: #center;
		yourself.

	specs do: [:n |
		n = #-
			ifTrue: [
				transformButtons addMorphBack: (Morph new extent: 3@10; color: Color transparent; 
		yourself)]
			ifFalse: [
				b := ToggleButton new
					onForm: (PhratchFrameMorph skinAt: ((n at: 1), 'ButtonPressed'))
						offForm: (PhratchFrameMorph skinAt: ((n at: 1), 'Button'))
						overForm: (PhratchFrameMorph skinAt: ((n at: 1), 'Button'));
					target: canvasMorph;
					isMomentary: true;
					toggleMode: false;
					actionSelector: (n at: 2);
					setProperty: #balloonText toValue: (n at: 3) localized; 
		yourself.
				transformButtons addMorphBack: b]].

	self addMorph: transformButtons.

]

{ #category : #drawing }
PaintFrame >> areasRemainingToFill: aRectangle [
	"Drawing optimization. If damage is within my bounds, don't drawn anything below me."

	((bounds insetBy: 15) containsRect: aRectangle)
		ifTrue: [^ #()]
		ifFalse: [^ Array with: aRectangle].


]

{ #category : #interaction }
PaintFrame >> cancelled [
	"Cancel button was pressed. Cancel painting without saving."

	oldCostumeName ifNotNil: [
		originalObject ifNotNil: [
			originalObject revertToCostume: oldCostumeName.
			deleteSpriteOnCancel ifTrue: [originalObject deleteSprite]]].

	self exitPaintEditor.
	super cancelled.

]

{ #category : #'entry points' }
PaintFrame >> clearRotationCenter [
	"Clear the rotation center. Used when making a new drawing."

	canvasMorph clearRegistrationPoint.

]

{ #category : #drawing }
PaintFrame >> drawSubmorphsOn: aCanvas [
	"Optimization: If change is only within PaintCanvas, only redraw that."

	(canvasMorph bounds containsRect: aCanvas clipRect) ifTrue: [
		 aCanvas fullDrawMorph: canvasMorph.
		^ self].

	super drawSubmorphsOn: aCanvas.

]

{ #category : #other }
PaintFrame >> exitPaintEditor [

	phratchFrame ifNotNil: [phratchFrame paintingInProgress: false].
	World ifNotNil: [World activeHand turnOffGridding; showTemporaryCursor: nil].

]

{ #category : #other }
PaintFrame >> export [
	| triple form textBox fName f |
	triple := self newFormTextBoxAndRegPoint.
	triple ifNil: [^ PhratchError error: 'beep'. ].	"empty drawing"
	form := triple first.
	textBox := triple second.
	(textBox isNil or: [ textBox contents isEmpty ])
		ifFalse: [ 
			form := form deepCopy.
			textBox drawTextOn: (FormCanvas on: form) ].
	fName := ''.
	fName := PhratchFileChooserDialog chooseNewFileDefault: fName title: 'File Name?' type: #costume.
	fName = #cancelled
		ifTrue: [ ^ self ].
	fName size = 0
		ifTrue: [ ^ self ].	"make sure that file can be created"
	f := StandardFileStream newPhratchFileNamed: fName.
	f ifNil: [ ^ self ].
	f close.
	f delete.
	"form colorsUsed size < 255
		ifTrue: [ 
			fName := (fName asLowercase endsWith: '.gif')
				ifTrue: [ fName ]
				ifFalse: [ fName , '.gif' ].
			GIFReadWriter putForm: form colorReduced8Bit onFileNamed: fName.
			^ self ]."
	fName := (fName asLowercase endsWith: '.bmp')
		ifTrue: [ fName ]
		ifFalse: [ fName , '.bmp' ].
	(form asFormOfDepth: 32) writeBMPFileNamed: fName
]

{ #category : #geometry }
PaintFrame >> extent: aPoint [

	super extent: aPoint.
	self fixLayout.

]

{ #category : #geometry }
PaintFrame >> fixLayout [

	canvasMorph ifNil: [^ self].
	canvasMorph position: (self right - canvasMorph width - 55)@(self top + 42).
	paletteMorph position:
		(self left + 20)@(canvasMorph top + 85).
	hScrollbar
		position: canvasMorph bottomLeft + (0@9);
		width: canvasMorph width.
	vScrollbar
		position: canvasMorph topRight + (9@0);
		height: canvasMorph height.

	titleBin left: self left + ((self width - titleBin width) // 2) - 5.
	fileButtons position: (self left + 20)@(canvasMorph top +45).
	transformButtons position: (self left + 18)@(canvasMorph top).
	colorSquarePicker position: (self left + 25)@(paletteMorph bottom - 55).
	colorPickerButton position: (colorSquarePicker right + 5)@(colorSquarePicker top + 30).
	setRotationCenterMorph position: (self left + (((canvasMorph left - self left) - setRotationCenterMorph width) // 2)) @ (colorSquarePicker bottom - 3).
	buttonRow position: (self right - buttonRow width - 30)@(self bottom - buttonRow height - 22).
	canvasFrame position: canvasMorph position - (4@4).
	zoomBar position: (canvasMorph left - zoomBar width - 15)@(setRotationCenterMorph top - 21).

]

{ #category : #drawing }
PaintFrame >> fullDrawOn: aCanvas [
	"Optimization. Don't draw myself if damage is only within the paint canvas."

	self isHidden ifTrue: [^ self].
	(self hasProperty: #errorOnDraw) ifTrue:[^ self drawErrorOn: aCanvas].
	(canvasMorph bounds containsRect: aCanvas clipRect)
		ifFalse: [aCanvas drawMorph: self].
	self drawSubmorphsOn:aCanvas.

]

{ #category : #initialization }
PaintFrame >> initialize [

	super initialize.
	self addMorph: (
		canvasMorph := PaintCanvas new
			extent: PhratchFrameMorph workpaneExtent;
			editForm: ((Form extent: PaintCanvas canvasExtent depth: 32) fillColor: Color transparent); 
		yourself).
	buttonRow ifNotNil: [
		buttonRow delete.
		self addMorph: buttonRow].
	self addMorph: (paletteMorph := canvasMorph palette).
	self addScrollbarsAndBevel.
	self addButtons.
	self addSetRotationCenterButton.
	self addTransformButtons.
	self addColorChoosers.

]

{ #category : #other }
PaintFrame >> justDroppedInto: aMorph event: evt [
	"almost off the screen; re-center"

	| r |
	super justDroppedInto: aMorph event: evt.
	owner = World
		ifFalse: [ ^ self ].
	r := self bounds intersect: World bounds.
	r width > 50 & (r height > 50)
		ifTrue: [ ^ self ].
	self position: World bounds center - (self extent // 2).
	self bottom > World bottom
		ifTrue: [ self top: World bottom - (self height - 20) ]
]

{ #category : #initialization }
PaintFrame >> makeButtonLabel: aString selector: sel [

	| font |
	font := (PhratchFrameMorph getFont: #PaintUtilityButton).
	^ ResizableToggleButton new
		offForm: (PhratchFrameMorph skinAt: #paintUtilityButton)
			onForm: (PhratchFrameMorph skinAt: #paintUtilityButtonPressed);
		label: aString localized font: font;
		target: canvasMorph;
		actionSelector: sel; 
		yourself

]

{ #category : #initialization }
PaintFrame >> makeZoomBar [

	| b t |
	zoomBar := AlignmentMorph new
		color: Color transparent;
		centering: #bottomRight;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap; 
		yourself.

	#(out in) do: [:n |
		b := ToggleButton
			onForm: (PhratchFrameMorph skinAt: ('paintZoom', n asString capitalized, 'Button'))
			offForm: (PhratchFrameMorph skinAt: ('paintZoom', n asString capitalized, 'Button')).
		b
			target: self;
			actionSelector: #scaleCanvas:;
			arguments: (Array with: n);
			borderWidth: 0;
			setProperty: #balloonText toValue: ('Zoom ', n asString) localized.
		zoomBar addMorphBack: b.

		#out = n ifTrue: [
			#(1 2 4 8 16) do: [:scale |
				t := ToggleButton
					onForm: (PhratchFrameMorph skinAt: ('zoom', scale asString, 'ButtonPressed'))
					offForm: (PhratchFrameMorph skinAt: ('zoom', scale asString, 'Button')).
				t
					target: self;
					actionSelector: #scaleCanvas:;
					arguments: (Array with: scale);
					setProperty: #balloonText toValue: scale asString, 'x'.
				zoomBar addMorphBack: t.
				zoomBar addMorphBack: (Morph new extent: 2@2; color: Color transparent; 
		yourself)]]].

	zoomBar privateFullBounds: nil; fullBounds.

	^ zoomBar

]

{ #category : #other }
PaintFrame >> newFormTextBoxAndRegPoint [
	"Answer an array containing my current canvasForm, text box, and registration point. The text box is sized to fit the text or is nil if it is empty."

	| textBox r newForm regPoint |
	canvasMorph commitMove.

	textBox := canvasMorph canvasTextBox.
	textBox
		textColor: canvasMorph textColor";
		fitContents".
	textBox contents isEmpty ifTrue: [textBox := nil].

	(originalObject isPhratchStageMorph)
		ifTrue: [
			r := 0@0 extent: PhratchFrameMorph workpaneExtent.
			newForm := Form extent: r extent depth: 32.
			newForm fillWhite.
			canvasMorph canvasForm
				displayOn: newForm
				at: (newForm extent - canvasMorph canvasForm extent // 2)
				rule: Form paint]
		ifFalse: [
			r := canvasMorph canvasForm rectangleEnclosingPixelsNotOfColor: Color transparent.
			((r area = 0) & textBox isNil) ifTrue: [^ nil].  "empty canvas and no text"
			r area = 0 ifTrue: [r := textBox position extent: 1@1].  "text only"
			textBox ifNotNil: [
				r := r merge: textBox bounds.
				textBox position: textBox position - r origin].
			newForm := Form extent: r extent depth: 32.
			canvasMorph canvasForm displayOn: newForm at: r origin negated rule: Form paint].

	regPoint := canvasMorph registrationPoint.
	regPoint
		ifNil: [regPoint := r extent // 2]
		ifNotNil: [regPoint := regPoint - r topLeft].

	^ Array with: newForm with: textBox with: regPoint

]

{ #category : #'entry points' }
PaintFrame >> oldCostumeName: aString deleteOnCancel: aBoolean [
	"Set state used when editing a Phratch costumes or painting a new sprite."

	oldCostumeName := aString.
	deleteSpriteOnCancel := aBoolean.
	aBoolean ifTrue: [canvasMorph editForm: (Form extent: 4@4 depth: 8)].  "clears cat"

]

{ #category : #accessing }
PaintFrame >> originalObject [

	^ originalObject
]

{ #category : #'entry points' }
PaintFrame >> phratchFrame: aPhratchFrameMorph [

	phratchFrame := aPhratchFrameMorph.

]

{ #category : #other }
PaintFrame >> presentColorPicker [

	colorPicker owner
		ifNil: [self addMorph: colorPicker.
			colorPicker position: paletteMorph bottomLeft - (0@55) + (5@0)]
		ifNotNil: [colorPicker delete].

]

{ #category : #other }
PaintFrame >> scaleCanvas: aNumberOrSymbol [

	| numToScale |

	numToScale := aNumberOrSymbol.
	(aNumberOrSymbol == #in) ifTrue: [numToScale := (canvasMorph scale*2 min: 16)].
	(aNumberOrSymbol == #out) ifTrue: [numToScale := (canvasMorph scale//2 max: 1)].
	
	zoomBar allMorphsDo: [:b |
		(b isToggleButton) ifTrue: [
			b arguments first = numToScale ifTrue: [b on] ifFalse: [b off]]].

	canvasMorph scale: numToScale.

]

{ #category : #accessing }
PaintFrame >> setRotationCenterButton [

	^ setRotationCenterButton
]

{ #category : #geometry }
PaintFrame >> updateScrollbars [
	"Update my scrollbars based on my current scale."

	| visible scaledTotal |
	visible := canvasMorph extent.
	scaledTotal := canvasMorph canvasForm extent * canvasMorph scale asFloat.
	hScrollbar
		percentVisible: visible x / scaledTotal x;
		scrollFraction: canvasMorph scrollFractionX.
	vScrollbar
		percentVisible: visible y / scaledTotal y;
		scrollFraction: canvasMorph scrollFractionY.

]

{ #category : #'entry points' }
PaintFrame >> withStartingObject: anObject [
	"Start editing the given object's form (i.e. it's current costume, if it is a PhratchSpriteMorph)."

	| costume |
	originalObject := anObject.
	(anObject respondsTo: #costume)
		ifTrue: [  "editing a Phratch object"
			costume := anObject costume.
			canvasMorph
				editForm: costume form
				regPoint: costume rotationCenter
				textBox: costume textBox
				isStage: (anObject isPhratchStageMorph)]
		ifFalse: [  "editing a non-Phratch object"
			canvasMorph editForm: anObject form].

	(anObject isPhratchStageMorph)
		ifTrue: [self scaleCanvas: 1]
		ifFalse: [self scaleCanvas: 2].
	World activeHand newKeyboardFocus: canvasMorph.


]

{ #category : #interaction }
PaintFrame >> yes [
	"Save the edited form back to the original object."

	| triple |
	originalObject ifNil: [^ self exitPaintEditor].

	triple := self newFormTextBoxAndRegPoint.
	triple ifNil: [ PhratchError error: 'beep'.Beeper  beep. ^self cancelled].

	originalObject
		editedForm: triple first textBox: triple second;
		rotationCenter: triple third.
	self exitPaintEditor.
	super yes.

]
