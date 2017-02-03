"
I am a class that, when loaded, downloads all necessary files and unpacks them where needed.
"
Class {
	#name : #PhratchInstaller,
	#superclass : #Object,
	#classVars : [
		'DeclaredSprites'
	],
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
	items add: (StartupAction
             name: 'Phratch window size'
             code: [PhratchInstaller fixWindowSize.]).
	StartupLoader default addAtStartupInImageDirectory: items.
	StartupLoader default loadFromDefaultLocations.

	(Workspace
		openContents:
			'"To try it out run the following expression:" ' 
			, String cr ,
			'PhratchFrameMorph open.'
			)
		label: 'Welcome to Phratch!'.
]

{ #category : #'class initialization' }
PhratchInstaller class >> declaredSprite [

	DeclaredSprites ifEmpty:[DeclaredSprites := Smalltalk allClasses select: [:e | (Pragma allNamed: #phratchObject in:  e class) notEmpty ]].
	^ DeclaredSprites
]

{ #category : #installation }
PhratchInstaller class >> downloadFileFromUrl: anUrl andUnzipIntoDirectory: aPath [

	| i |
	UIManager default informUserDuring: 
		[ :bar | 
		i:= ZnClient new get: anUrl.
		(ZipArchive new readFrom: (ReadStream on: i from: 1 to: i size)) 
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
	PhratchInstaller gotPhratchFont ifFalse: [PhratchInstaller getPhratchFont].

]

{ #category : #installation }
PhratchInstaller class >> fixWindowSize [

	"Display fullscreen: true.
	1 second wait.
	p:= DisplayScreen actualScreenSize.
	Display fullscreen: false."
	DisplayScreen hostWindowTitle: 'phratch'.
	"DisplayScreen hostWindowSize: ((p x * 19/20) asInteger @ (p y * 19/20) asInteger)."

]

{ #category : #installation }
PhratchInstaller class >> getBYOBManual [
	UIManager inform:  'Downloading BYOB Manual'.
	self
		downloadFileFromUrl: 'https://github.com/janniklaval/phratch/raw/master/Manual.zip' 
		andUnzipIntoDirectory: FileSystem workingDirectory
]

{ #category : #installation }
PhratchInstaller class >> getPhratchFont [
	UIManager inform: 'Downloading Fonts'.
	(FileSystem workingDirectory / 'Fonts') ensureCreateDirectory.
	self
		downloadFileFromUrl: 'http://software.sil.org/downloads/d/andika/Andika-5.000.zip'
		andUnzipIntoDirectory: FileSystem workingDirectory / 'Fonts'.
]

{ #category : #installation }
PhratchInstaller class >> getPhratchHelp [
	UIManager inform: 'Downloading Help'.
	self
		downloadFileFromUrl: 'https://github.com/janniklaval/phratch/raw/master/Help.zip' 
		andUnzipIntoDirectory: FileSystem workingDirectory
]

{ #category : #installation }
PhratchInstaller class >> getPhratchLicence [
	UIManager inform:  'Downloading licence.txt'.
	(FileStream newFileNamed: 'license.txt') nextPutAll: ((ZnClient new get: 'https://github.com/janniklaval/phratch/raw/master/license.txt'))
]

{ #category : #installation }
PhratchInstaller class >> getPhratchLocales [
	UIManager inform:  'Downloading Local'.
	
	{ 'eu' . 'is' . 'ne' . 'sv' . 'fa' . 'it' . 'nl' . 'th' . 'ar' . 'fi' . 'ja' . 'no' . 'tr' . 'bg' . 'fr' . 'ja_HIRA' . 'pl' . 'uk' . 'ca' . 'fr_CA' . 'kn' . 'pt' . 'vi' . 'cs' . 'gl' . 'ko' . 'pt_BR' . 'zh_CN' . 'da' . 'he' . 'lt' . 'ro' . 'zh_TW' . 'de' . 'hr' . 'mk' . 'ru' . 'el' . 'ht' . 'mn' . 'rw' . 'es' . 'hu' . 'mr' . 'sk' . 'et' . 'id' . 'ms' . 'sl' } do: [:lang | |f|
		('locale' asFileReference) ensureCreateDirectory.
		f:=( ('locale' asFileReference / lang,'po') writeStream).
		f nextPutAll: (ZnClient new get: 'https://raw.github.com/janniklaval/phratch/master/locale/',lang,'.po' )
	].
]

{ #category : #installation }
PhratchInstaller class >> getPhratchMedia [
	UIManager inform: 'Downloading Media'.
	(FileSystem workingDirectory / 'Media') ensureCreateDirectory.
	self
		downloadFileFromUrl: 'https://github.com/janniklaval/phratch/raw/master/Media/Backgrounds.zip'
		andUnzipIntoDirectory: (FileSystem workingDirectory / 'Media'). 
		
	self
		downloadFileFromUrl: 'https://github.com/janniklaval/phratch/raw/master/Media/Costumes.zip'
		andUnzipIntoDirectory: (FileSystem workingDirectory / 'Media').
		
	self
		downloadFileFromUrl: 'https://github.com/janniklaval/phratch/raw/master/Media/Sounds.zip'
		andUnzipIntoDirectory: (FileSystem workingDirectory / 'Media')
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
	UIManager inform: 'Downloading ', self skinFolder.
	self
		downloadFileFromUrl: 'https://github.com/janniklaval/phratch/raw/master/', self skinFolder, '.zip'
		andUnzipIntoDirectory: (FileSystem workingDirectory)
]

{ #category : #installation }
PhratchInstaller class >> gotBYOBManual [
	^ (FileSystem workingDirectory / 'Manual') exists
]

{ #category : #installation }
PhratchInstaller class >> gotPhratchFont [
	^ (FileSystem workingDirectory / 'Fonts') exists
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
	^ ((self pluginsPath /  'CameraPlugin') exists
		& (self pluginsPath /  'mpeg3Plugin') exists
		& (self pluginsPath / 'ScratchPlugin') exists)
		
	or: [ ((self pluginsPath /  'CameraPlugin.dll') exists
		& (self pluginsPath /  'Mpeg3Plugin.dll') exists
		& (self pluginsPath / 'ScratchPlugin.dll') exists) 

	or: [  (self pluginsPath /  'CameraPlugin') exists
		& (self pluginsPath /  'Mpeg3Plugin') exists
		& (self pluginsPath / 'ScratchPlugin') exists]
	]
]

{ #category : #installation }
PhratchInstaller class >> gotPhratchSkins [
	^ (FileSystem workingDirectory / self skinFolder) exists
]

{ #category : #'class initialization' }
PhratchInstaller class >> initialize [
	DeclaredSprites := OrderedCollection new.

]

{ #category : #'class initialization' }
PhratchInstaller class >> isLocaleAndikaFontCompatible [
"Include here locale compatible with Latin or Cyrillic alphabets"
	^ #('bg' 'ca' 'cs' 'da' 'de' 'es' 'en' 'et' 'fi' 'fr' 'fr_CA' 'gl' 'hr' 'ht' 'hu' 'id' 
	'is' 'it' 'lt' 'mk' 'mn' 'nl' 'no' 'pl'	'pt' 'pt_BR' 'ro' 'ru' 'rw' 'sk' 'sl' 'sv' 'tr' 
	'uk' 'vi') includes: PhratchTranslator currentLanguage.
]

{ #category : #installation }
PhratchInstaller class >> phratchSettingsOn: aBuilder [  
	<systemsettings>  
	(aBuilder group: #phratch)
		label: 'Phratch' localized;
		description: 'All Phratch settings' localized;
		with: [ 
			(aBuilder setting: #noviceMode) 
				label: 'noviceMode' localized;
		 		target: ScriptablePhratchMorph;
		 		description: '...' localized.	
			(aBuilder setting: #traceMode) 
				label: 'traceMode' localized;
		 		target: ScriptablePhratchMorph;
		 		description: '...' localized.	
			(aBuilder setting: #fileIOPreference) 
				label: 'fileIOPreference' localized;
		 		target: ScriptablePhratchMorph;
		 		description: 'Do you allow Phratch to write files' localized.	
			(aBuilder group: #visibility)
				label: 'Category Visibility' localized;
				description: 'Category Visibility' localized;
				with: [ 
					(PhratchCategory allSubclasses) do:[:e | 
						(aBuilder setting: #visible) 
							label: e label, ' visible' localized;
		 					target: e;
		 					description: 'Do you want to see this category ?' localized.
					].
				].
 
			(aBuilder group: #blockVisibility)
				label: 'Block Visibility' localized;
				description: 'Block Visibility' localized;
				with: [ |allPragmas|
					allPragmas := (Pragma
						allNamed: #phratchItem:kind:category:defaultValues:subCategory:special:
						in: ScriptablePhratchMorph) asOrderedCollection.
					ScriptablePhratchMorph allSubclasses
						do: [ :aSC | allPragmas addAll: (Pragma allNamed: #phratchItem:kind:category:defaultValues:subCategory:special: in: aSC) ].
					allPragmas sort: [ :a :b | (a argumentAt: 3) < (b argumentAt: 3) ].
					allPragmas do:[:e | 
						|prov|
						prov := {(e arguments at: 1).
							(e arguments at: 2).
							(e method selector).
							(e arguments at: 6)} , (e arguments at: 4).
							
						(aBuilder setting: #blockVisible) 
							icon: ((e methodClass new blockFromSpec: prov color: (PhratchCategory blockColorFor: (e arguments at: 3))) imageForm);
							label: "(e arguments at: 1), "' visible' localized;
		 					target: PhratchBlockSettings ;
							targetSelector: (e arguments at: 1);
							getSelector: #blockVisible;
							setSelector: #blockVisible:;
		 					description: 'Do you want to see this block ?' localized.
					PhratchBlockSettings addConfiguredMessages: (e arguments at: 1).
					].
				].
			(aBuilder launcher: #updatePhratchView)
				target: PhratchFrameMorph "; targetSelector: #closeAndOpen";
				script: #rebuildUI;
				label: 'Update Phratch display' localized.
		].
]

{ #category : #installation }
PhratchInstaller class >> pluginsPath [

"	^(Smalltalk vmBinary resolve parent / 'Plugins')."
	"^ FileSystem workingDirectory"
	^ Smalltalk os isMacOSX
		ifTrue: [ ^ Smalltalk vmBinary resolve  parent / 'Plugins' ]
		ifFalse: [ 
			(Smalltalk os isUnix or: [ Smalltalk os isWin32 ])
				ifTrue: [ ^ Smalltalk vmBinary resolve  parent]
				ifFalse: [ self error: 'Your operating system is not supported yet by the installer. Please visit https://code.google.com/p/phratch/ for details, and contact developers.' ]
		]
]

{ #category : #installation }
PhratchInstaller class >> pluginsURL [
	^ Smalltalk os isMacOSX
		ifTrue: [ ^ 'https://github.com/janniklaval/phratch/raw/master/pluginsMacOSX.zip' ]
		ifFalse: [ 
			Smalltalk os isUnix
				ifTrue: [ ^ 'https://github.com/janniklaval/phratch/raw/master/pluginsGNULinux.zip' ]
				ifFalse: [ 
					Smalltalk os isWin32
						ifTrue: [ ^ 'https://github.com/janniklaval/phratch/raw/master/pluginsWin32.zip' ]
						ifFalse: [ 
							self
								error:
									'Your operating system is not supported yet by the installer.' ] ] ]
]

{ #category : #setting }
PhratchInstaller class >> prepareImageForEndUserSilently: aFrameMorph [

"	(self confirm: '
Close non-Phratch windows and save this
image in end-user (fillScreen) mode?') ifFalse: [^ self].
"
	aFrameMorph setLanguage: 'en'.

	aFrameMorph enterNormalMode.
	ScriptablePhratchMorph keepOnStage: true.
	
	EventHatMorph threadSafeMode: false.

	BlockLabelFragmentDialog isExpanded: false.

	World submorphs do: [:m |
		(m isKindOf: SystemWindow) ifTrue: [m delete]].
	aFrameMorph clearStage.

	Display newDepth: 32.
	aFrameMorph enterUserMode.
	World doOneCycleNow.
	aFrameMorph newPhratchProject.
	ImageCleaner cleanUpForProduction.

	
]

{ #category : #setting }
PhratchInstaller class >> saveImageForEndUserSilently [

	| frame |
	frame := PhratchFrameMorph open.
	self prepareImageForEndUserSilently: frame.
	Smalltalk snapshot: true andQuit: true.
	frame startup.

]

{ #category : #'class initialization' }
PhratchInstaller class >> selectFontForLocale [
	| font |
	"Shake a bit FreeType"
	FreeTypeSystemSettings loadFt2Library ifTrue:[
		FreeTypeSystemSettings loadFt2Library: false.
		FreeTypeSystemSettings loadFt2Library: true].
	self isLocaleAndikaFontCompatible 
		ifTrue: [
			FreeTypeFontProvider current 
				updateFromFile: FileSystem workingDirectory / 'Fonts' / 'Andika-5.000' / 'Andika-R.ttf'.
			FreeTypeFontProvider current updateAvailableFontFamilies.
			font := LogicalFont familyName: 'Andika' pointSize: 10] 
		ifFalse: [
			FreeTypeSettings updateFontsAtImageStartup: true.
			FreeTypeSettings updateFreeType.
			font := LogicalFont 
				familyName: 'Arial Unicode MS'
				fallbackFamilyNames: nil pointSize: 10 stretchValue: 5	weightValue: 400 slantValue: 0.
			FreeTypeSettings updateFontsAtImageStartup: false].
	StandardFonts defaultFont: font.
	StandardFonts menuFont: font.
	StandardFonts balloonFont: font.
	BalloonMorph setBalloonColorTo: Color yellow muchLighter.
]

{ #category : #installation }
PhratchInstaller class >> skinFolder [

	^ 'ScratchSkin'
]

{ #category : #'class initialization' }
PhratchInstaller class >> updateDeclaredSprite [

	DeclaredSprites := Smalltalk allClasses select: [:e | (Pragma allNamed: #phratchObject in:  e class) notEmpty ]
]

{ #category : #'class initialization' }
PhratchInstaller class >> version [
	^ '5.0'
]
