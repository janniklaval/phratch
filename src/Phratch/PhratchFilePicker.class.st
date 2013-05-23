"
Allows the user to navigate through files and folders to select a file.

"
Class {
	#name : #PhratchFilePicker,
	#superclass : #ImageFrameMorph,
	#instVars : [
		'directoryBarMorph',
		'contentsPaneMorph',
		'feedbackMorph',
		'currentDir',
		'extensions',
		'fetchInProgress',
		'showThumbnails',
		'thumbnailFetchProcess',
		'lastUpMSecs',
		'wasSelected',
		'isDoubleClick',
		'sound',
		'finalSelection',
		'freezeFocus',
		'topBarMorph',
		'directoryBarArrowMorph',
		'phratchInfoClient',
		'phratchServers',
		'phratchProjectFetcher'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #private }
PhratchFilePicker >> addDriveShortcuts: menu [
	"Add shortcuts to the file picker menu."

	| drives visible |
	"Include drives"
	menu addLine.
	drives := (FileSystem disk root) directories.
	(visible := PhratchFrameMorph visibleDrives) ifNotNil: [
		drives := drives select: [:drive | visible includes: drive asUppercase]].
		drives := drives do: [:drive |
			menu add: drive printString
				target: self 
				selector: #currentDirectory:
				argument: drive].
]

{ #category : #private }
PhratchFilePicker >> buildButtons [
	"Build my directory bar, parent buttons, and new folder button."

	| b f |
	topBarMorph := AlignmentMorph newRow
		cellPositioning: #leftCenter;
		hResizing: #spaceFill;
		vResizing: #rigid;
		centering: #center;
		color: Color transparent.
	directoryBarArrowMorph := ImageMorph new form: (PhratchFrameMorph skinAt: #directoryBarArrow).
	directoryBarMorph := ResizableToggleButton2 new
		offForm: (PhratchFrameMorph skinAt: #directoryBar)
		onForm: (PhratchFrameMorph skinAt: #directoryBar);
		padding: 3@5.
	directoryBarMorph
		target: self;
		actionSelector: #directoryMenu;
		actWhen: #buttonUp.
	topBarMorph
		addMorphBack: (Morph new extent: (5@5); color: Color transparent);
		addMorphBack: directoryBarMorph.

	b := ToggleButton
		onForm: (PhratchFrameMorph skinAt: #parentDirectoryButtonOn)
		offForm: (PhratchFrameMorph skinAt: #parentDirectoryButton).
	b
		target: self;
		actionSelector: #showParentDirectory;
		actWhen: #buttonUp;
		isMomentary: true.
	topBarMorph
		addMorphBack: (Morph new extent: (5@5); color: Color transparent);
		addMorphBack: (b position: self position + (252@16)).

	f := ToggleButton
		onForm: (PhratchFrameMorph skinAt: #newFolderIconSelected)
		offForm: (PhratchFrameMorph skinAt: #newFolderIcon).
	f
		target: self;
		actionSelector: #newDirectory;
		actWhen: #buttonUp;
		isMomentary: true.
	topBarMorph
		addMorphBack: (Morph new extent: (5@5); color: Color transparent);
		addMorphBack: (f position: self position + (274@16)).

	directoryBarMorph
		label: "(UTF8 withAll: '<directory>')"'<directory>' font: (PhratchFrameMorph getFont: #FilePickerDirectoryName);
		leftJustifyInset: 9.

	self addMorphFront: (directoryBarArrowMorph position: self topLeft + ((b left - 32)@((50 - directoryBarArrowMorph height) // 2))).
	self addMorphBack: (topBarMorph position: self topLeft + (5@5)).

]

{ #category : #initialization }
PhratchFilePicker >> buildContentsPane [
	"Build a scroll pane to hold the directory contents."

	contentsPaneMorph := ScrollFrameMorph2 new
		color: self color;
		contents: (Morph new color: self color);
		showHorizontalScrollbar: false;
		hBarInset: 18;
		vBarInset: 18.

	self addMorphBack: contentsPaneMorph.

]

{ #category : #private }
PhratchFilePicker >> changeSelectionIndexBy: anInteger [

	| entries e newI |
	self stopPlayingSound.

	entries := contentsPaneMorph contents submorphs.
	entries size = 0 ifTrue: [^ self].

	1 to: entries size do: [:i |
		e := entries at: i.
		e isHighlit ifTrue: [
			e highlight: false.
			newI := i + anInteger.
			newI > entries size ifTrue: [newI := (i + 1) min: entries size].
			newI < 1 ifTrue: [newI := (i - 1) max: 1].
			self highlightAndScrollToEntry: (entries at: newI).
			^ self]].

	entries first highlight: true.
	phratchInfoClient ifNotNil: [self reportPhratchProjectInfo].

]

{ #category : #private }
PhratchFilePicker >> checkForPhratchInfoFetchDone [
	"Try to retrieve info for the currently selected Phratch project and, if successful, report it to our client."
	"Details: The fetcher is allowed to keep running even after the info dictionary is retrieved. Thus if the user decides to open this project, we'll have a head start on fetching it."

	| data s version infoSize infoDict |
	phratchProjectFetcher ifNil: [^ self].

	data := phratchProjectFetcher bodyData.
	data size >= 14 ifTrue: [
		s := ReadStream on: data.
		version := ObjStream phratchFileVersionFrom: (s next: 10) asString.
		(version = 1) | (version = 2)
			ifTrue: [
				infoSize := s uint32.
				infoSize <= (s size - s position) ifTrue: [
					infoDict := [ObjStream new readObjFrom: s] ifError: [Dictionary new].
					phratchInfoClient phratchInfo: infoDict]]
			ifFalse: [
				phratchInfoClient phratchInfo: Dictionary new]].


]

{ #category : #accessing }
PhratchFilePicker >> contentsPaneMorph [

	^ contentsPaneMorph

]

{ #category : #accessing }
PhratchFilePicker >> currentDirectory [
	"Answer the directory that is currently being viewed."

	^ currentDir

]

{ #category : #accessing }
PhratchFilePicker >> currentDirectory: aDirectoryOrString [
	"Set my current directory to the given directory or path String."

	| s truncated w eWidth |
	(currentDir isKindOf: PhratchServerDirectory) ifTrue: [
		fetchInProgress := false.
		currentDir stopFetching].
	
	(aDirectoryOrString isKindOf: String)
		ifTrue: [currentDir := ((aDirectoryOrString) asFileReference)]
		ifFalse: [currentDir := aDirectoryOrString].

	currentDir fullName isEmpty
		ifTrue: [s := FileSystem root basename]
		ifFalse: [s := currentDir basename].

	"trim directory name to fit button, if necessary"
	truncated := false.
	eWidth := (PhratchTranslator stringExtent: '...' font: directoryBarMorph label font) x.
	w := 190 - eWidth.
	[((PhratchTranslator stringExtent: s font: directoryBarMorph label font) x) > w] whileTrue: [
		truncated := true.
		s := s copyFrom: 1 to: s size - 1].
	truncated ifTrue: [s := s, '...'].
	s = '/' ifTrue: [s := 'Computer'].
	directoryBarMorph label: (String  withAll: s) font: (PhratchFrameMorph getFont: #FilePickerDirectoryName).
	directoryBarMorph
		width: contentsPaneMorph width - 160.
	directoryBarArrowMorph right: directoryBarMorph right - 9.
	lastUpMSecs := 0.
	self getDirectoryContents.

]

{ #category : #private }
PhratchFilePicker >> deleteDirectory [
	"Delete the directory or file that is currently highlit."

	| entries selectedDir dirEntries response e1|
	entries := contentsPaneMorph contents submorphs.
	selectedDir := entries detect: [:e | e1:= e. e isHighlit & e entryIsDirectory] ifNone: [^ self].

	dirEntries := (self currentDirectory / selectedDir) entries.
	dirEntries size > 0 ifTrue: [^ self].  "do nothing if selectedDir is not empty"

	freezeFocus := true.
	response := DialogBoxMorph ask: 
		'Are you sure you want to delete the empty folder ''' , selectedDir entryName , '''?'.
	freezeFocus := false.

	response ifTrue: [
		[self currentDirectory delete: e1 entryName]
			ifError: [^ DialogBoxMorph warn: 'Could not delete folder.'].
		^ self currentDirectory: self currentDirectory].

]

{ #category : #private }
PhratchFilePicker >> directoryMenu [
	"BROKEN!!"
	"Present a drop-down menu of all directories in my current path."

	| menu pathParts prefix n serverEntries choice s serverPath entry1 |
	
	self navigationForbidden ifTrue: [^ self].
	menu := MenuMorph new defaultTarget: self.
	pathParts := (currentDir) path.
	prefix := ''.
	n := ''.
	pathParts do: [:part |
		n := n asFileReference / part.
		menu add: prefix asUTF8, part
				target: self 
				selector: #currentDirectory:
				argument: n.
		prefix := prefix ,'  '.
	].
	pathParts isEmpty ifTrue: [
		menu add: 'Computer' 
				target: self 
				selector: #currentDirectory:
				argument: (FileSystem root) fullName].

	self addDriveShortcuts: menu.

	"if opening a Phratch project, allow access to servers"
	phratchInfoClient ifNotNil: [
		serverEntries := PhratchFrameMorph phratchServers.
		(serverEntries notNil and:[serverEntries size > 0]) ifTrue: [
			menu addLine.
			serverEntries do: [:entry | entry1:= entry.
				menu add: entry first
					target: self 
					selector: #currentDirectory:
					argument: n.
				n := n + 1]]].

	menu invokeModal.

	choice := self currentDirectory.
	((choice isKindOf: String) or:[choice isKindOf: FileReference]) ifTrue: [^ self currentDirectory: choice].

	choice path size > pathParts size ifTrue: [
		entry1 := serverEntries at: choice - pathParts size.
		^ self currentDirectory: (PhratchServerDirectory new
			serverName: (entry1 at: 2);
			path: (entry1 at: 3))].

	s := WriteStream on: String new.
	1 to: choice do: [:i |
		s nextPutAll: (pathParts at: i).
		i < choice ifTrue: [s nextPut: FileSystem disk delimiter]].

	(currentDir isKindOf: PhratchServerDirectory)
		ifTrue: [
			serverPath := '/', s contents.
			(serverPath endsWith: '/') ifFalse: [serverPath := serverPath, '/'].
			self currentDirectory: (currentDir copy path: serverPath)]
		ifFalse: [
			self currentDirectory: s contents].

]

{ #category : #accessing }
PhratchFilePicker >> extensions: anArrayOfStringsOrNil [
	"Set the set of extensions used to select which files to display. For example, extensions might be set to #(gif bmp png jpg) to show only files containing images. No filtering is done if extensions is nil, as it is by default."

	extensions := anArrayOfStringsOrNil.
	extensions ifNotNil: [
		extensions := extensions asArray collect: [:s | s asString asLowercase]].

]

{ #category : #geometry }
PhratchFilePicker >> extent: aPoint [
	"Resize my contents pane when I am resized."

	super extent: aPoint.
	contentsPaneMorph ifNotNil: [
		contentsPaneMorph
			bounds: ((self topLeft + (9@50)) corner: (self bottomRight - 7)).
		topBarMorph width: contentsPaneMorph width].

]

{ #category : #private }
PhratchFilePicker >> getDirectoryContents [
	"Generate and layout the morphs in my contents pane from the files and folder in the current directory."

	feedbackMorph delete.

	(currentDir isKindOf: FileReference )
		ifTrue: [^ self getLocalDirectoryContents].

	"remote case: start fetching directory contents and give feedback that fetch is started"
	feedbackMorph
		contents: 'Reading from ', currentDir fullName asString, '...';
		position: self topLeft + (20@60).

	contentsPaneMorph contents removeAllMorphs.
	contentsPaneMorph vScrollRelative: 0.
	self addMorphFront: feedbackMorph.
	fetchInProgress := true.

]

{ #category : #private }
PhratchFilePicker >> getFetchedServerDirectoryContents [
	"Generate and layout the morphs in my contents pane for the files and folder in the recently server directory contents. If the fetch generated an error, display the error."
	"Assume that the page morph exists already."

	| page m morphsToAdd x y nm isDir |
	page := contentsPaneMorph contents.

	currentDir fetchSucceeded ifFalse: [
		m := StringMorph contents: 'Failed: ', currentDir fetchFailureReason.
		page addMorph: (m position: page topLeft + (10@30)).
		^ self].

	morphsToAdd := OrderedCollection new: 1000.
	x := page left + 7.
	y := page top + 5.
	currentDir allNames do: [:n |
		nm := n.
		isDir := true.
		(n asLowercase endsWith: '.scratch') ifTrue: [
			nm := n copyFrom: 1 to: n size - '.scratch' size.
			isDir := false].
		(n asLowercase endsWith: '.sb') ifTrue: [
			nm := n copyFrom: 1 to: n size - '.sb' size.
			isDir := false].
		(n asLowercase endsWith: '.ypr') ifTrue: [
			nm := n copyFrom: 1 to: n size - '.ypr' size.
			isDir := false].
		m := PhratchFilePickerEntry new
			name: nm dir: currentDir isDirectory: isDir;
			width: self width - 60;
			color: self color.
		morphsToAdd add: (m position: x@y).
		y := y + m height].

	feedbackMorph delete.
	page removeAllMorphs.
	page addAllMorphs: morphsToAdd.
	self changeSelectionIndexBy: 1.

]

{ #category : #private }
PhratchFilePicker >> getLocalDirectoryContents [
	"Generate and layout the morphs in my contents pane from the files and folder in the current local directory."

	| allNames fileNames dirNames ext page |
	"make an alphabetized list of all files and directory names"

	fileNames := currentDir fileNames.
	extensions ifNotNil: [  "filter out files without a matching extension"
		fileNames := fileNames select: [:n |
			extensions includes: ((currentDir / n) extension) asLowercase]].
	fileNames := fileNames sort: [:n1 :n2 | n1 caseInsensitiveLessOrEqual: n2].
	dirNames := self getLocalDirectoryNames.
	dirNames := dirNames sort: [:n1 :n2 | n1 caseInsensitiveLessOrEqual: n2].
	allNames := dirNames , fileNames.
	allNames := allNames reject: [:n | n endsWith: ':=th.gif'].					"suppress Phratch project thumbnails"
	allNames := allNames reject: [:n | n beginsWith: '.'].						"suppress hidden files on Mac OS X and Unix"
	allNames := allNames reject: [:n |
		ext := (currentDir / n) extension asLowercase.
		#(app dll exe ini image changes) includes: ext].
	allNames := allNames reject: [:n | PhratchPlugin isHidden: (currentDir / n) fullName].	"suppress hidden files/folders on Win32"

	currentDir fullName = FileSystem workingDirectory fullName ifTrue: [
		allNames := allNames reject: [:fn |
			#(help icons 'license.txt' locale plugins 'scratch.app' ) includes: fn asLowercase]].

	showThumbnails
		ifTrue: [page := self thumbnailStylePageFor: allNames]
		ifFalse: [page := self listStylePageFor: allNames].
	contentsPaneMorph contents: page.

	showThumbnails ifTrue: [self startThumbnailFetchProcess].
	self changeSelectionIndexBy: 1.

]

{ #category : #private }
PhratchFilePicker >> getLocalDirectoryNames [
	"Answer the directories in currentDir. Suppress hidden volumes."

	| dirNames visible |
	dirNames := currentDir directoryNames.
	(visible := PhratchFrameMorph visibleDrives) ifNil: [^ dirNames].

	OSPlatform isMacOSX
		ifTrue: [currentDir pathName = '/Volumes' ifFalse: [^ dirNames]]
		ifFalse: [currentDir pathName = '' ifFalse: [^ dirNames]].

	^ dirNames select: [:dir | visible includes: dir asUppercase]

]

{ #category : #private }
PhratchFilePicker >> getPhratchInfoFromFile [
	"Answer the project info dictionary for the currently selected file. Answer the empty dictionary if no file is selected or if the file does not include a project info dictionary (e.g. if it is in an older Phratch file format)."

	| result fullName f version buf |
	result := Dictionary new.

	self selectedFile ifNil: [^ result].
	fullName := (currentDir / self selectedFile) fullName.
	( fullName asFileReference) exists ifFalse: [^ result].
	[f := (FileStream readOnlyFileNamed: fullName) binary] ifError: [^ result].

	[
		version := ObjStream phratchFileVersionFrom: (f next: 10) asString.
		(version = 1) | (version = 2) ifTrue: [
			buf := f next: f uint32.
			result := ((ObjStream new readObjFrom: (ReadStream on: buf)) associations collect: [:each | each value] ) asDictionary ].
	] ifError: [].
	f close.

	^ result

]

{ #category : #'event handling' }
PhratchFilePicker >> handlesMouseDown: evt [

	^ true

]

{ #category : #private }
PhratchFilePicker >> highlightAndScrollToEntry: e [

	e highlight: true.
	contentsPaneMorph scrollSubmorphIntoView: e.
	phratchInfoClient ifNotNil: [self reportPhratchProjectInfo].

]

{ #category : #'event handling' }
PhratchFilePicker >> highlightEntryAt: aPoint [
	"Highlight the entry at the given point, if any, and unhighlight all other entries. Answer true if the selected entry was already highlit, which means this is the second click on that entry."

	| secondClick |
	secondClick := false.
	contentsPaneMorph contents submorphsDo: [:m |
		(m isKindOf: PhratchFilePickerEntry) ifTrue: [
			(m containsPoint: aPoint)
				ifTrue: [secondClick := m isHighlit. m highlight: true]
				ifFalse: [m highlight: false]]].

	phratchInfoClient ifNotNil: [self reportPhratchProjectInfo].

	^ secondClick

]

{ #category : #initialization }
PhratchFilePicker >> initialize [

	super initialize.
	self initFromForm: (PhratchFrameMorph skinAt: #filePickerFrame).
	fetchInProgress := false.
	showThumbnails := false.
	finalSelection := false.
	feedbackMorph := StringMorph new.  "used to show a remote directory fetch in progress"
	freezeFocus := false.

	self buildButtons.
	self buildContentsPane.
  
	self extent: 380@310.
	self currentDirectory: (FileSystem workingDirectory).

]

{ #category : #accessing }
PhratchFilePicker >> isFinalSelection [

	^ finalSelection
]

{ #category : #'event handling' }
PhratchFilePicker >> keyStroke: evt [
	"Handle up/down arrow keys."

	| ch m entry |
	freezeFocus ifTrue: [^ self].

	ch := evt keyValue.

	ch = 9 ifTrue: [  "tab"
		(m := self ownerOrYourselfThatIsA: DialogBoxMorph) ifNotNil: [m tabToNextField: evt].
		^ self].

	ch = 27 ifTrue: [  "escape key"
		(m := self ownerOrYourselfThatIsA: DialogBoxMorph) ifNotNil: [m escapeKeyPressed: evt].
		^ self].

	((ch = 1) | (ch = 11)) ifTrue: [ "home or page up"
		self selectedEntryOrNil ifNotNil: [self selectedEntryOrNil highlight: false].
		^ self highlightAndScrollToEntry: contentsPaneMorph contents submorphs first].

	((ch = 4) | (ch = 12)) ifTrue: [ "end or page down"
		self selectedEntryOrNil ifNotNil: [self selectedEntryOrNil highlight: false].
		^ self highlightAndScrollToEntry: contentsPaneMorph contents submorphs last].

	((ch = 8) | (ch = 127)) ifTrue: [ "delete key"
		self deleteDirectory].

	((ch = 10) | (ch = 13)) ifTrue: [  "cr, lf, or enter key"
		(entry := self selectedEntryOrNil) ifNil: [^ self].
		(entry entryIsDirectory and:
		 [(owner isKindOf: PhratchFileChooserDialog)])
			ifTrue: [self currentDirectory: (currentDir directoryNamed: entry entryName)]
			ifFalse: [(self ownerOrYourselfThatIsA: PhratchFileChooserDialog) yes].
		^ self].

	(ch = 28) ifTrue: [^ self changeSelectionIndexBy: -1].	"left"
	(ch = 29) ifTrue: [^ self changeSelectionIndexBy: 1].	"right"
	(ch = 30) ifTrue: [  "up"
		showThumbnails
			ifTrue: [^ self changeSelectionIndexBy: -4]
			ifFalse: [^ self changeSelectionIndexBy: -1]].
	(ch = 31) ifTrue: [  "down"
		showThumbnails
			ifTrue: [^ self changeSelectionIndexBy: 4]
			ifFalse: [^ self changeSelectionIndexBy: 1]].

	((ch between: $a asciiValue and: $z asciiValue) or:
	 [ch between: $A asciiValue and: $Z asciiValue])
		ifTrue: [^ self scrollToFileStartingWith: ch asCharacter asLowercase].

]

{ #category : #private }
PhratchFilePicker >> listStylePageFor: allNames [
	"Answer a new contents page as a column of list style entries."

	| page dirNames morphsToAdd x y m |
	page := Morph new
		color: self color;
		width: self width - 20.

	dirNames := currentDir directoryNames asSet.
	morphsToAdd := OrderedCollection new: 1000.
	x := page left + 7.
	y := page top + 5.
	allNames do: [:n |
		m := PhratchFilePickerEntry new
			name: n dir: currentDir isDirectory: (dirNames includes: n);
			width: self width - 60;
			color: self color;
			borderWidth: 0;
			useRoundedCorners.
		morphsToAdd add: (m position: x@y).
		y := y + m height].

	page addAllMorphs: morphsToAdd.
	^ page

]

{ #category : #accessing }
PhratchFilePicker >> minExtent [

	^ self extent
]

{ #category : #'event handling' }
PhratchFilePicker >> mouseDown: evt [
	"Record whether the mouse went down in the currently highlit entry (wasSelected) and if it should be considered a double-click. See mouseUp: for details."

	evt hand newKeyboardFocus: self.
	wasSelected := self highlightEntryAt: evt cursorPoint.
	isDoubleClick :=
		(wasSelected and:
		 [lastUpMSecs notNil and:
		 [(Time millisecondClockValue - lastUpMSecs) < 1000]]).
	self selectedEntryOrNil ifNil: [
		contentsPaneMorph grabContentsAt: evt cursorPoint ]
]

{ #category : #'event handling' }
PhratchFilePicker >> mouseMove: evt [
	"If the user drags away from the original selection and comes back, don't consider it a virtual double-click."

	contentsPaneMorph isBeingDragged ifTrue: [
		^contentsPaneMorph dragContentsTo: evt cursorPoint ].

	(self highlightEntryAt: evt cursorPoint)
		ifFalse: [isDoubleClick := false].

	phratchInfoClient ifNotNil: [self reportPhratchProjectInfo].

]

{ #category : #'event handling' }
PhratchFilePicker >> mouseUp: evt [
	"Handle a mouse up. If the mouse went down on an entry that was already selected, open that entry. (Like a double-click, but not sensitive to timing.) If the entry 'double-clicked' was a directory, open that directory. If it was a file, set finalSelection to true to cause the dialog to open the file."

	| singleClickOpensDirs playSelectedSound entry ext |
	singleClickOpensDirs := false.
	playSelectedSound := true.
	lastUpMSecs := Time millisecondClockValue.
	
	contentsPaneMorph isBeingDragged ifTrue: [
		^contentsPaneMorph dropContents ].

	(sound notNil and: [sound isPlaying]) ifTrue: [
		self stopPlayingSound.
		isDoubleClick := false.
		wasSelected ifTrue: [playSelectedSound := false]].

	entry := contentsPaneMorph contents submorphs
		detect: [:m | m containsPoint: evt cursorPoint]
		ifNone: [^ self].

	entry entryIsDirectory ifTrue: [
		singleClickOpensDirs | isDoubleClick ifTrue: [
			self currentDirectory: (currentDir / entry entryName )].
		^ self].

	ext := (currentDir /  entry entryName) extension asLowercase.
	playSelectedSound :=
		(playSelectedSound & extensions notNil) and: [extensions includes: 'wav'].

	playSelectedSound & isDoubleClick not ifTrue: [
		(extensions includes: ext) ifTrue: [
			self startPlayingSound: (currentDir / entry entryName) fullName]].

	finalSelection := isDoubleClick.
	finalSelection ifTrue: [(self ownerOrYourselfThatIsA: PhratchFileChooserDialog) yes].
]

{ #category : #private }
PhratchFilePicker >> navigationForbidden [
	"Answer true if navigating the file hierarch is forbidden because there is a visibledrives entry in the .ini file."

	| thisDrive pathParts |
	PhratchFrameMorph visibleDrives ifNil: [^ false].

	thisDrive := ''.
	pathParts := (currentDir) path.
	pathParts size > 0 ifTrue: [thisDrive := pathParts first asUppercase].
	OSPlatform isMacOSX ifTrue: [
		((thisDrive = 'volumes') and: [pathParts size > 1]) ifTrue: [
			thisDrive := pathParts second asUppercase]].

	(PhratchFrameMorph visibleDrives includes: thisDrive) ifTrue: [^ false].

	Beeper beep.
	^ true

]

{ #category : #private }
PhratchFilePicker >> newDirectory [
	"Create a new directory."

	| name |
	name := StringDialog askWithCancel: 'New folder name:'.
	name = '' ifTrue: [^ self].
	[(self currentDirectory / name) createDirectory] ifError: [:err :rcvr |
		^ DialogBoxMorph warn: 'Could not create folder.'].
	self currentDirectory: self currentDirectory.

]

{ #category : #accessing }
PhratchFilePicker >> phratchInfoClient: anObject [
	"Set the object to be informed when a Phratch project file with an info dictionary is selected. The client will be sent the message #phratchInfo: once each time such a file is selected, allowing the project thumbnail and other project information to be displayed."

	phratchInfoClient := anObject.

]

{ #category : #accessing }
PhratchFilePicker >> projectFetcher [

	| fullPath |
	fullPath := currentDir path, self selectedFile, '.scratch'.

	phratchProjectFetcher ifNotNil: [  "try to use the existing fetcher"
		(phratchProjectFetcher serverName = currentDir serverName and:
		 [phratchProjectFetcher path = fullPath])
			ifTrue: [^ phratchProjectFetcher]
			ifFalse: [
				phratchProjectFetcher stopDownload.
				phratchProjectFetcher := nil]].

	"make a new fetcher"
	^ HTTPFetcher new
		startDownload: fullPath
		fromServer: currentDir serverName.


]

{ #category : #private }
PhratchFilePicker >> reportPhratchProjectInfo [
	"Try to retrieve info for the currently selected Phratch project and, if successful, report it to our client."

	| fullPath |
	phratchInfoClient ifNil: [^ self].

	phratchProjectFetcher ifNotNil: [
		phratchProjectFetcher stopDownload.
		phratchProjectFetcher := nil].

	self selectedFile ifNil: [phratchInfoClient phratchInfo: nil. ^ self].

	(currentDir isKindOf: AbstractFileReference ) ifTrue: [
		^ phratchInfoClient phratchInfo: self getPhratchInfoFromFile].

	"directory is on a server: start a fetcher to get the project info"
	fullPath := currentDir / self selectedFile, '.scratch'.
	
	((phratchProjectFetcher serverName ~= currentDir serverName) |
	 (phratchProjectFetcher path ~= fullPath)) ifTrue: [
		"start fetching from the new path"
		phratchProjectFetcher
			startDownload: fullPath 
			fromServer: currentDir serverName].

	(Delay forMilliseconds: 50) wait.
	self checkForPhratchInfoFetchDone.

]

{ #category : #private }
PhratchFilePicker >> scrollToFileStartingWith: aCharacter [

	| entries possibilities currentlyHighlightedIndex |
	self stopPlayingSound.

	entries := contentsPaneMorph contents submorphs.
	entries size = 0 ifTrue: [^ self].

	"get all folders and files starting with aCharacter"
	possibilities := entries select: [:e | e entryName asLowercase beginsWith: (String with: aCharacter)].
	possibilities isEmpty ifTrue: [^ self].

	"Find the currentlyHighlightedIndex"
	1 to: entries size do: [:i | | e |
		e := entries at: i.
		e isHighlit ifTrue: [
			e highlight: false. 
			currentlyHighlightedIndex := i]].

	"Find the next file or folder (after the currentlyHighlightedIndex) starting with aCharacter"
	currentlyHighlightedIndex ifNotNil: [
		(currentlyHighlightedIndex + 1) to: entries size do: [:i | | e |
			e := entries at: i.
			(e entryName asLowercase beginsWith: (String with: aCharacter)) ifTrue: [
				^ self highlightAndScrollToEntry: e]]].

	"If all else fails, highlight the first file or folder starting with aCharacter"
	^ self highlightAndScrollToEntry: possibilities first

]

{ #category : #private }
PhratchFilePicker >> selectedEntryOrNil [

	^ contentsPaneMorph contents submorphs
		detect: [:m | m isHighlit]
		ifNone: [^ nil]

]

{ #category : #accessing }
PhratchFilePicker >> selectedFile [
	"Answer the local name of the currently selected file or nil if there is no file selected."

	contentsPaneMorph contents submorphsDo: [:m |
		(m isHighlit & m entryIsDirectory not) ifTrue: [^ m entryName]].
	^ nil

]

{ #category : #private }
PhratchFilePicker >> showParentDirectory [
	"Go to my parent directory."

	self navigationForbidden ifTrue: [^ self].

	self currentDirectory: currentDir parent.

]

{ #category : #accessing }
PhratchFilePicker >> showThumbnails: aBoolean [
	"If true, generate and layout my contents as thumbnails."

	showThumbnails := aBoolean.

]

{ #category : #accessing }
PhratchFilePicker >> startPlayingSound: fullName [
	"Attempt to play the sound with given name."

	self stopPlayingSound.

	(fullName asLowercase endsWith: '.mp3')
		ifTrue: [sound := [StreamingMP3Sound onFileNamed: fullName] ifError: [nil]]
		ifFalse: [sound := [SampledSound fromFileNamed: fullName] ifError: [nil]].

	sound ifNotNil: [
		(sound respondsTo: #volume:) ifTrue: [sound volume: 1.0].
		sound play].

]

{ #category : #'private-thumbnails' }
PhratchFilePicker >> startThumbnailFetchProcess [
	"Start a background process to fetch thumbnails. This process runs at lower priority than the UI thread. The step method looks for thumbnails that have become ready and updates the display."

	thumbnailFetchProcess ifNotNil: [thumbnailFetchProcess terminate].
	thumbnailFetchProcess := [self thumbnailFetchLoop] newProcess.
	thumbnailFetchProcess priority: Processor userBackgroundPriority.
	thumbnailFetchProcess resume.

]

{ #category : #stepping }
PhratchFilePicker >> step [
	"If I am showing thumbnails, poll my contents for thumbnails that are ready for display."

	showThumbnails ifTrue: [
		(Delay forMilliseconds: 10) wait .
		contentsPaneMorph contents submorphsDo: [:m |
			m thumbnailReady ifTrue: [m clearThumbnailReady]]].

	fetchInProgress ifTrue: [
		currentDir fetchInProgress ifFalse: [
			self getFetchedServerDirectoryContents.
			fetchInProgress := false]].

	phratchProjectFetcher ifNotNil: [
		self checkForPhratchInfoFetchDone].

]

{ #category : #stepping }
PhratchFilePicker >> stepTime [

	^ 50

]

{ #category : #accessing }
PhratchFilePicker >> stopPlayingSound [
	"If I am playing a sound, stop it."

	sound ifNotNil: [sound pause].
	sound := nil.

]

{ #category : #'private-thumbnails' }
PhratchFilePicker >> stopThumbnailFetchProcess [

	thumbnailFetchProcess ifNotNil: [
		thumbnailFetchProcess terminate.
		thumbnailFetchProcess := nil].

]

{ #category : #'private-thumbnails' }
PhratchFilePicker >> thumbnailFetchLoop [

	contentsPaneMorph contents submorphs do: [:m |
		self isInWorld ifFalse: [^ self].
		m computeThumbnail.
		(Delay forMilliseconds:  100) wait].

	thumbnailFetchProcess := nil.
	Processor terminateActive.  "stop myself--nothing after here will execute"

]

{ #category : #private }
PhratchFilePicker >> thumbnailStylePageFor: allNames [
	"Answer a new contents page as tableau of thumbnails."

	| page dirNames morphsToAdd leftMargin rightMargin x y m thumbnailCache f |
	page := Morph new
		color: self color;
		width: self width - 20.

	dirNames := currentDir directoryNames asSet.
	thumbnailCache := ThumbnailCache new directory: currentDir.
	thumbnailCache readThumbnailFile; updateThumbnails.
	morphsToAdd := OrderedCollection new: 1000.
	leftMargin := page left + 7.
	rightMargin := page width - 75.
	x := leftMargin.
	y := page top + 5.
	allNames do: [:n |
		m := PhratchFilePickerImageEntry new
			name: n dir: currentDir isDirectory: (dirNames includes: n).
		m
			borderWidth: 0;
			useRoundedCorners.
		f := thumbnailCache thumbnailFor: n.
		f ifNotNil: [m thumbnailForm: f].
		morphsToAdd add: (m position: x@y).
		x := x + m width.
		x > rightMargin ifTrue: [
			x := leftMargin.
			y := y + m height]].

	page addAllMorphs: morphsToAdd.
	^ page

]
