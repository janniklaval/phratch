"
Allows the user to navigate through files and folders to select a file.

"
Class {
	#name : #PhratchFilePicker,
	#superclass : #ImageFrameMorph,
	#instVars : [
		'directoryBarMorph',
		'contentsPaneMorph',
		'currentDir',
		'extensions',
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
		'phratchInfoClient'
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
		color: Color transparent;
		yourself.
	directoryBarArrowMorph := ImageMorph new form: (PhratchFrameMorph skinAt: #directoryBarArrow).
	directoryBarMorph := ResizableToggleButton new
		offForm: (PhratchFrameMorph skinAt: #directoryBar)
		onForm: (PhratchFrameMorph skinAt: #directoryBar);
		padding: 3@5;
		yourself.
	directoryBarMorph
		target: self;
		actionSelector: #directoryMenu;
		actWhen: #buttonUp.
	topBarMorph
		addMorphBack: (Morph new extent: (5@5); color: Color transparent;
		yourself);
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
		addMorphBack: (Morph new extent: (5@5); color: Color transparent;
		yourself);
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
		addMorphBack: (Morph new extent: (5@5); color: Color transparent;
		yourself);
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

	contentsPaneMorph := ScrollFrameMorph new
		color: self color;
		contents: (Morph new color: self color);
		showHorizontalScrollbar: false;
		hBarInset: 18;
		vBarInset: 18;
		yourself.

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

{ #category : #accessing }
PhratchFilePicker >> currentDirectory [
	"Answer the directory that is currently being viewed."

	^ currentDir

]

{ #category : #accessing }
PhratchFilePicker >> currentDirectory: aDirectoryOrString [
	"Set my current directory to the given directory or path String."

	| s truncated w eWidth |

	currentDir := (aDirectoryOrString isString)
		ifTrue: [ aDirectoryOrString asFileReference ]
		ifFalse: [ aDirectoryOrString ].
	s := currentDir fullName isEmpty
		ifTrue: [ FileSystem root basename ]
		ifFalse: [ currentDir basename ].	"trim directory name to fit button, if necessary"
	truncated := false.
	eWidth := (PhratchTranslator stringExtent: '...' font: directoryBarMorph label font) x.
	w := 190 - eWidth.
	[ (PhratchTranslator stringExtent: s font: directoryBarMorph label font) x > w ]
		whileTrue: [ 
			truncated := true.
			s := s copyFrom: 1 to: s size - 1 ].
	truncated
		ifTrue: [ s := s , '...' ].
	s = '/'
		ifTrue: [ s := 'Computer' ].
	directoryBarMorph label: (String withAll: s) font: (PhratchFrameMorph getFont: #FilePickerDirectoryName).
	directoryBarMorph width: contentsPaneMorph width - 160.
	directoryBarArrowMorph right: directoryBarMorph right - 9.
	lastUpMSecs := 0.
	self getDirectoryContents
]

{ #category : #private }
PhratchFilePicker >> deleteDirectory [
	"Delete the directory or file that is currently highlit."

	| entries selectedDir dirEntries response e1 |
	entries := contentsPaneMorph contents submorphs.
	selectedDir := entries
		detect: [ :e | 
			e1 := e.
			e isHighlit & e entryIsDirectory ]
		ifNone: [ ^ self ].
	dirEntries := (self currentDirectory / selectedDir) entries.
	dirEntries size > 0
		ifTrue: [ ^ self ].	"do nothing if selectedDir is not empty"
	freezeFocus := true.
	response := DialogBoxMorph ask: 'Are you sure you want to delete the empty folder ''' , selectedDir entryName , '''?'.
	freezeFocus := false.
	response
		ifFalse: [ ^ self ].
	[ self currentDirectory delete: e1 entryName ] ifError: [ ^ DialogBoxMorph warn: 'Could not delete folder.' ].
	^ self currentDirectory: self currentDirectory
]

{ #category : #private }
PhratchFilePicker >> directoryMenu [
	"Present a drop-down menu of all directories in my current path."

	| menu pathParts prefix choice pathArg |
	
	self navigationForbidden ifTrue: [^ self].
	menu := MenuMorph new defaultTarget: self.
	pathParts := (currentDir) path.
	prefix := ''.
	pathArg := ''.
	pathParts do: [:part |
		pathArg := pathArg , '/' , part.
		menu add: prefix, part
				target: self 
				selector: #currentDirectory:
				argument: pathArg.
		prefix := prefix ,'  ' ].
	pathParts isEmpty ifTrue: [
		menu add: 'Computer' 
				target: self 
				selector: #currentDirectory:
				argument: (FileSystem root) fullName].

	self addDriveShortcuts: menu.

	menu invokeModal.

	choice := self currentDirectory.
	^ self currentDirectory: choice

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

	^ self getLocalDirectoryContents
]

{ #category : #private }
PhratchFilePicker >> getLocalDirectoryContents [
	"Generate and layout the morphs in my contents pane from the files and folder in the current local directory."

	| allNames fileNames dirNames ext page |
	"make an alphabetized list of all files and directory names"
	fileNames := currentDir fileNames.
	extensions
		ifNotNil: [ 
			"filter out files without a matching extension"
			fileNames := fileNames select: [ :n | extensions includes: (currentDir / n) extension asLowercase ] ].
	fileNames := fileNames sort: [ :n1 :n2 | n1 caseInsensitiveLessOrEqual: n2 ].
	dirNames := self getLocalDirectoryNames.
	dirNames := dirNames sort: [ :n1 :n2 | n1 caseInsensitiveLessOrEqual: n2 ].
	allNames := dirNames , fileNames.
	allNames := allNames reject: [ :n | n endsWith: ':=th.gif' ].	"suppress Phratch project thumbnails"
	allNames := allNames reject: [ :n | n beginsWith: '.' ].	"suppress hidden files on Mac OS X and Unix"
	allNames := allNames
		reject: [ :n | 
			ext := (currentDir / n) extension asLowercase.
			#(#app #dll #exe #ini #image #changes #sprite) includes: ext ].
	"allNames := allNames reject: [ :n | PhratchPlugin isHidden: (currentDir / n) fullName ]."	"suppress hidden files/folders on Win32"
	currentDir fullName = FileSystem workingDirectory fullName
		ifTrue: [ 
			allNames := allNames
				reject: [ :fn | #(#help #icons 'license.txt' #locale #plugins 'scratch.app') includes: fn asLowercase ] ].
	page := showThumbnails
		ifTrue: [ self thumbnailStylePageFor: allNames ]
		ifFalse: [ self listStylePageFor: allNames ].
	contentsPaneMorph contents: page.
	showThumbnails
		ifTrue: [ self startThumbnailFetchProcess ].
	self changeSelectionIndexBy: 1
]

{ #category : #private }
PhratchFilePicker >> getLocalDirectoryNames [
	"Answer the directories in currentDir. Suppress hidden volumes."

	| dirNames visible |
	dirNames := currentDir directoryNames.
	(visible := PhratchFrameMorph visibleDrives) ifNil: [^ dirNames].

	Smalltalk os isMacOSX
		ifTrue: [currentDir pathName = '/Volumes' ifFalse: [^ dirNames]]
		ifFalse: [currentDir pathName = '' ifFalse: [^ dirNames]].

	^ dirNames select: [:dir | visible includes: dir asUppercase]

]

{ #category : #private }
PhratchFilePicker >> getPhratchInfoFromFile [
	"Answer the project info dictionary for the currently selected file. Answer the empty dictionary if no file is selected or if the file does not include a project info dictionary (e.g. if it is in an older Phratch file format)."

	| result fullName f version buf |
	result := Dictionary new.
	self selectedFile ifNil: [ ^ result ].
	fullName := (currentDir / self selectedFile) fullName.
	fullName asFileReference exists
		ifFalse: [ ^ result ].
	[ f := (FileStream readOnlyFileNamed: fullName) binary ] ifError: [ ^ result ].
	[ 
	version := FuelObjStream phratchFileVersionFrom: (f next: 10) asString.
	({1.2} includes: version)
		ifTrue: [ 
			buf := f next: f uint32.
			result := ((FuelObjStream new readObjFrom: (ReadStream on: buf)) associations collect: [ :each | each value ])
				asDictionary ] ]
		ifError: [ :e | 
			ScriptablePhratchMorph noviceMode ifFalse:[e signal].
		].
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
		(m isPhratchFilePickerEntry) ifTrue: [
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
	"fetchInProgress := false."
	showThumbnails := false.
	finalSelection := false.
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

{ #category : #accessing }
PhratchFilePicker >> isPhratchFilePicker [

	^ true
]

{ #category : #'event handling' }
PhratchFilePicker >> keyStroke: evt [
	"Handle up/down arrow keys."

	| ch m entry |
	freezeFocus ifTrue: [^ self].

	ch := evt keyValue.

	ch = 9 ifTrue: [  "tab"
		(m := self ownerOrYourselfThatIsADialogBoxMorph) ifNotNil: [m tabToNextField: evt].
		^ self].

	ch = 27 ifTrue: [  "escape key"
		(m := self ownerOrYourselfThatIsADialogBoxMorph) ifNotNil: [m escapeKeyPressed: evt].
		^ self].

	({1 . 11} includes: ch) ifTrue: [ "home or page up"
		self selectedEntryOrNil ifNotNil: [self selectedEntryOrNil highlight: false].
		^ self highlightAndScrollToEntry: contentsPaneMorph contents submorphs first].

	({4 . 12} includes: ch) ifTrue: [ "end or page down"
		self selectedEntryOrNil ifNotNil: [self selectedEntryOrNil highlight: false].
		^ self highlightAndScrollToEntry: contentsPaneMorph contents submorphs last].

	({8 . 127} includes: ch) ifTrue: [ "delete key"
		self deleteDirectory].

	({10 . 13} includes: ch) ifTrue: [  "cr, lf, or enter key"
		(entry := self selectedEntryOrNil) ifNil: [^ self].
		(entry entryIsDirectory and:
		 [(owner isKindOf: PhratchFileChooserDialog)])
			ifTrue: [self currentDirectory: (currentDir / entry entryName)]
			ifFalse: [(self ownerOrYourselfThatIsAPhratchFileChooserDialog) yes].
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
		width: self width - 20;
		yourself.

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
			useRoundedCorners;
		yourself.
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
	finalSelection ifTrue: [(self ownerOrYourselfThatIsAPhratchFileChooserDialog) yes].
]

{ #category : #private }
PhratchFilePicker >> navigationForbidden [

	^ false
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

{ #category : #private }
PhratchFilePicker >> reportPhratchProjectInfo [
	"Try to retrieve info for the currently selected Phratch project and, if successful, report it to our client."

	phratchInfoClient ifNil: [^ self].
	self selectedFile ifNil: [phratchInfoClient phratchInfo: nil. ^ self].

	^ phratchInfoClient phratchInfo: self getPhratchInfoFromFile
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

	"fetchInProgress ifTrue: [
		currentDir fetchInProgress ifFalse: [
			self getFetchedServerDirectoryContents.
			fetchInProgress := false]]."

	"phratchProjectFetcher ifNotNil: [
		self checkForPhratchInfoFetchDone]."

	showThumbnails
		ifFalse: [ ^ self ].
	(Delay forMilliseconds: 10) wait.
	contentsPaneMorph contents
		submorphsDo: [ :m | 
			m thumbnailReady
				ifTrue: [ m clearThumbnailReady ] ]
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
PhratchFilePicker >> thumbnailFetchLoop [

	contentsPaneMorph contents submorphs do: [:m |
		self isInWorld ifFalse: [^ self].
		"m computeThumbnail."
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
		width: self width - 20;
		yourself.

	dirNames := currentDir directoryNames asSet.
	thumbnailCache := ThumbnailCache new directory: currentDir.
	thumbnailCache updateThumbnails.
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
