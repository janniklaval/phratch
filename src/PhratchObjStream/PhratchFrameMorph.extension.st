Extension { #name : #PhratchFrameMorph }

{ #category : #'*PhratchObjStream' }
PhratchFrameMorph >> extractOldProjectFrom: aByteArray [
	"Answer a Phratch project (i.e. a PhratchStageMorph possibly containing sprites) from the given ByteArray. Answer nil if the project cannot be unpacked."

	| s version proj |

	ObjStream initialize. "just to make sure this works in filed-in changesets, -Jens"
	s := ReadStream on: aByteArray.
	version := ObjStream phratchFileVersionFrom: (s next: 10) asString.
	version = 0 ifTrue: [
		ScriptablePhratchMorph decodeAsByob.	"make sure we initialize every field - this breaks compatibility with Phratch-sprites. -Jens"
		s position: 0.
		[proj := ObjStream new oldReadObjFrom: s showProgress: true] ifError: [
		^ self extractPhratchProjectFrom: aByteArray]].
	({1 . 2} includes: version) ifTrue: [
		s skip: s uint32.  "skip header"
		proj := ObjStream new readObjFrom: s showProgress: true].

	proj class = PhratchStageMorph ifFalse: [
		version > 2
			ifTrue: [self error: 'Project created by a later version of Phratch']
			ifFalse: [self error: 'Problem reading project.'].
		^ nil].

	ScriptablePhratchMorph buildBlockSpecDictionary.

	'initializing...' 
		displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((proj allMorphs) select: [:m| m isKindOf: ScriptablePhratchMorph]) size * 2
		during: [:bar | | i | i := 0.

	proj allMorphsDo: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [
			 i := i + 1. bar value: i.
			m convertTuplesToDefinitions]].

	proj allMorphsDo: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [  "convert to new blocks" 
			i := i + 1. bar value: i.
			m convertStacksToTuples.
			m convertTuplesToStacks]]].

	^ proj

]

{ #category : #'*PhratchObjStream' }
PhratchFrameMorph >> extractScratchInfoFrom: aByteArray [
	"Answer a Phratch info dictionary from the given ByteArray. Answer an empty dictionary if it is an old project."

	| s version |
	s := ReadStream on: aByteArray.
	version := ObjStream phratchFileVersionFrom: (s next: 10) asString.
	({1 . 2} includes: version)
		ifTrue: [
			s skip: 4.  "skip info header byte count"
			^ ObjStream new oldReadObjFrom: s showProgress: false]
		ifFalse: [^ Dictionary new].


]

{ #category : #'*PhratchObjStream' }
PhratchFrameMorph >> extractScratchProjectFrom: aByteArray [
	"Answer a Phratch project (i.e. a PhratchStageMorph possibly containing sprites) from the given ByteArray. Answer nil if the project cannot be unpacked."

	| s version proj |

	FuelObjStream initialize. "just to make sure this works in filed-in changesets, -Jens"
	s := ReadStream on: aByteArray.
	version := FuelObjStream phratchFileVersionFrom: (s next: 10) asString.
	version = 0 ifTrue: [
		ScriptablePhratchMorph decodeAsByob.	"make sure we initialize every field - this breaks compatibility with Phratch-sprites. -Jens"
		s position: 0.
		[proj := ObjStream new oldReadObjFrom: s showProgress: true] ifError: [
		^ self extractPhratchProjectFrom: aByteArray]].
	({1 . 2} includes: version) ifTrue: [
		s skip: s uint32.  "skip header"
		proj := ObjStream new oldReadObjFrom: s showProgress: true].

	proj class = PhratchStageMorph ifFalse: [
		version > 2
			ifTrue: [self error: 'Project created by a later version of Phratch']
			ifFalse: [self error: 'Problem reading project.'].
		^ nil].

	ScriptablePhratchMorph buildBlockSpecDictionary.

	'initializing...' 
		displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((proj allMorphs) select: [:m| m isKindOf: ScriptablePhratchMorph]) size * 2
		during: [:bar | | i | i := 0.

	proj allMorphsDo: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [
			 i := i + 1. bar value: i.
			m convertTuplesToDefinitions]].

	proj allMorphsDo: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [  "convert to new blocks" 
			i := i + 1. bar value: i.
			m convertStacksToTuples.
			m convertTuplesToStacks]]].

	^ proj

]

{ #category : #'*PhratchObjStream' }
PhratchFrameMorph >> openScratchProject [
	"Allow the user to select a project to open, then open that project."

	| response newProj |
	self closeMediaEditorsAndDialogs
		ifFalse: [ ^ self ].
	self stopAll.
	(justSaved or: [ self projectIsEmpty ])
		ifFalse: [ 
			"ask the user if they want to save the current project"
			response := DialogBoxMorph askWithCancel: 'Save the current project?'.
			response = #cancelled
				ifTrue: [ ^ self ].
			response
				ifTrue: [ self savePhratchProjectNoDialog ] ].
	response := PhratchFileChooserDialog openPhratchFileFor: self.
	response = #cancelled
		ifTrue: [ ^ self ].
	(response isKindOf: FileReference)
		ifTrue: [ 
			"read the contents of a local file"
			^ self openScratchProjectNamed: response ].
	(response isKindOf: ByteArray)
		ifFalse: [ ^ self ].
	[ projectInfo := self extractInfoFrom: response ] ifError: [ projectInfo := Dictionary new ].
	[ newProj := self extractOldProjectFrom: response ] ifError: [ ^ self ].
	self installNewProject: newProj.
	projectDirectory := PhratchFileChooserDialog getDefaultFolderForType: #project
]

{ #category : #'*PhratchObjStream' }
PhratchFrameMorph >> openScratchProjectNamed: fName [
	"Open a Phratch project with the given name."

	| f projData newProj dir fn|
	self closeMediaEditorsAndDialogs ifFalse: [^ self].
	fn := fName.
	f := FileStream readOnlyFileNamedOrNil: fn.
 	f ifNil: ["try a different encoding, fixes a Firefox bug, -Jens"
		fn := fName fullName.
		f := FileStream readOnlyFileNamedOrNil: fn.
		f ifNil: [^ self inform: 'Could not read' withDetails: fName]].

	"["
		projData := f binary contentsOfEntireFile.
		newProj := self extractScratchProjectFrom: projData.
		projectInfo := self extractScratchInfoFrom: projData.
	"] ifError: [:err :rcvr | ^ self inform: 'Could not read project; file may be damaged' withDetails: '(', err, ')']."

	dir := (fn) parent.
	projectDirectory := dir.
	PhratchFileChooserDialog setLastFolderTo: projectDirectory forType: #project.
	projectName := ( fn) basename.

	self installNewProject: newProj.
	self initializeWatcherPositions.
	viewerPane updateContents.

]
