"
I am a class that, when loaded, downloads all necessary files and unpacks them where needed.
"
Class {
	#name : #PhratchInstaller,
	#superclass : #Object,
	#category : #'Phratch-Installation'
}

{ #category : #installation }
PhratchInstaller class >> beginInstall [
	"self
		inform:
			'You are about to install Phratch.', String cr, 'This process will modify some Smalltalk system classes and might subsequently break other projects from this working image.', String cr , 'This is your last chance to abort the installation.'.
"
	| items |
	items := OrderedCollection new.
	items add: (StartupAction
             name: 'Phratch external files'
             code: [PhratchInstaller externalVerification.]).
	StartupLoader default addAtStartupInImageDirectory: items.
	StartupLoader default loadStartupScript.

	AbstractSound initialize.
	SampledSound initialize.
	
	InputEventSensor addInstVarNamed: #keyPressed.


	(Smalltalk at: #SoundSystem ifAbsent: AbstractSoundSystem)  soundEnabled: true.
	SoundPlayer stopReverb.
	PhratchFrameMorph initFonts.
	(Workspace
		openContents:
			'"To try it out run the following expression:" ' 
			, String cr ,
			'PhratchFrameMorph open.'
			)
		label: 'Welcome to Phratch!'.
]

{ #category : #installation }
PhratchInstaller class >> downloadFileFromUrl: anUrl andUnzipIntoDirectory: aPath [

	UIManager default informUserDuring: 
		[ :bar | 
		(ZipArchive new readFrom: (ZnHTTPSocketFacade httpGet: anUrl)) 
			extractAllTo: (aPath)
			informing: bar 
			overwrite: true
			]
	
]

{ #category : #installation }
PhratchInstaller class >> externalVerification [

	PhratchInstaller gotPhratchLicence ifFalse: [PhratchInstaller getPhratchLicence].
	PhratchInstaller gotPhratchSkins ifFalse: [PhratchInstaller getPhratchSkins].
	PhratchInstaller gotPhratchPlugins ifFalse: [PhratchInstaller getPhratchPlugins]. 
	PhratchInstaller gotPhratchLocales ifFalse: [PhratchInstaller getPhratchLocales].
	PhratchInstaller gotPhratchMedia ifFalse: [PhratchInstaller getPhratchMedia].
	PhratchInstaller gotPhratchHelp ifFalse: [PhratchInstaller getPhratchHelp].
	PhratchInstaller gotBYOBManual ifFalse: [PhratchInstaller getBYOBManual].

]

{ #category : #installation }
PhratchInstaller class >> getBYOBManual [
	UIManager inform:  'Downloading BYOB Manual'.
	self
		downloadFileFromUrl: 'https://phratch.googlecode.com/files/Manual.zip' 
		andUnzipIntoDirectory: FileSystem workingDirectory
]

{ #category : #installation }
PhratchInstaller class >> getPhratchHelp [
	UIManager inform: 'Downloading Help'.
	self
		downloadFileFromUrl: 'https://phratch.googlecode.com/files/Help.zip' 
		andUnzipIntoDirectory: FileSystem workingDirectory
]

{ #category : #installation }
PhratchInstaller class >> getPhratchLicence [
	UIManager inform:  'Downloading licence.txt'.
	(FileStream newFileNamed: 'license.txt') nextPutAll: ((ZnHTTPSocketFacade httpGet: 'https://phratch.googlecode.com/files/license.txt'))
]

{ #category : #installation }
PhratchInstaller class >> getPhratchLocales [
	UIManager inform:  'Downloading Local'.
	self
		downloadFileFromUrl: 'https://phratch.googlecode.com/files/locale.zip'
		andUnzipIntoDirectory: FileSystem workingDirectory
]

{ #category : #installation }
PhratchInstaller class >> getPhratchMedia [
	UIManager inform: 'Downloading Media'.
	self
		downloadFileFromUrl: 'https://phratch.googlecode.com/files/Media.zip'
		andUnzipIntoDirectory: FileSystem workingDirectory 
]

{ #category : #installation }
PhratchInstaller class >> getPhratchPlugins [
	UIManager inform:  'Downloading Plugins'.
	UIManager inform: 'This will install plugins in VM directory'.
	self
		downloadFileFromUrl: self pluginsURL
		andUnzipIntoDirectory: (self pluginsPath)
]

{ #category : #installation }
PhratchInstaller class >> getPhratchSkins [
	UIManager inform: 'Downloading ScratchSkin'.
	self
		downloadFileFromUrl: 'https://phratch.googlecode.com/files/ScratchSkin.zip'
		andUnzipIntoDirectory: (FileSystem workingDirectory)
]

{ #category : #installation }
PhratchInstaller class >> gotBYOBManual [
	^ (FileSystem workingDirectory / 'Manual') exists
]

{ #category : #installation }
PhratchInstaller class >> gotPhratchHelp [
	^ (FileSystem workingDirectory / 'Help') exists
]

{ #category : #installation }
PhratchInstaller class >> gotPhratchLicence [
	^ (FileSystem workingDirectory / 'license.txt') exists
]

{ #category : #installation }
PhratchInstaller class >> gotPhratchLocales [
	^ (FileSystem workingDirectory / 'locale') exists
]

{ #category : #installation }
PhratchInstaller class >> gotPhratchMedia [
	^ (FileSystem workingDirectory / 'Media') exists
]

{ #category : #installation }
PhratchInstaller class >> gotPhratchPlugins [
	^ (self pluginsPath /  'CameraPlugin') exists
		& (self pluginsPath /  'mpeg3Plugin') exists
		& (self pluginsPath / 'ScratchPlugin') exists
]

{ #category : #installation }
PhratchInstaller class >> gotPhratchSkins [
	^ (FileSystem workingDirectory / 'ScratchSkin') exists
]

{ #category : #'class initialization' }
PhratchInstaller class >> initialize [
"	InputEventSensor startUp."
	SoundPlayer initialize; shutDown; startUp.
]

{ #category : #installation }
PhratchInstaller class >> phratchSettingsOn: aBuilder [  
	<systemsettings>  
	(aBuilder group: #phratch)
		label: 'Phratch' translated;
		description: 'All Phratch settings' translated;
		with: [ 
			(aBuilder setting: #insertionPointColor) 
				label: 'insertionPointColor' translated;
		 		target: Paragraph;
		 		description: '...' translated.	
			(aBuilder setting: #noviceMode) 
				label: 'noviceMode' translated;
		 		target: ScriptablePhratchMorph;
		 		description: '...' translated.	
			(aBuilder setting: #standardButtonFont) 
				label: 'standardButtonFont' translated;
		 		target: PhratchFrameMorph;
		 		description: '...' translated.	
			(aBuilder setting: #standardMenuFont) 
				label: 'standardMenuFont' translated;
		 		target: PhratchFrameMorph;
		 		description: '...' translated.	
			(aBuilder setting: #useLargeFonts) 
				label: 'useLargeFonts' translated;
		 		target: PhratchFrameMorph;
		 		description: '...' translated.	
			(aBuilder setting: #warnIfNoChangesFile) 
				label: 'warnIfNoChangesFile' translated;
		 		target: ElementsMethodEditorMorph;
		 		description: '...' translated.	
			(aBuilder setting: #warnIfNoSourcesFile) 
				label: 'warnIfNoSourcesFile' translated;
		 		target: ElementsMethodEditorMorph;
		 		description: '...' translated.	
			(aBuilder setting: #meshServerEnabled) 
				label: 'meshServerEnabled' translated;
		 		target: PhratchFrameMorph;
		 		description: 'A mesh server allows to share projects' translated.	
			(aBuilder setting: #takeOverScreen) 
				label: 'takeOverScreen' translated;
		 		target: PhratchFrameMorph;
		 		description: 'Do you allow Phratch to display on all screen' translated.	
			(aBuilder setting: #fileIOPreference) 
				label: 'fileIOPreference' translated;
		 		target: ScriptablePhratchMorph;
		 		description: 'Do you allow Phratch to write files' translated.	
			(aBuilder group: #visibility)
				label: 'Category Visibility' translated;
				description: 'Category Visibility' translated;
				with: [ 
					(PhratchCategory allSubclasses) do:[:e | 
						(aBuilder setting: #visible) 
							label: e label, ' visible' translated;
		 					target: e;
		 					description: 'Do you want to see this category ?' translated.
					].
				].
			(aBuilder launcher: #updatePhratchView)
				target: PhratchFrameMorph "; targetSelector: #closeAndOpen";
				script: #closeAndOpen;
				label: 'Update the view of Phratch' translated.
		].
]

{ #category : #installation }
PhratchInstaller class >> pluginsPath [

"	^(Smalltalk vmBinary resolve parent / 'Plugins')."
	"^ FileSystem workingDirectory"
	^ OSPlatform isMacOS
		ifTrue: [ ^ Smalltalk vmBinary resolve  parent / 'Plugins' ]
		ifFalse: [ 
			(OSPlatform isUnix or: [ OSPlatform isWin32 ])
				ifTrue: [ ^ Smalltalk vmBinary resolve  parent]
				ifFalse: [ self error: 'Your operating system is not supported yet by the installer. Please visit https://code.google.com/p/phratch/ for details, and contact developers.' ]
		]
]

{ #category : #installation }
PhratchInstaller class >> pluginsURL [
	^ OSPlatform isMacOS
		ifTrue: [ ^ 'https://phratch.googlecode.com/files/pluginsMacOSX.zip' ]
		ifFalse: [ 
			OSPlatform isUnix
				ifTrue: [ ^ 'https://phratch.googlecode.com/files/pluginsGNULinux.zip' ]
				ifFalse: [ 
					OSPlatform isWin32
						ifTrue: [ ^ 'https://phratch.googlecode.com/files/pluginsWin32.zip' ]
						ifFalse: [ 
							self
								error:
									'Your operating system is not supported yet by the installer.' ] ] ]
]
