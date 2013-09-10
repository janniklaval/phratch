"
I am the superclass of all scriptable Scratch morphs.

Scriptable morphs:
  1. allow the user to add user-defined scripts
  2. allow the user to add user-defined variables
  3. when they are copied, their scripts and variables are copied;
     thereafter, script changes to the original and the copy are entirely independent
  4. can be exported and imported into another Scratch project.

"
Class {
	#name : #ScriptablePhratchMorph,
	#superclass : #Morph,
	#instVars : [
		'objName',
		'vars',
		'lists',
		'blocksBin',
		'isClone',
		'media',
		'costume',
		'costumeChangeMSecs',
		'filterPack',
		'visibility',
		'volume',
		'tempoBPM',
		'sceneStates',
		'customBlocks',
		'deletedAttributes',
		'colors'
	],
	#classVars : [
		'BlockColorDict',
		'BlockSpecDict',
		'CameraOpenings',
		'DefaultBackgroundForm',
		'DoubleSize',
		'Experimental',
		'FileIOPreference',
		'KeepOnStage',
		'ListBlockColor',
		'MeowSound',
		'NoviceMode',
		'ObjEncoding',
		'PhratchOrigin',
		'PopSound',
		'RandomGen',
		'Recorder',
		'TimerStartMSecs'
	],
	#category : #'Phratch-Objects'
}

{ #category : #run }
ScriptablePhratchMorph class >> DoIt [
	| menu |
	menu := MenuMorphNG new defaultTarget: self.
	#(#('Acoustic Bass Drum' 35 ) #('Bass Drum 1' 36 ) #('Side Stick' 37 ) #('Acoustic Snare' 38 ) #('Hand Clap' 39 ) #('Electric Snare' 40 ) #('Low Floor Tom' 41 ) #('Closed Hi-Hat' 42 ) #('High Floor Tom' 43 ) #('Pedal Hi-Hat' 44 ) #('Low Tom' 45 ) #('Open Hi-Hat' 46 ) #('Low-Mid Tom' 47 ) #('Hi-Mid Tom' 48 ) #('Crash Cymbal 1' 49 ) #('High Tom' 50 ) #('Ride Cymbal 1' 51 ) #('Chinese Cymbal' 52 ) #('Ride Bell' 53 ) #('Tambourine' 54 ) #('Splash Cymbal' 55 ) #('Cowbell' 56 ) #('Crash Cymbal 2' 57 ) #('Vibraslap' 58 ) #('Ride Cymbal 2' 59 ) #('Hi Bongo' 60 ) #('Low Bongo' 61 ) #('Mute Hi Conga' 62 ) #('Open Hi Conga' 63 ) #('Low Conga' 64 ) #('High Timbale' 65 ) #('Low Timbale' 66 ) #('High Agogo' 67 ) #('Low Agogo' 68 ) #('Cabasa' 69 ) #('Maracas' 70 ) #('Short Whistle' 71 ) #('Long Whistle' 72 ) #('Short Guiro' 73 ) #('Long Guiro' 74 ) #('Claves' 75 ) #('Hi Wood Block' 76 ) #('Low Wood Block' 77 ) #('Mute Cuica' 78 ) #('Open Cuica' 79 ) #('Mute Triangle' 80 ) #('Open Triangle' 81 ) )
		do: [:pair | menu add: (self numberInParens: pair second)
					, pair first localizedMIDI value: pair second].
	^ (menu popUpInWorld ; selectedValue;
		yourself)
]

{ #category : #'block specs' }
ScriptablePhratchMorph class >> blockColorDict [

	^ BlockColorDict

]

{ #category : #'block specs' }
ScriptablePhratchMorph class >> blockColorFor: aCategory [
	"Answer the block color for the given category."

	^(PhratchCategory allSubclasses detect:[:e | e label = aCategory] ifNone: [PhratchCategory]) color.

]

{ #category : #'block specs' }
ScriptablePhratchMorph class >> blockSpecDict [
	"Answer my block specification dictionary."

	BlockSpecDict ifNil: [self buildBlockSpecDictionary].
	^ BlockSpecDict


]

{ #category : #'block specs' }
ScriptablePhratchMorph class >> blockSpecs [
	"To obtain all the items of the menu, execute:
	SystemNavigation default allCallsOn: #phratchItem:kind:category:defaultValues:subCategory: 
	"

	"Answer a collection of block specifications for the blocks that are common to all objects. Block specificatons (Arrays) are interspersed with category names (Strings). A block specification is an Array of the form: (<block spec string> <block type> <selector> [optional initial argument values]).

	Explanation of flags:
		-	no flags
		b	boolean reporter
		c	c-shaped block containing a sequence of commands (always special form)
		r	reporter
		g	color reporter
		R	special form reporter with its own evaluation rule
		s	special form command with its own evaluation rule
		t	timed command, like wait or glide
		E	message event hat
		K	key event hat
		M	mouse-click event hat
		S	start event hat
		W	when <condition> hat (obsolete)"

	| blocks allPragmas |
	blocks := #().
	
	
	"Add the block with the new method of declaration:"
	allPragmas := Pragma allNamed: #phratchItem:kind:category:defaultValues:subCategory: from: self to:  ScriptablePhratchMorph  sortedByArgument: 5.

	PhratchCategory allSubclassesDo: [ :c |
		|previousSC|
		previousSC := nil.
		blocks := blocks, {c label}.
		allPragmas select:[:pragma | (pragma arguments at: 3) = c label] 
			thenDo:[:aP |
				|prov|
				(previousSC notNil and: [previousSC ~~( aP arguments at: 5)]) ifTrue:[blocks := blocks, #(-) ].
				prov := { aP arguments at: 1 . aP arguments at: 2 . aP method selector},  (aP arguments at: 4).
				blocks := blocks, {prov}.
				previousSC := aP arguments at: 5.
			].
	].

	^ blocks
	
"'control'"
			"-"
			"('debug'							s	doPauseThread)
			('debug $String$'						R	doPauseThreadReporter)"
"'files'
			('host mesh'										-	hostMesh)
			('hosting mesh?'									b	isHostingMesh)
			-
			('join mesh $String$'							-	joinMesh:)
			('leave mesh'									-	leaveMesh)
			-
			('mesh IP address'								r	getMeshIPAddress)"
]

{ #category : #'block specs' }
ScriptablePhratchMorph class >> buildBlockSpecDictionary [
	"self buildBlockSpecDictionary"

	| blockColor sel |
	BlockSpecDict := IdentityDictionary new: 250.
	BlockColorDict := IdentityDictionary new: 250.

	self withAllSubclassesDo: [:cl |
		blockColor := Color blue.
		cl blockSpecs do: [:spec |
			((spec isKindOf: String) and: [spec size > 1]) ifTrue: [
				"set color  for this category"
				blockColor := self blockColorFor: spec].
			(spec isMemberOf: Array) ifTrue: [
				sel := spec at: 3.
				BlockSpecDict at: sel put: spec.
				BlockColorDict at: sel put: blockColor]]].

	BlockSpecDict at: #/ put: (BlockSpecDict at: #/\/).
	BlockColorDict at: #/ put: (BlockColorDict at: #/\/).
]

{ #category : #'panther-actions' }
ScriptablePhratchMorph class >> cameraOpened [

	CameraOpenings := ((CameraOpenings ifNil: [0]) max: 0) + 1.
]

{ #category : #'panther-actions' }
ScriptablePhratchMorph class >> closeCamera [
	CameraOpenings := (CameraOpenings - 1) max: 0.
	CameraOpenings = 0 ifTrue: [CameraPlugin closeCamera: 1].
]

{ #category : #'byob legacy support' }
ScriptablePhratchMorph class >> currentEncoding [
		^ObjEncoding ifNil: [^#byob ]
]

{ #category : #'byob legacy support' }
ScriptablePhratchMorph class >> decodeAsByob [
		ObjEncoding := #byob 
]

{ #category : #'byob legacy support' }
ScriptablePhratchMorph class >> decodeAsScratch [
		ObjEncoding := #scratch 
]

{ #category : #'forms/sounds/icons' }
ScriptablePhratchMorph class >> defaultBackgroundForm [

	(DefaultBackgroundForm isNil or:
	 [DefaultBackgroundForm extent ~= PhratchFrameMorph workpaneExtent]) ifTrue: [
		DefaultBackgroundForm := (Form extent: PhratchFrameMorph workpaneExtent depth: 1).
		DefaultBackgroundForm fillWhite].

	^ DefaultBackgroundForm

]

{ #category : #byob }
ScriptablePhratchMorph class >> doMakeNewList [
	^nil
]

{ #category : #other }
ScriptablePhratchMorph class >> doubleSize: aBoolean [

	DoubleSize := aBoolean.

]

{ #category : #accessing }
ScriptablePhratchMorph class >> fileIOPreference [
	^ FileIOPreference  ifNil: [ FileIOPreference := true ]
]

{ #category : #accessing }
ScriptablePhratchMorph class >> fileIOPreference: anObject [
	FileIOPreference := anObject
]

{ #category : #other }
ScriptablePhratchMorph class >> fromUser [
	"Go into a mode asking the user to select an instance of me, displaying a crossHair cursor while in this mode. The mode ends with the next mouse click. If the click is over an instance of me, return it. Otherwise, return nil. Keep running the world while waiting for the mouse click."

	| result p m mList |
	World ifNil: [^ self].  "not in morphic"
	result := nil.
	Cursor crossHair showWhile: [
		[Sensor anyButtonPressed] whileFalse: [World doOneCycleNoInput].
		p := Sensor cursorPoint.
		m := (World rootMorphsAt: p) first.
		(m isKindOf: PhratchFrameMorph) ifTrue: [
			mList := m workPane rootMorphsAt: p.
			mList size > 0 ifTrue: [
				m := (m workPane rootMorphsAt: p) first]].
		(m isKindOf: self) ifTrue: [result := m].
		Sensor waitNoButton].
	^ result

]

{ #category : #'class initialization' }
ScriptablePhratchMorph class >> initialize [
	"self initialize"

	Experimental := false.
	PhratchOrigin := 0@0.
	RandomGen := Random new.
	TimerStartMSecs := Time millisecondClockValue.
	ListBlockColor := Color h: 18 s: 0.92 v: 0.85.

	DoubleSize := false
]

{ #category : #other }
ScriptablePhratchMorph class >> isSpriteSpecificTarget: anObject selector: selector [
	"I determine whether the given selector is specific to a particular Sprite. ."

	| i |
	(anObject isKindOf: PhratchSpriteMorph) ifFalse: [^ false].
	i := selector asString
		findAnySubStr: #('answer' 'key' 'Loud' 'mouse' 'sensor' 'soundLevel' 'tempo' 'timer')
		startingAt: 1.
	^ i > selector asString size

]

{ #category : #byob }
ScriptablePhratchMorph class >> keepOnStage [

	^KeepOnStage ifNil: [true ]
]

{ #category : #byob }
ScriptablePhratchMorph class >> keepOnStage: aBool [
	KeepOnStage := aBool
]

{ #category : #'block specs' }
ScriptablePhratchMorph class >> listBlockColor [

	^ ListBlockColor

]

{ #category : #'forms/sounds/icons' }
ScriptablePhratchMorph class >> meowSound [

	^ MeowSound ifNil: [MeowSound := SampledSound fromFileNamed: (((FileSystem workingDirectory / 'ScratchSkin') / 'Kitten.wav') fullName)]

]

{ #category : #accessing }
ScriptablePhratchMorph class >> noviceMode [
	^ NoviceMode  ifNil: [ NoviceMode := false ]
]

{ #category : #accessing }
ScriptablePhratchMorph class >> noviceMode: anObject [
	NoviceMode := anObject
]

{ #category : #other }
ScriptablePhratchMorph class >> phratchOrigin: aPoint [
	"Set the origin for the Phratch coordinate system."

	PhratchOrigin := aPoint.

]

{ #category : #'forms/sounds/icons' }
ScriptablePhratchMorph class >> popSound [

	^ PopSound ifNil: [PopSound := SampledSound fromFileNamed: ((FileSystem workingDirectory / 'ScratchSkin'/ 'Pop.wav') fullName)]

]

{ #category : #other }
ScriptablePhratchMorph class >> randomInit [

	RandomGen initialize.

]

{ #category : #other }
ScriptablePhratchMorph class >> resetTimer [

	TimerStartMSecs := Time millisecondClockValue.

]

{ #category : #other }
ScriptablePhratchMorph class >> soundRecorder [
	"Return the shared SoundRecorder. Create and start it, if necessary."

	Recorder ifNil: [
		Recorder := SoundRecorder new.
		Recorder startRecording].
	Recorder isActive ifFalse: [Recorder startRecording].
	^ Recorder

]

{ #category : #other }
ScriptablePhratchMorph class >> stopSoundRecorder [
	"Stop the shared sound recorder."
	"self stopSoundRecorder"

	Recorder ifNotNil: [Recorder stopRecording; clearRecordedSound].


]

{ #category : #byob }
ScriptablePhratchMorph >> & aBoolean [
	<phratchItem: '$Boolean$ and $Boolean$' kind: #b category: 'operators' defaultValues: #() subCategory: #a4>

]

{ #category : #byob }
ScriptablePhratchMorph >> * aNumber [
	<phratchItem: '$Number$ * $Number$' kind: #r category: 'operators' defaultValues: #(- -) subCategory: #a1>

]

{ #category : #byob }
ScriptablePhratchMorph >> + aNumber [
	<phratchItem: '$Number$ + $Number$' kind: #r category: 'operators' defaultValues: #(- -) subCategory: #a1>

]

{ #category : #byob }
ScriptablePhratchMorph >> - aNumber [
	<phratchItem: '$Number$ - $Number$' kind: #r category: 'operators' defaultValues: #(- -) subCategory: #a1>

]

{ #category : #byob }
ScriptablePhratchMorph >> /\/ aNumber [
	<phratchItem: '$Number$ / $Number$' kind: #r category: 'operators' defaultValues: #(- -) subCategory: #a1>

]

{ #category : #byob }
ScriptablePhratchMorph >> < aString [
	<phratchItem: '$String$ < $String$' kind: #b category: 'operators' defaultValues: #('' '') subCategory: #a3>

]

{ #category : #byob }
ScriptablePhratchMorph >> = anObject [ 
	<phratchItem: '$String$ = $String$' kind: #b category: 'operators' defaultValues: #('' '') subCategory: #a3>
	^super = anObject
]

{ #category : #byob }
ScriptablePhratchMorph >> > aString [
	<phratchItem: '$String$ > $String$' kind: #b category: 'operators' defaultValues: #('' '') subCategory: #a3>

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> \\ aNumber [
	<phratchItem: '$Number$ mod $Number$' kind: #r category: 'operators' defaultValues: #(- -) subCategory: #a8>

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> addColor [

	| sFrame result colorName colorOwner |
	(sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ self beep].

	result := NewVariableDialog ask: 'Color name?'.
	result = #cancelled ifTrue: [^ self].
	colorName := result first.
	colorOwner := result second ifTrue: [self] ifFalse: [sFrame workPane].
	(colorOwner variableNameInUse: colorName) ifTrue: [
		self beep.
		DialogBoxMorph warn: 'That variable name is already in use'.
		^ self].

	colorOwner addColor: colorName.
	sFrame viewerPane categoryChanged: 'colors'.
	
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> addColor: colorName [
	"Add a new user variable with the given name to this object. Do nothing if the variable already exists or is built in."
	<phratchItem: 'make color $String$' kind: #- category: 'colors' defaultValues: #('a color') subCategory: #a3>
	| sFrame stage isGlobal |
	(sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ Beeper beep].
	isGlobal := false.
	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph)
		ifNotNil: [isGlobal := stage colorNames includes: colorName asString].
	((colors includesKey: colorName asString) or: [isGlobal = true]) ifFalse: [
		colors at: colorName asString put: (Color black)].
	sFrame viewerPane categoryChanged: 'colors'.
]

{ #category : #scripts }
ScriptablePhratchMorph >> addComment: aPhratchCommentMorph [
	"Aligns the newly added script below the lowest script in the pane."

	| y bottom |
	y := 10.
	blocksBin
		submorphsDo: [ :m | 
			bottom := m fullBounds bottom - blocksBin position y.
			y := y max: bottom ].
	aPhratchCommentMorph position: blocksBin position + (20 @ (y + 10)).
	blocksBin addMorph: aPhratchCommentMorph
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> addCostumeTyped: aString [

	| newC frameForm title result fList type |
	aString = 'camera' ifTrue: [
		"newC := ImageMedia new form: (Form extent: (self ownerThatIsA: ScratchStageMorph) extent) fillBlack."
		
		self cameraIsOpen ifTrue: [
			self flag:'this is crappy, but works...'.
			frameForm := Form extent: (CameraPlugin frameExtent: 1) depth: 32.
			CameraPlugin getFrameForCamera: 1 into: frameForm bits.
			(2 seconds) asDelay wait.
			CameraPlugin getFrameForCamera: 1 into: frameForm bits.
			
			
			newC := ImageMedia new form: frameForm]
		ifFalse: [^ self]]."]]]."
	aString = 'stage' ifTrue: [newC := ImageMedia new form: ((self ownerOrYourselfThatIsA: PhratchStageMorph) stageShotForm"Sized: 480@360")].
	aString = 'paint new' ifTrue: [self drawNewCostume.
		^ self updateAfterPopUp
	].
	aString = 'import' ifTrue: [
		(self isKindOf: PhratchStageMorph)
			ifTrue: [type := #background. title := 'Import Background']
			ifFalse: [type := #costume. title := 'Import Costume'].
		result := PhratchFileChooserDialog
			chooseImageFileType: type
			title: title.
		result = #cancelled ifTrue: [^ self updateAfterPopUp].

		fList := OrderedCollection new.
		[fList addLast: (Form fromFileNamed: result)] ifError: [^ self updateAfterPopUp].

		newC := ImageMedia new form: fList first.
		self updateAfterPopUp].
	newC mediaName: (self unusedMediaNameFromBaseName: (self defaultImageMedia mediaName)).
	media addLast: newC.
	self lookLike: newC mediaName.
	self updateMediaCategory.
]

{ #category : #byob }
ScriptablePhratchMorph >> addCustomBlock [
	|ans def sf|
	(sf := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^self].
	BlockDialog isOpen ifTrue: [^ self].
	ans := BlockDialog ask: 'Make a block' localized.
	(ans = #cancelled) ifTrue: [^self ].

	def := (CustomBlockDefinition new 
		userSpec: (ans at: 1);
		category: (ans fourth = #other ifTrue: [#none] ifFalse: [ans fourth]);
		yourself).
	(ans at: 2)	
		ifTrue: [ (ans at: 3) 
			ifTrue: [def type: #boolean]
			ifFalse: [def type: #any]]
		ifFalse: [def type: #none; isAtomic: false].
	def isGlobal: (ans at: 5) not.

	(self existsBlockId: (CustomBlockDefinition idFromSpec: (ans at: 1)) global: (ans at: 5))
			ifTrue: [^DialogBoxMorph warn: 'a custom block with this label already exists' localized].

	self ensureCustomBlockExists: def global: def isGlobal.

	sf projectModified. 
	sf viewerPane categoryChanged: 'variables'.
	#none = def category ifFalse: [
		sf viewerPane categoryChanged: def category asString ].
	self editScriptId: (CustomBlockDefinition idFromSpec: (ans at: 1)).
]

{ #category : #byob }
ScriptablePhratchMorph >> addCustomBlocksTo: page y: startY [
	| addButton x y b cdefs inherited all |
	addButton := PhratchFrameMorph buttonLabel: 'Make a block' localized selector: #addCustomBlock.
	x := 13.
	y := startY + 10.
	page
		addMorph:
			(addButton
				target: self;
				position: x @ y;
		yourself).
	y := addButton bottom + 5.	"add custom blocks (jens)"
	inherited := self inheritedBlocks select: [ :def | def category = #none ].
	customBlocks ifNil: [ cdefs := Set new ] ifNotNil: [ cdefs := customBlocks select: [ :def | def category = #none ] ].
	all := inherited , cdefs.
	all isEmpty
		ifTrue: [ ^ self ].
	all := all asSortedCollection: [ :first :second | first id <= second id ].
	all
		do: [ :eachDef | 
			b := self newCustomBlockFor: eachDef.
			page addMorph: (b position: x @ y).
			y := y + b height + 3 ]
]

{ #category : #blocks }
ScriptablePhratchMorph >> addEventNamesTo: aSet [
	"Add the names of all events implemented by this morph, excluding keyboard events. Suppress duplicates (ignoring case differences)."

	| allCustomBlockMorphs |
	(blocksBin isKindOf: Morph) ifFalse: [^ self].

	allCustomBlockMorphs := OrderedCollection new.
	customBlocks ifNotNil: [customBlocks do: [:cb | cb allBlocks do: [:ab |
		allCustomBlockMorphs addAll: ab allMorphs]]].

	blocksBin allMorphs, allCustomBlockMorphs do: [:m |
		(m class = EventTitleMorph) ifTrue: [
			(aSet anySatisfy: [:el | el caseInsensitiveEqual: m eventName]) ifFalse: [
				aSet add: m eventName]]].

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> addGenericColorBlocksTo: page x: x y: startY [
	"Add the generic variable blocks to the given page starting at the given y offset. Answer the new y."

	| y |
	y := startY.

	(self blocksFor: 'colors') do: [:blockOrSym |
		(blockOrSym = #-) | (blockOrSym = #~)
			ifTrue: [
				(blockOrSym = #-) ifTrue: [y := y + 15].	"insert a full space"
				(blockOrSym = #~) ifTrue: [y := y + 5]]	"insert a half space"
			ifFalse: [
				y := self createBlock: blockOrSym atPosition: x@y onPage: page.
				page submorphs last color: (ScriptablePhratchMorph blockColorFor: 'colors')]].

	^ y
]

{ #category : #blocks }
ScriptablePhratchMorph >> addGenericListBlocksTo: page y: startY [
	"Add the generic list blocks to the given page starting at the given y offset."

	| addButton deleteButton x y hasLists stage |
	addButton := PhratchFrameMorph
		buttonLabel: 'Make a list' localized
		selector: #addList.
	(self isKindOf: PhratchStageMorph) ifTrue: [addButton actionSelector: #addGlobalList].

	deleteButton := PhratchFrameMorph
		buttonLabel: 'Delete a list' localized
		selector: #deleteList.

	x := 13.
	y := startY + 10.
	page addMorph: (addButton target: self; position: x@y;
		yourself).
	y := addButton bottom + 3.

	hasLists := self listVarNames size > 0.
	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNotNil: [
		stage listVarNames size > 0 ifTrue: [hasLists := true]].
	hasLists ifTrue: [

		page addMorph: (deleteButton target: self; position: x@y;
		yourself).
		y := deleteButton bottom + 10.

		y := (self addListReportersTo: page x: x y: y) + 10 ].


	(self blocksFor: 'list') do: [:blockOrSym |
		(blockOrSym = #-) | (blockOrSym = #~) | (blockOrSym = #=)
			ifTrue: [
				(blockOrSym = #-) ifTrue: [y := y + 15].  "insert a full space"
				(blockOrSym = #~) ifTrue: [y := y + 5].  "insert a half space"
				(blockOrSym = #=) ifTrue: [
					y := y + 7.
					page addMorph: ((ImageMorph new form: (PhratchFrameMorph skinAt: #connector)) position: x@y).
					y := y + 20]]  "insert a line"
			ifFalse: [
				y := self createBlock: blockOrSym atPosition: x@y onPage: page.
				page submorphs last color: ScriptablePhratchMorph listBlockColor]].
	^y

]

{ #category : #blocks }
ScriptablePhratchMorph >> addGenericVariableBlocksTo: page x: x y: startY [
	"Add the generic variable blocks to the given page starting at the given y offset. Answer the new y."

	| y vName stage block varBlocks |
	y := startY.	"pick a default variable name"
	vName := nil.
	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	vName := (stage notNil and: [ stage varNames size > 0 ])
		ifTrue: [ stage varNames first ]
		ifFalse: [ 
			self varNames size = 0
				ifTrue: [ ''	"^ y" ]
				ifFalse: [ self varNames first ] ].
	vName ifNil: [ vName := '' ].
	varBlocks := OrderedCollection new.
	block := SetterBlockMorph new
		initSetterForVar: vName;
		receiver: self blockReceiver;
		yourself.
	block expressionArg stringExpression: '0'.
	varBlocks add: block.
	block := SetterBlockMorph new
		initChangerForVar: vName;
		receiver: self blockReceiver;
		yourself.
	block expressionArg numExpression: '1'.
	varBlocks add: block.
	(self blocksFor: 'variables')
		do: [ :b | 
			(b isKindOf: BlockMorph)
				ifTrue: [ b defaultArgs: (Array with: vName) ].
			varBlocks add: b ].
	block := VariableDeclarationBlockMorph new
		minArgs: 1;
		commandSpec: 'script variables' localized;
		receiver: self blockReceiver;
		addItem;
		isSpecialForm: true;
		selector: #doDeclareVariables;
		yourself.
	varBlocks add: block afterIndex: 5.
	varBlocks
		do: [ :blockOrSym | 
			blockOrSym = #- | (blockOrSym = #~) | (blockOrSym = #=)
				ifTrue: [ 
					blockOrSym = #-
						ifTrue: [ y := y + 15 ].	"insert a full space"
					blockOrSym = #~
						ifTrue: [ y := y + 5 ].	"insert a half space"
					blockOrSym = #=
						ifTrue: [ 
							y := y + 7.
							page addMorph: ((ImageMorph new form: (PhratchFrameMorph skinAt: #connector)) position: x @ y).
							y := y + 20 ] ]
				ifFalse: [ 
					blockOrSym
						color:
							((blockOrSym isKindOf: VariableDeclarationBlockMorph)
								ifTrue: [ Color gray ]
								ifFalse: [ self variableBlockColor ]).
					page addMorph: (blockOrSym position: x @ y).
					y := blockOrSym bottom + 3 ]	"insert a line" ].	"


[:b |
		b color: self variableBlockColor.
		page addMorph: (b position: x@y).
		y := b bottom + 3].
"
	^ y
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> addGlobalColor [
	"Ask the user for a color variable name, then add a background (global) variable of that name."

	| sFrame cName |
	(sFrame := self ownerThatIsA: PhratchFrameMorph) ifNil: [^ self beep].

	cName := StringDialog ask: 'Variable name?'.
	cName size = 0 ifTrue: [^ self].
	cName := cName.
	(sFrame workPane colorNames includes: cName) ifTrue: [
		self beep.
		DialogBoxMorph warn: 'That variable name is already in use'.
		^ self].

	sFrame workPane addColor: cName.
	sFrame viewerPane categoryChanged: 'colors'.
]

{ #category : #'list ops' }
ScriptablePhratchMorph >> addGlobalList [

	| sFrame listName |
	(sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ Beeper beep].

	listName := StringDialog ask: 'List name?'.
	listName size = 0 ifTrue: [^ self].
	sFrame workPane createListNamed: listName.
	sFrame viewerPane categoryChanged: 'variables'.

]

{ #category : #variables }
ScriptablePhratchMorph >> addGlobalVariable [
	"Ask the user for a variable name, then add a background (global) variable of that name."

	| sFrame varName |
	(sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ Beeper beep].

	varName := StringDialog ask: 'Variable name?'.
	varName size = 0 ifTrue: [^ self].
	varName := varName.
	(sFrame workPane variableNameInUse: varName) ifTrue: [
		Beeper beep.
		DialogBoxMorph warn: 'That variable name is already in use'.
		^ self].

	sFrame workPane addVariable: varName.
	sFrame viewerPane categoryChanged: 'variables'.
	self addWatcherForNewVariable: varName withScope: sFrame workPane.

]

{ #category : #'list ops' }
ScriptablePhratchMorph >> addList [

	| sFrame result listName |
	(sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ Beeper beep].

	result := NewVariableDialog ask: 'List name?'.
	result = #cancelled ifTrue: [^ self].
	listName := result first.
	result second
		ifTrue: [self createListNamed: listName]
		ifFalse: [sFrame workPane createListNamed: listName].
	sFrame viewerPane categoryChanged: 'variables'.

]

{ #category : #blocks }
ScriptablePhratchMorph >> addListReportersTo: page x: x y: startY [
	"Add the list block reporters to the given page starting at the given y offset. Answer the new y."

	| y stage b watcherButton yOffset line line2 |
	y := startY.
	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	(stage notNil and: [stage ~= self]) ifTrue: [
		stage listVarNames do: [:listVarName |
			b := ListContentsBlockMorph new
				color: ScriptablePhratchMorph listBlockColor;
				receiver: stage blockReceiver;
				commandSpec: listVarName;
				selector: #listNamed:;
		yourself.
			watcherButton := self createToggleButtonFor: b.
			yOffset := (b fullBounds height - watcherButton height) // 2.
			page addMorph: (watcherButton position: x @ (y + yOffset)).
			page addMorph: (b position: (x + watcherButton width + 4)@y).
			y := y + b height + 3].
		(self listVarNames size > 0) ifTrue: [
			line := Morph new.
			line
				extent: 90@1;
				color: Color gray darker darker;
				position: x@(y+2).
			line2 := Morph new.
			line2
				extent: 90@1;
				color: Color gray lighter;
				position: x@(y+3).
			page
				addMorph: line;
				addMorph: line2.
			y := y + 9]].

	self listVarNames do: [:listVarName |
		b := ListContentsBlockMorph new
			color: ScriptablePhratchMorph listBlockColor;
			receiver: self blockReceiver;
			commandSpec: listVarName;
			selector: #listNamed:;
		yourself.
		watcherButton := self createToggleButtonFor: b.
		yOffset := (b fullBounds height - watcherButton height) // 2.
		page addMorph: (watcherButton position: x @ (y + yOffset)).
		page addMorph: (b position: (x + watcherButton width + 4)@y).
		y := y + b height + 3].

	^ y

]

{ #category : #media }
ScriptablePhratchMorph >> addMediaItem: aPhratchMedia [
	"Add the given media item to my media."

	aPhratchMedia mediaName: (self unusedMediaNameFromBaseName: aPhratchMedia mediaName).
	media addLast: aPhratchMedia.
	aPhratchMedia isSound ifFalse: [self lookLike: aPhratchMedia mediaName].
	self updateMediaCategory.
]

{ #category : #scripts }
ScriptablePhratchMorph >> addStack: aBlockStack [
	"Aligns the newly added script below the lowest script in the pane."

	| y bottom |
	y := 10.
	blocksBin
		submorphsDo: [ :m | 
			bottom := m fullBounds bottom - blocksBin position y.
			y := y max: bottom ].
	aBlockStack position: blocksBin position + (20 @ (y + 10)).
	aBlockStack newScriptOwner: self.
	blocksBin addMorph: aBlockStack
]

{ #category : #byob }
ScriptablePhratchMorph >> addVariable [
	"Ask the user for a variable name, then add a user variable of that name. This version is for sprites and supports the option of making the variable specific to the sprite (i.e. local)."

	| sFrame result varName varOwner w |
	(sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ Beeper beep].

	result := NewVariableDialog ask: 'Variable name?'.
	result = #cancelled ifTrue: [^ self].
	varName := result first.
	varOwner := result second ifTrue: [self] ifFalse: [sFrame workPane].
	(varOwner variableNameInUse: varName) ifTrue: [
		Beeper beep.
		DialogBoxMorph warn: 'That variable name is already in use'.
		^ self].

	varOwner addVariable: varName.
	sFrame viewerPane categoryChanged: 'variables'.
	self addWatcherForNewVariable: varName withScope: varOwner.

	w := sFrame watcherForBlock: (VariableBlockMorph new receiver: self; commandSpec: varName; yourself).
	w ifNotNil: [w setCategoryColor: (ScriptablePhratchMorph blockColorFor: 'variables')].


]

{ #category : #variables }
ScriptablePhratchMorph >> addVariable: varName [
	"Add a new user variable with the given name to this object. Do nothing if the variable already exists or is built in."
	<phratchItem: 'make $String$' kind: #- category: 'variables' defaultValues: #('a variable') subCategory: #a1>
	| sFrame |
	(sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ Beeper beep].
	(vars includesKey: varName asString) ifFalse: [
		vars at: varName asString put: 0].
	self isClone: false.
	sFrame viewerPane categoryChanged: 'variables'.
	self addWatcherForNewVariable: varName withScope: sFrame workPane
]

{ #category : #variables }
ScriptablePhratchMorph >> addVariable: varName value: anObject [
	"Add a new user variable with the given name to this object. Do nothing if the variable already exists or is built in."

	(vars includesKey: varName asString) ifFalse: [
		vars at: varName asString put: anObject].
	self isClone: false.

]

{ #category : #blocks }
ScriptablePhratchMorph >> addVariableReportersTo: page x: x y: startY [
	"Add the list block reporters to the given page starting at the given y offset. Answer the new y."

	| y stage b watcherButton yOffset line line2 |
	y := startY.

	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	(stage notNil and: [stage ~= self]) ifTrue: [
		stage varNames do: [:vName |
			b := VariableBlockMorph new
				commandSpec: vName;
				receiver: stage blockReceiver;
		yourself.

			watcherButton := self createToggleButtonFor: b.
			yOffset := (b fullBounds height - watcherButton height) // 2.
			page addMorph: (watcherButton position: x @ (y + yOffset)).
			page addMorph: (b position: (x + watcherButton width + 4)@y).
			y := y + b height + 3].
		(self varNames size > 0) ifTrue: [
			line := Morph new.
			line
				extent: 90@1;
				color: Color gray darker darker;
				position: x@(y+2).
			line2 := Morph new.
			line2
				extent: 90@1;
				color: Color gray lighter;
				position: x@(y+3).
			page
				addMorph: line;
				addMorph: line2.
			y := y + 9]].

	self varNames do: [:vName |
		b := VariableBlockMorph new
			commandSpec: vName;
			receiver: self blockReceiver;
		yourself.

		watcherButton := self createToggleButtonFor: b.
		yOffset := (b fullBounds height - watcherButton height) // 2.
		page addMorph: (watcherButton position: x @ (y + yOffset)).
		page addMorph: (b position: (x + watcherButton width + 4)@y).
		y := y + b height + 3].

	^ y

]

{ #category : #variables }
ScriptablePhratchMorph >> addWatcherForNewVariable: varName withScope: spriteOrStage [
	"Add a watcher on the stage once a variable has been created."

	| sFrame |
	(sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ self].
	sFrame viewerPane pageViewer submorphs do: [:s | 
		(s isKindOf: PhratchBlockPaletteMorph) ifTrue: [
			s submorphs do: [:block | 
				(block isKindOf: VariableBlockMorph) ifTrue: [
					(block receiver = spriteOrStage) &
					(block commandSpec = varName) ifTrue: [
						(sFrame watcherForBlock: block) ifNil: [
							block toggleWatcher]]]]]].

]

{ #category : #byob }
ScriptablePhratchMorph >> allInstancesOf: aCustomBlockId [
	| objects stage all |
	stage := (self isKindOf: PhratchStageMorph)
		ifTrue: [ self ]
		ifFalse: [ self owner ].
	objects := {stage} , stage sprites.
	all := OrderedCollection new.
	objects do: [ :obj | all addAll: (obj instancesOf: aCustomBlockId) ].
	^ all
]

{ #category : #'byob OOP' }
ScriptablePhratchMorph >> allLocalBlockIds [

	| ownIds inheritedIds |
	ownIds := self blockIds.
	self prototype ifNil: [^ ownIds].
	inheritedIds := (self prototype localBlocks collect: [:each | 
		each id ]) reject: [:id |
			ownIds includes: id].
	^ (ownIds, inheritedIds) asSortedCollection
]

{ #category : #'BYOB object interface' }
ScriptablePhratchMorph >> allSprites [

	| stage |
	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	stage ifNil: [^ PhratchListMorph new].
	^ PhratchListMorph on: stage sprites
]

{ #category : #variables }
ScriptablePhratchMorph >> allVarNames [
	"Answer a set of all variable and list variable names."

	| allNames |
	allNames := vars keys asSet.
	allNames addAll: lists keys.
	^ allNames


]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> answer [
	<phratchItem: 'answer' kind: #r category: 'sensing' defaultValues: #() subCategory: #a1>
	^ PhratchPrompterMorph lastAnswer

]

{ #category : #'list ops' }
ScriptablePhratchMorph >> append: anObject toList: listName [
	<phratchItem: 'add $String$ to $List$' kind: #- category: 'list' defaultValues: #('thing') subCategory: #a4>
	| list |
	list := (listName isKindOf: PhratchListMorph)
		ifTrue: [ listName ]
		ifFalse: [ self listNamed: listName ifNone: [ ^ 0 ] ].
	list insertLine: (self asListElement: anObject) at: list lineCount + 1
]

{ #category : #'list ops' }
ScriptablePhratchMorph >> asListElement: anObject [
	"Answer the given object converted to an object suitable for storing in a list."

	(anObject isKindOf: ScriptablePhratchMorph) ifTrue: [^ anObject].
	(anObject isKindOf: BlockMorph) ifTrue: [^ anObject].
	(anObject isKindOf: PhratchListMorph) ifTrue: [^ anObject].
	(anObject isKindOf: String) ifTrue: [^ anObject].
	(anObject isKindOf: Character) ifTrue: [^ anObject asString].

	(anObject isKindOf: Boolean) ifTrue: [
		^ anObject].

"
	(anObject isKindOf: Boolean) ifTrue: [
		^ anObject ifTrue: ['1'] ifFalse: ['0']].
"

	^ anObject printString


]

{ #category : #'as yet unclassified' }
ScriptablePhratchMorph >> asReferenceTuple [

	self subclassResponsibility 
]

{ #category : #byob }
ScriptablePhratchMorph >> asciiCodeOf: aString [
	<phratchItem: 'ascii code of $String$' kind: #r category: 'operators' defaultValues: #('a') subCategory: #a7>
	| str |
	str := aString.
	str size = 1 ifFalse: [
		^ 0 ].
	^ str first asciiValue
]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> asciiFor: keyName [

	| localizedKey |
	keyName size = 1 ifTrue: [^ keyName first asciiValue].

	localizedKey := keyName localized.
	'space' localized = localizedKey ifTrue: [^ Character space asciiValue].
	'enter' localized = localizedKey ifTrue: [^ Character cr asciiValue].
	'up arrow' localized = localizedKey ifTrue: [^ 30].
	'down arrow' localized = localizedKey ifTrue: [^ 31].
	'right arrow' localized = localizedKey ifTrue: [^ 29].
	'left arrow' localized = localizedKey ifTrue: [^ 28].

	"needed to support old projects:"
	'up' = keyName ifTrue: [^ 30].
	'down' = keyName ifTrue: [^ 31].
	'right' = keyName ifTrue: [^ 29].
	'left' = keyName ifTrue: [^ 28].

	^ -1  "no match; should never happen"

]

{ #category : #byob }
ScriptablePhratchMorph >> asciiLetter: anInteger [
	<phratchItem: 'ascii $Number$ as letter' kind: #r category: 'operators' defaultValues: #('65') subCategory: #a7>
	| code |
	code := anInteger asNumberNoError.

	^ String with: (Character value: code)
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> askForFileIO [
	"Ask the user to either allow or deny file I/O, or return the preference from the sFrame if it exists."
	
	| sFrame dialog |
	(sFrame := self ownerThatIsA: PhratchFrameMorph) ifNil: [
		sFrame := (self ownerThatIsA: OffscreenWorldMorph) frame].
	ScriptablePhratchMorph fileIOPreference ifNotNil: [^ ScriptablePhratchMorph fileIOPreference].
	dialog := FileIOAskerDialog new forPhratchFrame: sFrame.
	^ dialog getUserResponse.
]

{ #category : #'as yet unclassified' }
ScriptablePhratchMorph >> attribute: attr [

	self subclassResponsibility 
]

{ #category : #'BYOB OOP message passing' }
ScriptablePhratchMorph >> attribute: attr of: anObject [
	"Answer the variable or built-in attribute value for the given sprite. Answer zero if the given sprite does not have a built-in attribute or variable of the given name."
	<phratchItem: 'get $Attributes$ of $Sprite$' kind: #r category: 'sensing' defaultValues: #() subCategory: #a3>
	| aSpriteOrStage |
	aSpriteOrStage := self coerceSpriteArg: anObject.

	(aSpriteOrStage isKindOf: ScriptablePhratchMorph) ifFalse: [^ 0].
	^ aSpriteOrStage attribute: attr

]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> attributeNames [

	^ vars keys

]

{ #category : #blocks }
ScriptablePhratchMorph >> blockCategories [
	"Answer a list of block categories."

	^ (self class blockSpecs select: [:el |
		(el isKindOf: String) and: [el ~= '-' and: [el ~= '~']]]) asArray

]

{ #category : #byob }
ScriptablePhratchMorph >> blockDefinition: anOrderedList [
	customBlocks := anOrderedList

]

{ #category : #'BYOB OOP message passing' }
ScriptablePhratchMorph >> blockForSelector: aSymbol [
	"Answer a block for the give selector or nil"

	| cat |

	self class blockSpecs do: [:spec |
		((spec isKindOf: Symbol) not and: [spec isKindOf: String])
			ifTrue: [cat := spec].

		((spec isKindOf: Array) and: [(spec at: 3) = aSymbol])
			ifTrue: [^ self blockFromSpec: spec color: (self class blockColorFor: cat)]].

	^ nil



]

{ #category : #blocks }
ScriptablePhratchMorph >> blockFromOldFormTuple: tuple receiver: scriptOwner [
	"Answer a new block for the given tuple."

	| k spec blockColor block argCount arg argBlock userSpec csp |
	k := tuple first.
	(#(#readVariable #changeVariable) includes: k)
		ifTrue: [ ^ self variableBlockFromTuple: tuple receiver: scriptOwner ].
	(#(#readBlockVariable #changeBlockVariable) includes: k)
		ifTrue: [ ^ self blockVariableBlockFromTuple: tuple receiver: scriptOwner ].
	#listNamed: = k
		ifTrue: [ 
			^ ListContentsBlockMorph new
				color: ScriptablePhratchMorph listBlockColor;
				receiver: scriptOwner;
				commandSpec: tuple second;
				selector: #listNamed:;
		yourself ].
	#lambda: = k
		ifTrue: [ 
			block := ReporterBlockMorph new.
			block
				color: Color lightGray;
				receiver: scriptOwner;
				selector: k;
				commandSpec: 'the $BlockId$ block'.
			(block argumentAt: 1) defaultValue: (tuple at: 2).
			^ block ].
	#doCustomBlock = k
		ifTrue: [ 
			userSpec := tuple at: 2.
			(scriptOwner definitionFor: (CustomBlockDefinition idFromSpec: userSpec)) isReporter
				ifTrue: [ 
					block := CustomReporterBlockMorph new.
					block isBoolean: (scriptOwner definitionFor: (CustomBlockDefinition idFromSpec: userSpec)) isBoolean ]
				ifFalse: [ block := CustomCommandBlockMorph new ].
			block
				receiver: scriptOwner;
				userSpec: userSpec.
			block isSpecialForm: true.
			block selector: #doCustomBlock.
			argCount := block argumentCount min: tuple size - 2.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 2.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: scriptOwner.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			^ block ].
	#doMakeNewList = k
		ifTrue: [ 
			block := MultiArgReporterBlockMorph new
				color: ScriptablePhratchMorph listBlockColor;
				receiver: scriptOwner;
				isSpecialForm: true;
				selector: #doMakeNewList;
		yourself.
			spec := 'list'.
			argCount := tuple size - 1.
			argCount timesRepeat: [ spec := spec , ' $String$' ].
			block commandSpec: spec.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 1.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: scriptOwner.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			^ block ].
	(#(#doCallBlockWithArgs #doReport) includes: k)
		ifTrue: [ 
			block := MultiArgReporterBlockMorph new
				color: (ScriptablePhratchMorph blockColorFor: 'control');
				receiver: scriptOwner;
				isSpecialForm: true;
				minArgs: 1;
				selector: k;
		yourself.
			spec := scriptOwner blockSpecForSelector: k.
			argCount := tuple size - 1.
			argCount - 2 timesRepeat: [ spec := spec , ' $String$' ].
			block commandSpec: spec.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 1.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: scriptOwner.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			^ block ].
	(#(#function #functionWithArgs) includes: k)
		ifTrue: [ 
			block := ReporterScriptBlockMorph new
				color: (ScriptablePhratchMorph blockColorFor: 'operators');
				receiver: scriptOwner;
				isSpecialForm: false;
				minArgs: 1;
				selector: k;
		yourself.
			spec := scriptOwner blockSpecForSelector: k.
			argCount := tuple size - 1.
			argCount - 2 timesRepeat: [ spec := spec , ' $String$' ].
			block commandSpec: spec.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 1.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: scriptOwner.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			^ block ].
	(#(#EventHatMorph #KeyEventHatMorph #MouseClickEventHatMorph #WhenHatBlockMorph) includes: k)
		ifTrue: [ 
			block := self hatBlockFromTuple: tuple receiver: scriptOwner.
			(block isKindOf: WhenHatBlockMorph)
				ifTrue: [ block color: Color red ].
			^ block ].
	(#phratchComment = k) | (#scratchComment = k) "for compatibility"
		ifTrue: [ 
			block := PhratchCommentMorph new.
			tuple size > 1
				ifTrue: [ block commentMorph contents: (tuple at: 2) ].
			tuple size > 2
				ifTrue: [ 
					(tuple at: 3)
						ifFalse: [ block toggleShowing ] ].
			tuple size > 3
				ifTrue: [ block width: (tuple at: 4) ].
			tuple size > 4
				ifTrue: [ block anchor: (self blockWithID: (tuple at: 5)) ].
			^ block ].
	#comment: = k
		ifTrue: [ 
			block := CommentBlockMorph new.
			tuple size > 1
				ifTrue: [ block comment: (tuple at: 2) ].
			tuple size > 2
				ifTrue: [ 
					(tuple at: 3)
						ifFalse: [ block toggleShowing ] ].
			block color: (Color r: 0.8 g: 0 b: 0).	"obsolete"
			^ block ].
	spec := self class blockSpecDict at: k ifAbsent: [ nil ].
	spec ifNil: [ ^ scriptOwner blockFromSpec: #('obsolete!' #- #yourself) color: Color red ].
	blockColor := BlockColorDict at: k ifAbsent: [ Color red ].
	block := scriptOwner blockFromSpec: spec color: blockColor.
	#procedureWithArgs = block selector
		ifTrue: [ 
			argCount := tuple size - 2.
			argCount > 1
				ifTrue: [ 
					csp := block commandSpec.
					argCount - 1 timesRepeat: [ csp := csp , ' $String$' ].
					block commandSpec: csp ] ].
	(block isKindOf: CommandBlockMorph)
		ifTrue: [ 
			argCount := block argumentCount min: tuple size - 1.
			1 to: argCount do: [ :i | 
				arg := ((#(#+ #- #/ #* #=) includes: block selector) and: [ PhratchTranslator isRTLMath ])
					ifTrue: [ tuple at: argCount + 1 - (i - 1) ]
					ifFalse: [ tuple at: i + 1 ].	"RTLMath operators are RTL"
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: scriptOwner.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) defaultValue: arg ] ].
			(block isKindOf: CBlockMorph) | (block isKindOf: CommandScriptBlockMorph)
				ifTrue: [ 
					(tuple last isKindOf: Array)
						ifTrue: [ block firstBlockList: (self stackFromTupleList: tuple last receiver: scriptOwner) ] ].
			(block isKindOf: IfElseBlockMorph)
				ifTrue: [ 
					arg := tuple at: tuple size - 1.
					(arg isKindOf: Array)
						ifTrue: [ block trueBlock: (self stackFromTupleList: arg receiver: scriptOwner) ].
					arg := tuple at: tuple size.
					(arg isKindOf: Array)
						ifTrue: [ block falseBlock: (self stackFromTupleList: arg receiver: scriptOwner) ] ].
			(block isKindOf: ReporterBlockMorph)
				ifTrue: [ 
					((spec at: 2) includes: $b)
						ifTrue: [ block isBoolean: true ] ] ].
	^ block
]

{ #category : #'list ops' }
ScriptablePhratchMorph >> blockFromSpec: spec color: blockColor [
	"Create a block from the given block specification. Answer nil if I don't implement the block spec selector."

	| blockLabelSpec blockType selector defaultArgs block rcvr argPermutation |
	blockLabelSpec := PhratchTranslator translationFor: (spec at: 1).
	argPermutation := CommandBlockMorph argPermutationForSpec: (spec at: 1) withTranslation: blockLabelSpec.
	blockType := spec at: 2.
	selector := (spec at: 3) asSymbol.
	defaultArgs := self defaultArgsFor: spec.
	(#(#E #K #M #S #W #C) includes: blockType)
		ifTrue: [ ^ (self hatBlockType: blockType) color: blockColor ].	"basic block type: normal or C-shaped"
	(blockType includes: $c)
		ifTrue: [ 
			block := selector = #doIfElse
				ifTrue: [ IfElseBlockMorph new isSpecialForm: true ]
				ifFalse: [ CBlockMorph new isSpecialForm: true ] ]
		ifFalse: [ 
			(blockType includes: $q) | (blockType includes: $Q)
				ifTrue: [ 
					block := (blockType includes: $Q)
						ifTrue: [ ReporterScriptBlockMorph new minArgs: 1 ]
						ifFalse: [ CommandScriptBlockMorph new ].
					block isSpecialForm: false ]
				ifFalse: [ 
					(blockType includes: $r) | (blockType includes: $b) | (blockType includes: $R)
						ifTrue: [ block := ReporterBlockMorph new ]
						ifFalse: [ 
							(blockType includes: $d)
								ifTrue: [ 
									block := MultiArgReporterBlockMorph new.
									(#(#doCallBlockWithArgs #doReport) includes: selector)
										ifTrue: [ block minArgs: 1 ] ]
								ifFalse: [ 
									(blockType includes: $u)
										ifTrue: [ 
											block := MultiArgCommandBlockMorph new.
											block minArgs: 1 ]
										ifFalse: [ 
											block := (blockType includes: $g)
												ifTrue: [ ColorBlockMorph new ]
												ifFalse: [ CommandBlockMorph new ] ] ] ] ] ].
	(blockType includes: $b)
		ifTrue: [ block isBoolean: true ].
	(blockType includes: $s) | (blockType includes: $R) | (blockType includes: $d) | (blockType includes: $u)
		ifTrue: [ block isSpecialForm: true ].
	(blockType includes: $t)
		ifTrue: [ block isTimed: true ].
	rcvr := (ScriptablePhratchMorph isSpriteSpecificTarget: self selector: selector)
		ifTrue: [ self ]
		ifFalse: [ self ownerOrYourselfThatIsA: PhratchStageMorph ].
	^ block
		argPermutation: argPermutation;
		color: blockColor;
		selector: selector;
		commandSpec: blockLabelSpec;
		defaultArgs: defaultArgs;
		receiver: rcvr;
		yourself
]

{ #category : #blocks }
ScriptablePhratchMorph >> blockFromTuple: tuple receiver: scriptOwner [
	"Answer a new block for the given tuple."

	| k rcvr spec blockColor block argCount arg argBlock userSpec csp def |
	#byob = tuple first
		ifFalse: [ ^ self blockFromOldFormTuple: tuple receiver: scriptOwner ].
	'Stage' = tuple second
		ifTrue: [ rcvr := self ownerOrYourselfThatIsA: PhratchStageMorph ]
		ifFalse: [ 
			(tuple second isKindOf: VariableFrame)
				ifFalse: [ rcvr := self coerceSpriteArg: tuple second ] ].
	rcvr ifNil: [ rcvr := scriptOwner ].
	k := tuple third.
	(#(#readVariable #changeVariable) includes: k)
		ifTrue: [ ^ self variableBlockFromTuple: tuple receiver: rcvr ].
	(#(#readBlockVariable #changeBlockVariable) includes: k)
		ifTrue: [ ^ self blockVariableBlockFromTuple: tuple receiver: rcvr ].
	#listNamed: = k
		ifTrue: [ 
			^ ListContentsBlockMorph new
				color: ScriptablePhratchMorph listBlockColor;
				receiver: rcvr;
				commandSpec: tuple fourth;
				selector: #listNamed:;
		yourself ].
	#lambda: = k
		ifTrue: [ 
			block := ReporterBlockMorph new.
			block
				color: Color lightGray;
				receiver: rcvr;
				selector: k;
				commandSpec: 'the $BlockId$ block'.
			(block argumentAt: 1) defaultValue: (tuple at: 4).
			^ block ].
	#autoLambda = k
		ifTrue: [ 
			block := CSlotMorph new.
			(tuple at: 9) ifNotNil: [ block attachBlockNested: (self stackFromTupleList: (tuple at: 9) receiver: scriptOwner) ].
			^ block ].
	#loopLambda = k
		ifTrue: [ 
			block := CArgSlotMorph new.
			(tuple at: 9) ifNotNil: [ block attachBlockNested: (self stackFromTupleList: (tuple at: 9) receiver: scriptOwner) ].
			^ block ].
	#autoBlock = k
		ifTrue: [ 
			block := OSlotMorph new type: #reporterslot.
			(tuple at: 4)
				ifNotNil: [ block replaceArgMorph: block argMorphs first by: (self stackFromTupleList: (tuple at: 4) receiver: scriptOwner) ].
			^ block ].
	#cLambda = k
		ifTrue: [ 
			block := CReporterSlotMorph new.
			(tuple at: 4)
				ifNotNil: [ block replaceArgMorph: block argMorphs first by: (self stackFromTupleList: (tuple at: 4) receiver: scriptOwner) ].
			^ block ].
	#typeInLambda = k
		ifTrue: [ 
			block := TypeInReporterSlotMorph new.
			((tuple at: 4) isKindOf: String)
				ifTrue: [ block argMorphs first defaultValue: (tuple at: 4) ]
				ifFalse: [ block replaceArgMorph: block argMorphs first by: (self stackFromTupleList: (tuple at: 4) receiver: scriptOwner) ].
			^ block ].
	#autoPredicate = k
		ifTrue: [ 
			block := OSlotMorph new type: #booleanslot.
			(tuple at: 4)
				ifNotNil: [ block replaceArgMorph: block argMorphs first by: (self stackFromTupleList: (tuple at: 4) receiver: scriptOwner) ].
			^ block ].
	#doCustomBlock = k
		ifTrue: [ 
			userSpec := tuple at: 4.
			def := rcvr definitionFor: (CustomBlockDefinition idFromSpec: userSpec).
			(def isNil or: [ #none = def type ])
				ifTrue: [ block := CustomCommandBlockMorph new ]
				ifFalse: [ 
					block := CustomReporterBlockMorph new.
					block isBoolean: def type = #boolean ].
			block
				receiver: rcvr;
				userSpec: userSpec.
			block isSpecialForm: true.
			block selector: #doCustomBlock.
			argCount := block argumentCount min: tuple size - 4.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 4.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: scriptOwner.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(arg isKindOf: PhratchListMorph)
							ifTrue: [ arg convertBlockTuplesToStacksFor: self ].
						(block argumentAt: i) defaultValue: arg ] ].
			^ block ].
	#doMakeNewList = k
		ifTrue: [ 
			block := MultiArgReporterBlockMorph new
				color: ScriptablePhratchMorph listBlockColor;
				receiver: rcvr;
				isSpecialForm: true;
				selector: #doMakeNewList;
		yourself.
			spec := 'list'.
			argCount := tuple size - 3.
			argCount timesRepeat: [ spec := spec , ' $String$' ].
			block commandSpec: spec.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 3.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: rcvr.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			^ block ].
	(#(#doCallBlockWithArgs #doReport #doCallBlockWithArgList) includes: k)
		ifTrue: [ 
			block := MultiArgReporterBlockMorph new
				color: (ScriptablePhratchMorph blockColorFor: 'control');
				receiver: rcvr;
				isSpecialForm: true;
				minArgs: 1;
				selector: k;
		yourself.
			spec := rcvr blockSpecForSelector: k.
			argCount := tuple size - 3.
			argCount - 3 timesRepeat: [ spec := spec , ' $String$' ].
			block commandSpec: spec.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 3.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: rcvr.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						((block argumentAt: i) isKindOf: ChoiceArgMorph)
							ifTrue: [ (block argumentAt: i) privateSetChoice: arg asString ]
							ifFalse: [ 
								arg isNil
									ifFalse: [ (block argumentAt: i) stringExpression: arg asString ] ] ] ].
			^ block ].
	(#(#function #functionWithArgs) includes: k)
		ifTrue: [ 
			block := ReporterScriptBlockMorph new
				color: (ScriptablePhratchMorph blockColorFor: 'operators');
				receiver: rcvr;
				isSpecialForm: false;
				minArgs: 1;
				selector: k;
				parameters: (tuple at: 4) asOrderedCollection;
				variables: (tuple at: 5) asOrderedCollection;
				type: (tuple at: 6);
				declarations: (tuple at: 7);
				isAtomic: (tuple at: 8);
		yourself.
			spec := scriptOwner blockSpecForSelector: k.
			argCount := tuple size - 9.
			argCount - 2 timesRepeat: [ spec := spec , ' $String$' ].
			block commandSpec: spec.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 8.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: rcvr.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			block fixInitialFrame.
			^ block ].
	#doDeclareVariables = k
		ifTrue: [ 
			block := VariableDeclarationBlockMorph new
				receiver: rcvr;
				color: Color gray;
				isSpecialForm: true;
				minArgs: 1;
				selector: k;
		yourself.
			argCount := tuple size - 3.
			spec := 'script variables' localized.
			argCount timesRepeat: [ spec := spec , ' $String$' ].
			block commandSpec: spec.
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 3.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: rcvr.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			^ block ].
	(#(#EventHatMorph #KeyEventHatMorph #MouseClickEventHatMorph #WhenHatBlockMorph #CreationEventHatMorph) includes: k)
		ifTrue: [ 
			block := self hatBlockFromTuple: tuple receiver: rcvr.
			(block isKindOf: WhenHatBlockMorph)
				ifTrue: [ block color: Color red ].
			^ block ].
	(#phratchComment = k) | (#scratchComment = k) "for compatibility"
		ifTrue: [ 
			block := PhratchCommentMorph new.
			tuple size > 3
				ifTrue: [ block commentMorph contents: (tuple at: 4) ].
			tuple size > 4
				ifTrue: [ 
					(tuple at: 5)
						ifFalse: [ block toggleShowing ] ].
			tuple size > 5
				ifTrue: [ block width: (tuple at: 6) ].
			tuple size > 6
				ifTrue: [ block anchor: (self blockWithID: (tuple at: 7)) ].
			block
				toggleShowing;
				toggleShowing.
			^ block ].
	#comment: = k
		ifTrue: [ 
			block := CommentBlockMorph new.
			tuple size > 1
				ifTrue: [ block comment: (tuple at: 2) ].
			tuple size > 2
				ifTrue: [ 
					(tuple at: 3)
						ifFalse: [ block toggleShowing ] ].
			block color: (Color r: 0.8 g: 0 b: 0).	"obsolete"
			^ block ].
	spec := self class blockSpecDict at: k ifAbsent: [ nil ].
	spec ifNil: [ ^ rcvr blockFromSpec: #('obsolete!' #- #yourself) color: Color red ].
	blockColor := BlockColorDict at: k ifAbsent: [ Color red ].
	block := rcvr blockFromSpec: spec color: blockColor.
	#procedure = block selector
		ifTrue: [ 
			block
				parameters: (tuple at: 4) asOrderedCollection;
				variables: (tuple at: 5) asOrderedCollection;
				type: (tuple at: 6);
				declarations: (tuple at: 7);
				isAtomic: (tuple at: 8).
			argCount := tuple size - 9.
			argCount > 1
				ifTrue: [ 
					csp := block commandSpec.
					argCount - 1 timesRepeat: [ csp := csp , ' $String$' ].
					block commandSpec: csp ].
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 8.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: rcvr.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			(tuple last isKindOf: Array)
				ifTrue: [ block firstBlockList: (self stackFromTupleList: tuple last receiver: rcvr) ].
			block fixInitialFrame.
			^ block ].
	#procedureWithArgs = block selector
		ifTrue: [ 
			block
				parameters: (tuple at: 4) asOrderedCollection;
				variables: (tuple at: 5) asOrderedCollection;
				type: (tuple at: 6);
				declarations: (tuple at: 7);
				isAtomic: (tuple at: 8).
			argCount := tuple size - 9.
			argCount > 1
				ifTrue: [ 
					csp := block commandSpec.
					argCount - 1 timesRepeat: [ csp := csp , ' $String$' ].
					block commandSpec: csp ].
			1 to: argCount do: [ :i | 
				arg := tuple at: i + 8.
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: rcvr.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(block argumentAt: i) stringExpression: arg asString ] ].
			(tuple last isKindOf: Array)
				ifTrue: [ block firstBlockList: (self stackFromTupleList: tuple last receiver: rcvr) ].
			block fixInitialFrame.
			^ block ].
	(block isKindOf: CommandBlockMorph)
		ifTrue: [ 
			argCount := block argumentCount min: tuple size - 3.
			(block isKindOf: MultiArgCommandBlockMorph)
				ifTrue: [ 
					argCount := tuple size - 3.
					csp := block commandSpec.
					argCount - 3 timesRepeat: [ csp := csp , ' $String$' ].
					block commandSpec: csp.
					1 to: argCount do: [ :i | 
						arg := tuple at: i + 3.
						(arg isKindOf: Array)
							ifTrue: [ 
								"argument is a block"
								(arg size = 1 and: [ arg first isKindOf: Array ])
									ifTrue: [ arg := arg first ].
								argBlock := self blockFromTuple: arg receiver: rcvr.
								block replaceArgMorph: (block argumentAt: i) by: argBlock ]
							ifFalse: [ 
								"argument is a value"
								((block argumentAt: i) isKindOf: ChoiceArgMorph)
									ifTrue: [ (block argumentAt: i) privateSetChoice: arg asString ]
									ifFalse: [ (block argumentAt: i) stringExpression: arg asString ] ] ].
					^ block ].
			1 to: argCount do: [ :i | 
				arg := ((#(#+ #- #/ #* #=) includes: block selector) and: [ PhratchTranslator isRTLMath ])
					ifTrue: [ tuple at: argCount + 3 - (i - 1) ]
					ifFalse: [ tuple at: i + 3 ].	"RTLMath operators are RTL"
				(arg isKindOf: Array)
					ifTrue: [ 
						"argument is a block"
						(arg size = 1 and: [ arg first isKindOf: Array ])
							ifTrue: [ arg := arg first ].
						argBlock := self blockFromTuple: arg receiver: scriptOwner.
						block replaceArgMorph: (block argumentAt: i) by: argBlock ]
					ifFalse: [ 
						"argument is a value"
						(arg isKindOf: PhratchListMorph)
							ifTrue: [ arg convertBlockTuplesToStacksFor: self ].
						(block argumentAt: i) defaultValue: arg ] ].
			(block isKindOf: CBlockMorph)
				ifTrue: [ 
					(tuple last isKindOf: Array)
						ifTrue: [ block firstBlockList: (self stackFromTupleList: tuple last receiver: rcvr) ] ].
			(block isKindOf: IfElseBlockMorph)
				ifTrue: [ 
					arg := tuple at: tuple size - 1.
					(arg isKindOf: Array)
						ifTrue: [ block trueBlock: (self stackFromTupleList: arg receiver: rcvr) ].
					arg := tuple at: tuple size.
					(arg isKindOf: Array)
						ifTrue: [ block falseBlock: (self stackFromTupleList: arg receiver: rcvr) ] ].
			(block isKindOf: ReporterBlockMorph)
				ifTrue: [ 
					((spec at: 2) includes: $b)
						ifTrue: [ block isBoolean: true ] ] ].
	^ block
]

{ #category : #byob }
ScriptablePhratchMorph >> blockIds [
	customBlocks ifNil: [ customBlocks := OrderedCollection new ].
	^ (customBlocks reject: [ :eachDef | eachDef isGlobal ]) collect: [ :eachDef | eachDef id ]
]

{ #category : #blocks }
ScriptablePhratchMorph >> blockReceiver [
	"Answer the object that is the receiver of my blocks. By default that is myself, but subclasses may re-direct block operations to another object."

	^ self

]

{ #category : #blocks }
ScriptablePhratchMorph >> blockSpecForSelector: aSymbol [
	"Answer a block specification string (in English) for the give selector or nil if there is no spec that has the given selector."

	self class blockSpecs do: [:spec |
		((spec isKindOf: Array) and: [(spec at: 3) = aSymbol])
			ifTrue: [^ spec first]].

	^ nil

]

{ #category : #blocks }
ScriptablePhratchMorph >> blockVariableBlockFromTuple: tuple receiver: scriptOwner [
	"Answer a new block for the given variable reference tuple."

	| varName rcvr selector block arg argBlock |
	#byob = tuple first
		ifFalse: [ ^ self blockVariableBlockFromTupleOldForm: tuple receiver: scriptOwner ].
	varName := tuple at: 4.
	rcvr := scriptOwner.
	tuple third = #readBlockVariable
		ifTrue: [ 
			rcvr := ((tuple at: 5) isKindOf: VariableFrame)
				ifTrue: [ (tuple at: 5) convertTuplesToStacks ]
				ifFalse: [ VariableFrame new	"definitionFor: (CustomBlockDefinition idFromSpec: (tuple at: 5))" ].
			^ VariableBlockMorph new
				receiver: rcvr;
				selector: #getVar:;
				commandSpec: varName;
				isSpecialForm: true;
		yourself ].
	tuple third = #changeBlockVariable
		ifTrue: [ 
			selector := tuple at: 5.
			rcvr := ((tuple at: 6) isKindOf: VariableFrame)
				ifTrue: [ (tuple at: 6) convertTuplesToStacks ]
				ifFalse: [ rcvr definitionFor: (CustomBlockDefinition idFromSpec: (tuple at: 6)) ].
			block := SetterBlockMorph new color: (ScriptablePhratchMorph blockColorFor: 'variables').
			(#(#setVar:to: #setBlockVar:to:) includes: selector)
				ifTrue: [ block initSetterForVar: varName ]
				ifFalse: [ block initChangerForVar: varName ].
			block
				receiver: rcvr;
				isSpecialForm: true.
			arg := tuple at: 7.
			(arg isKindOf: Array)
				ifTrue: [ 
					"argument is a block"
					(arg size = 1 and: [ arg first isKindOf: Array ])
						ifTrue: [ arg := arg first ].
					argBlock := self blockFromTuple: arg receiver: scriptOwner.
					block replaceArgMorph: block expressionArg by: argBlock ]
				ifFalse: [ 
					"argument is a value"
					block expressionArg defaultValue: arg ].
			^ block ].
	self error: 'unknown block variable spec'
]

{ #category : #blocks }
ScriptablePhratchMorph >> blockVariableBlockFromTupleOldForm: tuple receiver: scriptOwner [
	"Answer a new block for the given variable reference tuple."

	| varName rcvr selector block arg argBlock |
	varName := tuple at: 2.
	rcvr := scriptOwner.
	tuple first = #readBlockVariable
		ifTrue: [ 
			rcvr := (tuple third isKindOf: VariableFrame)
				ifTrue: [ tuple third convertTuplesToStacks ]
				ifFalse: [ rcvr definitionFor: (CustomBlockDefinition idFromSpec: tuple third) ].
			^ VariableBlockMorph new
				receiver: rcvr;
				selector: #getVar:;
				commandSpec: varName;
				isSpecialForm: true;
		yourself ].
	tuple first = #changeBlockVariable
		ifTrue: [ 
			selector := tuple at: 3.
			rcvr := (tuple fourth isKindOf: VariableFrame)
				ifTrue: [ tuple fourth convertTuplesToStacks ]
				ifFalse: [ rcvr definitionFor: (CustomBlockDefinition idFromSpec: tuple fourth) ].
			block := SetterBlockMorph new
				receiver: rcvr;
				color: (ScriptablePhratchMorph blockColorFor: 'variables');
		yourself.
			(#(#setVar:to: #setBlockVar:to:) includes: selector)
				ifTrue: [ block initSetterForVar: varName ]
				ifFalse: [ block initChangerForVar: varName ].
			block isSpecialForm: true.
			arg := tuple at: 5.
			(arg isKindOf: Array)
				ifTrue: [ 
					"argument is a block"
					(arg size = 1 and: [ arg first isKindOf: Array ])
						ifTrue: [ arg := arg first ].
					argBlock := self blockFromTuple: arg receiver: scriptOwner.
					block replaceArgMorph: block expressionArg by: argBlock ]
				ifFalse: [ 
					"argument is a value"
					block expressionArg defaultValue: arg ].
			^ block ].
	self error: 'unknown block variable spec'
]

{ #category : #blocks }
ScriptablePhratchMorph >> blockWithID: id [

	| topBlockList blockList|

	topBlockList := (blocksBin submorphs select: [:m | (m isKindOf: BlockMorph) ]) reversed.
	blockList := OrderedCollection new.
	topBlockList do: [:top | (top allMorphs select: [:b| b isKindOf: BlockMorph ]) do: [:m |
		blockList add: m ]].

	^ blockList at: id ifAbsent: [nil].

]

{ #category : #blocks }
ScriptablePhratchMorph >> blocksBin [

	^ blocksBin

]

{ #category : #blocks }
ScriptablePhratchMorph >> blocksFor: aCategory [
	"Answer a collection of blocks for the given category. Mixed with the blocks are dash and tilde symbols (#- and #~) indicating where full and half spaces should be inserted when laying out the blocks."

	| blockColor blocksList category b cdefs inherited all |
	blockColor := self class blockColorFor: aCategory.
	blocksList := OrderedCollection new.
	category := nil.
	self class blockSpecs do: [:spec |
		((spec isKindOf: String) and: [spec ~= #- and: [spec ~= #~ and: [spec ~= #=]]])
			ifTrue: [category := spec]
			ifFalse: [
				category = aCategory ifTrue: [
					(spec = #-) | (spec = #~)  | (spec = #=)
						ifTrue: [blocksList addLast: spec]
						ifFalse: [
							(b := self blockFromSpec: spec color: blockColor) ifNotNil: [
								blocksList addLast: b]]]]].

	"add custom blocks (jens)"
	inherited := self inheritedBlocks select: [:def |
		def category = aCategory asSymbol ].

	customBlocks 
		ifNil: [cdefs := Set new]
		ifNotNil: [ cdefs := customBlocks select: [:def | 
			def category = aCategory asSymbol]].

	all := inherited, cdefs.
	all isEmpty ifFalse: [
		blocksList
			add: #=.
		all := all asSortedCollection: [:x :y | x commandSpec <= y commandSpec].
		blocksList addAll: (all collect: [:each | self newCustomBlockFor: each ])].

	^ blocksList asArray

]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> brightnessEffect [

	| att |
	att := #brightness.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ [filterPack brightnessShift] ifError: [0]
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> brightnessEffect: aNumber [

	self undeleteAttribute: #brightness.
	self passiveBrightnessEffect: aNumber
]

{ #category : #'other ops' }
ScriptablePhratchMorph >> broadcast: name [
	"Broadcast the given event name with zero as its argument."
	<phratchItem: 'broadcast $Event$' kind: #- category: 'control' defaultValues: #() subCategory: #broadcast>
	self broadcast: name withArgument: 0.

]

{ #category : #'other ops' }
ScriptablePhratchMorph >> broadcast: name withArgument: arg [
	"Broadcast the given event with the given argument."

	| stage |
	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNotNil: [
		stage broadcastEventNamed: name asString with: arg].

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> cameraIsOpen [
	<phratchItem: 'camera is open?' kind: #b category: 'looks' defaultValues: #() subCategory: #a9>
	^ CameraPlugin cameraIsOpen: 1.
]

{ #category : #'looks ops' }
ScriptablePhratchMorph >> changeGraphicEffect: effect by: aNumber [
	"Change the given graphic effect by the given value."
	<phratchItem: 'change $Effects$ effect by $Number$' kind: #- category: 'looks' defaultValues: #('color' 25) subCategory: #a3>
	
	'brightness' = effect ifTrue: [self brightnessEffect: self brightnessEffect + aNumber asNumberNoError].
	'fisheye' = effect ifTrue: [self fisheyeEffect: self fisheyeEffect + aNumber asNumberNoError].
	'color' = effect ifTrue: [self colorEffect: self colorEffect + aNumber asNumberNoError].
	'mosaic' = effect ifTrue: [self mosaicEffect: self mosaicEffect + aNumber asNumberNoError].
	'pixelate' = effect ifTrue: [self pixelateEffect: self pixelateEffect + aNumber asNumberNoError].
	'ghost' = effect ifTrue: [
		self transparencyEffect: self transparencyEffect + aNumber asNumberNoError].
	'whirl' = effect ifTrue: [self whirlEffect: self whirlEffect + aNumber asNumberNoError].

]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> changeTempoBy: aNumber [
	<phratchItem: 'change tempo by $Number$' kind: #- category: 'sound' defaultValues: #(20) subCategory: #a5>
	self setTempoTo: self tempo + aNumber.

]

{ #category : #variables }
ScriptablePhratchMorph >> changeVar: varName by: increment [
	"Change the value of the given variable of this object by the given amount."
	<phratchItem: 'change $Variable$ by $Number$' kind: #- category: 'variables' defaultValues: #('' 1) subCategory: #a4>
	| stage n frame w |

	(vars includesKey: varName asString) ifFalse: [
		stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
		(stage notNil and: [stage ~= self]) 
			ifTrue: [stage changeVar: varName by: increment].
		(self prototype notNil and: [self prototype varNames includes: varName])
			ifTrue: [
				vars at: varName put: (self getVar: varName) + increment asNumberNoError.
			frame := self phratchFrame.
			frame ifNil: [^ self].
			frame viewerPane categoryChanged: 'variables'.
			w := frame watcherForBlock: (VariableBlockMorph new 
					receiver: self; 
					commandSpec: varName; 
					yourself).
			w ifNotNil: [
				w setCategoryColor: (ScriptablePhratchMorph blockColorFor: 'variables') ]].
		^ self].

	n := vars at: varName asString ifAbsent: [^ self].
	self setVar: varName to: n asNumberNoError + increment asNumberNoError.

]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> changeVolumeBy: aNumber [
	<phratchItem: 'change volume by $Number$' kind: #- category: 'sound' defaultValues: #(-10) subCategory: #a4>
	self setVolumeTo: volume + aNumber.

]

{ #category : #widgets }
ScriptablePhratchMorph >> changed [
	"Report that the area occupied by this morph should be redrawn."
	self invalidRect: self fullBounds.

]

{ #category : #'as yet unclassified' }
ScriptablePhratchMorph >> checkNil: str [
	<phratchItem: 'is $String$ nil?' kind: #b category: 'operators' defaultValues: #() subCategory: #b1>
	^ str isNil
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> clearFile: aFileNameString [
	"Clear the given file."
	<phratchItem: 'clear file $String$' kind: #- category: 'files' defaultValues: #() subCategory: #a>
	| f |
	(self askForFileIO = true) ifFalse: [^ self].
	aFileNameString asFileReference delete.
	f := FileStream newFileNamed: aFileNameString.
	f close
]

{ #category : #private }
ScriptablePhratchMorph >> clearMediaAndCostume [
	"Private! Used when exporting an empty stage."

	media := OrderedCollection new.
	costume := nil.

]

{ #category : #'as yet unclassified' }
ScriptablePhratchMorph >> clearPenTrails [

	self subclassResponsibility 
]

{ #category : #byob }
ScriptablePhratchMorph >> clearVariables [

	self varNames do: [:vn |
		self setVar: vn to: 0].

	self listVarNames do: [:ln |
		(self listNamed: ln) clear]
]

{ #category : #'event handling' }
ScriptablePhratchMorph >> click: evt [
	"Start or stop all my clickable scripts."

	| h clickEvt |
	h := World activeHand.
	h toolType ifNotNil: [^ self handleTool: h toolType hand: h].

	clickEvt := PhratchEvent new
		name: 'Phratch-MouseClickEvent'
		argument: 0.
	self eventReceived: clickEvt.

]

{ #category : #byob }
ScriptablePhratchMorph >> closeBlockEditor [
	| sf |
	sf := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	sf ifNil: [^self].
	^sf closeBlockEditor
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> closeCamera [

	self class closeCamera.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> closeDefinitivelyCamera [
	<phratchItem: 'close camera' kind: #- category: 'looks' defaultValues: #() subCategory: #a9>
	self cameraIsOpen
		ifFalse: [ ^ self ].
	CameraOpenings := 0.
	CameraPlugin closeCamera: 1
]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> coerceSpriteArg: anObject [
	"Coerce the given object to a sprite reference if necessary. If it is a Symbol (e.g. #mouse), just return it. If it is a String, try to find a Sprite with that name. If it is a Number, coerce it to a string and look for a Sprite with a matching name."

	| s targetName |
	(anObject isKindOf: ScriptablePhratchMorph) ifTrue: [^ anObject].
	(anObject isKindOf: Symbol) ifTrue: [^ anObject].

	targetName := anObject isNumber ifTrue: [anObject printString] ifFalse: [anObject].

	(s := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNil: [^ nil].
	s submorphsDo: [:m |
		((m isKindOf: ScriptablePhratchMorph) and:
		 [targetName = m objName])
			ifTrue: [^ m]].

	^ nil


]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> colorAsString: aColor [
	<phratchItem: '$Color$ as string' kind: #r category: 'colors' defaultValues: #() subCategory: #a7>
	^ aColor asHTMLColor
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> colorAtX: x y: y [
	<phratchItem: 'color of pixel x: $Number$ y: $Number$' kind: #g category: 'colors' defaultValues: #(0 0) subCategory:
		#a3>
	| frame w newX newY p |
	frame := self ownerThatIsA: PhratchFrameMorph.
	frame
		ifNil: [ 
			(w := self ownerThatIsA: OffscreenWorldMorph) ifNil: [ ^ self ].
			frame := w frame ].
	newX := x.
	newX isNaN
		ifTrue: [ newX := 0 ].
	newX := newX min: 240.
	newX := newX max: -240.
	newY := y.
	newY isNaN
		ifTrue: [ newY := 0 ].
	newY := newY max: -180.
	newY := newY min: 180.
	DoubleSize
		ifTrue: [ 
			newX := newX * 2.
			newY := newY * 2 ].
	p := newX @ newY negated.
	^ Display colorAt: PhratchOrigin + p
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> colorB: aColor [
	<phratchItem: '$Color$ blue' kind: #r category: 'colors' defaultValues: #() subCategory: #a4>
	^ aColor blue.
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> colorEffect [

	| att |
	att := #color.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ [filterPack hueShift] ifError: [0]
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> colorEffect: aNumber [

	self undeleteAttribute: #color.
	self passiveColorEffect: aNumber

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> colorG: aColor [
	<phratchItem: '$Color$ green' kind: #r category: 'colors' defaultValues: #() subCategory: #a4>
	^ aColor green.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> colorH: aColor [
	<phratchItem: '$Color$ hue' kind: #r category: 'colors' defaultValues: #() subCategory: #a5>
	^ aColor hue.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> colorH: h s: s v: v [
	<phratchItem: 'color h: $Number$ s: $Number$ b: $Number$' kind: #g category: 'colors' defaultValues: #(0 0 0) subCategory: #a5>
	^ (Color h: h s: s v: v).
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> colorNames [

	^ colors keys asArray sort.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> colorR: aColor [
	<phratchItem: '$Color$ red' kind: #r category: 'colors' defaultValues: #() subCategory: #a4>
	^ aColor red.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> colorR: r g: g b: b [
	"Answer the given color."

	<phratchItem: 'color r: $Number$ g: $Number$ b: $Number$' kind: #g category: 'colors' defaultValues: #(0 0 0) subCategory: #a4>
	^ (Color r: r g: g b: b).
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> colorS: aColor [
	<phratchItem: '$Color$ saturation' kind: #r category: 'colors' defaultValues: #() subCategory: #a5>
	^ aColor saturation.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> colorV: aColor [
	<phratchItem: '$Color$ brightness' kind: #r category: 'colors' defaultValues: #() subCategory: #a5>
	^ aColor brightness.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> colorsMenu [
	"Ask the user which user variable to show, then show it."

	| sFrame stage menu  |
	sFrame := self ownerThatIsA: PhratchFrameMorph.
	sFrame ifNil: [^ self].

	stage := sFrame workPane.

	menu := MenuMorphNG new.
	stage colorNames do: [:v | menu add: v value: v].
	self = stage ifFalse: [
		stage colorNames isEmpty ifFalse: [menu addLine].
		self colorNames do: [:v | menu add: v value: v]].
	menu invokeModal.
	^ menu
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> comeToFront [

	super comeToFront.
	self setLayerTo: 1
]

{ #category : #'other ops' }
ScriptablePhratchMorph >> computeFunction: functionName of: aNumber [
	"Return the result of computing the given mathematical function on the given number."
	<phratchItem: '$MathFunctions$ of $Number$' kind: #r category: 'operators' defaultValues: #('sqrt' 10) subCategory: #a9>
	'abs' = functionName ifTrue: [^ aNumber abs].
	'sqrt' = functionName ifTrue: [^ aNumber sqrt].
	'sin' = functionName ifTrue: [^ aNumber degreesToRadians sin].
	'cos' = functionName ifTrue: [^ aNumber degreesToRadians cos].
	'tan' = functionName ifTrue: [^ aNumber degreesToRadians tan].
	'asin' = functionName ifTrue: [^ (aNumber within: -1.0 and: 1.0) arcSin radiansToDegrees].
	'acos' = functionName ifTrue: [^ (aNumber within: -1.0 and: 1.0) arcCos radiansToDegrees].
	'atan' = functionName ifTrue: [^ aNumber arcTan radiansToDegrees].
	
	'ln' = functionName ifTrue: [^ aNumber ln].
	'log' = functionName ifTrue: [^ aNumber log].
	'e ^' = functionName ifTrue: [^ aNumber exp].
	'10 ^' = functionName ifTrue: [^ 10.0 raisedTo: aNumber].

	^ 0

]

{ #category : #'string ops' }
ScriptablePhratchMorph >> concatenate: arg1 with: arg2 [
	"Concatenate two strings. Arguments are converted to strings."
	<phratchItem: 'join $String$ $String$' kind: #r category: 'operators' defaultValues: #('hello ' 'world') subCategory: #a6>
	^ arg1 asString, arg2 asString

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> constantNames [
	"Answer the names of supported constants"

	^ #(
		'pi'
		'e'
		'newline'
		'tab')
]

{ #category : #'list ops' }
ScriptablePhratchMorph >> contentsOfList: listName [
	<phratchItem: '$List$' kind: #r category: 'list' defaultValues: #('a list') subCategory: #a1>
	| list |
	list := self listNamed: listName ifNone: [^ ''].
	^ list concatenatedLines

]

{ #category : #byob }
ScriptablePhratchMorph >> convertListVarReferencesToTuples [
	"format conventions:

		sprite:
					1 - #sprite
					2 - name

		stage:		#stage

		block: 
					1 - #block
					2 - receiver
					3 - tupleSequence

		named list reference:

					1 - #namedList
					2 - target obj name
					3 - list name

		variable-bound anonymous list reference:

					1 - #variableList
					2 - target obj name
					3 - var name

		anonymous list (either within a list or bound to a variable):

					converted to tuples in place"

	| obj ref rcvr |
	self varNames
		do: [ :varName | 
			obj := self getVar: varName.
			(obj isKindOf: BlockMorph)
				ifTrue: [ 
					rcvr := (obj receiver isKindOf: ScriptablePhratchMorph)
						ifTrue: [ 
							(obj receiver isKindOf: PhratchStageMorph)
								ifTrue: [ 'Stage' ]
								ifFalse: [ obj receiver objName ] ]
						ifFalse: [ '' ].
					vars at: varName put: (Array with: #block with: rcvr with: obj tupleSequence) ].
			(obj isKindOf: PhratchListMorph)
				ifTrue: [ 
					ref := obj asReferenceTuple.
					ref first = #variableList
						&
							({objName.
							'Stage'} includes: ref second) & (ref third = varName)
						ifTrue: [ obj convertStacksToTuples ]
						ifFalse: [ vars at: varName put: ref ] ].
			(obj isKindOf: ScriptablePhratchMorph)
				ifTrue: [ 
					ref := obj asReferenceTuple.
					vars at: varName put: ref ] ]
]

{ #category : #blocks }
ScriptablePhratchMorph >> convertStacksToTuples [
	"Convert my blocks bin from a morph containing block stack into a collection of (<point>, <tuple>) pairs the represent the same stacks in compact, language-independent form."

	| stacks blocks comments |
	(blocksBin isKindOf: Array) ifTrue: [^ self].  "already converted"

	self lists do: [:l | l convertStacksToTuples ].
	self convertListVarReferencesToTuples.

	stacks := (blocksBin submorphs select: [:m | m respondsTo: #tupleSequence]).
	blocks := stacks select: [:m | m isKindOf: BlockMorph].
	comments := stacks select: [:m | m isKindOf: PhratchCommentMorph].

	blocks := blocks collect: [:blockM | 
		Array
			with: blockM position - blocksBin position
			with: blockM tupleSequence].

	comments := comments collect: [:blockM |
		Array
			with: blockM position - blocksBin position
			with: blockM tupleSequence].

	blocksBin := blocks, comments.

	customBlocks ifNil: [^self].
	customBlocks do: [:eachDef|
		eachDef fixBlockVarReporters.
		eachDef body ifNotNil: [
			eachDef body: eachDef body tupleSequence ].
		eachDef answer ifNotNil: [
			(eachDef answer isKindOf: ReporterBlockMorph) 
				ifTrue:[	eachDef answer: eachDef answer tupleSequence ]]].


]

{ #category : #byob }
ScriptablePhratchMorph >> convertTuplesToDefinitions [

	customBlocks ifNil: [^ self].
	customBlocks do: [:eachDef |
		eachDef body ifNotNil: [ 
			(eachDef body isKindOf: Array) ifTrue: [
				eachDef body: (self stackFromTupleList: eachDef body receiver: self)]].
		eachDef answer ifNotNil: [ 
			(eachDef answer isKindOf: Array)
				ifTrue: [eachDef answer: (self stackFromTupleList: eachDef answer receiver: self)]].
		eachDef migrateBlockVars].

]

{ #category : #blocks }
ScriptablePhratchMorph >> convertTuplesToStacks [
	"Convert my blocks bin from a collection of (<point>, <tuple>) pairs into a morph containing a number of block stacks."

	| tuplesList stack |

	(blocksBin isKindOf: Array) ifFalse: [^ self].  "already converted"

	self lists do: [:l | l value convertTuplesToStacks ].
	self convertVarTuplesToListReferences.
	self convertTuplesToDefinitions.

	tuplesList := blocksBin.
	blocksBin := PhratchScriptsMorph new.
	tuplesList do: [:pair |
		stack := self stackFromTupleList: pair second receiver: self.
		stack position: pair first.
		blocksBin addMorph: stack].

	blocksBin allMorphsDo: [:m |
		(m isKindOf: AttributeArgMorph) ifTrue: [
			m refresh ]]


]

{ #category : #byob }
ScriptablePhratchMorph >> convertVarTuplesToListReferences [
	"format conventions:

		sprite:
					1 - #sprite
					2 - name

		stage:		#stage

		block: 
					1 - #block
					2 - receiver
					3 - tupleSequence

		named list reference:

					1 - #namedList
					2 - target obj name
					3 - list name

		variable-bound anonymous list reference:

					1 - #variableList
					2 - target obj name
					3 - var name

		anonymous list (either within a list or bound to a variable):

					converted to tuples in place"

	| obj rcvr stage block |
	self varNames
		do: [ :varName | 
			obj := self getVar: varName.
			(obj isKindOf: PhratchListMorph)
				ifTrue: [ obj convertTuplesToStacks ].
			(obj isKindOf: Array)
				ifTrue: [ 
					stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
					rcvr := obj second = 'Stage'
						ifTrue: [ stage ]
						ifFalse: [ stage coerceSpriteArg: obj second ].
					#block = obj first
						ifTrue: [ 
							block := stage stackFromTupleList: obj third receiver: rcvr.
							varName ifNotNil: [ vars at: varName put: block ] ].
					#namedList = obj first
						ifTrue: [ vars at: varName put: (stage listNamed: obj third targetName: obj second) ].
					#variableList = obj first
						ifTrue: [ vars at: varName put: (stage listInVarNamed: obj third targetName: obj second) ].
					#stage = obj first
						ifTrue: [ vars at: varName put: stage ].
					#sprite = obj first
						ifTrue: [ vars at: varName put: (stage coerceSpriteArg: obj second) ] ] ]
]

{ #category : #byob }
ScriptablePhratchMorph >> copyBlockDefinitionsFor: aSprite [
	"Answer a deep copy of my custom block definition list"

	|result|
	result := customBlocks deepCopy.
	result ifNil: [^nil].
	result do: [:def|
	 def body ifNotNil: [
			def body allMorphs do: [:m|
				((m isKindOf: BlockMorph) and: [
				m receiver = self]) ifTrue: [m receiver: aSprite]]]].
	^ result

]

{ #category : #private }
ScriptablePhratchMorph >> copyForExport [
	"Answer a copy of me for exporting."

	| objToExport |
	objToExport := self fullCopy.
	objToExport objName: objName.
	objToExport prepareForExport.
	^ objToExport

]

{ #category : #private }
ScriptablePhratchMorph >> copyListsFor: aSprite [
	"Answer a deep copy of my list variables dictionary."

	| result oldList copiedList |
	result := lists species new.
	lists associationsDo: [:assoc |
		oldList := assoc value.
		copiedList := PhratchListMorph new
			listName: oldList listName target: aSprite;
			newContents: oldList listContents;
		yourself.
		result at: assoc key put: copiedList].
	^ result


]

{ #category : #byob }
ScriptablePhratchMorph >> copyOfList: aList [
	<phratchItem: 'copy of $SAList$' kind: #r category: 'list' defaultValues: #() subCategory: #a7>
	aList ifNil: [^ PhratchListMorph on: #()].
	^ PhratchListMorph on: aList asArray

]

{ #category : #private }
ScriptablePhratchMorph >> copyRecordingIn: dict [
	"Copy my fields and scripts."

	| newCopy newBlocksBin |
	(self respondsTo: #sayNothing) ifTrue: [self sayNothing].  "remove talk bubble before copying"
	newCopy := super copyRecordingIn: dict.
	newCopy renewFilterPack.
	newBlocksBin := blocksBin fullCopy.
	newBlocksBin allMorphsDo: [:m |
		(m isKindOf: HatBlockMorph) ifTrue: [m scriptOwner: newCopy].
		(m isKindOf: CommandBlockMorph) ifTrue: [m mapReceiver: self to: newCopy]].
	newCopy vars: vars copy lists: (self copyListsFor: newCopy) blocksBin: newBlocksBin.
	newCopy blockDefinition: (self copyBlockDefinitionsFor: newCopy).
	newCopy objName: self nextInstanceName.
	newCopy setMedia: (media collect: [:el | el copy]).
	newCopy lookLike: costume mediaName.

	"for nested sprites:"
	(self isKindOf: PhratchSpriteMorph) ifTrue: [
		newCopy refPos: self referencePosition.
		newCopy privateSubsprites: (self subsprites collect: [:sub |
			(sub copyRecordingIn: dict)
				privateOwnerSprite: newCopy ])].

	^ newCopy

]

{ #category : #accessing }
ScriptablePhratchMorph >> costume [

	^ costume

]

{ #category : #accessing }
ScriptablePhratchMorph >> costumeChangeMSecs [
	"Answer the time of the last costume change. Whenever a costume change (or a filter change) occurs, this value is updated from the current millisecond clock. This value is used to optimize redrawing of thumbnails--if costumeChangeMSecs hasn't changed since the last time the thumbnail was updated we don't need to compute a new thumbnail."

	^ costumeChangeMSecs

]

{ #category : #private }
ScriptablePhratchMorph >> costumeChanged [

	costumeChangeMSecs := Time millisecondClockValue.
	filterPack ifNotNil: [filterPack clearFilterCaches].
	self layoutChanged.
	self keepOnScreen.

]

{ #category : #accessing }
ScriptablePhratchMorph >> costumeForm [
	"Answer my current costume form, without filtering, rotation or scaling. If my costume is a movie or animation, answer the appropriate frame."

	^ costume compositeForm

]

{ #category : #'looks ops' }
ScriptablePhratchMorph >> costumeFromName: aString [
	"If there is a costume by the given name, return it. Otherwise, return nil."

	| cameraCostume |
	((aString = '*** camera ***') and:
	 [CameraPlugin cameraIsAvailable]) ifTrue: [
		cameraCostume := CameraMedia new.
		(self class = PhratchStageMorph) ifTrue: [cameraCostume frameExtent: self extent].
		^ cameraCostume].

	^ media
		detect: [:el | el isSound not and: [el mediaName = aString or: [el mediaName = aString]]]
		ifNone: [nil]

]

{ #category : #'looks ops' }
ScriptablePhratchMorph >> costumeIndex [
	"Answer the index of my current costume."
	| att |
	att := #costumeIndex.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ (media reject: [:m | m isSound])
		indexOf: costume ifAbsent: [1]

]

{ #category : #'looks ops' }
ScriptablePhratchMorph >> costumeNameFromNumber: aNumber [
	"Return a costume name for the given number--rounded and modulo the number of costumes."

	| costumeList i |
	costumeList := media reject: [:m | m isSound].
	costumeList size = 0 ifTrue: [^ 'costume'].

	i := ((aNumber rounded - 1) \\ costumeList size) + 1.
	^ (costumeList at: i) mediaName

]

{ #category : #media }
ScriptablePhratchMorph >> costumeNames [
	"Answer a list of my costume (costume = non-sound media object) names."

	| result nm |
	result := OrderedCollection new.
	media do: [:el |
		el isSound ifFalse: [
			nm := el mediaName.
			(result includes: nm) ifFalse: [result add: nm]]].

	result := result asArray.
	CameraPlugin cameraIsAvailable ifTrue: [
		result := result copyWith: '*** camera ***'].
	^ result

]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> costumes [
	"this will at some future time answer first class costumes,
	for now it's just the costume names"

	^ PhratchListMorph on: ((media reject: [ :m | m isSound ]) collect: [ :c | c mediaName ])
]

{ #category : #blocks }
ScriptablePhratchMorph >> costumesPage: xOffset [
	"Answer a morph containing thumbnails of my costumes."

	| bin label m y images n recBut impBut photoBut maxHeight xMargin yMargin separator |
	xMargin := 15.
	yMargin := 15.
	bin := PhratchBlockPaletteMorph new color: PhratchFrameMorph scriptsPaneColor.
	label := (self isKindOf: PhratchStageMorph)
		ifTrue: [ 'New background:' localized ]
		ifFalse: [ 'New costume:' localized ].
	m := StringMorph contents: label font: (PhratchFrameMorph getFont: #CostumesPage).
	m color: Color white.
	bin addMorph: m.
	recBut := PhratchFrameMorph buttonLabel: 'Paint' localized selector: #drawNewCostume.
	recBut target: self.
	bin addMorph: recBut.
	impBut := PhratchFrameMorph buttonLabel: 'Import' localized selector: #importImage.
	impBut target: self.
	bin addMorph: impBut.
	photoBut := PhratchFrameMorph buttonLabel: 'Camera' localized selector: #takePhoto.
	photoBut target: self.
	bin addMorph: photoBut.
	maxHeight := m height max: (impBut height max: (recBut height max: photoBut height)).
	PhratchTranslator isRTL
		ifTrue: [ 
			photoBut position: xMargin @ (yMargin + ((maxHeight - photoBut height) / 2)).
			impBut position: (photoBut right + 4) @ (yMargin + ((maxHeight - impBut height) / 2)).
			recBut position: (impBut right + 4) @ (yMargin + ((maxHeight - recBut height) / 2)).
			m position: (recBut right + 4) @ (yMargin + ((maxHeight - m height) / 2)) ]
		ifFalse: [ 
			m position: xMargin @ (yMargin + ((maxHeight - m height) / 2)).
			recBut position: (m right + 4) @ (yMargin + ((maxHeight - recBut height) / 2)).
			impBut position: (recBut right + 4) @ (yMargin + ((maxHeight - impBut height) / 2)).
			photoBut position: (impBut right + 4) @ (yMargin + ((maxHeight - impBut height) / 2)) ].
	separator := TiledImageMorph new tileForm: (PhratchFrameMorph skinAt: #costumeSeparatorTile).
	bin addMorph: (separator position: (xOffset + 17) @ (yMargin + maxHeight + 5)).
	y := yMargin + maxHeight + 9.
	n := 0.
	images := media select: [ :item | item isImage ].
	images
		do: [ :item | 
			m := MediaItemMorph new.
			m
				phratchObj: self media: item;
				position: xOffset @ y.
			m setNumber: (n := n + 1).
			item = costume
				ifTrue: [ m highlight: true ].
			bin addMorph: m.
			y := y + m height - 1 ].
	bin submorphs size > 0
		ifTrue: [ separator width: bin firstSubmorph width - 14 ]
		ifFalse: [ separator width: 240 ].
	^ bin
]

{ #category : #blocks }
ScriptablePhratchMorph >> createBlock: block atPosition: pos onPage: page [
	"Creates a block on the given page. If the block is one that can become a watcher, then a toggle button is created as well."

	| x y changingX toggleButton yOffset frame |

	"don't create the following blocks, but keep their specs so they can be toggles using right / left arrows"

	((block respondsTo: #selector) and: [
	(#(	doRunBlockWithArgs 
		doRunBlockWithArgList
		doForkBlockWithArgs 
		doForkBlockWithArgList
		doCallBlockWithArgs 
		doCallBlockWithArgList
		functionWithArgs 
		procedureWithArgs) 
	includes: block selector)])
		ifTrue: [^pos y ].

	x := pos x.
	y := pos y.
	changingX := x.
	block canBecomeWatcher ifTrue: [
		toggleButton := self createToggleButtonFor: block.
		yOffset := (block fullBounds height - toggleButton fullBounds height) // 2.
		page addMorphBack: (toggleButton position: x@(y+yOffset)).
		changingX := x + toggleButton fullBounds width + 4].

	block fixBlockLayout; position: changingX@y.
	page addMorphBack: block.
	block canBecomeWatcher ifTrue: [
		frame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
		page updateWatcherButtonsForFrame: frame].

	((block respondsTo: #selector) and: [block selector = #newList:]) ifTrue: [
		block argMorphs first addArgSlot].

	^ y + block height + 3

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> createFile: aFileNameString [
	"Create the given file."
	<phratchItem: 'create file $String$' kind: #- category: 'files' defaultValues: #() subCategory: #a>
	| f |
	(self askForFileIO = true) ifFalse: [^ self].
	aFileNameString asFileReference delete.
	f := FileStream newFileNamed: aFileNameString.
	f close
]

{ #category : #'list ops' }
ScriptablePhratchMorph >> createListNamed: listName [

	| list stage n |
	(self variableNameInUse: listName) ifTrue: [
		Beeper beep.
		DialogBoxMorph warn: 'That variable name is already in use'.
		^ self].

	lists at: listName put: (list := PhratchListMorph new listName: listName target: self).
	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNotNil: [
		n := (stage submorphs select: [:m | m isKindOf: PhratchListMorph]) size.
		stage addMorph: (list position: stage topRight - ((list width + 10)@0) + (0@(10+(20*n)))).
		list startStepping].

]

{ #category : #blocks }
ScriptablePhratchMorph >> createToggleButtonFor: block [
	"Create the toggle button for each variable that could be viewed on the stage."

	| toggleButton |
	toggleButton := ToggleButton
		onForm: (PhratchFrameMorph skinAt: #watcherButtonPressed)
		offForm: (PhratchFrameMorph skinAt: #watcherButton).

	toggleButton
		target: block;
		actionSelector: #toggleWatcher;
		borderWidth: 0;
		setProperty: #balloonText toValue: 'View on stage' localized.

	^ toggleButton

]

{ #category : #byob }
ScriptablePhratchMorph >> customBlocks [
	^ customBlocks
]

{ #category : #byob }
ScriptablePhratchMorph >> customBlocksContaining: aBlock [
	"for error feedback"
	| def |
	customBlocks ifNil: [^Array empty].
	def := customBlocks detect: [ :each |
		each allBlocks includes: aBlock ] ifNone: [nil].
	def ifNil: [^Array empty].
	^self instancesOf: def id

]

{ #category : #blocks }
ScriptablePhratchMorph >> defaultArgsFor: blockSpec [
	"Answer the default argument for the given block specification."

	| defaultArgs stage sel currentSize list |
	defaultArgs := blockSpec copyFrom: 4 to: blockSpec size.	"may be empty"
	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	sel := (blockSpec at: 3) asSymbol.
	#gotoX:y: = sel
		ifTrue: [ defaultArgs := Array with: self referencePosition x rounded with: self referencePosition y rounded ].
	#glideSecs:toX:y:elapsed:from: = sel
		ifTrue: [ defaultArgs := Array with: 1 with: self referencePosition x rounded with: self referencePosition y rounded ].
	#setSizeTo: = sel
		ifTrue: [ 
			(self isKindOf: PhratchStageMorph)
				ifTrue: [ 
					"no size ops for stage -jens"
					^ Array with: 100 ].
			currentSize := (100.0 * (self scalePoint x max: self scalePoint y)) rounded.
			defaultArgs := Array with: currentSize ].
	#getAttribute:of: = sel
		ifTrue: [ 
			(stage := self ownerOrYourselfThatIsA: PhratchStageMorph)
				ifNotNil: [ 
					list := stage submorphs select: [ :m | m isKindOf: PhratchSpriteMorph ].
					list sort: [ :s1 :s2 | s1 objName asLowercase < s2 objName asLowercase ].
					defaultArgs := list size > 0
						ifTrue: [ Array with: 'x position' with: list first ]
						ifFalse: [ Array with: 'background #' with: stage ] ]
				ifNil: [ defaultArgs := Array with: 'x position' with: self ] ].
	#concatenate:with: = sel
		ifTrue: [ defaultArgs := Array with: 'hello ' localized with: 'world' localized ].
	#doAsk = sel
		ifTrue: [ defaultArgs := Array with: 'What''s your name?' localized ].
	#letter:of: = sel
		ifTrue: [ defaultArgs := Array with: 1 with: 'world' localized ].
	#stringLength: = sel
		ifTrue: [ defaultArgs := Array with: 'world' localized ].
	#say:duration:elapsed:from: = sel
		ifTrue: [ defaultArgs := Array with: 'Hello!' localized with: 2 ].
	#say: = sel
		ifTrue: [ defaultArgs := Array with: 'Hello!' localized ].
	#think:duration:elapsed:from: = sel
		ifTrue: [ defaultArgs := Array with: 'Hmm...' localized with: 2 ].
	#think: = sel
		ifTrue: [ defaultArgs := Array with: 'Hmm...' localized ].
	(#(#lookLike: #showBackground:) includes: sel)
		ifTrue: [ defaultArgs := Array with: self costumeNames last ].
	(#(#playSound: #doPlaySoundAndWait) includes: sel)
		ifTrue: [ 
			list := self soundNames.
			defaultArgs := list size <= 2
				ifTrue: [ Array with: '' ]
				ifFalse: [ Array with: (list at: list size - 2) ] ].
	(#(#broadcast: #doBroadcastAndWait) includes: sel)
		ifTrue: [ stage ifNotNil: [ defaultArgs := Array with: stage defaultEventName ] ].
	(#(#append:toList: #deleteLine:ofList: #insert:at:ofList:) includes: sel)
		ifTrue: [ 
			defaultArgs size >= 1
				ifTrue: [ defaultArgs at: 1 put: (defaultArgs at: 1) localized ] ].
	(#(#append:toList: #deleteLine:ofList: #getLine:ofList: #insert:at:ofList: #lineCountOfList: #contentsOfList:)
		includes: sel)
		ifTrue: [ defaultArgs := defaultArgs copyWith: self defaultListName ].
	#setLine:ofList:to: = sel
		ifTrue: [ 
			defaultArgs size >= 3
				ifTrue: [ 
					defaultArgs at: 2 put: self defaultListName.
					defaultArgs at: 3 put: (defaultArgs at: 3) localized ] ].
	#appendLettersOf:toList: = sel
		ifTrue: [ 
			defaultArgs size >= 2
				ifTrue: [ 
					defaultArgs at: 1 put: (defaultArgs at: 1) localized.
					defaultArgs at: 2 put: self defaultListName ] ].
	#list:contains: = sel
		ifTrue: [ 
			defaultArgs size >= 2
				ifTrue: [ 
					defaultArgs at: 1 put: self defaultListName.
					defaultArgs at: 2 put: (defaultArgs at: 2) localized ] ].
	^ defaultArgs
]

{ #category : #media }
ScriptablePhratchMorph >> defaultImageMedia [
	"Placeholder image media."

	^ ImageMedia new
		form: (Form extent: 8@8 depth: 8) fillWhite;
		mediaName: ('costume' localized, '1');
		yourself

]

{ #category : #'list ops' }
ScriptablePhratchMorph >> defaultListName [

	| stage |
	lists size > 0 ifTrue: [^ lists keys asArray sort first].

	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNotNil: [
		stage lists size > 0 ifTrue: [^ stage lists keys asArray sort first]].

	^ ''

]

{ #category : #byob }
ScriptablePhratchMorph >> definitionFor: anId [

	| all inherited def |
	inherited := self inheritedBlocks.
	customBlocks ifNil: [customBlocks := OrderedCollection new].
	all := inherited, customBlocks.
	def := all reversed detect: [:eachDef|
		eachDef id = anId]
		ifNone: [^nil].
	(def body isKindOf: BlockMorph) ifTrue: [
		def body newScriptOwnerPrivate: self].
	^ def
]

{ #category : #'BYOB object interface' }
ScriptablePhratchMorph >> deleteAttribute: aSymbol [

	| cat sf oi block w |
	self prototype ifNil: [
		^ self error: 'cannot delete attribute without prototype'].

	oi := self objectInterface.
	((oi at: aSymbol) at: 5) = #- ifTrue: [
		^ self error: 'undeletable attribute'].

	"special case for media"
	(#(costumes sounds) includes: aSymbol) ifFalse: [
		self perform: (oi at: aSymbol) third with: (self prototype perform: (oi at: aSymbol) second)].

	deletedAttributes ifNil: [
		deletedAttributes := Set new].
	deletedAttributes add: aSymbol.

	#costumes = aSymbol ifTrue: [
		self inheritCostumesNow].

	"update palette"

	sf := self phratchFrame.
	sf ifNil: [^ self].
	cat := (oi at: aSymbol) first.
	sf viewerPane categoryChanged: cat.

	"update watchers"

	block := self blockForSelector: ((oi at: aSymbol) second).

	block ifNil: [^ self].
	w := sf watcherForBlock: block.
	w ifNil: [^ self].
	w setCategoryColor: block color twiceLighter.
	
]

{ #category : #'BYOB object interface' }
ScriptablePhratchMorph >> deleteAttributes: aCollection [

	"use this when duplicating a sprite"

	self undeleteAllAttributes.
	aCollection do:[:attrib |
		self deleteAttribute: attrib ]	
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> deleteColor [
	"Ask the user which user variable to delete, then remove it."

	| sFrame stage menu choice |
	sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	sFrame ifNil: [^ self].

	stage := sFrame workPane.
	(stage colorNames isEmpty) & (self colorNames isEmpty)
		ifTrue: [^ self inform: 'No colors.' localized].

	menu := MenuMorphNG new.
	stage colorNames do: [:v | menu add: v value: (Array with: v with: #global)].
	self = stage ifFalse: [
		stage colorNames isEmpty ifFalse: [menu addLine].
		self colorNames do: [:v | menu add: v value: (Array with: v with: #local)]].
	choice := menu invokeModal; selectedValue;
		yourself.
	choice ifNil: [^ self].

	choice second = #global
		ifTrue: [stage deleteColor: choice first]
		ifFalse: [self deleteColor: choice first].

	sFrame viewerPane categoryChanged: 'colors'.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> deleteColor: colorName [
	"Delete the variable with the given name. Do nothing if the variable doesn't exist."

	| frame |
	colors removeKey: colorName asString ifAbsent: [^ self].
	(frame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [frame := (self ownerOrYourselfThatIsA: OffscreenWorldMorph) frame].
	frame deleteWatchersForVar: colorName ofSprite: self.
	frame viewerPane categoryChanged: 'colors'.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> deleteColorFull: colorName [
	"Delete the color variable with the given name. Do nothing if the variable doesn't exist."
	<phratchItem: 'delete color $String$' kind: #- category: 'colors' defaultValues: #('a color') subCategory: #a3>
	| frame stage |
	(colors includesKey: colorName) ifTrue: [self deleteColor: colorName].
	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	(stage notNil and: [stage colorNames includes: colorName]) ifTrue: [stage deleteColor: colorName].
	(frame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ self].
	frame viewerPane categoryChanged: 'colors'.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> deleteCostumeAt: index [
	"Delete the costume at the given index."

	| cList |
	cList := media reject: [:m | m isSound].

	self deleteMedia: (cList at: index).
]

{ #category : #byob }
ScriptablePhratchMorph >> deleteDefinitionId: id [

	| stage def |
	def := self definitionFor: id.
	def isGlobal  ifFalse: [
		^ self deleteLocalDefinitionId: id].

	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	stage ifNil: [^ self deleteLocalDefinitionId: id].

	stage sprites, {stage} do: [:obj |
		obj deleteLocalDefinitionId: id]
	
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> deleteFile: aFileNameString [
	"Create the given file."
	<phratchItem: 'delete file $String$' kind: #- category: 'files' defaultValues: #() subCategory: #a>
	(self askForFileIO = true) ifFalse: [^ self].
	aFileNameString asFileReference delete.
]

{ #category : #'list ops' }
ScriptablePhratchMorph >> deleteLine: lineNum ofList: listName [
	<phratchItem: 'delete $ListDelete$ of $List$' kind: #- category: 'list' defaultValues: #(1) subCategory: #a4>
	| list |
	list := self listNamed: listName ifNone: [^ self].
	lineNum = 'all' ifTrue: [list clear. ^ self].
	list deleteLineAt: (self lineNum: lineNum forList: list)

]

{ #category : #'list ops' }
ScriptablePhratchMorph >> deleteList [
	"Ask the user which list variable to delete, then remove it."

	| sFrame stage menu |
	sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	sFrame ifNil: [^ self].

	stage := sFrame workPane.
	(stage listVarNames isEmpty) & (self listVarNames isEmpty)
		ifTrue: [^ self inform: 'No lists.' localized].

	menu := MenuMorph new defaultTarget: self.
	stage listVarNames do: [:v | menu add: v target: stage selector: #deleteList: argument: v].
	self = stage ifFalse: [
		stage listVarNames isEmpty ifFalse: [menu addLine].
		self listVarNames do: [:v | menu add: v target: self selector: #deleteList: argument: v]].
	menu invokeModal.
	

	sFrame viewerPane categoryChanged: 'variables'.

]

{ #category : #'list ops' }
ScriptablePhratchMorph >> deleteList: listName [
	"Delete the list variable with the given name. Do nothing if the variable doesn't exist."
	<phratchItem: 'delete list $String$' kind: #- category: 'list' defaultValues: #('a list') subCategory: #a2>
	| stage sFrame |
	(sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ Beeper beep].
	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	lists removeKey: listName asString ifAbsent: [].
	(self prototype notNil and: [self prototype lists includesKey: listName]) ifFalse: [ 
	stage submorphs do: [:m |
		((m isKindOf: PhratchListMorph) and: 
		[(m listName = listName) and: 
		[m target = self]])
			ifTrue: [m delete]]].
	sFrame viewerPane categoryChanged: 'variables'.

]

{ #category : #byob }
ScriptablePhratchMorph >> deleteLocalDefinitionId: id [
	| affected sf def cat |
	sf := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	sf ifNil: [^self].
	sf notEditingBlock ifFalse: [^self].
	affected := self instancesOf: id.
	def := self definitionFor: id.
	def ifNil: [^ self].
	cat := def category.
	customBlocks remove: def ifAbsent: [].
	((self inheritedBlocks collect: [:b |
		b id]) includes: id) ifFalse: [
		affected do: [:eachBlock|
			eachBlock remove]].
	sf viewerPane categoryChanged: 'variables'.
	#none = cat ifFalse: [
		sf viewerPane categoryChanged: cat asString]
]

{ #category : #media }
ScriptablePhratchMorph >> deleteMedia: itemToDelete [
	"Delete the given media item."

	| oldIndex costumesBefore costumesAfter newCostume |
	oldIndex := media indexOf: itemToDelete.
	media remove: itemToDelete ifAbsent: [  ].
	itemToDelete isSound
		ifTrue: [ itemToDelete sound pause ].
	itemToDelete == costume
		ifTrue: [ 
			"select the costume just before or after the costume being deleted"
			costumesBefore := (media copyFrom: 1 to: oldIndex - 1) reject: [ :item | item isSound ].
			costumesAfter := (media copyFrom: oldIndex to: media size) reject: [ :item | item isSound ].
			costumesBefore size > 0
				ifTrue: [ newCostume := costumesBefore last ]
				ifFalse: [ 
					costumesAfter size > 0
						ifTrue: [ newCostume := costumesAfter first ]
						ifFalse: [ media addLast: (newCostume := itemToDelete) ] ].
			self lookLike: newCostume mediaName ].
	self updateMediaCategory.
	itemToDelete isSound
		ifTrue: [ 
			self undeleteAttribute: #sounds.
			self propagateSounds ]
		ifFalse: [ 
			self undeleteAttribute: #costumes.
			self propagateCostumes ]
]

{ #category : #'BYOB object interface' }
ScriptablePhratchMorph >> deleteObject: anObject [
	<phratchItem: 'delete $OSReporter$' kind: #- category: 'variables' defaultValues: #() subCategory: #a2>
	| oi obj att block sel rcv |
	(anObject isKindOf: PhratchSpriteMorph)
		ifTrue: [ ^ self deleteSprite: anObject ].
	(anObject isKindOf: CommandScriptBlockMorph)
		ifTrue: [ 
			oi := self objectInterface.
			obj := anObject receiver.
			(obj isKindOf: PhratchSpriteMorph)
				ifFalse: [ ^ self error: 'cannot delete attributes of non-Sprites' ].
			block := anObject body argMorphs first.
			(block isKindOf: VariableBlockMorph)
				ifTrue: [ 
					rcv := block receiver.
					rcv ifNil: [ ^ self ].
					^ rcv deleteVariable: block variable ].
			sel := block selector = #get:
				ifTrue: [ (oi at: block argMorphs first choice) second ]
				ifFalse: [ block selector ].
			att := oi keys
				detect: [ :key | (oi at: key) second = sel ]
				ifNone: [ ^ self error: 'no attribute found for selector: ' , anObject selector ].
			^ obj deleteAttribute: att ].
	self error: 'cannot delete this'
]

{ #category : #private }
ScriptablePhratchMorph >> deleteSprite [
	"Delete the sprite and all watchers that are associated with it."

	| frame sprites i presenter instances |
	frame := self ownerOrYourselfThatIsA: PhratchFrameMorph. 
	frame ifNil: [
		presenter := World findA: PhratchPresenterMorph.
		presenter ifNil: [^ self delete].
		frame := presenter frame].

	frame deleteWatchersForSprite: self.
	instances := self instances.

	frame workPane updateSpritesList.
	sprites := frame workPane sprites.
	i := sprites indexOf: self.  "remember my index"
	sprites remove: self ifAbsent: [].

	self delete.
	instances do: [:each |
		each prototype: nil].

	frame libraryPane fixLayout.

	"delete my thumbnail, and re-focus on the thumbnail right after me or the stage if there are no sprites"
	i > sprites size ifTrue: [i := i - 1].
	i < 1 
		ifTrue: [frame view: frame workPane tab: 'Scripts' category: 'motion'] 
		ifFalse: [frame view: (sprites at: i) tab: 'Scripts' category: 'motion'].	

]

{ #category : #'byob OOP' }
ScriptablePhratchMorph >> deleteSprite: aSprite [
	aSprite deleteSpriteQuickly.

	"now the deleted sprite has to be removed from all variables
	and lists - not sure how to accomplish this"
]

{ #category : #'BYOB object interface' }
ScriptablePhratchMorph >> deleteSpriteObj: anObject [
	<phratchItem: 'delete $Sprite$' kind: #- category: 'operators' defaultValues: #() subCategory: #b3>
	self deleteObject: anObject
]

{ #category : #'byob OOP' }
ScriptablePhratchMorph >> deleteSpriteQuickly [
	"Delete the sprite and all watchers that are associated with it."

	| frame sprites presenter instances |
	frame := self ownerOrYourselfThatIsA: PhratchFrameMorph. 
	frame ifNil: [
		presenter := World findA: PhratchPresenterMorph.
		presenter ifNil: [^ self delete].
		frame := presenter frame].

	frame deleteWatchersForSprite: self.
	instances := self instances.

	frame workPane updateSpritesList.
	sprites := frame workPane sprites.
	sprites remove: self ifAbsent: [].

	self delete.
	instances do: [:each |
		each undeleteAllAttributes.
		each undeleteAllVariables.
		each prototype: nil].

	frame libraryPane fixLayout.

	"delete my thumbnail, and re-focus on the thumbnail right after me or the stage if there are no sprites"

	frame view: frame workPane tab: 'Scripts' category: 'motion'
"
	i > sprites size ifTrue: [i := i - 1].
	i < 1 
		ifTrue: [frame view: frame workPane tab: 'Scripts' category: 'motion'] 
		ifFalse: [frame view: (sprites at: i) tab: 'Scripts' category: 'motion'].	
"
]

{ #category : #variables }
ScriptablePhratchMorph >> deleteVariable [
	"Ask the user which user variable to delete, then remove it."

	| sFrame stage menu |
	sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	sFrame ifNil: [^ self].

	stage := sFrame workPane.
	(stage varNames isEmpty) & (self varNames isEmpty)
		ifTrue: [^ self inform: 'No variables.' localized].

	menu := MenuMorph new defaultTarget: self.
	stage varNames do: [:v | menu add: v target: stage selector: #deleteVariable: argument: v].
	self = stage ifFalse: [
		stage varNames isEmpty ifFalse: [menu addLine].
		self varNames do: [:v | menu add: v target: self selector: #deleteVariable: argument: v]].
	menu invokeModal.

	sFrame viewerPane categoryChanged: 'variables'.

]

{ #category : #variables }
ScriptablePhratchMorph >> deleteVariable: varName [
	"Delete the variable with the given name. Do nothing if the variable doesn't exist."

	| frame w |
	frame := self phratchFrame.
	frame ifNotNil: [
		(self prototype notNil and: [self prototype varNames includes: varName]) ifFalse: [
			frame deleteWatchersForVar: varName ofSprite: self]].
	vars removeKey: varName asString ifAbsent: [^ self].
	frame viewerPane categoryChanged: 'variables'.
	w := frame watcherForBlock: (VariableBlockMorph new receiver: self; commandSpec: varName; yourself).
	w ifNotNil: [w setCategoryColor: (ScriptablePhratchMorph blockColorFor: 'variables') twiceLighter].
	self isClone: false.

]

{ #category : #'BYOB object interface' }
ScriptablePhratchMorph >> deletedAttributes [
	^ deletedAttributes ifNil: [ 
		deletedAttributes := Set new]
]

{ #category : #variables }
ScriptablePhratchMorph >> desparatelyGetVar: varName from: aVarBlockMorph [

	| anotherReceiver |
	anotherReceiver := aVarBlockMorph phratchObject.
	anotherReceiver ifNil: [^ 0].
	(anotherReceiver varNames includes: varName)	ifFalse: [
		anotherReceiver := anotherReceiver ownerOrYourselfThatIsA: PhratchStageMorph.
		anotherReceiver ifNil: [^ 0].
		(anotherReceiver varNames includes: varName) ifFalse: [
			^ 0]].
	aVarBlockMorph receiver: anotherReceiver.
	^ anotherReceiver getVar: varName
		
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> doAnswer [
"Answer the first string if the given condition is true, otherwise answer the second."
	<phratchItem: 'report $String$' kind: #s category: 'control' defaultValues: #() subCategory: #process>

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> doAsk [
	<phratchItem: 'ask $String$ and wait' kind: #s category: 'sensing' defaultValues: #('What''s your name?') subCategory: #a1>
	
]

{ #category : #byob }
ScriptablePhratchMorph >> doBroadcastAndWait [
	<phratchItem: 'broadcast $Event$ and wait' kind: #s category: 'control' defaultValues: #() subCategory: #broadcast>
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> doCallBlockWithArgList [
"Answer the first string if the given condition is true, otherwise answer the second."
	<phratchItem: 'call $OSReporter$ $Input$ $SAList$' kind: #d category: 'control' defaultValues: #() subCategory: #process>

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> doCallBlockWithArgs [
"Answer the first string if the given condition is true, otherwise answer the second."
	<phratchItem: 'call $OSReporter$ $Input$ $String$' kind: #d category: 'control' defaultValues: #() subCategory: #process>

]

{ #category : #byob }
ScriptablePhratchMorph >> doForever [
	<phratchItem: 'forever' kind: #c category: 'control' defaultValues: #() subCategory: #loop>
]

{ #category : #byob }
ScriptablePhratchMorph >> doForeverIf [
	<phratchItem: 'forever if $Boolean$' kind: #c category: 'control' defaultValues: #() subCategory: #loop>
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> doFork [
"Answer the first string if the given condition is true, otherwise answer the second."
	<phratchItem: 'launch $CSlot$' kind: #u category: 'control' defaultValues: #() subCategory: #process>

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> doForkBlockWithArgList [
"Answer the first string if the given condition is true, otherwise answer the second."
	<phratchItem: 'launch $CSlot$ $Input$ $SAList$' kind: #u category: 'control' defaultValues: #() subCategory: #process>

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> doForkBlockWithArgs [
"Answer the first string if the given condition is true, otherwise answer the second."
	<phratchItem: 'launch $CSlot$ $Input$ $String$' kind: #u category: 'control' defaultValues: #() subCategory: #process>

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> doIf [
"Answer the first string if the given condition is true, otherwise answer the second."
	<phratchItem: 'if $Boolean$' kind: #c category: 'control' defaultValues: #() subCategory: #if>

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> doIfElse [
"Answer the first string if the given condition is true, otherwise answer the second."
	<phratchItem: 'if $Boolean$' kind: #c category: 'control' defaultValues: #() subCategory: #if>

]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> doPlaySoundAndWait [
	<phratchItem: 'play sound $SoundNames$ until done' kind: #s category: 'sound' defaultValues: #() subCategory: #a1>
]

{ #category : #byob }
ScriptablePhratchMorph >> doRepeat [
	<phratchItem: 'repeat $Number$ times' kind: #c category: 'control' defaultValues: #(10) subCategory: #loop>
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> doReport [
"Answer the first string if the given condition is true, otherwise answer the second."
	<phratchItem: 'call $OSReporter$' kind: #d category: 'control' defaultValues: #() subCategory: #process>

]

{ #category : #byob }
ScriptablePhratchMorph >> doReturn [
	<phratchItem: 'stop script' kind: #s category: 'control' defaultValues: #() subCategory: #loop>
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> doRun [
"Answer the first string if the given condition is true, otherwise answer the second."
	<phratchItem: 'run $CSlot$' kind: #u category: 'control' defaultValues: #() subCategory: #process>

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> doRunBlockWithArgList [
"Answer the first string if the given condition is true, otherwise answer the second."
	<phratchItem: 'run $CSlot$ $Input$ $SAList$' kind: #u category: 'control' defaultValues: #() subCategory: #process>

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> doRunBlockWithArgs [
"Answer the first string if the given condition is true, otherwise answer the second."
	<phratchItem: 'run $CSlot$ $Input$ $String$' kind: #u category: 'control' defaultValues: #() subCategory: #process>

]

{ #category : #'other ops' }
ScriptablePhratchMorph >> doStopBlock [
	"Stop everything!"
	<phratchItem: 'stop block' kind: #s category: 'control' defaultValues: #() subCategory: #startstop>
	
]

{ #category : #byob }
ScriptablePhratchMorph >> doUntil [
	<phratchItem: 'repeat until $Boolean$' kind: #c category: 'control' defaultValues: #(10) subCategory: #loop>
]

{ #category : #'other ops' }
ScriptablePhratchMorph >> doWaitUntil [
	"Do nothing; just wait for the time interval to elapse."
	<phratchItem: 'wait until $Boolean$' kind: #s category: 'control' defaultValues: #() subCategory: #time>
	^ nil

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> doWithCamOpen [
	<phratchItem: 'do with camera open' kind: #c category: 'looks' defaultValues: #() subCategory: #a9>
	
]

{ #category : #'event handling' }
ScriptablePhratchMorph >> doubleClick: evt [
	"Show my viewer and script editor."
	
	| hand |
	hand := self world activeHand.
	hand toolType ifNotNil: [
		^ self handleTool: hand toolType hand: hand].

	self viewBlocksAndScripts.

]

{ #category : #media }
ScriptablePhratchMorph >> drawNewCostume [

	| oldCostumeName newName newImage |
	oldCostumeName := costume mediaName.
	newImage := ImageMedia new form: (Form extent:  4@4 depth: 8).
	newName := (self unusedMediaNameFromBaseName: self defaultImageMedia mediaName).
 	newImage mediaName: newName.
	media addLast: newImage.
	self updateMediaCategory.
	self lookLike: newImage mediaName.
	self editDrawingOldCostumeName: oldCostumeName deleteOnCancel: false.
	
	self undeleteAttribute: #costumes.
	
	self propagateCostumes


]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> drum: midiKey duration: beats elapsed: elapsedMSecs from: aNotePlayer [
	<phratchItem: 'play drum $Drums$ for $Number$ beats' kind: #t category: 'sound' defaultValues: #(48 0.2) subCategory: #a2>
	| stage player |
	aNotePlayer ifNil: [  "first call, start playing the drum"
		(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNil: [^ PhratchNotePlayer new].
		(player := stage notePlayerFor: self) ifNil: [^ PhratchNotePlayer new].
		^ player copy drumOn: midiKey].

	elapsedMSecs >= ((60000 * beats) // self tempo) ifTrue: [aNotePlayer drumOff].

]

{ #category : #scripts }
ScriptablePhratchMorph >> duplicate [

	| newSprite s |
	newSprite := self duplicateNoAttach.
	self world activeHand attachMorph: newSprite.

	((s := self ownerOrYourselfThatIsA: PhratchStageMorph) notNil and:
	 [s isQuarterSize]) ifTrue: [
		self world activeHand drawHalfSize: true].

	^ newSprite

]

{ #category : #media }
ScriptablePhratchMorph >> duplicateMedia: itemToDuplicate [
	"Duplicate the given media item."

	| dup |
	itemToDuplicate isSound ifTrue: [itemToDuplicate pausePlaying].
	dup := itemToDuplicate copy.
	dup mediaName: (self unusedMediaNameFromBaseName: itemToDuplicate mediaName).
	media addLast: dup.
	self updateMediaCategory.

	itemToDuplicate isSound 
		ifTrue: [
			self undeleteAttribute: #sounds.
			self propagateSounds]
		ifFalse: [
			self undeleteAttribute: #costumes.
			self propagateCostumes]
]

{ #category : #'right button menu' }
ScriptablePhratchMorph >> duplicateNoAttach [
	"Duplicate this sprite, but do not attach to the hand."

	| newSprite frame |
	newSprite := self fullCopy.
	newSprite undeleteAllAttributes.
	newSprite unhinge; unhingeAll; initializeNodes.
	newSprite position: (newSprite position + 20).
	frame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	frame ifNotNil: [
		frame workPane addMorphFront: newSprite.
		frame workPane sprites addLast: newSprite].
	^ newSprite

]

{ #category : #'right button menu' }
ScriptablePhratchMorph >> editDrawing [
	"Edit my current form with the paint editor."

	self editDrawingOldCostumeName: nil deleteOnCancel: false.

]

{ #category : #'right button menu' }
ScriptablePhratchMorph >> editDrawingOldCostumeName: oldCostumeName deleteOnCancel: aBoolean [
	"Edit my original form with the paint editor."

	| sFrame paintEditor |
	costume isMovie ifTrue: [^ Beeper beep].
	(sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph)
		ifNotNil: [
			sFrame paintingInProgress ifTrue: [^ Beeper beep].
			sFrame stopAll.
			sFrame paintingInProgress: true].

	paintEditor := PaintFrame new.
	paintEditor
		withStartingObject: self;
		phratchFrame: sFrame;
		oldCostumeName: oldCostumeName deleteOnCancel: aBoolean.

	oldCostumeName ifNotNil: [
		"When an oldCostumeName is supplied, it means I'm making a new drawing. Clear the initial rotation center."
		paintEditor clearRotationCenter].

	(paintEditor isKindOf: DialogBoxMorph)
		ifTrue: [paintEditor getUserResponse]
		ifFalse: [
			World addMorphFront: paintEditor.
			World startSteppingSubmorphsOf: paintEditor].

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> editDrawingOldCostumeName: oldCostumeName deleteOnCancel: aBoolean deleteCostume: delCost [
	"Edit my original form with the paint editor."

	| sFrame paintEditor |
	costume isMovie ifTrue: [^ Beeper beep].
	(sFrame := self ownerThatIsA: PhratchFrameMorph) ifNil: [(sFrame := (self ownerThatIsA: OffscreenWorldMorph) frame) ifNil: [^ self]].

	sFrame paintingInProgress ifTrue: [^ Beeper beep].
	"sFrame stopAll."
	sFrame paintingInProgress: true.

	paintEditor := PaintFrame new.
	paintEditor
		withStartingObject: self;
		phratchFrame: sFrame;
		oldCostumeName: oldCostumeName deleteOnCancel: aBoolean;
		deleteCostumeOnCancel: delCost.

	oldCostumeName ifNotNil: [
		"When an oldCostumeName is supplied, it means I'm making a new drawing. Clear the initial rotation center."
		paintEditor clearRotationCenter].

	(paintEditor isKindOf: DialogBoxMorph)
		ifTrue: [paintEditor getUserResponse]
		ifFalse: [
			World addMorphFront: paintEditor.
			World startSteppingSubmorphsOf: paintEditor].

]

{ #category : #byob }
ScriptablePhratchMorph >> editScriptId: id [
	|sf def|

	sf := self ownerOrYourselfThatIsA: PhratchFrameMorph.
"	sf ifNil: [^self]."
	def := self definitionFor: id.
"	def ifNil: [^self]."
	sf editBlockDefinition: def for: self
]

{ #category : #byob }
ScriptablePhratchMorph >> editSpecId: id [
	"let the user change the category (color) of a custom block"

	| stage ans def sf bd oldCat inst newType |
	sf := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	sf ifNil: [ ^ self ].
	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	def := self definitionFor: id.
	newType := def type.
	BlockDialog isOpen
		ifTrue: [ ^ self ].
	bd := BlockDialog new.
	bd
		title: '?' translated;
		withButtonsForYes: false
			no: false
			okay: true
			cancel: true;
		message: 'Custom block category';
		setUserSpec: def userSpec;
		setCategory: def category;
		setType: def type;
		updateTypeSelection.
	inst := self instancesOf: id.
	def isGlobal
		ifTrue: [ 
			inst := OrderedCollection new.
			stage isNil
				ifFalse: [ stage sprites , {stage} do: [ :obj | inst addAll: (obj instancesOf: id) ] ] ].
	inst isEmpty
		ifTrue: [ bd disableAllButCategoryAndShape ]
		ifFalse: [ bd disableAllButCategory ].
	bd updateInitialSettings.
	ans := bd getUserResponse.
	ans = #cancelled
		ifTrue: [ ^ self ].
	ans first isEmpty
		ifTrue: [ ^ self ].
	((self existsBlockId: (CustomBlockDefinition idFromSpec: ans first)) and: [ def userSpec ~= ans first ])
		ifTrue: [ ^ DialogBoxMorph warn: 'a custom block with this label already exists' localized ].
	(def varNames includesAnyOf: (def parameterNamesInSpec: ans first))
		ifTrue: [ ^ DialogBoxMorph warn: 'a block variable with the same name as a parameter already exists' ].
	ans = def userSpec
		ifTrue: [ ^ self ].
	ans isEmpty
		ifTrue: [ ^ self ].
	(self existsBlockId: (CustomBlockDefinition idFromSpec: ans))
		ifTrue: [ ^ DialogBoxMorph warn: 'a custom block with this label already exists' ].
	(def varNames includesAnyOf: (def parameterNamesInSpec: ans first))
		ifTrue: [ ^ DialogBoxMorph warn: 'a block variable with the same name as a parameter already exists' ].
	inst isEmpty
		ifTrue: [ 
			newType := (ans at: 2)
				ifTrue: [ 
					(ans at: 3)
						ifTrue: [ #boolean ]
						ifFalse: [ #any ] ]
				ifFalse: [ #none ] ].
	def type = newType
		ifFalse: [ def type: newType ].
	oldCat := def category.
	def
		category:
			(ans fourth = #other
				ifTrue: [ #none ]
				ifFalse: [ ans fourth ]).
	#none = oldCat
		ifFalse: [ sf viewerPane categoryChanged: oldCat asString ].
	def isGlobal
		ifFalse: [ ^ self updateLocalId: id withSpec: ans first ].
	stage ifNil: [ ^ self updateId: id withSpec: ans first ].
	stage sprites , {stage}
		do: [ :obj | 
			obj
				updateCustomBlockDefinitionId: id with: def;
				updateLocalId: id withSpec: ans first ]
]

{ #category : #media }
ScriptablePhratchMorph >> editedForm: aForm textBox: aMultilineTextMorph [

	| newImage |
	(costume isKindOf: ImageMedia) ifFalse: [
		newImage := ImageMedia new
			form: aForm;
			mediaName: (self unusedMediaNameFromBaseName: costume mediaName);
		yourself.
		media addLast: newImage.
		self lookLike: newImage mediaName].

	costume form: aForm.  "replace the current costume"
	costume textBox: aMultilineTextMorph.
	self lookLike: costume mediaName.
	self viewBlocksAndScripts.
	self updateMediaCategory.

	self undeleteAttribute: #costumes.
	self propagateCostumes


]

{ #category : #byob }
ScriptablePhratchMorph >> ensureCustomBlockExists: aBlockDef [

	| def bod |
 	aBlockDef ifNil: [^ self].
	(self definitionFor: aBlockDef id) ifNil: [
		def := aBlockDef "deepCopy" veryDeepCopy.
		customBlocks add: def.
		bod := aBlockDef body.
		bod ifNotNil: [def body: (bod fullCopy newScriptOwner: self) ]]
]

{ #category : #byob }
ScriptablePhratchMorph >> ensureCustomBlockExists: aBlockDef global: bool [

	| stage |

	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.

	(bool = false or: [stage isNil]) ifTrue: [
		^ self ensureCustomBlockExists: aBlockDef].

	stage sprites, {stage} do: [:obj |
		obj ensureCustomBlockExists: aBlockDef]
	
]

{ #category : #variables }
ScriptablePhratchMorph >> ensureListExists: listName [
	"If a list with the given name is not visible to this object, make one."

	| stage |

	listName = '' ifTrue: [^ self].

	(lists includesKey: listName) ifTrue: [^ self].
	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNotNil: [
		(stage listVarNames includes: listName) ifTrue: [^ self]].
	(self prototype notNil and: [self prototype listVarNames includes: listName])
		ifTrue: [^ self].


	"list not found; create it"
	lists at: listName put: (PhratchListMorph new listName: listName target: self).


]

{ #category : #byob }
ScriptablePhratchMorph >> ensureOwnBlockExists: aBlockDef [

	| def bod defId |

 	aBlockDef ifNil: [^ self].
	defId := aBlockDef id.
	customBlocks ifNil: [customBlocks := OrderedCollection new].
	customBlocks detect: [:eachDef|
		eachDef id = defId]
		ifNone: [
			def := aBlockDef deepCopy.
			bod := aBlockDef body.
			bod ifNotNil: [def body: (bod fullCopy newScriptOwner: self)].
			customBlocks add: def]

]

{ #category : #variables }
ScriptablePhratchMorph >> ensureVariableExists: varName [
	"Make sure that the variable with the given name is visible to this object. Do nothing if the variable already exists."

	| stage vn |
	(varName isKindOf: Array)
		ifTrue: [^ self].
	(varName isKindOf: CommandBlockMorph)
		ifTrue: [^ self].

	vn := varName asString.	
	vn = '' ifTrue: [^ self].

	(vars includesKey: vn) ifTrue: [^ self].
	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNotNil: [
		(stage varNames includes: vn) ifTrue: [^ self]].
	(self prototype notNil and: [self prototype varNames includes: vn])
		ifTrue: [^ self].

	"variable not found; create it"
	vars at: vn asString put: 0.

]

{ #category : #'other ops' }
ScriptablePhratchMorph >> eventReceived: event [
	"Start all non-running stacks with an EventHat matching the given events and answer a collection of the new processes. If a process is already running for a given stack, don't start a new one."

	| targetScripts newProcs |
	targetScripts := #().
	event name = 'Phratch-KeyPressedEvent'
		ifTrue: [ targetScripts := self scripts select: [ :s | s class == KeyEventHatMorph and: [ s respondsToKeyEvent: event argument ] ] ]
		ifFalse: [ 
			event name = 'Phratch-MouseClickEvent'
				ifTrue: [ 
					self isHidden
						ifFalse: [ targetScripts := self scripts select: [ :s | s class == MouseClickEventHatMorph ] ] ]
				ifFalse: [ 
					targetScripts := event name = 'Phratch-CreationEvent'
						ifTrue: [ self scripts select: [ :s | s class == CreationEventHatMorph ] ]
						ifFalse: [ self scripts select: [ :s | s class == EventHatMorph and: [ s eventName caseInsensitiveEqual: event name ] ] ] ] ].
	newProcs := targetScripts asArray collect: [ :script | script startForEvent: event ].
	^ newProcs select: [ :p | p notNil ]
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> eventReceivedNamed: eventName [
	"Collect an array of all stacks that respond to the given event and keep only the ones that are running. Answer true if the final list has any items."
	<phratchItem: '$Event$ received?' kind: #b category: 'control' defaultValues: #() subCategory: #broadcast>
	| targetScripts procs |
	self isSprite ifTrue: [^ (self ownerThatIsA: PhratchStageMorph) eventReceivedNamed: eventName].
	targetScripts := self scripts select: [:s |
		(s class == EventHatMorph) and: [s eventName caseInsensitiveEqual: eventName]].
	targetScripts := targetScripts asOrderedCollection.
	self submorphsDo: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [
			(m scripts select: [:s |
				(s class == EventHatMorph) and:
				[s eventName caseInsensitiveEqual: eventName]]) do: [:script | targetScripts := targetScripts copyWith: script]]].

	procs := targetScripts select: [:s |
		s phratchProc notNil].
	^ procs size > 0.
]

{ #category : #byob }
ScriptablePhratchMorph >> existsBlockId: id [

	customBlocks ifNil: [customBlocks := OrderedCollection new].
	customBlocks detect: [:def|
		def id = id ] ifNone: [^false].
	^true
]

{ #category : #byob }
ScriptablePhratchMorph >> existsBlockId: id global: bool [
	| stage |
	bool
		ifTrue: [ ^ self existsBlockId: id ].
	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	stage ifNil: [ ^ self existsBlockId: id ].
	^ stage sprites , {stage} anySatisfy: [ :obj | obj existsBlockId: id ]
]

{ #category : #'as yet unclassified' }
ScriptablePhratchMorph >> exitPhratch [
	<phratchItem: 'quit Phratch' kind: #- category: 'control' defaultValues: #() subCategory: #project>
    Smalltalk snapshot: false andQuit: true
]

{ #category : #'right button menu' }
ScriptablePhratchMorph >> exportObject [

	| fName dir f objToExport |

	fName := PhratchFileChooserDialog
		chooseNewFileDefault: objName
		title: 'Export Sprite'
		type: #sprite.
	fName = #cancelled ifTrue: [^ self].
	fName size = 0 ifTrue: [^ self].
"	(fName endsWith: '.sprite') ifFalse: [fName := fName, '.sprite']."
	(fName endsWith: '.ysp') ifFalse: [fName := fName, '.ysp'].
	dir := fName asFileReference parent.
	fName := fName asFileReference basename.  "ignore path, if any; save in default directory"

	
	(dir / fName) exists ifTrue: [
		(DialogBoxMorph ask: 'Overwrite existing ', fName, '?') ifFalse: [^ self].
		(dir / fName) delete].

	f := nil.
	[	f := (StandardFileStream newFileNamed: (dir / fName)) binary.
		objToExport := self copyForExport.
		objToExport objName: fName.

		objToExport firstSubmorph allSubsprites do: [:eachSub |
			eachSub owner ifNil: [objToExport addMorphBack: eachSub ]].
		ObjStream new storeObj: objToExport on: f showProgress: true.
		f close.
		FilePluginPrims new setMacFileNamed: (dir / fName) fullName type: 'STyp' creator: 'PHRATCH'.

	] ifError: [
		f ifNotNil: [f close].
		self inform: 'Could not write file' withDetails: 'Export failed' localized].


]

{ #category : #'as yet unclassified' }
ScriptablePhratchMorph >> factorial: t1 [ 
	<phratchItem: 'factorial of $Number$' kind: #r category: 'operators' defaultValues: #() subCategory: #a9>
    | answer t1store |
    t1 isInf ifTrue:[^0].
    t1 isNaN ifTrue:[^0].
    answer := 1.
    t1store := t1.
    t1 = 0 ifTrue: [^ 1].
    t1 < 0 ifTrue: [^ 0].
    t1 isInf ifTrue: [^ 0].
    t1 isNaN ifTrue: [^ 0].
    [t1store > 1]
        whileTrue: 
            [answer := answer * t1store.
            t1store := t1store - 1].
    ^ answer
]

{ #category : #'looks ops' }
ScriptablePhratchMorph >> filterReset [
	<phratchItem: 'clear graphic effects' kind: #- category: 'looks' defaultValues: #() subCategory: #a3>
	filterPack := nil.
	self transparency: 0.
	self costumeChanged.
	self spread.

	self
		colorEffect: 0;
		fisheyeEffect: 0;
		whirlEffect: 0;
		pixelateEffect: 0;
		mosaicEffect: 0;
		brightnessEffect: 0;
		transparencyEffect: 0
]

{ #category : #accessing }
ScriptablePhratchMorph >> filteredForm [
	
	filterPack ifNil: [^ self rotatedForm].

	filterPack filtersActive ifTrue: [  "filter parameters have changed; apply filters"
		PhratchFrameMorph useErrorCatcher
			ifTrue: [[filterPack applyFiltersTo: self rotatedForm]
						ifError: [UIManager inform:  'There is a problem with FilterPack'. filterPack := nil. ^ self rotatedForm]]
			ifFalse: [filterPack applyFiltersTo: self rotatedForm]].

	^ filterPack resultForm as8BitColorForm

]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> fisheyeEffect [

	| att |
	att := #fisheye.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].
	^ [filterPack fisheye] ifError: [0]
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> fisheyeEffect: aNumber [

	self undeleteAttribute: #fisheye.
	self passiveFisheyeEffect: aNumber
]

{ #category : #accessing }
ScriptablePhratchMorph >> form [
	"Answer my current costume form, without filtering, rotation, or scaling."

	^ self costumeForm

]

{ #category : #accessing }
ScriptablePhratchMorph >> form: aForm [

	costume := (ImageMedia new form: aForm).
	costume mediaName: (self unusedMediaNameFromBaseName: 'costume').
	media addLast: costume.
	self costumeChanged.
	self updateMediaCategory.

	self undeleteAttribute: #costumes.
	self propagateCostumes

]

{ #category : #'BYOB object interface' }
ScriptablePhratchMorph >> get: anObject [
	<phratchItem: 'attribute $Attributes$' kind: #r category: 'sensing' defaultValues: #() subCategory: #a3>
	| oi sel obj att block |

	anObject = #null
		ifTrue: [^nil].

	oi := self objectInterface.

	(anObject isKindOf: Symbol) ifTrue: [
		sel := oi at: anObject ifAbsent: [^ self error: 'unknown attribute: ', anObject asString ].
		sel second = #- ifTrue: [
			^ self error: 'cannot read this attribute'].
		^ self perform: sel second ].
		
	(anObject isKindOf: CommandScriptBlockMorph) ifTrue: [
		obj := anObject receiver.
		(obj isKindOf: ScriptablePhratchMorph) ifFalse: [
			^ self error: 'cannot get attributes of non-Sprites/Stage'].
		block := anObject body argMorphs first.
		att := oi keys detect: [:key |
			(oi at: key) second  = block selector] ifNone: [
				^ self error: 'no attribute found for selector: ', anObject selector].
		^ obj get: att ].

	^ anObject
]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> getAttribute: attr of: anObject [
	"Answer the variable or built-in attribute value for the given sprite. Answer zero if the given sprite does not have a built-in attribute or variable of the given name."
	<phratchItem: '$Attributes$ of $Sprite$' kind: #r category: 'sensing' defaultValues: #() subCategory: #a3>
	| aSpriteOrStage |
	aSpriteOrStage := self coerceSpriteArg: anObject.
	(aSpriteOrStage isKindOf: ScriptablePhratchMorph) ifFalse: [^ 0].
"	^ aSpriteOrStage getAttribute: attr asString"
	^ aSpriteOrStage attribute: attr


]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> getColor: colorName [

	^ colors at: colorName ifAbsent: [(Color black)]
]

{ #category : #byob }
ScriptablePhratchMorph >> getFalse [
	<phratchItem: 'false' kind: #b category: 'operators' defaultValues: #() subCategory: #a5>
	^false
]

{ #category : #'list ops' }
ScriptablePhratchMorph >> getLine: lineNum ofList: listName [
	<phratchItem: 'item $ListIndex$ of $List$' kind: #r category: 'list' defaultValues: #(1) subCategory: #a5>
	| list |
	list := (listName isKindOf: PhratchListMorph)
		ifTrue: [ listName ]
		ifFalse: [ self listNamed: listName ifNone: [ ^ '' ] ].
	^ list lineAt: (self lineNum: lineNum forList: list)
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> getNamedColor: aColorName [
	<phratchItem: 'color named $NamedColors$' kind: #g category: 'colors' defaultValues: #() subCategory: #a7>
	^ Color fromString: aColorName.
]

{ #category : #'byob OOP' }
ScriptablePhratchMorph >> getObject: anObject [
	<phratchItem: 'object $Sprite$' kind: #r category: 'sensing' defaultValues: #() subCategory: #a3>
	^ anObject
]

{ #category : #'byob OOP' }
ScriptablePhratchMorph >> getSpawnOf: anObject [
	^ anObject spawn
]

{ #category : #byob }
ScriptablePhratchMorph >> getTrue [
	<phratchItem: 'true' kind: #b category: 'operators' defaultValues: #() subCategory: #a5>
	^true
]

{ #category : #variables }
ScriptablePhratchMorph >> getVar: varName [
	"Answer the value of the given user variable of this object, or 0 if the variable has been deleted."

	| stage |
	(vars includesKey: varName)
		ifFalse: [ stage := (self ownerOrYourselfThatIsA: PhratchStageMorph).
			stage ifNotNil: [	^ stage vars at: varName asString ifAbsent: [
				(self prototype notNil and: [self prototype varNames includes: varName])
					ifTrue:[^self prototype getVar: varName]
					ifFalse: [^self phratchObject getVar: varName]]].
			(self prototype notNil and: [self prototype varNames includes: varName])
					ifTrue:[^self prototype getVar: varName]
					ifFalse: [^self phratchObject getVar: varName]].
	^ vars at: varName asString ifAbsent: [0]

]

{ #category : #variables }
ScriptablePhratchMorph >> getVar: varName block: aVariableBlockMorph [
	"Answer the value of the given user variable of this object, or 0 if the variable has been deleted."

	(vars includesKey: varName)
		ifFalse: [ ^ (self ownerOrYourselfThatIsA: PhratchStageMorph) vars at: varName asString ifAbsent: [
			(self prototype notNil and: [self prototype varNames includes: varName])
				ifTrue:[self prototype getVar: varName]
				ifFalse: [^ self desparatelyGetVar: varName from: aVariableBlockMorph]]].
	^ vars at: varName asString ifAbsent: [0]

]

{ #category : #'BYOB OOP message passing' }
ScriptablePhratchMorph >> getVarOrListNamed: varName [
	<phratchItem: 'variable named $String$' kind: #r category: 'variables' defaultValues: #() subCategory: #a3>
	| value |
	"first let's try to find a variable"
	value := (vars includesKey: varName)
		ifFalse: [ 
			(self ownerOrYourselfThatIsA: PhratchStageMorph) vars
				at: varName asString
				ifAbsent: [ 
					(self prototype notNil and: [ self prototype varNames includes: varName ])
						ifTrue: [ self prototype getVar: varName ]
						ifFalse: [ nil ] ] ]
		ifTrue: [ vars at: varName asString ifAbsent: [ nil ] ].	"if none is found check for a named list"
	value
		ifNil: [ 
			value := self
				listNamed: varName
				ifNone: [ 
					self error: 'no such variable or list'.
					nil ] ].
	^ value
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> graphicEffectNamed: effect [
"Answer the provided graphic effect"
	<phratchItem: '$Effects$ effect' kind: #r category: 'looks' defaultValues: #('color') subCategory: #a3>
	filterPack ifNil: [filterPack := FilterPack new].

	'brightness' = effect ifTrue: [^ filterPack brightnessShift].
	'fisheye' = effect ifTrue: [^ filterPack fisheye].
	'color' = effect ifTrue: [^ filterPack hueShift].
	'mosaic' = effect ifTrue: [^ filterPack mosaicCount].
	'pixelate' = effect ifTrue: [^ filterPack pixelateCount].
	'ghost' = effect ifTrue: [^ self transparency].
	'whirl' = effect ifTrue: [^ filterPack whirl].
]

{ #category : #'looks ops' }
ScriptablePhratchMorph >> graphicEffectNames [
	"Answer a collection of graphic effect names."

	^ #(
		'color'
		'fisheye'
		'whirl'
		'pixelate'
		'mosaic'
		'brightness'
		'ghost')

]

{ #category : #'event handling' }
ScriptablePhratchMorph >> handleTool: toolName hand: hand [

	| scaleFactor |
	toolName = 'CopyTool' ifTrue: [
		Sensor shiftPressed ifFalse: [hand toolType: nil].
		(self isKindOf: PhratchStageMorph) ifFalse: [
			^ self duplicate]].

	toolName = 'CutTool' ifTrue: [
		Sensor shiftPressed ifFalse: [hand toolType: nil].
		(self isKindOf: PhratchStageMorph) ifFalse: [
			^ self undoableDeleteSprite]].

	"exit now if I am not scalable"
	(self respondsTo: #multiplySizeBy:) ifFalse: [
		Beeper beep.
		hand toolType: nil.
		^ self].

	scaleFactor := hand lastEvent shiftPressed ifTrue: [1.2] ifFalse: [1.03].
	toolName = 'ZoomInTool' ifTrue: [^ self multiplySizeBy: scaleFactor].
	toolName = 'ZoomOutTool' ifTrue: [^ self multiplySizeBy: 1.0 / scaleFactor].

]

{ #category : #media }
ScriptablePhratchMorph >> handlesDropShadowInHand [
	^ true
]

{ #category : #'event handling' }
ScriptablePhratchMorph >> handlesMouseDown: evt [

	^ self isVisible

]

{ #category : #blocks }
ScriptablePhratchMorph >> hatBlockFromTuple: tuple receiver: scriptOwner [
	"Answer a new block for the given variable reference tuple."

	| blockClass block eventName arg |

	#byob = tuple first ifFalse: [
		^self hatBlockFromTupleOldForm: tuple receiver: scriptOwner ].

	blockClass := Smalltalk at: tuple third.
	block := blockClass new scriptOwner: scriptOwner.

	blockClass = EventHatMorph ifTrue: [
		eventName := tuple at: 4.
		eventName = 'Phratch-StartClicked'
			ifTrue: [block forStartEvent; scriptOwner: scriptOwner]
			ifFalse: [block eventName: eventName]].

	blockClass = KeyEventHatMorph ifTrue: [
		block choice: (tuple at: 4)].

	blockClass = WhenHatBlockMorph ifTrue: [
		(tuple at: 4) ~= false ifTrue: [
			arg := self blockFromTuple: (tuple at: 4) receiver: scriptOwner.
			block replaceArgMorph: block argMorph by: arg]].

	^ block

]

{ #category : #blocks }
ScriptablePhratchMorph >> hatBlockFromTupleOldForm: tuple receiver: scriptOwner [
	"Answer a new block for the given variable reference tuple."

	| blockClass block eventName arg |
	blockClass := Smalltalk at: tuple first.
	block := blockClass new scriptOwner: scriptOwner.

	blockClass = EventHatMorph ifTrue: [
		eventName := tuple at: 2.
		eventName = 'Phratch-StartClicked'
			ifTrue: [block forStartEvent; scriptOwner: scriptOwner]
			ifFalse: [block eventName: eventName]].

	blockClass = KeyEventHatMorph ifTrue: [
		block choice: (tuple at: 2)].

	blockClass = WhenHatBlockMorph ifTrue: [
		(tuple at: 2) ~= false ifTrue: [
			arg := self blockFromTuple: (tuple at: 2) receiver: scriptOwner.
			block replaceArgMorph: block argMorph by: arg]].

	^ block

]

{ #category : #blocks }
ScriptablePhratchMorph >> hatBlockType: blockType [

	| stage evtName |
	'E' = blockType ifTrue: [
		evtName := ''.
		(stage := self ownerOrYourselfThatIsA: PhratchStageMorph)
			ifNotNil: [evtName := stage defaultEventName].
		^ EventHatMorph new scriptOwner: self; eventName: evtName;
		yourself].

	'K' = blockType ifTrue: [^ KeyEventHatMorph new scriptOwner: self].
	'M' = blockType ifTrue: [^ MouseClickEventHatMorph new scriptOwner: self].
	'S' = blockType ifTrue: [^ EventHatMorph new forStartEvent scriptOwner: self].
	'W' = blockType ifTrue: [^ WhenHatBlockMorph new scriptOwner: self].
	'C' = blockType ifTrue: [^ CreationEventHatMorph new scriptOwner: self]

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> hideColor [
	"Ask the user which user variable to hide, then hide it."

	| sFrame stage menu choice |
	sFrame := self ownerThatIsA: PhratchFrameMorph.
	sFrame ifNil: [^ self].

	stage := sFrame workPane.
	(stage colorNames isEmpty) & (self colorNames isEmpty)
		ifTrue: [^ self inform: 'No colors.' localized].

	menu := MenuMorphNG new.
	stage colorNames do: [:v | menu add: v value: (Array with: v with: #global)].
	self = stage ifFalse: [
		stage colorNames isEmpty ifFalse: [menu addLine].
		self colorNames do: [:v | menu add: v value:  (Array with: v with: #local)]].
	choice := menu invokeModal; selectedValue;
		yourself.
	choice ifNil: [^ self].

	choice second = #global
		ifTrue: [stage hideColor: choice first]
		ifFalse: [self hideColor: choice first].

	sFrame viewerPane categoryChanged: 'colors'.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> hideColor: varName [
	"Hide the watcher(s) for the given variable. If the receiver is a sprite and both it and and the stage have the given variable, hide both. Do nothing if the variable does not exist or is already hidden."
	<phratchItem: 'hide color $ColorVar$' kind: #- category: 'colors' defaultValues: #('') subCategory: #a2>
	| stage |
	self showOrHideColor: varName show: false.

	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	stage ~= self ifTrue: [stage showOrHideColor: varName show: false].
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> hideList: aList [
	"Show the given list"
	<phratchItem: 'hide list $List$' kind: #- category: 'list' defaultValues: #() subCategory: #a3>
	self showOrHideList: aList show: false
]

{ #category : #variables }
ScriptablePhratchMorph >> hideVariable: varName [
	"Hide the watcher(s) for the given variable. If the receiver is a sprite and both it and and the stage have the given variable, hide both. Do nothing if the variable does not exist or is already hidden."
	<phratchItem: 'hide variable $Variable$' kind: #- category: 'variables' defaultValues: #() subCategory: #a2>
	| stage |
	self showOrHideVariable: varName show: false.

	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	stage ~= self ifTrue: [stage showOrHideVariable: varName show: false].


]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> hookupBooleanSensorNames [

	^ #(
		'button pressed'
		'connected'
	)

]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> hookupSensorNames [

	| sensorNames stage virtualSensors |
	sensorNames := #(
		'slider'
		'light'
		'sound'
		'resistance'
	).

	sensorNames := sensorNames, #('-' 'tilt' 'distance'). "WeDo sensors"

	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNotNil: [
		stage phratchServer ifNotNil: [
			virtualSensors := stage phratchServer sensorNames.
			virtualSensors size > 0 ifTrue: [
				^ sensorNames, {'-'}, stage phratchServer sensorNames]]].

	^ sensorNames

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> if: aCondition then: trueString else: falseString [
"Answer the first string if the given condition is true, otherwise answer the second."
	<phratchItem: 'if $Boolean$ then $String$ else $String$' kind: #r category: 'control' defaultValues: #() subCategory: #if>
	aCondition
		ifTrue: [^ trueString].
	^ falseString
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> ifB: aCondition then: trueString else: falseString [
"Answer the first string if the given condition is true, otherwise answer the second."
	<phratchItem: 'if $Boolean$ then $Boolean$ else $Boolean$' kind: #b category: 'control' defaultValues: #() subCategory: #if>
	aCondition
		ifTrue: [^ trueString = true].
	^ falseString
]

{ #category : #accessing }
ScriptablePhratchMorph >> imageForm [
	"Answer a Form showing myself for the purpose of generating a thumbnail."

	^ self filteredForm copy offset: 0@0

]

{ #category : #media }
ScriptablePhratchMorph >> importImage [
	"Import a new image from a file and add it to my media (concatenating the name if it is greater than 16 characters long). If the file is an animated gif, import all frames of the gif as separate costumes."

	| title result el fList isFirst newName type |
	(self isKindOf: PhratchStageMorph)
		ifTrue: [type := #background. title := 'Import Background']
		ifFalse: [type := #costume. title := 'Import Costume'].
	result := PhratchFileChooserDialog
		chooseImageFileType: type
		title: title.
	result = #cancelled ifTrue: [^ self].

	fList := OrderedCollection new.

	[fList addLast: (Form fromFileNamed: result)] ifError: [^ self].

	isFirst := true.
	fList do: [:f |
		el := ImageMedia new form: (PhratchFrameMorph scaledFormForPaintEditor: f).
		newName := self mediaNameFromFileName: result default: 'costume'.
		el mediaName: (self unusedMediaNameFromBaseName: (String withAll: newName)).
		media addLast: el.
		isFirst ifTrue: [isFirst := false. self lookLike: el mediaName.]].

	self updateMediaCategory.
	self undeleteAttribute: #costumes.
	self propagateCostumes

]

{ #category : #media }
ScriptablePhratchMorph >> importMedia: fileName [
	"Import a new image from a file and add it to my media."

	|  extensionLoc elList baseName fList isFirst |
	extensionLoc := ( fileName) extension asLowercase.

	elList := OrderedCollection new.

	(#(aif aiff wav mp3) includes: extensionLoc) ifTrue: [
		baseName := self mediaNameFromFileName: fileName default: 'sound'.
		[elList addLast: (SoundMedia new loadFile: fileName)] ifError: [^ self]].

	(#(jpg jpeg gif bmp png) includes: extensionLoc) ifTrue: [
		baseName := self
			mediaNameFromFileName: fileName
			default: self defaultImageMedia mediaName.
		fList := OrderedCollection new.
		"extensionLoc = 'gif' 
			ifTrue: 
				[[fList := (GIFReadWriter new on: (FileStream oldFileNamed: fileName)) nextImageSet] ifError: [^ self]]
			ifFalse: 
				["[fList addLast: (Form fromFileNamed: fileName)] ifError: [^ self]"]".
		fList do: [:f | 
			elList addLast: (ImageMedia new form: (PhratchFrameMorph scaledFormForPaintEditor: f))]].

	elList isEmpty ifTrue: [^ self].  "unknown file type; ignore"

	isFirst := true.
	elList do: [:el | 
		el mediaName: (self unusedMediaNameFromBaseName: baseName).
		media addLast: el.
		isFirst ifTrue: [
			isFirst := false. 
			el isSound 
				ifTrue: [
					self undeleteAttribute: #sounds.
					self propagateSounds
					]
				ifFalse: [
					self lookLike: el mediaName.
					self undeleteAttribute: #costumes.
					self propagateCostumes]]].
	
	self updateMediaCategory.

]

{ #category : #media }
ScriptablePhratchMorph >> importSound [
	"Import a new sound from a file and add it to my media."

	| result el newName |
	result := PhratchFileChooserDialog
		chooseExistingFileType: #sound
		extensions: #(aif aiff au wav mp3)
		title: 'Import Sound'.

	result = #cancelled ifTrue: [^ self].

	el := [SoundMedia new loadFile: result]
		ifError: [:err :rcvr |
			DialogBoxMorph warn: err.
			nil].
	el ifNil: [^ self].

	newName := self mediaNameFromFileName: result default: 'sound'.
	el mediaName: (String withAll: (self unusedMediaNameFromBaseName: newName)).
	media addLast: el.
	self updateMediaCategory.

	self undeleteAttribute: #sounds.
	self propagateSounds
]

{ #category : #accessing }
ScriptablePhratchMorph >> inPresentationMode [

	^ (self ownerOrYourselfThatIsA: OffscreenWorldMorph) notNil

]

{ #category : #'as yet unclassified' }
ScriptablePhratchMorph >> indexOf: t1 List: t2 [ 
	<phratchItem: 'first index of $String$ in $List$' kind: #r category: 'list' defaultValues: #('' 'list') subCategory: #a5>  
  | t3 |
    t3 := 1.
    (self lineCountOfList: t2)
        timesRepeat: 
            [(self getLine: t3 ofList: t2)
                = t1 ifTrue: [^ t3].
            t3 := t3 + 1].
    ^ 0
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> indexOf: subString startingAt: aNumber in: aString [
	<phratchItem: 'index of $String$ starting at $Number$ in $String$' kind: #r category: 'operators' defaultValues: #('o' 6 'hello world') subCategory: #a6>
    ^ aString asString findString: subString startingAt: aNumber
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> inheritCostumesNow [
	| att idx |
	att := #costumes.
	self prototype ifNil: [ ^ self ].
	(self deletedAttributes includes: att)
		ifFalse: [ ^ self ].
	idx := self costumeIndex.
	media := media select: [ :item | item isSound ].
	self prototype media
		do: [ :item | 
			item isSound
				ifFalse: [ media addLast: item copy ] ].
	self passiveLookLike: idx.
	self updateMediaCategory.
	self propagateCostumes
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> inheritSoundsNow [

	| att |
	att := #sounds.
	self prototype ifNil: [^ self].
	(self deletedAttributes includes: att) ifFalse: [^ self].

	media := media reject: [:item |
		item isSound].

	self prototype media do: [:item |
		item isSound ifTrue: [
			media addLast: item copy]].

	self updateMediaCategory.

	self propagateSounds
]

{ #category : #'byob OOP' }
ScriptablePhratchMorph >> inheritedBlockIds [

	| ownIds inheritedIds |
	self prototype ifNil: [^ #()].
	ownIds := self blockIds.
	inheritedIds := (self prototype localBlocks collect: [:each | 
		each id ]) reject: [:id |
			ownIds includes: id].
	^ inheritedIds
]

{ #category : #'byob OOP' }
ScriptablePhratchMorph >> inheritedBlocks [

	^ self inheritedBlockIds collect: [:id | 
		self prototype definitionFor: id ]
]

{ #category : #'object i/o' }
ScriptablePhratchMorph >> initFieldsFrom: anObjStream version: classVersion [

	| fields |

	fields := #(
		objName
		vars
		blocksBin
		isClone
		media
		costume
	).
	self class currentEncoding = #byob
		ifTrue: [
	fields := #(
		objName
		vars
		blocksBin
		customBlocks
		isClone
		media
		costume
	) ].

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: fields from: anObjStream.

]

{ #category : #initialization }
ScriptablePhratchMorph >> initialize [

	super initialize.
	objName := self nextInstanceName.
	vars := Dictionary new.
	lists := Dictionary new.
	colors:= Dictionary new.
	blocksBin := PhratchScriptsMorph new.
	isClone := false.
	costume := self defaultImageMedia.
	media := OrderedCollection new.
	costumeChangeMSecs := 0.
	visibility := 100.
	volume := 100.
	tempoBPM := 60.
	sceneStates := Dictionary new.

]

{ #category : #'byob OOP' }
ScriptablePhratchMorph >> initializeVarsAndLists [
	"used when spawning (cloning)"

	vars := Dictionary new.
	lists := Dictionary new
]

{ #category : #'list ops' }
ScriptablePhratchMorph >> insert: anObject at: lineNum ofList: listName [
	<phratchItem: 'insert $String$ at $ListIndex$ of $List$' kind: #- category: 'list' defaultValues: #('thing' 1) subCategory: #a4>
	| list i |
	list := self listNamed: listName ifNone: [^ self].
	i := self lineNum: lineNum forList: list.
	#last = lineNum ifTrue: [i := list lineCount + 1].
	list insertLine: (self asListElement: anObject) at: i.


]

{ #category : #media }
ScriptablePhratchMorph >> insertMedia: aPhratchMedia before: targetOrNil [
	"Shuffle my media list so that the given media item comes immediately before the target media item, or at the end of the list if targetPhratchMedia is nil. Do nothing if the given item is the same as the target item."

	| mediaItem |
	aPhratchMedia == targetOrNil ifTrue: [^ self].

	mediaItem := aPhratchMedia.
	(media includes: aPhratchMedia) ifFalse: [
		"dropping an undeleted media item"
		mediaItem := mediaItem copy.
		mediaItem mediaName: (self unusedMediaNameFromBaseName: mediaItem mediaName).
		media addLast: mediaItem].

	media remove: mediaItem.
	targetOrNil
		ifNil: [media addLast: mediaItem]
		ifNotNil: [media add: mediaItem before: targetOrNil].
	self updateMediaCategory.

	aPhratchMedia isSound 
		ifTrue: [
			self undeleteAttribute: #sounds.
			self propagateSounds]
		ifFalse: [
			self undeleteAttribute: #costumes.
			self propagateCostumes]

]

{ #category : #'debug and other' }
ScriptablePhratchMorph >> inspect: anObject [
	anObject inspect
]

{ #category : #byob }
ScriptablePhratchMorph >> installGlobalBlocks [

	| stage |

	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.	
	stage ifNil: [^ self].
	"add imported global custom block definitions"


	customBlocks ifNotNil: [

		'installing globals...' 
			displayProgressAt: self center - (32@5)  "Sensor cursorPoint"
			from: 0 to: customBlocks size
			during: [:bar | | i | i := 0.

		customBlocks do: [:eachDef | 
			i := i + 1. bar value: i.
			eachDef isGlobal ifTrue: [
				stage sprites, {stage} do: [:obj |
					obj
						updateCustomBlockDefinitionId: eachDef id with: eachDef;
						updateLocalId: eachDef id withSpec: eachDef userSpec]]]]].


]

{ #category : #'byob OOP' }
ScriptablePhratchMorph >> instances [

	| stage |
	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	stage ifNil: [^ #()].
	^ stage sprites select: [:each |
		each prototype = self ]
]

{ #category : #byob }
ScriptablePhratchMorph >> instancesOf: aCustomBlockId [

	| sf ans visible invisible blx |
	invisible := self invisibleInstancesOf: aCustomBlockId.
	visible := blocksBin allMorphs select: [ :m|
		((m isKindOf: CustomCommandBlockMorph) or:[
			m isKindOf: CustomReporterBlockMorph]) and: [m id = aCustomBlockId]].
	sf := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	sf ifNotNil: [
		sf blockEditors do: [:be |
			blx := be allBlocksFor: aCustomBlockId.
			blx size > 0 ifTrue: [
				visible addAll: blx ]]].

	ans := visible, invisible.
	^ans
]

{ #category : #private }
ScriptablePhratchMorph >> interpretStringAsNumberIfPossible: anObject [
	"If the argument is a string that can be interpreted as a number, such as '123', then return it's value as a number. Otherwise, return the original object."

	| s digits hasDigit |
	(anObject isKindOf: String)
		ifFalse: [ ^ anObject ].
	anObject size = 0
		ifTrue: [ ^ anObject ].
	s := (anObject first isKindOf: Character)
		ifTrue: [ ReadStream on: anObject asByteArray ]
		ifFalse: [ ReadStream on: anObject ].	"see if the string can be parsed as a Phratch number:"
	digits := '0123456789' asByteArray.
	hasDigit := false.
	(s atEnd not and: [ s peek = $- asciiValue ])
		ifTrue: [ s next ].
	[ s atEnd not and: [ digits includes: s peek ] ]
		whileTrue: [ 
			hasDigit := true.
			s next ].
	(s atEnd not and: [ s peek = $. asciiValue ])
		ifTrue: [ s next ].
	[ s atEnd not and: [ digits includes: s peek ] ]
		whileTrue: [ 
			hasDigit := true.
			s next ].
	(s atEnd and: [ hasDigit ])
		ifTrue: [ ^ anObject asNumberNoError ]
		ifFalse: [ ^ anObject ]
]

{ #category : #byob }
ScriptablePhratchMorph >> invisibleInstancesOf: aCustomBlockId [

	| ans |
	ans := Set new.
	customBlocks ifNil: [^ ans].
	customBlocks do: [:eachDef|
		eachDef body ifNotNil: [
			ans addAll: (eachDef body allMorphs select: [:m|
				((m isKindOf: CustomCommandBlockMorph) or: [
					m isKindOf: CustomReporterBlockMorph]) and: [
				m id = aCustomBlockId ]])].

		eachDef answer ifNotNil: [
			(eachDef answer isKindOf: BlockMorph) ifTrue: [
				ans addAll: (eachDef answer allMorphs select: [:m|
					((m isKindOf: CustomReporterBlockMorph) or: [
						m isKindOf: CustomReporterBlockMorph]) and: [
					m id = aCustomBlockId ]])]]].

	^ans asOrderedCollection
]

{ #category : #accessing }
ScriptablePhratchMorph >> isClone [

	^ false

]

{ #category : #accessing }
ScriptablePhratchMorph >> isClone: aBoolean [
	"Ignored here. Overridden by my subclasses."
]

{ #category : #testing }
ScriptablePhratchMorph >> isFibonacci: t1 [ 
	<phratchItem: '$Number$ is a Fibonacci number?' kind: #b category: 'operators' defaultValues: #() subCategory: #a9>
    | fib1 fib2 oldfib2 fib3 oldfib3 |
                t1 isInf ifTrue:[^false].
                t1 isNaN ifTrue:[^false].
                t1 < 0 ifTrue: [^ false].
    t1 = 0 ifTrue: [^ true].
    t1 = 1 ifTrue: [^ true].
    fib1 := 0.
    fib2 := 1.
    oldfib2 := fib2.
    fib3 := fib1 + fib2.
    oldfib3 := fib3.
    [t1 > fib3]
        whileTrue: 
            [fib3 := fib1 + fib2.
            fib2 := oldfib3.
            fib1 := oldfib2.
            oldfib3 := fib3.
            oldfib2 := fib2].
    t1 = fib3 ifTrue: [^ true]
		 ifFalse: [^ false]

]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> isHidden [

	| att |
	att := #isHidden.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ super isHidden


]

{ #category : #testing }
ScriptablePhratchMorph >> isInteger: t1 [
	<phratchItem: '$Number$ is an integer?' kind: #b category: 'operators' defaultValues: #() subCategory: #a9>
    ^ t1 = t1 rounded
]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> isLoud [
	<phratchItem: 'loud?' kind: #b category: 'sensing' defaultValues: #() subCategory: #a4>
	^ self class soundRecorder meterLevel > 30

]

{ #category : #byob }
ScriptablePhratchMorph >> isObject: object type: type [
	<phratchItem: 'is $String$ a $Type$ ?' kind: #b category: 'operators' defaultValues: #() subCategory: #b1>
	'object' "localized" = type ifTrue: [
		^ object isKindOf: ScriptablePhratchMorph].

	'number' "localized" = type ifTrue: [
		object isNumber ifTrue: [^true].
		(object isKindOf: Morph) ifTrue: [^ false].
		(object isKindOf: Boolean) ifTrue: [^ false].
		object isEmpty ifTrue: [^ false].
		object do: [:c | 
			c isDigit ifFalse: [('0.-' includes: c) ifFalse: [^ false]]].
		^ true].

	'text' "localized" = type ifTrue: [
		object isNumber ifTrue: [^ false].
		(object isKindOf: Morph) ifTrue: [^ false].
		(object isKindOf: Boolean) ifTrue: [^ false].
		object isEmpty ifTrue: [^ true].
		object do: [:c | 
			c isDigit ifFalse: [('0.-' includes: c) ifFalse: [^ true]]].
		^ false].

	'boolean' "localized" = type ifTrue: [
		^ object isKindOf: Boolean].

	'list' "localized" = type ifTrue: [
		^ object isKindOf: PhratchListMorph]. 

	'command' "localized" = type ifTrue: [
		(object isKindOf: LambdaBlockMorph) ifFalse: [^ false].
		^ object isFunction not].

	'reporter' "localized" = type ifTrue: [
		(object isKindOf: LambdaBlockMorph) ifFalse: [^ false].
		object isBooleanFunction ifTrue: [^ false].
		^ object isFunction].

	'predicate' "localized" = type ifTrue: [
		(object isKindOf: LambdaBlockMorph) ifFalse: [^ false].
		^ object isBooleanFunction].

	^ false



]

{ #category : #testing }
ScriptablePhratchMorph >> isPrime: t1 [ 
	<phratchItem: '$Number$ is prime?' kind: #b category: 'operators' defaultValues: #() subCategory: #a9>
    | divisor factor |
    t1 isInf ifTrue: [^ false].
    t1 isNaN ifTrue: [^ false].
    t1 < 1 ifTrue: [^ false].
    t1 = 1 ifTrue: [^ false].
    t1 = t1 rounded ifFalse:[^false].
    divisor := 2.
    [divisor > (0.5 * t1)]
        whileFalse: 
            [factor := t1 / divisor.
            factor = factor rounded ifTrue: [^false].
            divisor := divisor + 1].
    ^ true
]

{ #category : #accessing }
ScriptablePhratchMorph >> isScriptable [
	"I am a scriptable Phratch object."

	^ true

]

{ #category : #accessing }
ScriptablePhratchMorph >> isSprite [

	^ false

]

{ #category : #accessing }
ScriptablePhratchMorph >> isVisible [

	^ self isHidden not and: [visibility > 0]

]

{ #category : #'dropping/grabbing' }
ScriptablePhratchMorph >> justDroppedInto: newOwner event: evt [
	"If I'm dropped into any submorph of a PhratchFrameMorph, reject the drop unless it is onto the work pane. For developers, accept drops into other morphs (e.g. the World). Otherwise, reject the drop."

	| sFrame |
	(sFrame := newOwner ownerOrYourselfThatIsA: PhratchFrameMorph) ifNotNil: [
		newOwner = sFrame viewerPane pageViewer contents ifTrue: [
			self undoableDeleteSprite.
			sFrame libraryPane step.
			^ self].

		newOwner = sFrame workPane ifTrue: [^ self]. "allow drops onto the work pane"
		^ evt hand rejectDropMorph: self event: evt].

	ScriptablePhratchMorph noviceMode ifTrue: [^ evt hand rejectDropMorph: self event: evt].

]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> keyNames [
	"Key names for 'key pressed' block menu. Must keep this list in sync with asciiFor:."

	^ #('up arrow' 'down arrow' 'right arrow' 'left arrow' 'space'),
	   ($a to: $z), ($0 to: $9)
		 collect: [:ch | ch asString]

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> keyPressed [
	"Answer the currently pressed key."
	<phratchItem: 'key pressed' kind: #r category: 'sensing' defaultValues: #() subCategory: #a2>
	self flag: 'TODO: This needs to be rewritten to use Sensor keyboard or the like.'.
	self keyNames do: [:ch |
		(self keyPressed: ch) ifTrue: [^ ch]].
	^ ''.
]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> keyPressed: keyName [
	<phratchItem: 'key $Keys$ pressed?' kind: #b category: 'sensing' defaultValues: #('space') subCategory: #a2>
	| ch |
	ch := self asciiFor: keyName.
	(Sensor keyPressed: ch) ifTrue: [^ true].

	"if key is a letter, check the opposite case"
	(ch between: $a asciiValue and: $z asciiValue) ifTrue: [
		^ Sensor keyPressed: ch - 32].
	(ch between: $A asciiValue and: $Z asciiValue) ifTrue: [
		^ Sensor keyPressed: ch + 32].

	^ false

]

{ #category : #byob }
ScriptablePhratchMorph >> lambda: aCustomBlockId [

	"used for the getAttribute block menu"

	| def block |
	
	aCustomBlockId isEmpty ifTrue: [^nil].

	def := self definitionFor: aCustomBlockId.
	(def isNil or: [#none = def type])
		ifTrue: [block := CustomCommandBlockMorph new receiver: self]
		ifFalse: [
			block := CustomReporterBlockMorph new receiver: self.
			block isBoolean: def type = #boolean].

	block
		userSpec: def userSpec;
		isSpecialForm: true;
		selector: #doCustomBlock.

	block argMorphs do: [:arg |
		arg defaultValue: ''].

	^ block
	
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> layer [

	| att |
	att := #layer.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ owner submorphs indexOf: self
]

{ #category : #media }
ScriptablePhratchMorph >> layer: aNumber [

	| n submorphsMinusMe newSubmorphs |
	owner ifNil: [^ 1].
	n := (aNumber rounded max: 1) min: owner submorphCount.
	submorphsMinusMe := owner submorphs copyWithout: self.
	newSubmorphs :=
		(submorphsMinusMe copyFrom: 1 to: (n - 1 min: submorphsMinusMe size)),
		(Array with: self),
		(submorphsMinusMe copyFrom: n to: submorphsMinusMe size).
	owner privateSubmorphs: newSubmorphs.
	self changed.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> layoutStyles [

	^ #(
		'small'
		'large'
		'slider'
		).
]

{ #category : #'string ops' }
ScriptablePhratchMorph >> letter: index of: anObject [
	"Answer the ith letter of the given string. Answer the empty string if the index is out of bounds."
	<phratchItem: 'letter $Number$ of $String$' kind: #r category: 'operators' defaultValues: #(1 'world') subCategory: #a6>
	| s i |
	s := anObject.

	s := anObject asString.

	i := self letterNum: index of: s.
	((i < 1) | (i > s size)) ifTrue: [^ ''].
	^ (String with: (s at: i))

]

{ #category : #'string ops' }
ScriptablePhratchMorph >> letterNum: letterNum of: aString [
	"Answer the ith letter of the given string. Answer the empty string if the index is out of bounds."

	| s |
	letterNum isNumber ifTrue: [^ letterNum asInteger].

	s := letterNum.
	(s isKindOf: String) ifTrue: [
		#first = s ifTrue: [^ 1].
		#last = s ifTrue: [^ aString size].
		#any = s ifTrue: [
			aString size = 0 ifTrue: [^ 1].
			^ (1 to: aString size lineCount) atRandom].
		^ s asNumberNoError].
	^ 0

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> letters: start through: end of: aString [
	"Returns the letters in a string from the start index through the end index."
	<phratchItem: 'letters $Number$ - $Number$ of $String$' kind: #r category: 'operators' defaultValues: #(1 5 'hello world') subCategory: #a6>
	^ aString asString copyFrom: (start max: 1) to: (end min: aString size).
]

{ #category : #'list ops' }
ScriptablePhratchMorph >> lineCountOfList: listName [
	<phratchItem: 'length of $List$' kind: #r category: 'list' defaultValues: #() subCategory: #a5>
	| list |
	list := self listNamed: listName ifNone: [^ 0].
	^ list lineCount

]

{ #category : #'list ops' }
ScriptablePhratchMorph >> lineNum: lineNum forList: list [

	| s |
	lineNum isNumber ifTrue: [^ lineNum asInteger].

	s := lineNum.
	(s isKindOf: String) ifTrue: [
		#first = s ifTrue: [^ 1].
		#last = s ifTrue: [^ list lineCount].
		#any = s ifTrue: [
			list lineCount = 0 ifTrue: [^ 1].
			^ (1 to: list lineCount) atRandom].
		^ s asNumberNoError].
	^ 0

]

{ #category : #'list ops' }
ScriptablePhratchMorph >> list: listName contains: anObject [
	<phratchItem: '$List$ contains $String$' kind: #b category: 'list' defaultValues: #('list' 'thing') subCategory: #a5>
	| list |
	list := self listNamed: listName ifNone: [^ false].
	^ list contains: anObject

]

{ #category : #'list ops' }
ScriptablePhratchMorph >> listIndexForDeleteMenu [

	| menu |
	menu := MenuMorphNG new defaultTarget: self.
	#('1' last) do: [:s | menu add: s value: s].
	menu addLine.
	menu add: #all value: #all.
	menu localize invokeModal.
	^ menu 

]

{ #category : #'list ops' }
ScriptablePhratchMorph >> listIndexMenu [

	| menu |
	menu := MenuMorphNG new defaultTarget: self.
	#('1' last any) do: [:s | menu add: s value: s].
	menu localize invokeModal.
	^ menu

]

{ #category : #'list ops' }
ScriptablePhratchMorph >> listNamed: aString [

	^ self listNamed: aString ifNone: [nil]
]

{ #category : #'list ops' }
ScriptablePhratchMorph >> listNamed: aString ifNone: aBlock [
	"Answer a list with the given name. First check the local list variables, otherwise check the global list variables and the prototype. If there is no list variable with the given name, return the result of evaluating the given block."

	| result stage |
	(aString isKindOf: PhratchListMorph)
		ifTrue: [^aString ].
	(result := lists at: aString ifAbsent: [nil]) ifNotNil: [^ result].

	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNotNil: [
		(result := stage lists at: aString ifAbsent: [nil]) ifNotNil: [^ result]].

	self prototype ifNotNil: [^ self prototype listNamed: aString ifNone: aBlock].

	^ aBlock value



]

{ #category : #'list ops' }
ScriptablePhratchMorph >> listVarMenu [
	"Answer a menu for selecting a list variables."

	| result stage |
	result := #().
	((stage := self ownerOrYourselfThatIsA: PhratchStageMorph) notNil & (stage ~= self)) ifTrue: [
		result := stage listVarNames].

	self listVarNames size > 0 ifTrue: [
		result size > 0 ifTrue: [result := result copyWith: '-'].
		result := result, self listVarNames].

	result size > 0
		ifTrue: [^ #(''), result]
		ifFalse: [^ result]

]

{ #category : #'list ops' }
ScriptablePhratchMorph >> listVarNames [
	"Answer a list of list variable names."

	| lst |
	lst := lists keys asOrderedCollection.
	self prototype ifNotNil: [
		lst addAll: self prototype listVarNames ].

	^ lst asSet asArray sort


]

{ #category : #'list ops' }
ScriptablePhratchMorph >> lists [

	^ lists

]

{ #category : #byob }
ScriptablePhratchMorph >> localBlocks [
	^ self inheritedBlocks , (customBlocks ifNil: [ #() ]) reject: [ :eachDef | eachDef isGlobal ]
]

{ #category : #'looks ops' }
ScriptablePhratchMorph >> lookLike: costumeNameOrIndex [
	"Change to the costume indicated by the given name, index, or boolean. Noop if there is no costume of the given name in my library."
	"Note: Costumes can have names that look like numbers, but those numbers have nothing to do with the index of the costume. So, we first try interpreting the argument as a name. If that fails, we try interpreting it as a costume index number."

	| p newCostume i |
	p := self referencePosition.
	costume suspendPlaying.

	newCostume := nil.
	(costumeNameOrIndex isKindOf: String) ifTrue: [
		"try interpreting the argument as a costume name"
		newCostume := self costumeFromName: costumeNameOrIndex.

		"try interpreting the string as a number"
		newCostume ifNil: [
			i := self interpretStringAsNumberIfPossible: costumeNameOrIndex.
			i isNumber ifTrue: [
				newCostume := self costumeFromName: (self costumeNameFromNumber: i)]
				ifFalse: [^ self]]].  "string does not match a costume and cannot be coverted to a number"

	"treat other types (number, boolean) as a costume index"
	newCostume ifNil: [
		i := costumeNameOrIndex asNumberNoError.
		newCostume := self costumeFromName: (self costumeNameFromNumber: i)].

	newCostume ifNil: [^ self].  "should not happen..."

	costume := newCostume.
	(self isKindOf: PhratchSpriteMorph) ifTrue: [
		self setSizeTo: self scale ].		"adjust the size if it is really huge or tiny.-jens"
	costume resumePlaying.
	self costumeChanged.
	self referencePosition: p.
	World displayWorldSafely.

]

{ #category : #'right button menu' }
ScriptablePhratchMorph >> makeVisible [
	"Make sure that I am entirely on the screen and visible."

	self isHidden ifTrue: [self isHidden: false].
	visibility < 30 ifTrue: [self setGraphicEffect: 'ghost' to: 100].
	self scale < 10 ifTrue: [self setSizeTo: 100].
	(owner notNil and: [owner bounds containsPoint: self center]) ifFalse: [
		self gotoX: 0 y: 0 ].
	self comeToFront.
	World displayWorldSafely.

"	self viewBlocksAndScriptsQuickly."

]

{ #category : #'other ops' }
ScriptablePhratchMorph >> mathFunctionNames [
	"Answer a collection of math function names."

	^ #(
		'abs'
		'sqrt'
		'sin'
		'cos'
		'tan'
		'asin'
		'acos'
		'atan'
		'ln'
		'log'
		'e ^'
		'10 ^')

]

{ #category : #accessing }
ScriptablePhratchMorph >> media [

	^ media

]

{ #category : #media }
ScriptablePhratchMorph >> mediaNameFromFileName: fileName default: defaultName [
	"Answer a name for the given media item. If the existing name is '$$squeak$$' then the media was copied via windows drag-and-drop; use the given default name instead."

	| result |
	result := fileName basename.
	(result beginsWith: '$$squeak$$') ifTrue: [result := defaultName].
	result size > 16 ifTrue: [result := result copyFrom: 1 to: 16].
	^ result

]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> midiDrumMenu [
	"Provides a drop-down menu for setting the drum number."

	| menu |
	menu := MenuMorphNG new defaultTarget: self.
	#(	('Acoustic Bass Drum' 35)
		('Bass Drum 1' 36)
		('Side Stick' 37)
		('Acoustic Snare' 38)
		('Hand Clap' 39)
		('Electric Snare' 40)
		('Low Floor Tom' 41)
		('Closed Hi-Hat' 42)
		('High Floor Tom' 43)
		('Pedal Hi-Hat' 44)
		('Low Tom' 45)
		('Open Hi-Hat' 46)
		('Low-Mid Tom' 47)
		('Hi-Mid Tom' 48)
		('Crash Cymbal 1' 49)
		('High Tom' 50)
		('Ride Cymbal 1' 51)
		('Chinese Cymbal' 52)
		('Ride Bell' 53)
		('Tambourine' 54)
		('Splash Cymbal' 55)
		('Cowbell' 56)
		('Crash Cymbal 2' 57)
		('Vibraslap' 58)
		('Ride Cymbal 2' 59)
		('Hi Bongo' 60)
		('Low Bongo' 61)
		('Mute Hi Conga' 62)
		('Open Hi Conga' 63)
		('Low Conga' 64)
		('High Timbale' 65)
		('Low Timbale' 66)
		('High Agogo' 67)
		('Low Agogo' 68)
		('Cabasa' 69)
		('Maracas' 70)
		('Short Whistle' 71)
		('Long Whistle' 72)
		('Short Guiro' 73)
		('Long Guiro' 74)
		('Claves' 75)
		('Hi Wood Block' 76)
		('Low Wood Block' 77)
		('Mute Cuica' 78)
		('Open Cuica' 79)
		('Mute Triangle' 80)
		('Open Triangle' 81)
	) do: [:pair |
		menu
			add: (self numberInParens: pair second), (pair first localizedMIDI)
			value: pair second].
	menu invokeModal.
	^ menu 

]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> midiInstrument: aNumber [
	"Old 'set instrument to :=' block. Set the MIDI instrument used for note sounds."
	<phratchItem: 'set instrument to $Instruments$' kind: #- category: 'sound' defaultValues: #(1) subCategory: #a3>
	| stage player |
	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNil: [^ self].
	(player := stage notePlayerFor: self) ifNotNil: [
		player instrument: aNumber].

]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> midiInstrumentMenu [
	"Provides a drop-down menu for setting the instrument number."

	| menu |
	menu := MenuMorphNG  new.
	#(	('Acoustic Grand' 1)
		('Bright Acoustic' 2)
		('Electric Grand' 3)
		('Honky-Tonk' 4)
		('Electric Piano 1' 5)
		('Electric Piano 2' 6)
		('Harpsichord' 7)
		('Clavinet' 8)
		('Celesta' 9)
		('Glockenspiel' 10)
		('Music Box' 11)
		('Vibraphone' 12)
		('Marimba' 13)
		('Xylophone' 14)
		('Tubular Bells' 15)
		('Dulcimer' 16)
		('Drawbar Organ' 17)
		('Percussive Organ' 18)
		('Rock Organ' 19)
		('Church Organ' 20)
		('Reed Organ' 21)
		('Accordion' 22)
		('Harmonica' 23)
		('Tango Accordion' 24)
		('Nylon String Guitar' 25)
		('Steel String Guitar' 26)
		('Electric Jazz Guitar' 27)
		('Electric Clean Guitar' 28)
		('Electric Muted Guitar' 29)
		('Overdriven Guitar' 30)
		('Distortion Guitar' 31)
		('Guitar Harmonics' 32)
		('Acoustic Bass' 33)
		('Electric Bass (finger)' 34)
		('Electric Bass (pick)' 35)
		('Fretless Bass' 36)
		('Slap Bass 1' 37)
		('Slap Bass 2' 38)
		('Synth Bass 1' 39)
		('Synth Bass 2' 40)
		('Violin' 41)
		('Viola' 42)
		('Cello' 43)
		('Contrabass' 44)
		('Tremolo Strings' 45)
		('Pizzicato Strings' 46)
		('Orchestral Strings' 47)
		('Timpani' 48)
		('String Ensemble 1' 49)
		('String Ensemble 2' 50)
		('SynthStrings 1' 51)
		('SynthStrings 2' 52)
		('Choir Aahs' 53)
		('Voice Oohs' 54)
		('Synth Voice' 55)
		('Orchestra Hit' 56)
		('Trumpet' 57)
		('Trombone' 58)
		('Tuba' 59)
		('Muted Trumpet' 60)
		('French Horn' 61)
		('Brass Section' 62)
		('SynthBrass 1' 63)
		('SynthBrass 2' 64)
		('Soprano Sax' 65)
		('Alto Sax' 66)
		('Tenor Sax' 67)
		('Baritone Sax' 68)
		('Oboe' 69)
		('English Horn' 70)
		('Bassoon' 71)
		('Clarinet' 72)
		('Piccolo' 73)
		('Flute' 74)
		('Recorder' 75)
		('Pan Flute' 76)
		('Blown Bottle' 77)
		('Shakuhachi' 78)
		('Whistle' 79)
		('Ocarina' 80)
		('Lead 1 (square)' 81)
		('Lead 2 (sawtooth)' 82)
		('Lead 3 (calliope)' 83)
		('Lead 4 (chiff)' 84)
		('Lead 5 (charang)' 85)
		('Lead 6 (voice)' 86)
		('Lead 7 (fifths)' 87)
		('Lead 8 (bass+lead)' 88)
		('Pad 1 (new age)' 89)
		('Pad 2 (warm)' 90)
		('Pad 3 (polysynth)' 91)
		('Pad 4 (choir)' 92)
		('Pad 5 (bowed)' 93)
		('Pad 6 (metallic)' 94)
		('Pad 7 (halo)' 95)
		('Pad 8 (sweep)' 96)
		('FX 1 (rain)' 97)
		('FX 2 (soundtrack)' 98)
		('FX 3 (crystal)' 99)
		('FX 4 (atmosphere)' 100)
		('FX 5 (brightness)' 101)
		('FX 6 (goblins)' 102)
		('FX 7 (echoes)' 103)
		('FX 8 (sci-fi)' 104)
		('Sitar' 105)
		('Banjo' 106)
		('Shamisen' 107)
		('Koto' 108)
		('Kalimba' 109)
		('Bagpipe' 110)
		('Fiddle' 111)
		('Shanai' 112)
		('Tinkle Bell' 113)
		('Agogo' 114)
		('Steel Drums' 115)
		('Woodblock' 116)
		('Taiko Drum' 117)
		('Melodic Tom' 118)
		('Synth Drum' 119)
		('Reverse Cymbal' 120)
		('Guitar Fret Noise' 121)
		('Breath Noise' 122)
		('Seashore' 123)
		('Bird Tweet' 124)
		('Telephone Ring' 125)
		('Helicopter' 126)
		('Applause' 127)
		('Gunshot' 128)
	) do: [:pair |
		menu
			add: (self numberInParens: pair second), pair first localizedMIDI
			value: pair second asString].
	menu invokeModal.
	^ menu

]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> midiNoteMenu [
	"Provides a drop-down menu for setting the note number."

	| menu midiKey noteName |
	menu := MenuMorphNG new defaultTarget: self.
	midiKey := 48.
	#(#low #middle)
		do: [ :oct | 
			#(#C 'C#' #D 'Eb' #E #F 'F#' #G 'Ab' #A 'Bb' #B)
				do: [ :n | 
					noteName := n = #C
						ifTrue: [ oct , ' ' , n ]
						ifFalse: [ n ].
					menu add: '(' , midiKey printString , ') ' , noteName value: midiKey.
					midiKey := midiKey + 1 ] ].
	menu add: '(72) high C' value: 72.
	menu invokeModal.
	^ menu
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> mixColor: color1 ratioA: a toB: b with: color2 [
	<phratchItem: 'mix $Color$ $Number$ : $Number$ with $Color$' kind: #g category: 'colors' defaultValues: #() subCategory: #a6>
	^ color1 mixed: (a / (a + b)) with: color2.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> mixColor: color1 with: color2 [
	<phratchItem: 'mix $Color$ with $Color$' kind: #g category: 'colors' defaultValues: #() subCategory: #a6>
	^ color1 mixed: 0.5 with: color2.
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> mosaicEffect [

	| att |
	att := #mosaic.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ [filterPack mosaicCount] ifError: [0]
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> mosaicEffect: aNumber [

	self undeleteAttribute: #mosaic.
	self passiveMosaicEffect: aNumber
]

{ #category : #'event handling' }
ScriptablePhratchMorph >> mouseDown: evt [
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	evt hand newKeyboardFocus: nil.

	evt hand toolType ifNotNil: [
		self handleTool: evt hand toolType hand: evt hand.
		^ self].

	(owner isKindOf: PhratchStageMorph) ifFalse: [^ super mouseDown: evt].

	evt rightButtonPressed
		ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu]
		ifFalse:	[evt hand waitForClicksOrDrag: self event: evt].
]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> mousePressed [
	<phratchItem: 'mouse down?' kind: #b category: 'sensing' defaultValues: #() subCategory: #a2>
	^ Sensor redButtonPressed

]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> mouseX [
	<phratchItem: 'mouse x' kind: #r category: 'sensing' defaultValues: #() subCategory: #a21>
	| s centerX |
	DoubleSize ifTrue: [^ (Sensor lastMousePosition x - PhratchOrigin x) // 2].

	self inPresentationMode ifFalse: [
		s := self ownerOrYourselfThatIsA: PhratchStageMorph.
		(s notNil and: [s isQuarterSize]) ifTrue: [
			centerX := s left + (s width // 4).
			^ 2 * (Sensor lastMousePosition x - centerX)]].

	^ Sensor lastMousePosition x - PhratchOrigin x

]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> mouseY [
	<phratchItem: 'mouse y' kind: #r category: 'sensing' defaultValues: #() subCategory: #a21>
	| s centerY |
	DoubleSize ifTrue: [^ (Sensor lastMousePosition y - PhratchOrigin y) negated // 2].

	self inPresentationMode ifFalse: [
		s := self ownerOrYourselfThatIsA: PhratchStageMorph.
		(s notNil and: [s isQuarterSize]) ifTrue: [
			centerY := s top + (s height // 4).
			^ -2 * (Sensor lastMousePosition y - centerY)]].

	^ (Sensor lastMousePosition y - PhratchOrigin y) negated

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> moveVar: aVarName toX: x y: y [
	<phratchItem: 'move $Variable$ to x: $Number$ y: $Number$' kind: #- category: 'variables' defaultValues: #('' 0 0) subCategory: #a5>
	| stage |
	self positionVar: aVarName atX: x y: y.

	stage := self ownerThatIsA: PhratchStageMorph.
	stage ~= self ifTrue: [stage positionVar: aVarName atX: x y: y].
]

{ #category : #'other ops' }
ScriptablePhratchMorph >> mwait: duration elapsed: elapsed from: ignored [
	"Do nothing; just wait for the time interval to elapse."

	^ nil

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> n: aNumber toPower: aPower [
	<phratchItem: '$Number$ ^ $Number$' kind: #r category: 'operators' defaultValues: #(- -) subCategory: #a8>
	^ aNumber raisedTo: aPower
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> namedColors [

	^ Color colorNames.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> newCostumeTypes [

	^ #('camera'
		'stage'
		'paint new'
		'import').
]

{ #category : #byob }
ScriptablePhratchMorph >> newCustomBlockFor: aDefinition [

	| b |

	#none = aDefinition type
		ifTrue: [b := CustomCommandBlockMorph new receiver: self]
		ifFalse: [
			b := CustomReporterBlockMorph new receiver: self.
			b isBoolean: (aDefinition type = #boolean)].
	b userSpec: aDefinition userSpec.
	b isSpecialForm: true.
	b selector: #doCustomBlock.
	b setDefaultArgs.
	^ b

]

{ #category : #byob }
ScriptablePhratchMorph >> newList: aPhratchListMorph [
	<phratchItem: 'list $MAAny$' kind: #r category: 'list' defaultValues: #() subCategory: #a1>
	^aPhratchListMorph
]

{ #category : #'looks ops' }
ScriptablePhratchMorph >> nextCostume [
	"Show the next costume in my costumes list."
	self lookLike: self costumeIndex + 1.

]

{ #category : #private }
ScriptablePhratchMorph >> nextInstanceName [
	"Answer a name for a new instance. For sprites, an attempt is made to create a unique name of the form 'spriteN'."

	| stage lastN digits |
	self = PhratchStageMorph ifTrue: [^ 'Stage' localized].

	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNil: [^ 'Sprite' localized, 1 printString].
	lastN := 0.
	stage sprites ifNotNil: [
		stage sprites do: [:m |
			(m isKindOf: PhratchSpriteMorph) ifTrue: [
				digits := m objName trailingDigits.
				((digits size > 0) and: [m objName beginsWith: ('Sprite' localized)])
					ifTrue: [lastN := lastN max: digits asNumber]]]].

	^ 'Sprite' localized, (lastN + 1) printString

]

{ #category : #byob }
ScriptablePhratchMorph >> not [
	<phratchItem: 'not $Boolean$' kind: #b category: 'operators' defaultValues: #() subCategory: #a4>

]

{ #category : #byob }
ScriptablePhratchMorph >> notEditingBlock [
	| sf |
	sf := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	sf ifNil: [^true].
	^sf notEditingBlock
]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> noteOn: midiKey duration: beats elapsed: elapsedMSecs from: aNotePlayer [
	<phratchItem: 'play note $Notes$ for $Number$ beats' kind: #t category: 'sound' defaultValues: #(60 0.5) subCategory: #a3>
	| stage player |
	aNotePlayer ifNil: [  "first call, start playing the note"
		(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNil: [^ PhratchNotePlayer new].
		(player := stage notePlayerFor: self) ifNil: [^ PhratchNotePlayer new].
		^ player copy noteOn: midiKey].

	elapsedMSecs >= ((60000 * beats) // self tempo) ifTrue: [aNotePlayer noteOff].

]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> noteSelector [
	"Returns an instance of a PhratchNoteSelector for selecting notes. This object behaves like a CustomMenu."

	| stageMorph notePlayer |
	stageMorph := (self ownerOrYourselfThatIsA: PhratchStageMorph).
	stageMorph ifNil: [^ self midiNoteMenu].
	notePlayer := stageMorph notePlayerFor: self.
	notePlayer ifNil: [^ self midiNoteMenu].

	^ (PhratchNoteSelector new setNotePlayer: notePlayer)

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> numFileLines: aFileNameString [
	"Answer the contents of the given file."
	<phratchItem: 'number of lines of file $String$' kind: #r category: 'files' defaultValues: #() subCategory: #a>
	| f data |
	(self askForFileIO = true) ifFalse: [^ self].
	(aFileNameString asFileReference exists) ifFalse: [^ ''].
	f := (FileStream readOnlyFileNamed: aFileNameString) binary.
	f ifNil: [^ ''].
	data := f contentsOfEntireFile asString.
	f close.
	"Replace newlines:
	data replaceAll: $
 with: $ ."
	^ data lines size.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> numUrlFileLines: aURLString [
	<phratchItem: 'number of lines of file at URL $String$' kind: #r category: 'files' defaultValues: #('http://') subCategory: #a>
	^ (ZnHTTPSocketFacade httpGet: aURLString) contents lines size.
]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> numberInParens: aNumber [

	^ '(' , aNumber printString, ') '

]

{ #category : #'as yet unclassified' }
ScriptablePhratchMorph >> numberSort: t1 [ 
	<phratchItem: 'sort items of $List$ by numerical value' kind: #- category: 'list' defaultValues: #('list') subCategory: #a6>
    | t2 t3 t4 t5 t6 |
    t2 := #() asOrderedCollection.
    t3 := #() asOrderedCollection.
    t4 := #() asOrderedCollection.
    t6 := #() asOrderedCollection.
    t5 := 1.
    (self lineCountOfList: t1)
        timesRepeat: 
            [t2 add: (self getLine: t5 ofList: t1).
            t5 := t5 + 1].
    t2 do: 
        [:t7 | 
        t3 add: t7 asNumberNoError.
        t7 asNumberNoError = 0 ifTrue: [t4 add: t7]].
    t3 := t3 asArray sort.
    t3 := t3 asOrderedCollection.
    t5 := 1.
    t3 do: 
        [:t8 | 
        t8 = 0 ifFalse: [t6 add: t8].
        t8 = 0
            ifTrue: 
                [t6 add: (t4 at: t5).
                t5 := t5 + 1]].
    self deleteLine: 'all' ofList: t1.
    t6 do: [:t9 | self append: t9 toList: t1]
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> numericConstant: t1 [ 
	<phratchItem: '$Constants$' kind: #r category: 'operators' defaultValues: #('pi') subCategory: #a2>
	'pi' = t1 ifTrue: [^ Float pi].
	'e' = t1 ifTrue: [^ Float e].
	'newline' = t1 ifTrue: [^ String crlf].
	'tab' = t1 ifTrue: [^ '	']
]

{ #category : #accessing }
ScriptablePhratchMorph >> objName [
	<phratchItem: 'self' kind: #r category: 'control' defaultValues: #() subCategory: #self>
	^ objName

]

{ #category : #accessing }
ScriptablePhratchMorph >> objName: aString [

	"don't allow renaming a sprite to use a name already in use"
	(self spriteNameInUse: aString) ifTrue: [^ self].
	objName := aString.
	objName size = 0 ifTrue: [objName := self nextInstanceName].

]

{ #category : #'BYOB object interface' }
ScriptablePhratchMorph >> objectInterface [

	^ 
	{	"attribute					category		getter				setter				menu string			inheritable"

		#name				->	#(	sprite			objName 			objName:			'name'				-			).
		#isDraggable		->	#(	sprite			getIsDraggable		draggable:			'draggable?'			+			).
		#rotationStyle		->	#(	sprite			getRotationStyle 	setRotationStyle:		'rotation style'		+			).
		#rotateWithOwner	->	#(	sprite			rotateWithOwner 	rotateWithOwner:	'synchronous?'		+			).

		#xPosition			->	#(	motion			xpos 				xpos:				'x position'			+ 			).
		#yPosition			->	#(	motion			ypos 				ypos:				'y position'			+			).
		#heading			->	#(	motion			heading 			heading:			'direction'			+			).

		#costumes			->	#(	looks			costumes			-					'costumes'			+			).
		#costumeIndex		->	#(	looks			costumeIndex		lookLike:			'costume #'			+			).
		#size				->	#(	looks			scale				setSizeTo:			'size'				+			).
		#isHidden			->	#(	looks			isHidden				setHideFlagTo:		'hidden?'			+			).
		#layer				->	#(	looks			layer				setLayerTo:			'layer'				+			).

		#color				->	#(	effects			colorEffect			colorEffect:			'color effect'		+			).
		#fisheye			->	#(	effects			fisheyeEffect		fisheyeEffect:		'fisheye effect'		+			).
		#whirl				->	#(	effects			whirlEffect			whirlEffect:			'whirl effect'		+			).
		#pixelate			->	#(	effects			pixelateEffect		pixelateEffect:		'pixelate effect'		+			).
		#mosaic				->	#(	effects			mosaicEffect		mosaicEffect:		'mosaic effect'		+			).
		#brightness			->	#(	effects			brightnessEffect		brightnessEffect:	'brightness'			+			).
		#ghost				->	#(	effects			transparencyEffect	transparencyEffect:	'ghost effect'		+			).

		#sounds				->	#(	sound			sounds				-					'sounds'				+			).
		"#instrument			->	#(	sound			-					midiInstrument:		'instrument'			-			)."
		#volume			->	#(	sound			volume				setVolumeTo:		'volume'			+			).
		#tempo				->	#(	sound			tempo				setTempoTo:			'tempo'				+			).

		#penDown			->	#(	pen				penDown			penDown:			'pen down?'			+			).
		#penColor			->	#(	pen				penHue				setPenHueTo:		'pen color'			+			).
		#penShade			->	#(	pen				penShade			setPenShadeTo:		'pen shade'			+			).
		#penSize			->	#(	pen				penSize				penSize:				'pen size'			+			).

		#prototype			->	#(	relationship		prototype			prototype:			'parent'				-			).
		#instances			->	#(	relationship		children			-					'children'			-			).
		#anchor			->	#(	relationship		ownerSprite			stickTo:				'anchor'			+			).
		#parts				->	#(	relationship		parts				-					'parts'				-			).

	} asDictionary
]

{ #category : #media }
ScriptablePhratchMorph >> onlyCostume: aForm [
	"Remove all my costumes, then make a new costume using the given Form."

	| el |
	media := media select: [:m | m isSound].

	el := ImageMedia new form: aForm.
	el mediaName: 'costume'.
	media addLast: el.
	self lookLike: el mediaName.
	self updateMediaCategory.

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> openCamera [
	<phratchItem: 'open camera' kind: #- category: 'looks' defaultValues: #() subCategory: #a9>
	self cameraIsOpen ifFalse: [
			(CameraPlugin openCamera: 1 width: 480 height: 360) ifNotNil: [
				CameraPlugin waitForCameraStart.]
	].
	CameraOpenings := CameraOpenings +1.
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> passiveBrightnessEffect: aNumber [

	self privateSetGraphicEffect: 'brightness' to: aNumber asNumberNoError.
	self propagate: #brightness
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> passiveColorEffect: aNumber [

	self privateSetGraphicEffect: 'color' to: aNumber asNumberNoError.
	self propagate: #color.
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> passiveFisheyeEffect: aNumber [

	self privateSetGraphicEffect: 'fisheye' to: aNumber asNumberNoError.
	self propagate: #fisheye
]

{ #category : #'as yet unclassified' }
ScriptablePhratchMorph >> passiveLookLike: costumeName [

	self subclassResponsibility 
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> passiveMosaicEffect: aNumber [

	self privateSetGraphicEffect: 'mosaic' to: aNumber asNumberNoError.
	self propagate: #mosaic

]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> passivePixelateEffect: aNumber [

	self privateSetGraphicEffect: 'pixelate' to: aNumber asNumberNoError.
	self propagate: #pixelate
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> passiveSetHideFlagTo: aBool [

	(aBool isKindOf: Boolean) 
		ifFalse: [^ self error: 'expecting a Boolean'].
	self isHidden: aBool.
	self spread.
	self propagate: #isHidden
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> passiveSetLayerTo: aNumber [

	self layer: aNumber asNumberNoError truncated.
	self spread.
	self propagate: #layer
]

{ #category : #'byob OOP' }
ScriptablePhratchMorph >> passiveSetVolumeTo: aNumber [

	| stage player |
	volume := aNumber asNumberNoError within: 0 and: 100.
	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNotNil: [
		(player := stage notePlayerFor: self) ifNotNil: [
			player volume: volume]].

	media do: [:snd |
		snd isSound ifTrue: [snd volume: volume]].

	self propagate: #volume


]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> passiveTransparencyEffect: aNumber [

	self privateSetGraphicEffect: 'ghost' to: aNumber asNumberNoError.
	self propagate: #ghost
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> passiveWhirlEffect: aNumber [

	self privateSetGraphicEffect: 'whirl' to: aNumber asNumberNoError.
	self propagate: #whirl
]

{ #category : #menu }
ScriptablePhratchMorph >> pause [
	<phratchItem: 'pause' kind: #- category: 'control' defaultValues: #() subCategory: #startstop>
    DialogBoxMorph warn: 'Paused: Click OK to continue'.
	self updateAfterPopUp.
]

{ #category : #'looks ops' }
ScriptablePhratchMorph >> penDown [
	"Overriden by sprites."

	^ false

]

{ #category : #scripts }
ScriptablePhratchMorph >> phratchFrame [

	| frame w |
	frame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	frame ifNil: [
		(w := self ownerOrYourselfThatIsA: OffscreenWorldMorph) ifNil: [^ nil].
		frame := w frame].
	^ frame


]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> pixelateEffect [

	| att |
	att := #pixelate.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ [filterPack pixelateCount] ifError: [0]
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> pixelateEffect: aNumber [

	self undeleteAttribute: #pixelate.
	self passivePixelateEffect: aNumber
]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> playSound: soundName [
	<phratchItem: 'play sound $SoundNames$' kind: #- category: 'sound' defaultValues: #() subCategory: #a1>
	| snd |
	snd := self soundNamed: soundName ifAbsent: [^ self].
	snd playFromStart.

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> positionVar: varName atX: x y: y [
	| frame w b newX newY p |
	(self varNames includes: varName)
		ifFalse: [ ^ self ].
	frame := self ownerThatIsA: PhratchFrameMorph.
	frame
		ifNil: [ 
			(w := self ownerThatIsA: OffscreenWorldMorph) ifNil: [ ^ self ].
			frame := w frame ].
	b := VariableBlockMorph new
		commandSpec: varName;
		receiver: self blockReceiver;
		yourself.
	(w := frame watcherForBlock: b) ifNil: [ ^ self ].
	newX := x.
	newX isNaN
		ifTrue: [ newX := 0 ].
	newX := newX min: 240.
	newX := newX max: -240 - w extent x.
	newY := y.
	newY isNaN
		ifTrue: [ newY := 0 ].
	newY := newY max: -180.
	newY := newY min: 180 + w extent y.
	p := newX @ newY negated.
	w position: PhratchOrigin + p
]

{ #category : #scripts }
ScriptablePhratchMorph >> prepareForExport [
	self blocksBin allMorphsDo: [:m |
		(m isKindOf: BlockMorph) ifTrue: [m stop].
		(m isKindOf: SpriteArgMorph) ifTrue: [m clearMorphReference]].

	customBlocks ifNotNil: [
		customBlocks do: [:eachDef |
			eachDef body ifNotNil: [
				eachDef body allMorphsDo: [:m |
					(m isKindOf: SpriteArgMorph) ifTrue: [m clearMorphReference]]].
			(eachDef answer isKindOf: Morph) ifTrue: [
				eachDef answer allMorphsDo: [:m |
					(m isKindOf: SpriteArgMorph) ifTrue: [m clearMorphReference]]]]].

	self convertStacksToTuples.

	(self isKindOf: PhratchSpriteMorph) ifTrue: [
		self subsprites do: [:sub |
			sub prepareForExport ]]

]

{ #category : #'as yet unclassified' }
ScriptablePhratchMorph >> pressGreenFlag [
	<phratchItem: 'press green flag' kind: #- category: 'control' defaultValues: #() subCategory: #startstop>
	| sFrame |
	sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	sFrame pressGreenFlagButton
]

{ #category : #private }
ScriptablePhratchMorph >> printSummaryOn: aStream [
	| costumes snds stacks hats otherStacks |
	aStream
		nextPutAll: 'Sprite: ';
		nextPutAll: self objName;
		crlf.
	costumes := media select: [ :item | item isImage ].
	aStream
		nextPutAll: '  Costumes (';
		nextPutAll: costumes size printString;
		nextPutAll: '):';
		crlf.
	costumes
		do: [ :item | 
			aStream
				nextPutAll: '    ';
				nextPutAll: item mediaName;
				nextPutAll: ' (';
				nextPutAll: item infoString;
				nextPutAll: ')';
				crlf ].
	snds := media select: [ :item | item isSound ].
	aStream
		nextPutAll: '  Sounds (';
		nextPutAll: snds size printString;
		nextPutAll: '):';
		crlf.
	snds
		do: [ :item | 
			aStream
				nextPutAll: '    ';
				nextPutAll: item mediaName;
				nextPutAll: ' (';
				nextPutAll: item infoString;
				nextPutAll: ')';
				crlf ].
	stacks := blocksBin submorphs select: [ :m | m isKindOf: BlockMorph ].
	stacks size = 0
		ifTrue: [ 
			aStream
				nextPutAll: '  No stacks.';
				crlf;
				crlf.
			^ self ].
	aStream
		nextPutAll: '  Stacks (';
		nextPutAll: stacks size printString;
		nextPutAll: '):';
		crlf.
	hats := stacks select: [ :m | m isKindOf: HatBlockMorph ].
	otherStacks := stacks reject: [ :m | m isKindOf: HatBlockMorph ].
	hats , otherStacks
		do: [ :item | 
			item printCodeOn: aStream indent: 1.
			(item isKindOf: ReporterBlockMorph)
				ifTrue: [ aStream crlf ].
			aStream crlf ]
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> privateSetGraphicEffect: effect to: aNumber [
	"Set the given graphic effect to the given value."

	filterPack ifNil: [filterPack := FilterPack new].

	'brightness' = effect ifTrue: [filterPack brightnessShift: aNumber].
	'fisheye' = effect ifTrue: [filterPack fisheye: aNumber].
	'color' = effect ifTrue: [filterPack hueShift: aNumber].
	'mosaic' = effect ifTrue: [filterPack mosaicCount: aNumber].
	'pixelate' = effect ifTrue: [filterPack pixelateCount: aNumber].
	'ghost' = effect ifTrue: [self transparency: aNumber].
	'whirl' = effect ifTrue: [filterPack whirl: aNumber].

	costumeChangeMSecs := Time millisecondClockValue.
	self layoutChanged.
	self changed.
	self spread
]

{ #category : #private }
ScriptablePhratchMorph >> projectDirectory [
	"Answer the directory containing this Phratch project or the default directory."

	| frame |
	(frame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ FileSystem workingDirectory].
	^ frame projectDirectory

]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> promptForInput: questionString [

	| s prompter |
	(s := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNil: [^ self].
	prompter := PhratchPrompterMorph new.
	((self isKindOf: PhratchStageMorph) | (self isHidden))
		ifTrue: [
			prompter question: questionString]
		ifFalse: [
			self showQuestion: questionString.
			prompter sprite: self].

	prompter left: s center x - (prompter width // 2).
	prompter bottom: s bottom - 5.
	prompter isSticky: true.

	s addMorphFront: prompter.
	prompter grabKeyboardFocus.
"	World doOneCycle."

	^ prompter

	
]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> promptInProgress [

	| s |
	(s := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNil: [^ false].
	s submorphsDo: [:m |
		(m isKindOf: PhratchPrompterMorph) ifTrue: [^ true]].
	^ false

]

{ #category : #'byob OOP' }
ScriptablePhratchMorph >> propagate: attributeName [
	"private - apply the method calling me to all subsprites"

	| sel args instances |
	instances := self instances select: [:each |
		each deletedAttributes includes: attributeName].
	instances isEmpty ifTrue: [^self].
	sel := thisContext sender method selector.
	args := OrderedCollection new.
	1 to: thisContext sender method numArgs do: [:idx |
		args add: (thisContext sender tempAt: idx) ].
	instances do: [:eachPart |
		args isEmpty
			ifTrue: [ eachPart perform: sel]
			ifFalse: [ eachPart perform: sel withArguments: args asArray]]
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> propagateCostumes [

	self instances do: [:child |
		child inheritCostumesNow]
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> propagateSounds [

	self instances do: [:child |
		child inheritSoundsNow]
]

{ #category : #'byob OOP' }
ScriptablePhratchMorph >> prototype [
	(self isKindOf: PhratchSpriteMorph)
		ifTrue: [^ self prototype]
		ifFalse: [^ nil]
]

{ #category : #byob }
ScriptablePhratchMorph >> purgeVarsAndLists [

	vars keysDo: [:each |
		((vars at: each) isKindOf: BlockMorph)
			ifTrue: [vars at: each put: '']].

"
	vars keysDo: [:each |
		(((vars at: each) isKindOf: PhratchListMorph) or: [(vars at: each) isKindOf: BlockMorph ])
			ifTrue: [vars at: each put: '']].

"
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> quietCreateListNamed: listName [
	<phratchItem: 'make list $String$' kind: #- category: 'list' defaultValues: #('a list') subCategory: #a2>
	| list stage n |
	(self variableNameInUse: listName) ifTrue: [^ self].

	lists at: listName put: (list := PhratchListMorph new listName: listName target: self).
	(stage := self ownerThatIsA: PhratchStageMorph) ifNotNil: [
		n := (stage submorphs select: [:m | m isKindOf: PhratchListMorph]) size.
		stage addMorph: (list position: stage topRight - ((list width + 10)@0) + (0@(10+(20*n)))).
		list startStepping].
	self showOrHideList: listName show: false.
]

{ #category : #'other ops' }
ScriptablePhratchMorph >> randomFrom: start to: stop [
	"Answer a random number within the given range. If both min and max are integers, the result is rounded to the nearest integer."

	<phratchItem: 'pick random $Number$ to $Number$' kind: #r category: 'operators' defaultValues: #(1 10) subCategory: #a2>
	| min max result |
	min := start min: stop.
	max := start max: stop.
	result := RandomGen next * (max - min) + min.
	result := min isInteger & max isInteger
		ifTrue: [ (RandomGen next * (max + 1 - min)) truncated + min ]
		ifFalse: [ RandomGen next * (max - min) + min ].
	^ result
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> readFile: aFileNameString [
	"Answer the contents of the given file."
	<phratchItem: 'contents of file $String$' kind: #r category: 'files' defaultValues: #() subCategory: #a>
	| f data |
	(self askForFileIO = true) ifFalse: [^ self].
	(aFileNameString asFileReference exists) ifFalse: [^ ''].
	f := (FileStream readOnlyFileNamed: aFileNameString) binary.
	f ifNil: [^ ''].
	data := f contentsOfEntireFile asString.
	f close.
	^ data
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> readFromUrl: aURLString [
	<phratchItem: 'contents of file at URL $String$' kind: #r category: 'files' defaultValues: #('http://') subCategory: #a>
	^ (ZnHTTPSocketFacade httpGet: aURLString) contents.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> readLine: t1 FromUrl: t2 [ 
	<phratchItem: 'line $Number$ of file at URL $String$' kind: #r category: 'files' defaultValues: #(1 'http://') subCategory: #a>
	^ (ZnHTTPSocketFacade httpGet: t2) contents lines at: t1 ifAbsent: [''].
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> readLine: lineNum ofFile: aFileNameString [
	"Answer the contents of the given file."
	<phratchItem: 'line $Number$ of file $String$' kind: #r category: 'files' defaultValues: #() subCategory: #a>
	| f data |
	(self askForFileIO = true) ifFalse: [^ self].
	(aFileNameString asFileReference exists) ifFalse: [^ ''].
	f := (FileStream readOnlyFileNamed: aFileNameString) binary.
	f ifNil: [^ ''].
	data := f contentsOfEntireFile asString.
	f close.
	^ data lines at: lineNum ifAbsent: [''].
]

{ #category : #media }
ScriptablePhratchMorph >> recordSound [

	| frame |
	frame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	frame ifNil: [^ Beeper beep].
	frame stopAll.
	World submorphs do: [:m |
		(m isKindOf: PhratchSoundRecorderDialogMorph) ifTrue: [m delete]].

	PhratchSoundRecorderDialogMorph forClient: self.


]

{ #category : #'dropping/grabbing' }
ScriptablePhratchMorph >> rejectDropEvent: evt [
	"Reject being dropped by the given event."

	(self owner isKindOf: PhratchStageMorph)
		ifFalse: [ ^ evt hand rejectDropMorph: self event: evt ]
		ifTrue: [ ^ false ]
]

{ #category : #accessing }
ScriptablePhratchMorph >> renewFilterPack [

	filterPack := FilterPack new.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> replaceCostume: aNumber with: aString [
	
	| cList i newC name j m frameForm title result fList type |
	cList := media reject: [:l | l isSound].
	cList size = 0 ifTrue: [^ self].  "should never happen..."
	i := ((aNumber rounded - 1) \\ cList size) + 1.
	name := (cList at: i) mediaName.
	aString = 'camera' ifTrue: [
		"newC := ImageMedia new form: (Form extent: (self ownerThatIsA: ScratchStageMorph) extent) fillBlack."
		"(CameraPlugin openCamera: 1 width: 480 height: 360) ifNotNil: [
			CameraPlugin waitForCameraStart.
			(CameraPlugin frameExtent: 1) x = 0 ifFalse: ["
		self cameraIsOpen ifTrue: [
			frameForm := Form extent: (CameraPlugin frameExtent: 1) depth: 32.
			CameraPlugin getFrameForCamera: 1 into: frameForm bits.
			newC := ImageMedia new form: frameForm]
		ifFalse: [^ self]]."]]]."
	aString = 'stage' ifTrue: [newC := ImageMedia new form: ((self ownerOrYourselfThatIsA: PhratchStageMorph) stageShotForm"Sized: 480@360")].
	aString = 'paint new' ifTrue: [self editDrawingOldCostumeName: name deleteOnCancel: false deleteCostume: false.
		self flag:'crappy line to solve Issue 53:	some blocks are executable only once'.
		^ self updateAfterPopUp.
		].
	aString = 'import' ifTrue: [
		(self isKindOf: PhratchStageMorph)
			ifTrue: [type := #background. title := 'Import Background']
			ifFalse: [type := #costume. title := 'Import Costume'].
		result := PhratchFileChooserDialog
			chooseImageFileType: type
			title: title.
		result = #cancelled ifTrue: [^ self updateAfterPopUp.].

		fList := OrderedCollection new.
		[fList addLast: (Form fromFileNamed: result)] ifError: [^ self updateAfterPopUp].

		newC := ImageMedia new form: fList first.
		self updateAfterPopUp].
	j := 1.
	newC mediaName: name.
	[j <= media size] whileTrue: [
		m := media at: j.
		((m isSound not) and: [m mediaName = name]) ifTrue: [
			media at: j put: newC.
			self lookLike: name.
			^ self updateMediaCategory.].
		j := j + 1].
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> reportColor: colorName [
	"Answer the value of the given user color variable of this object or its parent."
	<phratchItem: '$ColorVar$' kind: #g category: 'colors' defaultValues: #('') subCategory: #a1>
	| stage |
	(self colorNames includes: colorName)
		ifTrue: [^ self getColor: colorName].
	(stage := self ownerThatIsA: PhratchStageMorph)
		ifNotNil: [^ stage getColor: colorName]
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> reportVar: varName [
	"Answer the value of the given user variable of this object or its parent."
	<phratchItem: '$Variable$' kind: #r category: 'variables' defaultValues: #('') subCategory: #a3>
	| stage |
	(self varNames includes: varName)
		ifTrue: [^ self getVar: varName].
	(stage := self ownerThatIsA: PhratchStageMorph)
		ifNotNil: [^ stage getVar: varName]

]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> rest: duration elapsed: elapsed from: ignored [
	"Do nothing; just wait for the time interval to elapse."
	<phratchItem: 'rest for $Number$ beats' kind: #t category: 'sound' defaultValues: #(0.2) subCategory: #a2>
	^ nil

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> returnW: aTypeString [
	<phratchItem: 'date/time: $TimeDates$' kind: #r category: 'operators' defaultValues: #() subCategory: #a2>
	| time date |
	time := Time now.
	date := Date today.
	'time' = aTypeString ifTrue: [^ time asString].
	'hour' = aTypeString ifTrue: [^ time hours].
	'minute' = aTypeString ifTrue: [^ time minutes].
	'second' = aTypeString ifTrue: [^ time seconds].
	'date' = aTypeString ifTrue: [^ date asString].
	'weekday-name' = aTypeString ifTrue: [^ date weekday].
	'weekday-#' = aTypeString
		ifTrue: 
			[date weekday = 'Monday' ifTrue: [^ 1].
			date weekday = 'Tuesday' ifTrue: [^ 2].
			date weekday = 'Wednesday' ifTrue: [^ 3].
			date weekday = 'Thursday' ifTrue: [^ 4].
			date weekday = 'Friday' ifTrue: [^ 5].
			date weekday = 'Saturday' ifTrue: [^ 6].
			date weekday = 'Sunday' ifTrue: [^ 7]].
	'month-name' = aTypeString ifTrue: [^ date monthName asString].
	'month-#' = aTypeString ifTrue: [^ date monthIndex].
	'day of month' = aTypeString ifTrue: [^ date dayOfMonth].
	'day of year' = aTypeString ifTrue: [^ date daysInYear - date daysLeftInYear].
	'year' = aTypeString ifTrue: [^ date year].
	^ 0
]

{ #category : #media }
ScriptablePhratchMorph >> revertToCostume: oldCostumeName [
	"Sent by the paint editor if editing of a newly-created costume is cancelled. Delete the new costume and revert to the old costume with the given name."

	| newlyCreatedCostume |
	newlyCreatedCostume := costume.
	self lookLike: oldCostumeName.
	media remove: newlyCreatedCostume ifAbsent: [].
	self updateMediaCategory.

	self undeleteAttribute: #costumes.
	self propagateCostumes

]

{ #category : #'right button menu' }
ScriptablePhratchMorph >> rightButtonMenu [
	"This default implementation does nothing."

]

{ #category : #accessing }
ScriptablePhratchMorph >> rotatedForm [
	"By default, just return my costume form. Sprites override this method to do rotation."

	^ self costumeForm


]

{ #category : #accessing }
ScriptablePhratchMorph >> rotationCenter: aPoint [
	"Set my costume's rotation center."

	costume rotationCenter: aPoint.
	self costumeChanged.

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> rounded [
	<phratchItem: 'round $Number$' kind: #r category: 'operators' defaultValues: #(-) subCategory: #a8>

]

{ #category : #media }
ScriptablePhratchMorph >> savePhoto: aForm [

	| n |
	n := self unusedMediaNameFromBaseName: 'costume' localized, '1'.
	self addMediaItem: (ImageMedia new mediaName: n; form: aForm;
		yourself).

	self undeleteAttribute: #costumes.
	self propagateCostumes



]

{ #category : #'as yet unclassified' }
ScriptablePhratchMorph >> saveProj [
	<phratchItem: 'save project' kind: #- category: 'control' defaultValues: #() subCategory: #project>
| t1 |
t1 := self ownerThatIsA: PhratchFrameMorph.
t1 savePhratchProject
]

{ #category : #media }
ScriptablePhratchMorph >> saveSound: aSampledSound name: baseName [

	| sndItem |
	sndItem := SoundMedia new.
	sndItem mediaName: (self unusedMediaNameFromBaseName: baseName).
	media addLast: sndItem.

	sndItem sound: aSampledSound.
	self updateMediaCategory.

	self undeleteAttribute: #sounds.
	self propagateSounds

]

{ #category : #'looks ops' }
ScriptablePhratchMorph >> sayNothing [
	"Default behavior does nothing. Overridden in PhratchSpriteMorph."

]

{ #category : #'looks ops' }
ScriptablePhratchMorph >> sceneNames [

	^ (self ownerOrYourselfThatIsA: PhratchStageMorph) sceneNames

]

{ #category : #scripts }
ScriptablePhratchMorph >> scripts [
	"Answer my scripts, a collection of HatBlockMorphs."

	(blocksBin isKindOf: Morph) ifFalse: [^ blocksBin].
	^ blocksBin submorphs select: [:m | m isKindOf: HatBlockMorph]

]

{ #category : #networking }
ScriptablePhratchMorph >> serialized [
	"Answer a ByteArray containing this Phratch object in serialized form."

	| s objToExport |
	s := WriteStream on: (ByteArray new: 100000).
	objToExport := self copyForExport.
	objToExport firstSubmorph allSubsprites do: [:eachSub |
		eachSub owner ifNil: [objToExport addMorphBack: eachSub ]].
	ObjStream new storeObj: objToExport on: s showProgress: false.
	^ s contents


]

{ #category : #'BYOB object interface' }
ScriptablePhratchMorph >> set: anObject to: aValue [
	<phratchItem: 'set $Attributes$ to $String$' kind: #- category: 'operators' defaultValues: #() subCategory: #b3>
	| oi sel obj att block arg |
	oi := self objectInterface.
	(anObject isKindOf: Symbol)
		ifTrue: [ 
			sel := oi at: anObject ifAbsent: [ ^ self error: 'unknown attribute: ' , anObject asString ].
			sel third = #-
				ifTrue: [ ^ self error: 'cannot set r/o attribute' ].
			^ self perform: sel third with: aValue ].
	(anObject isKindOf: String)
		ifTrue: [ ^ self setVar: anObject to: aValue ].
	(anObject isKindOf: CommandScriptBlockMorph)
		ifTrue: [ 
			obj := anObject receiver.
			(obj isKindOf: ScriptablePhratchMorph)
				ifFalse: [ ^ self error: 'cannot get attributes of non-Sprites/Stage' ].
			block := anObject body argMorphs first.
			(block isKindOf: VariableBlockMorph)
				ifTrue: [ ^ obj setVar: block variable to: aValue ].
			#get: = block selector
				ifTrue: [ 
					arg := block argumentAt: 1.
					att := (arg isKindOf: ChoiceArgMorph)
						ifTrue: [ (block argumentAt: 1) choice ]
						ifFalse: [ (block argumentAt: 1) evaluate ] ]
				ifFalse: [ 
					att := oi keys
						detect: [ :key | (oi at: key) second = block selector ]
						ifNone: [ ^ self error: 'no attribute found for selector: ' , anObject selector ] ].
			^ obj set: att to: aValue ].
	self error: [ 'cannot set this value' ]
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> setColor: colorName to: newValue [
	<phratchItem: 'set $ColorVar$ to $Color$' kind: #- category: 'colors' defaultValues: #('') subCategory: #a1>
	| cName stage |
	cName := colorName asString. "convert Symbol to String if needed"
	(colors includesKey: cName) ifFalse: [
		stage := self ownerThatIsA: PhratchStageMorph.
		(stage notNil and: [stage ~= self]) ifTrue: [
			stage setColor: cName to: newValue].
		^ self].

	colors at: cName put: newValue.
]

{ #category : #'looks ops' }
ScriptablePhratchMorph >> setGraphicEffect: effect to: aNumber [
	"Set the given graphic effect to the given value."
	<phratchItem: 'set $Effects$ effect to $Number$' kind: #- category: 'looks' defaultValues: #('color' 0) subCategory: #a3>
	
	'brightness' = effect ifTrue: [self brightnessEffect: aNumber].
	'fisheye' = effect ifTrue: [self fisheyeEffect: aNumber].
	'color' = effect ifTrue: [self colorEffect: aNumber].
	'mosaic' = effect ifTrue: [self mosaicEffect: aNumber].
	'pixelate' = effect ifTrue: [self pixelateEffect: aNumber].
	'ghost' = effect ifTrue: [self transparencyEffect: aNumber].
	'whirl' = effect ifTrue: [self whirlEffect: aNumber].

]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> setHideFlagTo: aBool [

	self undeleteAttribute: #isHidden.
	self passiveSetHideFlagTo: aBool
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> setLayerTo: aNumber [

	self undeleteAttribute: #layer.
	self passiveSetLayerTo: aNumber
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> setLayoutOfVar: varName to: aString [
	<phratchItem: 'set layout of $Variable$ to $LayoutStyles$' kind: #- category: 'variables' defaultValues: #('' '') subCategory: #a5>
	| symbol b w frame stage |
	symbol := aString asSymbol.
	frame := self ownerThatIsA: PhratchFrameMorph.
	frame ifNil: [
		(w := self ownerThatIsA: OffscreenWorldMorph) ifNil: [^ self].
		frame := w frame].
	(self varNames includes: varName) ifFalse: [
		stage := frame workPane.
		(stage varNames includes: varName) ifTrue: [^ stage setLayoutOfVar: varName to: aString.].].
	
	b := VariableBlockMorph new commandSpec: varName; receiver: self blockReceiver;
		yourself.
	w := frame watcherForBlock: b.
	w ifNotNil: [w layoutStyle: symbol].
]

{ #category : #'list ops' }
ScriptablePhratchMorph >> setLine: lineNum ofList: listName to: anObject [
	<phratchItem: 'replace item $ListIndex$ of $List$ with $String$' kind: #- category: 'list' defaultValues: #(1 'list' 'thing') subCategory: #a4>
	| list |
	list := self listNamed: listName ifNone: [^ ''].
	^ list setLineAt: (self lineNum: lineNum forList: list) to: (self asListElement: anObject)

]

{ #category : #media }
ScriptablePhratchMorph >> setMedia: mediaCollection [
	"Set my media to the given collection when copying."

	media := mediaCollection.

]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> setTempoTo: aNumber [
	<phratchItem: 'set tempo to $Number$ bpm' kind: #- category: 'sound' defaultValues: #(60) subCategory: #a5>
	| stage |
	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNil: [^ self].
	stage setTempoTo: aNumber.

]

{ #category : #variables }
ScriptablePhratchMorph >> setVar: varName to: newValue [
	"Set the value of the given variable of this object to the given value."
	<phratchItem: 'set $Variable$ to $String$' kind: #- category: 'variables' defaultValues: #('' '0') subCategory: #a4>
	| vName stage sf w |

	"BYOB OOP interface:"
	(varName isKindOf: CommandScriptBlockMorph) ifTrue: [
		^ self set: varName to: newValue].

	vName := varName asString. "convert Symbol to String if needed"
	(vars includesKey: vName) ifFalse: [
		(self prototype notNil and: [self prototype varNames includes: varName])
			ifTrue: [
				vars at: vName put: newValue.
				sf := self ownerOrYourselfThatIsA: PhratchFrameMorph.
				sf ifNil: [^ self].
				sf viewerPane categoryChanged: #variables.
				w := sf watcherForBlock: (VariableBlockMorph new 
						receiver: self; 
						commandSpec: varName; 
						yourself).
				w ifNotNil: [
				w setCategoryColor: (ScriptablePhratchMorph blockColorFor: 'variables').
				^ self]].
			stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
		(stage notNil and: [stage ~= self]) 
			ifTrue: [stage setVar: varName to: newValue].
		^ self ].

	vars at: vName put: newValue.

]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> setVolumeTo: aNumber [
	<phratchItem: 'set volume to $Number$' kind: #- category: 'sound' defaultValues: #(100) subCategory: #a4>
	self undeleteAttribute: #volume.
	self passiveSetVolumeTo: aNumber

]

{ #category : #networking }
ScriptablePhratchMorph >> shareObject [
	"send this object to all peers"

	| server |
	server := (self ownerOrYourselfThatIsA: PhratchStageMorph) phratchServer.
	server ifNil: [^self].
	server sendSprite: self

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> showAskDialogWithText: text [ 
	<phratchItem: 'ask $String$ in dialog' kind: #- category: 'sensing' defaultValues: #('What''s your name?') subCategory: #a1>
	"Show an information dialog with the given title and text."
	PhratchPrompterMorph lastAnswer: (StringDialog ask: text).
	
	self flag:'crappy line to solve Issue 53:	some blocks are executable only once'.
	self updateAfterPopUp.
	
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> showColor [
	"Ask the user which user variable to show, then show it."

	| sFrame stage menu choice |
	sFrame := self ownerThatIsA: PhratchFrameMorph.
	sFrame ifNil: [^ self].

	stage := sFrame workPane.
	(stage colorNames isEmpty) & (self colorNames isEmpty)
		ifTrue: [^ self inform: 'No colors.' localized].

	menu := MenuMorphNG new.
	stage colorNames do: [:v | menu add: v value: (Array with: v with: #global)].
	self = stage ifFalse: [
		stage colorNames isEmpty ifFalse: [menu addLine].
		self colorNames do: [:v | menu add: v value: (Array with: v with: #local)]].
	choice := menu invokeModal; selectedValue;
		yourself.
	choice ifNil: [^ self].

	choice second = #global
		ifTrue: [stage showColor: choice first]
		ifFalse: [self showColor: choice first].

	sFrame viewerPane categoryChanged: 'colors'.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> showColor: varName [
	"Show the watcher for the given variable. If the receiver is a sprite and both it and and the stage have the given variable, hide both. Do nothing if the variable does not exist or is already hidden."
	<phratchItem: 'show color $ColorVar$' kind: #- category: 'colors' defaultValues: #('') subCategory: #a2>
	| stage |
	self showOrHideColor: varName show: true.

	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	stage ~= self ifTrue: [stage showOrHideColor: varName show: true].
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> showInformDialog: title withText: text [ 
	<phratchItem: 'show dialog $String$ with text $String$' kind: #- category: 'sensing' defaultValues: #('info' '') subCategory: #a1>
	"Show an information dialog with the given title and text."
	DialogBoxMorph inform: text title: title.
	
	self flag:'crappy line to solve Issue 53:	some blocks are executable only once'.
	self updateAfterPopUp.
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> showList: aList [
	"Show the given list"
	<phratchItem: 'show list $List$' kind: #- category: 'list' defaultValues: #() subCategory: #a3>
	self showOrHideList: aList show: true
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> showOrHideColor: varName show: showFlag [
	"Show the watcher for the given variable. Do nothing if the variable does not exist or is already showing."

	| frame w b palette |
	(self colorNames includes: varName) ifFalse: [^ self].
	frame := self ownerThatIsA: PhratchFrameMorph.
	frame ifNil: [
		(w := self ownerThatIsA: OffscreenWorldMorph) ifNil: [^ self].
		frame := w frame].

	b := (self blockFromSpec: #('$ColorVar$' g reportColor: '')  color: (self class blockColorFor: 'colors')) defaultArgs: {varName}.
	w := frame watcherForBlock: b.
	showFlag
		ifTrue: [w ifNil: [frame showWatcher: b createWatcher]]
		ifFalse: [w ifNotNil: [w delete]].

	palette := frame viewerPane pageViewer contents.
	palette ifNotNil: [palette updateWatcherButtonsForFrame: frame].

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> showOrHideList: aList show: aBoolean [
	"Show or hide the given list"
 
	| list stage sFrame |
	(stage := self ownerThatIsA: PhratchStageMorph).
	(self listVarNames includes: aList)
		ifFalse: [stage
			ifNotNil: [(stage listVarNames includes: aList)
				ifTrue: [list := stage lists at: aList]
				ifFalse: [^ self]]
			ifNil: [^ self]]
		ifTrue: [list := lists at: aList].
	aBoolean
		ifTrue: [stage addMorph: list]
		ifFalse: [list delete].
	(sFrame := self ownerThatIsA: PhratchFrameMorph) ifNil: [^ self].
	sFrame viewerPane categoryChanged: 'variables'
]

{ #category : #variables }
ScriptablePhratchMorph >> showOrHideVariable: varName show: showFlag [
	"Show the watcher for the given variable. Do nothing if the variable does not exist or is already showing."

	| frame w b palette |
	(self varNames includes: varName) ifFalse: [^ self].
	frame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	frame ifNil: [
		(w := self ownerOrYourselfThatIsA: OffscreenWorldMorph) ifNil: [^ self].
		frame := w frame].

	b := VariableBlockMorph new commandSpec: varName; receiver: self blockReceiver;
		yourself.
	w := frame watcherForBlock: b.
	showFlag
		ifTrue: [w ifNil: [frame showWatcher: b createWatcher]]
		ifFalse: [w ifNotNil: [w delete]].

	palette := frame viewerPane pageViewer contents.
	palette ifNotNil: [palette updateWatcherButtonsForFrame: frame].

]

{ #category : #variables }
ScriptablePhratchMorph >> showVariable: varName [
	"Show the watcher(s) for the given variable. If the receiver is a sprite and both it and and the stage have the given variable, show both. Do nothing if the variable does not exist or is already showing."
	<phratchItem: 'show variable $Variable$' kind: #- category: 'variables' defaultValues: #() subCategory: #a2>
	| stage |
	self showOrHideVariable: varName show: true.

	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	stage ~= self ifTrue: [stage showOrHideVariable: varName show: true].


]

{ #category : #media }
ScriptablePhratchMorph >> soleCostume: imageMedia [
	"Make the given image my only costume."

	media := media reject: [ :item | item isImage ].
	self addMediaItem: imageMedia
]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> soundFromIndex: aNumber [
	"Return a sound for the given number--rounded and modulo the number of costumes. Return nil if there are not sounds."

	| soundList i |
	soundList := media select: [:m | m isSound].
	soundList size = 0 ifTrue: [^ nil].

	i := ((aNumber rounded - 1) \\ soundList size) + 1.
	^ soundList at: i

]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> soundLevel [
	<phratchItem: 'loudness' kind: #r category: 'sensing' defaultValues: #() subCategory: #a4>
	^ self class soundRecorder meterLevel

]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> soundNamed: soundNameOrIndex ifAbsent: absentBlock [
	"Return a SoundMedia with the given name (ignoring case differences) or index. If there is none, return the result of evaluating the given block."

	| snd i |
	snd := nil.
	(soundNameOrIndex isKindOf: String) ifTrue: [ "first, try using the argument as a sound name"
		snd := media
			detect: [:el | el isSound and: [el mediaName caseInsensitiveEqual: soundNameOrIndex]]
			ifNone: [nil].

		snd ifNil: [
			i := self interpretStringAsNumberIfPossible: soundNameOrIndex.
			i isNumber ifTrue: [
				snd := self soundFromIndex: i]].

		snd ifNil: [^ absentBlock value]].

	snd ifNil: [snd := self soundFromIndex: soundNameOrIndex asNumberNoError].

	snd
		ifNil: [^ absentBlock value]
		ifNotNil: [^ snd]


]

{ #category : #media }
ScriptablePhratchMorph >> soundNames [
	"Answer a list of my sound names. Suppress duplicates (ignoring case differences)."

	| result nm |
	result := OrderedCollection new.
	media do: [:el |
		el isSound ifTrue: [
			nm := el mediaName.
			(result anySatisfy: [:s | s caseInsensitiveEqual: nm])
				ifFalse: [result add: nm]]].
	result addLast: '-'.
	result addLast: 'record' localized, PhratchTranslator ellipsesSuffix.
	^ result asArray

]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> sounds [
	"this will at some future time answer first class sounds,
	for now it's just the sound names"

	^ PhratchListMorph on: ((media select: [:m | 
		m isSound]) collect: [:c | c mediaName])
]

{ #category : #blocks }
ScriptablePhratchMorph >> soundsPage: xOffset [
	"Answer a morph containing thumbnails of my sounds."

	| bin m y sounds n recBut impBut maxHeight yMargin xMargin separator |
	xMargin := 15.
	yMargin := 15.

	bin := PhratchBlockPaletteMorph new.

	m := StringMorph
		contents: 'New sound:' localized
		font: (PhratchFrameMorph getFont: #SoundsPage).
	m color: Color white.
	bin addMorph: m.

	recBut := PhratchFrameMorph buttonLabel: 'Record' localized selector: #recordSound.
	recBut target: self.
	bin addMorph: recBut.

	impBut := PhratchFrameMorph buttonLabel: 'Import' localized selector: #importSound.
	impBut target: self.
	bin addMorph: impBut.

	maxHeight := (m height max: (impBut height max: recBut height)).
	PhratchTranslator isRTL
		ifTrue: [impBut position: xMargin@(yMargin + ((maxHeight - impBut height) / 2)).
			recBut position: (impBut right + 4)@(yMargin + ((maxHeight - recBut height) / 2)).
			m position: (recBut right + 4)@(yMargin + ((maxHeight - m height) / 2))]
		ifFalse: [m position: xMargin@(yMargin + ((maxHeight - m height) / 2)).
			recBut position: (m right + 4)@(yMargin + ((maxHeight - recBut height) / 2)).
			impBut position: (recBut right + 4)@(yMargin + ((maxHeight - impBut height) / 2))].

	separator := TiledImageMorph new tileForm: (PhratchFrameMorph skinAt: #costumeSeparatorTile).
	bin addMorph: (separator position: (xOffset + 17)@(yMargin + maxHeight + 5)).

	n := 0.
	y := yMargin + maxHeight + 9.
	sounds := media select: [:item | item isSound].
	sounds do: [:item |
		m := MediaItemMorph new.
		m phratchObj: self media: item; position: xOffset@y.
		m setNumber: (n := n + 1).
		bin addMorph: m.
		y := y + m height - 1].

	bin submorphs size > 0
		ifTrue: [separator width: bin firstSubmorph width - 14]
		ifFalse: [separator width: 240].

	^ bin

]

{ #category : #nesting }
ScriptablePhratchMorph >> spread [
	"overridden by my subclasses. Default is to do nothing"
]

{ #category : #private }
ScriptablePhratchMorph >> spriteNameInUse: aString [

	| s |
	(s := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNotNil: [
		s submorphs do: [:m |
			m == self ifFalse: [
				((m isKindOf: ScriptablePhratchMorph) and:
				 [m objName caseInsensitiveEqual: aString]) ifTrue: [
					^ true]]]].

	^ false

]

{ #category : #blocks }
ScriptablePhratchMorph >> stackFromTupleList: tupleList receiver: scriptOwner [
	"Answer a new block stack from the given sequence of tuples."
	"self stackFromTupleList: #() receiver: nil"

	| stackTop previousBlock block |
	stackTop := previousBlock := nil.
	tupleList do: [:tuple | 
		block := self blockFromTuple: tuple receiver: scriptOwner.
		previousBlock
			ifNil: [stackTop := block]
			ifNotNil: [previousBlock nextBlock: block].
		previousBlock := block].

	^ stackTop

]

{ #category : #'event handling' }
ScriptablePhratchMorph >> startDrag: evt [
	"This is a drag gesture; pick me up."

	| rootForGrab |
	rootForGrab := owner rootForGrabOf: self.
	rootForGrab ifNil: [^ self].
	rootForGrab position: evt hand position + (self topLeft - evt cursorPoint).
	evt hand grabMorph: rootForGrab.

]

{ #category : #stepping }
ScriptablePhratchMorph >> step [

	costume mediaStep ifTrue: [self costumeChanged].

]

{ #category : #stepping }
ScriptablePhratchMorph >> stepTime [

	^ 0

]

{ #category : #'other ops' }
ScriptablePhratchMorph >> stopAll [
	"Stop everything!"
	<phratchItem: 'stop all' kind: #- category: 'control' defaultValues: #() subCategory: #startstop>
	| stage |
	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	stage ifNotNil: [stage stopAll].

]

{ #category : #byob }
ScriptablePhratchMorph >> stopAllScriptsFor: eventName [
	<phratchItem: 'stop all scripts for $Event$' kind: #- category: 'control' defaultValues: #() subCategory: #startstop>
	| stage |
	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNotNil: [
		stage stopAllScriptsFor: eventName].

]

{ #category : #'other ops' }
ScriptablePhratchMorph >> stopAllSounds [
	"Stop all sounds and MIDI notes/drums."
	<phratchItem: 'stop all sounds' kind: #- category: 'sound' defaultValues: #() subCategory: #a1>
	| stage |
	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	stage ifNotNil: [stage stopAllSounds].

]

{ #category : #private }
ScriptablePhratchMorph >> stopPlaying [
	"Stop playing all movies and sounds."

	| firstCostume |
	costume stopPlaying.
	self filterReset.
	self setVolumeTo: 100.	"reset volume"	"exit camera mode"
	(costume isKindOf: CameraMedia)
		ifFalse: [ ^ self ].
	firstCostume := media detect: [ :el | el isImage ] ifNone: [ ^ self ].
	self lookLike: firstCostume mediaName
]

{ #category : #byob }
ScriptablePhratchMorph >> stopScriptsFor: eventName [
	"Stop all my running stacks with an EventHat matching the given event name."

	((eventName = 'Phratch-KeyPressedEvent') | (eventName = 'Phratch-MouseClickEvent'))
		ifFalse: [ self scripts do: [:s |
			((s class == EventHatMorph) and: [s eventName caseInsensitiveEqual: eventName])
				ifTrue: [s stop]]]
]

{ #category : #'object i/o' }
ScriptablePhratchMorph >> storeFieldsOn: anObjStream [

	| oldBlockBinOwner |
	super storeFieldsOn: anObjStream.
	(blocksBin isKindOf: Morph) ifTrue: [
		oldBlockBinOwner := blocksBin owner.
		blocksBin delete].

	self purgeVarsAndLists.

	self storeFieldsNamed: #(
		objName
		vars
		blocksBin
		customBlocks
		isClone
		media
		costume
	) on: anObjStream.

	oldBlockBinOwner ifNotNil: [oldBlockBinOwner addMorph: blocksBin].

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> stringAsColor: aString [
	<phratchItem: '$String$ as color' kind: #g category: 'colors' defaultValues: #('#FFFFFF') subCategory: #a7>
	^ Color fromString: (aString asString).
]

{ #category : #'string ops' }
ScriptablePhratchMorph >> stringLength: anObject [
	<phratchItem: 'length of $String$' kind: #r category: 'operators' defaultValues: #('world') subCategory: #a6>
	^ anObject asString size

]

{ #category : #'as yet unclassified' }
ScriptablePhratchMorph >> stringSort: t1 [
	<phratchItem: 'sort items of $List$ by string value' kind: #- category: 'list' defaultValues: #('list') subCategory: #a6> 
    | t2 t3 |
    (self lineCountOfList: t1)
        = 0 ifTrue: [^ self].
    (self lineCountOfList: t1)
        = 1 ifTrue: [^ self].
    t2 := #() asOrderedCollection.
    t3 := 1.
    (self lineCountOfList: t1)
        timesRepeat: 
            [t2 add: (self getLine: t3 ofList: t1).
            t3 := t3 + 1].
    t2 := t2 asArray sort.
    self deleteLine: 'all' ofList: t1.
    t2 do: [:t4 | self append: t4 toList: t1]
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> stringToBoolean: aString [
	"Answer the given string as a boolean."
	<phratchItem: '$String$ as boolean' kind: #b category: 'operators' defaultValues: #('true') subCategory: #b1>
	| s |
	s := aString asString.
	((s = '0') or: [s = '' or: [s = 'false']]) ifTrue: [^ false] ifFalse: [^ true].
]

{ #category : #media }
ScriptablePhratchMorph >> takePhoto [
	"Take a photo."

	PhratchCameraDialog new
		client: self;
		openInWorld;
		openCamera.

]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> tempo [
	<phratchItem: 'tempo' kind: #r category: 'sound' defaultValues: #() subCategory: #a5>
	| stage |
	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNil: [^ 60].
	^ stage tempo

]

{ #category : #'byob OOP' }
ScriptablePhratchMorph >> thumbnailImageForm [

	^ self imageForm toThumbnail: 50@50 borderWidth: 0 borderColor: Color transparent
]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> timeDates [
	^ #('time' 'hour' 'minute' 'second' 'date' 'day of month' 'day of year' 'weekday-name' 'weekday-#' 'month-name' 'month-#' 'year' )
]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> timer [
	<phratchItem: 'timer' kind: #r category: 'sensing' defaultValues: #() subCategory: #timer>
	| now |
	now := Time millisecondClockValue.
	TimerStartMSecs ifNil: [ TimerStartMSecs := now ].
	TimerStartMSecs := TimerStartMSecs min: now.
	^ (now - TimerStartMSecs) asFloat / 1000.0
]

{ #category : #'sensing ops' }
ScriptablePhratchMorph >> timerReset [
	<phratchItem: 'reset timer' kind: #- category: 'sensing' defaultValues: #() subCategory: #timer>
	TimerStartMSecs := Time millisecondClockValue.

]

{ #category : #'as yet unclassified' }
ScriptablePhratchMorph >> times: t1 List: t2 [ 
<phratchItem: 'times $String$ appears in $List$' kind: #r category: 'list' defaultValues: #('' 'list') subCategory: #a5>
    | t3 t4 |
    t3 := 1.
    t4 := 0.
    (self lineCountOfList: t2)
        timesRepeat: 
            [(self getLine: t3 ofList: t2)
                = t1 ifTrue: [t4 := t4 + 1].
            t3 := t3 + 1].
    ^ t4
]

{ #category : #'looks ops' }
ScriptablePhratchMorph >> transparency [
	"Answer my transparency. 0 is opaque; 100 is transparent."

	^ 100 - self visibility

]

{ #category : #'looks ops' }
ScriptablePhratchMorph >> transparency: aNumber [
	"Set my transparency. 0 is opaque; 100 is transparent."

	self visibility: (100 - aNumber abs).

]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> transparencyEffect [

	| att |
	att := #ghost.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ self transparency
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> transparencyEffect: aNumber [

	self undeleteAttribute: #ghost.
	self passiveTransparencyEffect: aNumber
]

{ #category : #'BYOB object interface' }
ScriptablePhratchMorph >> undeleteAllAttributes [

	deletedAttributes := nil
]

{ #category : #'BYOB object interface' }
ScriptablePhratchMorph >> undeleteAllBlocks [

	self inheritedBlocks do: [:eachDef |
		self ensureOwnBlockExists: eachDef]
]

{ #category : #'byob OOP' }
ScriptablePhratchMorph >> undeleteAllVariables [
	"... and lists"

	self varNames do: [:vn |
		self setVar: vn to: (self getVar: vn)].

	self listVarNames do: [:ln |
		lists at: ln put: (self listNamed: ln)]
]

{ #category : #'BYOB object interface' }
ScriptablePhratchMorph >> undeleteAttribute: aSymbol [

	| oi sf cat block w |
	deletedAttributes ifNil: [
		deletedAttributes := Set new].
	deletedAttributes remove: aSymbol ifAbsent: [^ nil].

	"update palette"
	
	oi := self objectInterface.
	sf := self phratchFrame.
	sf ifNil: [^ self].
	cat := (oi at: aSymbol) first.
	sf viewerPane categoryChanged: cat.

	"update watchers"

	block := self blockForSelector: ((oi at: aSymbol) second).
	block ifNil: [^ self].
	w := sf watcherForBlock: block.
	w ifNil: [^ self].
	w setCategoryColor: block color
]

{ #category : #private }
ScriptablePhratchMorph >> undoableDeleteSprite [
	"Delete the sprite and store it in the clipboard in case of an undo."

	self notEditingBlock ifFalse: [^self].
	self unhinge; unhingeAll.
	PhratchFrameMorph putInClipboard: self.
	self deleteSprite.

]

{ #category : #byob }
ScriptablePhratchMorph >> unloadUnusedCustomBlocks [

	customBlocks ifNil: [^ self].
	customBlocks do: [:block |
		(self allInstancesOf: block id) isEmpty ifTrue: [
			self deleteDefinitionId: block id]]
]

{ #category : #media }
ScriptablePhratchMorph >> unusedMediaNameFromBaseName: baseName [
	"Answer an unused name for a new media item with the given base name. Strip off the file extension, if any."

	^ self unusedMediaNameFromBaseName: baseName forMedia: nil
]

{ #category : #media }
ScriptablePhratchMorph >> unusedMediaNameFromBaseName: baseName forMedia: aMedia [
	"Answer an unused name for a new media item with the given base name. Strip off the file extension, if any.  med is the sound or costume media which is currently being renamed."

	| nm i existingNames greatestNum |
	nm := baseName.
	i := nm indexOf: $..
	i > 1
		ifTrue: [ nm := nm copyFrom: 1 to: i - 1 ].
	nm size = 0
		ifTrue: [ 
			aMedia
				ifNil: [ nm := 'new' localized , '1' ]
				ifNotNil: [ 
					nm := aMedia isImage
						ifTrue: [ self defaultImageMedia mediaName ]
						ifFalse: [ 'sound' localized , '1' ] ] ].
	existingNames := Set new.
	media
		do: [ :m | 
			m = aMedia
				ifFalse: [ existingNames add: (String withAll: m mediaName) ] ].
	(nm size > 0 and: [ nm last isDigit ])
		ifFalse: [ 
			(existingNames includes: (String withAll: nm))
				ifFalse: [ ^ nm ] ].	"remove trailing digits, if any"
	i := nm size.
	[ i > 1 and: [ (nm at: i) isDigit ] ] whileTrue: [ i := i - 1 ].
	[ i > 1 and: [ (nm at: i) = Character space ] ] whileTrue: [ i := i - 1 ].
	nm := nm copyFrom: 1 to: i.
	greatestNum := 0.
	existingNames
		do: [ :n | 
			i := n size.
			[ i > 1 and: [ (n at: i) isDigit ] ] whileTrue: [ i := i - 1 ].
			(n copyFrom: 1 to: i) = nm
				ifTrue: [ greatestNum := (n copyFrom: i + 1 to: n size) asNumber max: greatestNum ] ].
	^ nm , (greatestNum + 1) printString
]

{ #category : #'as yet unclassified' }
ScriptablePhratchMorph >> updateAfterPopUp [

	self flag:'crappy line to solve Issue 53:	some blocks are executable only once'.
	PhratchFrameMorph allInstancesDo:[:d | d  updateWorkPane].
]

{ #category : #byob }
ScriptablePhratchMorph >> updateCustomBlockDefinitionId: id with: newDef [

	| oldDef |

	oldDef := self definitionFor: id.
	customBlocks removeAllSansError: {oldDef. newDef}.
	self ensureCustomBlockExists: newDef.

	self prototype ifNotNil: [
		(self prototype definitionFor: newDef id) ifNotNil: [
			self ensureOwnBlockExists: newDef]]
]

{ #category : #byob }
ScriptablePhratchMorph >> updateLocalId: id withSpec: newUserSpec [

	"a userSpec has been changed by way of drag'n'drop"

	| def affected sf |
	sf := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	sf ifNil: [^self].
	affected := self instancesOf: id.
	def := self definitionFor: id. 
	def ifNil: [self error: 'block definition not found'. ^ self ].
	def userSpec: newUserSpec.
	affected do: [:eachBlock|
		eachBlock
			color: def blockColor;

			privateSetUserSpec: newUserSpec;
			commandSpec: def commandSpec;
"			userSpec: newUserSpec;"

			addLabel].
	sf blockEditors do: [:be |
		be definition id = id ifTrue: [
			be definition: def
"			be template color: def blockColor.
			be buildVariables "]].

	sf viewerPane categoryChanged: 'variables'.
	#none = def category ifFalse: [
		sf viewerPane categoryChanged: def category asString ].

	WatcherMorph allInstancesDo: [:inst | inst step].
]

{ #category : #private }
ScriptablePhratchMorph >> updateMediaCategory [
	"Update the media category in the viewer, if it is showing."

	| sFrame |
	sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	sFrame ifNotNil: [
		sFrame projectModified.
		sFrame updateMediaCategoryFor: self.
		sFrame viewerPane refresh].


]

{ #category : #byob }
ScriptablePhratchMorph >> updateOnlyLocalId: id withSpec: newUserSpec [

	"a userSpec has been changed by way of drag'n'drop
	don't update block editors"

	| def affected sf |
	sf := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	sf ifNil: [^self].
	affected := self instancesOf: id.
	def := self definitionFor: id. 
	def userSpec: newUserSpec.
	affected do: [:eachBlock|
		eachBlock
			color: def blockColor;

			privateSetUserSpec: newUserSpec;
			commandSpec: def commandSpec;
			addLabel].

	sf viewerPane categoryChanged: 'variables'.
	#none = def category ifFalse: [
		sf viewerPane categoryChanged: def category asString ].

	WatcherMorph allInstancesDo: [:inst | inst step].
]

{ #category : #variables }
ScriptablePhratchMorph >> varNames [
	"Answer a list of variable names."

	| lst |
	lst := vars keys asSet.
	self prototype ifNotNil: [
		lst addAll: self prototype varNames ].

	^ lst asSet asArray

]

{ #category : #variables }
ScriptablePhratchMorph >> varNamesMenu [
	"Answer a list of variable names."

	| varList stage |
	varList := #().
	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNotNil: [varList := stage varNames].
	self == stage ifFalse: [
		varList size > 0 ifTrue: [varList := varList copyWith: #-].
		varList := varList, self varNames].

	^ varList
]

{ #category : #variables }
ScriptablePhratchMorph >> variableBlockColor [

	^ Color h: 25 s: 0.88 v: 0.95


]

{ #category : #blocks }
ScriptablePhratchMorph >> variableBlockFromTuple: tuple receiver: scriptOwner [
	"Answer a new block for the given variable reference tuple."

	| varName rcvr bg selector block arg argBlock |

	#byob = tuple first ifFalse: [
		^self variableBlockFromTupleOldForm: tuple receiver: scriptOwner ].

	varName := tuple at: 4.
	rcvr := scriptOwner.
	(varName isKindOf: Array) ifFalse: [
		varName = '' ifFalse: [
			(scriptOwner varNames includes: varName) ifFalse: [
				bg := scriptOwner ownerOrYourselfThatIsA: PhratchStageMorph.
				bg
					ifNil: [scriptOwner addVariable: varName]
					ifNotNil: [
						bg addVariable: varName.
						"rcvr := bg"]]]].

	tuple third = #readVariable ifTrue: [
		^ VariableBlockMorph new
			commandSpec: varName;
			selector: #getVar:;
			receiver: rcvr;
		yourself].

	tuple third = #changeVariable ifTrue: [
		selector := tuple at: 5.
		"update selector if necessary (backward compatibility):"
		(selector = #set:to:) ifTrue: [selector := #setVar:to:].
		block := SetterBlockMorph new.
		block receiver: rcvr.
		selector = #setVar:to:
			ifTrue: [block initSetterForVar: varName]
			ifFalse: [block initChangerForVar: varName].

		block receiver: rcvr.

		arg := tuple at: 6.
		(arg isKindOf: Array)
			ifTrue: [  "argument is a block"
				((arg size = 1) and: [arg first isKindOf: Array]) ifTrue: [arg := arg first].
				argBlock := self blockFromTuple: arg receiver: scriptOwner.
				block replaceArgMorph: block expressionArg by: argBlock]
			ifFalse: [ "argument is a value"
				block expressionArg defaultValue: arg].

		^ block].

	self error: 'unknown variable spec'

]

{ #category : #blocks }
ScriptablePhratchMorph >> variableBlockFromTupleOldForm: tuple receiver: scriptOwner [
	"Answer a new block for the given variable reference tuple."

	| varName rcvr bg selector block arg argBlock |

	varName := tuple at: 2.
	rcvr := scriptOwner.
	(scriptOwner varNames includes: varName) ifFalse: [
		bg := scriptOwner ownerOrYourselfThatIsA: PhratchStageMorph.
		bg
			ifNil: [scriptOwner addVariable: varName]
			ifNotNil: [
				bg addVariable: varName.
				"rcvr := bg"]].

	tuple first = #readVariable ifTrue: [
		^ VariableBlockMorph new
			commandSpec: varName;
			selector: #getVar:;
			receiver: rcvr;
		yourself].

	tuple first = #changeVariable ifTrue: [
		selector := tuple at: 3.
		"update selector if necessary (backward compatibility):"
		(selector = #set:to:) ifTrue: [selector := #setVar:to:].
		block := SetterBlockMorph new.
		selector = #setVar:to:
			ifTrue: [block initSetterForVar: varName]
			ifFalse: [block initChangerForVar: varName].

		block receiver: rcvr.

		arg := tuple at: 4.
		(arg isKindOf: Array)
			ifTrue: [  "argument is a block"
				((arg size = 1) and: [arg first isKindOf: Array]) ifTrue: [arg := arg first].
				argBlock := self blockFromTuple: arg receiver: scriptOwner.
				block replaceArgMorph: block expressionArg by: argBlock]
			ifFalse: [ "argument is a value"
				block expressionArg defaultValue: arg].

		^ block].

	self error: 'unknown variable spec'

]

{ #category : #variables }
ScriptablePhratchMorph >> variableNameInUse: varName [
	"Answer true if the given variable name in the receiver would conflict with an existing variable or list. For example, if the receiver is the Stage and the given variable name is used by any sprite."

	| stage |
	(self allVarNames includes: varName) ifTrue: [^ true].

	self isSprite
		ifTrue: [
			(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNil: [^ false].
			^ stage allVarNames includes: varName]
		ifFalse: [
			submorphs do: [:m |
				(m isKindOf: PhratchSpriteMorph) ifTrue: [
					(m allVarNames includes: varName) ifTrue: [^ true]]]].

	^ false

]

{ #category : #byob }
ScriptablePhratchMorph >> vars [
	^vars
]

{ #category : #private }
ScriptablePhratchMorph >> vars: varsDict lists: listsDict blocksBin: aBlocksBin [
	"Private! Set my variables and blocks bin. Used by copyRecordingIn:."

	vars := varsDict.
	lists := listsDict.
	blocksBin := aBlocksBin.

]

{ #category : #blocks }
ScriptablePhratchMorph >> viewBlocksAndScripts [

	| sFrame editor viewer tabs |
	self isClone ifTrue: [^ self].

	(sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ self].
	editor := sFrame scriptsPane.
	viewer := sFrame viewerPane.
	tabs := sFrame scriptsPane tabPane.
	sFrame view: self tab: tabs currentTab category: viewer currentCategory.

	self world ifNotNil: [
		self zoomRectFrom: self bounds to: editor bounds].

]

{ #category : #byob }
ScriptablePhratchMorph >> viewBlocksAndScriptsQuickly [

	| sFrame viewer tabs |
	self isClone ifTrue: [^ self].

	(sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ self].
	viewer := sFrame viewerPane.
	tabs := sFrame scriptsPane tabPane.
	sFrame view: self tab: tabs currentTab category: viewer currentCategory.

"
	self world ifNotNil: [
		self zoomRectFrom: self bounds to: editor bounds].

"
]

{ #category : #blocks }
ScriptablePhratchMorph >> viewerPageForCategory: aCategoryName [
	"Answer a morph containing blocks for the given category for use in the given PhratchViewer."

	^(PhratchCategory allSubclasses detect:[:e | e label = aCategoryName]) viewerPageFor: self.
]

{ #category : #'looks ops' }
ScriptablePhratchMorph >> visibility [
	"Answer my visibility. 0 is invisible. 100 is fully opaque."

	^ visibility

]

{ #category : #'looks ops' }
ScriptablePhratchMorph >> visibility: aNumber [
	"Set my visibility. 0 is invisible. 100 is fully opaque."

	visibility := (aNumber max: 0) min: 100.
	self changed.

]

{ #category : #'sound ops' }
ScriptablePhratchMorph >> volume [
	<phratchItem: 'volume' kind: #r category: 'sound' defaultValues: #() subCategory: #a4>
	| att |
	att := #volume.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ volume

]

{ #category : #'other ops' }
ScriptablePhratchMorph >> wait: duration elapsed: elapsed from: ignored [
	"Do nothing; just wait for the time interval to elapse."
	<phratchItem: 'wait $Number$ secs' kind: #t category: 'control' defaultValues: #(1) subCategory: #time>
	^ nil

]

{ #category : #'other ops' }
ScriptablePhratchMorph >> whenEventReceived [
	<phratchItem: 'when I receive $Event$' kind: #E category: 'control' defaultValues: #() subCategory: #ahat>
]

{ #category : #'other ops' }
ScriptablePhratchMorph >> whenFlagClicked [
	<phratchItem: 'when $Sprite$ clicked' kind: #S category: 'control' defaultValues: #() subCategory: #ahat>
]

{ #category : #'other ops' }
ScriptablePhratchMorph >> whenKeyPressed [
	<phratchItem: 'when $Keys$ key pressed' kind: #K category: 'control' defaultValues: #() subCategory: #ahat>
]

{ #category : #'other ops' }
ScriptablePhratchMorph >> whenSpriteClicked [
	<phratchItem: 'when $Sprite$ clicked' kind: #M category: 'control' defaultValues: #() subCategory: #ahat>
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> whirlEffect [

	| att |
	att := #whirl.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ [filterPack whirl] ifError: [0]
]

{ #category : #'BYOB attributes' }
ScriptablePhratchMorph >> whirlEffect: aNumber [

	self undeleteAttribute: #whirl.
	self passiveWhirlEffect: aNumber
]

{ #category : #blocks }
ScriptablePhratchMorph >> wholeBlockSpecForSelector: aSymbol [
	"Answer a block specification string (in English) for the give selector or nil if there is no spec that has the given selector."

	self class blockSpecs do: [:spec |
		((spec isKindOf: Array) and: [(spec at: 3) = aSymbol])
			ifTrue: [^ spec]].

	^ nil

]

{ #category : #'panther actions' }
ScriptablePhratchMorph >> writeText: aString toFile: aFileNameString [
	"Answer the contents of the given file."
	<phratchItem: 'write $String$ to file $String$' kind: #- category: 'files' defaultValues: #() subCategory: #a>
	| f |
	(self askForFileIO = true) ifFalse: [^ self].
	(aFileNameString asFileReference exists) ifFalse: [^ self].
	f := (FileStream fileNamed: aFileNameString) binary.
	f ifNil: [^ self].
	f setToEnd.
	f nextPutAll: aString.
	f close
]

{ #category : #private }
ScriptablePhratchMorph >> zoomRectFrom: startRect to: finalRect [

	| steps r p1 p2 |
	steps := 8.
	r := startRect.
	Display border: r width: 2 rule: Form reverse fillColor: Color gray.
	Display forceDisplayUpdate.
	0 to: steps do: [:i |
		(Delay forMilliseconds: 35) wait.
		Display border: r width: 2 rule: Form reverse fillColor: Color gray.
		Display forceDisplayUpdate.
		p1 := startRect origin + ((i * (finalRect origin - startRect origin)) // steps).
		p2 := startRect corner + ((i * (finalRect corner - startRect corner)) // steps).
		r := p1 corner: p2.
		Display border: r width: 2 rule: Form reverse fillColor: Color gray.
		Display forceDisplayUpdate].
	(Delay forMilliseconds: 35) wait.
	Display border: r width: 2 rule: Form reverse fillColor: Color gray.
	Display forceDisplayUpdate.

]

{ #category : #byob }
ScriptablePhratchMorph >> | aBoolean [
	<phratchItem: '$Boolean$ or $Boolean$' kind: #b category: 'operators' defaultValues: #() subCategory: #a4>

]
