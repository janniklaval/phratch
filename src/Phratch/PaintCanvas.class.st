"
I am a paint editor that supports scrolling and scaling.


My instance variables are:
	palette				the UI for my drawing tool state
	canvasForm			the current contents of my painting
	bgForm				checkerboard pattern for showing transparent areas
	feedbackForm		holds feedback during line/rect/oval drawing; same extent as canvasForm
	bufferForm			used for updating my view on the screen
	undoList			keeps copies of recent canvasForms for undo
	undoIndex			index of current undo recorder
	scale				current scale factor
	scrollX				horizontal scroll in canvasForm coordinates
	scrollY				vertical scroll in canvasForm coordinates
	startPoint			starting point of current drag in canvasForm coordinates
	lastPoint			previous point of current drag in canvasForm coordinates
	brush				the Pen used for paint/erase
	moveOrStampForm	holds the image being moved or stamped
	textBox				holds editable text (although this is a morph, it is not in the world)
	textForm			holds text layer bitmap; same extent as canvasForm
	textDragMode		what to do when dragging in text mode (select, move, resize, etc.)
	textDragoffset		offset used during textBox moving and resizing


"
Class {
	#name : #PaintCanvas,
	#superclass : #Morph,
	#instVars : [
		'palette',
		'canvasForm',
		'bgForm',
		'feedbackForm',
		'bufferForm',
		'transformSrcForm',
		'transformScale',
		'transformDegrees',
		'transformHFlip',
		'transformVFlip',
		'transformUndoList',
		'transformUndoIndex',
		'undoList',
		'undoIndex',
		'scale',
		'scrollX',
		'scrollY',
		'brush',
		'startPoint',
		'lastPoint',
		'dragOffset',
		'selectionRect',
		'showSelection',
		'moveOrStampForm',
		'textBox',
		'textColor',
		'textForm',
		'textDragMode',
		'registrationPoint',
		'regPointUndoList',
		'regPointUndoIndex'
	],
	#classVars : [
		'BrushDict',
		'CanvasExtent',
		'EnlargeFactor'
	],
	#category : #'Phratch-Paint'
}

{ #category : #'brush creation' }
PaintCanvas class >> brushCursorSize: brushSize color: brushColor scale: scale [
	"Answer a round brush cursor of the given size and color."

	| outline f cm hole c |
	(BrushDict includesKey: brushSize) ifFalse: [
		outline := Form dotOfSize: brushSize.
		f := ColorForm extent: outline extent depth: 2.
		cm := Bitmap with: 0 with: (brushSize > 2 ifTrue: [1] ifFalse: [2]).
		(BitBlt toForm: f)
			sourceForm: outline;
			destRect: f boundingBox;
			combinationRule: Form paint;
			colorMap: cm;
			copyBits.
		brushSize > 2 ifTrue: [
			hole := Form dotOfSize: brushSize - 2.
			cm := Bitmap with: 0 with: 2.
			(BitBlt toForm: f)
				sourceForm: hole;
				sourceRect: hole boundingBox;
				destOrigin: 1@1;
				combinationRule: Form paint;
				colorMap: cm;
				copyBits].
		BrushDict at: brushSize put: f].

	c := brushColor.
	c isTransparent & (brushSize <= 2) ifTrue: [c := Color black].  "small erasers"
	f := (BrushDict at: brushSize) magnifyBy: scale.
"	f colors: (Array with: Color transparent with: Color black with: c with: Color transparent)."
	^ f

]

{ #category : #accessing }
PaintCanvas class >> canvasExtent [

	^ CanvasExtent

]

{ #category : #'class initialization' }
PaintCanvas class >> initialize [
	"self initialize"

	EnlargeFactor := 1.2.
	BrushDict := Dictionary new.
	CanvasExtent := 480@360.

]

{ #category : #'private-tranforms' }
PaintCanvas >> applyTransform [
	"Apply the current transform."

	| f degrees |
	f := transformSrcForm.
	degrees := transformDegrees.
	transformHFlip
		ifTrue: [ degrees := degrees negated ].
	transformVFlip
		ifTrue: [ degrees := degrees negated ].
	(degrees closeTo: 0.0)
		ifFalse: [ f := f rotateBy: degrees ].
	(transformScale closeTo: 1.0)
		ifFalse: [ f := f magnify: f boundingBox by: transformScale smoothing: 1 ].
	transformHFlip
		ifTrue: [ f := f flipBy: #horizontal centerAt: f boundingBox center ].
	transformVFlip
		ifTrue: [ f := f flipBy: #vertical centerAt: f boundingBox center ].
	f := f copy: (f rectangleEnclosingPixelsNotOfColor: Color transparent).
	f offset: nil.
	moveOrStampForm := f.
	selectionRect := selectionRect center - (f extent // 2) extent: f extent.
	self changed
]

{ #category : #'event handling' }
PaintCanvas >> autoScroll: cursorPoint [
	"Autoscroll towards the given point."

	| scrollDelta deltaX deltaY max |
	(bounds containsPoint: cursorPoint) ifTrue: [^ self].  "no scrolling needed"

	scrollDelta := 64 // scale.  "this controls autoscroll speed"

	cursorPoint x < bounds left ifTrue: [deltaX := scrollDelta negated].
	cursorPoint x > bounds right ifTrue: [deltaX := scrollDelta].
	cursorPoint y < bounds top ifTrue: [deltaY := scrollDelta negated].
	cursorPoint y > bounds bottom ifTrue: [deltaY := scrollDelta].

	deltaX ifNotNil: [
		max := canvasForm width - (self width // scale).
		scrollX := (scrollX + deltaX) rounded within: 0 and: max].
	deltaY ifNotNil: [
		max := canvasForm height - (self height // scale).
		scrollY := (scrollY + deltaY) rounded within: 0 and: max].
	(owner respondsTo: #updateScrollbars) ifTrue: [owner updateScrollbars].
	self changed.


]

{ #category : #private }
PaintCanvas >> brushCursorSize: brushSize color: brushColor [
	"Answer a round brush cursor of the given size and color."

	^ self class brushCursorSize: brushSize color: brushColor scale: scale

]

{ #category : #private }
PaintCanvas >> canvasChanged: aRectangle [
	"The given rectangle of the canvas form has changed. Report this change to my owner in screen coordinates."
	"Note: The extra pixel of expansion is for the selection rectangle, which draws one pixel outside the enclosed pixels."

	| r |
	r := ((aRectangle origin - (scrollX@scrollY) - 1) * scale) floor corner:
		((aRectangle corner - (scrollX@scrollY) + 1) * scale) ceiling.
	owner invalidRect: (r translateBy: bounds origin).

]

{ #category : #accessing }
PaintCanvas >> canvasForm [

	^ canvasForm

]

{ #category : #accessing }
PaintCanvas >> canvasTextBox [
	"Answer my text box."

	^ textBox

]

{ #category : #private }
PaintCanvas >> canvasToScreen: aPoint [
	"Answer the given canvas point in screen coordinates."

	^ bounds origin + ((aPoint - (scrollX@scrollY)) * scale) rounded

]

{ #category : #private }
PaintCanvas >> centerAt: aPoint [
	"Center the viewable area on the given point in the canvasForm--or as close as possible at the current scale."

	| limits |
	limits := (canvasForm extent - (self extent // scale)) max: (0@0).
	scrollX := (aPoint x - (self width // (2 * scale))) within: 0 and:limits x.
	scrollY := (aPoint y - (self height // (2 * scale))) within: 0 and: limits y.
	(self owner respondsTo: #updateScrollbars) ifTrue: [self owner updateScrollbars].
	self changed.


]

{ #category : #'private-move tool' }
PaintCanvas >> clearMoveState [

	selectionRect := nil.
	moveOrStampForm := nil.
	transformSrcForm := nil.
	transformUndoList := nil.

]

{ #category : #'registration point' }
PaintCanvas >> clearRegistrationPoint [

	registrationPoint := nil.
	regPointUndoList := nil.
	regPointUndoIndex := 0.

]

{ #category : #private }
PaintCanvas >> clearTextBox [

	textBox contents: ''.
	textBox position: (self extent // 2) - (50@25).
	textBox extent: (self extent - textBox topLeft).

]

{ #category : #'private-move tool' }
PaintCanvas >> commitMove [
	"Commit the last move operation, if any."

	(moveOrStampForm isNil | selectionRect isNil) ifTrue: [^ self].

	palette mode = #move ifTrue: [
		moveOrStampForm
			displayOn: canvasForm
			at: selectionRect origin
			rule: Form paint.
		self changed].

	self clearMoveState.


]

{ #category : #private }
PaintCanvas >> copyMoveSelection [
	"If we've made a selection with the move tool but haven't yet picked it up, make a copy of the selection."

	| f r |
	((palette mode = #move) & selectionRect notNil) ifFalse: [^PhratchError error: 'beep'.].

	moveOrStampForm
		ifNil: [moveOrStampForm := canvasForm copy: selectionRect]
		ifNotNil: [
			"commit current move, then copy bits"
			self saveForUndo.
			f := moveOrStampForm.
			r := selectionRect.
			self commitMove.
			moveOrStampForm := f.
			selectionRect := r].

	selectionRect := selectionRect translateBy: 5@5.
	self changed.
]

{ #category : #private }
PaintCanvas >> deleteOrCropCurrentSelection: evt [

	| r selForm |
	selectionRect ifNil: [^ self].  "no selection"
	moveOrStampForm ifNotNil: [
		r := selectionRect.
		self commitMove.
		selectionRect := r].
	self saveForUndo.
	evt shiftPressed
		ifTrue: [  "crop everything outside of the selection rectangle"
			selForm := canvasForm copy: selectionRect.
			canvasForm fillColor: Color transparent.
			selForm displayOn: canvasForm at: selectionRect origin rule: Form over]
		ifFalse: [  "delete current selection"
			canvasForm fill: selectionRect fillColor: Color transparent].
	selectionRect := moveOrStampForm := nil.
	self changed.

]

{ #category : #'event handling' }
PaintCanvas >> dragBrushTo: aPoint [
	"While painting or erasing, move the brush to the given point. Called repeatedly while dragging. All points are in canvas coordinates."

	| p |
	p := (aPoint max: scrollX@scrollY) min: (scrollX@scrollY) + (bounds extent // scale).
	brush goto: p.
	self canvasChanged: ((lastPoint rectangle: p) expandBy: (brush sourceForm width / 2.0) ceiling).
	lastPoint := p.

]

{ #category : #'event handling' }
PaintCanvas >> dragShapeTo: aPoint [
	"Draw or drag out a line or shape from the starting point to the given point. Called repeatedly while dragging. All points are in canvas coordinates."

	| mode w shapeCanvas endPoint r dx dy side |
	mode := palette mode.
	w := palette brushSize.
	feedbackForm bits atAllPut: 0.	"fast clear"
	shapeCanvas := FormCanvas on: feedbackForm.
	#line = mode
		ifTrue: [ 
			endPoint := aPoint.
			Sensor shiftPressed
				ifTrue: [ 
					endPoint := (endPoint y - startPoint y) abs > (endPoint x - startPoint x) abs
						ifTrue: [ startPoint x @ endPoint y ]
						ifFalse: [ endPoint x @ startPoint y ] ].
			shapeCanvas
				line: startPoint
				to: endPoint
				width: w
				color: Color black ].
	#oval = mode
		ifTrue: [ 
			r := startPoint rectangle: aPoint.
			Sensor shiftPressed
				ifTrue: [ 
					dx := aPoint x - startPoint x.
					dy := aPoint y - startPoint y.
					side := dx abs max: dy abs.
					r := startPoint rectangle: startPoint + (side * (dx sign @ dy sign)) ].
			palette shapeFilling
				ifTrue: [ shapeCanvas fillOval: r color: Color black ]
				ifFalse: [ shapeCanvas frameOval: r width: w color: Color black ] ].
	#rect = mode
		ifTrue: [ 
			r := startPoint rectangle: aPoint.
			Sensor shiftPressed
				ifTrue: [ 
					dx := aPoint x - startPoint x.
					dy := aPoint y - startPoint y.
					side := dx abs max: dy abs.
					r := startPoint rectangle: startPoint + (side * (dx sign @ dy sign)) ].
			palette shapeFilling
				ifTrue: [ shapeCanvas fillRectangle: r color: Color black ]
				ifFalse: [ shapeCanvas frameRectangle: r width: w color: Color black ] ].
	lastPoint := aPoint.
	self changed
]

{ #category : #'event handling' }
PaintCanvas >> dragTo: aPoint [
	"Drag to the given point with the current drawing tool. The point is in canvas coordinates."

	| mode c |
	mode := palette mode.
	({#paint . #erase} includes: mode)
		ifTrue: [ ^ self dragBrushTo: aPoint ].
	(#(#line #oval #rect) includes: mode)
		ifTrue: [ ^ self dragShapeTo: aPoint ].
	#eyedropper = mode
		ifTrue: [ 
			c :=" (bounds containsPoint: Sensor cursorPoint)
				ifTrue: [ ""canvasForm colorAt: aPoint" Display colorAt: Sensor cursorPoint "]
				ifFalse: [ Display colorAt: Sensor cursorPoint ]".	"if over me, get color from canvasForm"
			palette color1: c.
			^ self ].	"holding shift with the stamp tool does multiple stamps while dragging"
	#stamp = palette mode & Sensor shiftPressed
		ifFalse: [ ^ self ].
	self stampAt: aPoint.
	(Delay forMilliseconds: 50) wait.
	^ self
]

{ #category : #drawing }
PaintCanvas >> drawBGOnBufferSrcRect: srcRect dstRect: dstRect [
	"Draw a checkboard background pattern onto my buffer form with the given source and destination rectangles."

	| cm |
	(bgForm isNil or: [bgForm extent ~= canvasForm extent])
		ifTrue: [bgForm := self makeCheckerboard].

	cm := Bitmap
		with: ((Color gray: 0.9) pixelValueForDepth: 32)
		with: ((Color gray: 0.99) pixelValueForDepth: 32).
	(WarpBlt toForm: bufferForm)
		sourceForm: bgForm;
		colorMap: cm;
		cellSize: 1;
		combinationRule: Form paint;
		copyQuad: srcRect innerCorners toRect: dstRect.

]

{ #category : #drawing }
PaintCanvas >> drawFeedbackOnBufferSrcRect: srcRect dstRect: dstRect [
	"Draw my shape-drawing feedback scaled onto my buffer form with the given source and destination rectangles."

	| cm tempForm |
	palette color1 isTransparent ifFalse: [  "normal case: drawing with a color"
		cm := Bitmap new: 2.
		cm at: 1 put: 0.  "transparent"
		cm at: 2 put: (palette color1 pixelValueForDepth: 32).
		(WarpBlt toForm: bufferForm)
			sourceForm: feedbackForm;
			colorMap: cm;
			cellSize: 1;
			combinationRule: Form paint;
			copyQuad: srcRect innerCorners toRect: dstRect.
		^ self].

	"special case: drawing with transparent"
	tempForm := Form extent: bufferForm extent depth: 32.
	cm := Bitmap new: 2.
	cm at: 1 put: 0.  "transparent"
	cm at: 2 put: 16rFFFFFFFF.
	(WarpBlt toForm: tempForm)
		sourceForm: feedbackForm;
		colorMap: cm;
		cellSize: 1;
		combinationRule: Form paint;
		copyQuad: srcRect innerCorners toRect: dstRect.

	cm := Bitmap
		with: ((Color gray: 0.9) pixelValueForDepth: 32)
		with: (Color white pixelValueForDepth: 32).
	(WarpBlt toForm: tempForm)
		sourceForm: bgForm;
		colorMap: cm;
		cellSize: 1;
		combinationRule: Form and;
		copyQuad: srcRect innerCorners toRect: dstRect.

	(BitBlt toForm: bufferForm)
		sourceForm: tempForm;
		destRect: dstRect;
		combinationRule: Form paint;
		copyBits.

]

{ #category : #drawing }
PaintCanvas >> drawMoveOrStampFormSrcRect: srcRect dstRect: dstRect [
	"Draw the Form being moved or stamped on the bufferForm at the given point."

	| r |
	(moveOrStampForm isNil | selectionRect isNil) ifTrue: [^ self].
	((palette mode = #stamp) and: [(bounds containsPoint: Sensor cursorPoint) not]) ifTrue: [^ self].

	r := (selectionRect origin - srcRect origin extent: moveOrStampForm extent) scaleBy: scale.
	(WarpBlt toForm: bufferForm)
		sourceForm: moveOrStampForm;
		colorMap: (moveOrStampForm colormapIfNeededForDepth: 32);
		cellSize: 1;
		combinationRule: Form paint;
		copyQuad: moveOrStampForm boundingBox innerCorners toRect: r.


]

{ #category : #drawing }
PaintCanvas >> drawOn: aCanvas [

	| damageRect srcRect dstRect |
	(bufferForm notNil and: [bufferForm extent = self extent]) ifFalse: [
		bufferForm := Form extent: self extent depth: 32].

	damageRect := bounds intersect: aCanvas clipRect.
	srcRect := (self screenToCanvas: damageRect origin)
		extent: ((damageRect extent / scale) truncated + 1).
	dstRect := 0@0 extent: srcRect extent * scale.

	"draw the checkboard background onto the buffer"
	self drawBGOnBufferSrcRect: srcRect dstRect: dstRect.

	"draw the paint layer onto the buffer"
	(WarpBlt toForm: bufferForm)
		sourceForm: canvasForm;
		colorMap: (canvasForm colormapIfNeededForDepth: 32);
		cellSize: 1;
		combinationRule: Form paint;
		copyQuad: srcRect innerCorners toRect: dstRect.

	"draw text, move/stamp, and feedback layers onto the buffer"
	self drawTextOnBufferSrcRect: srcRect dstRect: dstRect.
	moveOrStampForm ifNotNil: [self drawMoveOrStampFormSrcRect: srcRect dstRect: dstRect].
	selectionRect notNil ifTrue: [self drawSelectionOnBufferSrcRect: srcRect dstRect: dstRect].
	feedbackForm ifNotNil: [self drawFeedbackOnBufferSrcRect: srcRect dstRect: dstRect].

	(palette notNil and: [palette showRotationCenter]) ifTrue: [
		self drawRegistrationPointOnBufferSrcRect: srcRect dstRect: dstRect].

	"draw the buffer onto the canvas"
	(aCanvas copyClipRect: bounds)
		image: bufferForm
		at: (self canvasToScreen: srcRect origin)
		sourceRect: (0@0 extent: dstRect extent)
		rule: Form paint.

]

{ #category : #drawing }
PaintCanvas >> drawRegistrationPointOnBufferSrcRect: srcRect dstRect: dstRect [
	"Draw the registation point."

	| r offset bitBlt x y |
	registrationPoint
		ifNil: [ 
			"compute an initial registration point"
			r := canvasForm rectangleEnclosingPixelsNotOfColor: Color transparent.
			registrationPoint := r area = 0
				ifTrue: [ canvasForm center ]
				ifFalse: [ r center ] ].
	registrationPoint := (registrationPoint max: 0 @ 0) min: canvasForm extent.
	offset := scale > 1
		ifTrue: [ scale // 2 ]
		ifFalse: [ 0 ].
	bitBlt := (BitBlt toForm: bufferForm)
		clipRect: dstRect;
		fillColor: (ColorForm new quickHighLight: bufferForm depth);
		combinationRule: Form reverse; 
		yourself.
	(registrationPoint x between: srcRect left and: srcRect right)
		ifTrue: [ 
			x := dstRect left + (scale * (registrationPoint x - srcRect left)) rounded + offset.
			bitBlt
				destRect: (x @ 0 extent: 1 @ bufferForm height);
				copyBits ].
	(registrationPoint y between: srcRect top and: srcRect bottom)
		ifFalse: [ ^ self ].
	y := dstRect top + (scale * (registrationPoint y - srcRect top)) rounded + offset.
	bitBlt
		destRect: (0 @ y extent: bufferForm width @ 1);
		copyBits
]

{ #category : #drawing }
PaintCanvas >> drawSelectionOnBufferSrcRect: srcRect dstRect: dstRect [
	"Draw the selection rectangle."

	| bitBlt r |
	(showSelection or: [palette mode = #move]) ifFalse: [^ self].
 
	bitBlt := (BitBlt toForm: bufferForm)
		clipRect: dstRect;
		fillColor: (ColorForm new quickHighLight: bufferForm depth);
		combinationRule: Form reverse; 
		yourself.

	r := ((selectionRect translateBy: srcRect topLeft negated) scaleBy: scale) rounded translateBy: dstRect topLeft.
	bitBlt destRect: (r topLeft extent: r width@1); copyBits.
	bitBlt destRect: (r topLeft + (0@1) extent: 1@(r height - 1)); copyBits.
	bitBlt destRect: (r topRight + (-1@1) extent: 1@(r height - 1)); copyBits.
	bitBlt destRect: (r bottomLeft + (1@(-1)) extent: (r width - 2)@1); copyBits.

]

{ #category : #drawing }
PaintCanvas >> drawTextOnBufferSrcRect: srcRect dstRect: dstRect [
	"Draw my text box scaled onto my buffer form with the given source and destination rectangles."

	| frameColor selectionColor cm bgColor |
	(textBox isEmpty and: [#text ~= palette mode]) ifTrue: [
		textForm := nil.
		^ self].  "don't show empty textbox"

	(textForm isNil or:
	 [textForm extent ~= canvasForm extent]) ifTrue: [  "create textForm if needed"
		textForm := Form extent: canvasForm extent depth: 4].
	textForm unhibernate.
	textForm bits atAllPut: 0.  "quick clear"

	textBox drawOn: (FormCanvas on: textForm).  "draw text box"

	#text = palette mode
		ifTrue: [
			"draw text handle with color entry 6 (green) from the 4-bit color palette"
			textForm fill: (textBox topLeft - 5 extent: 8@8) fillColor: Color green.

			bgColor := Color white.
			frameColor := Color black.
			selectionColor := Color r: 0.353 g: 0.607 b: 0.788]
		ifFalse: [
			bgColor := frameColor := selectionColor := Color transparent].

	"draw the text form (4-bits) onto the buffer form at the appropriate scale mapping its colors in the process"
	cm := Bitmap new: 16.
	cm at: 1 put: 0.  "transparent"
	cm at: 2 put: (textColor pixelValueForDepth: 32).
	cm at: 3 put: (frameColor pixelValueForDepth: 32).
	cm at: 4 put: (selectionColor pixelValueForDepth: 32).
	cm at: 5 put: (bgColor pixelValueForDepth: 32).
	cm at: 6 put: (Color black pixelValueForDepth: 32).	"corner handle"
	(WarpBlt toForm: bufferForm)
		sourceForm: textForm;
		colorMap: cm;
		cellSize: 2;
		combinationRule: Form paint;
		copyQuad: srcRect innerCorners toRect: dstRect.

]

{ #category : #'entry points' }
PaintCanvas >> editForm: aForm [
	"Set the Form that I should edit. Make a copy of the original Form."

	self editForm: aForm regPoint: aForm center textBox: nil isStage: false.

]

{ #category : #'entry points' }
PaintCanvas >> editForm: aForm regPoint: regPoint textBox: savedTextBox isStage: isStage [
	"Set the Form and textBox that I should edit. Make a copy of the original Form."

	| p |
	canvasForm := Form extent: (aForm extent max: self extent) depth: 32.
	p := (((canvasForm extent // 2) - regPoint) min: (canvasForm extent - aForm extent)) max: 0@0.
	aForm displayOn: canvasForm at: p rule: Form paint -1.
	registrationPoint := p + regPoint.
	bgForm := self makeCheckerboard.
	self clearTextBox.
	undoList := OrderedCollection new.
	undoIndex := 0.
	scrollX := scrollY := 0.
	self clearMoveState.

	savedTextBox ifNotNil: [  "install saved textbox"
		textBox := savedTextBox copy.
		isStage ifFalse: [textBox position: p + textBox position].
		textBox extent: (self extent - textBox topLeft).
		textColor := textBox textColor.
		textBox
			textColor: Color black;
			borderWidth: 0].

	self changed.

]

{ #category : #'button actions' }
PaintCanvas >> enlarge [

	Sensor shiftPressed ifTrue: [^ self magnify].
	self scaleBy: EnlargeFactor.

]

{ #category : #'button actions' }
PaintCanvas >> eraseAll [

	palette showRotationCenter: false.
	palette mode = #stamp ifFalse: [self clearMoveState].
	self clearRegistrationPoint.
	self saveForUndo.
	canvasForm := Form extent: self extent depth: 32.
	self changed.

]

{ #category : #private }
PaintCanvas >> extractProjectFrom: aByteArray [
	"Answer a Phratch project (i.e. a PhratchStageMorph possibly containing sprites) from the given ByteArray. Answer nil if the project cannot be unpacked."

	| s version proj |
	s := ReadStream on: aByteArray.
	version := FuelObjStream phratchFileVersionFrom: (s next: 10) asString.
	version = 0 ifTrue: [
		s position: 0.
		proj := FuelObjStream new readObjFrom: s showProgress: true].
	({1 . 2} includes: version) ifTrue: [
		s skip: s uint32.  "skip header"
		proj := FuelObjStream new readObjFrom: s showProgress: true].

	proj class = PhratchStageMorph ifFalse: [
		version > 2
			ifTrue: [self error: 'Project created by a later version of Phratch']
			ifFalse: [self error: 'Problem reading project.'].
		^ nil].

	^ proj

]

{ #category : #private }
PaintCanvas >> fillAt: aPoint [
	"Perform a fill operation starting at the given point."

	| fillStyle |
	fillStyle := palette paintBucketFillStyle.

	#color = fillStyle ifTrue: [
		canvasForm shapeFill: palette color1 interiorPoint: aPoint].
	#erase = fillStyle ifTrue: [
		canvasForm shapeFill: Color transparent interiorPoint: aPoint].
	#hGradient = fillStyle ifTrue: [
		canvasForm shapeFillGradientFrom: palette color1 to: palette color2 at: aPoint type: #horizontal].
	#vGradient = fillStyle ifTrue: [
		canvasForm shapeFillGradientFrom: palette color1 to: palette color2 at: aPoint type: #vertical].
	#rGradient = fillStyle ifTrue: [
		canvasForm shapeFillGradientFrom: palette color1 to: palette color2 at: aPoint type: #radial].

	self changed.
]

{ #category : #'button actions' }
PaintCanvas >> flipH [

	palette showRotationCenter: false.
	self prepareToTransform.
	transformSrcForm ifNil: [^ self].
	self saveTransformForUndo.
	transformHFlip := transformHFlip not.
	self applyTransform.

]

{ #category : #'button actions' }
PaintCanvas >> flipV [

	palette showRotationCenter: false.
	self prepareToTransform.
	transformSrcForm ifNil: [^ self].
	self saveTransformForUndo.
	transformVFlip := transformVFlip not.
	self applyTransform.

]

{ #category : #'event handling' }
PaintCanvas >> handlesKeyboard: evt [
^true  
]

{ #category : #'event handling' }
PaintCanvas >> handlesMouseDown: evt [

	^ true

]

{ #category : #'button actions' }
PaintCanvas >> import [
	"Import an image from the image library, or the current directory if there is not image library."

	| fName f spriteOrStage type |
	palette showRotationCenter: false.
	spriteOrStage := self owner originalObject.
	type := (spriteOrStage isPhratchStageMorph)
		ifTrue: [ #background ]
		ifFalse: [ #costume ].
	fName := PhratchFileChooserDialog chooseImageFileType: type title: 'Import Image'.
	(fName isNil or: [ fName = #cancelled ])
		ifTrue: [ ^ self ].
	(fName fullName asLowercase endsWith: '.sprite') | (fName fullName asLowercase endsWith: '.ysp')  | (fName fullName asLowercase endsWith: '.phsp')
		ifTrue: [ f := self importCostumeFromSprite: fName ]
		ifFalse: [ [ f := Form fromFileNamed: fName ] ifError: [ nil ] ].
	f ifNil: [ ^ self ].
	f := PhratchFrameMorph scaledFormForPaintEditor: f.
	(owner isKindOf: PaintFrame)
		ifTrue: [ owner scaleCanvas: 1 ].
	self commitMove.	"commit previous move, if any"
	palette mode: #move.
	moveOrStampForm := f.
	selectionRect := (canvasForm extent - f extent) // 2 extent: f extent
]

{ #category : #private }
PaintCanvas >> importCostumeFromSprite: fName [
	"Return the current costume from the give sprite file."

	| data  f importedStage |
	(fName) exists ifFalse: [^ nil].
	f := (FileStream readOnlyFileNamed: fName) binary.
	f ifNil: [^ nil].
	data := f contentsOfEntireFile.

	[importedStage := self extractProjectFrom: data] ifError: [^ nil].

	importedStage submorphs do: [:m |
		(m isPhratchSpriteMorph) ifTrue: [
			^ m costumeForm]].

	^ nil

]

{ #category : #initialization }
PaintCanvas >> initialize [

	super initialize.
	palette := PaintPalette new canvasMorph: self.
	scale := 1.
	scrollX := scrollY := 0.
	showSelection := false.
	textColor := Color black.
	"textBox := TextMorph new
		color: Color white;
		contents: '' localized, '...';
		borderWidth: 0;
		font: (StrikeFont osFontName: 'Helvetica Bold' size: 24);
		autoFit: true;
		wrapFlag: true;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap;
		yourself."
	textBox := MultilineStringMorph new
		font: (StrikeFont osFontName: 'Helvetica Bold' size: 24);
		textColor: Color black;	
		borderColor: Color white;
		borderWidth: 0; 
		yourself.
	textDragMode := #none.
	self extent: 250@250.
]

{ #category : #private }
PaintCanvas >> installCursorInHand: h [
	"Note: use XO cursors on XO except for paint and erase, which should be a their actual size."

	| mode cursor |
	h showTemporaryCursor: nil.
	palette showRotationCenter
		ifTrue: [ ^ self ].
	mode := palette mode.
	#eyedropper = mode
		ifTrue: [ h showTemporaryCursor: Cursor eyeDropper ].
	#fill = mode
		ifTrue: [ h showTemporaryCursor: Cursor paintBucket ].
	(#(#line #oval #rect) includes: mode)
		ifTrue: [ h showTemporaryCursor: Cursor crossHair ].
	(#(#stamp #move) includes: mode)
		ifTrue: [ 
			moveOrStampForm
				ifNil: [ h showTemporaryCursor: Cursor crossHair ]
				ifNotNil: [ 
					#stamp = mode
						ifTrue: [ h showTemporaryCursor: Cursor blank ]
						ifFalse: [ h showTemporaryCursor: Cursor handOpen ] ] ].
	#erase = mode
		ifTrue: [ 
			cursor := self brushCursorSize: palette brushSize color: Color transparent.
			h showTemporaryCursor: cursor hotSpotOffset: (cursor center truncateTo: scale) ].
	#paint = mode
		ifFalse: [ ^ self ].
	cursor := self brushCursorSize: palette brushSize color: palette color1.
	h showTemporaryCursor: cursor hotSpotOffset: (cursor center truncateTo: scale)
]

{ #category : #'event handling' }
PaintCanvas >> keyStroke: evt [

	| k |
	#text = palette mode ifTrue: [
		textBox extent: canvasForm extent - textBox position.
		textBox keyStroke: evt.
		
		^ self changed].

	k := evt keyValue.
	(evt commandKeyPressed | evt controlKeyPressed)
		ifTrue: [k := k \\ 32].  "treat command/alt same as the control key"

	k = ($a asciiValue \\ 32) ifTrue: [^ self selectAll].
	k = ($c asciiValue \\ 32) ifTrue: [^ self copyMoveSelection].
	(#(8 24 127) includes: k) ifTrue: [^ self deleteOrCropCurrentSelection: evt].
	k = ($z asciiValue \\ 32) ifTrue: [^ self undo].

	(palette mode = #move and: [selectionRect notNil]) ifTrue: [
		self startMove.
		"keys that act on the selection"
		k = 28 ifTrue: [^ self nudge: -1@0].  "left"
		k = 29 ifTrue: [^ self nudge:  1@0].  "right"
		k = 30 ifTrue: [^ self nudge:  0@(-1)].  "up"
		k = 31 ifTrue: [^ self nudge:  0@1]].  "down"
	PhratchError error: 'beep'.

]

{ #category : #'private-tranforms' }
PaintCanvas >> magnify [
	"Prompt the user for a percent and rescale by that factor."

	| percent s |
	percent := transformScale ifNil: [100] ifNotNil: [(100 * transformScale) rounded].
	s := StringDialog
		ask: 'Percent? (100 gives original size)'
		initialAnswer: percent printString.
	s isEmpty ifTrue: [^ self].
	[percent := s asNumber max: 1] ifError: [^ self nonNumberWarning].

	transformScale := 1.0.
	self scaleBy: percent / 100.0.

]

{ #category : #private }
PaintCanvas >> makeCheckerboard [
	"Create a checkboard form the same size as my canvas form and fill it with a checkboard pattern (used to show transparnecy). "

	| f squareSize blt |
	f := Form extent: canvasForm extent depth: 1.
	squareSize := 4.
	f fillColor: Color white.

	blt := (BitBlt toForm: f)
		fillColor: Color black;
		combinationRule: Form over;
		destRect: (0@0 extent: squareSize@squareSize); 
		yourself.

	0 to: f height by: (2 * squareSize) do: [:y |
		blt destY: y.
		0 to: f width by: (2 * squareSize) do: [:x | blt destX: x; copyBits].
		blt destY: y + squareSize.
		squareSize to: f width by: (2 * squareSize) do: [:x | blt destX: x; copyBits]].

	^ f

]

{ #category : #'event handling' }
PaintCanvas >> mouseDown: evt [

	startPoint := lastPoint := self screenToCanvas: evt cursorPoint.
	(#(stamp move) includes: palette mode) ifFalse: [self clearMoveState].

	palette showRotationCenter
		ifTrue: [^ self saveRegPointForUndo]
		ifFalse: [regPointUndoList := nil].

	#eyedropper = palette mode ifTrue: [^ self].
	#move = palette mode ifTrue: [^ self moveToolMouseDown: startPoint].
	#text = palette mode ifTrue: [^ self textMouseDown: evt].

	self saveForUndo.

	brush := (PhratchPen newOnForm: canvasForm)
		roundNib: palette brushSize;
		color: palette color1;
		place: startPoint; 
		yourself.

	(#erase = palette mode) | (palette color1 isTransparent) ifTrue: [
		brush color: Color black.
		brush combinationRule: Form erase1bitShape].

	(#(line oval rect) includes: palette mode) ifTrue: [
		feedbackForm := Form extent: canvasForm extent depth: 1].

	#fill = palette mode ifTrue: [self fillAt: startPoint].
	#stamp = palette mode ifTrue: [self stampAt: startPoint].

	self dragTo: startPoint.

]

{ #category : #'event handling' }
PaintCanvas >> mouseEnter: evt [

	World activeHand newKeyboardFocus: self.
	self installCursorInHand: evt hand.
	scale > 1 ifTrue: [
		evt hand
			gridTo: scale truncated
			origin: (self canvasToScreen: 0@0)].

]

{ #category : #'event handling' }
PaintCanvas >> mouseLeave: evt [

	evt hand
		showTemporaryCursor: nil;
		turnOffGridding.
	"self changed."
	
]

{ #category : #'event handling' }
PaintCanvas >> mouseMove: evt [
	"Draw and/or give feedback."

	| screenP |
	((#paint ~= palette mode))
		ifTrue: [self autoScroll: evt cursorPoint].

	palette showRotationCenter ifTrue: [
		screenP := evt cursorPoint adhereTo: (self topLeft corner: self bottomRight - 1).
		registrationPoint := self screenToCanvas: screenP.
		^ self changed].

	#text = palette mode ifTrue: [^ self textMouseMove: evt].

	self dragTo: (self screenToCanvas: evt cursorPoint).

]

{ #category : #'event handling' }
PaintCanvas >> mouseUp: evt [
	"Finish a drag."

	| rule shapeCM |
	textDragMode := #none.
	palette showRotationCenter ifTrue: [^ self].

	feedbackForm ifNotNil: [  "draw final rect/oval/line onto canvasForm"
		rule := Form paint.
		shapeCM := Bitmap new: 2.
		shapeCM at: 2 put: (palette color1 pixelValueForDepth: 32).
		palette color1 isTransparent ifTrue: [
			rule := Form erase.
			shapeCM at: 2 put: 16rFFFFFFFF].
		(BitBlt toForm: canvasForm)
			sourceForm: feedbackForm;
			colorMap: shapeCM;
			combinationRule: rule;
			copyBits.
		feedbackForm := nil.
		"self changed"].

]

{ #category : #'private-move tool' }
PaintCanvas >> moveToolMouseDown: aPoint [
	"Mouse up with move tool selected."

	(selectionRect notNil and:
	 [(selectionRect containsPoint: aPoint) not]) ifTrue: [
		"click outside current selection; select again"
		self commitMove.
		selectionRect := nil.
		self changed.
		World displayWorldSafely].  "force redraw to remove old selection"

	selectionRect ifNil: [  "choose a selection rectangle"
		selectionRect := self selectRectangleStartingAt: aPoint.
		moveOrStampForm := nil.
		^ self changed].

	self startMove.

	dragOffset := aPoint - selectionRect origin.
	World activeHand showTemporaryCursor: Cursor handClosed.
	self changed.

]

{ #category : #'private-tranforms' }
PaintCanvas >> nonNumberWarning [

	DialogBoxMorph inform: 'Please enter a number' localized.

]

{ #category : #private }
PaintCanvas >> nudge: aPoint [

	selectionRect ifNotNil: [
		self canvasChanged: selectionRect.
		selectionRect := selectionRect translateBy: aPoint.
		self canvasChanged: selectionRect].
	
]

{ #category : #accessing }
PaintCanvas >> palette [

	^ palette

]

{ #category : #'private-tranforms' }
PaintCanvas >> prepareToTransform [

	| f r |
	transformSrcForm ifNotNil: [^ self].

	(selectionRect isNil or: [palette mode ~= #move]) ifTrue: [
		self selectAll.
		selectionRect ifNil: [^ self]].  "empty canvas; do nothing".

	self startMove.

	f := moveOrStampForm.
	r := f rectangleEnclosingPixelsNotOfColor: Color transparent.
	(r width > 0) & (r height > 0) ifFalse: [transformSrcForm := nil. ^ self].

	transformSrcForm := moveOrStampForm := f copy: r.
	selectionRect := (selectionRect origin + r origin) extent: moveOrStampForm extent.

	transformScale := 1.0.
	transformDegrees := 0.
	transformHFlip := false.
	transformVFlip := false.
	transformUndoList := nil.  "clear undo list"

]

{ #category : #'button actions' }
PaintCanvas >> redo [

	palette mode = #text ifTrue: [^ PhratchError error: 'beep'.].

	palette showRotationCenter ifTrue: [^ self redoRegPointMove].
	transformSrcForm ifNotNil: [^ self redoTransform].

	undoIndex > 1 ifFalse: [^ PhratchError error: 'beep'.].  "nothing more to redo"
	undoIndex := undoIndex - 1.
	canvasForm := undoList at: undoIndex.
	self clearMoveState.
	self changed.

]

{ #category : #'registration point' }
PaintCanvas >> redoRegPointMove [

	regPointUndoList ifNil: [^ PhratchError error: 'beep'.].  "no undo entries yet"
	regPointUndoIndex < 2 ifTrue: [^ PhratchError error: 'beep'.].  "nothing more to redo"
	regPointUndoIndex := regPointUndoIndex - 1.
	registrationPoint := regPointUndoList at: regPointUndoIndex.
	self changed.

]

{ #category : #'private-tranforms' }
PaintCanvas >> redoTransform [

	| rec |
	transformUndoList ifNil: [^ PhratchError error: 'beep'.].  "no undo entries yet"
	transformUndoIndex < 2 ifTrue: [^ PhratchError error: 'beep'.].  "nothing more to redo"
	transformUndoIndex := transformUndoIndex - 1.

	rec := transformUndoList at: transformUndoIndex.
	transformScale := rec at: 1.
	transformDegrees := rec at: 2.
	transformHFlip := rec at: 3.
	transformVFlip := rec at: 4.
	selectionRect := Rectangle center: (rec at: 5) extent: selectionRect extent.
	self applyTransform.

]

{ #category : #'registration point' }
PaintCanvas >> registrationPoint [

	^ registrationPoint

]

{ #category : #'private-tranforms' }
PaintCanvas >> rotate: clockwiseFlag [

	| s degrees |
	s := StringDialog ask: 'Rotation degrees?' initialAnswer: '30'.
	s isEmpty ifTrue: [^ self].
	[degrees := s asNumber.
	clockwiseFlag
		ifTrue: [self rotateCWBy: degrees]
		ifFalse: [self rotateCWBy: degrees negated]
	] ifError: [
		^ self nonNumberWarning].

]

{ #category : #'button actions' }
PaintCanvas >> rotateCCW [

	Sensor shiftPressed ifTrue: [^ self rotate: false].
	self rotateCWBy: -30.

]

{ #category : #'button actions' }
PaintCanvas >> rotateCW [

	Sensor shiftPressed ifTrue: [^ self rotate: true].
	self rotateCWBy: 30.

]

{ #category : #'private-tranforms' }
PaintCanvas >> rotateCWBy: degrees [
	"Rotate my contents clockwise by the given angle in degrees."

	palette showRotationCenter: false.
	self prepareToTransform.
	transformSrcForm ifNil: [^ self].
	self saveTransformForUndo.
	transformDegrees := transformDegrees + degrees.
	self applyTransform.

]

{ #category : #private }
PaintCanvas >> saveForUndo [
	"Record my current canvas Form for undo."
	"Note: The most recent canvas is added to the front of the undo list. If the undo list is already of maximum size, the oldest
entry is removed and, if possible, recycled."

	| f |
	undoIndex > 0 ifTrue: [undoList := undoList copyFrom: undoIndex + 1 to: undoList size].

	((undoList size >= 10) and:
	 [undoList last extent = canvasForm extent])
		ifTrue: [f := undoList removeLast. f unhibernate]
		ifFalse: [f := Form extent: canvasForm extent depth: canvasForm depth].

	"quickly copy current canvas contents; f must be same size & depth and unhibernated"
	canvasForm unhibernate.
	f bits replaceFrom: 1 to: f bits size with: canvasForm bits startingAt: 1.

	undoList addFirst: f.
	undoIndex := 0.

]

{ #category : #'registration point' }
PaintCanvas >> saveRegPointForUndo [
	"Save the current registration point to allow undoing." 

	regPointUndoList ifNil: [  "create registration point undo list"
		regPointUndoList := OrderedCollection new.
		regPointUndoIndex := 0].

	registrationPoint ifNotNil: [
		regPointUndoList addFirst: registrationPoint.
		regPointUndoIndex := 0].

]

{ #category : #'private-tranforms' }
PaintCanvas >> saveTransformForUndo [
	"Save the current transform to allow undoing." 

	transformUndoList ifNil: [  "create transform undo list"
		transformUndoList := OrderedCollection new.
		transformUndoIndex := 0].

	transformUndoList addFirst: {
		transformScale.
		transformDegrees.
		transformHFlip.
		transformVFlip.
		selectionRect center}.

	transformUndoIndex := 0.

]

{ #category : #accessing }
PaintCanvas >> scale [

	^ scale

]

{ #category : #accessing }
PaintCanvas >> scale: aNumber [
	"Set the scale factor of my view. For example, 8 shows each pixel of canvas at eight times its actual size." 

	| oldCenter |
	oldCenter := self screenToCanvas: self center.
	scale := aNumber asFloat max: 0.01.
	self centerAt: oldCenter.

]

{ #category : #'private-tranforms' }
PaintCanvas >> scaleBy: scaleFactor [
	"Scale my contents by the given factor."

	| maxScale |
	palette showRotationCenter: false.
	self prepareToTransform.
	transformSrcForm ifNil: [^ self].
	maxScale := 1000.0 / (transformSrcForm width max: transformSrcForm height).
	self saveTransformForUndo.
	transformScale := (transformScale * scaleFactor) min: maxScale.
	self applyTransform.

]

{ #category : #private }
PaintCanvas >> screenToCanvas: aPoint [
	"Answer the given screen point in canvas coordinates."

	^ ((aPoint - bounds origin) // scale) + (scrollX@scrollY)

]

{ #category : #accessing }
PaintCanvas >> scrollFractionX [
	"Answer my horizontal scroll fraction, a number between 0.0 and 1.0."

	| total |
	total := canvasForm width - (self width // scale).
	total <= 0.0 ifTrue: [^ 0.0]. 
	^ (scrollX asFloat / total) min: 1.0


]

{ #category : #accessing }
PaintCanvas >> scrollFractionX: aNumber [

	| total |
	total := canvasForm width - (self width // scale).
	scrollX := (aNumber * total) rounded within: 0 and:  canvasForm width.
	self changed.

]

{ #category : #accessing }
PaintCanvas >> scrollFractionY [
	"Answer my vertical scroll fraction, a number between 0.0 and 1.0."

	| total |
	total := canvasForm height - (self height // scale).
	total <= 0.0 ifTrue: [^ 0.0].
	^ (scrollY asFloat / total) min: 1.0


]

{ #category : #accessing }
PaintCanvas >> scrollFractionY: aNumber [

	| total |
	total := canvasForm height - (self height // scale).
	scrollY := (aNumber * total) rounded within: 0 and: canvasForm height.
	self changed.

]

{ #category : #private }
PaintCanvas >> selectAll [
	"Select all non-transparent pixels and switch to move mode."

	| r |
	self commitMove.
	r := canvasForm rectangleEnclosingPixelsNotOfColor: Color transparent.
	r area = 0 ifTrue: [^ self].
	selectionRect := r.
	palette mode: #move.
	self changed.

]

{ #category : #'event handling' }
PaintCanvas >> selectRectangleStartingAt: aPoint [
	"Set selectionRect to a rectangular area starting at the given canvas point."

	| p |
	selectionRect := aPoint extent: 0@0.
	showSelection := true.
	World activeHand showTemporaryCursor: nil.
	Cursor crossHair showWhile: [
		[Sensor anyButtonPressed] whileTrue: [
			p := Sensor cursorPoint.
			self autoScroll: p.
			self canvasChanged: selectionRect.
			selectionRect := aPoint rectangle: (self screenToCanvas: p).
			selectionRect := selectionRect intersect: canvasForm boundingBox.
			self canvasChanged: selectionRect.
			World displayWorld]].
	showSelection := false.
	self changed.
	World displayWorld.

	selectionRect area = 0 ifTrue: [selectionRect := nil].
	^ selectionRect

]

{ #category : #'button actions' }
PaintCanvas >> shrink [

	Sensor shiftPressed ifTrue: [^ self magnify].
	self scaleBy: (1.0 / EnlargeFactor).

]

{ #category : #'event handling' }
PaintCanvas >> stampAt: aPoint [
	"Perform a stamp operation at the given point. If there is no stamp form, grab one from the screen. Otherwise, stamp it at the given point in canvas coordinates."

	| canvasR |
	moveOrStampForm ifNil: [  "no stamp form yet; grab one"
		canvasR := self selectRectangleStartingAt: aPoint.
		canvasR ifNil: [^ self].
		selectionRect := nil.
		moveOrStampForm := canvasForm copy: canvasR.
		moveOrStampForm ifNil: [^ self].  "empty selection rectangle"
		dragOffset := moveOrStampForm extent // 2.
		self installCursorInHand: World activeHand. "update cursor"
		^ self].

	"stamp the stamp form"
	moveOrStampForm
		displayOn: canvasForm
		at: (aPoint - (moveOrStampForm extent // 2))
		rule: Form paint.
	canvasR := (aPoint - (moveOrStampForm extent // 2)) extent: moveOrStampForm extent.
	self canvasChanged: canvasR.

]

{ #category : #'private-move tool' }
PaintCanvas >> startMove [
	"Start a move operation if there is a selection rectangle and if a move operation is not already in progress. (A move is in progress if moveOrStampForm is not nil.) Copy the canvas bits within the selection rectangle and clear that part of the canvas."

	transformSrcForm ifNotNil: [self saveTransformForUndo].
	moveOrStampForm notNil | selectionRect isNil ifTrue: [^ self].

	self saveForUndo.
	moveOrStampForm := canvasForm copy: selectionRect.
	canvasForm fill: selectionRect fillColor: Color transparent.

]

{ #category : #stepping }
PaintCanvas >> step [

	| h screenP canvasP |
	h := World activeHand.
	screenP := h gridPointRaw.
	canvasP := self screenToCanvas: screenP.

	moveOrStampForm ifNotNil: [
		((palette mode = #stamp) or:
		 [(palette mode = #move) and: [h hasMouseFocus: self]]) ifTrue: [
			selectionRect ifNotNil: [self canvasChanged: selectionRect].
			selectionRect := canvasP - dragOffset extent: moveOrStampForm extent.
			self canvasChanged: (selectionRect expandBy: 1)]].	"force redraw to show move/stamp feedback"

	(bounds containsPoint: screenP) ifFalse: [^ self].

	palette mode = #move ifTrue: [
		selectionRect ifNil: [h showTemporaryCursor: Cursor crossHair].
		(selectionRect notNil and: [Sensor anyButtonPressed not]) ifTrue: [
			(selectionRect containsPoint: canvasP)
				ifTrue: [h showTemporaryCursor: Cursor handOpen]
				ifFalse: [h showTemporaryCursor: Cursor crossHair]]].

	palette mode = #text ifTrue: [
		(self textHandleContainsPoint: canvasP)
			ifTrue: [h showTemporaryCursor: Cursor handOpen]
			ifFalse: [h showTemporaryCursor: Cursor normal]].

]

{ #category : #stepping }
PaintCanvas >> stepTime [

	^ 100

]

{ #category : #accessing }
PaintCanvas >> textColor [

	^ textColor

]

{ #category : #accessing }
PaintCanvas >> textColor: aColor [

	textColor := aColor.

]

{ #category : #'event handling' }
PaintCanvas >> textHandleContainsPoint: aPoint [
	"Answer true if the the text handle contains the given point in canvas coordinates."

	^ #text = palette mode and:[
	 	(textBox topLeft - 5 extent: 9@9) containsPoint: aPoint] 
]

{ #category : #'event handling' }
PaintCanvas >> textMouseDown: evt [
	"Handle a mouse down event in text mode at the given point in canvas coordinates."

	| p |
	evt hand newKeyboardFocus: self.
	p := self screenToCanvas: evt cursorPoint.

	(self textHandleContainsPoint: p) ifTrue: [  "click in drag handle"
		dragOffset := textBox position - p.
		textDragMode := #move.
		^ self].

	((textBox bounds insetBy: 2) containsPoint: p) ifTrue: [  "click in textBox"
		textDragMode := #select.
		textBox mouseDown: (evt copy cursorPoint: p).
		evt hand newKeyboardFocus: self.  "take focus back from textBox"
		^ self].

	"click not in textBox or drag handle; do nothing"
	textDragMode := #none.


]

{ #category : #'event handling' }
PaintCanvas >> textMouseMove: evt [
	"Draw and/or give feedback."

	| p |
	p := self screenToCanvas: evt cursorPoint.
	#move = textDragMode ifTrue: [
		textBox position: ((p + dragOffset) max: 0@0).
		textBox extent: canvasForm extent - textBox position].
	#select = textDragMode ifTrue: [
		textBox mouseMove: (evt copy cursorPoint: p)].
	self changed.

]

{ #category : #'button actions' }
PaintCanvas >> undo [

	palette mode = #text ifTrue: [^ PhratchError error: 'beep'.].

	palette showRotationCenter ifTrue: [^ self undoRegPointMove].
	transformSrcForm ifNotNil: [^ self undoTransform].

	undoIndex >= undoList size ifTrue: [^ PhratchError error: 'beep'.].  "nothing more to undo"

	palette mode = #move ifTrue: [moveOrStampForm := selectionRect := nil].

	undoIndex = 0 ifTrue: [
		self saveForUndo.  "save the current canvas so we can redo"
		undoIndex := 1].

	undoIndex := undoIndex + 1.
	canvasForm := undoList at: undoIndex.
	self clearMoveState.
	self changed.

]

{ #category : #'registration point' }
PaintCanvas >> undoRegPointMove [

	regPointUndoList ifNil: [^ PhratchError error: 'beep'.].  "no undo entries yet"
	regPointUndoIndex >= regPointUndoList size ifTrue: [^ PhratchError error: 'beep'.].  "nothing more to undo"
	regPointUndoIndex = 0 ifTrue: [
		self saveRegPointForUndo.
		regPointUndoIndex := 1].

	regPointUndoIndex := regPointUndoIndex + 1.
	registrationPoint := regPointUndoList at: regPointUndoIndex.
	self changed.

]

{ #category : #'private-tranforms' }
PaintCanvas >> undoTransform [

	| rec |
	transformUndoList ifNil: [^ PhratchError error: 'beep'.].  "no undo entries yet"
	transformUndoIndex >= transformUndoList size ifTrue: [^ PhratchError error: 'beep'.].  "nothing more to undo"
	transformUndoIndex = 0 ifTrue: [
		self saveTransformForUndo.
		transformUndoIndex := 1].

	transformUndoIndex := transformUndoIndex + 1.
	rec := transformUndoList at: transformUndoIndex.
	transformScale := rec at: 1.
	transformDegrees := rec at: 2.
	transformHFlip := rec at: 3.
	transformVFlip := rec at: 4.
	selectionRect := Rectangle center: (rec at: 5) extent: selectionRect extent.
	self applyTransform.

]
