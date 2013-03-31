"
I represent an image in a Scratch object's media closet.

"
Class {
	#name : #MediaItemMorph,
	#superclass : #Morph,
	#instVars : [
		'scratchObj',
		'media',
		'thumbnailMorph',
		'numberMorph',
		'nameMorph',
		'infoMorph',
		'soundSizeMorph',
		'playButton',
		'stopButton',
		'deleteButton',
		'highlightMorph',
		'topRightInset',
		'separator',
		'rightMorph',
		'highlightPadding',
		'numberMorphTopRight',
		'minThumbHeight'
	],
	#classVars : [
		'SoundIcon',
		'SoundIconOn'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'class initialization' }
MediaItemMorph class >> initialize [
	"Should run the Phratch installation first"
	PhratchInstaller beginInstall.

	ScratchFrameMorph readSkinFrom: (FileSystem workingDirectory /  'ScratchSkin').
	SoundIcon := (ScratchFrameMorph skinAt: #scratchSound).
	SoundIconOn := (ScratchFrameMorph skinAt: #scratchSoundOn).

]

{ #category : #initialization }
MediaItemMorph >> addPlayButton [

	| h |
	playButton := ResizableToggleButton2 new
		offForm: (ScratchFrameMorph skinAt: #btn)
		onForm: (ScratchFrameMorph skinAt: #btnPressed).

	playButton
		icon: (ScratchFrameMorph skinAt: #scratchSoundPlay);
		target: self;
		actionSelector: #startPreviewSound;
		toggleMode: false.

	h := (ScratchFrameMorph buttonLabel: 'Copy' localized selector: #duplicateMedia) height.
	h := h max: 21.
	playButton extent: (1.3 * h) rounded@h.

	rightMorph addMorphBack: playButton.

]

{ #category : #initialization }
MediaItemMorph >> addStopButton [

	| h |
	stopButton := ResizableToggleButton2 new
		offForm: (ScratchFrameMorph skinAt: #btn)
		onForm: (ScratchFrameMorph skinAt: #btnPressed).

	stopButton
		icon: (ScratchFrameMorph skinAt: #scratchSoundStop);
		target: self;
		actionSelector: #stopPreviewSound;
		toggleMode: false.

	h := (ScratchFrameMorph buttonLabel: 'Copy' localized selector: #duplicateMedia) height.
	h := h max: 21.
	stopButton extent: h@h.

	rightMorph addMorphBack: stopButton.

]

{ #category : #initialization }
MediaItemMorph >> buildRightSideMorph [
	"Answers the part of MediaItemMorph that includes the label, the edit/copy or record/play buttons, etc. This includes everything but the sprite image, the number, and the horizontal divider."

	| e c bottom |
	rightMorph := Morph new.
	rightMorph color: (Color transparent).

	nameMorph := UpdatingStringFieldMorph new
		acceptWhenFocusLost: true;
		font: (ScratchFrameMorph getFont: #UpdatingStringField);
		rightJustify: ScratchTranslator isRTL;
		getSelector: #mediaName;
		putSelector: #mediaName:;
		position: (0@0);
		target: self.

	nameMorph width: (5 * nameMorph height) asInteger.
	rightMorph addMorphBack: nameMorph.

	infoMorph := (ScratchStringMorph contents: (media infoString))
		font: (ScratchFrameMorph getFont: #MediaItemInfo);
		position: nameMorph left + 2 @ (nameMorph bottom).
	rightMorph addMorph: infoMorph.

	media isSound
		ifTrue: [
			self addPlayButton.
			playButton position: (nameMorph left)@(infoMorph bottom + 5).
			self addStopButton.
			stopButton position: playButton topRight + (5@0).
			deleteButton := self getDeleteButton.
			rightMorph addMorph: deleteButton.
			deleteButton left: stopButton right + 5.
			bottom := stopButton bottom.
		] ifFalse: [
			e := self getEditButton.
			rightMorph addMorph: e.
			e position: nameMorph left@(infoMorph bottom + 5).
			c := self getCopyButton.
			rightMorph addMorph: c.
			c position: e topRight + (5@0).
			deleteButton := self getDeleteButton.
			rightMorph addMorph: deleteButton.
			deleteButton position: c right + 5@5.
			bottom := c bottom].

	nameMorph extent: (deleteButton right max: nameMorph width)@(nameMorph extent y).
	deleteButton position: (nameMorph right - deleteButton width)@(infoMorph bottom + 6).

	soundSizeMorph := (ScratchStringMorph contents: '')
		font: (ScratchFrameMorph getFont: #MediaItemInfo);
		position: nameMorph right @ nameMorph bottom.
	rightMorph addMorph: soundSizeMorph.

	soundSizeMorph
		contents: media mediaSizeInKilobytes asString , ' KB';
		position: ((nameMorph right - soundSizeMorph width) @ nameMorph bottom).

	rightMorph extent: nameMorph width@bottom.

]

{ #category : #initialization }
MediaItemMorph >> buildSubmorphs [

	| thumbHeight |
	self buildRightSideMorph.

	numberMorph := (ScratchStringMorph contents: '345')
		font: (ScratchFrameMorph getFont: #MediaItemInfo);
		color: Color white;
		position: topRightInset.
	self addMorph: numberMorph.
	numberMorphTopRight := numberMorph topRight.

	thumbHeight := minThumbHeight max: (rightMorph height - (2 * highlightPadding y)).
	thumbnailMorph := TranslucentImageMorph new.
	thumbnailMorph form: (media thumbnailFormExtent: thumbHeight asPoint).
	thumbnailMorph width > thumbHeight ifTrue: [
		highlightPadding := (highlightPadding x - ((thumbnailMorph width - thumbHeight)/2))@highlightPadding y].
	self addMorph: thumbnailMorph.
	thumbnailMorph position: numberMorph topRight + highlightPadding.

	highlightMorph := ImageFrameMorph new
		initFromForm: (ScratchFrameMorph skinAt: #costumeSelected).
	highlightMorph extent: thumbnailMorph extent + (highlightPadding * 2).

	self addMorph: rightMorph.
	rightMorph position: thumbnailMorph topRight + ((highlightPadding x + 10)@highlightPadding y negated).
	rightMorph extent: rightMorph extent x@(rightMorph extent y max: highlightMorph extent y).

	separator := TiledImageMorph new tileForm: (ScratchFrameMorph skinAt: #costumeSeparatorTile).
	self addMorph: separator.
	separator
		position: (numberMorph left)@(rightMorph bottom + 5);
		width: rightMorph right - 14.
	
	self extent: (rightMorph right + 10)@separator bottom

]

{ #category : #'event handling' }
MediaItemMorph >> click: evt [
	"In a sound media item, if the thumbnail is clicked on, play the sound."

	| pos |
	pos := evt cursorPoint.
	(media isSound) ifFalse: [^ self].
	(thumbnailMorph bounds containsPoint: pos) ifTrue: [self startPreviewSound].

]

{ #category : #initialization }
MediaItemMorph >> configureForDragging [
	"Rebuild my submorphs to make a draggable version of me."
	"MediaItemMorph open configureForDragging"

	self removeAllMorphs.

	thumbnailMorph position: self position + highlightPadding.
	self addMorph: thumbnailMorph.

	highlightMorph position: self position.
	self addMorphBack: highlightMorph.

	self color: Color transparent.
	self extent: highlightMorph extent.

]

{ #category : #'menu/button ops' }
MediaItemMorph >> deleteMedia [

	ScratchFrameMorph putInClipboard: self configureForDragging.
	scratchObj deleteMedia: media.

]

{ #category : #'event handling' }
MediaItemMorph >> doubleClick: evt [

	media isImage ifTrue: [self editMedia].

]

{ #category : #'menu/button ops' }
MediaItemMorph >> duplicateMedia [

	scratchObj duplicateMedia: media.

]

{ #category : #'menu/button ops' }
MediaItemMorph >> editImage [

	scratchObj lookLike: media mediaName.
	scratchObj editDrawing.

]

{ #category : #'menu/button ops' }
MediaItemMorph >> editMedia [

	media isSound ifTrue: [self editSound].
	media isImage ifTrue: [self editImage].


]

{ #category : #'menu/button ops' }
MediaItemMorph >> editSound [

	| sFrame workPane editor |
	sFrame := self ownerOrYourselfThatIsA: ScratchFrameMorph.
	sFrame ifNil: [^ self].
	workPane := sFrame workPane.

	editor := ScratchSoundEditor new client: scratchObj; sound: media sound.
	editor soundName: media mediaName.
	editor position: workPane topLeft + (10@10).
	workPane addMorph: editor.
	workPane world ifNotNil: [workPane world startSteppingSubmorphsOf: editor].

]

{ #category : #'menu/button ops' }
MediaItemMorph >> exportMedia [

	| result title type |
	media isMovie ifTrue: [^ self].
	(self scratchObj isKindOf: ScratchStageMorph) ifTrue: 
		[type := #background. title := 'Export Background'].
	(self scratchObj isKindOf: ScratchSpriteMorph) ifTrue: 
		[type := #costume. title := 'Export Costume'].
	media isSound ifTrue: [type := #sound. title := 'Export Sound'].
	result := ScratchFileChooserDialog
		chooseNewFileDefault: media mediaName
		title: title
		type: type.
	result = #cancelled ifTrue: [^ self].
	result size > 0 ifTrue: [media exportFilename: result for: self scratchObj].

]

{ #category : #initialization }
MediaItemMorph >> getCopyButton [

	| b |
	b := ScratchFrameMorph buttonLabel: 'Copy' localized selector: #duplicateMedia.
	b target: self.
	^ b

]

{ #category : #initialization }
MediaItemMorph >> getDeleteButton [

	| b |
	b := ToggleButton
		onForm: (ScratchFrameMorph skinAt: #deleteCircleButtonPressed)
		offForm: (ScratchFrameMorph skinAt: #deleteCircleButton).
	b
		actionSelector: #deleteMedia;
		toggleMode: false.

	media isImage ifTrue: [(scratchObj isKindOf: ScratchStageMorph)
		ifTrue: [b setBalloonText: 'Delete this background' localized]
		ifFalse: [b setBalloonText: 'Delete this costume' localized]].
	media isSound ifTrue: [b setBalloonText: 'Delete this sound' localized].
	b target: self.
	^ b

]

{ #category : #initialization }
MediaItemMorph >> getEditButton [

	| b |
	b := ScratchFrameMorph buttonLabel: 'Edit' localized selector: #editMedia.
	b target: self.
	^ b

]

{ #category : #'event handling' }
MediaItemMorph >> handleTool: toolName hand: hand [

	toolName = 'CopyTool' ifTrue: [
		Sensor shiftPressed ifFalse: [hand toolType: nil].
		^ self duplicateMedia].

	toolName = 'CutTool' ifTrue: [
		Sensor shiftPressed ifFalse: [hand toolType: nil].
		self delete.
		ScratchFrameMorph putInClipboard: self configureForDragging.
		^ self deleteMedia].

]

{ #category : #'event handling' }
MediaItemMorph >> handlesMouseDown: evt [

	^ scratchObj notNil

]

{ #category : #accessing }
MediaItemMorph >> highlight: aBoolean [

	highlightMorph ifNil: [^ self].
	aBoolean
		ifTrue: [
			highlightMorph position: (self topLeft + numberMorphTopRight).
			highlightMorph owner = self ifFalse: [
				self addMorphBack: highlightMorph]]
		ifFalse: [
			highlightMorph owner = self ifTrue: [highlightMorph delete]].

]

{ #category : #initialization }
MediaItemMorph >> initialize [
 
	super initialize.
	topRightInset := 17@10.
	self extent: 285@81.
	self color: Color transparent.
	"this determines how far in in x and y the thumbnailMorph should be inside of the highlight when selected"
	highlightPadding := 20@5.
	"this determines the minimum size of the thumbnail. The thumbnail may grow larger with larger font sizes"
	minThumbHeight := 56.

]

{ #category : #'dropping/grabbing' }
MediaItemMorph >> justDroppedInto: aMorph event: evt [

	self delete.
	(aMorph ownerOrYourselfThatIsA: ScratchViewerMorph) ifNotNil: [
		"delete myself when dropped on the blocks palette"
		^ self deleteMedia].

	(aMorph ownerOrYourselfThatIsA: ScratchBlockPaletteMorph) ifNotNil: [
		"I have been accepted into a media list; exit this method to prevent myself from being put into the Clipboard again"
		^ self].

	(scratchObj media includes: media) not ifTrue: [
		"I have been dropped outside of the media list; allow myself to be resurrected again".
		^ self deleteMedia]

]

{ #category : #accessing }
MediaItemMorph >> media [

	^ media

]

{ #category : #accessing }
MediaItemMorph >> mediaName [

	media ifNotNil: [^ media mediaName]
]

{ #category : #accessing }
MediaItemMorph >> mediaName: name [

	| newName sFrame |
	newName := name.
	newName := self scratchObj unusedMediaNameFromBaseName: newName forMedia: self media.
	media mediaName: newName.
	nameMorph contents: newName.
	(sFrame := self ownerOrYourselfThatIsA: ScratchFrameMorph) ifNotNil: [
		sFrame viewerPane refresh].

]

{ #category : #'event handling' }
MediaItemMorph >> mouseDown: evt [
	"Handle a mouse click. Left button drags. Right button brings up a menu."

	scratchObj ifNil: [^ self].
	evt hand toolType ifNotNil: [
		^ self handleTool: evt hand toolType hand: evt hand].

	evt rightButtonPressed
		ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu]
		ifFalse:	[
			media isImage ifTrue: [scratchObj lookLike: media mediaName].
			evt hand waitForClicksOrDrag: self event: evt].

]

{ #category : #'event handling' }
MediaItemMorph >> mouseHold: evt [

	self rightButtonMenu.

]

{ #category : #printing }
MediaItemMorph >> printOn: aStream [

	aStream nextPutAll: self class name, '[', media mediaName, ']'.

]

{ #category : #'menu/button ops' }
MediaItemMorph >> rightButtonMenu [
	"Present the right button menu."

	| menu |
	menu := MenuMorph new defaultTarget: self.
	media isImage ifTrue: [
		menu add: 'turn into new sprite' action: #turnIntoNewSprite.
		menu add: 'export this costume' action: #exportMedia].
	media isSound ifTrue: [
		menu add: 'export this sound' action: #exportMedia].
	menu localize; popUpInWorld.

]

{ #category : #accessing }
MediaItemMorph >> scratchObj [

	^ scratchObj 

]

{ #category : #accessing }
MediaItemMorph >> scratchObj: anObject media: aScratchMedia [

	media := aScratchMedia.
	scratchObj := anObject.
	self buildSubmorphs.

]

{ #category : #accessing }
MediaItemMorph >> setNumber: anInteger [

	numberMorph contents: anInteger printString.

]

{ #category : #'event handling' }
MediaItemMorph >> startDrag: evt [

	(self ownerOrYourselfThatIsA: ScratchScriptEditorMorph)
		ifNil: [evt hand grabMorph: self]
		ifNotNil: [evt hand attachMorph: self fullCopy configureForDragging].

]

{ #category : #'event handling' }
MediaItemMorph >> startPreviewSound [

	media sound isPlaying
		ifFalse: [media sound play].
]

{ #category : #'event handling' }
MediaItemMorph >> step [
	
	Sensor anyButtonPressed ifTrue: [^ self].

	media isSound ifTrue: [
		(media sound notNil and: [media sound isPlaying])
			ifTrue: [
				thumbnailMorph form: SoundIconOn.
				infoMorph contents: media sound currentPosition hhmmss.
				infoMorph color: Color white.
				playButton on. 
				stopButton off]
			ifFalse: [
				thumbnailMorph form: SoundIcon.
				infoMorph contents: media infoString.
				infoMorph color: Color black.
				playButton off. 
				stopButton off]].

]

{ #category : #'event handling' }
MediaItemMorph >> stepTime [

	^ 50
]

{ #category : #'event handling' }
MediaItemMorph >> stopPreviewSound [

	media sound isPlaying
		ifTrue: [media sound pause].
]

{ #category : #'menu/button ops' }
MediaItemMorph >> turnIntoNewSprite [
	"Create a new sprite from this costume and delete the costume from previos sprite."

	| m frame |
	frame := self ownerOrYourselfThatIsA: ScratchFrameMorph.
	frame ifNil: [^ self].
	m := ScratchSpriteMorph new soleCostume: self media deepCopy.
	frame addAndView: m.
	self deleteMedia.

]
