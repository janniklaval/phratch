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
		'watcherPositions',
		'shuffledCostumeNames',
		'justSaved',
		'viewModeButtons',
		'viewMode',
		'lastViewMode',
		'viewModeButtonsPanel',
		'toolbarPanel',
		'currentProcessToRun',
		'previousProcessToRun'
	],
	#classVars : [
		'Clipboard',
		'DefaultSprite',
		'PhratchSkin',
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
PhratchFrameMorph class >> categoryButton [

	^ (ColorForm
	extent: 13@17
	depth: 16
	fromArray: #(1600085848 1279995163 456679263 1593835520 1600074823 928454181 520569183 1593835520 1595954504 1227360007 117445910 1593835520 1596202002 1362886656 203019 1593835520 725292045 838926336 665374 520093696 1331316230 33619968 203032 318767104 911346958 33619968 203280 1442840576 856951822 33619968 208656 1526726656 470943237 33619968 203317 285212672 1041040901 33619968 199433 251658240 1128269317 33619968 657452 150994944 1108102405 33619968 51715613 1493172224 772541957 33619968 168495364 1577058304 1597850672 1546256387 320359951 1593835520 1599298854 1161441544 387777610 1593835520 1600082979 958533393 67376991 1593835520 1600085793 1059652612 1342725983 1593835520)
	offset: 0@0)
	colors: {Color gray. Color black. Color black. Color gray. Color gray. Color black. Color black. Color gray. Color gray. Color gray. Color gray. Color gray. Color black. Color black. Color black. Color gray. Color gray. Color gray. Color black. Color gray. Color black. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color black. Color gray. Color gray. Color gray. Color black. Color gray. Color gray. Color black. Color black. Color gray. Color black. Color gray. Color black. Color gray. Color black. Color black. Color gray. Color gray. Color black. Color gray. Color black. Color gray. Color black. Color black. Color black. Color gray. Color black. Color black. Color gray. Color black. Color black. Color black. Color black. Color black. Color black. Color gray. Color black. Color gray. Color black. Color black. Color black. Color black. Color black. Color black. Color black. Color black. Color gray. Color black. Color black. Color black. Color gray. Color black. Color gray. Color black. Color black. Color black. Color black. Color black. Color gray. Color black. Color black. Color gray. Color black. Color gray. Color black. Color black. Color gray. Color transparent. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color gray. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent. Color transparent}
]

{ #category : #'initialize-release' }
PhratchFrameMorph class >> close [
	"Close Phratch window but don't quit Pharo"

	PhratchFrameMorph allInstancesDo: [ :i | i delete ]
]

{ #category : #'initialize-release' }
PhratchFrameMorph class >> closeAndOpen [
	"Close Phratch window but don't quit Pharo"
	PhratchFrameMorph allInstances size > 0 ifTrue:[
		(DialogBoxMorph ask: 'Pay attention, you will loose your current project if not saved.')
			ifFalse: [ ^ self ]].
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

{ #category : #'scratch skin' }
PhratchFrameMorph class >> getFont: aSymbol [
	"Get a font for a given purpose (specified by aSymbol) based on the current font setting."

	|  fonts  |
	fonts := {#Arg				->	1.
#Label			->	1.
#MenuTitle		->	2.
#Button			->	1.
#Category		->	1.
#Tab						->		2.
#CommentBlock				->		1.
#TalkBubble					->		3.
#ToolTip						->		4.
#ReporterToolTip				->		5.
#XYReadout					->		0.
#XYReadoutBold				->		0.
#CostumesPage				->		2.
#SoundsPage					->		2.
#ViewerPage				->		2.
#UpdatingStringField			->		2.
#Watcher					->		1.
#WatcherLarge				->		5.
#PaintUtilityButton			->		1.
#PaintSetRotationCenter		->		2.
#LibraryItemName			->		0.
#LibraryItemInfo			->		-3.
#MediaItemInfo				->		-3.
#DialogBoxTitle				->		5.
#DialogBoxMessage			->		4.
#DialogBoxButton			->		2.
#ProjectNotes				->		1.
#LinkMorphDefault			->		1.
#ShareLink					->		4.
#SoundRecorderButton		->		4.
#SoundRecorderTimer		->	1.
#StringDialogTypeIn			->		3.
#NewVariableDialogBox		->		2.
#AboutPhratch				->		2.
#UploadTagLabel				->		1.
#UploadTag					->		1.
#UploadDialogLabel			->		1.
#UploadDialogContents		->		1.
#UploadDialogComment		->		1.
#FolderShortcut				->		2.
#FileChooserNewFileTitle		->		1.
#FileChooserNewFilename		->		1.
#FileChooserLabel			->		1.
#FileChooserContents			->		3.
#FileChooserComment			->		1.
#FilePickerDirectoryName	->		0.
#FilePickerEntry				->		2.
#FilePickerEntryHighlighted	->		2.
#FrameMorphProjectTitle		->		4.
} asDictionary.

	^ LogicalFont 
		familyName: (StandardFonts defaultFont familyName) 
		pointSize: (StandardFonts defaultFont  pointSize + (fonts at: aSymbol))
]

{ #category : #'class initialization' }
PhratchFrameMorph class >> initialize [
	"self initialize"

	Clipboard := nil.
	WorkpaneExtent := 480@360.


]

{ #category : #'scratch skin' }
PhratchFrameMorph class >> menuCommandOn: aBuilder [

	<worldMenu>  
	(aBuilder item: #Phratch)
		order: 0.1;
		icon: ((ImageMorph withForm: (PhratchFrameMorph skinAt: 'phratchicon')) form magnifyBy: 0.38);
		action:[self closeAndOpen].
]

{ #category : #'initialize-release' }
PhratchFrameMorph class >> offFormBasicColor: aColor [
	|offForm|
	offForm := self categoryButton.
	offForm colors do:[:c | 
		c = Color black ifTrue: [ offForm  replaceColor: c with: aColor	]
	].
	^ offForm.
]

{ #category : #'initialize-release' }
PhratchFrameMorph class >> onFormBasicColor: aColor [
	|onForm|
	onForm := self categoryButton.
	onForm colors do:[:c | 
		c = Color black ifTrue: [ onForm  replaceColor: c with: aColor	].
		c = Color gray ifTrue: [ onForm  replaceColor: c with: aColor lighter	]
	].
	^ onForm.
]

{ #category : #utilities }
PhratchFrameMorph class >> open [
	
	^ self new startup openInWorld
]

{ #category : #'initialize-release' }
PhratchFrameMorph class >> openOneInstance [

	PhratchFrameMorph allInstances size > 1 ifFalse: [ ^ self new startup openInWorld].
]

{ #category : #'initialize-release' }
PhratchFrameMorph class >> overFormBasicColor: aColor [
	|onForm|
	onForm := self categoryButton.
	onForm colors do:[:c | 
		c = Color black ifTrue: [ onForm  replaceColor: c with: aColor	].
		c = Color gray ifTrue: [ onForm  replaceColor: c with: Color gray darker]
	].
	^ onForm.
]

{ #category : #utilities }
PhratchFrameMorph class >> palettePaneColor [

	| c |
	c := Color r: 124 g: 128 b: 131 range: 255.
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
			(FileSystem workingDirectory / PhratchInstaller skinFolder)
]

{ #category : #'scratch skin' }
PhratchFrameMorph class >> readSkinFrom: aDirectory [
	"Read the Forms for my skin from the given directory and store them in myskin dictionary."

	| dict img i fn1 |
	dict := Dictionary new.
	aDirectory exists
		ifTrue: [ aDirectory fileNames
				do: [ :fn | 
					fn1 := fn.
					Cursor read
						showWhile: [ img := [ Form fromFileNamed: (aDirectory / fn) fullName ]
								ifError: [ nil ] ].
					img
						ifNotNil: [ i := fn findLast: [ :c | c = $. ].
							i = 0
								ifFalse: [ fn1 := fn copyFrom: 1 to: i - 1 ].
							dict at: fn1 asSymbol put: img ] ] ].
	PhratchSkin := dict.
	img := PhratchSkin at: #scriptsPaneTexture ifAbsent: [ nil ].
	(img notNil and: [ img depth ~= 32 ])
		ifTrue: [ PhratchSkin at: #scriptsPaneTexture put: (img asFormOfDepth: 32) ].
	^ PhratchSkin
]

{ #category : #'initialize-release' }
PhratchFrameMorph class >> rebuildUI [
	"Close Phratch window but don't quit Pharo"

	PhratchFrameMorph allInstancesDo: [ :i | i rebuildUIForNewLanguage]
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
	^ aForm magnifyBy: scale

]

{ #category : #utilities }
PhratchFrameMorph class >> scriptsPaneColor [

	| c |
	c := Color r: 124 g: 128 b: 131 range: 255.
	^ c

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
	"Answer the skin image with the given name."

	^ self skin at: aSymbolOrString asSymbol ifAbsent: aBlock

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

	buttonSpecs := #(
		"name		tool tip				selector"
		(language	'Set language'		languageMenu:)
		(save		'Save this project'	#savePhratchProjectNoDialog)
"		(share		'Share this project'	share)"
	).

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
	menu := MenuMorph new defaultTarget: self.
	
	(PhratchSpriteMorph withAllSubclasses size = 1 and:[PhratchInstaller declaredSprite isEmpty]) ifTrue:[^ self paintSpriteMorph].
	
	PhratchSpriteMorph withAllSubclassesDo: [ :e |
		menu add: ('create ',e name) localized value: e.
	].

	PhratchInstaller declaredSprite do:[:e |
		menu add: ('create ',e name) localized value: e.
	].
	
	m := (menu
		localize;
		invokeModal; yourself) selectedValue.

	m ifNotNil:[
		|obj|
		obj := m new.
		obj isScriptable ifTrue:[newSprite := obj]
			ifFalse:[newSprite := PhratchSpriteMorph new.
				newSprite phratchModel: obj.
				newSprite objName: m asString].
	
		frame := self ownerOrYourselfThatIsAPhratchFrameMorph.
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
	self paintingInProgress ifTrue: [^PhratchError error: 'beep'].

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

{ #category : #'menu/button actions' }
PhratchFrameMorph >> addonMenu: aMenuTitleMorph [
	| menu |
	menu := MenuMorph new defaultTarget: self.
	
	[MetaRepoSearcher listOfProjects do:[:e |
		menu add: (self isLoaded: e value) checkBoxString, e key target: MetaRepoSearcher selector: #loadProject: argument: e value.
	] ]on: Error do: [ PhratchError errorWithDialog: 'You need an Internet connection to load AddOns.'].

	menu popUpInWorld 
]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> allProjectMedia [
	"Answer a collection of all media items in the current project."

	| result |
	result := OrderedCollection new.
	(workPane submorphs copyWith: workPane) do: [:m |
		(m isScriptablePhratchMorph) ifTrue: [
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
	"answer a form consisting of a checkbox and a label - used for the EDIT menu"

	| box label pic line cnts |
	pic := aBool
		ifTrue: [ PhratchFrameMorph skinAt: #watcherButtonPressed ]
		ifFalse: [ PhratchFrameMorph skinAt: #watcherButton ].
	box := ImageMorph new form: pic.
	cnts := ' ' , aString localized.
	label := StringMorph contents: cnts font: StandardFonts defaultFont.
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

	<phratchMenu: 'Clear all Variables' category: 'edit' position: 6 sub:2 shift: false>
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

{ #category : #'initialize-release' }
PhratchFrameMorph >> close [
	<phratchMenu: 'Close' category: 'file' position: 15 sub:6 shift: true>
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
		(m isDialogBoxMorph) ifTrue: [m cancelled; delete]].

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

	(Smalltalk at: #PhratchCategorySound ifPresent:[mList := (Smalltalk at: #PhratchSoundRecorderDialogMorph) allInstances select: [:m | m isInWorld].
	mList size > 0 ifTrue: [
		(DialogBoxMorph ask: 'Close sound recorder?') ifFalse: [^ false].
		mList do: [:m | m cancelled; delete]]]).

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
	<phratchMenu: 'Compress Images' category: 'edit' position: 4 sub:2 shift: false>
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

{ #category : #'tools (no longer used)' }
PhratchFrameMorph >> copyTool [

	| hand cursorForm offset |
	self paintingInProgress ifTrue: [^ PhratchError error: 'beep'.].
	hand := self world activeHand.
	hand toolType: 'CopyTool'.

	cursorForm := PhratchFrameMorph skinAt: #copyCursor.
	offset := 8@13.

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
	
	topPane hasDropShadow: false.
	viewerPane hasDropShadow: false.
	scriptsPane hasDropShadow: false.
	stageFrame hasDropShadow: false.
	titlePane hasDropShadow: false.
	workPane hasDropShadow: false.
	libraryPane hasDropShadow: false.

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
		cellPositioning: #center;
		color: Color transparent;
		centering: #center;
		inset: 0;
		height: 10;
		yourself.	"will grow as needed"

	self addShortcutButtonsTo: menuPanel.

	"menuSpecs defines the menus"
	menuSpecs := #(
		"name			selector"
		(File			fileMenu:)
		(Edit			editMenu:)
		(AddOns		addonMenu:)
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
			helpText: (spec at: 3) localized.

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
			helpText: (spec at: 3) localized.
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
			helpText: (spec at: 3) localized.
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
	self paintingInProgress ifTrue: [^ PhratchError error: 'beep'.].
	hand := self world activeHand.
	hand toolType: 'CutTool'.

	cursorForm := PhratchFrameMorph skinAt: #cutCursor.
	offset := 8@8.

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

	aSprite lists do: [ :m | m delete ].
	workPane
		submorphsDo: [ :m | 
			(m isWatcherMorph)
				ifTrue: [ 
					m target = aSprite
						ifTrue: [ m delete ] ] ].
	watcherPositions
		keysDo: [ :k | 
			(k at: 1) = aSprite
				ifTrue: [ watcherPositions removeKey: k ] ]
]

{ #category : #watchers }
PhratchFrameMorph >> deleteWatchersForVar: varName ofSprite: aSprite [
	"The given variable is being deleted. Delete all watchers associated with it."

	workPane submorphsDo: [:m |
		(m isWatcherMorph) ifTrue: [
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

	| menu previousSC |

	menu := MenuMorph new defaultTarget: self.
	previousSC := nil.
	(self menuPragmasFor: 'edit') do:[:e |
		(previousSC notNil and: [previousSC ~~( e arguments at: 4)]) ifTrue:[menu addLine ].
		(e arguments at: 5) ifFalse:[
			menu add: (e arguments at: 1) localized selector: e method selector
		]
		ifTrue: [ 
			Sensor shiftPressed ifTrue: [
				menu add: (e arguments at: 1) localized selector: e method selector.
			] 
		].
		previousSC := e arguments at: 4.
	].

	menu addLine.

	menu add: ScriptablePhratchMorph keepOnStage not checkBoxString, 'Allow Sprites offstage' localized
			selector: #toggleKeepSpritesOnStage.

	menu add: EventHatMorph threadSafeMode checkBoxString, 'Thread safe scripts' localized
			selector: #toggleThreadSafeMode.
			
	menu add: PhratchProcess traceFlag checkBoxString, 'Step by step' localized
			selector: #toggleStepByStep.
	
	Sensor shiftPressed ifTrue: [	self isDevelopmentMode ifTrue: [
			menu addLine.
		fillScreenFlag
			ifTrue: [menu add: 'turn fill screen off' localized selector: #fillScreenOff]
			ifFalse: [menu add: 'turn fill screen on' localized selector: #fillScreenOn].		
		]].
 
	menu localize.
	"menu invokeModalAt: aMenuTitleMorph bottomLeft + (0@10)."
	menu popUpInWorld 
]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> editNotes [
	<phratchMenu: 'Project notes' category: 'file' position: 9 sub:3 shift: false>
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
	
	(viewMode = #presentation) ifTrue: [^ self].

	lastViewMode := viewMode.
	viewMode := #presentation.

	self closeDialogBoxes.
	workPane isQuarterSize: false.
	presenter := PhratchPresenterMorph new frame: self.

	self delete.

	Display fillBlack.
	Display fullscreenMode: true.
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

{ #category : #'menu/button actions' }
PhratchFrameMorph >> enterUserMode [
	"Start filling the entire screen and being sticky. Also configure a few other things for the end user such as turning off halos and the control menu (noviceMode) and making sure that error catching is enabled."

	<phratchMenu: 'Enter user mode' category: 'file' position: 13 sub:5 shift: true>

	fillScreenFlag := true.
	TaskbarMorph allInstances do: [: e | e hide ].
	
	self position: 0@0.
	self isSticky: true.
	self extent: Display extent.
	self comeToFront.
	ScriptablePhratchMorph noviceMode: true.
	Paragraph insertionPointColor: (Color r: 0.353 g: 0.607 b: 0.788).
	self updateProjectName.
	self fixLayout.
	self step.

]

{ #category : #'view mode' }
PhratchFrameMorph >> exitPresentationMode [
	"Exit presentation mode."

	TaskbarMorph allInstances do: [: e | e show ].

		Display fullscreenMode: false.
		World restoreDisplay.


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

	<phratchMenu: 'Export project' category: 'file' position: 8 sub:2 shift: false>
	scriptsPane target exportObject.

]

{ #category : #geometry }
PhratchFrameMorph >> extent: aPoint [

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

Note: this is a compatibility force method"

	| s version proj |

	FuelObjStream initialize. "just to make sure this works in filed-in changesets, -Jens"

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
			ifTrue: [self error: 'Project created by a later version of Scratch']
			ifFalse: [self error: 'Problem reading project.'].
		^ nil].

	'initializing...' 
		displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((proj allMorphs) select: [:m| m isScriptablePhratchMorph]) size * 2
		during: [:bar | | i | i := 0.
].

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

	'initializing...' 
		displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((proj allMorphs) select: [:m| m isScriptablePhratchMorph]) size * 2
		during: [:bar | | i | i := 0.
].

	^ proj

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> fileMenu: aMenuTitleMorph [
	| menu previousSC|
	
	menu := MenuMorph new defaultTarget: self.
	previousSC := nil.
	(self menuPragmasFor: 'file') do:[:e |
		(previousSC notNil and: [previousSC ~~( e arguments at: 4)]) ifTrue:[menu addLine ].
		(e arguments at: 5) ifFalse:[
			menu add: (e arguments at: 1) localized selector: e method selector
		]
		ifTrue: [ 
			Sensor shiftPressed ifTrue: [
				menu add: (e arguments at: 1) localized selector: e method selector.
			] 
		].
		previousSC := e arguments at: 4.
	].

	menu localize.
	"menu popUpAt: aMenuTitleMorph bottomLeft + (0 @ 10) inWorld: World"
	menu popUpInWorld 
]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> fillScreenOff [
	"Stop filling the entire screen. Useful during development."

	<phratchMenu: 'Exit user mode' category: 'file' position: 12 sub:5 shift: true>
	Display fullscreenMode: false.
	World restoreDisplay.

	fillScreenFlag := false.
	TaskbarMorph allInstances do: [: e | e show ].
	
	self isSticky: false.
	self extent: 1000@600"Display extent - 50".
	ScriptablePhratchMorph noviceMode: false.
	Paragraph insertionPointColor: (Color r: 0.4 g: 1.0 b: 0.0).
	self fixLayout.

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> fillScreenOn [
	"Start filling the entire screen and being sticky. Also configure a few other things for the end user such as turning off halos and the control menu (noviceMode) and making sure that error catching is enabled."

	fillScreenFlag := true.
	TaskbarMorph allInstances do: [: e | e hide ].
	
	self position: 0@0.
	self isSticky: true.
	self extent: Display extent.
	self comeToFront.
	ScriptablePhratchMorph noviceMode: false.
	Paragraph insertionPointColor: (Color r: 0.353 g: 0.607 b: 0.788).
	self updateProjectName.
	self fixLayout.
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

	(libraryPane bounds containsRect: damageR) ifTrue: [
		libraryPane fullDrawOn: aCanvas.
		readoutPane fullDrawOn: aCanvas.
		^ self].

	(readoutPane bounds containsRect: damageR) ifTrue: [
		readoutPane fullDrawOn: aCanvas.
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
	| menu previousSC |
	menu := MenuMorph new defaultTarget: self.
	
		previousSC := nil.
	(self menuPragmasFor: 'help') do:[:e |
		(previousSC notNil and: [previousSC ~~( e arguments at: 4)]) ifTrue:[menu addLine ].
		(e arguments at: 5) ifFalse:[
			menu add: (e arguments at: 1) localized selector: e method selector
		]
		ifTrue: [ 
			Sensor shiftPressed ifTrue: [
				menu add: (e arguments at: 1) localized selector: e method selector.
			] 
		].
		previousSC := e arguments at: 4.
	].

	
	menu add: 'Phratch Website' localized target: PhratchHelp selector: #launchWebsite.
	menu addLine.
	menu add: 'Scratch Help Page' localized target: PhratchHelp selector: #launchHelpPage.
	menu add: 'Generated Block Doc' localized target: PhratchHelp selector: #launchBlockDoc.
	menu add: 'Help Screens' localized target: PhratchHelp selector: #launchAllHelpScreens.
	menu addLine.
	menu add: 'BYOB Reference Manual' localized target: PhratchHelp selector: #openBYOBManual.
	menu add: 'Panther Tutorials' localized target: PhratchHelp selector: #openPantherTutorials.
	menu addLine.
	menu add: 'About Phratch' localized target: PhratchHelp selector: #aboutPhratch.
	menu localize.
	"menu popUpAt: aMenuTitleMorph bottomLeft + (0 @ 10) inWorld: World"
	menu popUpInWorld 
]

{ #category : #'file read/write' }
PhratchFrameMorph >> importPhratchProject [
	"Allow the user to select a project to open, then merge that project's sprites with the
current project."
	<phratchMenu: 'Import project' category: 'file' position: 7 sub:2 shift: false>
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
		(m isWatcherMorph) ifTrue: [m mapReceiver: importedStage to: workPane].
		(m isScriptablePhratchMorph) ifTrue: [
			m blocksBin submorphs do: [:stack |
				(stack isBlockMorph) ifTrue: [
					stack blockSequence do: [:b | b mapReceiver: importedStage to: workPane]]]]].

	"add global variables from importated stage to my stage"
	importedStage varNames do: [:v |
		workPane addVariable: v value: (importedStage getVar: v)].
	importedStage varNames do: [:v | workPane addVariable: v].

	"add imported stage scripts"
	importedStage blocksBin submorphs do: [:stack |
		(stack isBlockMorph) ifTrue: [workPane addStack: stack fullCopy]].

	"add imported background costumes and scripts to my stage, filtering out default items"
	defaultForm := workPane defaultImageMedia form hibernateForPhratch.
	(Smalltalk at: #PhratchCategorySound ifPresent:[defaultSound := (Smalltalk at: #SoundMedia) new sound]).
	importedStage media do: [:media |
		(media isImage and: [media form hibernate bits ~= defaultForm bits])
			ifTrue: [workPane addMediaItem: media].
		(Smalltalk at: #PhratchCategorySound ifPresent:[(media isSound and: [media sound samples ~= defaultSound samples])
			ifTrue: [workPane addMediaItem: media]])
	].

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
		(m isPhratchSpriteMorph) ifTrue: [
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
	self hasDropShadow: false.
	fillScreenFlag := false.
	paintingInProgress := false.
	projectInfo := Dictionary new.
	watcherPositions := Dictionary new.
	justSaved := false.
	blockEditors := Set new.
	author := ''.
	viewMode := #normal.

	PhratchInstaller selectFontForLocale.
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
	(Smalltalk at: #PhratchCategorySound ifPresent:[newWorkpane midiPortNum: workPane midiPortNum.
	workPane closeMIDI]).

	workPane owner replaceSubmorph: workPane by: newWorkpane.
	workPane := newWorkpane.

"	self fixByteReversedSounds. "

	"fix sprite positions (backward compatibility)"
	workPane submorphs do: [:m |
		(m isWatcherMorph) ifTrue: [m convertFromOldWatcher].
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
			(m isScriptablePhratchMorph) ifTrue: [workPane sprites addLast: m]]].

	scriptsPane tabPane currentTab: 'Scripts'.
	libraryPane clearLibrary.
	
	workPane clearPenTrails.
	PhratchPrompterMorph clearLastAnswer.

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

{ #category : #'menu/button actions' }
PhratchFrameMorph >> isLoaded: value [

	Smalltalk at: value asSymbol ifAbsent:[^false].
	^true
]

{ #category : #testing }
PhratchFrameMorph >> isPhratchFrameMorph [

	^ true
]

{ #category : #'event handling' }
PhratchFrameMorph >> keyStroke: evt [
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

{ #category : #accessing }
PhratchFrameMorph >> libraryPane [

	^ libraryPane

]

{ #category : #watchers }
PhratchFrameMorph >> listWatchers [
	"Answer a collection of all the list watchers in the work pane."

	^ self workPane submorphs select: [:m | m isPhratchListMorph]

]

{ #category : #intialization }
PhratchFrameMorph >> makeXYReadout [
	"Make and answer an x-y readout."

	| normalFont boldFont panel spaceWidth labelX readoutX labelY readoutY |
	normalFont := PhratchFrameMorph getFont: #XYReadout.
	boldFont := PhratchFrameMorph getFont: #XYReadoutBold.
	PhratchTranslator renderScale ~= 1
		ifTrue: [ 
			normalFont := StrikeFont
				osFontName: normalFont familyName
				size: normalFont pointSize / PhratchTranslator renderScale asFloat.
			boldFont := StrikeFont osFontName: boldFont name size: boldFont pointSize / PhratchTranslator renderScale asFloat ].
	panel := Morph new color: (Color r: 0.753 g: 0.764 b: 0.776).
	labelX := StringMorph new
				font: normalFont;
				contents: 'x:' .
	readoutX := PhratchUpdatingStringMorph new
		target: self;
		getSelector: #mouseX;
		font: boldFont;
		stepTime: 150;
		growable: false;
		yourself.
	readoutX width: (readoutX stringWidth: '-1000') asInteger.
	labelY :=  labelX fullCopy contents: 'y:' .
	readoutY := readoutX fullCopy getSelector: #mouseY.
	spaceWidth := ((readoutX stringWidth: ' ') * 0.8) asInteger.
	 
	panel addMorph: (labelX position: 0 @ 0).
	panel addMorph: (readoutX position: labelX topRight + (spaceWidth @ 0)) .
	 
	panel addMorph: (labelY position: (readoutX stringWidth: 'x: -1000  ') asInteger @ labelX top).
	panel addMorph: (readoutY position: labelY topRight + (spaceWidth @ 0)) .
	 panel extent: (readoutX stringWidth: 'x: -1000 y: -1000 ') asInteger@ labelY bottom.
	^ panel
]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> menuPragmasFor: stringMenuCat [
	"To obtain all the items of the menu, execute:
	SystemNavigation default allCallsOn: #phratchItem:kind:category:defaultValues:subCategory:special:
	"
	| allPragmas |
	
	allPragmas := Pragma allNamed: #phratchMenu:category:position:sub:shift: in:  PhratchFrameMorph  sortedByArgument: 3.
	^(allPragmas select:[:pragma | (pragma arguments at: 2) = stringMenuCat])
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

	^ workPane mouseX asInteger

]

{ #category : #other }
PhratchFrameMorph >> mouseY [

	^ workPane mouseY asInteger

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

{ #category : #'menu/button actions' }
PhratchFrameMorph >> newPhratchProject [
	"Make a new, blank Phratch project."

	<phratchMenu: 'New' category: 'file' position: 1 sub:1 shift: false>
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

	self initializeWatcherPositions.
	blockEditors := Set new.
	justSaved := true.

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

{ #category : #'file read/write' }
PhratchFrameMorph >> openPhratchProject [
	"Allow the user to select a project to open, then open that project."

	<phratchMenu: 'Open' category: 'file' position: 2 sub:1 shift: false>
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
	self extent: Display extent.
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

	^ self workPane submorphs select: [:m | m isScriptablePhratchMorph]

]

{ #category : #watchers }
PhratchFrameMorph >> phratchWatchers [
	"Answer a collection of all the phratch watchers in the work pane."

	^ self workPane submorphs select: [:m | m isWatcherMorph]

]

{ #category : #'falta adaptar' }
PhratchFrameMorph >> presentHelpScreen: aStringOrNil [
	"Look for a help screen with the given name in the 'Help' folder. If found, present it to the user."

	| helpDir subDir fileNames helpFileName helpForm |
	aStringOrNil ifNil: [^ PhratchError error: 'beep'.].

	(FileSystem workingDirectory fileSystem exists: 'Help') ifFalse: [^ PhratchError error: 'beep'.].  "no help folder"
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
	helpFileName ifNil: [^ PhratchError error: 'beep'.].

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

	(el isArray) ifTrue: [self printTupleList: el on: s. ^ self].
	(el isSymbol) ifTrue: [s nextPutAll: el. ^ self].
	(el isString) ifTrue: [s nextPut: $". s nextPutAll: el. s nextPut: $". ^ self].
	(el isScriptablePhratchMorph) ifTrue: [s nextPutAll: el objName. ^ self].
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

{ #category : #'view mode' }
PhratchFrameMorph >> projectComment: aString [

	projectInfo at: 'comment' put: aString asString.

]

{ #category : #accessing }
PhratchFrameMorph >> projectCommentOrTemplate [

	| s |
	s := projectInfo at: 'comment' ifAbsent: [''].
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
		(workPane submorphs first isPhratchSpriteMorph) ifFalse: [^ false]].

	allScriptables := workPane submorphs copyWith: workPane.
	defaultCostumes := Set
		with: ScriptablePhratchMorph defaultBackgroundForm.
	defaultSnds := Set new.
	Smalltalk at: #PhratchCategorySound ifPresent:[defaultSnds := Set
		with: ScriptablePhratchMorph popSound
		with: ScriptablePhratchMorph meowSound].

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

	<phratchMenu: 'Quit' category: 'file' position: 16 sub:6 shift: false>
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
		from: 0 to: ((workPane allMorphs) select: [:m| m isScriptablePhratchMorph]) size * 3
		during: [:bar |
			self updatePanes.
			self
				view: scriptsPane target
				tab: scriptsPane tabPane currentTab
				category: viewerPane currentCategory].

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> saveImageForEndUser [

	<phratchMenu: 'Save image in user mode' category: 'file' position: 14 sub:5 shift: true>
	(self confirm: '
Close non-Phratch windows and save this
image in end-user (fillScreen) mode?') ifFalse: [^ self].


	self setLanguage: 'en'.

	self enterNormalMode.
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

{ #category : #'file read/write' }
PhratchFrameMorph >> savePhratchProject [

	<phratchMenu: 'Save as' category: 'file' position: 5 sub:1 shift: false>
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

	projectDirectory := fName asFileReference parent.
	fName := (self nameFromFileName: fName), '.phr'.
	projectName :=fName asFileReference basename.

	projectInfo at: 'author' put: author.
	self updateHistoryProjectName: projectName op: 'save'.

	self writePhratchProject.

]

{ #category : #'file read/write' }
PhratchFrameMorph >> savePhratchProjectNoDialog [

	<phratchMenu: 'Save' category: 'file' position: 4 sub:1 shift: false>
	|  dir |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].

	projectName ifNil: [projectName := ''].
	self nameFromFileName: projectName.

	"Do we need to ask for a filename or directory?"
	dir := PhratchFileChooserDialog getLastFolderForType: #project.
	"(fName size = 0 | (dir asFileReference / fName , 'phr') exists not) ifTrue: [^ self savePhratchProject]."
	PhratchFileChooserDialog lastFolderIsSampleProjectsFolder ifTrue:  [^ self savePhratchProject].
	projectDirectory := dir.

	self updateLastHistoryEntryIfNeeded.
	self updateHistoryProjectName: projectName op: 'save'.
	self writePhratchProject.

]

{ #category : #'menu/button actions' }
PhratchFrameMorph >> saveState [
	"Quit from Phratch. Ask the user if they want to save, first."
	<phratchMenu: 'Save state' category: 'file' position: 6 sub:1 shift: false>
	Smalltalk snapshot: true andQuit: false.

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

"			importedProject customBlocks ifNotNil: [
				importedProject customBlocks do: [:eachDef |
					workPane sprites, {workPane} do: [:obj |
						obj
							updateCustomBlockDefinitionId: eachDef id with: eachDef;
							updateLocalId: eachDef id withSpec: eachDef userSpec]]].
"
			importedProject submorphs do: [:m |
				(m isPhratchSpriteMorph) ifTrue: [DefaultSprite := m].
				^ self]]].

	"if default image exists, use the image and add 'pop' sound"
	#(gif png jpg bmp) do: [:e |
		fName := 'default.', e.
		(d / fName) asFileReference exists ifTrue: [
			DefaultSprite := PhratchSpriteMorph new
				importMedia: (d / fName) fullName;
				yourself.
			(Smalltalk at: #PhratchCategorySound ifPresent:[
				DefaultSprite addMediaItem: ((Smalltalk at: #SoundMedia) new
					mediaName: 'pop' localized;
					sound: PhratchSpriteMorph popSound;
					yourself)]).
			^ self]].

]

{ #category : #private }
PhratchFrameMorph >> setLanguage: aString [
	"Set my language and update my blocks."

	| tempJustSaved |

	self closeDialogBoxes.

	'updating...' 
		displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((workPane allMorphs) select: [:m| m isScriptablePhratchMorph]) size * 2
		during: [:bar |

			tempJustSaved := justSaved.

			PhratchTranslator setLanguage: (PhratchTranslator isoCodeForName: aString).
			PhratchInstaller selectFontForLocale.
			viewerPane rebuildCategorySelectors.

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
	self flag: 'The following line allows the retrocompatibility with Scratch'.
	workPane broadcastEventNamed: 'Scratch-StartClicked' with: 0.
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

	<phratchMenu: 'Settings' category: 'edit' position: 7 sub:3 shift: false>
	SettingBrowser new changePackageSet: {RPackageOrganizer default packageNamed: 'Phratch' . RPackageOrganizer default packageNamed: 'Network-Kernel' . RPackageOrganizer default packageNamed: 'Graphics-Fonts' .RPackageOrganizer default packageNamed: 'FreeType' }; open
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

	PhratchTranslator importLanguagesList.
	
	ScriptablePhratchMorph keepOnStage: true.
	EventHatMorph threadSafeMode: false.

	BlockEditorFrameMorph resetDimensions.
	ElementsEditorFrameMorph resetDimensions.
	
	(Smalltalk at: #DebuggerFrameMorph) resetDimensions.

	self updateProjectName.
	
	author := ''.
	justSaved := true.

	viewerPane currentCategory: 'motion'.
	
	self setDefaultSprite.
	self newPhratchProject.
]

{ #category : #stepping }
PhratchFrameMorph >> step [
	"Run each process until it gives up control, then filter out any processes that have terminated."


	| screenExtent oldJustSaved |

	fillScreenFlag ifTrue: [
		screenExtent := Display extent.
		(self extent = screenExtent) ifFalse: [
			oldJustSaved := justSaved.
			self position: 0@0.
			self extent: screenExtent.
			scriptsPane currentCategory: scriptsPane currentCategory.
			justSaved := oldJustSaved.
			^ self]]. "simplify at the moment"

	workPane ifNotNil: [
		ScriptablePhratchMorph phratchOrigin: workPane center.
		viewerPane target isNil 
			ifTrue: [workPane viewBlocksAndScripts]
			ifFalse: [viewerPane target isInWorld ifFalse: [workPane viewBlocksAndScriptsQuickly]]].

	paintingInProgress ifTrue: [^ self].

	"self updateToolButtons."
	"self processKeyboardEvents. "
	
	workPane stepProcesses.
	currentProcessToRun := workPane processesToRun size.
	
	currentProcessToRun = previousProcessToRun ifFalse:[
	currentProcessToRun > 0
		ifTrue: [flagButton on]
		ifFalse: [flagButton off. self showPause].
	].		
	previousProcessToRun := workPane processesToRun size.

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
	self paintingInProgress ifTrue: [PhratchError error: 'beep'.^ PhratchError error: 'beep'.].

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
PhratchFrameMorph >> toggleStepByStep [

	PhratchProcess toggleStepByStep
]

{ #category : #byob }
PhratchFrameMorph >> toggleThreadSafeMode [

	EventHatMorph threadSafeMode: EventHatMorph threadSafeMode not.

]

{ #category : #byob }
PhratchFrameMorph >> undoLastDrop [

	<phratchMenu: 'Undo last drop' category: 'edit' position: 2 sub:1 shift: false>
	scriptsPane currentCategory: 'Scripts'.
	scriptsPane target blocksBin undoLastDrop
]

{ #category : #'tools (no longer used)' }
PhratchFrameMorph >> undoTool [

	<phratchMenu: 'Undelete' category: 'edit' position: 1 sub:1 shift: false>
	| m newOwner oldName |
	self paintingInProgress ifTrue: [^ PhratchError error: 'beep'.].
	Clipboard ifNil: [^ PhratchError error: 'beep'.].
	self activeHand toolType: nil.
	m := Clipboard copy.
	((m isBlockMorph) and: [m isCustomBlock and: [m definition isNil]])
		ifTrue: [^ PhratchError error: 'beep'.].
	"Reset clipboard to empty since an undo just happened"
	
	(m isBlockMorph) ifTrue: [
		newOwner := viewerPane target.
		newOwner ifNotNil: [m newScriptOwner: newOwner].
		(viewerPane currentCategory = 'variables') ifTrue: [
			"update 'variables' category if it is showing"
			viewerPane currentCategory: 'variables']].

	(m isPhratchSpriteMorph) ifTrue: [  "sprite; add to stage"
		"m filterReset; show."
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
	projectInfo removeKey: 'organization' ifAbsent: [].
	projectInfo at: 'phratch-version' put: PhratchInstaller version.

	timestamp := (Date today printFormat: #(3 2 1 $- 1 1)), ' ', Time now print24.
	tab := String tab.

	history := projectInfo at: 'history' ifAbsent: [''].
	history := history, timestamp, tab.
	history := history, operation, tab, (self nameFromFileName: projName), tab, author.
	history := history, String cr.
	projectInfo at: 'history' put: history.

	"record other data"
	projectInfo at: 'phratch-version' put: PhratchInstaller version.
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

{ #category : #stepping }
PhratchFrameMorph >> updateMediaCategoryFor: anObject [
	"Update the media viewer for the given object's media category. Do nothing if the media category of the given object is not being viewed."

	scriptsPane target = anObject ifTrue: [
		(Smalltalk at: #PhratchCategorySound ifPresent:[scriptsPane categoryChanged: 'Sounds']).
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

	
	PhratchScriptsMorph allInstances do:[:sm |
		(sm submorphs select:[:m | m isCommandBlockMorph])  
			do:[:i | i changeLanguageString.
				].
		(sm submorphs select:[:m | m isHatBlockMorph])  
			do:[:i | 
				i changeLanguageString
			].
	].
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

	projectName ifNil: [ projectName := '' ].
	projectName := self nameFromFileName: projectName.
	projectName := projectName , '.phr'.
	projectTitleMorph contents: projectName.
	projectTitleMorph contents size > 0
		ifTrue: [ projectTitleMorph contents , '- PHR' ]
		ifFalse: [ 'PHR ' , PhratchInstaller version].
	self updateWindowsName: projectName.
	self fixLayout
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
PhratchFrameMorph >> updateWindowsName: nameOfProject [
	"Update the project name display in the Phratch title bar."

	DisplayScreen hostWindowTitle: ('phratch - ', nameOfProject).
	
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

	^ (aMorph isBlockMorph) or: [
	  	(aMorph isScriptablePhratchMorph) or: [
			(aMorph isPhratchCommentMorph)]].

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

	<phratchMenu: 'Write multiple project summaries' category: 'file' position: 11 sub:4 shift: true>
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

	|     saveError out |
	workPane submorphsDo: [:m |
		(m isWatcherMorph) ifTrue: [m delete]].
	
	self stopAll.
	self world ifNotNil: [self world activeHand newKeyboardFocus: nil].  "terminates active editor"

	"share duplicate sounds and images"
	self canonicalizeSoundsBits: nil saveOriginal: false.
	self canonicalizeImagesQuality: nil saveOriginal: false.

"	oldScriptsTarget := scriptsPane target.
	oldTab := scriptsPane tabPane currentTab.
	oldViewerCategory := viewerPane currentCategory.
	scriptsPane target: nil."

	workPane updateSpritesList.
"	oldPosition := workPane position.
	workPane delete; position: 0@0.
"	self updatePenPositions.


	'saving...' 
		displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((workPane allMorphs) select: [:m| m isScriptablePhratchMorph]) size * 2
		during: [:bar | | i | i := 0.

	workPane allMorphsDo: [:m |
		(m isScriptablePhratchMorph) ifTrue: [
			i := i + 1. bar value: i.
			(m isPhratchSpriteMorph)
				ifTrue: [m cacheRefPos].
			(m blocksBin isPhratchSpriteMorph) ifTrue: [  m blocksBin allMorphsDo: [:b |
				(b isBlockMorph) ifTrue: [b stop]]].
			]].

	saveError := nil.
	[ 
		out := FileStream newFileNamed: (self unusedNameStartingWith: 'tmp').
		out
			ifNil: [saveError := 'Folder may be locked or read-only']
			ifNotNil: [
				out binary.
				out nextPutAll: 'PhratchV01' asByteArray. "changed the internal version marker for the prototype -Jens"
				self storeProjectInfoOn: out.
				FuelObjStream new storeObj: workPane on: out.
				out close].
	] ifError: [:err :rcvr |
		out ifNotNil: [
			[	out close.
				projectDirectory deleteFileNamed: out localName.
			] ifError: []]. 
		saveError := err].
].

	"self addMorph: (workPane position: oldPosition).
	oldScriptsTarget ifNil: [oldScriptsTarget := workPane].
	oldScriptsTarget viewBlocksAndScripts.
	scriptsPane tabPane currentTab: oldTab.
	viewerPane currentCategory: oldViewerCategory."
	self updatePenPositions.

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

	<phratchMenu: 'Write project summary' category: 'file' position: 10 sub:4 shift: true>
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
	sprites := workPane submorphs select: [ :m | m isPhratchSpriteMorph ].
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
	sprites := workPane submorphs select: [ :m | m isScriptablePhratchMorph ].
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
	self paintingInProgress ifTrue: [^ PhratchError error: 'beep'.].
	hand := self world activeHand.
	hand toolType: 'ZoomInTool'.

	cursorForm := PhratchFrameMorph skinAt: #zoomInCursor.
	offset := 8@8.

	hand showTemporaryCursor: cursorForm hotSpotOffset: offset.

]

{ #category : #'tools (no longer used)' }
PhratchFrameMorph >> zoomOutTool [

	| hand cursorForm offset |
	self paintingInProgress ifTrue: [^ PhratchError error: 'beep'.].
	hand := self world activeHand.
	hand toolType: 'ZoomOutTool'.

	cursorForm := PhratchFrameMorph skinAt: #zoomOutCursor.
	offset := 8@8.
	hand showTemporaryCursor: cursorForm hotSpotOffset: offset.


]
