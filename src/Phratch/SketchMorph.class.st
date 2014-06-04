"
I represent a color bitmapped image that can be rotated, scaled, and edited using the PaintBox (SketchEditorMorph and PaintBoxMorph).

originalForm holds the original bitmap, before any rotation or scaling. rotatedForm is cache of the rotated and scaled version of originalForm.

rotationCenter is the center of rotation in originalForm. When the rotation or scaling is changed, the system keeps the location of the rotation center on the screen fixed. Thus, rotation centers can be used as the registration points for a sequence of instance of me representing animation frames.

rotationStyle has several possible values:
	normal		continuous rotation
	leftRight	rotatation with an x component < 0, flip bitmap around the y-axis, otherwise it is not rotated
	upDown		rotatation with an y component < 0, flip bitmap around the x-axis, otherwise it is not rotated
	none		never rotate

"
Class {
	#name : #SketchMorph,
	#superclass : #Morph,
	#instVars : [
		'originalForm',
		'rotationCenter',
		'rotationDegrees',
		'rotationStyle',
		'scalePoint',
		'rotatedForm',
		'offsetWhenRotated'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #'instance creation' }
SketchMorph class >> withForm: aForm [
	"Note: 'SketchMorph withForm: f' is faster than 'SketchMorph new form: f'."

	^ self basicNew initializeWith: aForm

]

{ #category : #menu }
SketchMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addLine.
	aCustomMenu add: 'grab from screen' translated action: #grabFromScreen.
	aCustomMenu add: 'read from file' translated action: #readFromFile.
	aCustomMenu addLine.
	aCustomMenu add: 'save as BMP' translated action: #saveAsBMP.
	aCustomMenu add: 'save as GIF' translated action: #saveAsGIF.
	aCustomMenu add: 'save as JPEG' translated action: #saveAsJPEG.
	aCustomMenu addLine.
	aCustomMenu add: 'set rotation center' translated action: #setRotationCenter.
	aCustomMenu add: 'set rotation style' translated action: #setRotationStyle.
	aCustomMenu add: 'erase pixels of color' translated action: #erasePixelsOfColor:.
	aCustomMenu add: 'recolor of pixels of color' translated action: #recolorPixelsOfColor:.
	aCustomMenu addLine.
	aCustomMenu add: 'repaint' translated action: #editDrawing
]

{ #category : #geometry }
SketchMorph >> containsPoint: aPoint [
 
	^ (self bounds containsPoint: aPoint) and:
	  [(self rotatedForm isTransparentAt: aPoint - bounds origin) not]

]

{ #category : #drawing }
SketchMorph >> drawOn: aCanvas [

	aCanvas paintImage: self rotatedForm at: bounds origin.

]

{ #category : #menu }
SketchMorph >> editDrawing [
	"Edit my original form with the paint editor."

	| myPaint |
	World abandonAllHalos; displayWorld.
	myPaint := PaintFrame new.
	World addMorph: myPaint.
	myPaint withStartingObject: self.

]

{ #category : #other }
SketchMorph >> editedForm: aForm textBox: ignored [
	"Accept a new form after editing."

	originalForm := aForm.
	self layoutChanged.

]

{ #category : #menu }
SketchMorph >> erasePixelsOfColor: evt [

	| c r |
	c := evt hand chooseColor.
	originalForm mapColor: c to: Color transparent.
	r := originalForm rectangleEnclosingPixelsNotOfColor: Color transparent.
	self form: (originalForm copy: r).


]

{ #category : #geometry }
SketchMorph >> extent: newExtent [
	"Change my scale to fit myself into the given extent."

	| radians s c divisor w h origExtent |
	radians := rotationDegrees degreesToRadians.
	s := radians sin abs.
	c := radians cos abs.
	divisor := (c * c) - (s * s).
	w := ((c * newExtent x) - (s * newExtent y)) / divisor.
	h := ((c * newExtent y) - (s * newExtent x)) / divisor.
	origExtent := originalForm extent.
	rotationStyle = #normal
		ifTrue: [
			scalePoint :=
				((w asFloat / origExtent x) max: 0.001) @
				((h asFloat / origExtent y) max: 0.001).
			divisor abs < 0.5 ifTrue: [  "avoid instability near multiples of 45 degrees"
				s := newExtent r / (origExtent r * 2 sqrt).
				scalePoint := s@s]]
		ifFalse: [  "scaling for constraint rotation styles"
			scalePoint :=
				((newExtent x max: 1) asFloat / origExtent x) @
				((newExtent y max: 1) asFloat / origExtent y)].
	self layoutChanged.

]

{ #category : #accessing }
SketchMorph >> form [
 
	^ originalForm

]

{ #category : #accessing }
SketchMorph >> form: aForm [

	originalForm := aForm.
	rotationCenter := aForm extent // 2.
	rotationDegrees := 0.0.
	self layoutChanged.

]

{ #category : #drawing }
SketchMorph >> generateRotatedForm [
	"Compute my rotatedForm and offsetWhenRotated."

	"headed down; use flipped"

	| adjustedAngle smoothPix pair |
	adjustedAngle := rotationStyle = #normal
		ifTrue: [ rotationDegrees ]
		ifFalse: [ 0.0 ].	"smooth rotation"	"leftRight, upDown, none"
	((adjustedAngle closeTo: 0.0) and: [ 1.0 @ 1.0 = scalePoint ])
		ifTrue: [ 
			"no rotation or scaling; use original"
			rotatedForm := originalForm.
			offsetWhenRotated := 0 @ 0 ]
		ifFalse: [ 
			"generated rotated and/or scaled form"
			smoothPix := (scalePoint x < 1.0 or: [ scalePoint y < 1.0 ])
				ifTrue: [ 2 ]
				ifFalse: [ 1 ].
			pair := WarpBlt
				rotatePhratch: originalForm
				degrees: adjustedAngle negated
				center: rotationCenter
				scaleBy: self scalePoint
				smoothing: smoothPix.
			rotatedForm := pair first.
			offsetWhenRotated := pair last negated ].
	(rotationStyle = #leftRight and: [ rotationDegrees < 0.0 ])
		ifTrue: [ 
			"headed left; use flipped"
			rotatedForm := rotatedForm flipBy: #horizontal centerAt: 0 @ 0.
			offsetWhenRotated := offsetWhenRotated + ((2 * (rotationCenter x - (originalForm width // 2))) @ 0 * scalePoint).
			^ self ].
	(rotationStyle = #upDown and: [ rotationDegrees > 90.0 or: [ rotationDegrees < -90.0 ] ])
		ifFalse: [ ^ self ].
	rotatedForm := rotatedForm flipBy: #vertical centerAt: 0 @ 0.
	offsetWhenRotated := offsetWhenRotated + (0 @ (2 * (rotationCenter y - (originalForm height // 2))) * scalePoint).
	^ self
]

{ #category : #menu }
SketchMorph >> grabFromScreen [

	self form: Form fromUser.

]

{ #category : #initialization }
SketchMorph >> initialize [
	super initialize.
	^ self initializeWith: ImageMorph defaultForm

]

{ #category : #initialization }
SketchMorph >> initializeWith: aForm [

	super initialize.
	originalForm := aForm.
	rotationCenter := aForm extent // 2.	"relative to the top-left corner of the Form"
	rotationDegrees := 0.0.				"clockwise angle of rotation"
	rotationStyle := #normal.				"#normal, #leftRight, #upDown, or #none"
	scalePoint := 1.0@1.0.
	rotatedForm := originalForm.			"cached rotated/scaled copy of originalForm"
	offsetWhenRotated := 0@0.			"offset for rotated form"
	self extent: originalForm extent.

]

{ #category : #'change reporting' }
SketchMorph >> layoutChanged [
	"Update rotatedForm and offsetWhenRotated and compute new bounds."

	| unrotatedOrigin |
	self changed.
	unrotatedOrigin := bounds origin - offsetWhenRotated.
	(rotationStyle == #none and: [scalePoint = (1.0@1.0)])
		ifTrue: [
			"zero rotation and scale; use original Form"
			rotatedForm := originalForm.
			offsetWhenRotated := 0@0]
		ifFalse: [self generateRotatedForm].	"changes offsetWhenRotated"

	bounds := (unrotatedOrigin + offsetWhenRotated) extent: rotatedForm extent.
	super layoutChanged.
	self changed.

]

{ #category : #menu }
SketchMorph >> readFromFile [

	|  fileName |
	fileName := UIManager default
		request: 'Please enter the image file name' translated
		initialAnswer: 'fileName'.
	fileName isEmptyOrNil ifTrue: [^ self].
	self form: (Form fromFileNamed: fileName).

]

{ #category : #menu }
SketchMorph >> recolorPixelsOfColor: evt [

	| c d newForm map newC |
	c := evt hand chooseColor.  "color to replace"
	newC := evt hand chooseColor.  "new color"
	d := originalForm depth.
	newForm := Form extent: originalForm extent depth: d.
	map := (Color cachedColormapFrom: d to: d) copy.
	map at: (c indexInMap: map) put: (newC pixelValueForDepth: d).
	newForm copyBits: newForm boundingBox
		from: originalForm at: 0@0
		colorMap: map.
	self form: newForm.

]

{ #category : #accessing }
SketchMorph >> referencePosition [
 
	^ (bounds origin - offsetWhenRotated) + rotationCenter

]

{ #category : #accessing }
SketchMorph >> referencePosition: aPoint [
 
	self position: (aPoint - rotationCenter) + offsetWhenRotated.

]

{ #category : #other }
SketchMorph >> releaseCachedState [
	"Clear cache of rotated, scaled Form."

	super releaseCachedState.
	rotatedForm := nil.
	originalForm hibernate.

]

{ #category : #accessing }
SketchMorph >> rotatedForm [
 
	rotatedForm ifNil: [self layoutChanged].
	^ rotatedForm

]

{ #category : #accessing }
SketchMorph >> rotationCenter [
 
	^ rotationCenter

]

{ #category : #accessing }
SketchMorph >> rotationCenter: aPoint [

	rotationCenter := aPoint.
	self layoutChanged.

]

{ #category : #accessing }
SketchMorph >> rotationDegrees [
 
	^ rotationDegrees

]

{ #category : #accessing }
SketchMorph >> rotationDegrees: angleInDegrees [
	rotationDegrees ~= angleInDegrees
		ifFalse: [ ^ self ].
	rotationDegrees := angleInDegrees \\ 360.0.
	self layoutChanged
]

{ #category : #accessing }
SketchMorph >> rotationDegrees: newRotationDegrees scalePoint: newScalePoint [
	(newRotationDegrees ~= rotationDegrees or: [ scalePoint ~= newScalePoint ])
		ifFalse: [ ^ self ].
	rotationDegrees := newRotationDegrees \\ 360.0.
	scalePoint := newScalePoint.
	self layoutChanged
]

{ #category : #accessing }
SketchMorph >> rotationStyle [
 
	^ rotationStyle

]

{ #category : #accessing }
SketchMorph >> rotationStyle: aSymbol [
	"Set my rotation style to #normal, #leftRight, #upDown, or #none. Styles mean:
		#normal		-- continuous 360 degree rotation
		#leftRight		-- quantize angle to left or right facing
		#upDown		-- quantize angle to up or down facing
		#none			-- do not rotate"

	| oldStyle |
	oldStyle := rotationStyle.
	rotationStyle := aSymbol.
	((aSymbol = #normal) and: [oldStyle ~= #normal]) ifTrue: [self rotationDegrees: 0.0].
	self layoutChanged.

]

{ #category : #menu }
SketchMorph >> saveAsBMP [

	| formToSave  fileName |
	formToSave := originalForm asFormOfDepth: 32.

	fileName := UIManager default request: 'File name?'.
	fileName size = 0 ifTrue: [^ self].
	(fileName asLowercase endsWith: '.bmp') ifFalse: [
		fileName := fileName, '.bmp'].

	formToSave writeBMPFileNamed: fileName.

]

{ #category : #menu }
SketchMorph >> saveAsGIF [

	| formToSave  fileName |
	formToSave := originalForm.
	formToSave depth > 8 ifTrue: [
		formToSave := originalForm colorReduced.
		formToSave depth > 8 ifTrue: [
			(self confirm:
'Saving as GIF will reduce to 8-bit color
with some loss of quality. Continue?') ifFalse: [^ self].
			formToSave := originalForm asFormOfDepth: 8]].

	fileName := UIManager default request: 'File name?'.
	fileName size = 0 ifTrue: [^ self].
	(fileName asLowercase endsWith: '.gif') ifFalse: [
		fileName := fileName, '.gif'].

	GIFReadWriter putForm: formToSave onFileNamed: fileName.

]

{ #category : #menu }
SketchMorph >> saveAsJPEG [
	"Save my originalForm in JPEG format. Convert to 16-bit color if necessary."

	| formToSave quality fileName bytes f |
	formToSave := originalForm.
	formToSave depth < 16 ifTrue: [
		formToSave := originalForm asFormOfDepth: 16].

	quality := UIManager default request: 'JPEG Quality (1-100):' initialAnswer: '50'.
	((quality size = 0) or: [quality first isDigit not]) ifTrue: [^ self].

	fileName := UIManager default request: 'File name?'.
	fileName size = 0 ifTrue: [^ self].
	(fileName asLowercase endsWith: '.jpg') ifFalse: [
		fileName := fileName, '.jpg'].

	bytes := PluginBasedJPEGReadWriter new compress: formToSave quality: quality asNumber.
	f := (FileStream newFileNamed: fileName) binary.
	f nextPutAll: bytes; close.

]

{ #category : #accessing }
SketchMorph >> scalePoint [

	scalePoint ifNil: [scalePoint := 1.0@1.0].
	^ scalePoint

]

{ #category : #accessing }
SketchMorph >> scalePoint: aPoint [

	scalePoint := aPoint.
	self layoutChanged.

]

{ #category : #menu }
SketchMorph >> setRotationCenter [
	"Interactively set the rotation center in my original form."

	| w p oldRotation oldScale |
	(w := self world) ifNil: [^ self].

	"undo current rotation and scale..."
	oldRotation := rotationDegrees.
	oldScale := scalePoint.
	self rotationDegrees: 0.0 scalePoint: 1.0@1.0.
	"self positionTalkBubble."

	w displayWorldSafely.

	Cursor crossHair showWhile: [p := Sensor waitButton].
	Sensor waitNoButton.
	self rotationCenter: p - bounds origin.

	"restore old rotation and scale:"
	self rotationDegrees: oldRotation scalePoint: oldScale.

]

{ #category : #menu }
SketchMorph >> setRotationStyle [

	| menu |
	menu := MenuMorph new defaultTarget: self.
	#('rotate smoothly' 'left-right flip only' 'up-down flip only' 'don''t rotate')
		with: #(normal leftRight upDown none)
		 do: [:name :action | menu 
				add: name
				target: self 
				selector: #rotationStyle:
				argument: action].
	menu popUpInWorld.
]
