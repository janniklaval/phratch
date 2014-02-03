"
I am the top level user interface for Scratch. I tile the screen with a toolbar, a work pane (for content), a viewer pane, and a script editor pane. I can resize myself to fill the entire Squeak window.

I keep a list of Scratch processes (threads) and run each one to the its next stopping point when I am stepped each screen update cycle.

"
Class {
	#name : #PhratchFrameMorph,
	#superclass : #Morph,
	#instVars : [
		'pauseButton',
		'blockEditors',
		'topPane',
		'viewerPane',
		'scriptsPane',
		'stageFrame',
		'workPane',
		'titlePane',
		'libraryPane',
		'menuPanel',
		'stageButtonsPanel',
		'readoutPane',
		'logoMorph',
		'projectTitleMorph',
		'flagButton',
		'fillScreenFlag',
		'paintingInProgress',
		'projectDirectory',
		'projectName',
		'projectInfo',
		'author',
		'loginName',
		'watcherPositions',
		'shuffledCostumeNames',
		'justSaved',
		'viewModeButtons',
		'viewMode',
		'lastViewMode',
		'viewModeButtonsPanel',
		'toolbarPanel',
		'quitFlag'
	],
	#classVars : [
		'AllowSharing',
		'Clipboard',
		'DefaultNotes',
		'DefaultSprite',
		'Fonts',
		'FontsXO',
		'PhratchSkin',
		'PhratchSkinXO',
		'StandardButtonFont',
		'StandardMenuFont',
		'TakeOverScreen',
		'UseErrorCatcher',
		'Version',
		'VersionDate',
		'VisibleDrives',
		'WorkpaneExtent'
	],
	#category : #'Phratch-UI-Panes'
}

{ #category : #'falta adaptar' }
PhratchFrameMorph class >> buttonLabel: aString selector: aSymbolOrNil [
	"Answer a big button with the given label."

	| button |
	button := ResizableToggleButton new
		offForm: (PhratchFrameMorph skinAt: #btn)
			onForm: (PhratchFrameMorph skinAt: #btnPressed);
		label: aString font: (PhratchFrameMorph getFont: #Button);
		actionSelector: aSymbolOrNil;
		yourself.

	^ button

]

{ #category : #utilities }
PhratchFrameMorph class >> cameraMode [

	^ #normal

]

{ #category : #'initialize-release' }
PhratchFrameMorph class >> close [
	"Close Phratch window but don't quit Pharo"

	PhratchFrameMorph allInstancesDo: [ :i | i delete ]
]

{ #category : #'initialize-release' }
PhratchFrameMorph class >> closeAndOpen [
	"Close Phratch window but don't quit Pharo"
	(DialogBoxMorph ask: 'Pay attention, you will loose your current project if not saved.')
		ifFalse: [ ^ self ].
	PhratchFrameMorph allInstancesDo: [ :i | i delete ].
	PhratchFrameMorph open
]

{ #category : #utilities }
PhratchFrameMorph class >> defaultSprite [
"Return the default sprite if one was set, or the cat otherwise"

	DefaultSprite
		ifNotNil: [^ DefaultSprite]
		ifNil: [^ PhratchSpriteMorph new
			addMediaItem: (ImageMedia new
				mediaName: ('costume' localized, '1');
				form: (PhratchFrameMorph skinAt: #defaultSpriteCostume);
		yourself);
			lookLike: ('costume' localized, '1');
		yourself].

]

{ #category : #byob }
PhratchFrameMorph class >> disableSharing [
	AllowSharing := false
]

{ #category : #'scratch skin' }
PhratchFrameMorph class >> getFont: aSymbol [
	"Get a font for a given purpose (specified by aSymbol) based on the current font setting."

	^ self isXO
		ifTrue: [FontsXO at: aSymbol]
		ifFalse: [Fonts at: aSymbol].

]

{ #category : #'scratch skin' }
PhratchFrameMorph class >> initFonts [
	"self initFonts"

	| fontSpecs fonts fontsXO |
	fontSpecs := #(
		(Arg						Verdana		10	HelveticaMedium 14)
		(Label			VerdanaBoldNarrowSpace	10	Helvetica		18)
		(MenuTitle					VerdanaBold		14	ArialBold		16)
		(Button						VerdanaBold		10	ArialBold		16)
		(Category					VerdanaBold		10	ArialBold		16)
		(Tab						VerdanaBold		11	ArialBold		16)
		(CommentBlock				Verdana		10	Verdana		14)
		(TalkBubble					VerdanaBold		12	VerdanaBold		18)
		(ToolTip						Verdana		13	ArialBold		16)
		(ReporterToolTip				Verdana		14	ArialBold		16)
		(XYReadout					Verdana		10	Arial			14)
		(XYReadoutBold				VerdanaBold		10	ArialBold		14)
		(CostumesPage				VerdanaBold		11	ArialBold		14)
		(SoundsPage					VerdanaBold		11	ArialBold		14)
		(ViewerPage				VerdanaBold		11	ArialBold		14)
		(UpdatingStringField			VerdanaBold		11	VerdanaBold		14)
		(Watcher					VerdanaBold		10	ArialBold		14)
		(WatcherLarge				VerdanaBold		14	VerdanaBold		14)

		(PaintUtilityButton			VerdanaBold		10	ArialBold		16)
		(PaintSetRotationCenter		VerdanaBold		11	ArialBold		14)

		"Library"
		(LibraryItemName			VerdanaBold		9	ArialBold		14)
		(LibraryItemInfo			Verdana		6	Verdana		10)
		(MediaItemInfo				Verdana		9	Arial			14)

		"Dialog Boxes"
		(DialogBoxTitle				VerdanaBold		14	VerdanaBold		16)
		(DialogBoxMessage			VerdanaBold		13	VerdanaBold		16)
		(DialogBoxButton			VerdanaBold		11	VerdanaBold		16)
		(ProjectNotes				Verdana		10	Verdana		12)
		(LinkMorphDefault			VerdanaBold		10	VerdanaBold		12)
		(ShareLink					VerdanaBold		13	VerdanaBold		12)
		(SoundRecorderButton		VerdanaBold		13	VerdanaBold		12)
		(SoundRecorderTimer		NewYorkBold	10	NewYorkBold	12)
		(StringDialogTypeIn			Verdana		12	Verdana		16)
		(NewVariableDialogBox		Verdana		11	Verdana		14)
		(AboutPhratch				VerdanaBold		11	VerdanaBold		14)
		(UploadTagLabel				VerdanaBold		10	VerdanaBold		12)
		(UploadTag					Verdana		10	Verdana		12)
		(UploadDialogLabel			VerdanaBold		10	VerdanaBold		12)
		(UploadDialogContents		Verdana		10	Verdana		12)
		(UploadDialogComment		Verdana		10	Verdana		12)

		"File Choosers"
		"This is the for the folder shortcuts in the file dialog"
		(FolderShortcut				Verdana		11	Verdana		14)
		(FileChooserNewFileTitle		VerdanaBold		10	VerdanaBold		14)
		(FileChooserNewFilename		Verdana		10	Verdana		12)
		(FileChooserLabel			VerdanaBold		10	VerdanaBold		14)
		(FileChooserContents			Verdana		12	Verdana		12)
		(FileChooserComment			Verdana		10	Verdana		12)
		(FilePickerDirectoryName	VerdanaBold		9	VerdanaBold		12)
		(FilePickerEntry				Verdana		11	Verdana		13)
		(FilePickerEntryHighlighted	VerdanaBold		11	VerdanaBold		13)

		(FrameMorphProjectTitle		VerdanaBold		13	ArialBold		16)
	).

	fonts := Dictionary new.
	fontsXO := Dictionary new.
	fontSpecs do: [:r |
		fonts at: (r at: 1) put: (StrikeFont fontName: (r at: 2) size: (r at: 3)).
		fontsXO at: (r at: 1) put: (StrikeFont fontName: (r at: 4) size: (r at: 5))].
	Fonts := fonts.
	FontsXO := fontsXO.

]

{ #category : #'class initialization' }
PhratchFrameMorph class >> initialize [
	"self initialize"

	Clipboard := nil.
	WorkpaneExtent := 480@360.
	UseErrorCatcher := true.
	AllowSharing := true.
	DefaultNotes := ''.
	Version := '0.1'.

	self initFonts.


]

{ #category : #'scratch skin' }
PhratchFrameMorph class >> isXO [
	"Return true if the current skin is XO."

	^ "IsXO" false

]

{ #category : #'scratch skin' }
PhratchFrameMorph class >> menuCommandOn: aBuilder [

	<worldMenu>  
	(aBuilder item: #Phratch)
		order: 0.1;
		icon: ((ImageMorph fromStream: (FileStream fileNamed: (FileSystem workingDirectory /  'ScratchSkin' / 'phratchicon.png'))) form magnifyBy: 0.35);
		action:[self openOneInstance].
]

{ #category : #utilities }
PhratchFrameMorph class >> open [
"	InputEventSensor startUp."
	"SoundPlayer initialize; shutDown; startUp. "
		
	^ self new startup openInWorld
]

{ #category : #'as yet unclassified' }
PhratchFrameMorph class >> openOneInstance [

	PhratchFrameMorph allInstances size > 1 ifFalse: [ ^ self new startup openInWorld].
]

{ #category : #utilities }
PhratchFrameMorph class >> palettePaneColor [

	| c |
	c := Color r: 124 g: 128 b: 131 range: 255.
	self isXO ifTrue: [c := c mixed: 0.75 with: Color white].
	^ c

]

{ #category : #utilities }
PhratchFrameMorph class >> putInClipboard: anObject [
	
	Clipboard := anObject.
]

{ #category : #'scratch skin' }
PhratchFrameMorph class >> readSkin [
	
	^ PhratchSkin := 
		PhratchFrameMorph readSkinFrom: 
			(FileSystem workingDirectory / 'ScratchSkin')
]

{ #category : #'scratch skin' }
PhratchFrameMorph class >> readSkinFrom: aDirectory [
	"Read the Forms for my skin from the given directory and store them in myskin dictionary."
	"When in XO mode, entries in ScratchSkinXO override the corresponding entries in ScratchSkin."
	"self readSkinFrom: (FileDirectory default directoryNamed: 'ScratchSkin')"
"Corregido error sintaxsis"
	| dict img i xoDict fn1|
	dict := Dictionary new.
	xoDict := Dictionary new.
	aDirectory fileNames do:  [:fn |
		fn1 := fn.
		Cursor read showWhile: [
			img := [Form fromFileNamed: ((aDirectory /  fn) fullName )] ifError: [nil]].
		
		img ifNotNil: [
			i := fn findLast: [:c | c = $.].
			i = 0 ifFalse: [fn1 := fn copyFrom: 1 to: i - 1].
			(fn1 asLowercase endsWith: '_xo')
				ifTrue: [xoDict at: (fn1 copyFrom: 1 to: fn1 size - 3) asSymbol put: img]
				ifFalse: [dict at: fn1 asSymbol put: img]].
			].
	PhratchSkin := dict.
	PhratchSkinXO := xoDict.

	img := PhratchSkin at: #scriptsPaneTexture ifAbsent: [nil].
	(img notNil and: [img depth ~= 32]) ifTrue: [
		PhratchSkin at: #scriptsPaneTexture put: (img asFormOfDepth: 32)].

	^ PhratchSkin
]

{ #category : #utilities }
PhratchFrameMorph class >> scaledFormForPaintEditor: aForm [
	"Answer either the given form or a copy of it scaled down to fit into the paint editor."
	"This method supports a quick fix to the following problem: When a big image is loaded onto a sprite and then edited in the image editor, (a) you cannot edit offscreen pixels and (b) if you click 'OK' to accept the edits, the image will be cropped. This fix resizes the loaded image to fit into paint editor canvas to avoid these problems. In the longer term, we should fix the paint editor to allow editing images larger than the canvas size."

	| maxExtent scale |
	maxExtent := WorkpaneExtent.
	((aForm width <= maxExtent x) and:
	 [aForm height <= maxExtent y])
		ifTrue: [^ aForm].

	scale := (maxExtent x / aForm width) min: (maxExtent y / aForm height).
	^ PhratchPlugin scale: aForm by: scale

]

{ #category : #utilities }
PhratchFrameMorph class >> scriptsPaneColor [

	| c |
	c := Color r: 124 g: 128 b: 131 range: 255.
	self isXO ifTrue: [c := c mixed: 0.8 with: Color white].
	^ c

]

{ #category : #utilities }
PhratchFrameMorph class >> setVisibleDrives: driveListString [
	"Set my set of visible drives. If the argument is nil, then all drives are made visible."

	| in drive |
	VisibleDrives := nil.
	driveListString ifNil: [ ^ self ].

	VisibleDrives := OrderedCollection new.
	in := ReadStream on: driveListString.
	[ in atEnd ]
		whileFalse: [ 
			in skipSeparators.
			drive := (in upTo: $,) trimBoth.
			drive size > 0
				ifTrue: [ VisibleDrives addLast: drive asUppercase ] ].
	VisibleDrives := VisibleDrives size > 0
		ifTrue: [ VisibleDrives asArray ]
		ifFalse: [ nil ]

]

{ #category : #'scratch skin' }
PhratchFrameMorph class >> skin [
	^PhratchSkin ifNil: [self readSkin]
]

{ #category : #'scratch skin' }
PhratchFrameMorph class >> skinAt: aSymbolOrString [

	^ self skinAt: aSymbolOrString ifAbsent: [
		(aSymbolOrString endsWith: 'Over') ifTrue: [ ^self skinAt: 'controlOver' ifAbsent:[] ].
		(aSymbolOrString endsWith: 'Pressed') ifTrue: [ ^self skinAt: 'controlPressed' ifAbsent:[] ].
		^self skinAt: 'control' ifAbsent:[]]

]

{ #category : #'scratch skin' }
PhratchFrameMorph class >> skinAt: aSymbolOrString ifAbsent: aBlock [
	"Answer the skin image with the given name. In XO mode, first check to see if an entry appears in ScratchSkinXO. If so, use it. Otherwise, use the image from the normal skin dictionary."

	| k |
	k := aSymbolOrString asSymbol.
	self isXO ifTrue: [
		k = #scriptsPaneTexture ifTrue: [^ aBlock value].
		(PhratchSkinXO includesKey: k) ifTrue: [^ PhratchSkinXO at: k]].

	^ self skin at: k ifAbsent: aBlock

]

{ #category : #font }
PhratchFrameMorph class >> standardButtonFont [
	^ StandardButtonFont   ifNil: [ StandardButtonFont := StandardFonts defaultFont ] 
]

{ #category : #accessing }
PhratchFrameMorph class >> standardMenuFont [
	^ StandardMenuFont ifNil: [ StandardMenuFont := StandardFonts defaultFont ]
]

{ #category : #accessing }
PhratchFrameMorph class >> takeOverScreen [
	^ TakeOverScreen ifNil: [ TakeOverScreen := false ] 
]

{ #category : #accessing }
PhratchFrameMorph class >> takeOverScreen: anObject [
	TakeOverScreen := anObject
]

{ #category : #utilities }
PhratchFrameMorph class >> useErrorCatcher [

	^ UseErrorCatcher

]

{ #category : #utilities }
PhratchFrameMorph class >> version [

	^ Version

]

{ #category : #utilities }
PhratchFrameMorph class >> version: aString [
	"self version: '3.1.1 (', (Date today printFormat: #(1 2 3 $- 2 2)), ')'"
	"self version: '1.0'"

	Version := aString.
	VersionDate := Date today printFormat: #(3 2 1 $- 1 1).

]

{ #category : #utilities }
PhratchFrameMorph class >> visibleDrives [
	"For Win32. Answer a list of visible drive names or nil. If nil, then all drives are visble."

	^ VisibleDrives

]

{ #category : #utilities }
PhratchFrameMorph class >> workpaneExtent [
	"Answer the extent of the work pane."

	^ WorkpaneExtent

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> aboutPhratch [
	| dialogBox |
	dialogBox := DialogBoxMorph new
		title: 'About Phratch' translated;
		withButtonsForYes: false
			no: false
			okay: true
			cancel: false;
		yourself.
	dialogBox
		message:
			'Phratch 1.0
Copyright (c) 2013 Jannik Laval.
All rights reserved.

Phratch Logo and Phratch Robot images
Copyright (c) 2013 Natacha Perrin.
All rights reserved.

Phratch is based on Scratch
Copyright (C)  2009 Massachusetts Institute of Technology.
All rights reserved.

Scratch is developed by the Lifelong Kindergarten Group at the MIT Media Lab,
with support from the National Science Foundation, Microsoft, Intel,
Nokia, and MIT Media Lab research consortia.

For more information, see https://code.google.com/p/phratch/
http://byob.berkeley.edu
http://scratch.mit.edu and http://chirp.scratchr.org.
for license, see license.txt in folder.

Please report bugs to https://code.google.com/p/phratch/issues/list.
'
		font: (PhratchFrameMorph getFont: #AboutPhratch).
	dialogBox
		setBalloonText:
			(CommandBlockMorph new
				color: (ScriptablePhratchMorph blockColorFor: 'control');
				commandSpec: 'B Y $OSReporter$ B';
		yourself) asLambda displayForm.
	dialogBox getUserResponse
]

{ #category : #other }
PhratchFrameMorph >> addAndView: aSpriteMorph [
	"Add given morph to the work pane and view it."

	| pos i p |
	aSpriteMorph center: workPane center.
	pos := self phratchObjects collect: [:o | o referencePosition].
	i := 0.
	[pos includes: (p := (10 * i) asPoint)] whileTrue: [i := i + 1].
	workPane addMorphFront: aSpriteMorph.
	aSpriteMorph objName: aSpriteMorph nextInstanceName.
	aSpriteMorph referencePosition: p.

	aSpriteMorph installGlobalBlocks.

	workPane customBlocks ifNotNil: [
		workPane customBlocks do: [:eachDef |
			eachDef isGlobal ifTrue: [
				aSpriteMorph ensureCustomBlockExists: eachDef ]]].

	aSpriteMorph startStepping.
	workPane sprites addLast: aSpriteMorph.
	self view: aSpriteMorph tab: 'Scripts' category: 'motion'.

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> addShortcutButtonsTo: rowMorph [

	| buttonSpecs b |

	self class disableSharing.

	buttonSpecs := #(
		"name		tool tip				selector"
		(language	'Set language'		languageMenu:)
		(save		'Save this project'	#savePhratchProjectNoDialog)
"		(share		'Share this project'	share)"
	).
	AllowSharing ifFalse: [
		buttonSpecs := buttonSpecs select: [:spec | spec first ~= #share]].

	buttonSpecs do: [:spec |
		b := ToggleButton
			onForm: (PhratchFrameMorph skinAt: (spec at: 1), 'ButtonOver')
			offForm: (PhratchFrameMorph skinAt: (spec at: 1), 'Button')
			overForm: (PhratchFrameMorph skinAt: (spec at: 1), 'ButtonOver').
		b
			target: self;
			actionSelector: (spec at: 3);
			setBalloonText: (spec at: 2) localized;
			actWhen: #buttonUp;
			isMomentary: true.
		
		('language' = (spec at: 1)) ifTrue: [  "language special case"
			b arguments: (Array with: b)].

		('save' = (spec at: 1)) ifTrue: [  "bigger spacer"
			rowMorph addMorphBack: (Morph new extent: (10@5); color: Color transparent;
		yourself)].

		('share' = (spec at: 1)) ifTrue: [  "add spacer between buttons"
			rowMorph addMorphBack: (Morph new extent: (8@5); color: Color transparent;
		yourself)].
		rowMorph addMorphBack: b].

	rowMorph addMorphBack: (Morph new extent: (15@5); color: Color transparent;
		yourself).

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> addSpecialSprite [

	|menu m newSprite frame |
	menu := MenuMorphNG new defaultTarget: self.
	
	PhratchSpriteMorph withAllSubclasses size = 1 ifTrue:[^ self paintSpriteMorph].
	
	PhratchSpriteMorph withAllSubclassesDo: [ :e |
		menu add: ('create ',e name) translated value: e.
	].
	
	m := (menu
		localize;
		invokeModal; yourself) selectedValue.
	
	m ifNotNil:[
		newSprite := m new.
	
		frame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
		frame ifNotNil: [
			frame workPane addMorphFront: newSprite.
			frame workPane sprites addLast: newSprite].
		^ newSprite
	]
]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> addSpriteMorph [

	| result f m el |
	self world activeHand toolType: nil.
	self paintingInProgress ifTrue: [^ Beeper beep].

	result := PhratchFileChooserDialog chooseSpriteCostumeFor: self.
	result = #cancelled ifTrue: [^ self].
	((result basename asLowercase endsWith: '.sprite') | (result basename asLowercase endsWith: '.ysp')  | (result basename asLowercase endsWith: '.phsp'))
		ifTrue: [^ self importSpriteOrProject: result].

	[f := Form fromFileNamed: result] ifError: [ PhratchError error. ^ self].
	el := ImageMedia new form: (PhratchFrameMorph scaledFormForPaintEditor: f).
	m := PhratchSpriteMorph new soleCostume: el.
	el mediaName: (m unusedMediaNameFromBaseName: (result basename)).
	self addAndView: m.

]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> allProjectMedia [
	"Answer a collection of all media items in the current project."

	| result |
	result := OrderedCollection new.
	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [
			result addAll: m media]].
	^ result

]

{ #category : #drawing }
PhratchFrameMorph >> areasRemainingToFill: aRectangle [
	"Drawing optimization. Since I completely fill my bounds with opaque pixels, this method tells Morphic that it isn't necessary to draw any morphs covered by me."
	
	^ aRectangle areasOutside: self bounds

]

{ #category : #accessing }
PhratchFrameMorph >> author [

	^ author

]

{ #category : #accessing }
PhratchFrameMorph >> author: aString [
	"This is the author used in notes and save as, which is different from the user name used when uploading to the website."

	author := aString.


]

{ #category : #byob }
PhratchFrameMorph >> blockContrastStrong [

	BlockMorph contrastStrong.
	self refreshBlocks.
]

{ #category : #byob }
PhratchFrameMorph >> blockEditors [
	^blockEditors
]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> canonicalizeImagesQuality: qualityOrNil saveOriginal: saveFlag [

	| count unique match |
	count := 0.
	unique := OrderedCollection new: 1000.
	self allProjectMedia do: [:m |
		m isImage ifTrue: [
			match := unique detect: [:u | u form equals: m form] ifNone: [nil].
			match
				ifNil: [
					qualityOrNil ifNotNil: [
						(m jpegCompressIfPossibleQuality: qualityOrNil saveOriginal: saveFlag)
							ifTrue: [count := count + 1]].
					unique add: m]
				ifNotNil: [
					m shareFormWith: match]]].
	^ count

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> canonicalizeSoundsBits: bitsPerSample saveOriginal: saveFlag [

	| count unique match |
	count := 0.
	unique := OrderedCollection new: 1000.
	self allProjectMedia do: [:m |
		m isSound ifTrue: [
			match := unique detect: [:u | u sound equals: m sound] ifNone: [nil].
			match
				ifNil: [
					bitsPerSample ifNotNil: [
						(m compressBitsPerSample: bitsPerSample saveOriginal: saveFlag)
							ifTrue: [count := count + 1]].
					unique add: m]
				ifNotNil: [
					m shareSoundWith: match]]].

	bitsPerSample notNil & saveFlag not ifTrue: [
		"uncompress compressed sounds so the result can be heard"
		self allProjectMedia do: [:m | m isSound ifTrue: [ m decompress]]].

	^ count

]

{ #category : #byob }
PhratchFrameMorph >> checkBoxLabelled: aString marked: aBool width: anInt [
	"answer a form consisting of a checkbox and a label - used for the EDIT menu in BYOB"

	| box label pic line cnts |
	pic := aBool
		ifTrue: [ PhratchFrameMorph skinAt: #watcherButtonPressed ]
		ifFalse: [ PhratchFrameMorph skinAt: #watcherButton ].
	box := ImageMorph new form: pic.
	cnts := ' ' , aString localized.
	label := StringMorph contents: cnts font: PhratchFrameMorph standardMenuFont.
	line := Morph new color: Color transparent.
	line height: (box height max: label height).
	line width: (box width + label width max: anInt).
	box left: line left.
	box top: line top + ((line height - box height) // 2).
	label left: box right.
	label top: line top + ((line height - label height) // 2).
	line addMorph: box.
	line addMorph: label.
	^ line imageForm
]

{ #category : #byob }
PhratchFrameMorph >> clearAllVariables [

	workPane clearAllVariables
]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> clearStage [

	self stopAll.
	projectDirectory := PhratchFileChooserDialog getDefaultFolderForType: #project.
	projectName := ''.
	projectInfo := Dictionary new.

	self installNewProject: PhratchStageMorph new.
	self initializeWatcherPositions.
	justSaved := true.

]

{ #category : #'as yet unclassified' }
PhratchFrameMorph >> close [

	| response |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.

	(justSaved or: [self projectIsEmpty]) ifFalse: [
		response := PhratchCloseDialog new getUserResponse.
		response = #cancelled ifTrue: [^ self].
		response ifTrue: [
			self savePhratchProjectNoDialog.
			justSaved ifFalse: [^ self]]].
	self class close
]

{ #category : #byob }
PhratchFrameMorph >> closeBlockEditor [
	blockEditors do:[:each | each yes "no"].
	blockEditors := Set new.

]

{ #category : #'presentation mode' }
PhratchFrameMorph >> closeDialogBoxes [
	"Close all dialog boxes, including PaintEditors and SoundRecorders."

	World submorphs do: [:m |
		(m isKindOf: DialogBoxMorph) ifTrue: [m cancelled; delete]].

	blockEditors := Set new

]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> closeMediaEditorsAndDialogs [
	"Close any open paint or sound editors, asking the user first to avoid losing edits. Answer true if all are closed."

	| mList mHasCancel |
	mList := PaintFrame allInstances select: [:m | m isInWorld].
	mList size > 0 ifTrue: [
		(DialogBoxMorph ask: 'Close paint editor?') ifFalse: [^ false].
		mList do: [:m | m cancelled; delete].
		paintingInProgress := false].

	mList := PhratchSoundRecorderDialogMorph allInstances select: [:m | m isInWorld].
	mList size > 0 ifTrue: [
		(DialogBoxMorph ask: 'Close sound recorder?') ifFalse: [^ false].
		mList do: [:m | m cancelled; delete]].

	mList := DialogBoxMorph allInstances select: [:m | m isInWorld].
	mList size > 0 ifTrue: [
		(DialogBoxMorph ask: 'Close dialog?') ifFalse: [^ false].
		mList do: [:m |
			mHasCancel := false.
			m buttons do: [:b |
				b action = #cancelled ifTrue: [mHasCancel := true]].
			mHasCancel
				ifTrue: [m cancelled; delete]
				ifFalse: [m no; delete]]].

	DialogBoxMorph subclassesDo: [:c |
		mList := c allInstances select: [:m | m isInWorld].
		mList size > 0 ifTrue: [
			(DialogBoxMorph ask: 'Close dialog?') ifFalse: [^ false].
			mList do: [:m |
				mHasCancel := false.
				m buttons do: [:b |
					b action = #cancelled ifTrue: [mHasCancel := true]].
				mHasCancel
					ifTrue: [m cancelled; delete]
					ifFalse: [m no; delete]]]].

	"subclass of a subclass of DialogBoxMorph"
	mList := NewVariableDialog allInstances select: [:m | m isInWorld].
	mList size > 0 ifTrue: [
		(DialogBoxMorph ask: 'Close dialog?') ifFalse: [^ false].
		mList do: [:m | m cancelled; delete]].

	^ true

]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> compressImages [

	| s q count |
	s := StringDialog askWithCancel: 'JPEG Quality (10-100)?' initialAnswer: '70'.
	s size = 0 ifTrue: [^ self].
	q := [s asNumber] ifError: [nil].
	q ifNil: [^ self].
	q := (q within: 10 and: 101) truncated.

	q > 100 ifTrue: [q := nil].  "just canonicalize, don't compress"
	count := self canonicalizeImagesQuality: q saveOriginal: false.

	scriptsPane categoryChanged: 'Costumes'.
	DialogBoxMorph inform: 'Images compressed' withDetails: count printString.

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> compressSounds [
	| menu bitsPerSample count |
	menu := MenuMorph new
		title: 'Sound quality:' translated;
		defaultTarget: self;
		yourself.	"menu add: 'High (biggest)'
		target: self 
		selector: #canonicalizeSoundsBits:saveOriginal:
		argumentList: (Array with: 5 with: false).
	menu add: 'Normal'
		target: self 
		selector: #canonicalizeSoundsBits:saveOriginal:
		argumentList: (Array with: 4 with: false).
	menu add: 'Low'
		target: self 
		selector: #canonicalizeSoundsBits:saveOriginal:
		argumentList: (Array with: 3 with: false).
	menu add: 'Lowest (smallest)'
		target: self 
		selector: #canonicalizeSoundsBits:saveOriginal:
		argumentList: (Array with: 2 with: false).
	menu addLine.
	menu add: 'cancel' action: nil.
	count := menu localize; invokeModal."
	menu := MenuMorphNG new
		title: 'Sound quality:' translated;
		defaultTarget: self;
		yourself.
	menu add: 'High (biggest)' value: 5.
	menu add: 'Normal' value: 4.
	menu add: 'Low' value: 3.
	menu add: 'Lowest (smallest)' value: 2.
	menu addLine.
	menu add: 'cancel' value: nil.
	menu localize.
	(bitsPerSample := menu
		invokeModal;
		selectedValue;
		yourself) ifNil: [ ^ self ].
	count := self canonicalizeSoundsBits: bitsPerSample saveOriginal: false.
	scriptsPane categoryChanged: 'Sounds'.
	DialogBoxMorph inform: 'Sounds compressed' withDetails: count printString
]

{ #category : #'tools (no longer used)' }
PhratchFrameMorph >> copyTool [

	| hand cursorForm offset |
	self paintingInProgress ifTrue: [^ Beeper beep].
	hand := self world activeHand.
	hand toolType: 'CopyTool'.

	cursorForm := PhratchFrameMorph skinAt: #copyCursor.
	offset := 8@13.

	PhratchFrameMorph isXO ifTrue: [
		cursorForm := cursorForm magnifyBy: 1.5.
		offset := (offset * 1.5) rounded].

	hand showTemporaryCursor: cursorForm hotSpotOffset: offset.

]

{ #category : #intialization }
PhratchFrameMorph >> createBasicPanes [
	"Create and add my palette (viewer), script editor, stage, and library panes."

	topPane := ImageFrameMorph new initFromForm: (PhratchFrameMorph skinAt: 'topPane').
	viewerPane := PhratchViewerMorph new rebuildCategorySelectors.	
	scriptsPane := PhratchScriptEditorMorph new.
	stageFrame := ImageFrameMorph new initFromForm: (PhratchFrameMorph skinAt: 'stagePane').
	titlePane := ImageFrameMorph new initFromForm: (PhratchFrameMorph skinAt: 'titlePane').
	workPane := PhratchStageMorph new extent: WorkpaneExtent.
	libraryPane := PhratchLibraryMorph new.

	"make panes sticky so clicking on them doesn't pick up entire frame"
	self
		addMorph: (topPane isSticky: true);
		addMorph: (viewerPane isSticky: true);
		addMorph: (scriptsPane isSticky: true);
		addMorph: (stageFrame isSticky: true);
		addMorph: (workPane isSticky: true);
		addMorph: (titlePane isSticky: true);
		addMorph: (libraryPane isSticky: true).

	libraryPane removeAllMorphs; buildPanes.

	self createReadoutPane.
	workPane comeToFront.

]

{ #category : #intialization }
PhratchFrameMorph >> createLogo [
	"Create and the Phratch logo."

	logoMorph := SketchMorph withForm: (PhratchFrameMorph skinAt: #scratchLogo).
	logoMorph position: topPane position + (12@8).
	topPane addMorph: logoMorph.

]

{ #category : #intialization }
PhratchFrameMorph >> createMenuPanel [
	"Create and add a panel containing the menus and close button."

	| menuSpecs m |
	"create panel"
	menuPanel := AlignmentMorph new
		cellPositioning: #leftCenter;
		color: Color transparent;
		centering: #center;
		inset: 0;
		height: 0;
		yourself.	"will grow as needed"

	self addShortcutButtonsTo: menuPanel.

	"menuSpecs defines the menus"
	menuSpecs := #(
		"name			selector"
		(File			fileMenu:)
		(Edit			editMenu:)
		"(Share			shareMenu:)"
		(Help			helpMenu:)
	).

	menuSpecs do: [:spec |
		m := PhratchMenuTitleMorph new
			contents: (spec at: 1) localized;
			target: self selector: (spec at: 2);
		yourself.
		menuPanel addMorphBack: m.
		#helpMenu: = (spec at: 2) ifFalse: [
			menuPanel addMorphBack: (Morph new color: Color transparent; extent: 12@5;
		yourself)]].

	topPane addMorph: menuPanel.

]

{ #category : #intialization }
PhratchFrameMorph >> createReadoutPane [
	"Create and add my presentation mode button, new sprite buttongs, and mouse readout pane."

	| xyReadout |

	readoutPane := ImageFrameMorph new initFromForm: (PhratchFrameMorph skinAt: #mouseReadoutPane).
	xyReadout := self makeXYReadout.
	readoutPane	 addMorph: xyReadout.

	"make pane sticky so clicking on it doesn't pick up entire frame"
	self addMorph: (readoutPane isSticky: true).

]

{ #category : #intialization }
PhratchFrameMorph >> createStageButtonsPanel [
	"Create and add a panel containing the project title, green flag, and stop buttons."

	| buttonSpecs bName button |
	"create panel"
	stageButtonsPanel := AlignmentMorph new
		cellPositioning: #leftCenter;
		color: Color transparent;
		centering: #center;
		height: 20;
		yourself.

	projectTitleMorph := StringMorph new
		forceUnicodeRendering: true;
		contents: '';
		font: (PhratchFrameMorph getFont: #FrameMorphProjectTitle);
		yourself.
	stageButtonsPanel
		addMorphBack: projectTitleMorph;
		addMorphBack: (AlignmentMorph newSpacer: Color transparent).

	"buttonSpecs defines the toolbar buttons; first is icon name, second is selector"
	buttonSpecs := #(
		"name	selector		tool tip"
		(go		shoutGo		'Start green flag scripts')
		(pause	togglePause	'Pause/resume everything')
		(stop	stopAll		'Stop everything')).

	buttonSpecs do: [:spec |
		bName := spec first.
		button := ToggleButton
			onForm: (PhratchFrameMorph skinAt: (bName, 'ButtonGrayPressed') asSymbol)
			offForm: (PhratchFrameMorph skinAt: (bName, 'ButtonGray') asSymbol)
			overForm: (PhratchFrameMorph skinAt: (bName, 'ButtonGrayPressed') asSymbol).
		button
			target: self;
			actionSelector: (spec at: 2);
			isMomentary: true;
			setProperty: #balloonText toValue: (spec at: 3) localized.

		stageButtonsPanel addMorphBack: button.
		bName = #pause ifTrue: [
			pauseButton := button].

		bName = #go ifTrue: [
			flagButton := button.
			"stageButtonsPanel addMorphBack: (Morph new color: Color transparent; extent: 2@5)" "commented out if there is a pause button -jens" ]].

	titlePane addMorph: stageButtonsPanel.
	
	self setProperty: #stopAllButton toValue: button

]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> createToolbar [
	"Create and add the toolbar."

	| buttonSpecs bName button |
	toolbarPanel := AlignmentMorph new
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		color: Color transparent;
		yourself.
		
	buttonSpecs := #(
		"name			selector"			"tooltip"
		(copy			copyTool		'Duplicate')
		(delete			cutTool			'Delete')
		(zoomIn 		zoomInTool		'Grow sprite')
		(zoomOut 		zoomOutTool		'Shrink sprite')
	).

	buttonSpecs do: [:spec |
		bName := spec at: 1.
		button := ToggleButton
			onForm: (PhratchFrameMorph skinAt: (bName, 'ButtonPressed') asSymbol)
			offForm: (PhratchFrameMorph skinAt: (bName, 'Button') asSymbol)
			overForm: (PhratchFrameMorph skinAt: (bName, 'ButtonOver') asSymbol).
		button
			target: self;
			actionSelector: (spec at: 2);
			isMomentary: true;
			setProperty: #balloonText toValue: (spec at: 3) localized.
		toolbarPanel addMorphBack: button].

	self addMorph: toolbarPanel.

]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> createViewModeButtonsPanel [

	| specs bName button |
	viewModeButtonsPanel := AlignmentMorph newRow
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		color: Color transparent;
		yourself.

	viewModeButtons := OrderedCollection new.
	specs := OrderedCollection new.
	specs add: #(quarter			enterQuarterMode		'Switch to small stage').
	specs add: #(normal			enterNormalMode		'Switch to full stage').
	specs add: #(presentation	enterPresentationMode	'Switch to presentation mode').

	specs do: [:spec |
		bName := spec first.
		button := ToggleButton new
			onForm: (PhratchFrameMorph skinAt: bName, 'ViewModeOn')
			offForm: (PhratchFrameMorph skinAt: bName, 'ViewMode')
			overForm: (PhratchFrameMorph skinAt: bName, 'ViewModeOver').
		button
			target: self;
			actionSelector: (spec at: 2);
			alphaOn: true;
			setProperty: #balloonText toValue: (spec at: 3) localized.
		viewModeButtonsPanel
			addMorphBack: button;
			addMorphBack: (Morph new extent: 1@5; color: Color transparent;
		yourself).
		viewModeButtons add: button].

	self addMorph: viewModeButtonsPanel.

]

{ #category : #'tools (no longer used)' }
PhratchFrameMorph >> cutTool [

	| hand cursorForm offset |
	self paintingInProgress ifTrue: [^ Beeper beep].
	hand := self world activeHand.
	hand toolType: 'CutTool'.

	cursorForm := PhratchFrameMorph skinAt: #cutCursor.
	offset := 8@8.

	PhratchFrameMorph isXO ifTrue: [
		cursorForm := cursorForm magnifyBy: 1.5.
		offset := (offset * 1.5) rounded].

	hand showTemporaryCursor: cursorForm hotSpotOffset: offset.

]

{ #category : #other }
PhratchFrameMorph >> delete [

	World activeHand toolType: nil.
	super delete.

]

{ #category : #watchers }
PhratchFrameMorph >> deleteWatchersForSprite: aSprite [
	"The given sprite is being deleted. Delete all watchers associated with it."

	aSprite lists do: [:m | m delete].

	workPane submorphsDo: [:m |
		(m isKindOf: WatcherMorph) ifTrue: [
			(m target = aSprite) ifTrue: [m delete]]].

	watcherPositions keys do: [:k | 
		(k at: 1) = aSprite ifTrue: [watcherPositions removeKey: k]].

]

{ #category : #watchers }
PhratchFrameMorph >> deleteWatchersForVar: varName ofSprite: aSprite [
	"The given variable is being deleted. Delete all watchers associated with it."

	workPane submorphsDo: [:m |
		(m isKindOf: WatcherMorph) ifTrue: [
			((m target = aSprite) and:
			 [(#(getVar: reportColor:) includes: m getSelector) and:
			 [m parameter = varName]])
				ifTrue: [m delete]]].
]

{ #category : #watchers }
PhratchFrameMorph >> deletingWatcher [
	"The given watcher is being removed from the stage; remember it's last position."

	| palette w |
	watcherPositions do: [:rec |
		rec first ifNotNil: [
			w := rec first.
			w owner ifNil: [
				rec at: 1 put: nil.
				rec at: 2 put: w position - workPane position. "record old position and layout style"
				rec at: 3 put: w layoutStyle.
				rec at: 4 put: w sliderRange]]].

	palette := viewerPane pageViewer contents.
	(palette respondsTo: #updateWatcherButtonsForFrame:) 
		ifTrue: [palette updateWatcherButtonsForFrame: self].

]

{ #category : #drawing }
PhratchFrameMorph >> drawOn: aCanvas [
	"Optimization: Don't draw myself at all since I am completely tiled."


]

{ #category : #byob }
PhratchFrameMorph >> editBlockDefinition: aCustomBlockDefinition for: aScriptablePhratchMorph [

	| editor def id |
	"for prototypal inheritance:"
	id := aCustomBlockDefinition id.
	aScriptablePhratchMorph ensureOwnBlockExists: aCustomBlockDefinition.
	def := aScriptablePhratchMorph customBlocks detect: [:eachDef | eachDef id = id]
		ifNone: [^ self ].
	(self notEditingBlockDefinition: def) ifFalse: [^self].
	def fixBlockVarReporters.
	editor 	:= BlockEditorFrameMorph new
		withButtonsForYes: false no: false okay: true cancel: true;
		receiver: aScriptablePhratchMorph;
		definition: def;
		yourself.
	blockEditors add: editor.
	editor getUserResponse.
	blockEditors remove: editor ifAbsent: []
]

{ #category : #accessing }
PhratchFrameMorph >> editMenu: aMenuTitleMorph [

	| menu |

	menu := MenuMorph new defaultTarget: self.
	menu add: 'Undelete' localized action: #undoTool.
	menu add: 'Undo last drop' localized action: #undoLastDrop.

	menu addLine.

	menu add: self isTurbo checkBoxString, 'Turbo' localized
			action: #toggleTurboMode.

	menu add: ScriptablePhratchMorph keepOnStage not checkBoxString, 'Allow Sprites offstage' localized
			action: #toggleKeepSpritesOnStage.

	menu add: EventHatMorph threadSafeMode checkBoxString, 'Thread safe scripts' localized
			action: #toggleThreadSafeMode.
	menu addLine.
	menu add: 'Compress Sounds' localized action: #compressSounds.
	menu add: 'Compress Images' localized action: #compressImages.
	menu add: 'Unload unused blocks' localized action: #unloadAllUnusedCustomBlocks.
	menu add: 'Clear all Variables' localized action: #clearAllVariables.

	menu add: 'Settings' localized action: #showSettingBrowser.
	
	Sensor shiftPressed ifTrue: [	self isDevelopmentMode ifTrue: [
			menu addLine.
		fillScreenFlag
			ifTrue: [menu add: 'turn fill screen off' localized action: #fillScreenOff]
			ifFalse: [menu add: 'turn fill screen on' localized action: #fillScreenOn].
		UseErrorCatcher
			ifTrue: [menu add: 'turn error catching off' localized action: #toggleErrorCatcher]
			ifFalse: [menu add: 'turn error catching on' localized action: #toggleErrorCatcher].
		
		]].
 
	menu localize.
"
	#(3 4 7 8) do: [:n |
		menu labels at: n put:
			((menu labels at: n) copyFrom: 1 to: (menu labels at: n) size - 1), PhratchTranslator ellipsesSuffix].
"
	menu invokeModalAt: aMenuTitleMorph bottomLeft + (0@10).
]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> editNotes [

	(PhratchNotesDialog editNotesFor: self) getUserResponse.

]

{ #category : #'view mode' }
PhratchFrameMorph >> enterNormalMode [
	"Go into normal (full-stage) mode."

	(viewMode = #normal) ifTrue: [
		self updateViewModeButtons.
		^ self].

	viewMode := #normal.

	workPane isQuarterSize: false.
	workPane isInWorld
		ifTrue: [self fixLayout]
		ifFalse: [self exitPresentationMode].

	self updatePanes.
	self updateViewModeButtons.

]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> enterPresentationMode [
	"Go into presentation mode."

	| presenter |
	"PhratchPlugin pluginAvailable ifFalse: [
		self updateViewModeButtons.
		^ Beeper beepPrimitive]."
	(viewMode = #presentation) ifTrue: [^ self].

	lastViewMode := viewMode.
	viewMode := #presentation.

	self closeDialogBoxes.
	workPane isQuarterSize: false.
	presenter := PhratchPresenterMorph new frame: self.

	self delete.

	Display fillBlack.
	Display fullScreenMode: true.
	TaskbarMorph allInstances do: [: e | e hide ].

	World restoreDisplay.
	Display fillBlack.
	World assuredCanvas.  "re-allocate canvas after entering full-screen mode"

	((Display width >= 965) & (Display height >= 750))
		ifTrue: [presenter beDoubleSize].
	presenter extent: Display extent.

	World addMorphFront: presenter.
	World startSteppingSubmorphsOf: presenter.
	World activeHand newKeyboardFocus: nil.
	self updatePenPositions.
	self updateViewModeButtons.

	World assuredCanvas.  "re-allocate canvas after entering full-screen mode"
	World fullRepaintNeeded.
	World displayWorldSafely.

]

{ #category : #'view mode' }
PhratchFrameMorph >> enterQuarterMode [
	"Go into quarter stage mode."

	(viewMode = #quarter) ifTrue: [
		self updateViewModeButtons.
		^ self].

	viewMode := #quarter.

	workPane isQuarterSize: true.
	workPane isInWorld
		ifTrue: [self fixLayout]
		ifFalse: [self exitPresentationMode].

	self updatePanes.
	self updateViewModeButtons.

]

{ #category : #'view mode' }
PhratchFrameMorph >> exitPresentationMode [
	"Exit presentation mode."

	TaskbarMorph allInstances do: [: e | e show ].
	
	quitFlag ifTrue: [^Smalltalk quitPrimitive].

	PhratchFrameMorph takeOverScreen ifFalse: [
		Display fullScreenMode: false.
		World restoreDisplay].


	ScriptablePhratchMorph doubleSize: false.
	self addMorphFront: workPane.
	self fixLayout.
	World addMorphFront: self.
	World startSteppingSubmorphsOf: self.
	World fullRepaintNeeded.
	self updatePenPositions.

	lastViewMode ifNil: [lastViewMode := #normal].
	lastViewMode = #normal ifTrue: [^ self enterNormalMode].
	lastViewMode = #quarter ifTrue: [^ self enterQuarterMode].


]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> exportSprite [

	scriptsPane target exportObject.

]

{ #category : #geometry }
PhratchFrameMorph >> extent: aPoint [
	"Position all my submorphs whenever I get resized."

	super extent: aPoint.
	self fixLayout.

]

{ #category : #'file read/write' }
PhratchFrameMorph >> extractInfoFrom: aByteArray [
	"Answer a Phratch info dictionary from the given ByteArray. Answer an empty dictionary if it is an old project."

	| s version |
	s := ReadStream on: aByteArray.
	version := FuelObjStream phratchFileVersionFrom: (s next: 10) asString.
	({1 . 2} includes: version)
		ifTrue: [
			s skip: 4.  "skip info header byte count"
			^ FuelObjStream new readObjFrom: s showProgress: false]
		ifFalse: [^ Dictionary new].


]

{ #category : #'file read/write' }
PhratchFrameMorph >> extractPhratchProjectFrom: aByteArray [
	"Answer a Phratch project (i.e. a PhratchStageMorph possibly containing sprites) from the given ByteArray. Answer nil if the project cannot be unpacked.

Note: this is a compatibility force method for BYOB - jens"

	| s version proj |

	FuelObjStream initialize. "just to make sure this works in filed-in changesets, -Jens"

	s := ReadStream on: aByteArray.
	version := FuelObjStream phratchFileVersionFrom: (s next: 10) asString.
	version = 0 ifTrue: [
		ScriptablePhratchMorph decodeAsScratch.	"this is the forcing part. -Jens"
		s position: 0.
		proj := FuelObjStream new readObjFrom: s showProgress: true].
	({1 . 2} includes: version) ifTrue: [
		s skip: s uint32.  "skip header"
		proj := FuelObjStream new readObjFrom: s showProgress: true].

	proj class = PhratchStageMorph ifFalse: [
		version > 2
			ifTrue: [self error: 'Project created by a later version of Scratch']
			ifFalse: [self error: 'Problem reading project.'].
		^ nil].

	ScriptablePhratchMorph buildBlockSpecDictionary.

	'initializing...' 
		displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((proj allMorphs) select: [:m| m isKindOf: ScriptablePhratchMorph]) size * 2
		during: [:bar | | i | i := 0.

	proj allMorphsDo: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [
			 i := i + 1. bar value: i.
			m convertTuplesToDefinitions]].

	proj allMorphsDo: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [  "convert to new blocks" 
			i := i + 1. bar value: i.
			m convertStacksToTuples.
			m convertTuplesToStacks]]].

	^ proj

]

{ #category : #'file read/write' }
PhratchFrameMorph >> extractProjectFrom: aByteArray [
	"Answer a Phratch project (i.e. a PhratchStageMorph possibly containing sprites) from the given ByteArray. Answer nil if the project cannot be unpacked."

	| s version proj |

	FuelObjStream initialize. "just to make sure this works in filed-in changesets, -Jens"
	s := ReadStream on: aByteArray.
	version := FuelObjStream phratchFileVersionFrom: (s next: 10) asString.
	version = 0 ifTrue: [
		ScriptablePhratchMorph decodeAsByob.	"make sure we initialize every field - this breaks compatibility with Phratch-sprites. -Jens"
		s position: 0.
		[proj := FuelObjStream new readObjFrom: s showProgress: true] ifError: [
		^ self extractPhratchProjectFrom: aByteArray]].
	({1 . 2} includes: version) ifTrue: [
		s skip: s uint32.  "skip header"
		proj := FuelObjStream new readObjFrom: s showProgress: true].

	proj class = PhratchStageMorph ifFalse: [
		version > 2
			ifTrue: [self error: 'Project created by a later version of Phratch']
			ifFalse: [self error: 'Problem reading project.'].
		^ nil].

	ScriptablePhratchMorph buildBlockSpecDictionary.

	'initializing...' 
		displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((proj allMorphs) select: [:m| m isKindOf: ScriptablePhratchMorph]) size * 2
		during: [:bar | | i | i := 0.

	proj allMorphsDo: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [
			 i := i + 1. bar value: i.
			m convertTuplesToDefinitions]].

	proj allMorphsDo: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [  "convert to new blocks" 
			i := i + 1. bar value: i.
			m convertStacksToTuples.
			m convertTuplesToStacks]]].

	^ proj

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> fileMenu: aMenuTitleMorph [
	| menu |
	menu := MenuMorph new defaultTarget: self.
	menu add: 'New' localized action: #newPhratchProject.
	menu add: 'Open' localized action: #openPhratchProject.
	menu add: 'Open Scratch' translated action: #openScratchProject.
	menu add: 'Save' localized action: #savePhratchProjectNoDialog.
	menu add: 'Save As' localized action: #savePhratchProject.
	menu addLine.
	menu add: 'Import Project' localized action: #importPhratchProject.
	menu add: 'Export Sprite' localized action: #exportSprite.
	menu addLine.
	menu add: 'Project Notes' localized action: #editNotes.
	Sensor shiftPressed
		ifTrue: [ 
			"developer menu"
			menu addLine.
			menu add: 'Write Project Summary' localized action: #writeSummaryFile.
			menu add: 'Write Multiple Project Summaries' localized action: #writeMultipleSummaries.
			menu addLine.
			fillScreenFlag
				ifTrue: [ menu add: 'Exit User Mode' localized action: #fillScreenOff ]
				ifFalse: [ 
					menu add: 'Enter User Mode' localized action: #fillScreenOn.
					menu add: 'Save Image in User Mode' localized action: #saveImageForEndUser ] ].
	menu addLine.
	menu add: 'Close' localized action: #close.
	menu add: 'Quit' localized action: #quitPhratch.
	menu localize.
	#(2 4 5 6 7)
		do: [ :n | 
			menu labels
				at: n
				put:
					((menu labels at: n) contents copyFrom: 1 to: (menu labels at: n) contents size - 1) , PhratchTranslator ellipsesSuffix ].
	menu popUpAt: aMenuTitleMorph bottomLeft + (0 @ 10) inWorld: World
]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> fillScreenOff [
	"Stop filling the entire screen. Useful during development."


	Display fullScreenMode: false.
	World restoreDisplay.

	fillScreenFlag := false.
	TaskbarMorph allInstances do: [: e | e show ].
	
	self isSticky: false.
	self extent: 1000@600"Display extent - 50".
	UseErrorCatcher := false.
	ScriptablePhratchMorph noviceMode: false.
	Paragraph insertionPointColor: (Color r: 0.4 g: 1.0 b: 0.0).

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> fillScreenOn [
	"Start filling the entire screen and being sticky. Also configure a few other things for the end user such as turning off halos and the control menu (noviceMode) and making sure that error catching is enabled."

	PhratchFrameMorph takeOverScreen ifTrue: [
		Display fullScreenMode: true.
		World restoreDisplay].

	fillScreenFlag := true.
	TaskbarMorph allInstances do: [: e | e hide ].
	
	self position: 0@0.
	self isSticky: true.
	self extent: Display extent.
	self comeToFront.
	UseErrorCatcher := true.
	ScriptablePhratchMorph noviceMode: true.
	Paragraph insertionPointColor: (Color r: 0.353 g: 0.607 b: 0.788).
	self updateProjectName.
	self step.

]

{ #category : #geometry }
PhratchFrameMorph >> fixLayout [

	| stageExtent xyReadout w |
	stageExtent :=
		workPane isQuarterSize
			ifTrue: [workPane extent // 2]
			ifFalse: [workPane extent].

	topPane
		position: self topLeft;
		width: self width;
		height: (menuPanel height + 0 max: logoMorph height + 10).

	stageFrame
		extent: stageExtent + (14@42);
		top: topPane bottom;
		right: self right.

	workPane position: stageFrame topLeft + (4@37).

	titlePane
		position: stageFrame topLeft + (0@1);
		width: stageFrame width - 6;
		height: 36.

	self fixProjectTitleMorphLayout.

	scriptsPane fixLayout.
	w := (viewerPane catButtonsExtent x + 17)
		within: 40
		and: (self width - (scriptsPane bareMinimumWidth + stageFrame width)).
	viewerPane position: topPane bottomLeft;
		width: w ;
		height: self bottom - topPane bottom.

	scriptsPane
		position: viewerPane topRight;
		width: self width - (stageFrame width + viewerPane width);
		height: self bottom - topPane bottom;
		fixLayout.

	libraryPane position: stageFrame bottomLeft;
		width: (self right - scriptsPane right);
		height: self bottom - libraryPane top.

	menuPanel
		left: logoMorph right + 18;
		top: topPane top + ((topPane height - menuPanel height) // 2) + 2.

	viewModeButtonsPanel
		right: stageFrame right - 8;
		top: self top + 7.

	stageButtonsPanel
		position: (stageFrame left + 10)@(topPane bottom + 5);
		width: stageFrame width - 28;
		height: (workPane top - stageFrame top) - 8.

	xyReadout := readoutPane submorphs at: 1.
	readoutPane
		width: xyReadout width + 23;
		height: xyReadout height + 15;
		position: stageFrame bottomRight - ((readoutPane width + 6)@3).
	xyReadout position: readoutPane position + (18@5).

	toolbarPanel
		left: (stageFrame left - 4 max: menuPanel right);
		top: self top + ((topPane height - toolbarPanel height) // 2) + 3.

	((toolbarPanel right - 5) > viewModeButtonsPanel left)
		ifTrue: [toolbarPanel delete]
		ifFalse: [
			(toolbarPanel owner = self) ifFalse: [
				self addMorphFront: toolbarPanel]].

]

{ #category : #private }
PhratchFrameMorph >> fixNestedBlocks [
	"Not the best solution, I'm sure, but working"
	
	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [
			m convertStacksToTuples]].

	viewerPane rebuildCategorySelectors.

	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [
			m convertTuplesToStacks]].
	self updatePanes.
]

{ #category : #private }
PhratchFrameMorph >> fixProjectTitleMorphLayout [
 
	| s truncated eWidth w |

	projectName ifNotNil: [
		s :=  (self nameFromFileName: projectName).
		"trim project name to fit, if necessary"
		truncated := false.
		eWidth := (PhratchTranslator stringExtent: '...' font: projectTitleMorph font) x.
		w := titlePane width - 100 - eWidth.
		[((PhratchTranslator stringExtent: s font: projectTitleMorph font) x) > w] whileTrue: [
			truncated := true.
			s := s copyFrom: 1 to: s size - 1].
		truncated ifTrue: [s := s, '...'].
		projectTitleMorph contents: s].

]

{ #category : #drawing }
PhratchFrameMorph >> fullDrawOn: aCanvas [
	"Draw my full Morphic structure on the given Canvas."
	"Optimization: if damage is entirely contained in a given pane, draw only that pane."

	| damageR stageR |
	damageR := aCanvas clipRect.

	stageR := workPane bounds.
	workPane isQuarterSize ifTrue: [
		stageR := workPane position extent: (workPane width // 2) @ (workPane height // 2)].
	(stageR containsRect: damageR) ifTrue: [
		workPane fullDrawOn: aCanvas.
		^ self].

	(scriptsPane bounds containsRect: damageR) ifTrue: [
		scriptsPane fullDrawOn: aCanvas.
		^ self].

	(viewerPane bounds containsRect: damageR) ifTrue: [
		viewerPane fullDrawOn: aCanvas.
		^ self].

	(readoutPane bounds containsRect: damageR) ifTrue: [
		readoutPane fullDrawOn: aCanvas.
		^ self].

	(libraryPane bounds containsRect: damageR) ifTrue: [
		libraryPane fullDrawOn: aCanvas.
		^ self].

	super fullDrawOn: aCanvas.

]

{ #category : #'event handling' }
PhratchFrameMorph >> handlesKeyboard: evt [
	^ true
]

{ #category : #'event handling' }
PhratchFrameMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> helpMenu: aMenuTitleMorph [
	| menu |
	menu := MenuMorph new defaultTarget: self.
	menu add: 'Phratch Website' translated action: #launchWebsite.
	menu addLine.
	menu add: 'Scratch Help Page' translated action: #launchHelpPage.
	menu add: 'Help Screens' translated action: #launchAllHelpScreens.
	menu addLine.
	menu add: 'BYOB Reference Manual' translated action: #openBYOBManual.
	menu add: 'Panther Tutorials' translated action: #openPantherTutorials.
	menu addLine.
	menu add: 'About Phratch' translated action: #aboutPhratch.
	menu localize.
	#(1 2 3 4 5 6)
		do: [ :n | 
			menu labels
				at: n
				put:
					((menu labels at: n) contents copyFrom: 1 to: (menu labels at: n) contents size - 1) , PhratchTranslator ellipsesSuffix ].
	menu popUpAt: aMenuTitleMorph bottomLeft + (0 @ 10) inWorld: World
]

{ #category : #'file read/write' }
PhratchFrameMorph >> importPhratchProject [
	"Allow the user to select a project to open, then merge that project's sprites with the
current project."

	| response |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.

	response := PhratchFileChooserDialog
		chooseExistingFileType: #project
		extensions: #(scratch sb ypr phr)
		title: 'Import Project'.
	response ifNil: [^ self].

	self importSpriteOrProject: response.

]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> importSpriteOrProject: fileNameOrData [
	"Read the sprite or project file and merge into the current project."

	| data f importedStage defaultForm defaultSound |
	data := fileNameOrData.
	(data isKindOf: FileReference) ifTrue: [  "read the contents of a local file"
		fileNameOrData exists ifFalse: [^ self].
		f := (FileStream readOnlyFileNamed: fileNameOrData) binary.
		f ifNil: [^ self].
		data := f contentsOfEntireFile].

	[importedStage := self extractProjectFrom: data] ifError: [^ self].

	"fix references to old stage"
	importedStage allMorphsDo: [:m |
		(m isKindOf: WatcherMorph) ifTrue: [m mapReceiver: importedStage to: workPane].
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [
			m blocksBin submorphs do: [:stack |
				(stack isKindOf: BlockMorph) ifTrue: [
					stack blockSequence do: [:b | b mapReceiver: importedStage to: workPane]]]]].

	"add global variables from importated stage to my stage"
	importedStage varNames do: [:v |
		workPane addVariable: v value: (importedStage getVar: v)].
	importedStage varNames do: [:v | workPane addVariable: v].

	"add imported stage scripts"
	importedStage blocksBin submorphs do: [:stack |
		(stack isKindOf: BlockMorph) ifTrue: [workPane addStack: stack fullCopy]].

	"add imported background costumes and scripts to my stage, filtering out default items"
	defaultForm := workPane defaultImageMedia form hibernateForPhratch.
	defaultSound := SoundMedia new sound.
	importedStage media do: [:media |
		(media isImage and: [media form hibernate bits ~= defaultForm bits])
			ifTrue: [workPane addMediaItem: media].
		(media isSound and: [media sound samples ~= defaultSound samples])
			ifTrue: [workPane addMediaItem: media]].

	"add imported global custom block definitions"
	importedStage customBlocks ifNotNil: [

		'installing globals...' 
			displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
			from: 0 to: importedStage customBlocks size
			during: [:bar | | i | i := 0.

		importedStage customBlocks do: [:eachDef |
			i := i + 1. bar value: i.
			workPane sprites, {workPane} do: [:obj |
				obj
					updateCustomBlockDefinitionId: eachDef id with: eachDef;
					updateLocalId: eachDef id withSpec: eachDef userSpec]]]].

	importedStage position: workPane position.

	importedStage submorphs do: [:m | 
		(m isKindOf: PhratchSpriteMorph) ifTrue: [
			"m objName: m  nextInstanceName".
			workPane addMorphFront: m.
			m startStepping.
			workPane sprites addLast: m.
			self view: m tab: 'Scripts' category: 'motion'.
			m refPos ifNotNil: [
				m referencePosition: m refPos + (50@ -50) ].
			m layoutChanged.
			m changed
			]].

	workPane layoutChanged.

]

{ #category : #intialization }
PhratchFrameMorph >> initialize [

	super initialize.
	fillScreenFlag := false.
	paintingInProgress := false.
	projectInfo := Dictionary new.
	watcherPositions := Dictionary new.
	justSaved := false.
	quitFlag := false.
	blockEditors := Set new.
	author := ''.
	loginName := ''.
	viewMode := #normal.

	self createBasicPanes.
	self createLogo.
	self createMenuPanel.
	self createViewModeButtonsPanel.
	self createStageButtonsPanel.
	self createToolbar.

	self extent: 1000@600.

]

{ #category : #watchers }
PhratchFrameMorph >> initializeWatcherPositions [
	"If any watchers are on the stage, store their position. The dictionary, which is created lazily, is formatted in the following way:
	(<sprite or nil, depending on whether the block isSpriteSpecific>, <name of block>) ->
		(<watcher or nil, depending on whether the watcher is showing on stage>,
		 <position of watcher with top-left corner of stage = 0@0>
		 <layout style>
		 <slider range>)
	Or, more concisely: (sprite/nil,selectorAndArg)->(watcher/nil,position,style,range)."
 
	| p |
	watcherPositions := Dictionary new.
	self phratchWatchers do: [:w |
		p := w position - workPane position.
		watcherPositions
			at: {w getAssociatedSprite. w selectorAndArg}
			put: {w. p. w layoutStyle. w sliderRange}].

]

{ #category : #'file read/write' }
PhratchFrameMorph >> installNewProject: newWorkpane [
	"Called after creating or reading a new project to clear the process scheduler, pick an object to view, clear the library thumbnails, and perform other housekeeping."

	| viewTarget |
	self stopAll.

	newWorkpane class = PhratchStageMorph
		ifFalse: [^ self inform: 'Incompatible Phratch file format'].

	newWorkpane isQuarterSize: workPane isQuarterSize.
	newWorkpane bounds: workPane bounds.
	newWorkpane midiPortNum: workPane midiPortNum.
	workPane closeMIDI.

	workPane owner replaceSubmorph: workPane by: newWorkpane.
	workPane := newWorkpane.

"	self fixByteReversedSounds. "

	"fix sprite positions (backward compatibility)"
	workPane submorphs do: [:m |
		(m isKindOf: WatcherMorph) ifTrue: [m convertFromOldWatcher].
		(m respondsTo: #costume) ifTrue: [
			m position: m position + m costume rotationCenter]. "fix up positions"
		m layoutChanged].
	workPane layoutChanged.

	"reset timer"
	ScriptablePhratchMorph resetTimer.

	"pick an object view, or view the background if there is no other"
	viewTarget := workPane.
	workPane submorphs do: [:m |
		(m respondsTo: #scripts) ifTrue: [
			m scripts size >= viewTarget scripts size ifTrue: [viewTarget := m]]].
	viewTarget viewBlocksAndScripts.

	"populate the sprites list if it is empty (backward compatability)"
	workPane sprites isEmpty ifTrue: [
		workPane submorphs do: [:m |
			(m isKindOf: ScriptablePhratchMorph) ifTrue: [workPane sprites addLast: m]]].

	scriptsPane tabPane currentTab: 'Scripts'.
	libraryPane clearLibrary.
	
	workPane clearPenTrails.
	"self updateProjectName".
	PhratchProcess blockHighlightMSecs: 1.
	PhratchPrompterMorph clearLastAnswer.

	"(projectInfo at: 'isHosting' ifAbsent: [false]) ifTrue: [
		self enableRemoteSensors]."
	(projectInfo includesKey: 'penTrails') ifTrue: [
		workPane penTrailsForm: (projectInfo at: 'penTrails')].

	(projectInfo at: 'keepOnStage' ifAbsent: [true]) = ScriptablePhratchMorph keepOnStage
		ifFalse: [self toggleKeepSpritesOnStage].

	Clipboard := nil.
	World cleanseStepList.  "make sure garbage collect can clean up the old sprites"
	Smalltalk garbageCollect.  "get rid of old sprite instances"

	self world ifNotNil: [self world startSteppingSubmorphsOf: self].
	ScriptablePhratchMorph phratchOrigin: workPane center.
	justSaved := true.

]

{ #category : #byob }
PhratchFrameMorph >> isDevelopmentMode [

	^true
]

{ #category : #classification }
PhratchFrameMorph >> isHandMorph [
	^fillScreenFlag
]

{ #category : #byob }
PhratchFrameMorph >> isTurbo [
	^ PhratchProcess blockHighlightMSecs < 1
]

{ #category : #byob }
PhratchFrameMorph >> keepSpritesOnStage: anInt [
	| bool |

	bool := {false. true} at: anInt + 1.
	ScriptablePhratchMorph keepOnStage: bool
]

{ #category : #'event handling' }
PhratchFrameMorph >> keyStroke: evt [
	|ch|
	ch := evt keyValue.
			evt commandKeyPressed ifTrue: [ch := ch \\ 32].	"map cmd/alt keys to control keys"
			({3 . 13} includes: ch) ifTrue: [^ self pressGreenFlagButton].
			ch = 15 ifTrue: [^ self openPhratchProject].
			ch = 17 ifTrue: [^ self quitPhratch].
			ch = 19 ifTrue: [^ self savePhratchProjectNoDialog].       
			ch = 27 ifTrue: [
				PhratchFrameMorph takeOverScreen ifTrue: [
					Display fullScreenMode: false.
					Display fullScreenMode: true.
					World restoreDisplay].
				^ self].
			workPane broadcastEventNamed: 'Phratch-KeyPressedEvent' with: evt.
]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> languageMenu: aToggleButtonMorph [
	"Present a menu of possible languages for blocks."

	| bullet menu |
	bullet := String withAll: '*'.
	menu := MenuMorph new defaultTarget: self.
	PhratchTranslator languageNames do: [:lang |
		((PhratchTranslator isoCodeForName: lang) = (PhratchTranslator currentLanguage))
			ifTrue: [menu 
						add: (bullet, ' ', lang, ' ', bullet)
						target: self 
						selector: #setLanguage:
						argument: lang]
			ifFalse: [menu 
						add: lang
						target: self 
						selector: #setLanguage:
						argument: lang]].
	menu invokeModalAt: aToggleButtonMorph bottomLeft + (0@10) in: World allowKeyboard: true. 

	self stopAll.

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> launchAllHelpScreens [

	self launchHelpFile: 'allscreens.html'

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> launchHelpFile: aFilename [

	| helpDir subDir |
	
	helpDir := FileSystem workingDirectory / 'Help'.
	helpDir exists ifFalse: [^ Beeper beep].  "no help folder"
	self stopAll.
	

	"use the English subfolder by default if it exists"
	(helpDir directoryNames includes: 'en') ifTrue: [subDir := helpDir / 'en'].
	"use subfolder for the current language if it exists"
	(helpDir directoryNames includes: PhratchTranslator currentLanguage) ifTrue: [
		subDir := helpDir / PhratchTranslator currentLanguage].
	subDir ifNotNil: [helpDir := subDir].
	(helpDir / aFilename) exists
		ifTrue: [ 
			self open: (((helpDir / aFilename) fullName))]
		ifFalse: [
			DialogBoxMorph inform: 'Help file not found.' localized].

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> launchHelpPage [

	self launchHelpFile: 'index.html'.

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> launchWebsite [

	self world displayWorldSafely.
	Cursor wait showWhile: [PhratchPlugin primOpenURL: 'https://code.google.com/p/phratch/'].

]

{ #category : #accessing }
PhratchFrameMorph >> libraryPane [

	^ libraryPane

]

{ #category : #watchers }
PhratchFrameMorph >> listWatchers [
	"Answer a collection of all the list watchers in the work pane."

	^ self workPane submorphs select: [:m | m isKindOf: PhratchListMorph]

]

{ #category : #accessing }
PhratchFrameMorph >> loginName [

	^ loginName

]

{ #category : #intialization }
PhratchFrameMorph >> makeXYReadout [
	"Make and answer an x-y readout."

	| normalFont boldFont panel spaceWidth labelX readoutX labelY readoutY |
	normalFont := PhratchFrameMorph getFont: #XYReadout.
	boldFont := PhratchFrameMorph getFont: #XYReadoutBold.
	PhratchTranslator renderScale ~= 1
		ifTrue: [ 
			"force fonts to be fixed size:"
			normalFont := StrikeFont
				osFontName: normalFont name
				size: normalFont pointSize / PhratchTranslator renderScale asFloat.
			boldFont := StrikeFont osFontName: boldFont name size: boldFont pointSize / PhratchTranslator renderScale asFloat ].
	panel := Morph new color: (Color r: 0.753 g: 0.764 b: 0.776).
	labelX := PhratchTranslator isRTL
		ifTrue: [ 
			StringMorph new
				font: normalFont;
				contents: ':x' ]
		ifFalse: [ 
			StringMorph new
				font: normalFont;
				contents: 'x:' ].
	readoutX := UpdatingStringMorph new
		target: self;
		getSelector: #mouseX;
		forceUnicodeRendering: true;
		font: boldFont;
		stepTime: 150;
		growable: false;
		yourself.
	readoutX width: (readoutX stringWidth: '-1000').
	labelY := PhratchTranslator isRTL
		ifTrue: [ labelX fullCopy contents: ':y' ]
		ifFalse: [ labelX fullCopy contents: 'y:' ].
	readoutY := readoutX fullCopy getSelector: #mouseY.
	spaceWidth := ((readoutX stringWidth: ' ') * 0.8) asInteger.
	PhratchTranslator isRTL
		ifTrue: [ 
			readoutY rightJustify: true.
			panel addMorph: (readoutY position: 0 @ 0).
			panel addMorph: (labelY position: readoutY topRight + (spaceWidth @ 0)) ]
		ifFalse: [ 
			panel addMorph: (labelX position: 0 @ 0).
			panel addMorph: (readoutX position: labelX topRight + (spaceWidth @ 0)) ].
	PhratchTranslator isRTL
		ifTrue: [ 
			readoutX rightJustify: true.
			panel addMorph: (readoutX position: labelY right @ labelY top + (spaceWidth @ 0)).
			panel addMorph: (labelX position: readoutX topRight + (spaceWidth @ 0)) ]
		ifFalse: [ 
			panel addMorph: (labelY position: (labelX right + readoutX width + 8) @ labelX top).
			panel addMorph: (readoutY position: labelY topRight + (spaceWidth @ 0)) ].
	PhratchTranslator isRTL
		ifTrue: [ panel extent: (labelX right max: labelY right) @ labelY bottom ]
		ifFalse: [ panel extent: (readoutX right max: readoutY right) @ labelY bottom ].
	^ panel
]

{ #category : #'event handling' }
PhratchFrameMorph >> mouseDown: evt [
	"Revert to normal cursor."

	evt hand toolType: nil.
	(evt cursorPoint y - self top) < topPane height ifTrue: [
		self isSticky ifFalse: [evt hand grabMorph: self]].

]

{ #category : #other }
PhratchFrameMorph >> mouseX [

	^ workPane mouseX

]

{ #category : #other }
PhratchFrameMorph >> mouseY [

	^ workPane mouseY

]

{ #category : #'file read/write' }
PhratchFrameMorph >> nameFromFileName: fileName [
	"Return the given Phratch file name without the trailing .sb or .scratch or .ypr extension, if it has one. Ensure the the result is UTF8."

	| s |
	fileName = '' ifTrue: [ ^'default' ].
	s := fileName asFileReference basename.
	(s asLowercase endsWith: '.scratch') ifTrue: [s := s copyFrom: 1 to: s size - 8].
	(s asLowercase endsWith: '.sb') ifTrue: [s := s copyFrom: 1 to: s size - 3].
	(s asLowercase endsWith: '.ypr') ifTrue: [s := s copyFrom: 1 to: s size - 4].
	(s asLowercase endsWith: '.phr') ifTrue: [s := s copyFrom: 1 to: s size - 4].
	s := String withAll: s.

	^ s


]

{ #category : #buttonActions }
PhratchFrameMorph >> newPhratchProject [
	"Make a new, blank Phratch project."

	| response newProject sprite |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.

	(justSaved or: [self projectIsEmpty]) ifFalse: [
		"ask the user if they want to save the current project"
		response := DialogBoxMorph askWithCancel: 'Save the current project?'.
		response = #cancelled ifTrue: [^ self].
		response ifTrue: [self savePhratchProjectNoDialog.
			justSaved ifFalse: [^ self]]].

	projectDirectory := PhratchFileChooserDialog getDefaultFolderForType: #project.
	projectName := ''.
	projectInfo := Dictionary new.

	newProject := PhratchStageMorph new.
	sprite := PhratchFrameMorph defaultSprite fullCopy.
	sprite position: (240@180) - sprite extent.
	newProject addMorph: sprite.
	self installNewProject: newProject.
	sprite installGlobalBlocks.

	ScriptablePhratchMorph decodeAsByob. 

	self initializeWatcherPositions.
	blockEditors := Set new.
	justSaved := true.

]

{ #category : #other }
PhratchFrameMorph >> newSound [
	"Open the dialog to record a new sound."

	scriptsPane tabPane currentTab: 'Sounds'.
	viewerPane target recordSound.
]

{ #category : #private }
PhratchFrameMorph >> nextSurpriseCostumeName [
	"Answer a surprise costume name or nil if there are no costumes."
	"Details: Shuffle the list of available costume names and return them one at a time. When there are none left, generate a new shuffle. This avoids repeats."

	| dir ext  |
	(shuffledCostumeNames isNil or:
	 [shuffledCostumeNames size = 0]) ifTrue: [
		shuffledCostumeNames := OrderedCollection new: 1000.
		dir := (FileSystem workingDirectory / 'Media' / 'Costumes').
		
		dir allChildren do: [:f |
			|fn|
			fn := f fullName. 
			(fn includesSubstring: 'Letters') ifFalse: [
				ext := ((FileSystem workingDirectory / fn) extension) asLowercase.
			
				((ext size > 0) and: [#(gif png jpg) includes: ext])
					ifTrue: [shuffledCostumeNames add: fn]]]].

	shuffledCostumeNames shuffleBy: Random new.
	shuffledCostumeNames size = 0
		ifTrue: [^ nil]
		ifFalse: [^ shuffledCostumeNames removeFirst].
]

{ #category : #byob }
PhratchFrameMorph >> notEditingBlock [
	blockEditors size = 0 ifTrue: [^true].
	(DialogBoxMorph ask: 'Close open block editor(s)?') ifFalse: [^false].
	blockEditors do:[:each | each no].
	blockEditors := Set new.
	^true
]

{ #category : #byob }
PhratchFrameMorph >> notEditingBlockDefinition: aCustomBlockDefinition [
	| editor |
	blockEditors size = 0 ifTrue: [^true].
	editor := blockEditors detect: [:each | 
		each definition id = aCustomBlockDefinition id] 
		ifNone: [nil].
	editor ifNil: [^true].
	editor comeToFront.
	^ false
]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> open: aFileName [ 
	Smalltalk os isMacOSX ifTrue: [  
		^ OSProcess command: ('open "', aFileName, '"').
	].
	Smalltalk os isUnix ifTrue:[
		^ OSProcess command: ('xdg-open "', aFileName, '"').
	].
	Smalltalk os isWin32 ifTrue:[
		"^NBWin32Shell shellOpen: '', aFileName, ''."
		^ OSProcess command: ('cmd.exe /k "', aFileName, '"').
	]
]

{ #category : #byob }
PhratchFrameMorph >> openBYOBManual [

	self open: (((FileSystem workingDirectory / 'Manual' / 'BYOBManual.pdf') fullName))
]

{ #category : #other }
PhratchFrameMorph >> openMIDI [
	"Prompt the user to select a MIDI port number, then open it."

	workPane openMIDI.

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> openPantherTutorials [

	self world displayWorldSafely.
	Cursor wait showWhile: [PhratchPlugin primOpenURL: 'http://pantherprogramming.weebly.com/panther-tutorials.html'].

]

{ #category : #'file read/write' }
PhratchFrameMorph >> openPhratchProject [
	"Allow the user to select a project to open, then open that project."

	| response newProj |
	self closeMediaEditorsAndDialogs
		ifFalse: [ ^ self ].
	self stopAll.
	(justSaved or: [ self projectIsEmpty ])
		ifFalse: [ 
			"ask the user if they want to save the current project"
			response := DialogBoxMorph askWithCancel: 'Save the current project?'.
			response = #cancelled
				ifTrue: [ ^ self ].
			response
				ifTrue: [ self savePhratchProjectNoDialog ] ].
	response := PhratchFileChooserDialog openPhratchFileFor: self.
	response = #cancelled
		ifTrue: [ ^ self ].
	(response isKindOf: FileReference)
		ifTrue: [ 
			"read the contents of a local file"
			^ self openPhratchProjectNamed: response ].
	(response isKindOf: ByteArray)
		ifFalse: [ ^ self ].
	[ projectInfo := self extractInfoFrom: response ] ifError: [ projectInfo := Dictionary new ].
	[ newProj := self extractProjectFrom: response ] ifError: [ ^ self ].
	self installNewProject: newProj.
	projectDirectory := PhratchFileChooserDialog getDefaultFolderForType: #project
]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> openPhratchProjectNamed: fName [
	"Open a Phratch project with the given name."

	| f projData newProj dir fn|
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	fn := fName.
	f := FileStream readOnlyFileNamedOrNil: fn.
 	f ifNil: ["try a different encoding, fixes a Firefox bug, -Jens"
		fn := fName fullName.
		f := FileStream readOnlyFileNamedOrNil: fn.
		f ifNil: [^ self inform: 'Could not read' withDetails: fName]].

	"["
		projData := f binary contentsOfEntireFile.
		newProj := self extractProjectFrom: projData.
		projectInfo := self extractInfoFrom: projData.
	"] ifError: [:err :rcvr | ^ self inform: 'Could not read project; file may be damaged' withDetails: '(', err, ')']."

	dir := (fn) parent.
	projectDirectory := dir.
	PhratchFileChooserDialog setLastFolderTo: projectDirectory forType: #project.
	projectName := ( fn) basename.

	self installNewProject: newProj.
	self initializeWatcherPositions.
	viewerPane updateContents.

]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> openSilentlyPhratchProjectNamed: fName [
	"Open a Phratch project with the given name."

	| f projData newProj dir fn|
	"self closeMediaEditorsAndDialogs ifFalse: [^ self]."
	fn := fName.
	f := FileStream readOnlyFileNamedOrNil: fn.
 	f ifNil: ["try a different encoding, fixes a Firefox bug, -Jens"
		fn := fName fullName.
		f := FileStream readOnlyFileNamedOrNil: fn.
		f ifNil: [^ self" inform: 'Could not read' withDetails: fName"]].

	"["
		projData := f binary contentsOfEntireFile.
		newProj := self extractProjectFrom: projData.
		projectInfo := self extractInfoFrom: projData.
	"] ifError: [:err :rcvr | ^ self inform: 'Could not read project; file may be damaged' withDetails: '(', err, ')']."

	dir := (fn) parent.
	projectDirectory := dir.
	PhratchFileChooserDialog setLastFolderTo: projectDirectory forType: #project.
	projectName := ( fn) basename.

	self installNewProject: newProj.
	self initializeWatcherPositions.
	viewerPane updateContents.

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> ownerChanged [
	"The receiver's owner has changed its layout.
	Since this method is called synchronously in the
	ui, delete the receiver if there are any excpetions."

	super ownerChanged.
	fillScreenFlag
		ifFalse: [ ^ self ].
	self position: 0 @ 0.
	self isSticky: true.
	self extent: Display extent
]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> paintSpriteMorph [

	| m |
	m := PhratchSpriteMorph new soleCostume: ImageMedia new.
	self addAndView: m.
	m editDrawingOldCostumeName: m costume mediaName deleteOnCancel: true.

]

{ #category : #accessing }
PhratchFrameMorph >> paintingInProgress [
	"Answer true if the paint editor is in use."

	^ paintingInProgress

]

{ #category : #accessing }
PhratchFrameMorph >> paintingInProgress: aBoolean [

	paintingInProgress := aBoolean.

]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> phratchObjects [
	"Answer a collection of all the phratch objects in the work pane."

	^ self workPane submorphs select: [:m | m isKindOf: ScriptablePhratchMorph]

]

{ #category : #watchers }
PhratchFrameMorph >> phratchWatchers [
	"Answer a collection of all the phratch watchers in the work pane."

	^ self workPane submorphs select: [:m | m isKindOf: WatcherMorph]

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> prepareImageForEndUserSilently [

"	(self confirm: '
Close non-Phratch windows and save this
image in end-user (fillScreen) mode?') ifFalse: [^ self].
"

	self setLanguage: 'en'.

	self enterNormalMode.
	self blockContrastStrong.
	ScriptablePhratchMorph keepOnStage: true.
	
	EventHatMorph threadSafeMode: false.

	BlockLabelFragmentDialog isExpanded: false.

	World submorphs do: [:m |
		(m isKindOf: SystemWindow) ifTrue: [m delete]].
	self clearStage.

	Display newDepth: 32.
	self fillScreenOn.
	World doOneCycleNow.
	ImageCleaner cleanUpForProduction.

]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> presentHelpScreen: aStringOrNil [
	"Look for a help screen with the given name in the 'Help' folder. If found, present it to the user."

	| helpDir subDir fileNames helpFileName helpForm |
	aStringOrNil ifNil: [^ Beeper beep].

	(FileSystem workingDirectory fileSystem exists: 'Help') ifFalse: [^ Beeper beep].  "no help folder"
	helpDir := FileSystem workingDirectory / 'Help'.

	"use the English subfolder by default if it exists"
	(helpDir / 'en') exists ifTrue: [subDir := helpDir / 'en'].
	"use subfolder for the current language if it exists"
	(helpDir / PhratchTranslator currentLanguage) exists ifTrue: [
		subDir := helpDir / PhratchTranslator currentLanguage].
	subDir ifNotNil: [helpDir := subDir].

	fileNames := helpDir fileNames collect: [:s | s asLowercase].

	helpFileName := nil.
	#(hlp gif png jpg bmp) do: [:ext |
		helpFileName ifNil: [
			helpFileName := aStringOrNil, '.', ext.
			(fileNames includes: helpFileName asLowercase)
				ifFalse: [helpFileName := nil]]].
	helpFileName ifNil: [^ Beeper beep].

	World doOneCycle.  "update cursor before fetching helpForm"
	[helpForm := Form fromFileNamed: (helpDir / helpFileName) fullName]
		ifError: [PhratchError error].

	HelpDialog showForm: helpForm.

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> pressGreenFlagButton [
	"Simulate pressing the green flag button when enter key is pressed."

	flagButton on.
	World displayWorld.
	(Delay forMilliseconds: 100) wait.
	flagButton off.
	World displayWorld.
	self shoutGo.


]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> printTupleElement: el on: s [

	(el isKindOf: Array) ifTrue: [self printTupleList: el on: s. ^ self].
	(el isKindOf: Symbol) ifTrue: [s nextPutAll: el. ^ self].
	(el isKindOf: String) ifTrue: [s nextPut: $". s nextPutAll: el. s nextPut: $". ^ self].
	(el isKindOf: ScriptablePhratchMorph) ifTrue: [s nextPutAll: el objName. ^ self].
	s nextPutAll: el printString.

]

{ #category : #uploading }
PhratchFrameMorph >> printTupleList: anArray on: s [

	s nextPut: $(.
	1 to: anArray size do: [:i |
		self printTupleElement: (anArray at: i)  on: s.
		i = anArray size ifFalse: [s space]].
	s nextPut: $).

]

{ #category : #stepping }
PhratchFrameMorph >> processKeyboardEvents [

	| evt ch |
	World hands do: [:h |
		[(evt := h nextUnclaimedKeystrokeOrNil) notNil] whileTrue: [
			ch := evt keyValue.
			evt commandKeyPressed ifTrue: [ch := ch \\ 32].	"map cmd/alt keys to control keys"
			({3 . 13} includes: ch) ifTrue: [^ self pressGreenFlagButton].
			ch = 15 ifTrue: [^ self openPhratchProject].
			ch = 17 ifTrue: [^ self quitPhratch].
			ch = 19 ifTrue: [^ self savePhratchProjectNoDialog].
			ch = 27 ifTrue: [
				PhratchFrameMorph takeOverScreen ifTrue: [
					Display fullScreenMode: false.
					Display fullScreenMode: true.
					World restoreDisplay].
				^ self].
			workPane broadcastEventNamed: 'Phratch-KeyPressedEvent' with: evt]].

]

{ #category : #startup }
PhratchFrameMorph >> processSettingsFile [
	"Process settings from the ini file."

	| lang |
	self class setVisibleDrives: nil.
	lang := nil.
	AllowSharing := true.
	PhratchFileChooserDialog clearFolderCache. "clear homeDir and last folder cache"
	
	lang ifNil: [lang := PhratchTranslator guessLanguage].
	self setLanguage: lang.

]

{ #category : #'view mode' }
PhratchFrameMorph >> projectComment: aString [

	aString = DefaultNotes ifTrue: [
		projectInfo removeKey: 'comment' ifAbsent: [].
		^ self].

	projectInfo at: 'comment' put: aString asString.

]

{ #category : #accessing }
PhratchFrameMorph >> projectCommentOrTemplate [

	| s |
	s := projectInfo at: 'comment' ifAbsent: [''].
	s size = 0 ifTrue: [s := DefaultNotes].
	^ s

]

{ #category : #other }
PhratchFrameMorph >> projectDirectory [

	projectDirectory ifNil: [^ FileSystem workingDirectory].
	^ projectDirectory

]

{ #category : #accessing }
PhratchFrameMorph >> projectInfo [
	"Answer the project info dictionary."

	^ projectInfo

]

{ #category : #private }
PhratchFrameMorph >> projectIsEmpty [
	"Answer true if the current project has no scripts, no variables, no special costumes or sounds, and at most a single sprite."

	| allScriptables defaultCostumes defaultSnds |
	"at most one sprite in workpane?"
	workPane submorphs size > 1 ifTrue: [^ false].
	workPane submorphs size = 1 ifTrue: [
		(workPane submorphs first isKindOf: PhratchSpriteMorph) ifFalse: [^ false]].

	allScriptables := workPane submorphs copyWith: workPane.
	defaultCostumes := Set
		with: ScriptablePhratchMorph defaultBackgroundForm.
	defaultSnds := Set
		with: ScriptablePhratchMorph popSound
		with: ScriptablePhratchMorph meowSound.

	PhratchFrameMorph defaultSprite ifNotNil: [
		PhratchFrameMorph defaultSprite media do: [:media |
			media isImage ifTrue: [defaultCostumes add: media form].
			media isSound ifTrue: [defaultSnds add: media sound]]].

	allScriptables do: [:m |
		m customBlocks ifNotNil: [m customBlocks size > 0 ifTrue: [^ false]].  "any custom blocks?"
		m blocksBin submorphs size > 0 ifTrue: [^ false].  "any stacks?"
		m varNames size > 1 ifTrue: [^ false].  "any variables?"
		m media do: [:media |
			(media isImage and: [(defaultCostumes includes: media form) not]) ifTrue: [^ false].
			(media isSound and: [(defaultSnds includes: media sound) not]) ifTrue: [^ false]]].

	^ true

]

{ #category : #other }
PhratchFrameMorph >> projectModified [
	"Record that the current project has changed since it was last saved."

	justSaved := false.

]

{ #category : #accessing }
PhratchFrameMorph >> projectName [

	^ self nameFromFileName: projectName

]

{ #category : #accessing }
PhratchFrameMorph >> projectName: aString [

	projectName := aString.
	projectTitleMorph contents: aString.
	self fixLayout.

]

{ #category : #byob }
PhratchFrameMorph >> purgeBlockEditors [
	blockEditors := blockEditors select: [ :each | each isInWorld ]
]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> quitPhratch [
	"Quit from Phratch. Ask the user if they want to save, first."

	| response |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.

	(justSaved or: [self projectIsEmpty]) ifFalse: [
		response := PhratchCloseDialog new getUserResponse.
		response = #cancelled ifTrue: [^ self].
		response ifTrue: [
			self savePhratchProjectNoDialog.
			justSaved ifFalse: [^ self]]].

	Smalltalk snapshot: true andQuit: true.

]

{ #category : #byob }
PhratchFrameMorph >> randomProjectName [
	| dir projects |
"	dir := PhratchFileChooserDialog getDefaultFolderForType: #project."

	(FileSystem workingDirectory / 'Projects') exists 
		ifTrue: [ dir := FileSystem workingDirectory / 'Projects']
		ifFalse: [ Smalltalk quitPrimitive ].

	projects := dir fileNames
				select: [:fn | (fn asLowercase endsWith: '.sb')
						or: [(fn asLowercase endsWith: '.scratch')
						or: [(fn asLowercase endsWith: '.ypr')
						or: [fn asLowercase endsWith: '.phr']	
				]]].
	projects size > 0 ifTrue: [^ dir fullNameFor: (projects asArray at: Random new next * projects size + 1)].
	^ nil
]

{ #category : #startup }
PhratchFrameMorph >> readDefaultNotes [
	"If there is a file named 'defaultNotes.txt' in the Phratch folder, read it in."

	| dir |
	DefaultNotes := ''.
	dir := FileSystem workingDirectory.
	(dir fileSystem exists: 'defaultNotes.txt') ifTrue: [
		DefaultNotes := (FileStream oldFileNamed: 'defaultNotes.txt') contentsOfEntireFile].

]

{ #category : #private }
PhratchFrameMorph >> rebuildUIForNewLanguage [
	"Rebuild my UI after the language or font has been changed."

	World fullRepaintNeeded.
	viewerPane rebuildCategorySelectors.
	self updatePanes.
	self
		view: scriptsPane target
		tab: scriptsPane tabPane currentTab
		category: viewerPane currentCategory.


]

{ #category : #byob }
PhratchFrameMorph >> refreshBlocks [

	'updating...' 
		displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((workPane allMorphs) select: [:m| m isKindOf: ScriptablePhratchMorph]) size * 3
		during: [:bar | | i | i := 0.

	(workPane submorphs copyWith: workPane) do: [:m |
	(m isKindOf: ScriptablePhratchMorph) ifTrue: [
		i := i + 1. bar value: i.
		m convertStacksToTuples]].

	workPane allMorphsDo: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [
			i := i + 1. bar value: i.
			m convertTuplesToDefinitions]].

	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [
			i := i + 1. bar value: i.
			m convertTuplesToStacks]].
	self updatePanes.
	self
		view: scriptsPane target
		tab: scriptsPane tabPane currentTab
		category: viewerPane currentCategory].

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> renderingMenu [

	PhratchTranslator renderingMenu.

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> saveImageForEndUser [

	(self confirm: '
Close non-Phratch windows and save this
image in end-user (fillScreen) mode?') ifFalse: [^ self].


	self setLanguage: 'en'.

	self enterNormalMode.
	self blockContrastStrong.
	ScriptablePhratchMorph keepOnStage: true.
	
	EventHatMorph threadSafeMode: false.

	BlockLabelFragmentDialog isExpanded: false.

	World submorphs do: [:m |
		(m isKindOf: SystemWindow) ifTrue: [m delete]].
	self clearStage.

	Display newDepth: 32.
	self fillScreenOn.
	World doOneCycleNow.
	ImageCleaner cleanUpForProduction.
	Smalltalk snapshot: true andQuit: true.
	self startup.

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> saveImageForEndUserSilently [

"	(self confirm: '
Close non-Phratch windows and save this
image in end-user (fillScreen) mode?') ifFalse: [^ self].
"
	self prepareImageForEndUserSilently.
	Smalltalk snapshot: true andQuit: true.
	self startup.

]

{ #category : #'file read/write' }
PhratchFrameMorph >> savePhratchProject [

	| fName result |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.

	fName := PhratchFileChooserDialog savePhratchFileFor: self.
	(fName size = 0 or: [fName = #cancelled]) ifTrue: [^ self].

	[(result := PhratchFileChooserDialog confirmFileOverwriteIfExisting: fName) = false] whileTrue: [
		fName := PhratchFileChooserDialog savePhratchFileFor: self.
		(fName size = 0 or: [fName = #cancelled]) ifTrue: [^ self]].
	(result = #cancelled) ifTrue: [^ self].

	self updateLastHistoryEntryIfNeeded.

"	fName := (self nameFromFileName: fName), '.sb'."

	projectDirectory := fName asFileReference parent.
	fName := (self nameFromFileName: fName), '.phr'.
	projectName :=fName asFileReference basename.

	projectInfo at: 'author' put: author.
	self updateHistoryProjectName: projectName op: 'save'.
	self writePhratchProject.

]

{ #category : #'file read/write' }
PhratchFrameMorph >> savePhratchProjectNoDialog [

	| fName dir |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].

	projectName ifNil: [projectName := ''].
	fName := self nameFromFileName: projectName.

	"Do we need to ask for a filename or directory?"
	dir := PhratchFileChooserDialog getLastFolderForType: #project.
	"(fName size = 0 | (dir asFileReference / fName , 'phr') exists not) ifTrue: [^ self savePhratchProject]."
	PhratchFileChooserDialog lastFolderIsSampleProjectsFolder ifTrue:  [^ self savePhratchProject].
	projectDirectory := dir.

	self updateLastHistoryEntryIfNeeded.
	self updateHistoryProjectName: projectName op: 'save'.
	self writePhratchProject.

]

{ #category : #accessing }
PhratchFrameMorph >> scriptsPane [

	^ scriptsPane

]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> setDefaultSprite [
	"Look for default sprite in Media directory. If none found, use the DefaultCatSprite"

	| d f data importedProject fName |

	DefaultSprite := nil.

	"if dfault.ysp exists, use that"
	d := PhratchFileChooserDialog getDefaultFolderForType: #costume.
	(d / 'default.sprite') exists ifTrue: [
		f := (FileStream readOnlyFileNamed: (d / 'default.sprite') fullName) binary.
		f ifNotNil: [
			data := f contentsOfEntireFile.
			importedProject := [self extractProjectFrom: data] ifError: [nil].
			importedProject ifNil: [^ self].
			
			"add imported global custom block definitions"
"
			importedProject customBlocks ifNotNil: [
				importedProject customBlocks do: [:eachDef |
					workPane sprites, {workPane} do: [:obj |
						obj
							updateCustomBlockDefinitionId: eachDef id with: eachDef;
							updateLocalId: eachDef id withSpec: eachDef userSpec]]].
"
			importedProject submorphs do: [:m |
				(m isKindOf: PhratchSpriteMorph) ifTrue: [DefaultSprite := m].
				^ self]]].

	"if default image exists, use the image and add 'pop' sound"
	#(gif png jpg bmp) do: [:e |
		fName := 'default.', e.
		(d / fName) asFileReference exists ifTrue: [
			DefaultSprite := PhratchSpriteMorph new
				importMedia: (d / fName) fullName;
				addMediaItem: (SoundMedia new
					mediaName: 'pop' localized;
					sound: PhratchSpriteMorph popSound;
		yourself);
		yourself.
			^ self]].

]

{ #category : #private }
PhratchFrameMorph >> setLanguage: aString [
	"Set my language and update my blocks."

	| tempJustSaved |

	self closeDialogBoxes.

	'updating...' 
		displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((workPane allMorphs) select: [:m| m isKindOf: ScriptablePhratchMorph]) size * 2
		during: [:bar | | i | i := 0.

	tempJustSaved := justSaved.
	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [
			i := i + 1. bar value: i.
			m convertStacksToTuples]].

	PhratchTranslator setLanguage: (PhratchTranslator isoCodeForName: aString).
	viewerPane rebuildCategorySelectors.

	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [
			i := i + 1. bar value: i.
			m convertTuplesToStacks]].
	self updatePanes.
	self
		view: scriptsPane target
		tab: scriptsPane tabPane currentTab
		category: viewerPane currentCategory.
	justSaved := tempJustSaved].

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> shoutGo [
	"Broadcasts the start event to all objects and processes."

	self stopAll.
	workPane broadcastEventNamed: 'Phratch-StartClicked' with: 0.
	flagButton on.
	self showPause.
	World displayWorldSafely.  "force button flash"
	(Delay forMilliseconds:  20)wait.

]

{ #category : #byob }
PhratchFrameMorph >> showPause [

	pauseButton
		onForm: (PhratchFrameMorph skinAt: #pauseButtonGrayPressed)
		offForm: (PhratchFrameMorph skinAt: #pauseButtonGray)
		overForm: (PhratchFrameMorph skinAt: #pauseButtonGrayPressed)

]

{ #category : #byob }
PhratchFrameMorph >> showPlay [

	pauseButton
		onForm: (PhratchFrameMorph skinAt: #playButtonGrayPressed)
		offForm: (PhratchFrameMorph skinAt: #playButtonGray)
		overForm: (PhratchFrameMorph skinAt: #playButtonGrayPressed)

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> showSettingBrowser [

	SettingBrowser new changePackageSet: {PackageOrganizer default mostSpecificPackageOfClass: PhratchInstaller}; open
]

{ #category : #watchers }
PhratchFrameMorph >> showWatcher: watcher [
	"Show the given watcher. Reuse it's old position if it was showing before. Otherwise, find a new position for it."

	| rec style range |
	rec := watcherPositions
		at: {watcher getAssociatedSprite. watcher selectorAndArg}
		ifAbsent: [nil].
	rec
		ifNil: [
			watcher position: self unusedPositionForWatcher.
			style := #small.
			range := watcher sliderRange]
		ifNotNil: [
			watcher position: workPane position + rec second.
			style := rec third.
			range := rec fourth].

	watcherPositions
		at: {watcher getAssociatedSprite. watcher selectorAndArg}
		put: {watcher. (watcher position - workPane position). style. range}.

	watcher sliderRange: range.
	watcher layoutStyle: style.
	watcher updateTargetName.
	workPane addMorph: watcher.
	watcher world ifNotNil: [watcher world startSteppingSubmorphsOf: watcher].


]

{ #category : #startup }
PhratchFrameMorph >> startup [

	| startupFileNames fileName arg presentationMode |
"
	HostSystemMenus startUp.
	HostSystemMenus menuBarControler reviseHostMenus.
"
	ScriptablePhratchMorph randomInit.
	PhratchTranslator importLanguagesList.

"	PhratchFrameMorph readShareServerEntry."
	BlockMorph contrastStrong.
	self keepSpritesOnStage: 1.
	EventHatMorph threadSafeMode: false.
	HandMorph translucentWhenDragging: true.
	VariableFrame scopeContrast: false.
	self processSettingsFile.
	self readDefaultNotes.

	BlockEditorFrameMorph resetDimensions.
	ElementsEditorFrameMorph resetDimensions.
	DebuggerFrameMorph resetDimensions.

	self updateProjectName.
	shuffledCostumeNames := nil.
	author := ''.
	loginName := ''.
	justSaved := true.
	presentationMode := false.
	quitFlag := false.
	
	startupFileNames := "InputSensor startupFileNames asOrderedCollection" OrderedCollection new.
	
	
	2 to: 10 do: [:i |
		arg := Smalltalk vm getSystemAttribute: i.
		(arg notNil and: [arg size > 0]) ifTrue: [
			startupFileNames addLast: (PhratchPlugin primShortToLongPath: arg)]].

	startupFileNames do: [:n |
		(n asLowercase = 'presentation') ifTrue: [
			quitFlag := true. 
			presentationMode := true.
			self isHidden: true.
			Display fillBlack].
		(n asLowercase = 'fullscreen') ifTrue: [PhratchFrameMorph takeOverScreen: true]].
"
	TakeOverScreen ifTrue: [
		Display fullScreenMode: true.
		World restoreDisplay].
"
			PhratchFrameMorph takeOverScreen: false.

	"self enterQuarterModeIfSmallScreen."

	fileName := startupFileNames
		detect: [:fn |
			(fn asLowercase endsWith: '.sb') or: [(fn asLowercase endsWith: '.scratch') or: [(fn asLowercase endsWith: '.ypr') or:[fn asLowercase endsWith: '.phr']]]]
		ifNone: [presentationMode ifTrue: [self randomProjectName]]. "this is BYOB's screensaver feature -jens"
	fileName ifNotNil: [
		presentationMode ifTrue: [Display fillColor: Color black].
		self openPhratchProjectNamed: fileName.
		presentationMode ifTrue: [self enterPresentationMode; shoutGo].
		^ self].

	viewerPane currentCategory: 'motion'.
	
	self setDefaultSprite.
	self newPhratchProject.

	fileName := startupFileNames
		detect: [:fn | (fn asLowercase endsWith: '.sprite') or: [(fn asLowercase endsWith: '.ysp') or: [(fn asLowercase endsWith: '.phr') or: [fn asLowercase endsWith: '.phsp']]]]
		ifNone: [^ self].

	"open a .sprite file"
	workPane submorphs do: [:m | (m isKindOf: PhratchSpriteMorph) ifTrue: [m deleteSprite]].
	self importSpriteOrProject: fileName.

]

{ #category : #stepping }
PhratchFrameMorph >> step [
	"Run each process until it gives up control, then filter out any processes that have terminated."


"	fillScreenFlag ifTrue: [
		screenExtent := Display extent.
		((self position = (0@0)) and: [self extent = screenExtent]) ifFalse: [
			oldJustSaved := justSaved.
			self position: 0@0.
			self extent: screenExtent.
			self enterQuarterModeIfSmallScreen.
			scriptsPane currentCategory: scriptsPane currentCategory.
			justSaved := oldJustSaved.
			^ self]]." "simplify at the moment"

	workPane ifNotNil: [
		ScriptablePhratchMorph phratchOrigin: workPane center.
		viewerPane target isNil 
			ifTrue: [workPane viewBlocksAndScripts]
			ifFalse: [viewerPane target isInWorld ifFalse: [workPane viewBlocksAndScriptsQuickly]]].

	paintingInProgress ifTrue: [^ self].

"	self checkForWeDo." "simplify at the moment"
	self updateToolButtons.
	self processKeyboardEvents. 
	workPane stepProcesses.
"	self processDroppedFiles." "simplify at the moment"
	workPane processesToRun size > 0
		ifTrue: [flagButton on]
		ifFalse: [flagButton off. self showPause]

]

{ #category : #stepping }
PhratchFrameMorph >> stepTime [
	"Every screen update cycle."

	^ 0

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> stopAll [
	"Tell my workPane to stop everything."

	| oldJustSaved |
	oldJustSaved := justSaved.
	workPane stopAll.
	pauseButton off.
	justSaved := oldJustSaved.

]

{ #category : #'file read/write' }
PhratchFrameMorph >> storeProjectInfoOn: aBinaryStream [

	| s |
	projectInfo at: 'thumbnail' put: workPane thumbnailForm.
	projectInfo at: 'keepOnStage' put: ScriptablePhratchMorph keepOnStage.

	s := WriteStream on: (ByteArray new: 100000).
	FuelObjStream new storeObj: projectInfo on: s.

	aBinaryStream uint32: s size.
	aBinaryStream nextPutAll: s contents.


]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> surpriseSpriteMorph [

	| fileName f el m e |
	self world activeHand toolType: nil.
	self paintingInProgress ifTrue: [^ Beeper beep].

	fileName := self nextSurpriseCostumeName.
	fileName ifNil: [
		^ self addAndView: PhratchFrameMorph defaultSprite fullCopy].

	[f := Form fromFileNamed: fileName] ifError: [^ self].
	el := ImageMedia new form: (PhratchFrameMorph scaledFormForPaintEditor: f).
	m := PhratchSpriteMorph new soleCostume: el.

	el mediaName: (m unusedMediaNameFromBaseName: fileName asFileReference  base).
	self addAndView: m.

	e := (workPane extent - m extent) abs // 2.
	m referencePosition: ((e x negated) to: e x) atRandom @ ((e y negated) to: e y) atRandom.

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> toggleErrorCatcher [

	UseErrorCatcher := UseErrorCatcher not.

]

{ #category : #byob }
PhratchFrameMorph >> toggleKeepSpritesOnStage [
	ScriptablePhratchMorph keepOnStage: ScriptablePhratchMorph keepOnStage not.
	
]

{ #category : #byob }
PhratchFrameMorph >> togglePause [
	workPane togglePause.
	workPane isPaused
		ifTrue: [self showPlay]
		ifFalse: [self showPause]

]

{ #category : #byob }
PhratchFrameMorph >> toggleThreadSafeMode [

	EventHatMorph threadSafeMode: EventHatMorph threadSafeMode not.

]

{ #category : #byob }
PhratchFrameMorph >> toggleTurboMode [

	self isTurbo ifTrue: [
		^ PhratchProcess blockHighlightMSecs: 1].
	PhratchProcess blockHighlightMSecs: 0
]

{ #category : #byob }
PhratchFrameMorph >> undoLastDrop [

	scriptsPane currentCategory: 'Scripts'.
	scriptsPane target blocksBin undoLastDrop
]

{ #category : #'tools (no longer used)' }
PhratchFrameMorph >> undoTool [

	| m newOwner oldName |
	self paintingInProgress ifTrue: [^ Beeper beep].
	Clipboard ifNil: [^ Beeper beep].
	self activeHand toolType: nil.
	m := Clipboard copy.
	((m isKindOf: BlockMorph) and: [m isCustomBlock and: [m definition isNil]])
		ifTrue: [^ Beeper beep].
	"Reset clipboard to empty since an undo just happened"
	
	(m isKindOf: BlockMorph) ifTrue: [
		newOwner := viewerPane target.
		newOwner ifNotNil: [m newScriptOwner: newOwner].
		(viewerPane currentCategory = 'variables') ifTrue: [
			"update 'variables' category if it is showing"
			viewerPane currentCategory: 'variables']].

	(m isKindOf: PhratchSpriteMorph) ifTrue: [  "sprite; add to stage"
		m filterReset; show.
		m objName: m objName.
		Clipboard := nil.
		oldName := m objName.
		self addAndView: m.
		m objName: oldName.
		^ self].

	"blocks or anything else: attach to hand"
	self activeHand attachMorph: m.
	Clipboard := nil.

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> uniqueSummaryFileName [

	| baseName fileName n |

	baseName := self projectName.
	baseName size <= 1 ifTrue: [baseName := 'newProject'].
	fileName := baseName, '-summary.txt'.
	n := 1.

	[(FileSystem workingDirectory / fileName) exists ] whileTrue: [
		fileName := baseName, n printString, '-summary.txt'.
		n := n + 1].

	^ fileName


]

{ #category : #byob }
PhratchFrameMorph >> unloadAllUnusedCustomBlocks [

	workPane unloadAllUnusedCustomBlocks
]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> unusedNameStartingWith: prefix [
	"Answer an unused file or directory name in this directory starting with the given prefix and ending with one or more digits."
	"FileDirectory default unusedNameStartingWith: 'tmp'"

	| usedNames i result |
	usedNames := (projectDirectory childNames)asSet.
	i := 0.
	result := prefix, '0'.
	[usedNames includes: result] whileTrue: [
		result := prefix, (i := i + 1) printString].
	^ (projectDirectory / result) fullName

]

{ #category : #watchers }
PhratchFrameMorph >> unusedPositionForWatcher [
	"Return an unused watcher position on the stage."

	| watchers positions rowH x y newX |
	watchers := (watcherPositions values collect: [ :r | r first ]) select: [ :w | w notNil ].
	positions := watchers collect: [ :w | w position ].
	rowH := watchers size > 0
		ifTrue: [ (watchers at: 1) height ]
		ifFalse: [ 25 ].
	x := workPane left + 10.
	y := workPane top + 10.
	[ positions includes: x @ y ]
		whileTrue: [ 
			y := y + rowH.
			y > (workPane bottom - rowH)
				ifTrue: [ 
					"start a new column"
					newX := 0.
					watchers
						do: [ :w | 
							w left < (x + 20)
								ifTrue: [ newX := newX max: w right + 4 ] ].
					newX > (workPane right - 20)
						ifTrue: [ ^ (10 to: 400) atRandom @ (10 to: 330) atRandom ].	"no free location"
					x := newX.
					y := workPane top + 10 ] ].
	^ x @ y
]

{ #category : #'file read/write' }
PhratchFrameMorph >> updateHistoryProjectName: projName op: operation [
	"The given user is about to save or upload a project with the given name. Update the project history. operation is a string specifying the operation."

	| timestamp tab history platform osVersion |
	projectInfo removeKey: 'organization' ifAbsent: [].	"obsolete"
	projectInfo at: 'phratch-version' put: Version.

	timestamp := (Date today printFormat: #(3 2 1 $- 1 1)), ' ', Time now print24.
	tab := String tab.

	history := projectInfo at: 'history' ifAbsent: [''].
	history := history, timestamp, tab.
	history := history, operation, tab, (self nameFromFileName: projName), tab, loginName, tab, author.
	history := history, String cr.
	projectInfo at: 'history' put: history.

	"record other data"
	projectInfo at: 'phratch-version' put: Version.
	projectInfo at: 'language' put: PhratchTranslator currentLanguage.

	platform :=  Smalltalk os name.
	platform ifNil: [platform := 'unknown'].
	'linux' = platform ifTrue: [
		Display extent = (1200@900) ifTrue: [platform := 'XO']].
	projectInfo at: 'platform' put: platform.

	osVersion :=  Smalltalk os version.
	osVersion ifNil: [osVersion := 'unknown'].
	projectInfo at: 'os-version' put: osVersion.

	workPane penTrailsForm
		ifNil: [projectInfo removeKey: 'penTrails' ifAbsent: []]
		ifNotNil: [projectInfo at: 'penTrails' put: workPane penTrailsForm].


]

{ #category : #'file read/write' }
PhratchFrameMorph >> updateLastHistoryEntryIfNeeded [
	"If the the last entry in this project's history is an old-sytle entry (i.e. one that does not include the project name and author) update it."

	| lines lastLine oldAuthor tab s |
	lines := (projectInfo at: 'history' ifAbsent: ['']) lines.
	lines size = 0 ifTrue: [^ self].
	lastLine := lines at: lines size.
	(lastLine includes: Character tab) ifTrue: [^ self].  "last line is already a new-style entry"

	oldAuthor := projectInfo at: 'author' ifAbsent: [''].
	tab := String tab.
	lastLine := lastLine, tab, 'old', tab, projectName, tab, "blank Phratch name" tab, oldAuthor.
	lines at: lines size put: lastLine.

	s := WriteStream on: (String new: 1000).
	lines do: [:entry | s nextPutAll: entry; cr].
	projectInfo at: 'history' put: s contents.

]

{ #category : #other }
PhratchFrameMorph >> updateMediaCategoryFor: anObject [
	"Update the media viewer for the given object's media category. Do nothing if the media category of the given object is not being viewed."

	scriptsPane target = anObject ifTrue: [
		scriptsPane categoryChanged: 'Sounds'.
		scriptsPane categoryChanged: 'Costumes'].
	viewerPane target = anObject ifTrue: [
		viewerPane categoryChanged: 'Sound'].

]

{ #category : #private }
PhratchFrameMorph >> updatePanes [

	menuPanel delete.
	self createMenuPanel.

	toolbarPanel delete.
	self createToolbar.

	viewModeButtonsPanel delete.
	self createViewModeButtonsPanel.

	stageButtonsPanel delete.
	self createStageButtonsPanel.
	titlePane addMorph: stageButtonsPanel.

	scriptsPane tabPane delete.
	scriptsPane createTabPane.

	readoutPane delete.
	self createReadoutPane.

	libraryPane clearLibrary.

	self phratchWatchers do: [:w | w languageChanged].
	self listWatchers do: [:w | w fixLayoutForNewLanguage].

	World startSteppingSubmorphsOf: self.
	self fixLayout.
	scriptsPane fixLayout.
	self updateViewModeButtons.

]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> updatePenPositions [
	"Update the pen positions of my sprites when going between normal and presentation mode."

	| stage |
	stage := self workPane.
	ScriptablePhratchMorph phratchOrigin: stage center.
	stage submorphsDo: [:m | stage updatePenPositionFor: m].

]

{ #category : #private }
PhratchFrameMorph >> updateProjectName [
	"Update the project name display in the Phratch title bar."

	| s |
	projectName ifNil: [ projectName := '' ].
	projectName := self nameFromFileName: projectName.
	projectName := projectName , '.phr'.
	projectTitleMorph contents: projectName.
	s := projectTitleMorph contents size > 0
		ifTrue: [ projectTitleMorph contents , '- PHR' ]
		ifFalse: [ 'PHR ' , Version asString ].
	PhratchPlugin primSetWindowTitle: s.
	self fixLayout
]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> updateToolButtons [
	"Update the highlighting of my tool buttons."

	| toolButtons currentTool |
	Sensor anyButtonPressed ifTrue: [^ self].  "don't update if mouse button pressed"

	toolButtons := toolbarPanel submorphs select: [:m |
		(m isKindOf: ToggleButton) and: [m actionSelector endsWith: 'Tool']].

	currentTool := (World activeHand toolType ifNil: ['none']) asLowercase.
	toolButtons do: [:b |
		(b actionSelector asLowercase = currentTool)
			ifTrue: [b on]
			ifFalse: [b off]].


]

{ #category : #'view mode' }
PhratchFrameMorph >> updateViewModeButtons [

	viewModeButtons do: [:b | b off].
	viewModeButtons do: [:b |
		(b actionSelector = #enterQuarterMode and: [viewMode = #quarter])
			ifTrue: [b on].
		(b actionSelector = #enterNormalMode and: [viewMode = #normal])
			ifTrue: [b on].
		(b actionSelector = #enterPresentationMode and: [viewMode = #presentation])
			ifTrue: [b on]].

]

{ #category : #private }
PhratchFrameMorph >> updateWorkPane [

	self flag:'crappy line to solve Issue 53:	some blocks are executable only once'.	
	World startSteppingSubmorphsOf: self.

]

{ #category : #other }
PhratchFrameMorph >> view: aMorph tab: t category: c [
	"Add given morph to the work pane and view it."

	scriptsPane target: aMorph.
	scriptsPane tabPane currentTab: t.
	viewerPane
		target: aMorph;
		currentCategory: c.

]

{ #category : #accessing }
PhratchFrameMorph >> viewMode [

	^ viewMode

]

{ #category : #accessing }
PhratchFrameMorph >> viewerPane [

	^ viewerPane

]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> wantsDroppedMorph: aMorph event: evt [

	^ (aMorph isKindOf: BlockMorph) or: [
	  	(aMorph isKindOf: ScriptablePhratchMorph) or: [
			(aMorph isKindOf: PhratchCommentMorph)]].

]

{ #category : #watchers }
PhratchFrameMorph >> watcherForBlock: aBlockMorph [
	"Answer a watcher for the given block if there is one currently showing on the stage."

	| pair |
	pair := watcherPositions
		at: {aBlockMorph getAssociatedSprite. aBlockMorph selectorAndArg}
		ifAbsent: [^ nil].

	^ pair first


]

{ #category : #watchers }
PhratchFrameMorph >> watcherShowingFor: sprite selectorAndArg: selectorAndArg [
	"Answer true if a watcher for the given sprite, selector, and argument is currently showing on the stage."

	| sel arg listM pair |
	sel := selectorAndArg first.
	arg := selectorAndArg second.
	#listNamed: = sel ifTrue: [
		listM := sprite listNamed: arg ifNone: [^ false].
		^ listM value owner notNil].

	pair := watcherPositions at: {sprite. selectorAndArg} ifAbsent: [^ false].
	pair first ifNotNil: [
		pair first owner ifNil: [pair at: 1 put: nil]].
	^ pair first notNil

]

{ #category : #accessing }
PhratchFrameMorph >> workPane [

	^ workPane

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> writeMultipleSummaries [
	"Write the summary for all Phratch projects in a given folder."

	| dir |
	dir := PhratchFileChooserDialog chooseFolder: (FileSystem workingDirectory fullName).
	dir = #cancelled ifTrue: [^ self].

	(dir) files do: [:fn |
		(fn basename endsWith: '.scratch') | (fn basename endsWith: '.sb')  | (fn basename endsWith: '.ypr') | (fn basename endsWith: '.phr') ifTrue: [
			self openPhratchProjectNamed: fn.
			"World doOneCycleNoInput."
			self writeSummaryFile: fn]].

]

{ #category : #'file read/write' }
PhratchFrameMorph >> writePhratchProject [
	"Write this Phratch project to the file named projectFile in the project directory. Called by savePhratchProject."

	| oldScriptsTarget oldTab oldViewerCategory oldPosition saveError out |
	workPane submorphsDo: [:m |
		(m isKindOf: WatcherMorph) ifTrue: [m delete]].
	
	self stopAll.
	self world ifNotNil: [self world activeHand newKeyboardFocus: nil].  "terminates active editor"

	"share duplicate sounds and images"
	self canonicalizeSoundsBits: nil saveOriginal: false.
	self canonicalizeImagesQuality: nil saveOriginal: false.

	oldScriptsTarget := scriptsPane target.
	oldTab := scriptsPane tabPane currentTab.
	oldViewerCategory := viewerPane currentCategory.
	scriptsPane target: nil.

	workPane updateSpritesList.
	oldPosition := workPane position.
	workPane delete; position: 0@0.
	self updatePenPositions.

	ScriptablePhratchMorph buildBlockSpecDictionary.



	'saving...' 
		displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((workPane allMorphs) select: [:m| m isKindOf: ScriptablePhratchMorph]) size * 2
		during: [:bar | | i | i := 0.

	workPane allMorphsDo: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [
			i := i + 1. bar value: i.
			(m isKindOf: PhratchSpriteMorph)
				ifTrue: [m cacheRefPos].
			(m blocksBin isKindOf: PhratchSpriteMorph) ifTrue: [  m blocksBin allMorphsDo: [:b |
				(b isKindOf: BlockMorph) ifTrue: [b stop]]].
			m convertStacksToTuples]].

	saveError := nil.
	[ 
		out := FileStream newFileNamed: (self unusedNameStartingWith: 'tmp').
		out
			ifNil: [saveError := 'Folder may be locked or read-only']
			ifNotNil: [
				out binary.
				out nextPutAll: 'PhratchV01' asByteArray. "changed the internal version marker for the byob-prototype -Jens"
				self storeProjectInfoOn: out.
				FuelObjStream new storeObj: workPane on: out.
				out close].
	] ifError: [:err :rcvr |
		out ifNotNil: [
			[	out close.
				projectDirectory deleteFileNamed: out localName.
			] ifError: []]. 
		saveError := err].

	workPane allMorphsDo: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [
			i := i + 1. bar value: i.
			m convertTuplesToStacks]]].

	self addMorph: (workPane position: oldPosition).
	oldScriptsTarget ifNil: [oldScriptsTarget := workPane].
	oldScriptsTarget viewBlocksAndScripts.
	scriptsPane tabPane currentTab: oldTab.
	viewerPane currentCategory: oldViewerCategory.
	self updatePenPositions.
	ScriptablePhratchMorph decodeAsByob. "remember that we save this project in BYOB format"

	saveError
		ifNil: [
			justSaved := true.
			self updateProjectName.
			(projectDirectory / projectName) exists ifTrue:[(projectDirectory / projectName) delete].
			[(projectDirectory / out localName) renameTo: projectName]
				ifError: [^ self inform: 'Save failed' withDetails: 'Is the folder read-only?' localized].
			FilePluginPrims new setMacFileNamed: (projectDirectory / projectName) fullName type: 'STpb' creator: 'PHRA']
		ifNotNil: [
			projectName := ''.
			self inform: 'Save failed' withDetails: saveError].

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> writeSummaryFile [
	"Write a summary of this project to a file."

	self writeSummaryFile: self projectDirectory.

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> writeSummaryFile: fullFile [
	"Write a summary of this project to a file."

	| s sprites f fName fullFileName |
	s := WriteStream on: (String new: 10000).
	fullFileName := fullFile fullName.
	s
		nextPutAll: 'Project: ';
		nextPutAll: self projectName;
		crlf.
	fullFileName size > 0
		ifTrue: [ 
			s
				nextPutAll: 'Location: ';
				nextPutAll: fullFileName;
				crlf ].
	(projectInfo includesKey: 'author')
		ifTrue: [ 
			s
				nextPutAll: 'Author: ';
				nextPutAll: (projectInfo at: 'author');
				crlf ].
	(projectInfo includesKey: 'phratch-version')
		ifTrue: [ 
			s
				nextPutAll: 'Scratch: ';
				nextPutAll: (projectInfo at: 'phratch-version');
				crlf ].
	(projectInfo includesKey: 'comment')
		ifTrue: [ 
			s
				nextPutAll: 'Notes:';
				crlf.
			(projectInfo at: 'comment') lines
				do: [ :l | 
					s
						nextPutAll: '    ';
						nextPutAll: l;
						crlf ].
			s crlf ].
	(projectInfo includesKey: 'history')
		ifTrue: [ 
			s
				nextPutAll: 'History:';
				crlf.
			(projectInfo at: 'history') lines
				do: [ :l | 
					s
						nextPutAll: '    ';
						nextPutAll: l;
						crlf ].
			s crlf ].
	self writeSummaryTotalsOn: s.
	s
		nextPutAll: '--------';
		crlf.
	workPane printSummaryOn: s.
	sprites := workPane submorphs select: [ :m | m isKindOf: PhratchSpriteMorph ].
	sprites
		do: [ :m | 
			s skip: -2.	"remove last crlf"
			s
				nextPutAll: '--------';
				crlf.
			m printSummaryOn: s ].
	s
		nextPutAll: '--------';
		crlf.
	TextEditor new clipboardTextPut: s contents asText.
	fName := fullFileName.
	fullFileName size = 0
		ifTrue: [ 
			fName := PhratchFileChooserDialog
				chooseNewFileDefault: self uniqueSummaryFileName
				title: 'File Name?'
				type: #projectSummary.
			fName = #cancelled
				ifTrue: [ ^ self ] ]
		ifFalse: [ fName := self uniqueSummaryFileName ].
	f := StandardFileStream newPhratchFileNamed: fullFile parent / fName.
	f ifNil: [ ^ self ].
	f nextPutAll: s contents.
	f close
]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> writeSummaryTotalsOn: aStream [
	"Write the totals for this project on the given stream."

	| sprites uniqueCostumes uniqueSounds stackCount |
	sprites := workPane submorphs select: [ :m | m isKindOf: ScriptablePhratchMorph ].
	sprites := sprites asArray copyWith: workPane.
	uniqueCostumes := IdentitySet new: 100.
	uniqueSounds := IdentitySet new: 100.
	stackCount := 0.
	sprites
		do: [ :m | 
			m media
				do: [ :item | 
					item isImage
						ifTrue: [ uniqueCostumes add: item form ].
					item isSound
						ifTrue: [ uniqueSounds add: item sound ] ].
			stackCount := stackCount + m blocksBin submorphCount ].
	aStream
		nextPutAll: 'Totals: ';
		crlf.
	aStream
		nextPutAll: '    Sprites: ';
		nextPutAll: (sprites size - 1) printString;
		crlf.
	aStream
		nextPutAll: '    Stacks: ';
		nextPutAll: stackCount printString;
		crlf.
	aStream
		nextPutAll: '    Unique costumes: ';
		nextPutAll: uniqueCostumes size printString;
		crlf.
	aStream
		nextPutAll: '    Unique sounds: ';
		nextPutAll: uniqueSounds size printString;
		crlf
]

{ #category : #'tools (no longer used)' }
PhratchFrameMorph >> zoomInTool [

	| hand cursorForm offset |
	self paintingInProgress ifTrue: [^ Beeper beep].
	hand := self world activeHand.
	hand toolType: 'ZoomInTool'.

	cursorForm := PhratchFrameMorph skinAt: #zoomInCursor.
	offset := 8@8.

	PhratchFrameMorph isXO ifTrue: [
		cursorForm := cursorForm magnifyBy: 1.5.
		offset := (offset * 1.5) rounded].

	hand showTemporaryCursor: cursorForm hotSpotOffset: offset.

]

{ #category : #'tools (no longer used)' }
PhratchFrameMorph >> zoomOutTool [

	| hand cursorForm offset |
	self paintingInProgress ifTrue: [^ Beeper beep].
	hand := self world activeHand.
	hand toolType: 'ZoomOutTool'.

	cursorForm := PhratchFrameMorph skinAt: #zoomOutCursor.
	offset := 8@8.

	PhratchFrameMorph isXO ifTrue: [
		cursorForm := cursorForm magnifyBy: 1.5.
		offset := (offset * 1.5) rounded].

	hand showTemporaryCursor: cursorForm hotSpotOffset: offset.


]
