"
I represent the background of the Scratch work pane. Like a sprite, I have a set of media and can change my costume. I also have my own scripts and variables. The main difference between me and a sprite is that I am fixed in position: I cannot move or rotate.

"
Class {
	#name : #PhratchStageMorph,
	#superclass : #ScriptablePhratchMorph,
	#instVars : [
		'hPan',
		'vPan',
		'penTrailsForm',
		'lastPenPositions',
		'runningBlocks',
		'inProcessStep',
		'midiPortNum',
		'midiPort',
		'notePlayerDict',
		'sprites',
		'isQuarterSize',
		'cachedForm',
		'feedbackMorph',
		'phratchServer'
	],
	#category : #'Phratch-Objects'
}

{ #category : #'dropping/grabbing' }
PhratchStageMorph >> acceptDroppingMorph: aMorph event: evt [

	self isQuarterSize ifTrue: [
		aMorph center: (2 * aMorph center) - self position.
		self changed].

	self addMorph: aMorph.
	self isInWorld ifTrue: [self world startSteppingSubmorphsOf: aMorph].
	((aMorph respondsTo: #penDown) and: [aMorph penDown])
		ifTrue: [self penUpOrDownChangeFor: aMorph].
	self changed.


]

{ #category : #'panther actions' }
PhratchStageMorph >> addBackgroundTyped: aString [
	<phratchItem: 'add $NewCostume$ to backgrounds' kind: #- category: 'looks' defaultValues: #() subCategory: #a2>
	self addCostumeTyped: aString.
]

{ #category : #'-- all --' }
PhratchStageMorph >> adjustedCursorPoint [
	"Answer the current mouse cursorPoint adjusted for the scaling presentation and q-mode."

	DoubleSize
		ifTrue: [^((Sensor lastMousePosition - self center) // 2) + self center].
	isQuarterSize
		ifTrue: [^((Sensor lastMousePosition - self position) * 2) + self position].
	^Sensor lastMousePosition





]

{ #category : #clones }
PhratchStageMorph >> allClones [
	"Answer a collection of all sprite clones."

	^ self submorphs select: [:m |
		(m isKindOf: ScriptablePhratchMorph) and: [m isClone]].

]

{ #category : #'scratch processes/events' }
PhratchStageMorph >> allEventNames [
	"Answer a list of all events that have been defined in this project."

	| result |
	result := Set new: 100.
	self submorphsDo: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [
			m addEventNamesTo: result]].
	self addEventNamesTo: result.

	phratchServer ifNotNil: [
		result addAll: phratchServer broadcastsSeen].

	"remove empty string"
	result remove: '' ifAbsent: [].

	^ result asArray sort

]

{ #category : #'byob OOP' }
PhratchStageMorph >> asReferenceTuple [

	" answer an array describing the receiver in an abstract way
	format conventions:"

	^ Array with: #stage

]

{ #category : #'byob OOP' }
PhratchStageMorph >> attribute: attr [
	"Answer the value of my variable or built-in attribute with the given name. Answer zero if I have no attribute or variable with the given name."

	| a |
	
	(attr isKindOf: CommandBlockMorph)
		ifTrue: [^ attr fullCopy newScriptOwner: self; yourself] 		"self blockLike: attr body]".

	a := attr asString.
	(vars includesKey: a) ifTrue: [^ vars at: a].
	(self allLocalBlockIds includes: a) ifTrue: [ ^self lambda: a ].

	a := a localized.
	'background #' localized = a ifTrue: [^ self backgroundIndex].
	'costume #' localized = a ifTrue: [^ self backgroundIndex].
	'volume' localized = a ifTrue: [^ self volume].
	^ 0

]

{ #category : #'sensing ops' }
PhratchStageMorph >> attributeNames [

	^ #('background #' 'volume') collect: [:s | s]

]

{ #category : #'looks ops' }
PhratchStageMorph >> backgroundIndex [
	"Answer the index of my current costume."
	<phratchItem: 'background #' kind: #r category: 'looks' defaultValues: #() subCategory: #a2>
	^ self costumeIndex

]

{ #category : #'scratch processes/events' }
PhratchStageMorph >> broadcastEventNamed: name with: value [
	"Broadcast a PhratchEvent with given name and argument value to all Phratch objects and answer a collection of the newly created processes. This is done by finding all public scripts that respond to this event, and starting new processes for any not already running."

	| event objList newProcs |
	phratchServer ifNotNil: [phratchServer queueBroadcast: name].
	event := PhratchEvent new name: name argument: value.
	newProcs := OrderedCollection new.

	"start scripts"
	objList := submorphs select: [:m | m isKindOf: ScriptablePhratchMorph].
	objList do: [:obj |
		newProcs addAll: (obj eventReceived: event)].
	newProcs addAll: (self eventReceived: event).

	^ newProcs asArray

]

{ #category : #'looks ops' }
PhratchStageMorph >> changeHPanBy: amount [
	"Change my horizontal pan by the given amount."
	<phratchItem: 'change horizontal pan by $Number$' kind: #- category: 'looks' defaultValues: #() subCategory: #a4>
	hPan := hPan + amount truncated.
	self changed.

]

{ #category : #'looks ops' }
PhratchStageMorph >> changeVPanBy: amount [
	"Change my vertical pan by the given amount."
	<phratchItem: 'change vertical pan by $Number$' kind: #- category: 'looks' defaultValues: #() subCategory: #a4>
	vPan := vPan + amount truncated.
	self changed.

]

{ #category : #byob }
PhratchStageMorph >> clearAllVariables [

	self clearVariables.
	sprites do: [:each |
		each clearVariables]

]

{ #category : #'pen support' }
PhratchStageMorph >> clearPenTrails [
	"Remove my pen trails Form. It will be recreated later if it is needed."
	<phratchItem: 'clear pen trails' kind: #- category: 'pen' defaultValues: #() subCategory: #a5>
	penTrailsForm := nil.
	self changed.

]

{ #category : #midi }
PhratchStageMorph >> closeMIDI [
	"Close the MIDI port and clear the note player dictionary."

	midiPort ifNotNil: [
		midiPort close.
		midiPort := nil].
	notePlayerDict := Dictionary new.

]

{ #category : #'event handling' }
PhratchStageMorph >> containsPoint: aPoint [

	self isQuarterSize ifTrue: [^ (self position extent: self extent // 2)  containsPoint: aPoint].
	^ self bounds containsPoint: aPoint

]

{ #category : #accessing }
PhratchStageMorph >> copyForExport [
	"Answer a copy of me with no sprites for use in exporting the background by itself."

	^ super copyForExport removeAllMorphs

]

{ #category : #accessing }
PhratchStageMorph >> costumeChanged [

	costumeChangeMSecs := Time millisecondClockValue.
	filterPack ifNotNil: [filterPack clearFilterCaches].
	self changed.

]

{ #category : #'pen support' }
PhratchStageMorph >> createOrResizeTrailsForm [
	"If necessary, create a new penTrailsForm or resize the existing one to fill my bounds. On return, penTrailsForm will be a Form of the correct size."

	"resize trails Form to my current exent"

	| newForm |
	penTrailsForm
		ifNil: [ 
			penTrailsForm := Form extent: self extent depth: 32.
			^ self ].
	penTrailsForm extent = self extent
		ifTrue: [ ^ self ].
	newForm := Form extent: self extent depth: 32.
	newForm
		copy: penTrailsForm boundingBox
		from: penTrailsForm
		to: 0 @ 0
		rule: Form paint.
	penTrailsForm := newForm
]

{ #category : #'scratch processes/events' }
PhratchStageMorph >> defaultEventName [
	"Answer a default event name for message send and receive blocks."

	| evtNames |
	evtNames := self allEventNames.
	^ evtNames size = 0 ifTrue: [''] ifFalse: [evtNames first]

]

{ #category : #accessing }
PhratchStageMorph >> defaultImageMedia [

	^ ImageMedia new
		form: ScriptablePhratchMorph defaultBackgroundForm;
		mediaName: ('background' localized, '1');
		yourself

]

{ #category : #clones }
PhratchStageMorph >> deleteAllClones [
	"Delete all clones."

	self allClones do: [:clone | clone delete].

]

{ #category : #'as yet unclassified' }
PhratchStageMorph >> deleteBackgroundAt: aNumber [
	<phratchItem: 'delete background $Number$' kind: #- category: 'looks' defaultValues: #(1) subCategory: #a2>
	self deleteCostumeAt: aNumber.
]

{ #category : #'byob OOP' }
PhratchStageMorph >> deleteSprite [
	"override the inherited default method to do nothing"
	^ self
]

{ #category : #media }
PhratchStageMorph >> drawNewCostume [

	| oldCostumeName newName newImage |
	oldCostumeName := costume mediaName.
	newImage := ImageMedia new form: (Form extent:  (480.0@360.0) depth: 8).
	newName := (self unusedMediaNameFromBaseName: self defaultImageMedia mediaName).
 	newImage mediaName: newName.
	media addLast: newImage.
	self updateMediaCategory.
	self lookLike: newImage mediaName.
	self editDrawingOldCostumeName: oldCostumeName deleteOnCancel: false.
	
	self undeleteAttribute: #costumes.
	
	self propagateCostumes


]

{ #category : #drawing }
PhratchStageMorph >> drawOn: aCanvas [
	"Draw myself if my visibility is > 0. If my visibility is 1, draw using the normal 'paint' mode. Otherwise, draw using 'alpha' resulting in a partially transparent rendering."

	| clipC f p alpha |
	clipC := aCanvas copyClipRect: bounds.
	clipC fillRectangle: bounds color: Color white.
	f := self filteredForm.

	f ifNotNil: [
		p := bounds center - (f extent // 2) + (hPan@vPan).
		visibility < 100
			ifTrue: [
				visibility > 0 ifTrue: [
					alpha := ((255.0 * visibility) / 100.0) truncated.
					clipC paintImage: f at: p sourceRect: f boundingBox alpha: alpha]]
			ifFalse: [clipC paintImage: f at: p]].

	self updateTrailsForm.
	penTrailsForm ifNotNil: [clipC paintImage: penTrailsForm at: self position].

]

{ #category : #'pen support' }
PhratchStageMorph >> drawPenTrailFor: aMorph from: oldPoint to: newPoint [
	"Draw a pen trail between the given points for the given morph using its pen size and color. The points are in Phratch coordinates (that is, 0@0 is the center of the work pane and y increases toward the top of the screen."
	"The penTrailsForm is created on demand when the first pen is put down and removed (to save space) when pen trails are cleared."

	| pen penSize offset p1 p2 r |
	self createOrResizeTrailsForm.
	pen := PhratchPen newOnForm: penTrailsForm.
	penSize := aMorph penSize.
	aMorph penSize ~= 1 ifTrue: [
		pen roundNib: penSize.
		pen sourceForm offset: nil].  "clear form offset"
	pen color: aMorph penColor.
	offset := (penTrailsForm extent - penSize) / 2.0.
	p1 := ((oldPoint * (1 @ -1)) + offset) rounded.
	p2 := ((newPoint * (1 @ -1)) + offset) rounded.
	pen drawFrom: p1 to: p2.
	r := ((p1 rect: p2) expandBy: penSize + 1) translateBy: self topLeft.
	self invalidRect: r.

]

{ #category : #drawing }
PhratchStageMorph >> drawQuarterSizeOn: aCanvas [
	"Draw myself and my submorphs to an offscreen canvas, then scale down to quarter size and draw that on the given canvas."

	| r srcR c|

	cachedForm ifNil: [cachedForm := Form extent: self extent depth: 32].	
	r := aCanvas clipRect intersect: (bounds origin extent: bounds extent // 2).

	srcR := ((r origin - bounds origin) * 2.0) truncated extent: (r extent * 2.0) rounded.
	c := (FormCanvas on: cachedForm)
		copyOrigin: self position negated
		clipRect: srcR.
	super fullDrawOn: c.
	self updateAfterPopUp.
	
	PhratchPlugin halfSize: cachedForm into: Display srcPoint: srcR origin dstRect: r.
"xxx
	cachedForm unhibernate.
	LowResPlugin
		primHalf2Average: cachedForm bits w: cachedForm width h: cachedForm height
		into: Display bits w: Display width h: Display height
		srcX: srcR left srcY: srcR top
		dstX: r left dstY: r top dstW: r width dstH: r height.

	(WarpBlt toForm: Display)
		sourceForm: cachedForm;
		combinationRule: Form over;
		clipRect: aCanvas clipRect;
		cellSize: 2;
		copyQuad: srcR corners toRect: r.
xxx"

	"the following scales down entire stage:"
"	LowResPlugin scale: cachedForm into: aCanvas form at: aCanvas origin + self position."

]

{ #category : #drawing }
PhratchStageMorph >> drawSubmorphsOn: aCanvas [
	"Clip submorph drawing to my bounds."

	| clipCanvas |
	clipCanvas := aCanvas copyClipRect: bounds.
	submorphs reverseDo:[:m |
		(clipCanvas isVisible: m fullBounds) ifTrue: [
			m fullDrawOn: clipCanvas]].

	"draw sprite talk bubbles in front of all morphs:"
	submorphs reverseDo:[:m |
		((m isKindOf: PhratchSpriteMorph) and:
		 [m isHidden not and:
		 [clipCanvas isVisible: m fullBounds]]) ifTrue: [
			m drawTalkBubbleOn: clipCanvas]].


]

{ #category : #drawing }
PhratchStageMorph >> exportFileName: fileName [
	| form fName |
	form := self stageShotForm.
	form depth <= 8
		ifTrue: [ 
			fName := (fileName asLowercase endsWith: '.gif')
				ifTrue: [ fileName ]
				ifFalse: [ fileName , '.gif' ].
			GIFReadWriter putForm: form colorReduced8Bit onFileNamed: fName.
			^ self ].
	fName := (fileName asLowercase endsWith: '.bmp')
		ifTrue: [ fileName ]
		ifFalse: [ fileName , '.bmp' ].
	(form asFormOfDepth: 32) writeBMPFileNamed: fName
]

{ #category : #'object i/o' }
PhratchStageMorph >> fieldsVersion [

	^ 5

]

{ #category : #drawing }
PhratchStageMorph >> fullBounds [
	"Overridden to clip submorph hit detection to my bounds."

	^ bounds

]

{ #category : #'event handling' }
PhratchStageMorph >> fullContainsPoint: aPoint [
	"Answer true if the given point is in my visible bounds. In quarterSize mode, my visible bounds is only half of my extent."

	| r |
	r := self isQuarterSize
		ifTrue: [self position extent: bounds extent // 2]
		ifFalse: [bounds].

	^ r containsPoint: aPoint

]

{ #category : #drawing }
PhratchStageMorph >> fullDrawOn: aCanvas [
	"Calls super fullDrawOn and then draws the frame shadow"

	| shadowOrigin topShadowExtent leftShadowExtent alphas |

	(self isQuarterSize and: [self isInWorld]) ifTrue: [
		^ self drawQuarterSizeOn: aCanvas].

	super fullDrawOn: aCanvas.

	"don't draw shadows if owner is not a PhratchFrameMorph"
	(owner isKindOf: PhratchFrameMorph) ifFalse: [^ self].

	"shadow constants"
	shadowOrigin := self topLeft + aCanvas origin.
	topShadowExtent := self width@1.
	leftShadowExtent := 1@self height.

	"shadow alpha values"
	alphas := FloatArray
		with: 0.51
		with: 0.26
		with: 0.07.

	"top/horizontal shadow"
	1 to: 3 do: [:i |
		aCanvas grafPort
			fill: (shadowOrigin + (0@(i-1)) extent: topShadowExtent)
			fillColor: (Color black alpha: (alphas at: i))
			rule: Form blend].

	"left/vertical shadow"
	1 to: 3 do: [:i |
		aCanvas grafPort
			fill: (shadowOrigin + ((i-1)@0) extent: leftShadowExtent)
			fillColor: (Color black alpha: (alphas at: i))
			rule: Form blend].

	"corner shadow fix"
	aCanvas grafPort
		fill: (shadowOrigin extent: (1@1))
		fillColor: (Color white alpha: 0.32)
		rule: Form blend.
	aCanvas grafPort
		fill: (shadowOrigin +(0@1) extent: (1@1))
		fillColor: (Color white alpha: 0.19)
		rule: Form blend.
	aCanvas grafPort
		fill: (shadowOrigin + (1@0) extent: (1@1))
		fillColor: (Color white alpha: 0.19)
		rule: Form blend.
	aCanvas grafPort
		fill: (shadowOrigin +(0@2) extent: (1@1))
		fillColor: (Color white alpha: 0.05)
		rule: Form blend.
	aCanvas grafPort
		fill: (shadowOrigin + (2@0) extent: (1@1))
		fillColor: (Color white alpha: 0.05)
		rule: Form blend.

]

{ #category : #'event handling' }
PhratchStageMorph >> grabSpriteFromScreen [
	"Create a new sprite, grabbing it's costume from an area of the screen."

	| frame m f |
	(frame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ self].
	m := PhratchSpriteMorph new.
	(f := m grabFormFromScreen) ifNil: [^ self].
	m onlyCostume: f.
	frame addAndView: m.


]

{ #category : #'object i/o' }
PhratchStageMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		zoom
		hPan
		vPan
	) from: anObjStream.
	classVersion = 1 ifTrue: [^ self].

	"fields added in version 2"
	self initFieldsNamed: #(
		obsoleteSavedState
	) from: anObjStream.
	classVersion = 2 ifTrue: [^ self].

	"fields added in version 3"
	self initFieldsNamed: #(
		sprites
	) from: anObjStream.
	classVersion = 3 ifTrue: [^ self].

	"fields added in version 4"
	self initFieldsNamed: #(
		volume
		tempoBPM
	) from: anObjStream.
	classVersion = 4 ifTrue: [^ self].

	"fields added in version 5"
	self initFieldsNamed: #(
		sceneStates
		lists
	) from: anObjStream.
	lists ifNil: [lists := Dictionary new].  "work around"

]

{ #category : #initialization }
PhratchStageMorph >> initialize [

	super initialize.
	color := Color white.
	self enableDragNDrop: true.
	objName := 'Stage' localized.
	costume := self defaultImageMedia.
	media := OrderedCollection with: costume with: SoundMedia new.
	hPan := 0.
	vPan := 0.
	runningBlocks := OrderedCollection new.
	inProcessStep := false.
	midiPortNum := -1.
	notePlayerDict := Dictionary new.
	sprites := OrderedCollection new.

]

{ #category : #drawing }
PhratchStageMorph >> invalidRect: damageRect [
	"Clip damage reports to my bounds, since drawing is clipped to my bounds."

	| r |
	(owner isKindOf: PhratchFrameMorph) ifTrue: [owner projectModified].

	(self isQuarterSize and: [owner isKindOf: PhratchFrameMorph])
		ifTrue: [
			r := (bounds origin + ((damageRect origin - bounds origin) / 2.0)) extent: (damageRect extent / 2.0).
			r := r intersect: (bounds origin extent: bounds extent // 2)]
		ifFalse: [
			r := (damageRect topLeft truncated) corner: (damageRect right ceiling@damageRect bottom ceiling).
			r := r intersect: self bounds].

	(r width > 0 and: [r height > 0]) ifTrue: [super invalidRect: r].

]

{ #category : #byob }
PhratchStageMorph >> isPaused [

	| allObjs |
	allObjs := submorphs select: [:m | m isKindOf: ScriptablePhratchMorph].
	allObjs := allObjs copyWith: self.
	allObjs do: [:obj |
		(obj blocksBin isKindOf: Morph) ifTrue: [
			obj blocksBin submorphs do: [:b |
				(b isKindOf: BlockMorph) ifTrue: [(b phratchProc notNil and: [b phratchProc isPaused not]) ifTrue: [^ false]]]]].
	^ true


]

{ #category : #accessing }
PhratchStageMorph >> isQuarterSize [

	isQuarterSize ifNil: [isQuarterSize := false].  "lazy initialization"
	^ isQuarterSize

]

{ #category : #accessing }
PhratchStageMorph >> isQuarterSize: aBoolean [

	isQuarterSize := aBoolean.

]

{ #category : #byob }
PhratchStageMorph >> listInVarNamed: varName targetName: targetName [

	targetName = 'Stage' ifTrue: [
		^self getVar: varName].

	sprites do: [:sprite |
		(sprite varNames includes: varName)
			ifTrue: [^sprite getVar: varName]].

	^ nil
]

{ #category : #byob }
PhratchStageMorph >> listNamed: listName targetName: targetName [

	targetName = 'Stage' ifTrue: [
		^self listNamed: listName ].

	sprites do: [:sprite |
		(sprite listVarNames includes: listName)
			ifTrue: [^sprite listNamed: listName ]].

	^ nil
]

{ #category : #'looks ops' }
PhratchStageMorph >> lookLike: costumeName [

	self undeleteAttribute: #costumeIndex.
	self passiveLookLike: costumeName.
	costumeName isNumber ifFalse: [
		self lookLike: self costumeIndex ].
]

{ #category : #'looks ops' }
PhratchStageMorph >> makeVisible [
	"Do nothing. I'm always visible."

]

{ #category : #midi }
PhratchStageMorph >> midiAllNotesOff [
	"If the MIDI port is open, send an 'all notes off' command on every channel."

	midiPort ifNil: [^ self].
	midiPort ensureOpenIfFail: [self closeMIDI].
	notePlayerDict do: [:player | player noteOff].

]

{ #category : #midi }
PhratchStageMorph >> midiPortNum [

	^ midiPortNum

]

{ #category : #midi }
PhratchStageMorph >> midiPortNum: anInteger [

	midiPortNum := anInteger.


]

{ #category : #'event handling' }
PhratchStageMorph >> mouseDown: evt [
	"Handle a mouse down event."

	evt hand newKeyboardFocus: nil.
	evt hand toolType ifNotNil: [evt hand toolType: nil].

	evt rightButtonPressed
		ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu]
		ifFalse:	[evt hand waitForClicksOrDrag: self event: evt].

]

{ #category : #'looks ops' }
PhratchStageMorph >> newScene [

	| sceneName |
	sceneName := StringDialog ask: 'Enter Scene Name:'.
	sceneName size = 0 ifTrue: [ ^ self ].

	sceneStates at: sceneName put: self backgroundIndex.
	submorphs do: [:m |
		(m isKindOf: PhratchSpriteMorph) ifTrue: [
			m recordScene: sceneName]].

]

{ #category : #'looks ops' }
PhratchStageMorph >> nextCostume [
	"Show the next background in my backgrounds list."
	<phratchItem: 'next background' kind: #- category: 'looks' defaultValues: #() subCategory: #a1>
	super nextCostume.

]

{ #category : #midi }
PhratchStageMorph >> notePlayerFor: aPhratchObject [
	"Answer a note player for the given object, creating one if necessary. Open the MIDI port if necessary."

	| deletedMorphs channelUsage ch newCh newPlayer |
	midiPort ifNil: [self tryToOpenMidiPort].

	(notePlayerDict includesKey: aPhratchObject) ifTrue: [
		^ notePlayerDict at: aPhratchObject].

	"remove deleted morphs from the note player dictionary"
	deletedMorphs := notePlayerDict keys select: [:m | m owner isNil].
	deletedMorphs do: [:m | notePlayerDict removeKey: m].

	"find the channel used by the fewest objects"
	channelUsage := Array new: 16 withAll: 0.
	channelUsage at: 10 put: 1000000.  "make sure channel 10 (drums) is not chosen"
	notePlayerDict do: [:player |
		ch := player channel.
		channelUsage at: ch put: (channelUsage at: ch) + 1].
	newCh := channelUsage indexOf: channelUsage min.

	newPlayer := PhratchNotePlayer new
		channel: newCh;
		midiPort: midiPort;
		instrument: 1;
		yourself.
	notePlayerDict at: aPhratchObject put: newPlayer.

	^ newPlayer

]

{ #category : #accessing }
PhratchStageMorph >> objName [

	^ 'Stage' localized

]

{ #category : #midi }
PhratchStageMorph >> openMIDI [
	"Prompt the user to select a MIDI port number, then open it."

	| possiblePorts dir menu |
	self closeMIDI.
	possiblePorts := (0 to: SimpleMIDIPort primPortCount - 1)
		select: [ :i | 
			dir := SimpleMIDIPort primPortDirectionalityOf: i.
			dir = 2 | (dir = 3) ].	"out or in/out port"
	possiblePorts size = 0
		ifTrue: [ ^ self inform: 'No MIDI ports currently available.' ].
	menu := MenuMorph new
		defaultTarget: self;
		title: 'MIDI port:' translated;
		yourself.
	possiblePorts
		do: [ :i | 
			menu
				add: (SimpleMIDIPort portDescription: i)
				target: self
				selector: #midiPortNum:
				argument: i ].
	menu popUpInWorld.
	self tryToOpenMidiPort
]

{ #category : #'byob OOP' }
PhratchStageMorph >> passiveLookLike: costumeName [
	"Change to the costume with the given name. Noop if there is no costume of the given name in my library."

	hPan := 0.
	vPan := 0.
	super lookLike: costumeName.

	self propagate: #costumeIndex
]

{ #category : #drawing }
PhratchStageMorph >> patchAt: patchRect withoutWatchersAnd: stopMorph andNothingAbove: stopThere [
	"Return a complete rendering of this patch of the display screen without drawing stopMorph and, if stopThere is true, without drawing any morph above it."

	| c morphsToDraw i |
	c := FormCanvas extent: patchRect extent depth: Display depth.
	c := c copyOrigin: patchRect topLeft negated clipRect: (0@0 extent: patchRect extent).

	(self bounds containsRect: patchRect) ifFalse: [
		"fill areas of patchRect outside my bounds with black"
		c form fillColor: Color black].
	(self bounds intersects: patchRect) ifFalse: [^ c form].  "entirely out of bounds"

	"draw all morphs intersecting the given patch, stopping at the given morph"
	c fillRectangle: self bounds color: color.  "draw world color"
	self drawOn: c.
	morphsToDraw := submorphs reversed asOrderedCollection.
	(i := morphsToDraw indexOf: stopMorph) > 0 ifTrue: [
		stopThere
			ifTrue: [morphsToDraw := morphsToDraw copyFrom: 1 to: i - 1]  "stop at stopMorph"
			ifFalse: [morphsToDraw removeIndex: i]].  "skip stopMorph"
	morphsToDraw do: [:m |
		(m isKindOf: WatcherMorph)
			ifFalse: [m fullDrawOn: c]].
	^ c form

]

{ #category : #byob }
PhratchStageMorph >> pauseAllProcesses [
	"Pause all running Phratch processes."

	| |
	"pause all sounds"
	SoundPlayer pauseAll.
		
	"clear all processes, including those with error feedback"
"
	allObjs := submorphs select: [:m | m isKindOf: ScriptablePhratchMorph].
	allObjs := allObjs copyWith: self.
	allObjs do: [:obj |
		(obj blocksBin isKindOf: Morph) ifTrue: [
			obj blocksBin submorphs do: [:b |
				(b isKindOf: BlockMorph) ifTrue: [b pauseProcess]]]].
"

	runningBlocks do: [:each |
		each pauseProcess]

]

{ #category : #'pen support' }
PhratchStageMorph >> penTrailsForm [

	^ penTrailsForm

]

{ #category : #'pen support' }
PhratchStageMorph >> penTrailsForm: aForm [

	penTrailsForm := aForm.
	penTrailsForm ifNotNil: [self createOrResizeTrailsForm].

]

{ #category : #'pen support' }
PhratchStageMorph >> penUpOrDownChangeFor: aSprite [
	"The pen up/down state for the given sprite may have changed; update lastPenPositions accordingly."

	| p |
	aSprite penDown
		ifTrue: [  "pen down transition"
			lastPenPositions ifNil: [lastPenPositions := IdentityDictionary new].
			p := aSprite penPosition.
			lastPenPositions at: aSprite put: p.
			self drawPenTrailFor: aSprite from: p to: p]
		ifFalse: [
			lastPenPositions ifNil: [^ self].
			lastPenPositions removeKey: aSprite ifAbsent: [].
			lastPenPositions size = 0 ifTrue: [lastPenPositions := nil]].

]

{ #category : #accessing }
PhratchStageMorph >> phratchServer [

	^ phratchServer

]

{ #category : #accessing }
PhratchStageMorph >> phratchServer: anObject [

	phratchServer := anObject.

]

{ #category : #'scratch processes/events' }
PhratchStageMorph >> processesToRun [
	"Answer a collection of processes to run. Filter out any processes for objects have been picked up. Always return a copy of the processes list."

	| result m |
	result := runningBlocks collect: [ :b | b phratchProc ].
	result := result select: [ :proc | proc notNil ].
	World activeHand submorphs size > 0
		ifTrue: [ 
			m := World activeHand submorphs first.
			result := result reject: [ :proc | proc includesReceiver: m ] ].
	^ result
]

{ #category : #byob }
PhratchStageMorph >> referenceToList: aPhratchList [

	"answer an Array describing the variable which holds an anonymous list, nil
	if there isn't any.

	format:

		1 - target obj name
		2 - var name"

	self varNames do: [:key |
		aPhratchList == (vars at: key)
			ifTrue: [^ Array with: 'Stage' with: key ]].

	sprites do: [:sprite |
		sprite varNames do: [:vname |
			aPhratchList == (sprite getVar: vname)
				ifTrue: [^ Array with: sprite objName with: vname ]]].

	^ nil
]

{ #category : #'scratch processes/events' }
PhratchStageMorph >> rejectDropEvent: evt [
	"we should only reject drops if they're not sprites, variables, etc. Should check it out better" 
	^false
]

{ #category : #'scratch processes/events' }
PhratchStageMorph >> removeTerminatedProcesses [
	"Remove terminated processes from the process list."

	| newRunning proc |
	newRunning := runningBlocks species new: 100.
	runningBlocks do: [:b |
		(proc := b phratchProc) ifNotNil: [
			proc isRunning
				ifTrue: [newRunning addLast: b]
				ifFalse: [proc errorFlag ifFalse: [b stop]]]].

	runningBlocks := newRunning.

]

{ #category : #'panther actions' }
PhratchStageMorph >> replaceBackground: name with: sel [
	<phratchItem: 'replace background $Number$ with $NewCostume$' kind: #- category: 'looks' defaultValues: #(1) subCategory: #a2>
	self replaceCostume: name with: sel.
]

{ #category : #'looks ops' }
PhratchStageMorph >> rerecordScene [

	| sceneList menu |
	sceneList := self sceneNames .
	sceneList := sceneList copyFrom: 1 to: sceneList size - 3.
	menu := MenuMorph new defaultTarget: self.
	sceneList do: [:n | 
		menu 
			add: n
			target: self 
			selector: #rerecordScene:
			argument: n].
	menu popUpInWorld.
]

{ #category : #'as yet unclassified' }
PhratchStageMorph >> rerecordScene: sceneName [
	sceneStates at: sceneName put: self backgroundIndex.
	submorphs do: [:m |
		(m isKindOf: PhratchSpriteMorph) ifTrue: [
			m recordScene: sceneName]].

]

{ #category : #byob }
PhratchStageMorph >> resumeAllProcesses [
	"Pause all running Phratch processes."

	"resume all sounds"
	SoundPlayer resumeAll.

	"clear all processes, including those with error feedback"

	runningBlocks do: [:each |
		each resumeProcess]

]

{ #category : #menus }
PhratchStageMorph >> rightButtonMenu [
	"Present the right button menu."

	| menu |
	menu := MenuMorph new defaultTarget: self.
	menu add: 'grab screen region for new sprite' translated action: #grabSpriteFromScreen.
	menu addLine.
	menu add: 'save picture of stage...' translated action: #stageShot.
	menu
		localize;
		invokeModal
]

{ #category : #'dropping/grabbing' }
PhratchStageMorph >> rootForGrabOf: aMorph [
	"Allow the given submorph to be extracted."

	| root |
	root := aMorph.
	[root = self] whileFalse: [
		root owner == self ifTrue: [^ root].
		root := root owner].

	^ super rootForGrabOf: aMorph

]

{ #category : #accessing }
PhratchStageMorph >> rotationCenter [

	^ costume rotationCenter

]

{ #category : #media }
PhratchStageMorph >> savePhoto: aForm [

	| n f |
	n := self unusedMediaNameFromBaseName: 'background' localized, '1'.

	f := Form extent: self extent depth: 32.
	(WarpBlt toForm: f)
		sourceForm: aForm;
		cellSize: 1;  "installs a new colormap if cellSize > 1"
		combinationRule: Form over;
		copyQuad: aForm boundingBox innerCorners toRect: f boundingBox.

	self addMediaItem: (ImageMedia new mediaName: n; form: f;
		yourself).


]

{ #category : #'looks ops' }
PhratchStageMorph >> sceneNames [

	| setOfNames |
	setOfNames := Set new.
	submorphs do: [:m |
		(m isKindOf: PhratchSpriteMorph) ifTrue: [
			setOfNames addAll: m scenes]].

	^ setOfNames asArray sort, (Array
		with: '-'
		with: 'record' localized, PhratchTranslator ellipsesSuffix
		with: 're-record' localized, PhratchTranslator ellipsesSuffix)

]

{ #category : #'looks ops' }
PhratchStageMorph >> setHPanTo: aNumber [
	"Set my horizontal pan to the given offset."
	<phratchItem: 'set horizontal pan to $Number$' kind: #- category: 'looks' defaultValues: #(0) subCategory: #a4>
	hPan := aNumber truncated.
	self changed.


]

{ #category : #'sound ops' }
PhratchStageMorph >> setTempoTo: aNumber [

	tempoBPM := (aNumber asNumberNoError within: 20 and: 500).

]

{ #category : #'looks ops' }
PhratchStageMorph >> setVPanTo: aNumber [
	"Set my vertical pan to the given offset."
	<phratchItem: 'set vertical pan to $Number$' kind: #- category: 'looks' defaultValues: #(0) subCategory: #a4>
	vPan := aNumber truncated.
	self changed.


]

{ #category : #'looks ops' }
PhratchStageMorph >> showBackground: costumeNameOrIndex [
	"This is lookLike: for the stage..."
	<phratchItem: 'switch to background $Costumes$' kind: #- category: 'looks' defaultValues: #('background1') subCategory: #a1>
	self lookLike: costumeNameOrIndex.

]

{ #category : #accessing }
PhratchStageMorph >> sprites [

	^ sprites

]

{ #category : #'event handling' }
PhratchStageMorph >> stageShot [

	| result |
	result := PhratchFileChooserDialog
		chooseNewFileDefault: ''
		title: 'Save Stage Shot'
		type: #stageShot.
	result = #cancelled ifTrue: [^ self].
	result size > 0 ifTrue: [self exportFileName: result].

]

{ #category : #drawing }
PhratchStageMorph >> stageShotForm [
	"Answer a stage shot of me and my submorphs."

	^ self stageShotSized: self width @ self height

]

{ #category : #drawing }
PhratchStageMorph >> stageShotSized: size [
	"Answer a thumbnail of me and my submorphs. Use super fullDrawOn: to avoid drawing the shadows along the top and left edges of the workspace."

	| canvas thumbForm |
	canvas := FormCanvas extent: bounds extent depth: 32.
	canvas translateBy: bounds topLeft negated during: [:c | super fullDrawOn: c].
	thumbForm := Form extent: size depth: 32.
	(WarpBlt toForm: thumbForm)
		sourceForm: canvas form;
		cellSize: 2;
		combinationRule: Form over;
		copyQuad: (0@0 extent: canvas extent) innerCorners toRect: thumbForm boundingBox.

	thumbForm := thumbForm colorReduced.  "first try to make a ColorForm with exact colors"
	thumbForm depth > 8 ifTrue: [
		thumbForm := thumbForm asFormOfDepth: 8].  "if that fails, use the closest 8-bit colors"
	^ thumbForm


]

{ #category : #'pen support' }
PhratchStageMorph >> stampCostume: aSprite [
	"Stamp a copy of the given sprite on my pen trails form."

	self createOrResizeTrailsForm.
	aSprite filteredForm
		displayOn: penTrailsForm
		at: (aSprite position - self topLeft)
		rule: Form paint.

]

{ #category : #'event handling' }
PhratchStageMorph >> startDrag: evt [
	"Ignore drag events."

]

{ #category : #'scratch processes/events' }
PhratchStageMorph >> startProcessFor: topBlock [
	"Start a process to run the given block or stack of blocks. Return the new process."

	| sequence proc |
	sequence := topBlock blockSequence.
	sequence first isHatBlock ifTrue: [
		sequence := sequence allButFirst].  "skip hat block"

	topBlock phratchProc ifNotNil: [topBlock stop].

	proc := PhratchProcess new
		topBlock: topBlock;
		expression: sequence;
		yourself.
	topBlock phratchProc: proc.

	(runningBlocks includes: topBlock) ifFalse: [runningBlocks addLast: topBlock].

	^ proc

]

{ #category : #byob }
PhratchStageMorph >> startProcessForSequence: anArray [
	"Start a process to run the given block or stack of blocks. Return the new process."

	| sequence proc topBlock |
	sequence := anArray last.
	topBlock := sequence first.
	sequence first isHatBlock ifTrue: [
		sequence := sequence allButFirst].  "skip hat block"

	topBlock phratchProc ifNotNil: [topBlock stop].

	proc := PhratchProcess new
		topBlock: topBlock;
		scriptList: anArray;
		expression: sequence;
		yourself.
	topBlock phratchProc: proc.
	(runningBlocks includes: topBlock) ifFalse: [runningBlocks addLast: topBlock].

	^ proc

]

{ #category : #nesting }
PhratchStageMorph >> step [

	| cp targets dragged |
	super step.
	feedbackMorph ifNotNil: [feedbackMorph delete].
	cp := self adjustedCursorPoint. 
	self updateTrailsForm.
	(self containsPoint: Sensor lastMousePosition) ifFalse: [^self].
	(World activeHand submorphs isEmpty not and: [World activeHand submorphs first isKindOf: LibraryItemMorph]) ifFalse: [^self].
	dragged := World activeHand submorphs first target.
	targets := self sprites select: [:each| 
		each containsPoint: cp ].
	targets size > 0 ifTrue: [
		targets first == dragged ifFalse:[
			feedbackMorph := targets first feedbackMorph.
			World activeHand addMorphFront: feedbackMorph ]].



]

{ #category : #'scratch processes/events' }
PhratchStageMorph >> stepProcesses [
	"Run each Phratch process until it gives up control, then filter out any processes that have terminated."
	"Details: Iterate over a copy of processes to allow processes to stop themselves. During development, the error catcher makes it difficult to track down errors, so it can be disabled."

	| proc |

	PhratchProcess blockHighlightMSecs = 0 ifTrue: [^ self stepProcessesTurbo].

	inProcessStep ifTrue: [^ self].
	inProcessStep := true.
	PhratchFrameMorph useErrorCatcher
		ifTrue: [
			[self processesToRun do: [:p | (proc := p) runStepFor: self]]
				ifError: [proc errorFlag: true]]
		ifFalse: [
			self processesToRun do: [:p | p runStepFor: self]].

	self removeTerminatedProcesses.
"	self deleteTerminatedClones."

	inProcessStep := false.

]

{ #category : #'scratch processes/events' }
PhratchStageMorph >> stepProcessesTurbo [
	"Run each Phratch process until it gives up control, then filter out any processes that have terminated. Do this repeatedly until time is up."

	| sliceMSecs startMSecs now proc |
	sliceMSecs := 100.
	inProcessStep ifTrue: [^ self].
	inProcessStep := true.

	startMSecs := Time millisecondClockValue.
	[
		[now := Time millisecondClockValue.
		 runningBlocks size > 0 and:
		  [(now >= startMSecs) and: [(now - startMSecs) < sliceMSecs]]] whileTrue: [
			self processesToRun do: [:p | (proc := p) runStepFor: self].
			self removeTerminatedProcesses].
	] ifError: [proc errorFlag: true].

	inProcessStep := false.

]

{ #category : #'scratch processes/events' }
PhratchStageMorph >> stopAll [
	"Stop all processes and make sure I am stepping."

	| sFrame |
	World hands do: [:h | h newKeyboardFocus: nil; clearUnclaimedKeystrokes].
	Sensor clearKeystate.
	SoundPlayer stopPlayingAll.
	self class stopSoundRecorder.
	self stopAllProcesses.
	self stopAsks.
	self deleteAllClones.
	self midiAllNotesOff.
	self stopPlaying.
	self allMorphsDo: [:m |
		(m isKindOf: ScriptablePhratchMorph) ifTrue: [m stopPlaying]].

	DebuggerFrameMorph allInstancesDo: [:df | df delete ].

	(sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNotNil: [
		sFrame scriptsPane allMorphsDo: [:m |
			(m respondsTo: #stop) ifTrue: [m stop].
			(m respondsTo: #litUp:) ifTrue: [m litUp: false]].
		World startSteppingSubmorphsOf: sFrame].

	World startSteppingSubmorphsOf: self. 

]

{ #category : #'scratch processes/events' }
PhratchStageMorph >> stopAllProcesses [
	"Stop all running Phratch processes."

	| allObjs |
	"clear all processes, including those with error feedback"
	allObjs := submorphs select: [:m | m isKindOf: ScriptablePhratchMorph].
	allObjs := allObjs copyWith: self.
	allObjs do: [:obj |
		(obj blocksBin isKindOf: Morph) ifTrue: [
			obj blocksBin submorphs do: [:b |
				(b isKindOf: BlockMorph) ifTrue: [b clearProcess]]]].

	runningBlocks := OrderedCollection new.
	inProcessStep := false.

]

{ #category : #byob }
PhratchStageMorph >> stopAllScriptsFor: eventName [

"	remember to implement this in the mesh network later -jens"
"	phratchServer ifNotNil: [phratchServer queueBroadcast: name]."

	"stop scripts"
	submorphs do: [:m | (m isKindOf: ScriptablePhratchMorph) ifTrue: [
		m stopScriptsFor: eventName]].
	self stopScriptsFor: eventName 

]

{ #category : #'scratch processes/events' }
PhratchStageMorph >> stopAllSounds [
	"Stop all sounds and MIDI notes/drums."

	SoundPlayer shutDown.
	self midiAllNotesOff.


]

{ #category : #'scratch processes/events' }
PhratchStageMorph >> stopAsks [
	"Stop/close any ask that is currently on the screen."

	PhratchPrompterMorph allInstancesDo: [:m | m stopAsk].
	PhratchPrompterMorph clearLastAnswer.

]

{ #category : #'object i/o' }
PhratchStageMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		zoom
		hPan
		vPan
		obsoleteSavedState
		sprites
		volume
		tempoBPM
		sceneStates
		lists
	) on: anObjStream.

]

{ #category : #'sound ops' }
PhratchStageMorph >> tempo [

	^ tempoBPM

]

{ #category : #drawing }
PhratchStageMorph >> thumbnailForm [
	"Answer a thumbnail of me and my submorphs."

	^ self stageShotSized: (160@120)

]

{ #category : #byob }
PhratchStageMorph >> togglePause [

	self isPaused
		ifTrue: [self resumeAllProcesses]
		ifFalse: [self pauseAllProcesses] 
]

{ #category : #'event handling' }
PhratchStageMorph >> transformFrom: uberMorph [
	"Return a transform to map coorinates of uberMorph, a morph above me in my owner chain, into the coordinates of my submorphs."

	| transform |
	self isQuarterSize ifFalse: [^ super transformFrom: uberMorph].

	transform := MorphicTransform offset: (self position // -2) angle: 0.0 scale: 0.5.
	owner == uberMorph ifTrue: [^ transform].
	owner ifNil: [^ transform].
	^ (owner transformFrom: uberMorph) composedWith: transform


]

{ #category : #midi }
PhratchStageMorph >> tryToOpenMidiPort [
	"Attempt to open the MIDI port. First try the port selected by the user, if any. If that port number is not a MIDI output port, try to find another port number. If all measures fail, leave midiPort set to nil."

	| possiblePorts dir portNum |
	OSPlatform isUnix
		ifTrue: [ 
			midiPort := nil.
			^ self ].
	possiblePorts := (0 to: SimpleMIDIPort primPortCount - 1)
		select: [ :i | 
			dir := SimpleMIDIPort primPortDirectionalityOf: i.
			dir = 2 | (dir = 3) ].	"out or in/out port"
	possiblePorts size = 0
		ifTrue: [ 
			midiPort := nil.
			^ self ].	"no midi ports"
	portNum := (possiblePorts includes: midiPortNum)
		ifTrue: [ midiPortNum ]
		ifFalse: [ possiblePorts first ].	"use the port requested by the user"	"use the first available port"
	[ 
	midiPort := SimpleMIDIPort openOnPortNumber: portNum.
	midiPort ensureOpen ] ifError: [ midiPort := nil ]
]

{ #category : #byob }
PhratchStageMorph >> unloadAllUnusedCustomBlocks [

	'updating...' 
		displayProgressAt: Display center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((self allMorphs) select: [:m| m isKindOf: ScriptablePhratchMorph]) size
		during: [:bar | | i | i := 0.

	{self}, self sprites do: [:obj |
		i := i + 1. bar value: i.
		obj unloadUnusedCustomBlocks]]

]

{ #category : #'event handling' }
PhratchStageMorph >> unlockedMorphsAt: aPoint addTo: mList [
	"Adjust aPoint to handle quarter-size case if necessary."

	| p |
	self isQuarterSize ifFalse: [
		super unlockedMorphsAt: aPoint addTo: mList.
		^ mList].

	(self containsPoint: aPoint) ifFalse: [^ mList]. "quick elimination"
	p := self position + (2 * (aPoint - self position)).

	submorphs do: [:m | m unlockedMorphsAt: p addTo: mList].
	mList addLast: self.

	^ mList

]

{ #category : #'pen support' }
PhratchStageMorph >> updatePenPositionFor: aSprite [
	"Update the given sprites pen position if necessary. Used to avoid drawing glitches when going between normal and presentation mode."

	lastPenPositions ifNil: [^ self].  "no pens are down"
	(lastPenPositions includes: aSprite) ifTrue: [
		lastPenPositions at: aSprite put: aSprite penPosition].

]

{ #category : #accessing }
PhratchStageMorph >> updateSpritesList [
	"Populate the sprites list, which keeps track of the ordering of the sprite thumbnails"

	| frame |
	frame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	frame ifNil: [^ self].
	sprites := OrderedCollection new.
	frame libraryPane spriteThumbnails do: [:m | m target ifNotNil: [sprites addLast: m target]].

]

{ #category : #'pen support' }
PhratchStageMorph >> updateTrailsForm [
	"Update the pen trails form using the current positions of all sprites with their pens down."
	"Details: The positions of all sprites with their pens down are recorded by my draw method. If the list from the last display update isn't empty, then trails are drawn from the old to the current positions of all such morphs on the pen trails form. The pen trails form is created on demand when the first pen is put down and removed (to save space) when the pen trails are cleared."

	| spritesToRemove m oldPoint newPoint |
	(lastPenPositions isNil or: [lastPenPositions size = 0]) ifTrue: [^ self].

	spritesToRemove := OrderedCollection new.
	lastPenPositions associationsDo: [:assoc |
		m := assoc key.
		(m penDown and: [m owner == self])
			ifTrue: [
				oldPoint := assoc value.
				newPoint := m penPosition.
				newPoint = oldPoint ifFalse: [
					self drawPenTrailFor: m from: oldPoint to: newPoint.
					assoc value: newPoint]]
			ifFalse: [spritesToRemove add: m]].

	"remove sprites that are not longer owned by me or whose pens are up"
	spritesToRemove do: [:key | lastPenPositions removeKey: key ifAbsent: []].

]

{ #category : #byob }
PhratchStageMorph >> userSelectSpriteDefault: defaultSprite butNotAnyOf: excludeArray [
	| menu current |
	menu := MenuMorphNG new defaultTarget: self.
	current := (defaultSprite isKindOf: PhratchSpriteMorph)
		ifTrue: [ defaultSprite objName ]
		ifFalse: [ 'none' ].
	menu title: 'current parent: ' , current.
	sprites
		do: [ :each | 
			(excludeArray includes: each)
				ifFalse: [ menu add: each objName value: each ] ].
	menu addLine.
	menu add: 'none' value: #null.
	^ menu
		defaultTarget: #null;
		popUpInWorld;
		selectedValue;
		yourself
]
