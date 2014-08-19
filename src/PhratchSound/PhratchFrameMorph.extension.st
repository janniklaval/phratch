Extension { #name : #PhratchFrameMorph }

{ #category : #'*PhratchSound' }
PhratchFrameMorph >> closeMediaEditorsAndDialogs [
	"Close any open paint or sound editors, asking the user first to avoid losing edits. Answer true if all are closed."

	| mList mHasCancel |
	mList := PaintFrame allInstances select: [:m | m isInWorld].
	mList size > 0 ifTrue: [
		(DialogBoxMorph ask: 'Close paint editor?') ifFalse: [^ false].
		mList do: [:m | m cancelled; delete].
		paintingInProgress := false].

	mList := PhratchSoundRecorderDialogMorph allInstances select: [:m | m isInWorld].
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

{ #category : #'*PhratchSound' }
PhratchFrameMorph >> compressSounds [
	<phratchMenu: 'Compress Sounds' category: 'edit' position: 3 sub:2 shift: false>
	| menu bitsPerSample count |
	menu := MenuMorph new
		title: 'Sound quality:' translated;
		defaultTarget: self;
		yourself.	"menu add: 'High (biggest)'
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
	count := menu localize; invokeModal."
	menu := MenuMorph new
		title: 'Sound quality:' translated;
		defaultTarget: self;
		yourself.
	menu add: 'High (biggest)' value: 5.
	menu add: 'Normal' value: 4.
	menu add: 'Low' value: 3.
	menu add: 'Lowest (smallest)' value: 2.
	menu addLine.
	menu add: 'cancel' value: nil.
	menu localize.
	(bitsPerSample := menu
		invokeModal;
		selectedValue;
		yourself) ifNil: [ ^ self ].
	count := self canonicalizeSoundsBits: bitsPerSample saveOriginal: false.
	scriptsPane categoryChanged: 'Sounds'.
	DialogBoxMorph inform: 'Sounds compressed' withDetails: count printString
]

{ #category : #'*PhratchSound' }
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

{ #category : #'*PhratchSound' }
PhratchFrameMorph >> newSound [
	"Open the dialog to record a new sound."

	scriptsPane tabPane currentTab: 'Sounds'.
	viewerPane target recordSound.
]

{ #category : #'*PhratchSound' }
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
"
			importedProject customBlocks ifNotNil: [
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
				addMediaItem: (SoundMedia new
					mediaName: 'pop' localized;
					sound: PhratchSpriteMorph popSound;
		yourself);
		yourself.
			^ self]].

]

{ #category : #'*PhratchSound' }
PhratchFrameMorph >> updateMediaCategoryFor: anObject [
	"Update the media viewer for the given object's media category. Do nothing if the media category of the given object is not being viewed."

	scriptsPane target = anObject ifTrue: [
		scriptsPane categoryChanged: 'Sounds'.
		scriptsPane categoryChanged: 'Costumes'].
	viewerPane target = anObject ifTrue: [
		viewerPane categoryChanged: 'Sound'].

]
