Extension { #name : #ScriptablePhratchMorph }

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> addCostumeTyped: aString [

	| newC frameForm title result fList type |
	aString = 'camera' ifTrue: [
		
		self cameraIsOpen ifTrue: [
			self flag:'this is crappy, but works...'.
			frameForm := Form extent: (CameraPlugin frameExtent: 1) depth: 32.
			CameraPlugin getFrameForCamera: 1 into: frameForm bits.
			(2 seconds) asDelay wait.
			CameraPlugin getFrameForCamera: 1 into: frameForm bits.
			
			
			newC := ImageMedia new form: frameForm]
		ifFalse: [^ self]]."]]]."
	aString = 'stage' ifTrue: [newC := ImageMedia new form: ((self ownerOrYourselfThatIsAPhratchStageMorph) stageShotForm"Sized: 480@360")].
	aString = 'paint new' ifTrue: [self drawNewCostume.
		^ self updateAfterPopUp
	].
	aString = 'import' ifTrue: [
		(self isPhratchStageMorph)
			ifTrue: [type := #background. title := 'Import Background']
			ifFalse: [type := #costume. title := 'Import Costume'].
		result := PhratchFileChooserDialog
			chooseImageFileType: type
			title: title.
		result = #cancelled ifTrue: [^ self updateAfterPopUp].

		fList := OrderedCollection new.
		[fList addLast: (Form fromFileNamed: result)] ifError: [^ self updateAfterPopUp].

		newC := ImageMedia new form: fList first.
		self updateAfterPopUp].
	newC mediaName: (self unusedMediaNameFromBaseName: (self defaultImageMedia mediaName)).
	media addLast: newC.
	self lookLike: newC mediaName.
	self updateMediaCategory.
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> brightnessEffect [

	| att |
	att := #brightness.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ [filterPack brightnessShift] ifError: [0]
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> brightnessEffect: aNumber [

	self undeleteAttribute: #brightness.
	self passiveBrightnessEffect: aNumber
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> changeGraphicEffect: effect by: aNumber [
	"Change the given graphic effect by the given value."
	<phratchItem: 'change $Effects$ effect by $Number$' kind: #- category: 'looks' defaultValues: #('color' 25) subCategory: #a3 special: #()>
	
	'brightness' = effect ifTrue: [self brightnessEffect: self brightnessEffect + aNumber asNumberNoError].
	'fisheye' = effect ifTrue: [self fisheyeEffect: self fisheyeEffect + aNumber asNumberNoError].
	'color' = effect ifTrue: [self colorEffect: self colorEffect + aNumber asNumberNoError].
	'mosaic' = effect ifTrue: [self mosaicEffect: self mosaicEffect + aNumber asNumberNoError].
	'pixelate' = effect ifTrue: [self pixelateEffect: self pixelateEffect + aNumber asNumberNoError].
	'ghost' = effect ifTrue: [
		self transparencyEffect: self transparencyEffect + aNumber asNumberNoError].
	'whirl' = effect ifTrue: [self whirlEffect: self whirlEffect + aNumber asNumberNoError].

]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> closeDefinitivelyCamera [
	"Close the camera. Do nothing if the camera is already close."
	<phratchItem: 'close camera' kind: #- category: 'looks' defaultValues: #() subCategory: #a9 special: #()>
	self cameraIsOpen
		ifFalse: [ ^ self ].
	CameraOpenings := 0.
	CameraPlugin closeCamera: 1
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> colorEffect [

	| att |
	att := #color.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ [filterPack hueShift] ifError: [0]
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> colorEffect: aNumber [

	self undeleteAttribute: #color.
	self passiveColorEffect: aNumber

]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> deleteCostumeAt: index [
	"Delete the costume at the given index."

	| cList |
	cList := media reject: [:m | m isSound].

	self deleteMedia: (cList at: index).
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> doWithCamOpen [
	"Do the included block while opening the camera"
	<phratchItem: 'do with camera open' kind: #CBlockMorph category: 'looks' defaultValues: #() subCategory: #a9 special: #()>
	
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> editDrawingOldCostumeName: oldCostumeName deleteOnCancel: aBoolean deleteCostume: delCost [
	"Edit my original form with the paint editor."

	| sFrame paintEditor |
	costume isMovie ifTrue: [^ PhratchError error: 'beep'.].
	(sFrame := self ownerThatIsAPhratchFrameMorph) ifNil: [(sFrame := (self ownerThatIsAOffscreenWorldMorph) frame) ifNil: [^ self]].

	sFrame paintingInProgress ifTrue: [^ PhratchError error: 'beep'.].
	"sFrame stopAll."
	sFrame paintingInProgress: true.

	paintEditor := PaintFrame new.
	paintEditor
		withStartingObject: self;
		phratchFrame: sFrame;
		oldCostumeName: oldCostumeName deleteOnCancel: aBoolean;
		deleteCostumeOnCancel: delCost.

	oldCostumeName ifNotNil: [
		"When an oldCostumeName is supplied, it means I'm making a new drawing. Clear the initial rotation center."
		paintEditor clearRotationCenter].

	(paintEditor isDialogBoxMorph)
		ifTrue: [paintEditor getUserResponse]
		ifFalse: [
			World addMorphFront: paintEditor.
			World startSteppingSubmorphsOf: paintEditor].

]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> filterReset [
	"Reset all the graphics filters applied to the sprite"
	<phratchItem: 'clear graphic effects' kind: #- category: 'looks' defaultValues: #() subCategory: #a3 special: #()>
	filterPack := nil.
	self transparency: 0.
	self costumeChanged.
	self spread.

	self
		colorEffect: 0;
		fisheyeEffect: 0;
		whirlEffect: 0;
		pixelateEffect: 0;
		mosaicEffect: 0;
		brightnessEffect: 0;
		transparencyEffect: 0
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> fisheyeEffect [

	| att |
	att := #fisheye.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].
	^ [filterPack fisheye] ifError: [0]
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> fisheyeEffect: aNumber [

	self undeleteAttribute: #fisheye.
	self passiveFisheyeEffect: aNumber
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> graphicEffectNamed: effect [
"Answer the provided graphic effect"
	<phratchItem: '$Effects$ effect' kind: #ReporterWatcherBlockMorph category: 'looks' defaultValues: #('color') subCategory: #a3 special: #()>
	filterPack ifNil: [filterPack := FilterPack new].

	'brightness' = effect ifTrue: [^ filterPack brightnessShift].
	'fisheye' = effect ifTrue: [^ filterPack fisheye].
	'color' = effect ifTrue: [^ filterPack hueShift].
	'mosaic' = effect ifTrue: [^ filterPack mosaicCount].
	'pixelate' = effect ifTrue: [^ filterPack pixelateCount].
	'ghost' = effect ifTrue: [^ self transparency].
	'whirl' = effect ifTrue: [^ filterPack whirl].
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> mosaicEffect [

	| att |
	att := #mosaic.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ [filterPack mosaicCount] ifError: [0]
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> mosaicEffect: aNumber [

	self undeleteAttribute: #mosaic.
	self passiveMosaicEffect: aNumber
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> nextCostume [
	"Show the next costume in my costumes list."
	self lookLike: self costumeIndex + 1.

]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> passiveBrightnessEffect: aNumber [

	self privateSetGraphicEffect: 'brightness' to: aNumber asNumberNoError.
	self propagate: #brightness
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> passiveColorEffect: aNumber [

	self privateSetGraphicEffect: 'color' to: aNumber asNumberNoError.
	self propagate: #color.
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> passiveFisheyeEffect: aNumber [

	self privateSetGraphicEffect: 'fisheye' to: aNumber asNumberNoError.
	self propagate: #fisheye
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> passiveMosaicEffect: aNumber [

	self privateSetGraphicEffect: 'mosaic' to: aNumber asNumberNoError.
	self propagate: #mosaic

]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> passivePixelateEffect: aNumber [

	self privateSetGraphicEffect: 'pixelate' to: aNumber asNumberNoError.
	self propagate: #pixelate
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> passiveSetHideFlagTo: aBool [

	(aBool isBoolean) 
		ifFalse: [^ self error: 'expecting a Boolean'].
	self isHidden: aBool.
	self spread.
	self propagate: #isHidden
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> passiveTransparencyEffect: aNumber [

	self privateSetGraphicEffect: 'ghost' to: aNumber asNumberNoError.
	self propagate: #ghost
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> passiveWhirlEffect: aNumber [

	self privateSetGraphicEffect: 'whirl' to: aNumber asNumberNoError.
	self propagate: #whirl
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> pixelateEffect [

	| att |
	att := #pixelate.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ [filterPack pixelateCount] ifError: [0]
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> pixelateEffect: aNumber [

	self undeleteAttribute: #pixelate.
	self passivePixelateEffect: aNumber
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> privateSetGraphicEffect: effect to: aNumber [
	"Set the given graphic effect to the given value."

	filterPack ifNil: [filterPack := FilterPack new].

	'brightness' = effect ifTrue: [filterPack brightnessShift: aNumber].
	'fisheye' = effect ifTrue: [filterPack fisheye: aNumber].
	'color' = effect ifTrue: [filterPack hueShift: aNumber].
	'mosaic' = effect ifTrue: [filterPack mosaicCount: aNumber].
	'pixelate' = effect ifTrue: [filterPack pixelateCount: aNumber].
	'ghost' = effect ifTrue: [self transparency: aNumber].
	'whirl' = effect ifTrue: [filterPack whirl: aNumber].

	costumeChangeMSecs := Time millisecondClockValue.
	self layoutChanged.
	self changed.
	self spread
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> replaceCostume: aNumber with: aString [
	
	| cList i newC name j m frameForm title result fList type |
	cList := media reject: [:l | l isSound].
	cList size = 0 ifTrue: [^ self].  "should never happen..."
	i := ((aNumber rounded - 1) \\ cList size) + 1.
	name := (cList at: i) mediaName.
	aString = 'camera' ifTrue: [
		"(CameraPlugin openCamera: 1 width: 480 height: 360) ifNotNil: [
			CameraPlugin waitForCameraStart.
			(CameraPlugin frameExtent: 1) x = 0 ifFalse: ["
		self cameraIsOpen ifTrue: [
			frameForm := Form extent: (CameraPlugin frameExtent: 1) depth: 32.
			CameraPlugin getFrameForCamera: 1 into: frameForm bits.
			newC := ImageMedia new form: frameForm]
		ifFalse: [^ self]]."]]]."
	aString = 'stage' ifTrue: [newC := ImageMedia new form: ((self ownerOrYourselfThatIsAPhratchStageMorph) stageShotForm"Sized: 480@360")].
	aString = 'paint new' ifTrue: [self editDrawingOldCostumeName: name deleteOnCancel: false deleteCostume: false.
		^ self updateAfterPopUp.
		].
	aString = 'import' ifTrue: [
		(self isPhratchStageMorph)
			ifTrue: [type := #background. title := 'Import Background']
			ifFalse: [type := #costume. title := 'Import Costume'].
		result := PhratchFileChooserDialog
			chooseImageFileType: type
			title: title.
		result = #cancelled ifTrue: [^ self updateAfterPopUp.].

		fList := OrderedCollection new.
		[fList addLast: (Form fromFileNamed: result)] ifError: [^ self updateAfterPopUp].

		newC := ImageMedia new form: fList first.
		self updateAfterPopUp].
	j := 1.
	newC mediaName: name.
	[j <= media size] whileTrue: [
		m := media at: j.
		((m isSound not) and: [m mediaName = name]) ifTrue: [
			media at: j put: newC.
			self lookLike: name.
			^ self updateMediaCategory.].
		j := j + 1].
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> setGraphicEffect: effect to: aNumber [
	"Set the given graphic effect to the given value."
	<phratchItem: 'set $Effects$ effect to $Number$' kind: #- category: 'looks' defaultValues: #('color' 0) subCategory: #a3 special: #()>
	
	'brightness' = effect ifTrue: [self brightnessEffect: aNumber].
	'fisheye' = effect ifTrue: [self fisheyeEffect: aNumber].
	'color' = effect ifTrue: [self colorEffect: aNumber].
	'mosaic' = effect ifTrue: [self mosaicEffect: aNumber].
	'pixelate' = effect ifTrue: [self pixelateEffect: aNumber].
	'ghost' = effect ifTrue: [self transparencyEffect: aNumber].
	'whirl' = effect ifTrue: [self whirlEffect: aNumber].

]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> setHideFlagTo: aBool [

	self undeleteAttribute: #isHidden.
	self passiveSetHideFlagTo: aBool
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> transparency [
	"Answer my transparency. 0 is opaque; 100 is transparent."

	^ 100 - self visibility

]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> transparency: aNumber [
	"Set my transparency. 0 is opaque; 100 is transparent."

	self visibility: (100 - aNumber abs).

]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> transparencyEffect [

	| att |
	att := #ghost.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ self transparency
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> transparencyEffect: aNumber [

	self undeleteAttribute: #ghost.
	self passiveTransparencyEffect: aNumber
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> whirlEffect [

	| att |
	att := #whirl.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ [filterPack whirl] ifError: [0]
]

{ #category : #'*PhratchLooks' }
ScriptablePhratchMorph >> whirlEffect: aNumber [

	self undeleteAttribute: #whirl.
	self passiveWhirlEffect: aNumber
]
