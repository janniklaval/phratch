"
I am a class that, when loaded, downloads all necessary files and unpacks them where needed.
"
Class {
	#name : #PhratchInstaller,
	#superclass : #Object,
	#category : #'Phratch-Installation'
}

{ #category : #'as yet unclassified' }
PhratchInstaller class >> beginInstall [
	"self
		inform:
			'You are about to install Phratch.', String cr, 'This process will modify some Smalltalk system classes and might subsequently break other projects from this working image.', String cr , 'This is your last chance to abort the installation.'.
"
	self gotPhratchSkins ifFalse: [self getPhratchSkins].
	self gotPhratchPlugins ifFalse: [self getPhratchPlugins]. 
	self gotPhratchLocales ifFalse: [self getPhratchLocales].
	self gotPhratchMedia ifFalse: [self getPhratchMedia].
	self gotPhratchHelp ifFalse: [self getPhratchHelp].
	self gotBYOBManual ifFalse: [self getBYOBManual].

	AbstractSound initialize.
	SampledSound initialize.
	
	InputEventSensor addInstVarNamed: #keyPressed.


	AbstractSoundSystem soundEnabled: true.
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

{ #category : #'as yet unclassified' }
PhratchInstaller class >> downloadFileFromUrl: anUrl andUnzipIntoDirectory: aPath [
	(ZipArchive new readFrom: (ZnHTTPSocketFacade httpGet: anUrl)) extractAllTo: (aPath)
]

{ #category : #'as yet unclassified' }
PhratchInstaller class >> getBYOBManual [
	Transcript cr; 
		show: 'Downloading BYOB Manual'.
	self
		downloadFileFromUrl: 'https://phratch.googlecode.com/files/Manual.zip' 
		andUnzipIntoDirectory: FileSystem workingDirectory
]

{ #category : #'as yet unclassified' }
PhratchInstaller class >> getPhratchHelp [
	Transcript cr; 
		show: 'Downloading Help'.
	self
		downloadFileFromUrl: 'https://phratch.googlecode.com/files/Help.zip' 
		andUnzipIntoDirectory: FileSystem workingDirectory
]

{ #category : #'as yet unclassified' }
PhratchInstaller class >> getPhratchLocales [
	Transcript cr; 
		show: 'Downloading Local'.
	self
		downloadFileFromUrl: 'https://phratch.googlecode.com/files/locale.zip'
		andUnzipIntoDirectory: FileSystem workingDirectory
]

{ #category : #'as yet unclassified' }
PhratchInstaller class >> getPhratchMedia [
	Transcript cr; 
		show: 'Downloading Media'.
	self
		downloadFileFromUrl: 'https://phratch.googlecode.com/files/Media.zip'
		andUnzipIntoDirectory: FileSystem workingDirectory 
]

{ #category : #'as yet unclassified' }
PhratchInstaller class >> getPhratchPlugins [
	Transcript cr; 
		show: 'Downloading Plugins'.
	UIManager inform: 'This will install plugins in VM directory'.
	self
		downloadFileFromUrl: self pluginsURL
		andUnzipIntoDirectory: (self pluginsPath)
]

{ #category : #'as yet unclassified' }
PhratchInstaller class >> getPhratchSkins [
	Transcript cr; 
		show: 'Downloading ScratchSkin'.
	self
		downloadFileFromUrl: 'https://phratch.googlecode.com/files/ScratchSkin.zip'
		andUnzipIntoDirectory: FileSystem workingDirectory
]

{ #category : #'as yet unclassified' }
PhratchInstaller class >> gotBYOBManual [
	^ (FileSystem workingDirectory / 'Manual') exists
]

{ #category : #'as yet unclassified' }
PhratchInstaller class >> gotPhratchHelp [
	^ (FileSystem workingDirectory / 'Help') exists
]

{ #category : #'as yet unclassified' }
PhratchInstaller class >> gotPhratchLocales [
	^ (FileSystem workingDirectory / 'locale') exists
]

{ #category : #'as yet unclassified' }
PhratchInstaller class >> gotPhratchMedia [
	^ (FileSystem workingDirectory / 'Media') exists
]

{ #category : #'as yet unclassified' }
PhratchInstaller class >> gotPhratchPlugins [
	^ (self pluginsPath /  'CameraPlugin') exists
		& (self pluginsPath / 'LocalePlugin') exists
		& (self pluginsPath /  'mpeg3Plugin') exists
		& (self pluginsPath / 'ScratchPlugin') exists
		& (self pluginsPath / 'UnicodePlugin') exists
]

{ #category : #'as yet unclassified' }
PhratchInstaller class >> gotPhratchSkins [
	^ (FileSystem workingDirectory / 'ScratchSkin') exists
]

{ #category : #'as yet unclassified' }
PhratchInstaller class >> initialize [
"	InputEventSensor startUp."
	SoundPlayer initialize; shutDown; startUp.
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
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
