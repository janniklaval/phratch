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
ScriptablePhratchMorph >> doWithCamOpen [
	"Do the included block while opening the camera"
	<phratchItem: 'do with camera open' kind: #CBlockMorph category: 'looks' defaultValues: #() subCategory: #a9 special: #()>
	
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
ScriptablePhratchMorph >> nextCostume [
	"Show the next costume in my costumes list."
	self lookLike: self costumeIndex + 1.

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
