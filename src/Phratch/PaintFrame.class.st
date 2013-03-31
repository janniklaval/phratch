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
		'canvasButtons',
		'fileButtons',
		'colorSquarePicker',
		'colorPicker',
		'zoomBar',
		'canvasFrame',
		'scratchFrame',
		'originalObject',
		'oldCostumeName',
		'deleteSpriteOnCancel',
		'setRotationCenterMorph',
		'setRotationCenterButton',
		'colorPickerButton'
	],
	#classVars : [
		'ColorPicker',
		'SquareColorPicker'
	],
	#category : #'Phratch-Paint'
}

{ #category : #'instance creation' }
PaintFrame class >> clearColorPickers [
	"self clearColorPickers"

	ColorPicker := SquareColorPicker := nil.

]

{ #category : #'instance creation' }
PaintFrame class >> new [

	^ super new
		withButtonsForYes: false no: false okay: true cancel: true;
		title: 'Paint Editor';
		extent: 800@490;
		fixLayout

]

{ #category : #initialization }
PaintFrame >> addButtons [

	| b |
	fileButtons := AlignmentMorph newRow
		color: Color transparent;
		vResizing: #rigid;
		width: 233;
		inset: 0.

	b := self makeButtonLabel: 'Import' selector:  #import.
	b setProperty: #balloonText toValue: 'Import an image on top of your current canvas' localized.
	fileButtons addMorphBack: b.

	b := ResizableToggleButton2 new
		offForm: (ScratchFrameMorph skinAt: #paintUtilityButton)
			onForm: (ScratchFrameMorph skinAt: #paintUtilityButtonPressed);
		label: 'Clear' localized font: (ScratchFrameMorph getFont: #PaintUtilityButton);
		target: canvasMorph;
		actionSelector: #eraseAll;
		setProperty: #balloonText toValue: 'Clear canvas' localized.
	fileButtons addMorphBack: (AlignmentMorph newSpacer: Color transparent).
	fileButtons addMorphBack: b.

	canvasButtons := AlignmentMorph newRow
		color: Color transparent;
		vResizing: #shrinkWrap;
		inset: 0.

	b := self makeButtonLabel: 'Undo' selector:  #undo.
	b setProperty: #balloonText toValue: 'Undo' localized.
	canvasButtons addMorphBack: b.

	b := self makeButtonLabel: 'Redo' selector:  #redo.
	b setProperty: #balloonText toValue: 'Redo' localized.
	canvasButtons addMorphBack: b.

	self addMorph: fileButtons.
	self addMorph: canvasButtons.
	self addMorph: self makeZoomBar.

]

{ #category : #initialization }
PaintFrame >> addColorChoosers [
	"ColorPicker := SquareColorPicker := nil"

	"color picker is somewhat slow to create, so cache one and copy it"
	(ColorPicker isNil or:
	 [ColorPicker extent ~= (112@108)]) ifTrue: [
		ColorPicker := PaintColorPicker new initFromForm: (ScratchFrameMorph skinAt: #paintCanvasFrame);
			selector: #color1:;
			selector2: #color2:;
			extent: 120@108].
	colorPicker := ColorPicker fullCopy target: canvasMorph palette.

	SquareColorPicker ifNil: [
		SquareColorPicker := PaintColorSquarePicker new initFromForm: (ScratchFrameMorph skinAt: #paintCanvasFrame);
			selector: #color1:;
			selector2: #color2:;
			extent: 120@108].
	colorSquarePicker := SquareColorPicker fullCopy target: canvasMorph palette.

	colorPickerButton := ToggleButton
		onForm: (ScratchFrameMorph skinAt: #squareColorSquare)
		offForm: (ScratchFrameMorph skinAt: #colorSquare).
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
		hScrollbar := ScratchScrollBar newHorizontal
			target: canvasMorph;
			selector: #scrollFractionX:).
	self addMorph: (
		vScrollbar := ScratchScrollBar newVertical
			target: canvasMorph;
			selector: #scrollFractionY:).
	self addMorphBack: (
		canvasFrame := ImageFrameMorph new
			initFromForm: (ScratchFrameMorph skinAt: #paintCanvasFrame);
			extent: canvasMorph extent + (8@8)).

]

{ #category : #initialization }
PaintFrame >> addSetRotationCenterButton [

	| setRotationLabel spacer font |

	setRotationCenterMorph := AlignmentMorph newRow
		cellPositioning: #leftCenter;
		color: Color transparent;
		hResizing: #shrinkWrap;
		centering: #center.

	"make components"
	setRotationCenterButton := ToggleButton
		onForm: (ScratchFrameMorph skinAt: #paintSetRotCenterButtonPressed)
		offForm: (ScratchFrameMorph skinAt: #paintSetRotCenterButton).
	setRotationCenterButton
		target: paletteMorph;
		actionSelector: #toggleRotationPoint;
		setProperty: #balloonText toValue: 'Position the cross-hair to set the rotation center' localized.
	spacer := Morph new extent: 6@3; color: Color transparent.
	setRotationLabel := ScratchStringMorph contents: 'Set costume center' localized.
	font := (ScratchFrameMorph getFont: #PaintSetRotationCenter).
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
		centering: #center.

	specs do: [:n |
		n = #-
			ifTrue: [
				transformButtons addMorphBack: (Morph new extent: 3@10; color: Color transparent)]
			ifFalse: [
				b := ToggleButton new
					onForm: (ScratchFrameMorph skinAt: ((n at: 1), 'ButtonPressed'))
						offForm: (ScratchFrameMorph skinAt: ((n at: 1), 'Button'))
						overForm: (ScratchFrameMorph skinAt: ((n at: 1), 'Button'));
					target: canvasMorph;
					isMomentary: true;
					toggleMode: false;
					actionSelector: (n at: 2);
					setProperty: #balloonText toValue: (n at: 3) localized.
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

	scratchFrame ifNotNil: [scratchFrame paintingInProgress: false].
	World ifNotNil: [World activeHand turnOffGridding; showTemporaryCursor: nil].

]

{ #category : #other }
PaintFrame >> export [

	| triple form textBox fName f |
	triple := self newFormTextBoxAndRegPoint.
	triple ifNil: [^ Beeper beep].  "empty drawing"
	form := triple first.
	textBox := triple second.
	(textBox isNil or: [textBox contents isEmpty]) ifFalse: [
		form := form deepCopy.
		textBox drawTextOn: (FormCanvas on: form)].

	fName := ''.
	fName := ScratchFileChooserDialog
		chooseNewFileDefault: fName
		title: 'File Name?'
		type: #costume.
	fName = #cancelled ifTrue: [^ self].
	fName size = 0 ifTrue: [^ self].

	"make sure that file can be created"
	f := StandardFileStream newScratchFileNamed: fName.
	f ifNil: [^ self].
	f close.
	
	f delete.

	form colorsUsed size < 255 ifTrue: [
		(fName asLowercase endsWith: '.gif')
			ifTrue: [fName := fName]
			ifFalse: [fName := fName, '.gif'].
		GIFReadWriter putForm: form colorReduced8Bit onFileNamed: fName.
		^ self].
	(fName asLowercase endsWith: '.bmp')
		ifTrue: [fName := fName]
		ifFalse: [fName := fName, '.bmp'].
	(form asFormOfDepth: 32) writeBMPFileNamed: fName.

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
	canvasButtons position: (self left + 20)@(canvasMorph top + 80).
	paletteMorph position:
		(self left + 20)@(canvasButtons bottom + 5).
	hScrollbar
		position: canvasMorph bottomLeft + (0@9);
		width: canvasMorph width.
	vScrollbar
		position: canvasMorph topRight + (9@0);
		height: canvasMorph height.

	titleBin left: self left + ((self width - titleBin width) // 2) - 5.
	fileButtons position: (self left + 20)@(canvasButtons top - 35).
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
			extent: ScratchFrameMorph workpaneExtent;
			editForm: ((Form extent: PaintCanvas canvasExtent depth: 32) fillColor: Color transparent)).
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

	| r |
	super justDroppedInto: aMorph event: evt.
	owner = World ifFalse: [^ self].

	r := self bounds intersect: World bounds.
	(r width > 50) & (r height > 50) ifFalse: [  "almost off the screen; re-center"
		self position: World bounds center - (self extent // 2).
		self bottom > World bottom ifTrue: [self top: World bottom - (self height - 20)]].

]

{ #category : #initialization }
PaintFrame >> makeButtonLabel: aString selector: sel [

	| font |
	font := (ScratchFrameMorph getFont: #PaintUtilityButton).
	^ ResizableToggleButton2 new
		offForm: (ScratchFrameMorph skinAt: #paintUtilityButton)
			onForm: (ScratchFrameMorph skinAt: #paintUtilityButtonPressed);
		label: aString localized font: font;
		target: canvasMorph;
		actionSelector: sel

]

{ #category : #initialization }
PaintFrame >> makeZoomBar [

	| b t |
	zoomBar := AlignmentMorph new
		color: Color transparent;
		centering: #bottomRight;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.

	#(out in) do: [:n |
		b := ToggleButton
			onForm: (ScratchFrameMorph skinAt: ('paintZoom', n asString capitalized, 'Button'))
			offForm: (ScratchFrameMorph skinAt: ('paintZoom', n asString capitalized, 'Button')).
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
					onForm: (ScratchFrameMorph skinAt: ('zoom', scale asString, 'ButtonPressed'))
					offForm: (ScratchFrameMorph skinAt: ('zoom', scale asString, 'Button')).
				t
					target: self;
					actionSelector: #scaleCanvas:;
					arguments: (Array with: scale);
					setProperty: #balloonText toValue: scale asString, 'x'.
				zoomBar addMorphBack: t.
				zoomBar addMorphBack: (Morph new extent: 2@2; color: Color transparent)]]].

	zoomBar privateFullBounds: nil; fullBounds.

	^ zoomBar

]

{ #category : #other }
PaintFrame >> newFormTextBoxAndRegPoint [
	"Answer an array containing my current canvasForm, text box, and registration point. The text box is sized to fit the text or is nil if it is empty."

	| textBox r newForm regPoint |
	canvasMorph commitMove.

	textBox := canvasMorph canvasTextBox copy.
	textBox
		textColor: canvasMorph textColor;
		fitContents.
	textBox contents isEmpty ifTrue: [textBox := nil].

	(originalObject isKindOf: ScratchStageMorph)
		ifTrue: [
			r := 0@0 extent: ScratchFrameMorph workpaneExtent.
			newForm := Form extent: r extent depth: 32.
			newForm fillWhite.
			canvasMorph canvasForm
				displayOn: newForm
				at: (newForm extent - canvasMorph canvasForm extent // 2)
				rule: Form paint]
		ifFalse: [
			r := canvasMorph canvasForm rectangleEnclosingPixelsNotOfColor: Color transparent.
			((r area = 0) & textBox isNil) ifTrue: [^ nil].  "empty canvas and no text"
			r area = 0 ifTrue: [r := textBox position extent: 1].  "text only"
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
	"Set state used when editing a Scratch costumes or painting a new sprite."

	oldCostumeName := aString.
	deleteSpriteOnCancel := aBoolean.
	aBoolean ifTrue: [canvasMorph editForm: (Form extent: 4@4 depth: 8)].  "clears cat"

]

{ #category : #accessing }
PaintFrame >> originalObject [

	^ originalObject
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
		(b isKindOf: ToggleButton) ifTrue: [
			b arguments first = numToScale ifTrue: [b on] ifFalse: [b off]]].

	canvasMorph scale: numToScale.

]

{ #category : #'entry points' }
PaintFrame >> scratchFrame: aScratchFrameMorph [

	scratchFrame := aScratchFrameMorph.

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
	"Start editing the given object's form (i.e. it's current costume, if it is a ScratchSpriteMorph)."

	| costume |
	originalObject := anObject.
	(anObject respondsTo: #costume)
		ifTrue: [  "editing a Scratch object"
			costume := anObject costume.
			canvasMorph
				editForm: costume form
				regPoint: costume rotationCenter
				textBox: costume textBox
				isStage: (anObject isKindOf: ScratchStageMorph)]
		ifFalse: [  "editing a non-Scratch object"
			canvasMorph editForm: anObject form].

	(anObject isKindOf: ScratchStageMorph)
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
	triple ifNil: [ Beeper  beep. ^self cancelled].

	originalObject
		editedForm: triple first textBox: triple second;
		rotationCenter: triple third.
	self exitPaintEditor.
	super yes.

]
