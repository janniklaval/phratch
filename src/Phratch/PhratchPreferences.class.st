Class {
	#name : #PhratchPreferences,
	#superclass : #Object,
	#classVars : [
		'FileIOPreference',
		'InsertionPointColor',
		'MeshServerEnabled',
		'NoviceMode',
		'StandardButtonFont',
		'StandardMenuFont',
		'TakeOverScreen',
		'TextHighlightColor',
		'UseLargeFonts',
		'WarnIfNoChangesFile',
		'WarnIfNoSourcesFile'
	],
	#category : #'Phratch-Installation'
}

{ #category : #accessing }
PhratchPreferences class >> fileIOPreference [

	^ FileIOPreference
]

{ #category : #accessing }
PhratchPreferences class >> fileIOPreference: aBoolean [ 

	FileIOPreference := aBoolean
]

{ #category : #accessing }
PhratchPreferences class >> insertionPointColor [
	^ InsertionPointColor ifNil: [ InsertionPointColor := Color r: 0.353 g: 0.607 b: 0.788 ]
]

{ #category : #accessing }
PhratchPreferences class >> insertionPointColor: anObject [
	InsertionPointColor := anObject
]

{ #category : #accessing }
PhratchPreferences class >> meshServerEnabled [
	^ MeshServerEnabled  ifNil: [ MeshServerEnabled := true ]
]

{ #category : #accessing }
PhratchPreferences class >> meshServerEnabled: anObject [
	MeshServerEnabled := anObject
]

{ #category : #accessing }
PhratchPreferences class >> noviceMode [
	^ NoviceMode  ifNil: [ NoviceMode := false ]
]

{ #category : #accessing }
PhratchPreferences class >> noviceMode: anObject [
	NoviceMode := anObject
]

{ #category : #'as yet unclassified' }
PhratchPreferences class >> phratchSettingsOn: aBuilder [  
	<systemsettings>  
	(aBuilder group: #phratch)
		label: 'Phratch' translated;
		description: 'All Phratch settings' translated;
		with: [ 
			(aBuilder setting: #insertionPointColor) 
				label: 'insertionPointColor' translated;
		 		target: PhratchPreferences;
		 		description: '...' translated.	
			(aBuilder setting: #noviceMode) 
				label: 'noviceMode' translated;
		 		target: PhratchPreferences;
		 		description: '...' translated.	
			(aBuilder setting: #standardButtonFont) 
				label: 'standardButtonFont' translated;
		 		target: PhratchPreferences;
		 		description: '...' translated.	
			(aBuilder setting: #standardMenuFont) 
				label: 'standardMenuFont' translated;
		 		target: PhratchPreferences;
		 		description: '...' translated.	
			(aBuilder setting: #textHighlightColor) 
				label: 'textHighlightColor' translated;
		 		target: PhratchPreferences;
		 		description: '...' translated.	
			(aBuilder setting: #useLargeFonts) 
				label: 'useLargeFonts' translated;
		 		target: PhratchPreferences;
		 		description: '...' translated.	
			(aBuilder setting: #warnIfNoChangesFile) 
				label: 'warnIfNoChangesFile' translated;
		 		target: PhratchPreferences;
		 		description: '...' translated.	
			(aBuilder setting: #warnIfNoSourcesFile) 
				label: 'warnIfNoSourcesFile' translated;
		 		target: PhratchPreferences;
		 		description: '...' translated.	
			(aBuilder setting: #meshServerEnabled) 
				label: 'meshServerEnabled' translated;
		 		target: PhratchPreferences;
		 		description: 'A mesh server allows to share projects' translated.	
			(aBuilder setting: #takeOverScreen) 
				label: 'takeOverScreen' translated;
		 		target: PhratchPreferences;
		 		description: 'Do you allow Phratch to display on all screen' translated.	
			(aBuilder setting: #fileIOPreference) 
				label: 'fileIOPreference' translated;
		 		target: PhratchPreferences;
		 		description: 'Do you allow Phratch to write files' translated.	
		].
]

{ #category : #accessing }
PhratchPreferences class >> standardButtonFont [
	^ StandardButtonFont   ifNil: [ StandardButtonFont := StandardFonts defaultFont ] 
]

{ #category : #accessing }
PhratchPreferences class >> standardButtonFont: anObject [
	StandardButtonFont := anObject
]

{ #category : #accessing }
PhratchPreferences class >> standardMenuFont [
	^ StandardMenuFont ifNil: [ StandardMenuFont := StandardFonts defaultFont ] 
]

{ #category : #accessing }
PhratchPreferences class >> standardMenuFont: anObject [
	StandardMenuFont := anObject
]

{ #category : #accessing }
PhratchPreferences class >> takeOverScreen [
	^ TakeOverScreen ifNil: [ TakeOverScreen := false ] 
]

{ #category : #accessing }
PhratchPreferences class >> takeOverScreen: anObject [
	TakeOverScreen := anObject
]

{ #category : #accessing }
PhratchPreferences class >> textHighlightColor [
	^ TextHighlightColor ifNil: [ TextHighlightColor := Color r: 0.353 g: 0.607 b: 0.788 ]
]

{ #category : #accessing }
PhratchPreferences class >> textHighlightColor: anObject [
	TextHighlightColor := anObject
]

{ #category : #accessing }
PhratchPreferences class >> useLargeFonts [
	^ UseLargeFonts ifNil: [ UseLargeFonts := false ]
]

{ #category : #accessing }
PhratchPreferences class >> useLargeFonts: anObject [
	UseLargeFonts := anObject
]

{ #category : #accessing }
PhratchPreferences class >> warnIfNoChangesFile [
	^ WarnIfNoChangesFile ifNil: [ WarnIfNoChangesFile := false ]
]

{ #category : #accessing }
PhratchPreferences class >> warnIfNoChangesFile: anObject [
	WarnIfNoChangesFile := anObject
]

{ #category : #accessing }
PhratchPreferences class >> warnIfNoSourcesFile [
	^ WarnIfNoSourcesFile ifNil: [ WarnIfNoSourcesFile := false ]
]

{ #category : #accessing }
PhratchPreferences class >> warnIfNoSourcesFile: anObject [
	WarnIfNoSourcesFile := anObject
]
