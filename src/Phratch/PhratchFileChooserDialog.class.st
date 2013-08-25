"
I am a File Chooser dialog box for Scratch. My submorphs vary according to my function. For example, I may show a project thumbnail, I may have a typein field to allow the user to enter a new file name, or I may have buttons to create or paint a new sprite.

You can also use me to select an existing or create a new file or folder. Some examples:

  ScratchFileChooserDialog chooseFile
  ScratchFileChooserDialog chooseFile: FileDirectory default enableNew: false

"
Class {
	#name : #PhratchFileChooserDialog,
	#superclass : #DialogBoxMorph,
	#instVars : [
		'list',
		'choosingFolder',
		'newFileTitle',
		'newFileName',
		'thumbnailMorph',
		'authorMorph',
		'commentMorph',
		'type',
		'newTitleBin',
		'phratchFrame',
		'readingPhratchFile'
	],
	#classVars : [
		'LastFolderForType',
		'UserHomeFolder'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #'instance creation' }
PhratchFileChooserDialog class >> chooseExistingFileType: type extensions: anArrayOrNil title: titleString [

	| m |
	PhratchFileChooserDialog deleteDuplicates.
	m := self new
		createFileChooserLayout: false;
		type: type;
		extensions: anArrayOrNil;
		title: titleString;
		yourself.

	^ m getUserResponse

]

{ #category : #'instance creation' }
PhratchFileChooserDialog class >> chooseFolder: aDirectory [

	| m |
	PhratchFileChooserDialog deleteDuplicates.
	m := self new
		createFileChooserLayout: false;
		choosingFolder: true;
		setDirectory: aDirectory;
		extensions: '!';
		title: 'Choose a folder' translated;
		yourself.	"initial directory"	"do not show files in the directories"

	^ m getUserResponseForFolder

]

{ #category : #'instance creation' }
PhratchFileChooserDialog class >> chooseImageFileType: type title: aString [
	"PhratchFileChooserDialog chooseImageFileType: #costume title: 'Costume'"

	| m |
	PhratchFileChooserDialog deleteDuplicates.
	m := self new
		createFileChooserLayout: false;
		showThumbnails: true;
		type: type;
		extensions: #(gif jpeg jpg bmp png);
		title: aString;
		listExtent: 550@300;
		yourself.

	"allow sprites to be imported into the paint editor:"
	aString = 'Import Image' ifTrue: [
		m extensions: #(gif jpeg jpg bmp png sprite)].

	^ m getUserResponse

]

{ #category : #'instance creation' }
PhratchFileChooserDialog class >> chooseNewFileDefault: defaultName title: titleString type: type [

	| m |
	PhratchFileChooserDialog deleteDuplicates.
	m := self new
		createFileChooserLayout: true;
		type: type;
		defaultName: defaultName;
		title: titleString;
		listExtent: 400@280;
		yourself.

	^ m getUserResponseForNewFile

]

{ #category : #'instance creation' }
PhratchFileChooserDialog class >> chooseSpriteCostumeFor: aPhratchFrameMorph [
	"PhratchFileChooserDialog chooseSpriteCostumeFor: nil"

	| m |
	PhratchFileChooserDialog deleteDuplicates.
	m := self new
		createFileChooserLayout: false;
		title: 'New Sprite' translated;
		showThumbnails: true;
		type: #costume;
		extensions: #(#gif #jpeg #jpg #bmp #png #sprite #ysp);
		phratchFrame: aPhratchFrameMorph;
		listExtent: 550 @ 300;
		yourself.

	^ m getUserResponse

]

{ #category : #'class initialization' }
PhratchFileChooserDialog class >> clearFolderCache [
	"Clear all folder caches."
	"PhratchFileChooserDialog clearFolderCache"

	UserHomeFolder := nil.
	LastFolderForType := Dictionary new.

]

{ #category : #utilities }
PhratchFileChooserDialog class >> confirmFileOverwriteIfExisting: aFilename [
	"If the given file exists, ask the user if they want to overwrite it or pick a different file name."

	| response fName |
	fName := aFilename.
"	(fName endsWith: '.sb') ifFalse: [fName := fName, '.sb']."
	(fName endsWith: '.phr') ifFalse: [fName := fName, '.phr'].
	( aFilename asFileReference) exists ifFalse: [^ aFilename].

	response := DialogBoxMorph
		askWithCancel: 'The file name already exists. Overwrite existing file?'.
	response = #cancelled ifTrue: [^ #cancelled].
	response ifTrue: [^ fName] ifFalse: [^ false].

]

{ #category : #'instance creation' }
PhratchFileChooserDialog class >> deleteDuplicates [
	"If another file chooser dialog box is already opened, delete it"

	World submorphs do: [:i | 
		(i isKindOf: PhratchFileChooserDialog) ifTrue: [i delete]].

]

{ #category : #accessing }
PhratchFileChooserDialog class >> getDefaultFolderForType: type [

	| mediaDir |
	(type = #project) ifTrue: [^ self userPhratchProjectsDir].

	(FileSystem workingDirectory / 'Media') exists ifTrue: [
		mediaDir := FileSystem workingDirectory / 'Media'.
		#background = type ifTrue: [
			(mediaDir / 'Backgrounds') asFileReference exists ifTrue: [
				^ mediaDir / 'Backgrounds']].
		(#(costume sprite) includes: type) ifTrue: [
			(mediaDir / 'Costumes') asFileReference exists ifTrue: [
				^ mediaDir / 'Costumes']].
		#sound = type ifTrue: [
			(mediaDir / 'Sounds') asFileReference exists ifTrue: [
				^ mediaDir / 'Sounds']]].

	^ self homeDir

]

{ #category : #accessing }
PhratchFileChooserDialog class >> getLastFolderForType: type [
	"Return the last used folder for the given type. If this is the first time the type has been used, return the default folder for that type."

	| dir |
	dir := LastFolderForType at: type ifAbsent: [nil].
	dir ifNotNil: [
		dir asFileReference exists ifTrue: [^ dir]].

	^ PhratchFileChooserDialog getDefaultFolderForType: type

]

{ #category : #accessing }
PhratchFileChooserDialog class >> homeDir [
	"Return the home directory for this user. By default, this is either provided by the OS via primGetFolderPath: but it can be overridden by adding a 'homedir=path' entry to the .ini folder."

	| homeDir |
	UserHomeFolder ifNotNil: [^ UserHomeFolder]. "provided by .ini"
	"try in order: documents folder, user home folder, Phratch folder"
	homeDir := FileLocator documents.  "documents"
	(homeDir exists) ifFalse: [
		homeDir := FileLocator home].  "home"
	(homeDir exists) ifFalse: [
		homeDir := FileLocator workingDirectory fullName].  "Phratch folder (last resort)"

	^ homeDir
]

{ #category : #'class initialization' }
PhratchFileChooserDialog class >> initialize [

	self clearFolderCache.

]

{ #category : #accessing }
PhratchFileChooserDialog class >> lastFolderIsSampleProjectsFolder [
	"Return true if the last projects folder is the sample projects folder."

	| lastDirPath sampleProjectDirPath |
	lastDirPath := (self getLastFolderForType: #project) fullName.

	sampleProjectDirPath := (FileSystem workingDirectory / 'Projects') fullName.
	^ lastDirPath beginsWith: sampleProjectDirPath

]

{ #category : #'instance creation' }
PhratchFileChooserDialog class >> openPhratchFileFor: aPhratchFrameMorph [
	"Choose a Phratch project file for reading. Answer:
		nil, if no file is selected
		the full file name, if a local file is selected
		a ByteArray containing the project data, if a remote file is selected.
	As the user selects files in the file picker, preview the project thumbnail and info string for the selected project. If the file 'servers.txt' is found in the Phratch folder, then allow browsing and selecting of Phratch projects on a remote HTTP server."
	"PhratchFileChooserDialog openPhratchFileFor: nil"

	| m response s |
	PhratchFileChooserDialog deleteDuplicates.
	m := self new
		createPhratchFileChooserFor: aPhratchFrameMorph saving: false;
		type: #project;
		yourself.

	response := m getUserResponse.
	response = #cancelled ifTrue: [^ nil].

	(response isKindOf: FileReference) ifTrue: [^ response].  "answer the full name of a local file"

	"get contents of a remote file, giving the user the option of aborting"
	self assert: [response isKindOf: HTTPFetcher].
	self waitForCompletionOrCancelOfFetch: response.
	response succeeded ifFalse: [response stopDownload. ^ nil].

	s := (response path findTokens: '/') last.
	aPhratchFrameMorph projectName: (aPhratchFrameMorph nameFromFileName: s).

	^ response bodyData

]

{ #category : #utilities }
PhratchFileChooserDialog class >> replaceAsteriskWithUserName: aString [
	"If the given string includes an asterisk, replace it with the name of the current user. Otherwise, return the string."
	"self replaceAsteriskWithUserName: '/Users/*/Documents'"

	| i home delimiter userName |
	(i := aString indexOf: $*) = 0 ifTrue: [^ aString].
	home := PhratchPlugin primGetFolderPathOrNil: 1.
	home ifNil: [^ aString].
	delimiter := FileSystem disk delimiter asString.
	userName := (home findTokens: delimiter) last.
	^ (aString copyFrom: 1 to: i - 1), userName, (aString copyFrom: i + 1 to: aString size).

]

{ #category : #'instance creation' }
PhratchFileChooserDialog class >> savePhratchFileFor: aPhratchFrameMorph [
	"Choose a file for saving the current Phratch project file. Display the thumbnail and info string for the current project and allow the info string to be edited. Answer the full name of the file in which to save the project or #cancelled if the operation is cancelled."
	"PhratchFileChooserDialog savePhratchFileFor: nil"

	| m result |
	PhratchFileChooserDialog deleteDuplicates.
	m := self new
		createPhratchFileChooserFor: aPhratchFrameMorph saving: true;
		type: #project;
		redirectSavesToSampleFolder;
		yourself.

	result := m getUserResponseForNewFile.
	result = #cancelled ifTrue: [^ result].

"	(result asLowercase endsWith: '.sb') ifFalse: [result := result, '.sb']."
	(result asLowercase endsWith: '.phr') ifFalse: [result := result, '.phr'].
	^ result

]

{ #category : #accessing }
PhratchFileChooserDialog class >> setHomeDir: aStringOrNil [
	"Set the home directory for this user. If the user name contains an asterisk, replace it with the name of logged in user."
	"self setHomeDir: '/Users/*/Documents'"

	| path |
	UserHomeFolder := nil.
	aStringOrNil ifNotNil: [
		path := self replaceAsteriskWithUserName: aStringOrNil.
		(path asFileReference ) exists ifTrue: [
			UserHomeFolder := path asFileReference ]].

]

{ #category : #accessing }
PhratchFileChooserDialog class >> setLastFolderTo: dir forType: type [
	"Remember the given dir as the last folder used for the given type of file."

	(dir isKindOf: PhratchServerDirectory) ifTrue: [^ self].
	LastFolderForType at: type put: dir.


]

{ #category : #accessing }
PhratchFileChooserDialog class >> userPhratchProjectsDir [
	"Return the path to the user's 'Phratch' project folder, usually located inside the user's 'Documents' folder. If the folder does not already exists, attempt to create it. If the .ini file specifies an alternate home directory, create the folder there. If the directory can't be created, return the user's home folder."

	| phratchFolderName homeDir |
	phratchFolderName := 'Phratch Projects'.  "if this were localized a user could get multiple project folders for different languages..."

	homeDir := self homeDir.

	"try to create Phratch Projects folder in the user's homeDir"
	(homeDir / phratchFolderName) exists ifFalse: [
		[(homeDir / phratchFolderName) ensureDirectory] ifError: []].

	^ (homeDir / phratchFolderName) exists
		ifTrue: [(homeDir / phratchFolderName) asFileReference]
		ifFalse: [homeDir asFileReference]

]

{ #category : #utilities }
PhratchFileChooserDialog class >> waitForCompletionOrCancelOfFetch: anHTTPFetcher [
	"Put up dialog box until the given fetch completes, fails, or is cancelled by the user."
	"self waitForCompletionOrCancelOfFetch: nil"

	| dialogBox total |
	dialogBox := DialogBoxMorph new
		title: 'Downloading...' translated;
		withButtonsForYes: false
			no: false
			okay: false
			cancel: true;
		extent: 200 @ 150;
		percentDone: 0;
		yourself.

	dialogBox center: World center.
	dialogBox openInWorld.

	total := nil.
	[ dialogBox isDone not & anHTTPFetcher inProgress ]
		whileTrue: [ 
			(Delay forMilliseconds: 100) wait.
			total ifNil: [ total := anHTTPFetcher contentLength ].
			total ifNotNil: [ dialogBox percentDone: 100 * anHTTPFetcher bytesDownloaded // total ].
			World doOneCycle ].	"wait for user to press a button"
	anHTTPFetcher succeeded
		ifFalse: [ 
			dialogBox message: 'Failed: ' , anHTTPFetcher failureReason.
			[ dialogBox isDone ] whileFalse: [ World doOneCycle ] ].

	dialogBox delete.
	World doOneCycle

]

{ #category : #initialization }
PhratchFileChooserDialog >> addShortcutButtons [
	"Add shortcut buttons for my type to the shortcutColumn."

	| spacer |
	spacer := Morph new extent: 5@5; color: Color transparent;
		yourself.
	shortcutColumn removeAllMorphs.

	shortcutColumn addMorphBack: (self shortcutButtonLabel: 'Computer' action: #myComp icon: #folderDiscsIcon).
	shortcutColumn addMorphBack: spacer fullCopy.

	shortcutColumn addMorphBack: (self shortcutButtonLabel: self labelForHomeFolder action: #myHome icon: #folderHouseIcon).
	shortcutColumn addMorphBack: spacer fullCopy.

	shortcutColumn addMorphBack: (self shortcutButtonLabel: 'Desktop' action: #myDesktop icon: #folderIcon).
	shortcutColumn addMorphBack: spacer fullCopy.

	#background = self type ifTrue: [
		shortcutColumn addMorphBack:
			(self shortcutButtonLabel: 'Backgrounds' action: #phratchBackgrounds icon: #folderCatIcon)].

	#costume = self type ifTrue: [
		shortcutColumn addMorphBack:
			(self shortcutButtonLabel: 'Costumes' action: #phratchCostumes icon: #folderCatIcon)].

	#project = self type ifTrue: [
		shortcutColumn addMorphBack:
			(self shortcutButtonLabel: 'Examples' action: #sampleProjects icon: #folderCatIcon).
		shortcutColumn addMorphBack: spacer fullCopy.
		shortcutColumn addMorphBack:
			(self shortcutButtonLabel: 'My Projects' action: #userProjects icon: #folderIcon)].

	#sound = self type ifTrue: [
		shortcutColumn addMorphBack:
			(self shortcutButtonLabel: 'Sounds' action: #phratchSounds icon: #folderCatIcon)].


]

{ #category : #accessing }
PhratchFileChooserDialog >> choosingFolder: aBoolean [

	choosingFolder := aBoolean.

]

{ #category : #accessing }
PhratchFileChooserDialog >> createFileChooserLayout: allowNewFile [
	"Create the file chooser dialog box."

	list := PhratchFilePicker new.
	self removeAllMorphs.
	bottomSpacer delete.
	bottomSpacer := nil.
	mainColumn addMorphBack: list.
	self title: 'Open' translated.
	allowNewFile
		ifTrue: [ 
			self title: 'Save As' translated.
			newFileTitle := StringMorph new
				contents: 'New Filename:' localized , ' ';
				color: (Color gray: 0.3);
				font: (PhratchFrameMorph getFont: #FileChooserNewFileTitle);
		yourself.
			newFileName := StringFieldMorph new
				font: (PhratchFrameMorph getFont: #FileChooserNewFilename);
				color: (Color r: 211 / 255 g: 214 / 255 b: 216 / 255);
				width: 180;
		yourself.
			newTitleBin
				addMorphBack: newFileTitle;
				addMorphBack:
						(Morph new
								extent: 5 @ 5;
								color: Color transparent;
		yourself);
				addMorphBack: newFileName;
				addMorphBack: (AlignmentMorph newSpacer: Color transparent).
			PhratchTranslator isRTL
				ifTrue: [ 
					newTitleBin submorphs reversed
						do: [ :m | 
							m delete.
							newTitleBin addMorphBack: m ] ] ].
	mainColumn
		addMorphBack: newTitleBin;
		addMorphBack: buttonRow.
	self
		addMorphBack: shortcutColumn;
		addMorphBack: mainColumn;
		addMorphBack: fileInfoColumn
]

{ #category : #initialization }
PhratchFileChooserDialog >> createPhratchFileChooserFor: aPhratchFrameMorph saving: savingFlag [
	"Create a Phratch file chooser dialog box with a project thumbnail and info box."

	| labelFont contentsFont commentFont thumbnailHolder dumm thumbnailFrameMorph commentLabelMorph authorLabelMorph |
	phratchFrame := aPhratchFrameMorph.
	readingPhratchFile := savingFlag not. 
	list := PhratchFilePicker new extensions: #(#scratch #sb #ypr #phr).
	self removeAllMorphs. 
	bottomSpacer delete. 
	bottomSpacer := nil.
	mainColumn addMorphBack: list.
	savingFlag
		ifFalse: [ 
			self title: 'Open Project' translated.
			list phratchInfoClient: self ].
	labelFont := PhratchFrameMorph getFont: #FileChooserLabel.
	contentsFont := PhratchFrameMorph getFont: #FileChooserContents.
	commentFont := PhratchFrameMorph getFont: #FileChooserComment.
	savingFlag
		ifTrue: [ 
			self title: 'Save Project' translated.
			newFileTitle := StringMorph contents: 'New Filename:' localized , ' ' font: labelFont.
			newFileTitle color: (Color gray: 0.3).
			newFileName := StringFieldMorph new
				contents: phratchFrame projectName;
				client: self;
				font: contentsFont;
				color: (Color r: 211 / 255 g: 214 / 255 b: 216 / 255);
				width: 180;
		yourself.
			tabFields add: newFileName.
			newTitleBin
				addMorphBack: newFileTitle;
				addMorphBack:
						(Morph new
								extent: 5 @ 5;
								color: Color transparent;
		yourself);
				addMorphBack: newFileName;
				addMorphBack: (AlignmentMorph newSpacer: Color transparent).
			PhratchTranslator isRTL
				ifTrue: [ 
					newTitleBin submorphs reversed
						do: [ :m | 
							m delete.
							newTitleBin addMorphBack: m ] ] ].
	mainColumn
		addMorphBack:
				(Morph new
						extent: 5 @ 9;
						color: Color transparent;
		yourself);
		addMorphBack: newTitleBin.
	thumbnailHolder := AlignmentMorph newColumn
		cellPositioning: #topCenter;
		centering: #center;
		vResizing: #shrinkWrap;
		color: Color transparent;
		yourself.
	thumbnailFrameMorph := ImageFrameMorph new initFromForm: (PhratchFrameMorph skinAt: #dialogThumbnailFrame).
	thumbnailFrameMorph extent: 170 @ 130.
	thumbnailHolder addMorph: thumbnailFrameMorph.
	dumm := Morph new
		extent: 210 @ 130;
		color: Color transparent;
		yourself.	"hack SPFA"
	fileInfoColumn
		addMorphBack: (dumm addMorph: thumbnailFrameMorph);
		addMorphBack:
				(Morph new
						extent: 5 @ 6;
						color: Color transparent;
		yourself).	"hack SPFA"	"spacer"
	thumbnailMorph := ImageMorph new form: (Form extent: 160 @ 120 depth: 1).
	thumbnailFrameMorph addMorphFront: (thumbnailMorph position: thumbnailFrameMorph position + (5 @ 5)).
	authorLabelMorph := StringMorph contents: 'Project author:' localized font: labelFont.
	authorLabelMorph color: (Color gray: 0.3).
	fileInfoColumn addMorphBack: authorLabelMorph.
	savingFlag
		ifTrue: [ 
			authorMorph := StringFieldMorph new
				useStringFieldFrame;
				contents: '';
				font: contentsFont;
		yourself.
			tabFields add: authorMorph ]
		ifFalse: [ 
			fileInfoColumn
				addMorphBack:
					(Morph new
						extent: 5 @ 6;
						color: Color transparent;
		yourself).	"spacer"
			authorMorph := StringFieldMorph new
				color: Color transparent;
				borderWidth: 0;
				contents: '';
				isEditable: false;
				font: contentsFont;
		yourself ].
	fileInfoColumn
		addMorphBack: authorMorph;
		addMorphBack:
				(Morph new
						extent: 5 @ 6;
						color: Color transparent;
		yourself).	"spacer"
	commentLabelMorph := StringMorph contents: 'About this project:' localized font: labelFont.
	commentLabelMorph color: authorLabelMorph color.
	fileInfoColumn addMorphBack: commentLabelMorph.
	commentMorph := ScrollingStringMorph new
		borderWidth: 0;
		contents: '';
		font: commentFont;
		extent: 210 @ 110;
		yourself.
	savingFlag
		ifTrue: [ 
			commentMorph backForm: (PhratchFrameMorph skinAt: #stringFieldFrame).
			tabFields add: commentMorph ]
		ifFalse: [ commentMorph isEditable: false ].
	fileInfoColumn addMorphBack: commentMorph.
	fileInfoColumn addMorphBack: buttonRow.
	self
		addMorphBack: shortcutColumn;
		addMorphBack: mainColumn;
		addMorphBack: fileInfoColumn.
	savingFlag
		ifFalse: [ ^ self ].
	self phratchInfo: phratchFrame projectInfo.
	thumbnailMorph form: phratchFrame workPane thumbnailForm.	"default author field to login name if known; else author"
	aPhratchFrameMorph loginName size > 0
		ifTrue: [ authorMorph contents: aPhratchFrameMorph loginName ]
		ifFalse: [ authorMorph contents: aPhratchFrameMorph author ]
]

{ #category : #accessing }
PhratchFileChooserDialog >> defaultName: aString [
	"Set the default file name."

	newFileName ifNotNil: [newFileName contents: aString].

]

{ #category : #other }
PhratchFileChooserDialog >> delete [

	super delete.
	(list isKindOf: PhratchFilePicker) ifTrue: [list stopPlayingSound].

]

{ #category : #accessing }
PhratchFileChooserDialog >> extensions: anArray [

	list extensions: anArray.

]

{ #category : #initialization }
PhratchFileChooserDialog >> getUserResponse [
	"Wait for the user to respond, then answer the full path name of the chosen file or #cancelled if the user cancels the operation. If opening a remote file for reading, answer a HTTPFetcher on the remote file."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop."

	| w |
	self openInWorld.
	w := self world.
	w activeHand newKeyboardFocus: (tabFields at: 1).
	self centerOnScreen.
	newFileName ifNotNil: [w activeHand newKeyboardFocus: newFileName].
	list getDirectoryContents.

	response := #cancelled.  "default response"
	done := false.
	[done or: [list isFinalSelection]] whileFalse: [w doOneCycle].
	self delete.
	w doOneCycle.  "erase myself from the screen"

	((response = #cancelled) and: [list isFinalSelection not]) ifTrue: [^ #cancelled].
	list selectedFile ifNil: [^ #cancelled].

	(thumbnailMorph notNil & readingPhratchFile not) ifTrue: [  "save info in project"
		phratchFrame author: authorMorph contents trimBoth.
		phratchFrame projectComment: commentMorph contents].

	(list currentDirectory isKindOf: PhratchServerDirectory)
		ifTrue: [^ list projectFetcher]
		ifFalse: [^ (list currentDirectory / list selectedFile)].

]

{ #category : #interaction }
PhratchFileChooserDialog >> getUserResponseForFolder [
	"Wait for the user to respond, then answer the full path name of the chosen directory or #cancelled if the user cancels the operation. To make a FileDirectory from the response string use the method: FileDirectory on: <reponse>."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop."

	| w |
	self openInWorld.
	w := self world.
	w activeHand newKeyboardFocus: (tabFields at: 1).
	self extent: self extent.  "force layout"
	self position: w center - (self extent // 2) + (0@5).  "center on screen but disregard the shadow on the bottom"
	list getDirectoryContents.

	response := #cancelled.  "default response"
	done := false.
	[done "or: [list model isFinalSelection]"] whileFalse: [w doOneCycle].
	self delete.
	w doOneCycle.  "erase myself from the screen"

	response = #cancelled
		ifTrue: [^ #cancelled]
		ifFalse: [^ list currentDirectory].

]

{ #category : #interaction }
PhratchFileChooserDialog >> getUserResponseForNewFile [
	"Wait for the user to respond, then answer the full path name of the new file or #cancelled if the user cancels the operation."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop."

	| w fn |
	self openInWorld.
	w := self world.
	w activeHand newKeyboardFocus: (tabFields at: 1).
	self extent: self extent.  "force layout"
	self position: w center - (self extent // 2) + (0@5).  "center on screen but disregard the shadow on the bottom"
	newFileName ifNotNil: [w activeHand newKeyboardFocus: newFileName].
	list getDirectoryContents.

	[true] whileTrue: [
		done := false.
		[done] whileFalse: [w doOneCycle].

		response = #cancelled ifTrue: [^ #cancelled].

		thumbnailMorph ifNotNil: [  "save info in project"
			phratchFrame author: authorMorph contents trimBoth.
			phratchFrame projectComment: commentMorph contents].

		fn := newFileName contents trimBoth.
		fn size > 0 ifTrue: [
			fn := fn collect: [:ch | ('\/:' includes: ch) ifTrue: [$-] ifFalse: [ch]].  "replace directory delimiters with dashes"
			^ list currentDirectory fullName, FileSystem disk delimiter asString, fn].

		newFileTitle color: Color red.
		self openInWorld. 
		w activeHand newKeyboardFocus: newFileName].

]

{ #category : #initialization }
PhratchFileChooserDialog >> initialize [
	"Create the file chooser dialog box"

	super initialize.
	choosingFolder := false.
	phratchFrame := nil.
	readingPhratchFile := false.

	newTitleBin := AlignmentMorph newRow
		cellPositioning: #leftCenter;
		centering: #center;
		color: Color transparent;
		yourself.
	buttonRow hResizing: #spaceFill.

	self withButtonsForYes: false no: false okay: true cancel: true.

]

{ #category : #shortcuts }
PhratchFileChooserDialog >> labelForHomeFolder [
	"Answer the name to use for the home folder. This is the user name unless the home folder location has been overridden by an entry in the .ini file."

	| home delimiter |
	UserHomeFolder notNil ifTrue: [^ 'Home' localized].

	home := PhratchPlugin primGetFolderPathOrNil: 1.
	home ifNil: [^ 'Home' localized].
	delimiter := FileSystem disk delimiter asString.

	^ String withAll: (home findTokens: delimiter) last

]

{ #category : #accessing }
PhratchFileChooserDialog >> listExtent: anExtent [
	
	list extent: anExtent.
	self changed.

]

{ #category : #shortcuts }
PhratchFileChooserDialog >> myComp [
	"My Computer button was pressed."
	list currentDirectory: FileSystem root.
]

{ #category : #shortcuts }
PhratchFileChooserDialog >> myDesktop [
	"My desktop button was pressed."

	list currentDirectory: (FileLocator desktop asFileReference)

]

{ #category : #shortcuts }
PhratchFileChooserDialog >> myHome [
	"My Home button was pressed."

	list currentDirectory: self class homeDir asFileReference.

]

{ #category : #shortcuts }
PhratchFileChooserDialog >> phratchBackgrounds [
	"Phratch Backgrounds button was pressed."

	| backgrounds |
	backgrounds := PhratchFileChooserDialog getDefaultFolderForType: #background.
	backgrounds ifNotNil: [list currentDirectory: backgrounds].

]

{ #category : #shortcuts }
PhratchFileChooserDialog >> phratchCostumes [
	"Phratch Costumes button was pressed."

	| costumes |
	costumes := PhratchFileChooserDialog getDefaultFolderForType: #costume.
	costumes ifNotNil: [list currentDirectory: costumes].

]

{ #category : #accessing }
PhratchFileChooserDialog >> phratchFrame: aPhratchFrameMorph [

	phratchFrame := aPhratchFrameMorph.

]

{ #category : #other }
PhratchFileChooserDialog >> phratchInfo: infoDict [
	"Update the Phratch project thumbnail and info display."

	| s |
	infoDict ifNil: [  "clear thumbnail and info"
		thumbnailMorph form: (Form extent: thumbnailMorph extent depth: 1) fillWhite.
		authorMorph contents: ''.
		commentMorph contents: ''.
		^ self].

	((infoDict includesKey: 'thumbnail') and: [thumbnailMorph notNil])
		ifTrue: [thumbnailMorph form: (infoDict at: 'thumbnail')]
		ifFalse: [thumbnailMorph form: (Form extent: thumbnailMorph extent depth: 1) fillBlack].

	authorMorph contents: ''.
	((infoDict includesKey: 'author') and: [authorMorph notNil]) ifTrue: [
		authorMorph contents: (infoDict at: 'author')].

	s := ''.
	readingPhratchFile
		ifTrue: [
			(infoDict includesKey: 'comment') ifTrue: [s := infoDict at: 'comment']]
		ifFalse: [
			s := phratchFrame projectCommentOrTemplate].
	commentMorph contents: s; changed.



]

{ #category : #shortcuts }
PhratchFileChooserDialog >> phratchSounds [
	"Phratch Sounds button was pressed."

	| sounds |
	sounds := PhratchFileChooserDialog getDefaultFolderForType: #sound.
	sounds ifNotNil: [list currentDirectory: sounds].

]

{ #category : #accessing }
PhratchFileChooserDialog >> redirectSavesToSampleFolder [
	"Check to see if we are about to save into the Sample projects directory. If so, change the default location to the user's project folder."

	(PhratchFileChooserDialog lastFolderIsSampleProjectsFolder) ifTrue: [
		self setDirectory: PhratchFileChooserDialog userPhratchProjectsDir].

]

{ #category : #shortcuts }
PhratchFileChooserDialog >> sampleProjects [
	"Sample Projects button was pressed."
	(FileSystem workingDirectory / 'Projects') exists ifTrue: [
		list currentDirectory:
			(FileSystem workingDirectory / 'Projects')].

]

{ #category : #accessing }
PhratchFileChooserDialog >> setDirectory: anObject [
	"Set the currently selected directory. The argument may be either a FileDirectory or a string."
	list currentDirectory: (anObject asFileReference)
]

{ #category : #accessing }
PhratchFileChooserDialog >> showThumbnails: aBoolean [

	list showThumbnails: aBoolean.

]

{ #category : #accessing }
PhratchFileChooserDialog >> type [
	"Return the type of thing being opened/saved in the file dialog box, in order to include the appropriate shortcuts.  Possible types include
	#costume
	#background
	#sound
	#sprite
	#stageShot
	#project"

	^ type

]

{ #category : #accessing }
PhratchFileChooserDialog >> type: t [
	"Set the type of thing being opened/saved in the file dialog box, in order to include the appropriate shortcuts.  Then add relevant shortcut buttons and set the directory. Types include:
	#background
	#costume
	#list
	#project
	#projectSummary
	#scriptSnapshot
	#sound
	#sprite
	#stageShot"

	type := t.
	self addShortcutButtons.
	self setDirectory: (PhratchFileChooserDialog getLastFolderForType: type).

]

{ #category : #shortcuts }
PhratchFileChooserDialog >> userProjects [
	"My Projects button was pressed."

	list currentDirectory: self class userPhratchProjectsDir.

]

{ #category : #interaction }
PhratchFileChooserDialog >> yes [
	"Yes button was pressed."

	| entry |
	entry := list selectedEntryOrNil.
	(entry notNil and: [entry entryIsDirectory]) ifTrue: [
		(newFileName isNil or: [newFileName contents size = 0]) ifTrue: [
			self setDirectory: (list currentDirectory / entry entryName).
			choosingFolder ifTrue: [super yes].
			^ self]].
	PhratchFileChooserDialog setLastFolderTo: list currentDirectory forType: self type.
	^ super yes

]
