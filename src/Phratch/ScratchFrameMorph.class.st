"
I am the top level user interface for Scratch. I tile the screen with a toolbar, a work pane (for content), a viewer pane, and a script editor pane. I can resize myself to fill the entire Squeak window.

I keep a list of Scratch processes (threads) and run each one to the its next stopping point when I am stepped each screen update cycle.

"
Class {
	#name : #ScratchFrameMorph,
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
		'loginPassword',
		'watcherPositions',
		'shuffledCostumeNames',
		'justSaved',
		'viewModeButtons',
		'viewMode',
		'lastViewMode',
		'viewModeButtonsPanel',
		'toolbarPanel',
		'lastWeDoPoll',
		'quitFlag'
	],
	#classVars : [
		'AllowSharing',
		'Clipboard',
		'DefaultNotes',
		'DefaultSprite',
		'Fonts',
		'FontsXO',
		'IsXO',
		'ScratchServers',
		'ScratchSkin',
		'ScratchSkinXO',
		'ShareServer',
		'ShareServerPath',
		'SupportServer',
		'SupportServerPath',
		'TakeOverScreen',
		'UseErrorCatcher',
		'Version',
		'VersionDate',
		'VisibleDrives',
		'WorkpaneExtent'
	],
	#category : #'Phratch-UI-Panes'
}

{ #category : #byob }
ScratchFrameMorph class >> addSlotShapesToSkin [

	"ScratchFrameMorph addSlotShapesToSkin"
	"ImageMorph new form: (ScratchFrameMorph skinAt: #typeCommand); openInWorld"

	| block form big slot halfList |

	"typeCommand"
	form := Form fromFileNamed: 'command_new.png'.
	form replaceColor: Color black withColor: Color transparent.
	self skin at: #typeCommand put: (form withEmbeddedOutlineColor: Color darkGray width: 1).

	"typePredicate"
	form := Form fromFileNamed: 'predicate_new.png'.
	form replaceColor: Color black withColor: Color transparent.
	self skin at: #typePredicate put: (form withEmbeddedOutlineColor: Color darkGray width: 1).

	"typeReporter"
	form := Form fromFileNamed: 'reporter_new.png'.
	form replaceColor: Color black withColor: Color transparent.
	self skin at: #typeReporter put: (form withEmbeddedOutlineColor: Color darkGray width: 1).

	"typeList"
	block := ReporterBlockMorph new color: (ScriptableScratchMorph blockColorFor: 'list'); commandSpec: '%s'.
	slot := block argMorphs first.
	slot extent: 7 @ 4.
	form := slot imageForm.
	form replaceColor: (form colorAt: 2@2) withColor: (ScriptableScratchMorph blockColorFor: 'list').
	halfList := slot extent + 1.
	big := Form extent: halfList x @ (halfList y * 2) depth: 8.
	(WarpBlt toForm: big)
		sourceForm: form;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: form boundingBox corners toRect: form boundingBox.
	(WarpBlt toForm: big)
		sourceForm: form;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: form boundingBox corners toRect: (form boundingBox translateBy: 0@(halfList y)).
	self skin at: #typeList put: ((big withOutlineColor: Color white width: 2) withEmbeddedOutlineColor: Color darkGray width: 1).

	"typeText"
	block := ReporterBlockMorph new color: Color lightGray; commandSpec: '%s'.
	block argMorphs first stringExpression: '     '.
	form := block argMorphs first imageForm.
	self skin at: #typeText put: form. 


]

{ #category : #'falta adaptar' }
ScratchFrameMorph class >> buttonLabel: aString selector: aSymbolOrNil [
	"Answer a big button with the given label."

	| button |
	button := ResizableToggleButton2 new
		offForm: (ScratchFrameMorph skinAt: #btn)
			onForm: (ScratchFrameMorph skinAt: #btnPressed);
		label: aString font: (ScratchFrameMorph getFont: #Button);
		actionSelector: aSymbolOrNil.

	^ button

]

{ #category : #utilities }
ScratchFrameMorph class >> cameraMode [

	^ #normal

]

{ #category : #utilities }
ScratchFrameMorph class >> colorToTrack [

	^ Color red


]

{ #category : #utilities }
ScratchFrameMorph class >> defaultSprite [
"Return the default sprite if one was set, or the cat otherwise"

	DefaultSprite
		ifNotNil: [^ DefaultSprite]
		ifNil: [^ ScratchSpriteMorph new
			addMediaItem: (ImageMedia new
				mediaName: ('costume' localized, '1');
				form: (ScratchFrameMorph skinAt: #defaultSpriteCostume));
"			addMediaItem: (ImageMedia new
				mediaName: ('costume' localized, '2');
				form: (ScratchFrameMorph skinAt: #defaultSpriteCostume2));
			addMediaItem: (SoundMedia new
				mediaName: 'meow' localized;
				sound: ScratchSpriteMorph meowSound); "
			lookLike: ('costume' localized, '1')].

]

{ #category : #byob }
ScratchFrameMorph class >> disableSharing [
	AllowSharing := false
]

{ #category : #'scratch skin' }
ScratchFrameMorph class >> getFont: aSymbol [
	"Get a font for a given purpose (specified by aSymbol) based on the current font setting."

	^ self isXO
		ifTrue: [FontsXO at: aSymbol]
		ifFalse: [Fonts at: aSymbol].

]

{ #category : #'scratch skin' }
ScratchFrameMorph class >> initFonts [
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
		(AboutScratch				VerdanaBold		11	VerdanaBold		14)
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
ScratchFrameMorph class >> initialize [
	"self initialize"

	Clipboard := nil.
	WorkpaneExtent := 480@360.
	UseErrorCatcher := true.
	AllowSharing := true.
	DefaultNotes := ''.

	self initFonts.


]

{ #category : #'scratch skin' }
ScratchFrameMorph class >> isXO [
	"Return true if the current skin is XO."

	^ "IsXO" false

]

{ #category : #'scratch skin' }
ScratchFrameMorph class >> isXO: aBoolean [
	"Set the current skin style to #XO if the argument is true, normal otherwise."
	"self isXO: true"
	"self isXO: false"

	IsXO := aBoolean.

	"aBoolean ifTrue: [(Preferences setMenuFontTo: (StrikeFont fontName: #VerdanaBold size: 18))]
			ifFalse: [(Preferences restoreDefaultFonts)]." "annoying for development"

]

{ #category : #utilities }
ScratchFrameMorph class >> open [
"	InputEventSensor startUp."
	"SoundPlayer initialize; shutDown; startUp. "
	self new startup openInWorld
]

{ #category : #utilities }
ScratchFrameMorph class >> palettePaneColor [

	| c |
	c := Color r: 124 g: 128 b: 131 range: 255.
	self isXO ifTrue: [c := c mixed: 0.75 with: Color white].
	^ c

]

{ #category : #byob }
ScratchFrameMorph class >> parseDownloadDatabase: fileName [
	"Parse the HTML file for the Scratch download database."
	"self parseDownloadDatabase: 'mlist.html'"
	"To list downloads by date:
		(db collect: [:r | r first upTo: Character space]) asBag sortedElements"

	| raw lines inTable s records r |
	raw := (FileStream oldFileNamed: fileName) contentsOfEntireFile.
	lines := OrderedCollection new.
	inTable := false.
	raw lines do: [:ln |
		s := ln trimBoth.
		s = '</table>' ifTrue: [inTable := false].
		inTable ifTrue: [lines addLast: s].
		s = '<table>' ifTrue: [inTable := true]].

	records := OrderedCollection new.
	lines := ReadStream on: lines.
	[lines atEnd] whileFalse: [ | ln |
		ln := lines next.
		ln = '<tr>' ifTrue: [
			r := self parseRecordFrom: lines.
			r size > 0 ifTrue: [records addLast: r asArray]]].

	^ records asArray


]

{ #category : #utilities }
ScratchFrameMorph class >> parseRecordFrom: lineStream [
	"An HTML table record from the given stream of lines."

	| rec ln buf |
	rec := OrderedCollection new.
	[true] whileTrue: [
		ln := lineStream next.
		ln = '</tr>' ifTrue: [^ rec].
		(ln beginsWith: '<td>') ifTrue: [
			buf := ln copyFrom: 5 to: ln size.
			[lineStream atEnd | (buf endsWith: '</td>')] whileFalse: [buf := buf, ' ', lineStream next].
			buf := buf copyFrom: 1 to: buf size - 5.
			rec addLast: buf]].
	^ rec

]

{ #category : #utilities }
ScratchFrameMorph class >> patchWindowsVM: vmFileName quitMessage: aString [
	"Modify the Squeak application (the .exe file) for Windows to display the given string when you quit. You must start with a copy of the original VM, not one that has already been modified. This file will be modified in place, so make sure you keep a copy of the original! The string is truncated to 27 characters since it must fit into the space of the original quit message."
	"self patchWindowsVM: 'Scratch.exe' quitMessage: 'Want to quit Scratch now?'"

	| orig firstOrigByte replacement f found startPos |
	orig := 'Quit Squeak without saving?' asByteArray.
	firstOrigByte := orig first.

	replacement := aString asByteArray copyFrom: 1 to: (aString size min: orig size).
	replacement size < orig size ifTrue: [  "pad with zeros to the same size as the original"
		replacement := replacement, (ByteArray new: orig size - replacement size withAll: 0)].

	f := (FileStream oldFileNamed: vmFileName) binary.

	found := false.
	[f atEnd | found] whileFalse: [
		[f atEnd not and: [f next ~= firstOrigByte]] whileTrue.  "scan for first byte"
		startPos := f position - 1.
		f position: startPos.
		found := true.
		1 to: orig size do: [:i | f next = (orig at: i) ifFalse: [found := false]]].

	found ifTrue: [  "over-write the original message with the replacement"
		f position: startPos.
		replacement do: [:byte | f nextPut: byte]].

	f position: f size.  "position to end of file to avoid possible file truncation"
	f close.

	found
		ifTrue: [self inform: 'New quit message installed']
		ifFalse: [self inform: 'Original quit message not found; no change made'].


]

{ #category : #utilities }
ScratchFrameMorph class >> putInClipboard: anObject [
	
	Clipboard := anObject.
]

{ #category : #utilities }
ScratchFrameMorph class >> quitFromMenu [
	"The user is using the application menu to quit from Scratch. If there is an open Scratch window, ask the user about saving the project. Otherwise, confirm that the user really wants to quit."

	| scratchWindow |
	scratchWindow := World submorphs detect: [:m | (m isKindOf: self)] ifNone: [nil].
	scratchWindow
		ifNil: [World hands first quitSession]
		ifNotNil: [scratchWindow quitScratch].

]

{ #category : #utilities }
ScratchFrameMorph class >> readShareServerEntry [
	"Check for a file containing a list of Scratch servers.
	If this file is found and it includes an entry labled '*share*' then make that entry the server and path for 'Share' uploads. 
	If this file includes an entry labeled *support* then make that entry the server and path for the 'Support' site link.
	This is meant to be done once when Scratch is first started. Other entries in this file used to appear as Scratch servers in the Scratch project open dialog."
	"self readShareServerEntry"

	| s zentry entryList servers key shareExists |
	"set defaults in case there is no 'servers.txt' file"
	ShareServer := 'scratch.mit.edu'.
	ShareServerPath := '/services/upload'.
	SupportServer := ShareServer.
	SupportServerPath := '/support'.
	ScratchServers := #(
"xxx
		('LTC Scratch Server'		'ltc.smm.org'			'/scratch/')
		('MIT Scratch Server'		'web.media.mit.edu'		'/~jmaloney/mit_scratch/')
xxx"
	).

	(FileSystem  workingDirectory /  'servers.txt') exists ifFalse: [^ self].
	[s := (FileStream readOnlyFileNamed: 'servers.txt') contentsOfEntireFile] ifError: [^ self].
	entryList := HtmlChunker parseTabbedString: s.

	"collect Scratch servers for open dialog"
	servers := entryList select: [:entry | (entry first beginsWith: '*share*') not].
	servers do: [:entry |
		entry size >= 3 ifTrue: [
			key := entry first asLowercase.
			ScratchServers := ScratchServers reject: [:e | e first asLowercase = key].
			ScratchServers := ScratchServers copyWith: entry]].
	ScratchServers sort: [:e1 :e2 | (e1 first compare: e2 first) <= 2].

	shareExists := true.
	"if there is a file *share* entry, it overrides the default Share server"
	zentry := entryList detect: [:e | (e first beginsWith: '*share*')] ifNone: [shareExists := false].
	shareExists ifTrue: [
		zentry size >= 3 ifTrue: [
			ShareServer := zentry at: 2.
			ShareServerPath := zentry at: 3]].

	"if there is a file *support* entry, it overrides the default Support server"
	zentry := entryList detect: [:e | (e first beginsWith: '*support*')] ifNone: [^ self].
	zentry size >= 3 ifTrue: [
		SupportServer := zentry at: 2.
		SupportServerPath := zentry at: 3].

]

{ #category : #'scratch skin' }
ScratchFrameMorph class >> readSkin [
	
	^ ScratchSkin := 
		ScratchFrameMorph readSkinFrom: 
			(FileSystem workingDirectory / 'ScratchSkin')
]

{ #category : #'scratch skin' }
ScratchFrameMorph class >> readSkinFrom: aDirectory [
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
	ScratchSkin := dict.
	ScratchSkinXO := xoDict.

	img := ScratchSkin at: #scriptsPaneTexture ifAbsent: [nil].
	(img notNil and: [img depth ~= 32]) ifTrue: [
		ScratchSkin at: #scriptsPaneTexture put: (img asFormOfDepth: 32)].

	^ ScratchSkin
]

{ #category : #utilities }
ScratchFrameMorph class >> scaledFormForPaintEditor: aForm [
	"Answer either the given form or a copy of it scaled down to fit into the paint editor."
	"This method supports a quick fix to the following problem: When a big image is loaded onto a sprite and then edited in the image editor, (a) you cannot edit offscreen pixels and (b) if you click 'OK' to accept the edits, the image will be cropped. This fix resizes the loaded image to fit into paint editor canvas to avoid these problems. In the longer term, we should fix the paint editor to allow editing images larger than the canvas size."

	| maxExtent scale |
	maxExtent := WorkpaneExtent.
	((aForm width <= maxExtent x) and:
	 [aForm height <= maxExtent y])
		ifTrue: [^ aForm].

	scale := (maxExtent x / aForm width) min: (maxExtent y / aForm height).
	^ ScratchPlugin scale: aForm by: scale

]

{ #category : #utilities }
ScratchFrameMorph class >> scratchServers [

	^ ScratchServers

]

{ #category : #utilities }
ScratchFrameMorph class >> scriptsPaneColor [

	| c |
	c := Color r: 124 g: 128 b: 131 range: 255.
	self isXO ifTrue: [c := c mixed: 0.8 with: Color white].
	^ c

]

{ #category : #utilities }
ScratchFrameMorph class >> setVisibleDrives: driveListString [
	"Set my set of visible drives. If the argument is nil, then all drives are made visible."

	| in drive |
	VisibleDrives := nil.
	driveListString ifNil: [^ self].

	VisibleDrives := OrderedCollection new.
	in := ReadStream on: driveListString.
	[in atEnd] whileFalse: [
		in skipSeparators.
		drive := (in upTo: $,) trimBoth.
		drive size > 0 ifTrue: [VisibleDrives addLast: drive asUppercase]].

	VisibleDrives size > 0
		ifTrue: [VisibleDrives := VisibleDrives asArray]
		ifFalse: [VisibleDrives := nil].

]

{ #category : #utilities }
ScratchFrameMorph class >> shareServer [
	"Answer the name of the Scratch project sharing server."

	^ ShareServer

]

{ #category : #'scratch skin' }
ScratchFrameMorph class >> skin [
	^ScratchSkin ifNil: [self readSkin]
]

{ #category : #'scratch skin' }
ScratchFrameMorph class >> skinAt: aSymbolOrString [

	^ self skinAt: aSymbolOrString ifAbsent: [ScratchSkin error: 'key not found']

]

{ #category : #'scratch skin' }
ScratchFrameMorph class >> skinAt: aSymbolOrString ifAbsent: aBlock [
	"Answer the skin image with the given name. In XO mode, first check to see if an entry appears in ScratchSkinXO. If so, use it. Otherwise, use the image from the normal skin dictionary."

	| k |
	k := aSymbolOrString asSymbol.
	self isXO ifTrue: [
		k = #scriptsPaneTexture ifTrue: [^ aBlock value].
		(ScratchSkinXO includesKey: k) ifTrue: [^ ScratchSkinXO at: k]].

	^ self skin at: k ifAbsent: aBlock

]

{ #category : #utilities }
ScratchFrameMorph class >> supportServer [
	"Answer the name of the Scratch support site server."

	^ SupportServer

]

{ #category : #utilities }
ScratchFrameMorph class >> supportServerPath [
	"Answer the path of the Scratch support site server."

	^ SupportServerPath

]

{ #category : #'scratch skin' }
ScratchFrameMorph class >> takeOverScreen: aBoolean [
	"self takeOverScreen: true"
	"self takeOverScreen: false"

	TakeOverScreen := aBoolean

]

{ #category : #'as yet unclassified' }
ScratchFrameMorph class >> updateSkinFrom: aDirectory [
	"Read the Forms for my skin from the given directory and update them in myskin dictionary."
	"When in XO mode, entries in ScratchSkinXO override the corresponding entries in ScratchSkin."
	"self updateSkinFrom: (FileDirectory default directoryNamed: 'skinRestore')"

	| dict img i xoDict |
	dict := Dictionary new.
	xoDict := Dictionary new.
	aDirectory fileNames do: [:fn |
		|fn1|
		fn1:= fn.
		Cursor read showWhile: [
			img := [Form fromFileNamed: (aDirectory / fn1) fullName] ifError: [Transcript cr; show: 'error'. nil]].
		img ifNotNil: [
			i := fn1 findLast: [:c | c = $.].
			i = 0 ifFalse: [fn1 := fn1 copyFrom: 1 to: i - 1].
			(fn1 asLowercase endsWith: '_xo')
				ifTrue: [xoDict at: (fn1 copyFrom: 1 to: fn1 size - 3) asSymbol put: img]
				ifFalse: [dict at: fn1 asSymbol put: img]]].
	dict keys do: [:key| Transcript cr; show: key. ScratchSkin at: key put: (dict at: key)].
	xoDict keys do: [:key| ScratchSkinXO at: key put: (xoDict at: key)].

	img := self skin at: #scriptsPaneTexture ifAbsent: [nil].
	(img notNil and: [img depth ~= 32]) ifTrue: [
		self skin at: #scriptsPaneTexture put: (img asFormOfDepth: 32)].

]

{ #category : #utilities }
ScratchFrameMorph class >> useErrorCatcher [

	^ UseErrorCatcher

]

{ #category : #utilities }
ScratchFrameMorph class >> vanity [

	^ 'BYOB ', self version, ' (C) Brian Harvey & Jens Mnig'
]

{ #category : #utilities }
ScratchFrameMorph class >> version [

	^ Version

]

{ #category : #utilities }
ScratchFrameMorph class >> version: aString [
	"self version: '3.1.1 (', (Date today printFormat: #(1 2 3 $- 2 2)), ')'"
	"self version: '1.0'"

	Version := aString.
	VersionDate := Date today printFormat: #(3 2 1 $- 1 1).

]

{ #category : #utilities }
ScratchFrameMorph class >> versionDate [

	^ VersionDate

]

{ #category : #utilities }
ScratchFrameMorph class >> visibleDrives [
	"For Win32. Answer a list of visible drive names or nil. If nil, then all drives are visble."

	^ VisibleDrives

]

{ #category : #utilities }
ScratchFrameMorph class >> workpaneExtent [
	"Answer the extent of the work pane."

	^ WorkpaneExtent

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> aboutPhratch [

	| dialogBox |
	dialogBox := DialogBoxMorph new
		title: 'About Phratch';
		withButtonsForYes: false no: false okay: true cancel: false.
	dialogBox
		message: 'Phratch 0.01
Based on Build Your Own Blocks - an extension to Scratch

Copyright 2011 Brian Harvey and Jens Moenig
bh@cs.berkeley.edu, jens@moenig.org
All rights reserved

Based on SCRATCH
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
		font: (ScratchFrameMorph getFont: #AboutScratch).

	dialogBox setBalloonText: ((CommandBlockMorph new color: (ScriptableScratchMorph blockColorFor: 'control'); commandSpec: 'B Y %r B')) asLambda displayForm.

	dialogBox getUserResponse.

]

{ #category : #other }
ScratchFrameMorph >> addAndView: aSpriteMorph [
	"Add given morph to the work pane and view it."

	| pos i p |
	aSpriteMorph center: workPane center.
	pos := self scratchObjects collect: [:o | o referencePosition].
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

{ #category : #byob }
ScratchFrameMorph >> addBlockEditor: aBlockEditor [
	blockEditors add: aBlockEditor
]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> addServerCommandsTo: menu [
	"Add Scratch server commands to the given menu."

	| disable endCmd |
	disable := false.  "make this true to disable this feature"
	disable ifTrue: [^ self].

	menu addLine.
	(workPane scratchServer notNil and:
	 [workPane scratchServer sessionInProgress])
		ifTrue: [
			menu add: 'Show IP Address' action: #showNetworkAddress.
			endCmd := workPane scratchServer isHosting
				ifTrue: ['Stop Hosting Mesh']
				ifFalse: ['Leave Mesh'].
			menu add: endCmd action: #exitScratchSession]
		ifFalse: [
			menu add: 'Host Mesh' action: #startHostingScratchSession.
			menu add: 'Join Mesh' action: #joinScratchSession].
	^menu


]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> addShortcutButtonsTo: rowMorph [

	| buttonSpecs b |

	self class disableSharing.

	buttonSpecs := #(
		"name		tool tip				selector"
		(language	'Set language'		languageMenu:)
		(save		'Save this project'	saveScratchProjectNoDialog)
"		(share		'Share this project'	share)"
	).
	AllowSharing ifFalse: [
		buttonSpecs := buttonSpecs select: [:spec | spec first ~= #share]].

	buttonSpecs do: [:spec |
		b := ToggleButton
			onForm: (ScratchFrameMorph skinAt: (spec at: 1), 'ButtonOver')
			offForm: (ScratchFrameMorph skinAt: (spec at: 1), 'Button')
			overForm: (ScratchFrameMorph skinAt: (spec at: 1), 'ButtonOver').
		b
			target: self;
			actionSelector: (spec at: 3);
			setBalloonText: (spec at: 2) localized;
			actWhen: #buttonUp;
			isMomentary: true.
		
		('language' = (spec at: 1)) ifTrue: [  "language special case"
			b arguments: (Array with: b)].

		('save' = (spec at: 1)) ifTrue: [  "bigger spacer"
			rowMorph addMorphBack: (Morph new extent: (10@5); color: Color transparent)].

		('share' = (spec at: 1)) ifTrue: [  "add spacer between buttons"
			rowMorph addMorphBack: (Morph new extent: (8@5); color: Color transparent)].
		rowMorph addMorphBack: b].

	rowMorph addMorphBack: (Morph new extent: (15@5); color: Color transparent).

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> addSpriteMorph [

	| result f m el |
	self world activeHand toolType: nil.
	self paintingInProgress ifTrue: [^ Beeper beep].

	result := ScratchFileChooserDialog chooseSpriteCostumeFor: self.
	result = #cancelled ifTrue: [^ self].
	((result basename asLowercase endsWith: '.sprite') | (result basename asLowercase endsWith: '.ysp'))
		ifTrue: [^ self importSpriteOrProject: result].

	[f := Form fromFileNamed: result] ifError: [^ self].
	el := ImageMedia new form: (ScratchFrameMorph scaledFormForPaintEditor: f).
	m := ScratchSpriteMorph new soleCostume: el.
	el mediaName: (m unusedMediaNameFromBaseName: (result basename)).
	self addAndView: m.

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> allBlocksString [

	| s stacks |
	s := WriteStream on: (String new: 10000).
	((Array with: workPane), self scratchObjects) do: [:obj |
		stacks := (obj blocksBin isKindOf: Collection) ifFalse:[obj blocksBin submorphs select: [:m | m isKindOf: BlockMorph]].
		stacks size > 0 ifTrue: [
			s nextPutAll: 'All stacks for ', obj objName, ':'; cr; cr.
			stacks do: [:blocks | self printTupleList: blocks tupleSequence on: s. s cr; cr].
			s cr]].

	^ s contents

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> allProjectMedia [
	"Answer a collection of all media items in the current project."

	| result |
	result := OrderedCollection new.
	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			result addAll: m media]].
	^ result

]

{ #category : #drawing }
ScratchFrameMorph >> areasRemainingToFill: aRectangle [
	"Drawing optimization. Since I completely fill my bounds with opaque pixels, this method tells Morphic that it isn't necessary to draw any morphs covered by me."
	
	^ aRectangle areasOutside: self bounds

]

{ #category : #accessing }
ScratchFrameMorph >> author [

	^ author

]

{ #category : #accessing }
ScratchFrameMorph >> author: aString [
	"This is the author used in notes and save as, which is different from the user name used when uploading to the website."

	author := aString.


]

{ #category : #byob }
ScratchFrameMorph >> blockContrastOff [

	BlockMorph contrastOff.
	self refreshBlocks.
	self recordBlockContrast: 0
]

{ #category : #byob }
ScratchFrameMorph >> blockContrastStrong [

	BlockMorph contrastStrong.
	self refreshBlocks.
	self recordBlockContrast: 1
]

{ #category : #byob }
ScratchFrameMorph >> blockEditors [
	^blockEditors
]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> canonicalizeImagesQuality: qualityOrNil saveOriginal: saveFlag [

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
ScratchFrameMorph >> canonicalizeSoundsBits: bitsPerSample [

	^self canonicalizeSoundsBits: bitsPerSample saveOriginal: false
]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> canonicalizeSoundsBits: bitsPerSample saveOriginal: saveFlag [

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
ScratchFrameMorph >> checkBoxLabelled: aString marked: aBool width: anInt [
	"answer a form consisting of a checkbox and a label - used for the EDIT menu in BYOB"

	| box label pic line cnts |
	aBool
		ifTrue: [pic := ScratchFrameMorph skinAt: #watcherButtonPressed]
		ifFalse: [pic := ScratchFrameMorph skinAt: #watcherButton].
	box := ImageMorph new form: pic. 
	
	ScratchTranslator useSqueakRendering
		ifTrue: [cnts := ' ', aString localized asMacRoman]
		ifFalse: [cnts := ' ' asUTF8, aString localized].

	label := ScratchStringMorph contents: cnts font: PhratchPreferences standardMenuFont.
	line := Morph new color: Color transparent.
	line height: (box height max: label height).
	line width: (box width + label width max: anInt).
	box left: line left.
	box top: line top + (line height - box height // 2).
	label left: box right.
	label top: line top + (line height - label height // 2).
	line addMorph: box.
	line addMorph: label.
	^ line imageForm
]

{ #category : #stepping }
ScratchFrameMorph >> checkForWeDo [
	"Check for WeDo, and show motor blocks if it is found."
	"Note: Polling on Vista can take several hundred milliseconds, so reduce polling to just a few times per minute."
"
	| now |
	now := Time millisecondClockValue.
	(lastWeDoPoll isNil or: [lastWeDoPoll > now]) ifTrue: [lastWeDoPoll := 0].
	((now - lastWeDoPoll) < 15000) ifTrue: [^ self]. ""don't poll too often"
"	lastWeDoPoll := now.
	WeDoPlugin readInputs.
	WeDoPlugin isOpen ifTrue: [
		workPane showMotorBlocks ifTrue: [^ self].
		self showMotorBlocks.
		WeDoPlugin readInputs]."

]

{ #category : #byob }
ScratchFrameMorph >> clearAllVariables [

	workPane clearAllVariables
]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> clearStage [

	self stopAll.
	projectDirectory := ScratchFileChooserDialog getDefaultFolderForType: #project.
	projectName := ''.
	projectInfo := Dictionary new.

	self installNewProject: ScratchStageMorph new.
	self initializeWatcherPositions.
	justSaved := true.

]

{ #category : #byob }
ScratchFrameMorph >> closeBlockEditor [
	blockEditors do:[:each | each yes "no"].
	blockEditors := Set new.

]

{ #category : #'presentation mode' }
ScratchFrameMorph >> closeDialogBoxes [
	"Close all dialog boxes, including PaintEditors and SoundRecorders."

	World submorphs do: [:m |
		(m isKindOf: DialogBoxMorph) ifTrue: [m cancelled; delete]].

	blockEditors := Set new

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> closeMediaEditorsAndDialogs [
	"Close any open paint or sound editors, asking the user first to avoid losing edits. Answer true if all are closed."

	| mList mHasCancel |
	mList := PaintFrame allInstances select: [:m | m isInWorld].
	mList size > 0 ifTrue: [
		(DialogBoxMorph ask: 'Close paint editor?') ifFalse: [^ false].
		mList do: [:m | m cancelled; delete].
		paintingInProgress := false].

	mList := ScratchSoundRecorderDialogMorph allInstances select: [:m | m isInWorld].
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
ScratchFrameMorph >> compressImages [

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

{ #category : #uploading }
ScratchFrameMorph >> compressMediaForUpload [
	"Compress my media prior to uploading this project."

	self canonicalizeSoundsBits: 4 saveOriginal: true.
	self canonicalizeImagesQuality: 90 saveOriginal: true.


]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> compressSounds [

	| menu bitsPerSample count |
	menu := MenuMorph new title: 'Sound quality:'; defaultTarget: self.
	menu add: 'High (biggest)'
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
	count := menu localize; invokeModal.
	
	scriptsPane categoryChanged: 'Sounds'.
	DialogBoxMorph inform: 'Sounds compressed' withDetails: count printString.

]

{ #category : #'tools (no longer used)' }
ScratchFrameMorph >> copyTool [

	| hand cursorForm offset |
	self paintingInProgress ifTrue: [^ Beeper beep].
	hand := self world activeHand.
	hand toolType: 'CopyTool'.

	cursorForm := ScratchFrameMorph skinAt: #copyCursor.
	offset := 8@13.

	ScratchFrameMorph isXO ifTrue: [
		cursorForm := cursorForm magnifyBy: 1.5.
		offset := (offset * 1.5) rounded].

	hand showTemporaryCursor: cursorForm hotSpotOffset: offset.

]

{ #category : #intialization }
ScratchFrameMorph >> createBasicPanes [
	"Create and add my palette (viewer), script editor, stage, and library panes."

	topPane := ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: 'topPane').
	viewerPane := ScratchViewerMorph new rebuildCategorySelectors.	
	scriptsPane := ScratchScriptEditorMorph new.
	stageFrame := ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: 'stagePane').
	titlePane := ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: 'titlePane').
	workPane := ScratchStageMorph new extent: WorkpaneExtent.
	libraryPane := ScratchLibraryMorph new.

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
ScratchFrameMorph >> createLogo [
	"Create and the Scratch logo."

	logoMorph := SketchMorph withForm: (ScratchFrameMorph skinAt: #scratchLogo).
	logoMorph position: topPane position + (12@8).
	topPane addMorph: logoMorph.

]

{ #category : #intialization }
ScratchFrameMorph >> createMenuPanel [
	"Create and add a panel containing the menus and close button."

	| menuSpecs m |
	"create panel"
	menuPanel := AlignmentMorph new
		cellPositioning: #leftCenter;
		color: Color transparent;
		centering: #center;
		inset: 0;
		height: 0.	"will grow as needed"

	self addShortcutButtonsTo: menuPanel.

	"menuSpecs defines the menus"
	menuSpecs := #(
		"name			selector"
		(File			fileMenu:)
		(Edit			editMenu:)
		(Share			shareMenu:)
		(Help			helpMenu:)
	).

	menuSpecs do: [:spec |
		m := ScratchMenuTitleMorph new
			contents: (spec at: 1) localized;
			target: self selector: (spec at: 2).
		menuPanel addMorphBack: m.
		#helpMenu: = (spec at: 2) ifFalse: [
			menuPanel addMorphBack: (Morph new color: Color transparent; extent: 12@5)]].

	topPane addMorph: menuPanel.

]

{ #category : #intialization }
ScratchFrameMorph >> createReadoutPane [
	"Create and add my presentation mode button, new sprite buttongs, and mouse readout pane."

	| xyReadout |

	readoutPane := ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: #mouseReadoutPane).
	xyReadout := self makeXYReadout.
	readoutPane	 addMorph: xyReadout.

	"make pane sticky so clicking on it doesn't pick up entire frame"
	self addMorph: (readoutPane isSticky: true).

]

{ #category : #intialization }
ScratchFrameMorph >> createStageButtonsPanel [
	"Create and add a panel containing the project title, green flag, and stop buttons."

	| buttonSpecs bName button |
	"create panel"
	stageButtonsPanel := AlignmentMorph new
		cellPositioning: #leftCenter;
		color: Color transparent;
		centering: #center;
		height: 20.

	projectTitleMorph := ScratchStringMorph new
		forceUnicodeRendering: true;
		contents: '';
		font: (ScratchFrameMorph getFont: #FrameMorphProjectTitle).
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
			onForm: (ScratchFrameMorph skinAt: (bName, 'ButtonGrayPressed') asSymbol)
			offForm: (ScratchFrameMorph skinAt: (bName, 'ButtonGray') asSymbol)
			overForm: (ScratchFrameMorph skinAt: (bName, 'ButtonGrayPressed') asSymbol).
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
ScratchFrameMorph >> createToolbar [
	"Create and add the toolbar."

	| buttonSpecs bName button |
	toolbarPanel := AlignmentMorph new
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		color: Color transparent.
		
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
			onForm: (ScratchFrameMorph skinAt: (bName, 'ButtonPressed') asSymbol)
			offForm: (ScratchFrameMorph skinAt: (bName, 'Button') asSymbol)
			overForm: (ScratchFrameMorph skinAt: (bName, 'ButtonOver') asSymbol).
		button
			target: self;
			actionSelector: (spec at: 2);
			isMomentary: true;
			setProperty: #balloonText toValue: (spec at: 3) localized.
		toolbarPanel addMorphBack: button].

	self addMorph: toolbarPanel.

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> createViewModeButtonsPanel [

	| specs bName button |
	viewModeButtonsPanel := AlignmentMorph newRow
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		color: Color transparent.

	viewModeButtons := OrderedCollection new.
	specs := OrderedCollection new.
	specs add: #(quarter			enterQuarterMode		'Switch to small stage').
	specs add: #(normal			enterNormalMode		'Switch to full stage').
	specs add: #(presentation	enterPresentationMode	'Switch to presentation mode').

	specs do: [:spec |
		bName := spec first.
		button := ToggleButton new
			onForm: (ScratchFrameMorph skinAt: bName, 'ViewModeOn')
			offForm: (ScratchFrameMorph skinAt: bName, 'ViewMode')
			overForm: (ScratchFrameMorph skinAt: bName, 'ViewModeOver').
		button
			target: self;
			actionSelector: (spec at: 2);
			alphaOn: true;
			setProperty: #balloonText toValue: (spec at: 3) localized.
		viewModeButtonsPanel
			addMorphBack: button;
			addMorphBack: (Morph new extent: 1@5; color: Color transparent).
		viewModeButtons add: button].

	self addMorph: viewModeButtonsPanel.

]

{ #category : #'tools (no longer used)' }
ScratchFrameMorph >> cutTool [

	| hand cursorForm offset |
	self paintingInProgress ifTrue: [^ Beeper beep].
	hand := self world activeHand.
	hand toolType: 'CutTool'.

	cursorForm := ScratchFrameMorph skinAt: #cutCursor.
	offset := 8@8.

	ScratchFrameMorph isXO ifTrue: [
		cursorForm := cursorForm magnifyBy: 1.5.
		offset := (offset * 1.5) rounded].

	hand showTemporaryCursor: cursorForm hotSpotOffset: offset.

]

{ #category : #other }
ScratchFrameMorph >> delete [

	World activeHand toolType: nil.
	super delete.

]

{ #category : #watchers }
ScratchFrameMorph >> deleteWatchersForSprite: aSprite [
	"The given sprite is being deleted. Delete all watchers associated with it."

	aSprite lists do: [:m | m delete].

	workPane submorphsDo: [:m |
		(m isKindOf: WatcherMorph) ifTrue: [
			(m target = aSprite) ifTrue: [m delete]]].

	watcherPositions keys do: [:k | 
		(k at: 1) = aSprite ifTrue: [watcherPositions removeKey: k]].

]

{ #category : #watchers }
ScratchFrameMorph >> deleteWatchersForVar: varName ofSprite: aSprite [
	"The given variable is being deleted. Delete all watchers associated with it."

	workPane submorphsDo: [:m |
		(m isKindOf: WatcherMorph) ifTrue: [
			((m target = aSprite) and:
			 [(m getSelector = #getVar:) and:
			 [m parameter = varName]])
				ifTrue: [m delete]]].

]

{ #category : #watchers }
ScratchFrameMorph >> deletingWatcher [
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

{ #category : #buttonActions }
ScratchFrameMorph >> developersMenu [
	"Present the Scratch developer's menu."

	| menu |

	self isDevelopmentMode ifFalse: [^ self].

	self world activeHand toolType: nil.
	Cursor normal show.
	menu :=MenuMorph new defaultTarget: self.

	fillScreenFlag
		ifTrue: [menu add: 'turn fill screen off' action: #fillScreenOff]
		ifFalse: [menu add: 'turn fill screen on' action: #fillScreenOn].
	UseErrorCatcher
		ifTrue: [menu add: 'turn error catching off' action: #toggleErrorCatcher]
		ifFalse: [menu add: 'turn error catching on' action: #toggleErrorCatcher].

	menu addLine.
	menu add: 'save image for end-user' action: #saveImageForEndUser.
 
	menu popUpInWorld

]

{ #category : #drawing }
ScratchFrameMorph >> drawOn: aCanvas [
	"Optimization: Don't draw myself at all since I am completely tiled."


]

{ #category : #byob }
ScratchFrameMorph >> editBlockDefinition: aCustomBlockDefinition for: aScriptableScratchMorph [

	| editor def id |
	"for prototypal inheritance:"
	id := aCustomBlockDefinition id.
	aScriptableScratchMorph ensureOwnBlockExists: aCustomBlockDefinition.
	def := aScriptableScratchMorph customBlocks detect: [:eachDef | eachDef id = id]
		ifNone: [^ self ].
	(self notEditingBlockDefinition: def) ifFalse: [^self].
	def fixBlockVarReporters.
	editor 	:= BlockEditorFrameMorph new
		withButtonsForYes: false no: false okay: true cancel: true;
		receiver: aScriptableScratchMorph;
		definition: def.
	blockEditors add: editor.
	editor getUserResponse.
	blockEditors remove: editor ifAbsent: []
]

{ #category : #accessing }
ScratchFrameMorph >> editMenu: aMenuTitleMorph [

	| menu |

	menu := MenuMorph new defaultTarget: self.
	menu add: 'Undelete' localized action: #undoTool.
	menu add: 'Undo last drop' localized action: #undoLastDrop.

	menu addLine.

	menu add: self isTurbo checkBoxString, 'Turbo' localized
			toolTip: 'check to squeeze more computational steps into one display cycle' localized
			action: #toggleTurboMode.

	menu add: ScriptableScratchMorph keepOnStage not checkBoxString, 'Allow Sprites offstage' localized
			toolTip: 'check to allow sprites to move offscreen' localized
			action: #toggleKeepSpritesOnStage.

	menu add: EventHatMorph threadSafeMode checkBoxString, 'Thread safe scripts' localized
			toolTip: 'check to disallow script reentrancy' localized
			action: #toggleThreadSafeMode.

"	menu add: ( BlockMorph contrast = #strong) checkBoxString, 'Zebra Coloring' localized
			toolTip: 'check to alternate color contrast among nested reporters with the same color' localized 
			action: #toggleZebraColoring."

"	menu add: HandMorph translucentWhenDragging checkBoxString, 'Translucent Dragging' localized
			toolTip: 'check to see through objects when they are dragged' localized
			action: #toggleTranslucentDragging."

"	menu add: VariableFrame scopeContrast checkBoxString, 'Scope Contrast' localized
			toolTip: 'check to contrast the color of lexically scoped blocks' localized
			action: #toggleScopeContrast.
"
	menu addLine.
	menu add: 'Compress Sounds' localized action: #compressSounds.
	menu add: 'Compress Images' localized action: #compressImages.
	menu add: 'Unload unused blocks' localized action: #unloadAllUnusedCustomBlocks.
	menu add: 'Clear all Variables' localized action: #clearAllVariables.

	menu addLine.

	menu add: workPane showMotorBlocks checkBoxString, 'Show Motor Blocks' localized
			toolTip: nil
			action: #toggleShowMotorBlocks.

	Sensor shiftPressed ifTrue: [	self isDevelopmentMode ifTrue: [
			menu addLine.
		fillScreenFlag
			ifTrue: [menu add: 'turn fill screen off' localized asMacRoman action: #fillScreenOff]
			ifFalse: [menu add: 'turn fill screen on' localized asMacRoman action: #fillScreenOn].
		UseErrorCatcher
			ifTrue: [menu add: 'turn error catching off' localized asMacRoman action: #toggleErrorCatcher]
			ifFalse: [menu add: 'turn error catching on' localized asMacRoman action: #toggleErrorCatcher].
		]].
 
	menu localize.
"
	#(3 4 7 8) do: [:n |
		menu labels at: n put:
			((menu labels at: n) copyFrom: 1 to: (menu labels at: n) size - 1), ScratchTranslator ellipsesSuffix].
"
	menu popUpAt: aMenuTitleMorph bottomLeft + (0@10) 
		forHand: World primaryHand in: World.

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> editNotes [

	(ScratchNotesDialog editNotesFor: self) getUserResponse.

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> enableRemoteSensors [
	"Start running the Scratch server, allowing Scratch and other applications to interact with this Scratch remotely."

	| server |
	workPane scratchServer ifNil: [
		server := ScratchServer new userName: 'Scratch'.
		server stage: workPane.
		workPane scratchServer: server].

	workPane scratchServer startHosting.
	DialogBoxMorph inform: 'Remote sensor connections enabled' localized.

]

{ #category : #'view mode' }
ScratchFrameMorph >> enterNormalMode [
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
ScratchFrameMorph >> enterPresentationMode [
	"Go into presentation mode."

	| presenter |
	ScratchPlugin pluginAvailable ifFalse: [
		self updateViewModeButtons.
		^ Beeper beep].

	(viewMode = #presentation) ifTrue: [^ self].

	lastViewMode := viewMode.
	viewMode := #presentation.

	self closeDialogBoxes.
	workPane isQuarterSize: false.
	presenter := ScratchPresenterMorph new frame: self.

	self delete.

	Display fillBlack.
	Display fullScreenMode: true.
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
ScratchFrameMorph >> enterQuarterMode [
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

{ #category : #private }
ScratchFrameMorph >> enterQuarterModeIfSmallScreen [

	(Display width >= 980) & (Display height >= 555) ifTrue: [^ self].
	viewMode = #normal ifTrue: [self enterQuarterMode].

]

{ #category : #'view mode' }
ScratchFrameMorph >> exitPresentationMode [
	"Exit presentation mode."

	quitFlag ifTrue: [^Smalltalk quitPrimitive].

	TakeOverScreen ifFalse: [
		Display fullScreenMode: false.
		World restoreDisplay].

	ScriptableScratchMorph doubleSize: false.
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
ScratchFrameMorph >> exitScratchSession [
	"Close all connections to remote collaborators."

	workPane scratchServer ifNil: [^ self].
	workPane scratchServer endScratchSession.
	workPane scratchServer: nil.

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> exportSprite [

	scriptsPane target exportObject.

]

{ #category : #geometry }
ScratchFrameMorph >> extent: aPoint [
	"Position all my submorphs whenever I get resized."

	super extent: aPoint.
	self fixLayout.

]

{ #category : #'file read/write' }
ScratchFrameMorph >> extractInfoFrom: aByteArray [
	"Answer a Scratch info dictionary from the given ByteArray. Answer an empty dictionary if it is an old project."

	| s version |
	s := ReadStream on: aByteArray.
	version := ObjStream scratchFileVersionFrom: (s next: 10) asString.
	(version = 1) | (version = 2)
		ifTrue: [
			s skip: 4.  "skip info header byte count"
			^ ObjStream new readObjFrom: s showProgress: false]
		ifFalse: [^ Dictionary new].


]

{ #category : #'file read/write' }
ScratchFrameMorph >> extractProjectFrom: aByteArray [
	"Answer a Scratch project (i.e. a ScratchStageMorph possibly containing sprites) from the given ByteArray. Answer nil if the project cannot be unpacked."

	| s version proj |

	ObjStream initialize. "just to make sure this works in filed-in changesets, -Jens"

	s := ReadStream on: aByteArray.
	version := ObjStream scratchFileVersionFrom: (s next: 10) asString.
	version = 0 ifTrue: [
		ScriptableScratchMorph decodeAsByob.	"make sure we initialize every field - this breaks compatibility with Scratch-sprites. -Jens"
		s position: 0.
		[proj := ObjStream new readObjFrom: s showProgress: true] ifError: [
		^ self extractScratchProjectFrom: aByteArray]].
	(version = 1) | (version = 2) ifTrue: [
		s skip: s uint32.  "skip header"
		proj := ObjStream new readObjFrom: s showProgress: true].

	proj class = ScratchStageMorph ifFalse: [
		version > 2
			ifTrue: [self error: 'Project created by a later version of Scratch']
			ifFalse: [self error: 'Problem reading project.'].
		^ nil].

	ScriptableScratchMorph buildBlockSpecDictionary.

	'initializing...' 
		displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((proj allMorphs) select: [:m| m isKindOf: ScriptableScratchMorph]) size * 2
		during: [:bar | | i | i := 0.

	proj allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			 i := i + 1. bar value: i.
			m convertTuplesToDefinitions]].

	proj allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [  "convert to new blocks" 
			i := i + 1. bar value: i.
			m convertStacksToTuples.
			m convertTuplesToStacks]]].

	^ proj

]

{ #category : #'file read/write' }
ScratchFrameMorph >> extractScratchProjectFrom: aByteArray [
	"Answer a Scratch project (i.e. a ScratchStageMorph possibly containing sprites) from the given ByteArray. Answer nil if the project cannot be unpacked.

Note: this is a compatibility force method for BYOB - jens"

	| s version proj |

	ObjStream initialize. "just to make sure this works in filed-in changesets, -Jens"

	s := ReadStream on: aByteArray.
	version := ObjStream scratchFileVersionFrom: (s next: 10) asString.
	version = 0 ifTrue: [
		ScriptableScratchMorph decodeAsScratch.	"this is the forcing part. -Jens"
		s position: 0.
		proj := ObjStream new readObjFrom: s showProgress: true].
	(version = 1) | (version = 2) ifTrue: [
		s skip: s uint32.  "skip header"
		proj := ObjStream new readObjFrom: s showProgress: true].

	proj class = ScratchStageMorph ifFalse: [
		version > 2
			ifTrue: [self error: 'Project created by a later version of Scratch']
			ifFalse: [self error: 'Problem reading project.'].
		^ nil].

	ScriptableScratchMorph buildBlockSpecDictionary.

	'initializing...' 
		displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((proj allMorphs) select: [:m| m isKindOf: ScriptableScratchMorph]) size * 2
		during: [:bar | | i | i := 0.

	proj allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			 i := i + 1. bar value: i.
			m convertTuplesToDefinitions]].

	proj allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [  "convert to new blocks" 
			i := i + 1. bar value: i.
			m convertStacksToTuples.
			m convertTuplesToStacks]]].

	^ proj

]

{ #category : #'-- all --' }
ScratchFrameMorph >> fileMenu: aMenuTitleMorph [

	| menu |
	menu := MenuMorph new defaultTarget: self.
	menu add: 'New' action: #newScratchProject.
	menu add: 'Open' action: #openScratchProject.
	menu add: 'Save' action: #saveScratchProjectNoDialog.
	menu add: 'Save As' action: #saveScratchProject.
	menu addLine.
	menu add: 'Import Project' action: #importScratchProject.
	menu add: 'Export Sprite' action: #exportSprite.
	menu addLine.
	menu add: 'Project Notes' action: #editNotes.

	Sensor shiftPressed ifTrue: [  "developer menu"
		menu addLine.
		menu add: 'Write Project Summary' action: #writeSummaryFile.
		menu add: 'Write Multiple Project Summaries' action: #writeMultipleSummaries.
		menu addLine.
		fillScreenFlag
			ifTrue: [
				menu add: 'Exit User Mode' action: #fillScreenOff]
			ifFalse: [
				menu add: 'Enter User Mode' action: #fillScreenOn.
				menu add: 'Save Image in User Mode' action: #saveImageForEndUser]].

	menu addLine.
	menu add: 'Quit' action: #quitScratch.
	menu localize.
	
	#(2 4 5 6 7) do: [:n |
		menu labels at: n put:
			((menu labels at: n) contents copyFrom: 1 to: (menu labels at: n) contents size - 1), ScratchTranslator ellipsesSuffix].

	menu invokeAt: aMenuTitleMorph bottomLeft + (0@10) in: World.


]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> fillScreenOff [
	"Stop filling the entire screen. Useful during development."


	Smalltalk fullScreenMode: false.
	World restoreDisplay.

	fillScreenFlag := false.
	self isSticky: false.
	self extent: Display extent - 50.
	UseErrorCatcher := false.
	PhratchPreferences noviceMode: false.
	PhratchPreferences warnIfNoSourcesFile: true.
	PhratchPreferences warnIfNoChangesFile: true.
	PhratchPreferences insertionPointColor: (Color r: 0.4 g: 1.0 b: 0.0).
	PhratchPreferences textHighlightColor: (Color r: 0.4 g: 1.0 b: 0.0).

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> fillScreenOn [
	"Start filling the entire screen and being sticky. Also configure a few other things for the end user such as turning off halos and the control menu (noviceMode) and making sure that error catching is enabled."

	TakeOverScreen ifTrue: [
		Smalltalk fullScreenMode: true.
		World restoreDisplay].

	fillScreenFlag := true.
	self position: 0@0.
	self isSticky: true.
	self comeToFront.
	UseErrorCatcher := true.
	Sensor useOSEvents: true.
	PhratchPreferences noviceMode: true.
	PhratchPreferences warnIfNoSourcesFile: false.
	PhratchPreferences warnIfNoChangesFile: false.
	PhratchPreferences insertionPointColor: (Color r: 0.353 g: 0.607 b: 0.788).
	PhratchPreferences textHighlightColor: (Color r: 0.353 g: 0.607 b: 0.788).
	self updateProjectName.
	self step.

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> fixByteReversedSounds [
	"See if the current project contains any byte-reversed copies of one of the standard sounds. If it does, byte-reverse all sounds. This is a workaround for a bug in Scratch 1.0 that did not upload sounds in big-endian order."

	| allSoundBuffers badMeowPrefix badPopPrefix foundBadSound |
	allSoundBuffers := IdentitySet new.
	self allProjectMedia do: [:media |
		media isSound ifTrue: [
			allSoundBuffers add: media sound samples]].
	allSoundBuffers remove: ScriptableScratchMorph meowSound samples ifAbsent: [].
	allSoundBuffers remove: ScriptableScratchMorph popSound samples ifAbsent: [].

	badMeowPrefix := ScriptableScratchMorph oldMeowPrefixReversed.
	badPopPrefix := (ScriptableScratchMorph popSound samples copyFrom: 1 to: 100) reverseEndiannessStereo: false.
	foundBadSound := false.
	allSoundBuffers do: [:buf |
		foundBadSound ifFalse: [
			((buf beginsWith: badMeowPrefix) or:
			 [buf beginsWith: badPopPrefix])
				ifTrue: [foundBadSound := true]]].

	foundBadSound ifTrue: [
		allSoundBuffers do: [:buf | buf reverseEndiannessStereo: false]].

]

{ #category : #geometry }
ScratchFrameMorph >> fixLayout [

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
ScratchFrameMorph >> fixNestedBlocks [
	"Not the best solution, I'm sure, but working"
	
	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			m convertStacksToTuples]].

	viewerPane rebuildCategorySelectors.

	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			m convertTuplesToStacks]].
	self updatePanes.
]

{ #category : #private }
ScratchFrameMorph >> fixProjectTitleMorphLayout [
 
	| s truncated eWidth w |

	projectName ifNotNil: [
		s :=  (self nameFromFileName: projectName).
		"trim project name to fit, if necessary"
		truncated := false.
		eWidth := (ScratchTranslator stringExtent: '...' font: projectTitleMorph font) x.
		w := titlePane width - 100 - eWidth.
		[((ScratchTranslator stringExtent: s font: projectTitleMorph font) x) > w] whileTrue: [
			truncated := true.
			s := s copyFrom: 1 to: s size - 1].
		truncated ifTrue: [s := s, '...'].
		projectTitleMorph contents: s].

]

{ #category : #drawing }
ScratchFrameMorph >> fullDrawOn: aCanvas [
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

{ #category : #'falta adaptar' }
ScratchFrameMorph >> getLoginName [
	"Ask the user for their name name and record their answer in 'loginName'."

	| s |
	s := StringDialog
		askWithCancel: 'User name:'
		initialAnswer: loginName.
	s size = 0 ifTrue: [^ ''].
	loginName := s.
	^ s

]

{ #category : #'event handling' }
ScratchFrameMorph >> handlesKeyboard: evt [
	^ true
]

{ #category : #'event handling' }
ScratchFrameMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> helpMenu: aMenuTitleMorph [

	| menu |
	menu := MenuMorph new defaultTarget: self.
	menu add: 'Phratch Website' action: #launchWebsite.
	menu addLine.
	menu add: 'Scratch Help Page' action: #launchHelpPage.
	menu add: 'Help Screens' action: #launchAllHelpScreens.
	menu addLine.
	menu add: 'BYOB Reference Manual' action: #openBYOBManual.
	menu addLine.
	menu add: 'About Phratch' action: #aboutPhratch.

	menu localize.

	#(1 2 3 4 5) do: [:n |
		menu labels at: n put:
			((menu labels at: n) contents copyFrom: 1 to: (menu labels at: n) contents size - 1), ScratchTranslator ellipsesSuffix].

	menu invokeAt: aMenuTitleMorph bottomLeft + (0@10) in: World.
]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> hideMotorBlocks [

	workPane showMotorBlocks: false.
	viewerPane refresh.

]

{ #category : #geometry }
ScratchFrameMorph >> hidePalette: hidePalette [
	"Hide or show the blocks palette."

	hidePalette = viewerPane owner isNil ifTrue: [^ self].  "no change"

	hidePalette
		ifTrue: [
			viewerPane delete.
			scriptsPane
				initFrontFromForm: (ScratchFrameMorph skinAt: #blocksPaletteFrameTransparent2) topSectionHeight: 90;
				middleBarLeftMargin: 5 rightMargin: 0]
		ifFalse: [
			self addMorph: viewerPane.
			scriptsPane
				initFrontFromForm: (ScratchFrameMorph skinAt: #scriptPaneFrameTransparent2) topSectionHeight: 90;
				middleBarLeftMargin: 0 rightMargin: 0].

	scriptsPane color: (Color r: 149/255 g: 154/255 b: 159/255).

]

{ #category : #'file read/write' }
ScratchFrameMorph >> importScratchProject [
	"Allow the user to select a project to open, then merge that project's sprites with the
current project."

	| response |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.

	response := ScratchFileChooserDialog
		chooseExistingFileType: #project
		extensions: #(scratch sb ypr)
		title: 'Import Project'.
	response ifNil: [^ self].

	self importSpriteOrProject: response.

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> importSpriteOrProject: fileNameOrData [
	"Read the sprite or project file and merge into the current project."

	| data f importedStage defaultForm defaultSound oldName oldPosition |
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
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
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
	defaultForm := workPane defaultImageMedia form hibernateForScratch.
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
		(m isKindOf: ScratchSpriteMorph) ifTrue: [
			"m objName: m  nextInstanceName".
			workPane addMorphFront: m.
			m startStepping.
			workPane sprites addLast: m.
			self view: m tab: 'Scripts' category: 'motion'.
			m refPos ifNotNil: [
				m referencePosition: m refPos + (50@ -50) ]]].

	workPane layoutChanged.

]

{ #category : #intialization }
ScratchFrameMorph >> initialize [

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
	loginPassword := ''.
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
ScratchFrameMorph >> initializeWatcherPositions [
	"If any watchers are on the stage, store their position. The dictionary, which is created lazily, is formatted in the following way:
	(<sprite or nil, depending on whether the block isSpriteSpecific>, <name of block>) ->
		(<watcher or nil, depending on whether the watcher is showing on stage>,
		 <position of watcher with top-left corner of stage = 0@0>
		 <layout style>
		 <slider range>)
	Or, more concisely: (sprite/nil,selectorAndArg)->(watcher/nil,position,style,range)."
 
	| p |
	watcherPositions := Dictionary new.
	self scratchWatchers do: [:w |
		p := w position - workPane position.
		watcherPositions
			at: {w getAssociatedSprite. w selectorAndArg}
			put: {w. p. w layoutStyle. w sliderRange}].

]

{ #category : #'file read/write' }
ScratchFrameMorph >> installNewProject: newWorkpane [
	"Called after creating or reading a new project to clear the process scheduler, pick an object to view, clear the library thumbnails, and perform other housekeeping."

	| viewTarget sb |
	self stopAll.

	newWorkpane class = ScratchStageMorph
		ifFalse: [^ self inform: 'Incompatible Scratch file format'].

	"self exitScratchSession."
	workPane scratchServer ifNotNil: [
		workPane scratchServer clearCaches.
		workPane scratchServer stage: newWorkpane.
		newWorkpane scratchServer: workPane scratchServer].

	newWorkpane isQuarterSize: workPane isQuarterSize.
	newWorkpane bounds: workPane bounds.
	newWorkpane midiPortNum: workPane midiPortNum.
	workPane closeMIDI.

	"use the same sensorboard for the new project"
	sb := workPane sensorBoard.
	newWorkpane submorphs do: [:m |
		(m isKindOf: SensorBoardMorph) ifTrue: [
			sb position: m position.
			newWorkpane replaceSubmorph: m by: sb.
			sb tryToOpenPort]].
	newWorkpane sensorBoard: sb.

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
	ScriptableScratchMorph resetTimer.

	"pick an object view, or view the background if there is no other"
	viewTarget := workPane.
	workPane submorphs do: [:m |
		(m respondsTo: #scripts) ifTrue: [
			m scripts size >= viewTarget scripts size ifTrue: [viewTarget := m]]].
	viewTarget viewBlocksAndScripts.

	"populate the sprites list if it is empty (backward compatability)"
	workPane sprites isEmpty ifTrue: [
		workPane submorphs do: [:m |
			(m isKindOf: ScriptableScratchMorph) ifTrue: [workPane sprites addLast: m]]].

	scriptsPane tabPane currentTab: 'Scripts'.
	libraryPane clearLibrary.
	workPane clearPenTrails.
	"self updateProjectName".
	ScratchProcess blockHighlightMSecs: 1.
	ScratchPrompterMorph clearLastAnswer.

	(projectInfo at: 'isHosting' ifAbsent: [false]) ifTrue: [
		self enableRemoteSensors].
	(projectInfo at: 'hasMotorBlocks' ifAbsent: [false]) ifTrue: [
		self showMotorBlocks].
	(projectInfo includesKey: 'penTrails') ifTrue: [
		workPane penTrailsForm: (projectInfo at: 'penTrails')].

	(projectInfo at: 'keepOnStage' ifAbsent: [true]) = ScriptableScratchMorph keepOnStage
		ifFalse: [self toggleKeepSpritesOnStage].

	Clipboard := nil.
	World cleanseStepList.  "make sure garbage collect can clean up the old sprites"
	Smalltalk garbageCollect.  "get rid of old sprite instances"

	self world ifNotNil: [self world startSteppingSubmorphsOf: self].
	ScriptableScratchMorph scratchOrigin: workPane center.
	justSaved := true.

]

{ #category : #byob }
ScratchFrameMorph >> isDevelopmentMode [

	| args arg |

	"PhratchPreferences noviceMode
		ifTrue: [
			args := OrderedCollection new.
			2 to: 10 do: [:i |
				arg := Smalltalk getSystemAttribute: i.
				arg ifNotNil: [args add: arg ]].
			args detect: [:each |
				each asLowercase = 'dev'] ifNone: [^false].
			^true]
		ifFalse: [^ true]"
	^true
]

{ #category : #byob }
ScratchFrameMorph >> isTurbo [
	^ ScratchProcess blockHighlightMSecs < 1
]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> joinScratchSession [
	"Join another Scratch user or a Scratch-compatible remote application."

	| server addrString ok |
	server := ScratchServer new.
	server stage: workPane.
	workPane scratchServer: server.

	addrString := StringDialog askWithCancel: 'IP address:'.
	addrString size = 0 ifTrue: [^ self].

	ok := workPane scratchServer joinSessionAt: addrString.
	ok ifFalse: [DialogBoxMorph warn: 'Could not connect to ', addrString].

]

{ #category : #byob }
ScratchFrameMorph >> keepSpritesOnStage: anInt [
	| bool |

	bool := {false. true} at: anInt + 1.
	ScriptableScratchMorph keepOnStage: bool
]

{ #category : #'event handling' }
ScratchFrameMorph >> keyStroke: evt [
	|ch|
	ch := evt keyValue.
			evt commandKeyPressed ifTrue: [ch := ch \\ 32].	"map cmd/alt keys to control keys"
			(ch = 3) | (ch = 13) ifTrue: [^ self pressGreenFlagButton].
			ch = 15 ifTrue: [^ self openScratchProject].
			ch = 17 ifTrue: [^ self quitScratch].
			ch = 19 ifTrue: [^ self saveScratchProjectNoDialog].       
			ch = 27 ifTrue: [
				TakeOverScreen ifTrue: [
					Smalltalk fullScreenMode: false.
					Smalltalk fullScreenMode: true.
					World restoreDisplay].
				^ self].
			workPane broadcastEventNamed: 'Scratch-KeyPressedEvent' with: evt.
]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> languageMenu: aToggleButtonMorph [
	"Present a menu of possible languages for blocks."

	| bullet menu choice |
	
	ScratchTranslator canRenderUnicode ifFalse: [
		"try to find a Unicode plugin in case this is the first use after startup"
		ScratchTranslator detectRenderPlugin].

"	bullet := UTF8 withAll: 'Ç¢ '."
	bullet := UTF8 withAll: '*'.
	menu := MenuMorph new defaultTarget: self.
	ScratchTranslator languageNames do: [:lang |
		((ScratchTranslator isoCodeForName: lang) = (ScratchTranslator currentLanguage))
			ifTrue: [menu 
						add: (bullet, ' ', lang asMacRoman, ' ', bullet)
						target: self 
						selector: #setLanguage:
						argument: lang]
			ifFalse: [menu 
						add: lang asMacRoman
						target: self 
						selector: #setLanguage:
						argument: lang]].
	choice := menu invokeModalAt: aToggleButtonMorph bottomLeft + (0@10) in: World allowKeyboard: true. 

	self stopAll.
	self recordLanguage: (ScratchTranslator currentLanguage).

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> launchAllHelpScreens [

	self launchHelpFile: 'allscreens.html'

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> launchHelpFile: aFilename [

	| helpDir subDir |
	
	helpDir := FileSystem workingDirectory / 'Help'.
	helpDir exists ifFalse: [^ Beeper beep].  "no help folder"
	self stopAll.
	

	"use the English subfolder by default if it exists"
	(helpDir directoryNames includes: 'en') ifTrue: [subDir := helpDir / 'en'].
	"use subfolder for the current language if it exists"
	(helpDir directoryNames includes: ScratchTranslator currentLanguage) ifTrue: [
		subDir := helpDir / ScratchTranslator currentLanguage].
	subDir ifNotNil: [helpDir := subDir].
	(helpDir / aFilename) exists
		ifTrue: [ 
			self open: (((helpDir / aFilename) fullName))]
		ifFalse: [
			DialogBoxMorph inform: 'Scratch help file not found.' localized].

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> launchHelpPage [

	self launchHelpFile: 'index.html'.

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> launchScratchWebsite [

	self world displayWorldSafely.
	Cursor wait showWhile: [ScratchPlugin primOpenURL: 'http://', ScratchFrameMorph shareServer].

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> launchWebsite [

	self world displayWorldSafely.
	Cursor wait showWhile: [ScratchPlugin primOpenURL: 'https://code.google.com/p/phratch/'].

]

{ #category : #accessing }
ScratchFrameMorph >> libraryPane [

	^ libraryPane

]

{ #category : #watchers }
ScratchFrameMorph >> listWatchers [
	"Answer a collection of all the list watchers in the work pane."

	^ self workPane submorphs select: [:m | m isKindOf: ScratchListMorph]

]

{ #category : #accessing }
ScratchFrameMorph >> loginName [

	^ loginName

]

{ #category : #accessing }
ScratchFrameMorph >> loginName: aString [

	loginName := aString.

]

{ #category : #accessing }
ScratchFrameMorph >> loginPassword [

	^ loginPassword

]

{ #category : #accessing }
ScratchFrameMorph >> loginPassword: aString [

	loginPassword := aString.

]

{ #category : #compiler }
ScratchFrameMorph >> makeExe [

	| argStr delim |
	justSaved ifFalse: [ 
		self saveScratchProject ].
	delim := FileSystem disk delimiter asString.
	argStr := (ScratchFileChooserDialog getLastFolderForType: #project) fullName
				, delim
				, projectName.
	Smalltalk os isWin32 ifTrue: [
		^ SystemPlugin primLaunch: 'mak\pack ', argStr ].
	SystemPlugin primLaunch: 
		'"'
		, FileSystem workingDirectory fullName
		, delim
		, 'compile.sh" '
		, '"'
		, argStr
		, '"'

]

{ #category : #intialization }
ScratchFrameMorph >> makeXYReadout [
	"Make and answer an x-y readout."

	| normalFont boldFont panel spaceWidth labelX readoutX labelY readoutY |
	normalFont := (ScratchFrameMorph getFont: #XYReadout).
	boldFont := (ScratchFrameMorph getFont: #XYReadoutBold).

	(ScratchTranslator renderScale ~= 1) ifTrue: [
		"force fonts to be fixed size:"
		normalFont := StrikeFont
			osFontName: normalFont name
			size: normalFont pointSize / ScratchTranslator renderScale asFloat.
		boldFont := StrikeFont
			osFontName: boldFont name
			size: boldFont pointSize / ScratchTranslator renderScale asFloat].

	panel := Morph new color: (Color r: 0.753 g: 0.764 b: 0.776).

	ScratchTranslator isRTL
		ifTrue: [labelX := ScratchStringMorph new font: normalFont; contents: ':x' asUTF8]
		ifFalse: [labelX := ScratchStringMorph new font: normalFont; contents: 'x:' asUTF8].
	readoutX := UpdatingStringMorph new
		target: self; getSelector: #mouseX;
		forceUnicodeRendering: true;
		font: boldFont;
		stepTime: 150;
		growable: false.
	readoutX width: (readoutX stringWidth: '-1000').
	ScratchTranslator isRTL
		ifTrue: [labelY := labelX fullCopy contents: ':y' asUTF8]
		ifFalse: [labelY := labelX fullCopy contents: 'y:' asUTF8].
	readoutY := readoutX fullCopy getSelector: #mouseY.

	spaceWidth := ((readoutX stringWidth: ' ') * 0.8) asInteger.

	ScratchTranslator isRTL
		ifTrue: [readoutY rightJustify: true.
			panel addMorph: (readoutY position: 0@0).
			panel addMorph: (labelY position: ((readoutY topRight) + (spaceWidth@0))).]
		ifFalse: [panel addMorph: (labelX position: 0@0).
			panel addMorph: (readoutX position: ((labelX topRight) + (spaceWidth@0)))].

	ScratchTranslator isRTL
		ifTrue: [readoutX rightJustify: true.
			panel addMorph: (readoutX position: (labelY right@labelY top) + (spaceWidth@0)).
			panel addMorph: (labelX position: ((readoutX topRight) + (spaceWidth@0)))]
		ifFalse: [panel addMorph: (labelY position: (labelX right + readoutX width + 8)@(labelX top)).
			panel addMorph: (readoutY position: ((labelY topRight) + (spaceWidth@0)))].
	
	ScratchTranslator isRTL
		ifTrue: [panel extent: ((labelX right) max: (labelY right))@(labelY bottom)]
		ifFalse: [panel extent: ((readoutX right) max: (readoutY right))@(labelY bottom)].

	^ panel

]

{ #category : #'event handling' }
ScratchFrameMorph >> mouseDown: evt [
	"Revert to normal cursor."

	evt hand toolType: nil.
	(evt cursorPoint y - self top) < topPane height ifTrue: [
		self isSticky ifFalse: [evt hand grabMorph: self]].

]

{ #category : #other }
ScratchFrameMorph >> mouseX [

	^ workPane mouseX

]

{ #category : #other }
ScratchFrameMorph >> mouseY [

	^ workPane mouseY

]

{ #category : #'file read/write' }
ScratchFrameMorph >> nameFromFileName: fileName [
	"Return the given Scratch file name without the trailing .sb or .scratch or .ypr extension, if it has one. Ensure the the result is UTF8."

	| s |
	fileName = '' ifTrue: [ ^'default' ].
	s := fileName asFileReference basename.
	(s asLowercase endsWith: '.scratch') ifTrue: [s := s copyFrom: 1 to: s size - 8].
	(s asLowercase endsWith: '.sb') ifTrue: [s := s copyFrom: 1 to: s size - 3].
	(s asLowercase endsWith: '.ypr') ifTrue: [s := s copyFrom: 1 to: s size - 4].
	s isUnicode ifFalse: [s := UTF8 withAll: s].

	^ s


]

{ #category : #buttonActions }
ScratchFrameMorph >> newScratchProject [
	"Make a new, blank Scratch project."

	| response newProject sprite |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.

	(justSaved or: [self projectIsEmpty]) ifFalse: [
		"ask the user if they want to save the current project"
		response := DialogBoxMorph askWithCancel: 'Save the current project?'.
		response = #cancelled ifTrue: [^ self].
		response ifTrue: [self saveScratchProjectNoDialog.
			justSaved ifFalse: [^ self]]].

	projectDirectory := ScratchFileChooserDialog getDefaultFolderForType: #project.
	projectName := ''.
	projectInfo := Dictionary new.

	newProject := ScratchStageMorph new.
	sprite := ScratchFrameMorph defaultSprite fullCopy.
	sprite position: (240@180) - sprite extent.
	newProject addMorph: sprite.
	self installNewProject: newProject.
	sprite installGlobalBlocks.

	ScriptableScratchMorph decodeAsByob. "remember we created this project in byob and not in Scratch"

	self initializeWatcherPositions.
	blockEditors := Set new.
	justSaved := true.

]

{ #category : #other }
ScratchFrameMorph >> newSound [
	"Open the dialog to record a new sound."

	scriptsPane tabPane currentTab: 'Sounds'.
	viewerPane target recordSound.
]

{ #category : #private }
ScratchFrameMorph >> nextSurpriseCostumeName [
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

	shuffledCostumeNames := shuffledCostumeNames shuffledBy: Random new.
	shuffledCostumeNames size = 0
		ifTrue: [^ nil]
		ifFalse: [^ shuffledCostumeNames removeFirst].
]

{ #category : #'tools (no longer used)' }
ScratchFrameMorph >> normalTool [

	self paintingInProgress ifTrue: [^ Beeper beep].
	self world activeHand toolType: nil.

]

{ #category : #byob }
ScratchFrameMorph >> notEditingBlock [
	blockEditors size = 0 ifTrue: [^true].
	(DialogBoxMorph ask: 'Close open block editor(s)?') ifFalse: [^false].
	blockEditors do:[:each | each no].
	blockEditors := Set new.
	^true
]

{ #category : #byob }
ScratchFrameMorph >> notEditingBlockDefinition: aCustomBlockDefinition [
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
ScratchFrameMorph >> open: aFileName [ 
	OSPlatform isMacOS ifTrue: [  
		^ OSProcess command: ('open "', aFileName, '"').
	].
	OSPlatform isUnix ifTrue:[
		^ OSProcess command: ('xdg-open "', aFileName, '"').
	].
	OSPlatform isWin32 ifTrue:[
		^NBWin32Shell shellOpen: '"', aFileName, '"'.
	]
]

{ #category : #byob }
ScratchFrameMorph >> openBYOBManual [

	self open: (((FileSystem workingDirectory / 'Manual' / 'BYOBManual.pdf') fullName))
]

{ #category : #other }
ScratchFrameMorph >> openMIDI [
	"Prompt the user to select a MIDI port number, then open it."

	workPane openMIDI.

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> openScratchDroppedProjectNamed: fName [
	"Open a Scratch project with the given name that was dropped on the Scratch window."

	| response |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.

	(justSaved or: [self projectIsEmpty]) ifFalse: [
		"ask the user if they want to save the current project"
		response := DialogBoxMorph askWithCancel: 'Save the current project?'.
		response = #cancelled ifTrue: [^ self].
		response ifTrue: [self saveScratchProjectNoDialog]].

	self openScratchProjectNamed: fName.

]

{ #category : #'file read/write' }
ScratchFrameMorph >> openScratchProject [
	"Allow the user to select a project to open, then open that project."

	| response newProj |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.
	(justSaved or: [self projectIsEmpty]) ifFalse: [
		"ask the user if they want to save the current project"
		response := DialogBoxMorph askWithCancel: 'Save the current project?'.
		response = #cancelled ifTrue: [^ self].
		response ifTrue: [self saveScratchProjectNoDialog]].

	response := ScratchFileChooserDialog openScratchFileFor: self.
	response = #cancelled ifTrue: [^ self].

	(response isKindOf: FileReference) ifTrue: [  "read the contents of a local file"
		^ self openScratchProjectNamed: response].

	(response isKindOf: ByteArray) ifTrue: [
		[projectInfo := self extractInfoFrom: response] ifError: [projectInfo := Dictionary new].
		[newProj := self extractProjectFrom: response] ifError: [^ self].
		self installNewProject: newProj.
		projectDirectory := ScratchFileChooserDialog getDefaultFolderForType: #project].

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> openScratchProjectNamed: fName [
	"Open a Scratch project with the given name."

	| f projData newProj dir fn|
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	fn := fName.
	f := FileStream readOnlyFileNamedOrNil: fn.
 	f ifNil: ["try a different encoding, fixes a Firefox bug, -Jens"
		fn := fName isoLatinToMac asUTF8.
		f := FileStream readOnlyFileNamedOrNil: fn.
		f ifNil: [^ self inform: 'Could not read' withDetails: fName]].

	[	projData := f binary contentsOfEntireFile.
		newProj := self extractProjectFrom: projData.
		projectInfo := self extractInfoFrom: projData.
	] ifError: [:err :rcvr | ^ self inform: 'Could not read project; file may be damaged' withDetails: '(', err, ')'].

	dir := (fn) parent.
	projectDirectory := dir.
	ScratchFileChooserDialog setLastFolderTo: projectDirectory forType: #project.
	projectName := ( fn) basename.

	self installNewProject: newProj.
	self initializeWatcherPositions.
	viewerPane updateContents.

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> paintSpriteMorph [

	| m |
	m := ScratchSpriteMorph new soleCostume: ImageMedia new.
	self addAndView: m.
	m editDrawingOldCostumeName: m costume mediaName deleteOnCancel: true.

]

{ #category : #accessing }
ScratchFrameMorph >> paintingInProgress [
	"Answer true if the paint editor is in use."

	^ paintingInProgress

]

{ #category : #accessing }
ScratchFrameMorph >> paintingInProgress: aBoolean [

	paintingInProgress := aBoolean.

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> presentHelpScreen: aStringOrNil [
	"Look for a help screen with the given name in the 'Help' folder. If found, present it to the user."

	| helpDir subDir fileNames helpFileName helpForm |
	aStringOrNil ifNil: [^ Beeper beep].

	(FileSystem workingDirectory fileSystem exists: 'Help') ifFalse: [^ Beeper beep].  "no help folder"
	helpDir := FileSystem workingDirectory / 'Help'.

	"use the English subfolder by default if it exists"
	(helpDir / 'en') exists ifTrue: [subDir := helpDir / 'en'].
	"use subfolder for the current language if it exists"
	(helpDir / ScratchTranslator currentLanguage) exists ifTrue: [
		subDir := helpDir / ScratchTranslator currentLanguage].
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
		ifError: [^ Beeper beep].

	HelpDialog showForm: helpForm.

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> pressGreenFlagButton [
	"Simulate pressing the green flag button when enter key is pressed."

	flagButton on.
	World displayWorld.
	(Delay forMilliseconds: 100) wait.
	flagButton off.
	World displayWorld.
	self shoutGo.


]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> printTupleElement: el on: s [

	(el isKindOf: Array) ifTrue: [self printTupleList: el on: s. ^ self].
	(el isKindOf: Symbol) ifTrue: [s nextPutAll: el. ^ self].
	(el isKindOf: String) ifTrue: [s nextPut: $". s nextPutAll: el. s nextPut: $". ^ self].
	(el isKindOf: ScriptableScratchMorph) ifTrue: [s nextPutAll: el objName. ^ self].
	s nextPutAll: el printString.

]

{ #category : #uploading }
ScratchFrameMorph >> printTupleList: anArray on: s [

	s nextPut: $(.
	1 to: anArray size do: [:i |
		self printTupleElement: (anArray at: i)  on: s.
		i = anArray size ifFalse: [s space]].
	s nextPut: $).

]

{ #category : #stepping }
ScratchFrameMorph >> processDroppedFiles [
	"Process any files that have been dropped onto me."

	| droppedFiles m dropPoint fName |
	droppedFiles := FileStream droppedFiles.
	droppedFiles size = 0 ifTrue: [^ self].
	(m := self viewerPane target) ifNil: [^ self].
	dropPoint := droppedFiles first.

	(droppedFiles copyFrom: 2 to: droppedFiles size) do: [:file |
		file close.
		fName := file fullName.
		((fName asLowercase endsWith: '.scratch') | (fName asLowercase endsWith: '.sb') | (fName asLowercase endsWith: '.ypr'))
			ifTrue: [self openScratchDroppedProjectNamed: fName]
			ifFalse: [
				((fName asLowercase endsWith: '.sprite') | (fName asLowercase endsWith: '.ysp'))
					ifTrue: [self importSpriteOrProject: fName]
					ifFalse: [m importMedia: fName]]].

]

{ #category : #stepping }
ScratchFrameMorph >> processKeyboardEvents [

	| evt ch |
	World hands do: [:h |
		[(evt := h nextUnclaimedKeystrokeOrNil) notNil] whileTrue: [
			ch := evt keyValue.
			evt commandKeyPressed ifTrue: [ch := ch \\ 32].	"map cmd/alt keys to control keys"
			(ch = 3) | (ch = 13) ifTrue: [^ self pressGreenFlagButton].
			ch = 15 ifTrue: [^ self openScratchProject].
			ch = 17 ifTrue: [^ self quitScratch].
			ch = 19 ifTrue: [^ self saveScratchProjectNoDialog].
			ch = 27 ifTrue: [
				TakeOverScreen ifTrue: [
					Smalltalk fullScreenMode: false.
					Smalltalk fullScreenMode: true.
					World restoreDisplay].
				^ self].
			workPane broadcastEventNamed: 'Scratch-KeyPressedEvent' with: evt]].

]

{ #category : #startup }
ScratchFrameMorph >> processSettingsFile [
	"Process settings from the Scratch.ini file."

	| lang settings k |
	self class setVisibleDrives: nil.
	lang := nil.
	AllowSharing := true.
	ScratchFileChooserDialog clearFolderCache. "clear homeDir and last folder cache"
	settings := self readSettingsFile.
	settings associationsDo: [:assoc |
		k := assoc key.
		k = 'language' ifTrue: [lang := assoc value].
		k = 'home' ifTrue: [ScratchFileChooserDialog setHomeDir: assoc value].
		k = 'visibledrives' ifTrue: [self class setVisibleDrives: assoc value].
		k = 'share' ifTrue: [(assoc value) = '0' ifTrue: [AllowSharing := false]].
"		k = 'proxyserver' ifTrue: [ScratchUploadProgressDialog proxyServer: assoc value].
		k = 'proxyport' ifTrue: [ScratchUploadProgressDialog proxyPort: assoc value asNumberNoError]."
		k = 'keepspritesonstage' ifTrue: [self keepSpritesOnStage: assoc value asNumberNoError].
		k = 'blockcontrast' ifTrue: [assoc value = '0' ifTrue: [self blockContrastOff] ifFalse: [self blockContrastStrong]].
		k = 'threadsafemode' ifTrue: [assoc value = '0' ifTrue: [EventHatMorph threadSafeMode: false] ifFalse: [EventHatMorph threadSafeMode: true]].
		k = 'scopecontrast' ifTrue: [assoc value = '0' ifTrue: [VariableFrame scopeContrast: false] ifFalse: [VariableFrame scopeContrast: true]].
		k = 'translucentdragging' ifTrue: [assoc value = '0' ifTrue: [HandMorph translucentWhenDragging: false] ifFalse: [HandMorph translucentWhenDragging: true]].
].

	lang ifNil: [lang := ScratchTranslator guessLanguage].
	self setLanguage: lang.

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> processWhenConditions [
	"Trigger any 'when <condition>' hats."

	| objList |
	true ifTrue: [^ self].  "disabled"
	objList := workPane submorphs select: [:m | m isKindOf: ScriptableScratchMorph].
	objList := objList copyWith: workPane.
	objList do: [:obj |
		obj scripts do: [:hat |
			(hat isMemberOf: WhenHatBlockMorph) ifTrue: [
				(hat hasRunningProcess not and: [hat evaluateCondition]) ifTrue: [
					hat start; layoutChanged]]]].

]

{ #category : #accessing }
ScratchFrameMorph >> projectComment [

	^ projectInfo at: 'comment' ifAbsent: ['']

]

{ #category : #'view mode' }
ScratchFrameMorph >> projectComment: aString [

	aString = DefaultNotes ifTrue: [
		projectInfo removeKey: 'comment' ifAbsent: [].
		^ self].

	projectInfo at: 'comment' put: aString asString.

]

{ #category : #accessing }
ScratchFrameMorph >> projectCommentOrTemplate [

	| s |
	s := projectInfo at: 'comment' ifAbsent: [''].
	s size = 0 ifTrue: [s := DefaultNotes].
	^ s

]

{ #category : #other }
ScratchFrameMorph >> projectDirectory [

	projectDirectory ifNil: [^ FileSystem workingDirectory].
	^ projectDirectory

]

{ #category : #accessing }
ScratchFrameMorph >> projectInfo [
	"Answer the project info dictionary."

	^ projectInfo

]

{ #category : #private }
ScratchFrameMorph >> projectIsEmpty [
	"Answer true if the current project has no scripts, no variables, no special costumes or sounds, and at most a single sprite."

	| allScriptables defaultCostumes defaultSnds |
	"at most one sprite in workpane?"
	workPane submorphs size > 1 ifTrue: [^ false].
	workPane submorphs size = 1 ifTrue: [
		(workPane submorphs first isKindOf: ScratchSpriteMorph) ifFalse: [^ false]].

	allScriptables := workPane submorphs copyWith: workPane.
	defaultCostumes := Set
		with: ScriptableScratchMorph defaultBackgroundForm.
	defaultSnds := Set
		with: ScriptableScratchMorph popSound
		with: ScriptableScratchMorph meowSound.

	ScratchFrameMorph defaultSprite ifNotNil: [
		ScratchFrameMorph defaultSprite media do: [:media |
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
ScratchFrameMorph >> projectModified [
	"Record that the current project has changed since it was last saved."

	justSaved := false.

]

{ #category : #accessing }
ScratchFrameMorph >> projectName [

	^ self nameFromFileName: projectName

]

{ #category : #accessing }
ScratchFrameMorph >> projectName: aString [

	projectName := aString.
	projectTitleMorph contents: aString.
	self fixLayout.

]

{ #category : #byob }
ScratchFrameMorph >> purgeBlockEditors [
	blockEditors := blockEditors reject: [:each | 
		each isInWorld not]
]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> quitScratch [
	"Quit from Scratch. Ask the user if they want to save, first."

	| response |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.

	(justSaved or: [self projectIsEmpty]) ifFalse: [
		response := ScratchCloseDialog new getUserResponse.
		response = #cancelled ifTrue: [^ self].
		response ifTrue: [
			self saveScratchProjectNoDialog.
			justSaved ifFalse: [^ self]]].

	Smalltalk snapshot: false andQuit: true.

]

{ #category : #byob }
ScratchFrameMorph >> randomProjectName [
	| dir projects |
"	dir := ScratchFileChooserDialog getDefaultFolderForType: #project."

	(FileSystem workingDirectory / 'Projects') exists 
		ifTrue: [ dir := FileSystem workingDirectory / 'Projects']
		ifFalse: [ Smalltalk quitPrimitive ].

	projects := dir fileNames
				select: [:fn | (fn asLowercase endsWith: '.sb')
						or: [(fn asLowercase endsWith: '.scratch')
						or: [fn asLowercase endsWith: '.ypr']]].
	projects size > 0 ifTrue: [^ dir fullNameFor: (projects asArray at: Random new next * projects size + 1)].
	^ nil
]

{ #category : #startup }
ScratchFrameMorph >> readDefaultNotes [
	"If there is a file named 'defaultNotes.txt' in the Scratch folder, read it in."

	| dir |
	DefaultNotes := ''.
	dir := FileSystem workingDirectory.
	(dir fileSystem exists: 'defaultNotes.txt') ifTrue: [
		DefaultNotes := (FileStream oldFileNamed: 'defaultNotes.txt') contentsOfEntireFile].

]

{ #category : #startup }
ScratchFrameMorph >> readSettingsFile [
	"Read my settings file and answer a Dictionary of settings."
	"ScratchFrameMorph new readSettingsFile"

	| f dict s tokens k |
	f := FileStream readOnlyFileNamedOrNil: 'BYOB.ini'.
	f ifNil: [^ Dictionary new].
	dict := Dictionary new.
	f contentsOfEntireFile lines do: [:line |
		s := line collect: [:c | (c asciiValue < 32) ifTrue: [Character space] ifFalse: [c]].
		s ifNotEmpty: [
			tokens := s findTokens: '='.
			k := tokens first trimBoth asLowercase.
			tokens size = 2
				ifTrue: [dict at: k put: tokens second trimBoth]
				ifFalse: [dict at: k put: '1']]].
	^ dict

]

{ #category : #private }
ScratchFrameMorph >> rebuildUIForNewLanguage [
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
ScratchFrameMorph >> recordBlockContrast: anInteger [
	"Record my language in the settings file."
	"ScratchFrameMorph new recordLanguage: 'English'"

	| fName f sz settings all |
	fName := (FileSystem workingDirectory / 'BYOB.ini') fullName.
	f := FileStream concreteStream new open: fName forWrite: true.
	f ifNil: [^ self].
	sz := f size.
	settings := (f next: sz) lines.
	settings := settings reject: [:s | s asLowercase beginsWith: 'blockcontrast='].
	settings := settings reject: [:s | all := s asByteArray asSet. (all size = 1) and: [all asArray first = 0]].
	settings := settings copyWith: ('BlockContrast=', anInteger printString).
	f position: 0.
	settings do: [:s | f nextPutAll: s, String crlf].
	[f position < sz] whileTrue: [f nextPut: 0 asCharacter].
	f close.

]

{ #category : #byob }
ScratchFrameMorph >> recordKeepOnStage: anInteger [
	"Record a setting in the settings file."

	| fName f sz settings all |
	fName := (FileSystem workingDirectory / 'BYOB.ini') fullName.
	f := FileStream concreteStream new open: fName forWrite: true.
	f ifNil: [^ self].
	sz := f size.
	settings := (f next: sz) lines.
	settings := settings reject: [:s | s asLowercase beginsWith: 'keepspritesonstage='].
	settings := settings reject: [:s | all := s asByteArray asSet. (all size = 1) and: [all asArray first = 0]].
	settings := settings copyWith: ('KeepSpritesOnStage=', anInteger printString).
	f position: 0.
	settings do: [:s | f nextPutAll: s, String crlf].
	[f position < sz] whileTrue: [f nextPut: 0 asCharacter].
	f close.

]

{ #category : #private }
ScratchFrameMorph >> recordLanguage: aString [
	"Record my language in the settings file."
	"ScratchFrameMorph new recordLanguage: 'English'"

	| fName f sz settings all |
	fName := (FileSystem workingDirectory / 'BYOB.ini') fullName.
	f := FileStream concreteStream new open: fName forWrite: true.
	f ifNil: [^ self].
	sz := f size.
	settings := (f next: sz) lines.
	settings := settings reject: [:s | s asLowercase beginsWith: 'language='].
	settings := settings reject: [:s | all := s asByteArray asSet. (all size = 1) and: [all asArray first = 0]].
	settings := settings copyWith: ('Language=', aString).
	f position: 0.
	settings do: [:s | f nextPutAll: s, String crlf].
	[f position < sz] whileTrue: [f nextPut: 0 asCharacter].
	f close.

]

{ #category : #byob }
ScratchFrameMorph >> recordScopeContrast: anInteger [
	"Record a setting in the settings file."

	| fName f sz settings all |
	fName := (FileSystem workingDirectory / 'BYOB.ini') fullName.
	f := FileStream concreteStream new open: fName forWrite: true.
	f ifNil: [^ self].
	sz := f size.
	settings := (f next: sz) lines.
	settings := settings reject: [:s | s asLowercase beginsWith: 'scopecontrast='].
	settings := settings reject: [:s | all := s asByteArray asSet. (all size = 1) and: [all asArray first = 0]].
	settings := settings copyWith: ('ScopeContrast=', anInteger printString).
	f position: 0.
	settings do: [:s | f nextPutAll: s, String crlf].
	[f position < sz] whileTrue: [f nextPut: 0 asCharacter].
	f close.

]

{ #category : #byob }
ScratchFrameMorph >> recordThreadSafeMode: anInteger [
	"Record a setting in the settings file."

	| fName f sz settings all |
	fName :=( FileSystem workingDirectory / 'BYOB.ini') fullName.
	f := FileStream concreteStream new open: fName forWrite: true.
	f ifNil: [^ self].
	sz := f size.
	settings := (f next: sz) lines.
	settings := settings reject: [:s | s asLowercase beginsWith: 'threadsafemode='].
	settings := settings reject: [:s | all := s asByteArray asSet. (all size = 1) and: [all asArray first = 0]].
	settings := settings copyWith: ('ThreadSafeMode=', anInteger printString).
	f position: 0.
	settings do: [:s | f nextPutAll: s, String crlf].
	[f position < sz] whileTrue: [f nextPut: 0 asCharacter].
	f close.

]

{ #category : #byob }
ScratchFrameMorph >> recordTranslucentDragging: anInteger [
	"Record a setting in the settings file."

	| fName f sz settings all |
	fName := (FileSystem workingDirectory / 'BYOB.ini') fullName.
	f := FileStream concreteStream new open: fName forWrite: true.
	f ifNil: [^ self].
	sz := f size.
	settings := (f next: sz) lines.
	settings := settings reject: [:s | s asLowercase beginsWith: 'translucentdragging='].
	settings := settings reject: [:s | all := s asByteArray asSet. (all size = 1) and: [all asArray first = 0]].
	settings := settings copyWith: ('TranslucentDragging=', anInteger printString).
	f position: 0.
	settings do: [:s | f nextPutAll: s, String crlf].
	[f position < sz] whileTrue: [f nextPut: 0 asCharacter].
	f close.

]

{ #category : #byob }
ScratchFrameMorph >> refreshBlocks [

	'updating...' 
		displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((workPane allMorphs) select: [:m| m isKindOf: ScriptableScratchMorph]) size * 3
		during: [:bar | | i | i := 0.

	(workPane submorphs copyWith: workPane) do: [:m |
	(m isKindOf: ScriptableScratchMorph) ifTrue: [
		i := i + 1. bar value: i.
		m convertStacksToTuples]].

	workPane allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			i := i + 1. bar value: i.
			m convertTuplesToDefinitions]].

	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			i := i + 1. bar value: i.
			m convertTuplesToStacks]].
	self updatePanes.
	self
		view: scriptsPane target
		tab: scriptsPane tabPane currentTab
		category: viewerPane currentCategory].

]

{ #category : #byob }
ScratchFrameMorph >> removeBlockEditor: aBlockEditor [
	blockEditors remove: aBlockEditor
]

{ #category : #uploading }
ScratchFrameMorph >> removeLastHistoryEntry [
	"Remove the last entry in the project history. This is done if an upload attempt fails or is cancelled."

	| lines s |
	lines := (projectInfo at: 'history' ifAbsent: ['']) lines.
	lines size = 0 ifTrue: [^ self].

	lines := lines copyFrom: 1 to: lines size - 1.

	s := WriteStream on: (String new: 1000).
	lines do: [:entry | s nextPutAll: entry; cr].
	projectInfo at: 'history' put: s contents.

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> renderingMenu [

	ScratchTranslator renderingMenu.

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> resaveAllProjects [
	"Resave all the projects in the given directory (to recompress them)."

	| dir |
	dir := ScratchFileChooserDialog chooseFolder: FileSystem workingDirectory.
	dir = #cancelled ifTrue: [^ self].

	dir allFileNamesDo: [:fn |
		((fn asLowercase endsWith: '.sb') and:
		 [(fn endsWith: '-2.sb') not]) ifTrue: [
			self openScratchProjectNamed: fn.
			World doOneCycleNoInput.
"			projectName := (fn copyFrom: 1 to: fn size - 3), '-3.sb'."
			self writeScratchProject]].

]

{ #category : #uploading }
ScratchFrameMorph >> revertToUncompressedMedia [
	"Revert to uncomprssed media after uploading this project."

	self allProjectMedia do: [:m | m revertToUncompressed].

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> saveImageForEndUser [

	(self confirm: '
Close non-Scratch windows and save this
image in end-user (fillScreen) mode?') ifFalse: [^ self].

	ScratchFrameMorph isXO ifTrue: [PhratchPreferences useLargeFonts].

	self setLanguage: 'en'.

	self enterNormalMode.
	self blockContrastStrong.
	ScriptableScratchMorph keepOnStage: true.
	self recordKeepOnStage: 1. 
	EventHatMorph threadSafeMode: false.
	self recordThreadSafeMode: 0.

	BlockLabelFragmentDialog isExpanded: false.

	World submorphs do: [:m |
		(m isKindOf: SystemWindow) ifTrue: [m delete]].
	self clearStage.

	Display newDepth: 32.
	self fillScreenOn.
	World doOneCycleNow.
	Smalltalk snapshot: true andQuit: true.
	self startup.
	Sensor useOSEvents: true.

]

{ #category : #'file read/write' }
ScratchFrameMorph >> saveScratchProject [

	| fName result |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	self stopAll.

	fName := ScratchFileChooserDialog saveScratchFileFor: self.
	(fName size = 0 or: [fName = #cancelled]) ifTrue: [^ self].

	[(result := ScratchFileChooserDialog confirmFileOverwriteIfExisting: fName) = false] whileTrue: [
		fName := ScratchFileChooserDialog saveScratchFileFor: self.
		(fName size = 0 or: [fName = #cancelled]) ifTrue: [^ self]].
	(result = #cancelled) ifTrue: [^ self].

"
	(ScriptableScratchMorph currentEncoding = #scratch) ifTrue: [
		(DialogBoxMorph new 
			title: 'Caution! Converting Scratch to BYOB'; 
			withButtonsForYes: true no: true okay: false cancel: false;
			message: 'You will not be able to open this file in Scratch. Proceed anyway?';
			getUserResponse) ifFalse: [^self ]].
"
	self updateLastHistoryEntryIfNeeded.

"	fName := (self nameFromFileName: fName), '.sb'."

	projectDirectory := fName asFileReference parent.
	fName := (self nameFromFileName: fName), '.ypr'.
	projectName :=fName asFileReference basename.

	projectInfo at: 'author' put: author.
	self updateHistoryProjectName: projectName op: 'save'.
	self writeScratchProject.

]

{ #category : #'file read/write' }
ScratchFrameMorph >> saveScratchProjectNoDialog [

	| fName dir |
	self closeMediaEditorsAndDialogs ifFalse: [^ self].

	projectName ifNil: [projectName := ''].
	fName := self nameFromFileName: projectName.

	dir := ScratchFileChooserDialog getLastFolderForType: #project.
"	(fName size = 0 | (dir fileExists: fName , '.sb') not) ifTrue: [^ self saveScratchProject]."
	(fName size = 0 | (dir asFileReference / fName , 'ypr') exists not) ifTrue: [^ self saveScratchProject].
	ScratchFileChooserDialog lastFolderIsSampleProjectsFolder ifTrue:  [^ self saveScratchProject].

"
	(ScriptableScratchMorph currentEncoding = #scratch) ifTrue: [
		(DialogBoxMorph new 
			title: 'Caution! Converting Scratch to BYOB'; 
			withButtonsForYes: true no: true okay: false cancel: false;
			message: 'You will not be able to open this file in Scratch. Proceed anyway?';
			getUserResponse) ifFalse: [^self ]].
"
	self updateLastHistoryEntryIfNeeded.

"	projectName := FileDirectory localNameFor: (fName, '.sb'). " "ignore path, if any; save in the original project directory"
	projectName := dir basename.  "ignore path, if any; save in the original project directory"
	projectDirectory := dir.

	self updateHistoryProjectName: projectName op: 'save'.
	self writeScratchProject.

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> scratchObjects [
	"Answer a collection of all the scratch objects in the work pane."

	^ self workPane submorphs select: [:m | m isKindOf: ScriptableScratchMorph]

]

{ #category : #watchers }
ScratchFrameMorph >> scratchWatchers [
	"Answer a collection of all the scratch watchers in the work pane."

	^ self workPane submorphs select: [:m | m isKindOf: WatcherMorph]

]

{ #category : #accessing }
ScratchFrameMorph >> scriptsPane [

	^ scriptsPane

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> scriptsStringForUpload [

	| s scripts |
	s := WriteStream on: (String new: 10000).
	((Array with: workPane), self scratchObjects) do: [:obj |
		scripts := obj blocksBin submorphs select: [:m | m isKindOf: HatBlockMorph].
		scripts size > 0 ifTrue: [
			s nextPutAll: 'Scripts for ', obj objName, ':'; cr; cr.
			scripts do: [:hat | self printTupleList: hat tupleSequence on: s. s cr].
			s cr]].
	^ s contents

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> setDefaultSprite [
	"Look for default sprite in Media directory. If none found, use the DefaultCatSprite"

	| d f data importedProject fName |

	DefaultSprite := nil.

	"if dfault.ysp exists, use that"
	d := ScratchFileChooserDialog getDefaultFolderForType: #costume.
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
				(m isKindOf: ScratchSpriteMorph) ifTrue: [DefaultSprite := m].
				^ self]]].

	"if default image exists, use the image and add 'pop' sound"
	#(gif png jpg bmp) do: [:e |
		fName := 'default.', e.
		(d / fName) asFileReference exists ifTrue: [
			DefaultSprite := ScratchSpriteMorph new
				importMedia: (d / fName) fullName;
				addMediaItem: (SoundMedia new
					mediaName: 'pop' localized;
					sound: ScratchSpriteMorph popSound).
			^ self]].

]

{ #category : #private }
ScratchFrameMorph >> setLanguage: aString [
	"Set my language and update my blocks."

	| tempJustSaved |

	self closeDialogBoxes.

	'updating...' 
		displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((workPane allMorphs) select: [:m| m isKindOf: ScriptableScratchMorph]) size * 2
		during: [:bar | | i | i := 0.

	tempJustSaved := justSaved.
	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			i := i + 1. bar value: i.
			m convertStacksToTuples]].

	ScratchTranslator setLanguage: (ScratchTranslator isoCodeForName: aString).
	viewerPane rebuildCategorySelectors.

	(workPane submorphs copyWith: workPane) do: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
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
ScratchFrameMorph >> setSingleStepping [
	"Ask whether script should be single-stepped."

	| menu mSecs |
	menu := MenuMorph new title: 'Single-step speed?'.
	menu add: 'Turbo speed' 
		target: self 
		selector: #blockHighlightMSecs:
		argument: 0.
	menu add: 'Normal' 
		target: self 
		selector: #blockHighlightMSecs:
		argument: 1.
	menu add: 'Flash blocks (fast)' 
		target: self 
		selector: #blockHighlightMSecs:
		argument: 30.
	menu add: 'Flash blocks (slow)' 
		target: self 
		selector: #blockHighlightMSecs:
		argument: 200.
	menu localize; invokeModal: true.
]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> shareMenu: aMenuTitleMorph [

	| menu stage |
	menu := MenuMorph new defaultTarget: self.
	menu add: 'Compile This Project' action: #makeExe.
	menu addLine.
	self addServerCommandsTo: menu.

	stage := workPane.
	stage ifNotNil: [
		(stage scratchServer notNil and: 
		[stage scratchServer sessionInProgress])
			ifTrue: [
				menu add: 'share this sprite' action: #shareSprite ]].

	menu localize.

	#(1) do: [:n |
		menu labels at: n put:
			((menu labels at: n) contents copyFrom: 1 to: (menu labels at: n) contents size - 1), ScratchTranslator ellipsesSuffix].

	menu invokeAt: (aMenuTitleMorph bottomLeft + (0@10)) in: World.


]

{ #category : #byob }
ScratchFrameMorph >> shareSprite [

	scriptsPane target shareObject.

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> shoutGo [
	"Broadcasts the start event to all objects and processes."

	self stopAll.
	workPane broadcastEventNamed: 'Scratch-StartClicked' with: 0.
	flagButton on.
	self showPause.
	World displayWorldSafely.  "force button flash"
	(Delay forMilliseconds:  20)wait.

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> showMotorBlocks [

	workPane showMotorBlocks: true.
	viewerPane currentCategory: 'motion'.
	viewerPane pageViewer vScrollRelative: 1.0.
]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> showNetworkAddress [
	"Display my IP address. This is a temporary feature to allow connected multiple Scratch computers in a peer-to-peer configuration without the help of a presence server."

	| localAddr wanAddr msg |
	Socket initializeNetwork.
	localAddr := NetNameResolver localHostAddress.
	wanAddr := nil.
"	wanAddr := ScratchServer getIPAddressFromServer."

	msg := NetNameResolver stringFromAddress: localAddr.
	(wanAddr notNil and: [wanAddr ~= localAddr]) ifTrue: [
		msg := msg, String cr, 'Internet:   ', (NetNameResolver stringFromAddress: wanAddr)].

	DialogBoxMorph inform: msg title: 'IP Address'.

]

{ #category : #byob }
ScratchFrameMorph >> showPause [

	pauseButton
		onForm: (ScratchFrameMorph skinAt: #pauseButtonGrayPressed)
		offForm: (ScratchFrameMorph skinAt: #pauseButtonGray)
		overForm: (ScratchFrameMorph skinAt: #pauseButtonGrayPressed)

]

{ #category : #byob }
ScratchFrameMorph >> showPlay [

	pauseButton
		onForm: (ScratchFrameMorph skinAt: #playButtonGrayPressed)
		offForm: (ScratchFrameMorph skinAt: #playButtonGray)
		overForm: (ScratchFrameMorph skinAt: #playButtonGrayPressed)

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> showSensorBoard [

	| sb |
	sb := workPane sensorBoard.
	sb position: self workPane position + 20.
	self workPane addMorph: sb.
	sb tryToOpenPort.
	World startSteppingSubmorphsOf: sb.

]

{ #category : #watchers }
ScratchFrameMorph >> showWatcher: watcher [
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

{ #category : #'scat-additions' }
ScratchFrameMorph >> stageMorph [
"Horrid? Yes! But working!"
	 ^ self submorphs detect: [:each | each isKindOf: ScratchStageMorph]
]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> startHostingScratchSession [
	"Start running the Scratch server, allowing Scratch and other applications to interact with this Scratch remotely."

	| server |
	workPane scratchServer ifNil: [
		server := ScratchServer new.
		server stage: workPane.
		workPane scratchServer: server].

	workPane scratchServer startHosting.
	self showNetworkAddress.

]

{ #category : #startup }
ScratchFrameMorph >> startup [

	| startupFileNames fileName arg presentationMode |
"
	HostSystemMenus startUp.
	HostSystemMenus menuBarControler reviseHostMenus.
"
	ScriptableScratchMorph randomInit.
	ScratchTranslator detectRenderPlugin.
	ScratchTranslator importLanguagesList.

	ScratchFrameMorph readShareServerEntry.
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
	loginPassword := ''.
	justSaved := true.
	presentationMode := false.
	quitFlag := false.
	
	startupFileNames := "InputSensor startupFileNames asOrderedCollection" #().
	
	
	2 to: 10 do: [:i |
		arg := Smalltalk vm getSystemAttribute: i.
		(arg notNil and: [arg size > 0]) ifTrue: [
			startupFileNames addLast: (ScratchPlugin primShortToLongPath: arg)]].

	startupFileNames do: [:n |
		(n asLowercase = 'presentation') ifTrue: [
			quitFlag := true. 
			presentationMode := true.
			self isHidden: true.
			Display fillBlack].
		(n asLowercase = 'fullscreen') ifTrue: [TakeOverScreen := true]].
"
	TakeOverScreen ifTrue: [
		Display fullScreenMode: true.
		World restoreDisplay].
"
			TakeOverScreen := false.

	self enterQuarterModeIfSmallScreen.

	fileName := startupFileNames
		detect: [:fn |
			(fn asLowercase endsWith: '.sb') or: [(fn asLowercase endsWith: '.scratch') or: [fn asLowercase endsWith: '.ypr']]]
		ifNone: [presentationMode ifTrue: [self randomProjectName]]. "this is BYOB's screensaver feature -jens"
	fileName ifNotNil: [
		presentationMode ifTrue: [Display fillColor: Color black].
		self openScratchProjectNamed: fileName.
		presentationMode ifTrue: [self enterPresentationMode; shoutGo].
		^ self].

	viewerPane currentCategory: 'motion'.
	self setDefaultSprite.
	self newScratchProject.

	fileName := startupFileNames
		detect: [:fn | (fn asLowercase endsWith: '.sprite') or: [fn asLowercase endsWith: '.ysp']]
		ifNone: [^ self].

	"open a .sprite file"
	workPane submorphs do: [:m | (m isKindOf: ScratchSpriteMorph) ifTrue: [m deleteSprite]].
	self importSpriteOrProject: fileName.

]

{ #category : #stepping }
ScratchFrameMorph >> step [
	"Run each process until it gives up control, then filter out any processes that have terminated."

	| screenExtent oldJustSaved |

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
		ScriptableScratchMorph scratchOrigin: workPane center.
		viewerPane target isNil 
			ifTrue: [workPane viewBlocksAndScripts]
			ifFalse: [viewerPane target isInWorld ifFalse: [workPane viewBlocksAndScriptsQuickly]]].

	Sensor processOSMenuEvents.
	paintingInProgress ifTrue: [^ self].

"	workPane scratchServer ifNotNil: [workPane scratchServer stepServer]." "see later"
"	self checkForWeDo." "simplify at the moment"
	self updateToolButtons.
	self processWhenConditions.
	self processKeyboardEvents. 
	workPane stepProcesses.
"	workPane scratchServer ifNotNil: [workPane scratchServer stepServer]." "see later"
"	self processDroppedFiles." "simplify at the moment"
	workPane processesToRun size > 0
		ifTrue: [flagButton on]
		ifFalse: [flagButton off. self showPause]

]

{ #category : #stepping }
ScratchFrameMorph >> stepTime [
	"Every screen update cycle."

	^ 0

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> stopAll [
	"Tell my workPane to stop everything."

	| oldJustSaved |
	oldJustSaved := justSaved.
	workPane stopAll.
	pauseButton off.
	justSaved := oldJustSaved.

]

{ #category : #'file read/write' }
ScratchFrameMorph >> storeProjectInfoOn: aBinaryStream [

	| s |
	projectInfo at: 'thumbnail' put: workPane thumbnailForm.
	projectInfo at: 'keepOnStage' put: ScriptableScratchMorph keepOnStage.

	s := WriteStream on: (ByteArray new: 100000).
	ObjStream new storeObj: projectInfo on: s.

	aBinaryStream uint32: s size.
	aBinaryStream nextPutAll: s contents.


]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> surpriseSpriteMorph [

	| fileName f el m e |
	self world activeHand toolType: nil.
	self paintingInProgress ifTrue: [^ Beeper beep].

	fileName := self nextSurpriseCostumeName.
	fileName ifNil: [
		^ self addAndView: ScratchFrameMorph defaultSprite fullCopy].

	[f := Form fromFileNamed: fileName] ifError: [^ self].
	el := ImageMedia new form: (ScratchFrameMorph scaledFormForPaintEditor: f).
	m := ScratchSpriteMorph new soleCostume: el.

	el mediaName: (m unusedMediaNameFromBaseName: fileName asFileReference  base).
	self addAndView: m.

	e := (workPane extent - m extent) abs // 2.
	m referencePosition: ((e x negated) to: e x) atRandom @ ((e y negated) to: e y) atRandom.

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> toggleErrorCatcher [

	UseErrorCatcher := UseErrorCatcher not.

]

{ #category : #byob }
ScratchFrameMorph >> toggleKeepSpritesOnStage [
	| choice |
	ScriptableScratchMorph keepOnStage: ScriptableScratchMorph keepOnStage not.
	ScriptableScratchMorph keepOnStage
		ifTrue: [choice := 1]
		ifFalse: [choice := 0].
	self recordKeepOnStage: choice
]

{ #category : #byob }
ScratchFrameMorph >> togglePause [
	workPane togglePause.
	workPane isPaused
		ifTrue: [self showPlay]
		ifFalse: [self showPause]

]

{ #category : #byob }
ScratchFrameMorph >> toggleScopeContrast [
	| choice |
	VariableFrame scopeContrast: VariableFrame scopeContrast not.
	VariableFrame scopeContrast
		ifTrue: [choice := 1]
		ifFalse: [choice := 0].
	self refreshBlocks.
	self recordScopeContrast: choice
]

{ #category : #byob }
ScratchFrameMorph >> toggleShowMotorBlocks [

	workPane showMotorBlocks
		ifTrue: [self hideMotorBlocks]
		ifFalse: [self showMotorBlocks]
]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> toggleSingleStepping [
	"Toggle single stepping."

	ScratchProcess blockHighlightMSecs <= 1
		ifTrue: [ScratchProcess blockHighlightMSecs: 60]
		ifFalse: [ScratchProcess blockHighlightMSecs: 1].

]

{ #category : #byob }
ScratchFrameMorph >> toggleThreadSafeMode [
	| choice |
	EventHatMorph threadSafeMode: EventHatMorph threadSafeMode not.
	EventHatMorph threadSafeMode
		ifTrue: [choice := 1]
		ifFalse: [choice := 0].
	self recordThreadSafeMode: choice
]

{ #category : #byob }
ScratchFrameMorph >> toggleTranslucentDragging [
	| choice |
	HandMorph translucentWhenDragging: HandMorph translucentWhenDragging not.
	HandMorph translucentWhenDragging
		ifTrue: [choice := 1]
		ifFalse: [choice := 0].
	self recordTranslucentDragging: choice
]

{ #category : #byob }
ScratchFrameMorph >> toggleTurboMode [

	self isTurbo ifTrue: [
		^ ScratchProcess blockHighlightMSecs: 1].
	ScratchProcess blockHighlightMSecs: 0
]

{ #category : #byob }
ScratchFrameMorph >> toggleZebraColoring [

	BlockMorph contrast = #off
		ifTrue: [self blockContrastStrong]
		ifFalse: [self blockContrastOff]
]

{ #category : #byob }
ScratchFrameMorph >> undoLastDrop [

	scriptsPane currentCategory: 'Scripts'.
	scriptsPane target blocksBin undoLastDrop
]

{ #category : #'tools (no longer used)' }
ScratchFrameMorph >> undoTool [

	| m newOwner oldName |
	self paintingInProgress ifTrue: [^ Beeper beep].
	Clipboard ifNil: [^ self beep].
	self activeHand toolType: nil.
	m := Clipboard fullCopy.
	((m isKindOf: BlockMorph) and: [m isCustomBlock and: [m definition isNil]])
		ifTrue: [^ self beep].
	"Reset clipboard to empty since an undo just happened"
	
	(m isKindOf: BlockMorph) ifTrue: [
		newOwner := viewerPane target.
		newOwner ifNotNil: [m newScriptOwner: newOwner].
		(viewerPane currentCategory = 'variables') ifTrue: [
			"update 'variables' category if it is showing"
			viewerPane currentCategory: 'variables']].

	(m isKindOf: ScratchSpriteMorph) ifTrue: [  "sprite; add to stage"
		m filterReset; show.
		m objName: Clipboard objName.
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
ScratchFrameMorph >> uniqueSummaryFileName [

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
ScratchFrameMorph >> unloadAllUnusedCustomBlocks [

	workPane unloadAllUnusedCustomBlocks
]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> unusedNameStartingWith: prefix [
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
ScratchFrameMorph >> unusedPositionForWatcher [
	"Return an unused watcher position on the stage."

	| watchers positions rowH x y newX |
	watchers := (watcherPositions values collect: [:r | r first]) select: [:w | w notNil].
	positions := watchers collect: [:w | w position].

	(watchers size > 0)
		ifTrue: [rowH := (watchers at: 1) height]
		ifFalse: [rowH := 25].
	x := workPane left + 10.
	y := workPane top + 10.
	[positions includes: (x@y)] whileTrue: [
		y := y + rowH.
		(y > (workPane bottom - rowH)) ifTrue: [  "start a new column"
			newX := 0.
			watchers do: [:w |
				w left < (x + 20) ifTrue: [newX := newX max: w right + 4]].
			newX > (workPane right - 20) ifTrue: [
				^ ((10 to: 400) atRandom) @ ((10 to: 330) atRandom)].  "no free location"
			x := newX.
			y := workPane top + 10]].

	^ x@y

]

{ #category : #'file read/write' }
ScratchFrameMorph >> updateHistoryProjectName: projName op: operation [
	"The given user is about to save or upload a project with the given name. Update the project history. operation is a string specifying the operation."

	| timestamp tab history platform osVersion |
	projectInfo removeKey: 'organization' ifAbsent: [].	"obsolete"
	projectInfo at: 'scratch-version' put: Version.

	timestamp := (Date today printFormat: #(3 2 1 $- 1 1)), ' ', Time now print24.
	tab := String tab.

	history := projectInfo at: 'history' ifAbsent: [''].
	history := history, timestamp, tab.
	history := history, operation, tab, (self nameFromFileName: projName), tab, loginName, tab, author.
	history := history, String cr.
	projectInfo at: 'history' put: history.

	"record other data"
	projectInfo at: 'scratch-version' put: Version.
	projectInfo at: 'language' put: ScratchTranslator currentLanguage.

	platform := OSPlatform platformName.
	platform ifNil: [platform := 'unknown'].
	'linux' = platform ifTrue: [
		Display extent = (1200@900) ifTrue: [platform := 'XO']].
	projectInfo at: 'platform' put: platform.

	osVersion :=  OSPlatform osVersion.
	osVersion ifNil: [osVersion := 'unknown'].
	projectInfo at: 'os-version' put: osVersion.

	(workPane scratchServer notNil and:
	 [workPane scratchServer isHosting])
		ifTrue: [projectInfo at: 'isHosting' put: true]
		ifFalse: [projectInfo removeKey: 'isHosting' ifAbsent: []].

	(self allBlocksString includesSubstring: 'motor')
		ifTrue: [projectInfo at: 'hasMotorBlocks' put: true]
		ifFalse: [projectInfo removeKey: 'hasMotorBlocks' ifAbsent: []].

	workPane penTrailsForm
		ifNil: [projectInfo removeKey: 'penTrails' ifAbsent: []]
		ifNotNil: [projectInfo at: 'penTrails' put: workPane penTrailsForm].


]

{ #category : #'file read/write' }
ScratchFrameMorph >> updateLastHistoryEntryIfNeeded [
	"If the the last entry in this project's history is an old-sytle entry (i.e. one that does not include the project name and author) update it."

	| lines lastLine oldAuthor tab s |
	lines := (projectInfo at: 'history' ifAbsent: ['']) lines.
	lines size = 0 ifTrue: [^ self].
	lastLine := lines at: lines size.
	(lastLine includes: Character tab) ifTrue: [^ self].  "last line is already a new-style entry"

	oldAuthor := projectInfo at: 'author' ifAbsent: [''].
	tab := String tab.
	lastLine := lastLine, tab, 'old', tab, projectName, tab, "blank scratchr name" tab, oldAuthor.
	lines at: lines size put: lastLine.

	s := WriteStream on: (String new: 1000).
	lines do: [:entry | s nextPutAll: entry; cr].
	projectInfo at: 'history' put: s contents.

]

{ #category : #other }
ScratchFrameMorph >> updateMediaCategoryFor: anObject [
	"Update the media viewer for the given object's media category. Do nothing if the media category of the given object is not being viewed."

	scriptsPane target = anObject ifTrue: [
		scriptsPane categoryChanged: 'Sounds'.
		scriptsPane categoryChanged: 'Costumes'].
	viewerPane target = anObject ifTrue: [
		viewerPane categoryChanged: 'Sound'].

]

{ #category : #private }
ScratchFrameMorph >> updatePanes [

	| p |
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

	workPane sensorBoard owner
		ifNil: [p := nil]
		ifNotNil: [p := workPane sensorBoard position].

	workPane sensorBoard addReadouts.
	p ifNotNil:[
		self showSensorBoard.
		workPane sensorBoard position: p].

	libraryPane clearLibrary.

	self scratchWatchers do: [:w | w languageChanged].
	self listWatchers do: [:w | w fixLayoutForNewLanguage].

	World startSteppingSubmorphsOf: self.
	self fixLayout.
	scriptsPane fixLayout.
	self updateViewModeButtons.

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> updatePenPositions [
	"Update the pen positions of my sprites when going between normal and presentation mode."

	| stage |
	stage := self workPane.
	ScriptableScratchMorph scratchOrigin: stage center.
	stage submorphsDo: [:m | stage updatePenPositionFor: m].

]

{ #category : #private }
ScratchFrameMorph >> updateProjectName [
	"Update the project name display in the Scratch title bar."

	| s |
	projectName ifNil: [projectName := ''].
	projectTitleMorph contents: (self nameFromFileName: projectName).

	projectTitleMorph contents size > 0
		ifTrue: [s := projectTitleMorph contents, '- BYOB']
		ifFalse: [s := 'BYOB ', Version].
	ScratchPlugin primSetWindowTitle: s.

	self fixLayout.

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> updateToolButtons [
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
ScratchFrameMorph >> updateViewModeButtons [

	viewModeButtons do: [:b | b off].
	viewModeButtons do: [:b |
		(b actionSelector = #enterQuarterMode and: [viewMode = #quarter])
			ifTrue: [b on].
		(b actionSelector = #enterNormalMode and: [viewMode = #normal])
			ifTrue: [b on].
		(b actionSelector = #enterPresentationMode and: [viewMode = #presentation])
			ifTrue: [b on]].

]

{ #category : #other }
ScratchFrameMorph >> view: aMorph tab: t category: c [
	"Add given morph to the work pane and view it."

	scriptsPane target: aMorph.
	scriptsPane tabPane currentTab: t.
	viewerPane
		target: aMorph;
		currentCategory: c.

]

{ #category : #accessing }
ScratchFrameMorph >> viewMode [

	^ viewMode

]

{ #category : #accessing }
ScratchFrameMorph >> viewerPane [

	^ viewerPane

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> wantsDroppedMorph: aMorph event: evt [

	^ (aMorph isKindOf: BlockMorph) or: [
	  	(aMorph isKindOf: ScriptableScratchMorph) or: [
			(aMorph isKindOf: ScratchCommentMorph)]].

]

{ #category : #'event handling' }
ScratchFrameMorph >> wantsKeyboardFocusFor: aSubmorph [
	"Don't allow shift-click edit and select in random label strings."

	^ false

]

{ #category : #watchers }
ScratchFrameMorph >> watcherForBlock: aBlockMorph [
	"Answer a watcher for the given block if there is one currently showing on the stage."

	| pair |
	pair := watcherPositions
		at: {aBlockMorph getAssociatedSprite. aBlockMorph selectorAndArg}
		ifAbsent: [^ nil].

	^ pair first


]

{ #category : #watchers }
ScratchFrameMorph >> watcherShowingFor: sprite selectorAndArg: selectorAndArg [
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
ScratchFrameMorph >> workPane [

	^ workPane

]

{ #category : #accessing }
ScratchFrameMorph >> workPane: aWorkPane [

	workPane := aWorkPane 

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> writeMultipleSummaries [
	"Write the summary for all Scratch projects in a given folder."

	| dir |
	dir := ScratchFileChooserDialog chooseFolder: (FileSystem workingDirectory fullName).
	dir = #cancelled ifTrue: [^ self].

	(dir) files do: [:fn |
		(fn basename endsWith: '.scratch') | (fn basename endsWith: '.sb')  | (fn basename endsWith: '.ypr') ifTrue: [
			self openScratchProjectNamed: fn.
			"World doOneCycleNoInput."
			self writeSummaryFile: fn]].

]

{ #category : #'file read/write' }
ScratchFrameMorph >> writeScratchProject [
	"Write this Scratch project to the file named projectFile in the project directory. Called by saveScratchProject."

	| oldScriptsTarget oldTab oldViewerCategory oldPosition saveError out |
	self stopAll.

	ObjStream initialize. "just to make sure this works in filed-in changesets, -Jens"

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

	ScriptableScratchMorph buildBlockSpecDictionary.



	'saving...' 
		displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((workPane allMorphs) select: [:m| m isKindOf: ScriptableScratchMorph]) size * 2
		during: [:bar | | i | i := 0.

	workPane allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			i := i + 1. bar value: i.
			(m isKindOf: ScratchSpriteMorph)
				ifTrue: [m cacheRefPos].
			(m blocksBin isKindOf: ScratchSpriteMorph) ifTrue: [  m blocksBin allMorphsDo: [:b |
				(b isKindOf: BlockMorph) ifTrue: [b stop]]].
			m convertStacksToTuples]].

	saveError := nil.
	[ 
		out := FileStream newFileNamed: (self unusedNameStartingWith: 'tmp').
		out
			ifNil: [saveError := 'Folder may be locked or read-only']
			ifNotNil: [
				out binary.
				out nextPutAll: 'BloxExpV01' asByteArray. "changed the internal version marker for the byob-prototype -Jens"
				self storeProjectInfoOn: out.
				ObjStream new storeObj: workPane on: out.
				out close].
	] ifError: [:err :rcvr |
		out ifNotNil: [
			[	out close.
				projectDirectory deleteFileNamed: out localName.
			] ifError: []]. 
		saveError := err].

	workPane allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			i := i + 1. bar value: i.
			m convertTuplesToStacks]]].

	self addMorph: (workPane position: oldPosition).
	oldScriptsTarget ifNil: [oldScriptsTarget := workPane].
	oldScriptsTarget viewBlocksAndScripts.
	scriptsPane tabPane currentTab: oldTab.
	viewerPane currentCategory: oldViewerCategory.
	self updatePenPositions.
	ScriptableScratchMorph decodeAsByob. "remember that we save this project in BYOB format"

	saveError
		ifNil: [
			justSaved := true.
			self updateProjectName.
			(projectDirectory / projectName) delete.
			[(projectDirectory / out localName) renameTo: projectName]
				ifError: [^ self inform: 'Save failed' withDetails: 'Is the folder read-only?' localized].
			FilePluginPrims new setMacFileNamed: (projectDirectory / projectName) fullName type: 'STyb' creator: 'BYOB']
		ifNotNil: [
			projectName := ''.
			self inform: 'Save failed' withDetails: saveError].

]

{ #category : #'falta adaptar' }
ScratchFrameMorph >> writeScratchProjectOn: aStream [
	"Write this Scratch project in a serialized form on the given stream."

	| oldScriptsTarget oldTab oldViewerCategory oldPosition storeError |
	self stopAll.
	self world ifNotNil: [self world activeHand newKeyboardFocus: nil].  "terminates active editor"

	oldScriptsTarget := scriptsPane target.
	oldTab := scriptsPane tabPane currentTab.
	oldViewerCategory := viewerPane currentCategory.
	scriptsPane target: nil.

	workPane updateSpritesList.
	oldPosition := workPane position.
	workPane delete; position: 0@0.
	self updatePenPositions.

	ScriptableScratchMorph buildBlockSpecDictionary.
	workPane allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			m blocksBin allMorphsDo: [:b |
				(b isKindOf: BlockMorph) ifTrue: [b stop]].
			m convertStacksToTuples]].

	storeError := nil.
	[	aStream nextPutAll: 'ScratchV02' asByteArray.
		self storeProjectInfoOn: aStream.
		ObjStream new storeObj: workPane on: aStream.
	] ifError: [:err :rcvr | storeError := err].

	workPane allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			m convertTuplesToStacks]].

	self addMorph: (workPane position: oldPosition).
	oldScriptsTarget ifNil: [oldScriptsTarget := workPane].
	oldScriptsTarget viewBlocksAndScripts.
	scriptsPane tabPane currentTab: oldTab.
	viewerPane currentCategory: oldViewerCategory.
	self updatePenPositions.

	storeError ifNotNil: [self error: storeError].

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> writeSummaryFile [
	"Write a summary of this project to a file."

	self writeSummaryFile: self projectDirectory.

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> writeSummaryFile: fullFile [
	"Write a summary of this project to a file."

	| s sprites f fName fullFileName |
	s := WriteStream on: (String new: 10000).
	fullFileName := fullFile fullName.
	s nextPutAll: 'Project: ', self projectName; crlf.
	fullFileName size > 0 ifTrue: [s nextPutAll: 'Location: ', fullFileName; crlf].
	(projectInfo includesKey: 'author') ifTrue: [
		s nextPutAll: 'Author: ', (projectInfo at: 'author'); crlf].
	(projectInfo includesKey: 'scratch-version') ifTrue: [
		s nextPutAll: 'Scratch: ', (projectInfo at: 'scratch-version'); crlf].
	(projectInfo includesKey: 'comment') ifTrue: [
		s nextPutAll: 'Notes:'; crlf.
		(projectInfo at: 'comment') lines do: [:l | s nextPutAll: '    ', l; crlf].
		s crlf].
	(projectInfo includesKey: 'history') ifTrue: [
		s nextPutAll: 'History:'; crlf.
		(projectInfo at: 'history') lines do: [:l | s nextPutAll: '    ', l; crlf].
		s crlf].

	self writeSummaryTotalsOn: s.
	s nextPutAll: '--------'; crlf.
	workPane printSummaryOn: s.
	sprites := workPane submorphs select: [:m | m isKindOf: ScratchSpriteMorph].
	sprites do: [:m |
		s skip: -2.  "remove last crlf"
		s nextPutAll: '--------'; crlf.
		m printSummaryOn: s].
	s nextPutAll: '--------'; crlf.

	TextEditor new clipboardTextPut: s contents asText.

	fName := fullFileName.
	fullFileName size = 0
		ifTrue: [
			fName := ScratchFileChooserDialog
				chooseNewFileDefault: self uniqueSummaryFileName
				title: 'File Name?'
				type: #projectSummary.
			fName = #cancelled ifTrue: [^ self]]
		ifFalse: [
			fName := self uniqueSummaryFileName].

	f := StandardFileStream newScratchFileNamed: (fullFile parent) / fName.
	f ifNil: [^ self].
	f nextPutAll: s contents.
	f close.

]

{ #category : #'menu/button actions' }
ScratchFrameMorph >> writeSummaryTotalsOn: aStream [
	"Write the totals for this project on the given stream."

	| sprites uniqueCostumes uniqueSounds stackCount |
	sprites := workPane submorphs select: [:m | m isKindOf: ScriptableScratchMorph].
	sprites := sprites asArray copyWith: workPane.
	uniqueCostumes := IdentitySet new: 100.
	uniqueSounds := IdentitySet new: 100.
	stackCount := 0.
	sprites do: [:m |
		m media do: [:item |
			item isImage ifTrue: [uniqueCostumes add: item form].
			item isSound ifTrue: [uniqueSounds add: item sound]].
		stackCount := stackCount + m blocksBin submorphCount].

	aStream nextPutAll: 'Totals: '; crlf.
	aStream nextPutAll: '    Sprites: ', (sprites size - 1) printString; crlf.
	aStream nextPutAll: '    Stacks: ', stackCount printString; crlf.
	aStream nextPutAll: '    Unique costumes: ', uniqueCostumes size printString; crlf.
	aStream nextPutAll: '    Unique sounds: ', uniqueSounds size printString; crlf.

]

{ #category : #'tools (no longer used)' }
ScratchFrameMorph >> zoomInTool [

	| hand cursorForm offset |
	self paintingInProgress ifTrue: [^ Beeper beep].
	hand := self world activeHand.
	hand toolType: 'ZoomInTool'.

	cursorForm := ScratchFrameMorph skinAt: #zoomInCursor.
	offset := 8@8.

	ScratchFrameMorph isXO ifTrue: [
		cursorForm := cursorForm magnifyBy: 1.5.
		offset := (offset * 1.5) rounded].

	hand showTemporaryCursor: cursorForm hotSpotOffset: offset.

]

{ #category : #'tools (no longer used)' }
ScratchFrameMorph >> zoomOutTool [

	| hand cursorForm offset |
	self paintingInProgress ifTrue: [^ Beeper beep].
	hand := self world activeHand.
	hand toolType: 'ZoomOutTool'.

	cursorForm := ScratchFrameMorph skinAt: #zoomOutCursor.
	offset := 8@8.

	ScratchFrameMorph isXO ifTrue: [
		cursorForm := cursorForm magnifyBy: 1.5.
		offset := (offset * 1.5) rounded].

	hand showTemporaryCursor: cursorForm hotSpotOffset: offset.


]
