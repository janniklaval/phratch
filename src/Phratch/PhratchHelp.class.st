"
this class contains methods about the documentation of phratch. It contains only methods at the class side. It is used in the help menu of phratch.
"
Class {
	#name : #PhratchHelp,
	#superclass : #Object,
	#category : #'Phratch-Installation'
}

{ #category : #'menu/button actions' }
PhratchHelp class >> aboutPhratch [
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
			'Phratch ', PhratchInstaller version, '
Copyright (c) 2014 Jannik Laval.
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
				color: (PhratchCategory blockColorFor: 'control');
				commandSpec: 'B Y $OSReporter$ B';
		yourself) asLambda displayForm.
	dialogBox getUserResponse
]

{ #category : #externalCall }
PhratchHelp class >> htmlDoc [
	<phratchMenu: 'Generate HTML documentation' category: 'file' position: 12 sub: 5 shift: true>
	| allPragmas dir imgDir html |
	(FileSystem workingDirectory / 'htmlDoc') exists
		ifTrue: [ (FileSystem workingDirectory / 'htmlDoc') deleteAll ].
	dir := (FileSystem workingDirectory / 'htmlDoc') ensureCreateDirectory.
	imgDir := (dir / 'doc-img') ensureCreateDirectory.
	allPragmas := (Pragma
		allNamed: #phratchItem:kind:category:defaultValues:subCategory:special:
		in: ScriptablePhratchMorph) asOrderedCollection.
	ScriptablePhratchMorph allSubclasses
		do: [ :aSC | allPragmas addAll: (Pragma allNamed: #phratchItem:kind:category:defaultValues:subCategory:special: in: aSC) ].
	html := FileStream forceNewFileNamed: (dir / 'index.html') fullName.
	html nextPutAll: '<h2>Categories</h2><ul style="list-style-type: none;">'.
	PhratchCategory
		allSubclassesDo: [ :c | 
			(c label = 'none' or: [ c label = 'other' or: [ c label = 'custom' ] ])
				ifFalse: [ 
					| label offForm b |
					label := (PhratchTranslator translationFor: c label) capitalized.
					offForm := c label = 'list'
						ifTrue: [ PhratchFrameMorph skinAt: 'variables' ]
						ifFalse: [ PhratchFrameMorph skinAt: c label ].
					b := ResizableToggleButton new offForm: offForm onForm: offForm overForm: offForm.
					b
						label: label font: (PhratchFrameMorph getFont: #Category);
						setLabelColor: Color white;
						target: self;
						actionSelector: #currentCategory:;
						arguments: (Array with: c label);
						toggleButtonMode: true;
						toggleMode: false.
					b leftJustifyInset: 10.
					PNGReadWriter putForm: b imageForm onFileNamed: (imgDir / (c label , '.png')) fullName.
					html
						nextPutAll: '<li  style="display: inline; padding-right: 10px;"><a href="#';
						nextPutAll: c label;
						nextPutAll: '"><img src="./doc-img/';
						nextPutAll: c label;
						nextPutAll: '.png"/></a></li>' ] ].
	html nextPutAll: '</ul>'.
	PhratchCategory
		allSubclassesDo: [ :c | 
			(c label = 'none' or: [ c label = 'other' or: [ c label = 'custom' ] ])
				ifFalse: [ 
					html
						nextPutAll: '<h2 id="';
						nextPutAll: c label;
						nextPutAll: '">';
						nextPutAll: c label;
						nextPutAll: '</h2><table border="0">'.
					allPragmas
						select: [ :pragma | (pragma arguments at: 3) = c label ]
						thenDo: [ :aP | 
							| prov pngName comment |
							prov := {(aP arguments at: 1).
							(aP arguments at: 2).
							(aP method selector).
							(aP arguments at: 6)} , (aP arguments at: 4).
							pngName := (prov at: 1) asLegalSelector asString , (prov at: 3) asLegalSelector asString.
							[ (imgDir / (pngName , '.png')) exists ] whileTrue: [ pngName := pngName , '0' ].
							comment := aP method comment.
							comment ifNil: [ comment := '' ] ifNotNil: [ comment := comment copyFrom: 2 to: comment size - 1 ].
							PNGReadWriter
								putForm:
									(aP methodClass new blockFromSpec: prov color: (PhratchCategory blockColorFor: (aP arguments at: 3))) imageForm
								onFileNamed: (imgDir / (pngName , '.png')) fullName.
							html
								nextPutAll: '<tr><td WIDTH=300><img src="./doc-img/';
								nextPutAll: pngName;
								nextPutAll: '.png"/></td><td>';
								nextPutAll: comment;
								nextPutAll: '</td></tr>' ].
					html nextPutAll: '</table>' ] ]
]

{ #category : #externalCall }
PhratchHelp class >> htmlDocForWebsite [
	| allPragmas dir imgDir html |
	dir := (FileSystem workingDirectory / 'htmlDoc') ensureCreateDirectory.
	imgDir := (dir / 'doc-img') ensureCreateDirectory.
	allPragmas := (Pragma
		allNamed: #phratchItem:kind:category:defaultValues:subCategory:special:
		in: ScriptablePhratchMorph) asOrderedCollection.
	ScriptablePhratchMorph allSubclasses
		do: [ :aSC | allPragmas addAll: (Pragma allNamed: #phratchItem:kind:category:defaultValues:subCategory:special: in: aSC) ].
	html := FileStream forceNewFileNamed: (dir / 'index.html') fullName.
	html nextPutAll: '<h2>Categories</h2><ul style="list-style-type: none;">'.
	PhratchCategory
		allSubclassesDo: [ :c | 
			(c label = 'none' or: [ c label = 'other' or: [ c label = 'custom' ] ])
				ifFalse: [ 
					| label offForm b |
					label := (PhratchTranslator translationFor: c label) capitalized.
					offForm := c label = 'list'
						ifTrue: [ PhratchFrameMorph skinAt: 'variables' ]
						ifFalse: [ PhratchFrameMorph skinAt: c label ].
					b := ResizableToggleButton new offForm: offForm onForm: offForm overForm: offForm.
					b
						label: label font: (PhratchFrameMorph getFont: #Category);
						setLabelColor: Color white;
						target: self;
						actionSelector: #currentCategory:;
						arguments: (Array with: c label);
						toggleButtonMode: true;
						toggleMode: false.
					b leftJustifyInset: 10.
					PNGReadWriter putForm: b imageForm onFileNamed: (imgDir / (c label , '.png')) fullName.
					html
						nextPutAll: '<li  style="display: inline; padding-right: 10px;"><a href="#';
						nextPutAll: c label;
						nextPutAll: '"><img src="http://www.phratch.com/wp-content/uploads/doc-img/';
						nextPutAll: c label;
						nextPutAll: '.png"/></a></li>' ] ].
	html nextPutAll: '</ul>'.
	PhratchCategory
		allSubclassesDo: [ :c | 
			(c label = 'none' or: [ c label = 'other' or: [ c label = 'custom' ] ])
				ifFalse: [ 
					html
						nextPutAll: '<h2 id="';
						nextPutAll: c label;
						nextPutAll: '">';
						nextPutAll: c label;
						nextPutAll: '</h2><table border="0">'.
					allPragmas
						select: [ :pragma | (pragma arguments at: 3) = c label ]
						thenDo: [ :aP | 
							| prov pngName comment |
							prov := {(aP arguments at: 1).
							(aP arguments at: 2).
							(aP method selector).
							(aP arguments at: 6)} , (aP arguments at: 4).
							pngName := (prov at: 1) asLegalSelector asString , (prov at: 3) asLegalSelector asString.
							[ (imgDir / (pngName , '.png')) exists ] whileTrue: [ pngName := pngName , '0' ].
							comment := aP method comment.
							comment ifNil: [ comment := '' ] ifNotNil: [ comment := comment copyFrom: 2 to: comment size - 1 ].
							PNGReadWriter
								putForm:
									(aP methodClass new blockFromSpec: prov color: (PhratchCategory blockColorFor: (aP arguments at: 3))) imageForm
								onFileNamed: (imgDir / (pngName , '.png')) fullName.
							html
								nextPutAll: '<tr><td WIDTH=300><img src="http://www.phratch.com/wp-content/uploads/doc-img/';
								nextPutAll: pngName;
								nextPutAll: '.png"/></td><td>';
								nextPutAll: comment;
								nextPutAll: '</td></tr>' ].
					html nextPutAll: '</table>' ] ]
]

{ #category : #externalCall }
PhratchHelp class >> launchAllHelpScreens [

	self launchHelpFile: 'allscreens.html'

]

{ #category : #externalCall }
PhratchHelp class >> launchBlockDoc [

	[self htmlDoc] on: Error do: [ PhratchError error: 'files already exist'].
	self launchDocFile: 'index.html'.

]

{ #category : #externalCall }
PhratchHelp class >> launchDocFile: aFilename [

	| helpDir  |
	
	helpDir := FileSystem workingDirectory / 'htmlDoc'.
	0.5 second wait.
	(helpDir / aFilename) exists
		ifTrue: [ 
			self open: (((helpDir / aFilename) fullName))]
		ifFalse: [
			DialogBoxMorph inform: 'Doc file not found.' localized].

]

{ #category : #externalCall }
PhratchHelp class >> launchHelpFile: aFilename [

	| helpDir subDir |
	
	helpDir := FileSystem workingDirectory / 'Help'.
	helpDir exists ifFalse: [^ PhratchError error: 'beep'.].  "no help folder"
	

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

{ #category : #externalCall }
PhratchHelp class >> launchHelpPage [

	self launchHelpFile: 'index.html'.

]

{ #category : #externalCall }
PhratchHelp class >> launchWebsite [

	"self world displayWorldSafely."
	Cursor wait showWhile: ["PhratchPlugin primOpenURL:"self open:  'http://www.phratch.com/'].

]

{ #category : #generating }
PhratchHelp class >> open: aFileName [ 
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

{ #category : #externalCall }
PhratchHelp class >> openBYOBManual [

	self open: (((FileSystem workingDirectory / 'Manual' / 'BYOBManual.pdf') fullName))
]

{ #category : #externalCall }
PhratchHelp class >> openPantherTutorials [

	Cursor wait showWhile: ["PhratchPlugin primOpenURL:" self open: 'http://pantherprogramming.weebly.com/panther-tutorials.html'].

]
