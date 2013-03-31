"
I represent the background of the Scratch work pane. Like a sprite, I have a set of media and can change my costume. I also have my own scripts and variables. The main difference between me and a sprite is that I am fixed in position: I cannot move or rotate.

"
Class {
	#name : #ScratchStageMorph,
	#superclass : #ScriptableScratchMorph,
	#instVars : [
		'zoom',
		'hPan',
		'vPan',
		'penTrailsForm',
		'lastPenPositions',
		'runningBlocks',
		'inProcessStep',
		'sensorBoard',
		'midiPortNum',
		'midiPort',
		'notePlayerDict',
		'obsoleteSavedState',
		'sprites',
		'scratchServer',
		'isQuarterSize',
		'cachedForm',
		'showMotorBlocks',
		'feedbackMorph'
	],
	#category : #'Phratch-Objects'
}

{ #category : #'block specs' }
ScratchStageMorph class >> blockSpecs [

	| blocks |
	blocks := #(
		'sensing'
			('ask %s and wait'			s	doAsk 'What''s your name?')
			('answer'					r	answer)
			-
			('mouse x'					r	mouseX)
			('mouse y'					r	mouseY)
			('mouse down?'				b	mousePressed)
			-
			('key %k pressed?'			b	keyPressed: 'space')
			-
			('reset timer'				-	timerReset)
			('timer'						r	timer)
			-
			('%a of %m'					r	getAttribute:of:)
			('get %a of %m'				r	attribute:of:)
			-
			('loudness'					r	soundLevel)
			('loud?'						b	isLoud)
			~
			('%H sensor value'			r	sensor: 'slider')
			('sensor %h?'				b	sensorPressed: 'button pressed')
			=
			('object %m'						r	getObject:)
			('attribute %a'						r	get:)

		'looks'
			('switch to background %l'	-	showBackground: 'background1')
			('next background'			-	nextBackground)
			('background #'				r	backgroundIndex)
			-
			('change %g effect by %n'	-	changeGraphicEffect:by: 'color' 25)
			('set %g effect to %n'		-	setGraphicEffect:to: 'color' 0)
			('clear graphic effects'		-	filterReset)
			-
"xxx			('place sprites for scene %x'	-	showScene:) "
		'pen'
			('clear'						-	clearPenTrails)
	).

	^ blocks, super blockSpecs

]

{ #category : #'dropping/grabbing' }
ScratchStageMorph >> acceptDroppingMorph: aMorph event: evt [

	self isQuarterSize ifTrue: [
		aMorph center: (2 * aMorph center) - self position.
		self changed].

	self addMorph: aMorph.
	self isInWorld ifTrue: [self world startSteppingSubmorphsOf: aMorph].
	((aMorph respondsTo: #penDown) and: [aMorph penDown])
		ifTrue: [self penUpOrDownChangeFor: aMorph].
	self changed.


]

{ #category : #'-- all --' }
ScratchStageMorph >> adjustedCursorPoint [
	"Answer the current mouse cursorPoint adjusted for the scaling presentation and q-mode."

	DoubleSize
		ifTrue: [^((Sensor lastMousePosition - self center) // 2) + self center].
	isQuarterSize
		ifTrue: [^((Sensor lastMousePosition - self position) * 2) + self position].
	^Sensor lastMousePosition





]

{ #category : #clones }
ScratchStageMorph >> allClones [
	"Answer a collection of all sprite clones."

	^ self submorphs select: [:m |
		(m isKindOf: ScriptableScratchMorph) and: [m isClone]].

]

{ #category : #'scratch processes/events' }
ScratchStageMorph >> allEventNames [
	"Answer a list of all events that have been defined in this project."

	| result |
	result := Set new: 100.
	self submorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [
			m addEventNamesTo: result]].
	self addEventNamesTo: result.

	scratchServer ifNotNil: [
		result addAll: scratchServer broadcastsSeen].

	"remove empty string"
	result remove: '' ifAbsent: [].

	^ result asArray sort

]

{ #category : #'byob OOP' }
ScratchStageMorph >> asReferenceTuple [

	" answer an array describing the receiver in an abstract way
	format conventions:"

	^ Array with: #stage

]

{ #category : #'byob OOP' }
ScratchStageMorph >> attribute: attr [
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
ScratchStageMorph >> attributeNames [

	^ #('background #' 'volume') collect: [:s | s]

]

{ #category : #'looks ops' }
ScratchStageMorph >> backgroundIndex [
	"Answer the index of my current costume."

	^ self costumeIndex

]

{ #category : #'scratch processes/events' }
ScratchStageMorph >> broadcastEventNamed: name with: value [
	"Broadcast a ScratchEvent with given name and argument value to all Scratch objects and answer a collection of the newly created processes. This is done by finding all public scripts that respond to this event, and starting new processes for any not already running."

	| event objList newProcs |
	scratchServer ifNotNil: [scratchServer queueBroadcast: name].
	event := PhratchEvent new name: name argument: value.
	newProcs := OrderedCollection new.

	"start scripts"
	objList := submorphs select: [:m | m isKindOf: ScriptableScratchMorph].
	objList do: [:obj |
		newProcs addAll: (obj eventReceived: event)].
	newProcs addAll: (self eventReceived: event).

	^ newProcs asArray

]

{ #category : #'looks ops' }
ScratchStageMorph >> changeBackgroundIndexBy: aNumber [
	"Change my background index by the given amount."

	self changeCostumeIndexBy: aNumber.

]

{ #category : #'looks ops' }
ScratchStageMorph >> changeHPanBy: amount [
	"Change my horizontal pan by the given amount."

	hPan := hPan + amount truncated.
	self changed.

]

{ #category : #'looks ops' }
ScratchStageMorph >> changeVPanBy: amount [
	"Change my vertical pan by the given amount."

	vPan := vPan + amount truncated.
	self changed.

]

{ #category : #'looks ops' }
ScratchStageMorph >> changeZoomBy: percent [
	"Change my zoom by the given percent."

	zoom := zoom + percent.
	self changed.

]

{ #category : #byob }
ScratchStageMorph >> clearAllVariables [

	self clearVariables.
	sprites do: [:each |
		each clearVariables]

]

{ #category : #'pen support' }
ScratchStageMorph >> clearPenTrails [
	"Remove my pen trails Form. It will be recreated later if it is needed."

	penTrailsForm := nil.
	self changed.

]

{ #category : #midi }
ScratchStageMorph >> closeMIDI [
	"Close the MIDI port and clear the note player dictionary."

	midiPort ifNotNil: [
		midiPort close.
		midiPort := nil].
	notePlayerDict := Dictionary new.

]

{ #category : #'event handling' }
ScratchStageMorph >> containsPoint: aPoint [

	self isQuarterSize ifTrue: [^ (self position extent: self extent // 2)  containsPoint: aPoint].
	^ self bounds containsPoint: aPoint

]

{ #category : #accessing }
ScratchStageMorph >> copyForExport [
	"Answer a copy of me with no sprites for use in exporting the background by itself."

	^ super copyForExport removeAllMorphs

]

{ #category : #accessing }
ScratchStageMorph >> costumeChanged [

	costumeChangeMSecs := Time millisecondClockValue.
	filterPack ifNotNil: [filterPack clearFilterCaches].
	self changed.

]

{ #category : #'pen support' }
ScratchStageMorph >> createOrResizeTrailsForm [
	"If necessary, create a new penTrailsForm or resize the existing one to fill my bounds. On return, penTrailsForm will be a Form of the correct size."

	| newForm |
	penTrailsForm ifNil: [
		penTrailsForm := Form extent: self extent depth: 32.
		^ self].

	penTrailsForm extent = self extent ifFalse: [  "resize trails Form to my current exent"
		newForm := Form extent: self extent depth: 32.
		newForm
			copy: penTrailsForm boundingBox
			from: penTrailsForm
			to: 0@0
			rule: Form paint.
		penTrailsForm := newForm].

]

{ #category : #'scratch processes/events' }
ScratchStageMorph >> defaultEventName [
	"Answer a default event name for message send and receive blocks."

	| evtNames |
	evtNames := self allEventNames.
	^ evtNames size = 0 ifTrue: [''] ifFalse: [evtNames first]

]

{ #category : #accessing }
ScratchStageMorph >> defaultImageMedia [

	^ ImageMedia new
		form: ScriptableScratchMorph defaultBackgroundForm;
		mediaName: ('background' localized, '1')

]

{ #category : #clones }
ScratchStageMorph >> deleteAllClones [
	"Delete all clones."

	self allClones do: [:clone | clone delete].

]

{ #category : #'byob OOP' }
ScratchStageMorph >> deleteSprite [
	"override the inherited default method to do nothing"
	^ self
]

{ #category : #clones }
ScratchStageMorph >> deleteTerminatedClones [
	"Delete all clones that have no running scripts."

	| isRunning |
	self allClones do: [:clone |
		isRunning := false.
		clone blocksBin allMorphsDo: [:b |
			((b isKindOf: BlockMorph) and: [b hasRunningProcess])
				ifTrue: [isRunning := true]].
		isRunning ifFalse: [clone delete]].

]

{ #category : #drawing }
ScratchStageMorph >> drawOn: aCanvas [
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
ScratchStageMorph >> drawPenTrailFor: aMorph from: oldPoint to: newPoint [
	"Draw a pen trail between the given points for the given morph using its pen size and color. The points are in Scratch coordinates (that is, 0@0 is the center of the work pane and y increases toward the top of the screen."
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
ScratchStageMorph >> drawQuarterSizeOn: aCanvas [
	"Draw myself and my submorphs to an offscreen canvas, then scale down to quarter size and draw that on the given canvas."

	| r srcR c |
	cachedForm ifNil: [cachedForm := Form extent: self extent depth: 32].
	r := aCanvas clipRect intersect: (bounds origin extent: bounds extent // 2).

	srcR := ((r origin - bounds origin) * 2.0) truncated extent: (r extent * 2.0) rounded.
	c := (FormCanvas on: cachedForm)
		copyOrigin: self position negated
		clipRect: srcR.
	super fullDrawOn: c.

	ScratchPlugin halfSize: cachedForm into: Display srcPoint: srcR origin dstRect: r.

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
ScratchStageMorph >> drawSubmorphsOn: aCanvas [
	"Clip submorph drawing to my bounds."

	| clipCanvas |
	clipCanvas := aCanvas copyClipRect: bounds.
	submorphs reverseDo:[:m |
		(clipCanvas isVisible: m fullBounds) ifTrue: [
			m fullDrawOn: clipCanvas]].

	"draw sprite talk bubbles in front of all morphs:"
	submorphs reverseDo:[:m |
		((m isKindOf: ScratchSpriteMorph) and:
		 [m isHidden not and:
		 [clipCanvas isVisible: m fullBounds]]) ifTrue: [
			m drawTalkBubbleOn: clipCanvas]].


]

{ #category : #drawing }
ScratchStageMorph >> exportFileName: fileName [

	| form fName |
	form := self stageShotForm.
	form depth <= 8 ifTrue: [
		(fileName asLowercase endsWith: '.gif')
			ifTrue: [fName := fileName]
			ifFalse: [fName := fileName, '.gif'].
		GIFReadWriter putForm: form colorReduced8Bit onFileNamed: fName.
		^ self].

	(fileName asLowercase endsWith: '.bmp')
		ifTrue: [fName := fileName]
		ifFalse: [fName := fileName, '.bmp'].
	(form asFormOfDepth: 32) writeBMPFileNamed: fName.

]

{ #category : #'object i/o' }
ScratchStageMorph >> fieldsVersion [

	^ 5

]

{ #category : #drawing }
ScratchStageMorph >> fullBounds [
	"Overridden to clip submorph hit detection to my bounds."

	^ bounds

]

{ #category : #'event handling' }
ScratchStageMorph >> fullContainsPoint: aPoint [
	"Answer true if the given point is in my visible bounds. In quarterSize mode, my visible bounds is only half of my extent."

	| r |
	r := self isQuarterSize
		ifTrue: [self position extent: bounds extent // 2]
		ifFalse: [bounds].

	^ r containsPoint: aPoint

]

{ #category : #drawing }
ScratchStageMorph >> fullDrawOn: aCanvas [
	"Calls super fullDrawOn and then draws the frame shadow"

	| shadowOrigin topShadowExtent leftShadowExtent alphas |

	(self isQuarterSize and: [self isInWorld]) ifTrue: [
		^ self drawQuarterSizeOn: aCanvas].

	super fullDrawOn: aCanvas.

	"don't draw shadows if owner is not a ScratchFrameMorph"
	(owner isKindOf: ScratchFrameMorph) ifFalse: [^ self].

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

{ #category : #'sensing ops' }
ScratchStageMorph >> getAttribute: attr [
	"Answer the value of my variable or built-in attribute with the given name. Answer zero if I have no attribute or variable with the given name."

	| a |
	(vars includesKey: attr) ifTrue: [^ vars at: attr].
	(self allLocalBlockIds includes: attr) ifTrue: [ ^self lambda: attr ].

	a := attr localized.
	'background #' localized = a ifTrue: [^ self backgroundIndex].
	'costume #' localized = a ifTrue: [^ self backgroundIndex].
	'volume' localized = a ifTrue: [^ self volume].
	^ 0

]

{ #category : #'event handling' }
ScratchStageMorph >> grabSpriteFromScreen [
	"Create a new sprite, grabbing it's costume from an area of the screen."

	| frame m f |
	(frame := self ownerOrYourselfThatIsA: ScratchFrameMorph) ifNil: [^ self].
	m := ScratchSpriteMorph new.
	(f := m grabFormFromScreen) ifNil: [^ self].
	m onlyCostume: f.
	frame addAndView: m.


]

{ #category : #drawing }
ScratchStageMorph >> incrRedraw: damageList [
	"Redraw the damaged areas of this stage directly onto the display. Assumes that no other morph is in front of me."

	| f c p screenR |
	damageList do: [:r |
		f := Form extent: r extent depth: 32.
		c := (FormCanvas on: f) copyOffset: r origin negated.
		self fullDrawOn: c.
		DoubleSize
			ifTrue: [
				p := (self center - self extent) + (2 * (r origin - self topLeft)).
				screenR := p extent: 2 * f extent.
				(Display boundingBox containsRect: screenR) ifTrue: [
					[
						ScratchPlugin
							primDouble: f bits w: f width h: f height
							into: Display bits w: Display width h: Display height
							x: screenR left y: screenR top.
					] ifError: [].
					Display forceToScreen: screenR]]
			ifFalse: [
				f displayOn: Display at: r topLeft rule: Form over]].

]

{ #category : #'object i/o' }
ScratchStageMorph >> initFieldsFrom: anObjStream version: classVersion [

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
ScratchStageMorph >> initialize [

	super initialize.
	color := Color white.
	self enableDragNDrop: true.
	objName := 'Stage' localized.
	costume := self defaultImageMedia.
	media := OrderedCollection with: costume with: SoundMedia new.
	zoom := 1.0.
	hPan := 0.
	vPan := 0.
	runningBlocks := OrderedCollection new.
	inProcessStep := false.
	sensorBoard := SensorBoardMorph new.
	midiPortNum := -1.
	notePlayerDict := Dictionary new.
	obsoleteSavedState := nil.
	sprites := OrderedCollection new.
	showMotorBlocks := false.

]

{ #category : #drawing }
ScratchStageMorph >> invalidRect: damageRect [
	"Clip damage reports to my bounds, since drawing is clipped to my bounds."

	| r |
	(owner isKindOf: ScratchFrameMorph) ifTrue: [owner projectModified].

	(self isQuarterSize and: [owner isKindOf: ScratchFrameMorph])
		ifTrue: [
			r := (bounds origin + ((damageRect origin - bounds origin) / 2.0)) extent: (damageRect extent / 2.0).
			r := r intersect: (bounds origin extent: bounds extent // 2)]
		ifFalse: [
			r := (damageRect topLeft truncated) corner: (damageRect right ceiling@damageRect bottom ceiling).
			r := r intersect: self bounds].

	(r width > 0 and: [r height > 0]) ifTrue: [super invalidRect: r].

]

{ #category : #byob }
ScratchStageMorph >> isPaused [

	| allObjs |
	allObjs := submorphs select: [:m | m isKindOf: ScriptableScratchMorph].
	allObjs := allObjs copyWith: self.
	allObjs do: [:obj |
		(obj blocksBin isKindOf: Morph) ifTrue: [
			obj blocksBin submorphs do: [:b |
				(b isKindOf: BlockMorph) ifTrue: [(b scratchProc notNil and: [b scratchProc isPaused not]) ifTrue: [^ false]]]]].
	^ true


]

{ #category : #accessing }
ScratchStageMorph >> isQuarterSize [

	isQuarterSize ifNil: [isQuarterSize := false].  "lazy initialization"
	^ isQuarterSize

]

{ #category : #accessing }
ScratchStageMorph >> isQuarterSize: aBoolean [

	isQuarterSize := aBoolean.

]

{ #category : #byob }
ScratchStageMorph >> listInVarNamed: varName targetName: targetName [

	targetName = 'Stage' ifTrue: [
		^self getVar: varName].

	sprites do: [:sprite |
		(sprite varNames includes: varName)
			ifTrue: [^sprite getVar: varName]].

	^ nil
]

{ #category : #byob }
ScratchStageMorph >> listNamed: listName targetName: targetName [

	targetName = 'Stage' ifTrue: [
		^self listNamed: listName ].

	sprites do: [:sprite |
		(sprite listVarNames includes: listName)
			ifTrue: [^sprite listNamed: listName ]].

	^ nil
]

{ #category : #'looks ops' }
ScratchStageMorph >> lookLike: costumeName [

	self undeleteAttribute: #costumeIndex.
	self passiveLookLike: costumeName.
	costumeName isNumber ifFalse: [
		self lookLike: self costumeIndex ].
]

{ #category : #'looks ops' }
ScratchStageMorph >> makeVisible [
	"Do nothing. I'm always visible."

]

{ #category : #midi }
ScratchStageMorph >> midiAllNotesOff [
	"If the MIDI port is open, send an 'all notes off' command on every channel."

	midiPort ifNil: [^ self].
	midiPort ensureOpenIfFail: [self closeMIDI].
	notePlayerDict do: [:player | player noteOff].

]

{ #category : #midi }
ScratchStageMorph >> midiPortNum [

	^ midiPortNum

]

{ #category : #midi }
ScratchStageMorph >> midiPortNum: anInteger [

	midiPortNum := anInteger.


]

{ #category : #'event handling' }
ScratchStageMorph >> mouseDown: evt [
	"Handle a mouse down event."

	evt hand newKeyboardFocus: nil.
	evt hand toolType ifNotNil: [evt hand toolType: nil].

	evt rightButtonPressed
		ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu]
		ifFalse:	[evt hand waitForClicksOrDrag: self event: evt].

]

{ #category : #'looks ops' }
ScratchStageMorph >> newScene [

	| sceneName |
	sceneName := StringDialog ask: 'Enter Scene Name:'.
	sceneName size = 0 ifTrue: [ ^ self ].

	sceneStates at: sceneName put: self backgroundIndex.
	submorphs do: [:m |
		(m isKindOf: ScratchSpriteMorph) ifTrue: [
			m recordScene: sceneName]].

]

{ #category : #'looks ops' }
ScratchStageMorph >> nextBackground [
	"Show the next background in my backgrounds list."

	self nextCostume.

]

{ #category : #midi }
ScratchStageMorph >> notePlayerFor: aScratchObject [
	"Answer a note player for the given object, creating one if necessary. Open the MIDI port if necessary."

	| deletedMorphs channelUsage ch newCh newPlayer |
	midiPort ifNil: [self tryToOpenMidiPort].

	(notePlayerDict includesKey: aScratchObject) ifTrue: [
		^ notePlayerDict at: aScratchObject].

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
		instrument: 1.
	notePlayerDict at: aScratchObject put: newPlayer.

	^ newPlayer

]

{ #category : #accessing }
ScratchStageMorph >> objName [

	^ 'Stage' localized

]

{ #category : #midi }
ScratchStageMorph >> openMIDI [
	"Prompt the user to select a MIDI port number, then open it."

	| possiblePorts dir menu choice |
	self closeMIDI.
	possiblePorts := (0 to: SimpleMIDIPort primPortCount - 1) select: [:i |
		dir := SimpleMIDIPort primPortDirectionalityOf: i.
		(dir = 2) | (dir = 3)].  "out or in/out port"
	possiblePorts size = 0 ifTrue: [^ self inform: 'No MIDI ports currently available.'].
	menu := MenuMorph new defaultTarget: self; title: 'MIDI port:'.
	possiblePorts do: [:i | menu add: (SimpleMIDIPort portDescription: i) 
							target: self 
							selector: #midiPortNum:
							argument: i].	
	menu popUpInWorld.
	self tryToOpenMidiPort.

]

{ #category : #'byob OOP' }
ScratchStageMorph >> passiveLookLike: costumeName [
	"Change to the costume with the given name. Noop if there is no costume of the given name in my library."

	zoom := 100.
	hPan := 0.
	vPan := 0.
	super lookLike: costumeName.

	self propagate: #costumeIndex
]

{ #category : #drawing }
ScratchStageMorph >> patchAt: patchRect withoutWatchersAnd: stopMorph andNothingAbove: stopThere [
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
		((m isKindOf: WatcherMorph) or: [(m isKindOf: SensorBoardMorph)])
			ifFalse: [m fullDrawOn: c]].
	^ c form

]

{ #category : #byob }
ScratchStageMorph >> pauseAllProcesses [
	"Pause all running Scratch processes."

	| allObjs |
	"pause all sounds"
	SoundPlayer pauseAll.
		
	"clear all processes, including those with error feedback"
"
	allObjs _ submorphs select: [:m | m isKindOf: ScriptableScratchMorph].
	allObjs _ allObjs copyWith: self.
	allObjs do: [:obj |
		(obj blocksBin isKindOf: Morph) ifTrue: [
			obj blocksBin submorphs do: [:b |
				(b isKindOf: BlockMorph) ifTrue: [b pauseProcess]]]].
"

	runningBlocks do: [:each |
		each pauseProcess]

]

{ #category : #'pen support' }
ScratchStageMorph >> penTrailsForm [

	^ penTrailsForm

]

{ #category : #'pen support' }
ScratchStageMorph >> penTrailsForm: aForm [

	penTrailsForm := aForm.
	penTrailsForm ifNotNil: [self createOrResizeTrailsForm].

]

{ #category : #'pen support' }
ScratchStageMorph >> penUpOrDownChangeFor: aSprite [
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

{ #category : #drawing }
ScratchStageMorph >> previewForm [
	"Answer a full-size preview of me and my submorphs. Use super fullDrawOn: to avoid drawing the shadows along the top and left edges of the workspace."

	| canvas |
	canvas := FormCanvas extent: bounds extent depth: 32.
	canvas translateBy: bounds topLeft negated during: [:c | super fullDrawOn: c].
	^ canvas form

]

{ #category : #'scratch processes/events' }
ScratchStageMorph >> processesToRun [
	"Answer a collection of processes to run. Filter out any processes for objects have been picked up. Always return a copy of the processes list."

	| result m |
	result := runningBlocks collect: [:b | b scratchProc].
	result := result select: [:proc | proc notNil].

	World activeHand submorphs size > 0 ifTrue: [
		m := World activeHand submorphs first.
		result := result select: [:proc | (proc includesReceiver: m) not]].

	^ result
 
]

{ #category : #byob }
ScratchStageMorph >> referenceToList: aScratchList [

	"answer an Array describing the variable which holds an anonymous list, nil
	if there isn't any.

	format:

		1 - target obj name
		2 - var name"

	self varNames do: [:key |
		aScratchList == (vars at: key)
			ifTrue: [^ Array with: 'Stage' with: key ]].

	sprites do: [:sprite |
		sprite varNames do: [:vname |
			aScratchList == (sprite getVar: vname)
				ifTrue: [^ Array with: sprite objName with: vname ]]].

	^ nil
]

{ #category : #'scratch processes/events' }
ScratchStageMorph >> rejectDropEvent: evt [
	"we should only reject drops if they're not sprites, variables, etc. Should check it out better"
	self flag: 'to review'.  
	^false
]

{ #category : #'scratch processes/events' }
ScratchStageMorph >> removeTerminatedProcesses [
	"Remove terminated processes from the process list."

	| newRunning proc |
	newRunning := runningBlocks species new: 100.
	runningBlocks do: [:b |
		(proc := b scratchProc) ifNotNil: [
			proc isRunning
				ifTrue: [newRunning addLast: b]
				ifFalse: [proc errorFlag ifFalse: [b stop]]]].

	runningBlocks := newRunning.

]

{ #category : #'looks ops' }
ScratchStageMorph >> rerecordScene [

	| sceneName sceneList menu |
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
ScratchStageMorph >> rerecordScene: sceneName [
	sceneStates at: sceneName put: self backgroundIndex.
	submorphs do: [:m |
		(m isKindOf: ScratchSpriteMorph) ifTrue: [
			m recordScene: sceneName]].

]

{ #category : #byob }
ScratchStageMorph >> resumeAllProcesses [
	"Pause all running Scratch processes."

	| allObjs |
	"resume all sounds"
	SoundPlayer resumeAll.

	"clear all processes, including those with error feedback"
"
	allObjs := submorphs select: [:m | m isKindOf: ScriptableScratchMorph].
	allObjs := allObjs copyWith: self.
	allObjs do: [:obj |
		(obj blocksBin isKindOf: Morph) ifTrue: [
			obj blocksBin submorphs do: [:b |
				(b isKindOf: BlockMorph) ifTrue: [b resumeProcess]]]].

"

	runningBlocks do: [:each |
		each resumeProcess]

]

{ #category : #menus }
ScratchStageMorph >> rightButtonMenu [
	"Present the right button menu."

	| menu |
	menu := MenuMorph new defaultTarget: self.
	menu add: 'grab screen region for new sprite' action: #grabSpriteFromScreen.
	menu addLine.
	menu add: 'save picture of stage...' action: #stageShot.
	menu localize; popUpInWorld.

]

{ #category : #'dropping/grabbing' }
ScratchStageMorph >> rootForGrabOf: aMorph [
	"Allow the given submorph to be extracted."

	| root |
	root := aMorph.
	[root = self] whileFalse: [
		root owner == self ifTrue: [^ root].
		root := root owner].

	^ super rootForGrabOf: aMorph

]

{ #category : #accessing }
ScratchStageMorph >> rotationCenter [

	^ costume rotationCenter

]

{ #category : #media }
ScratchStageMorph >> savePhoto: aForm [

	| n f |
	n := self unusedMediaNameFromBaseName: 'background' localized, '1'.

	f := Form extent: self extent depth: 32.
	(WarpBlt toForm: f)
		sourceForm: aForm;
		cellSize: 1;  "installs a new colormap if cellSize > 1"
		combinationRule: Form over;
		copyQuad: aForm boundingBox innerCorners toRect: f boundingBox.

	self addMediaItem: (ImageMedia new mediaName: n; form: f).


]

{ #category : #'looks ops' }
ScratchStageMorph >> sceneNames [

	| setOfNames |
	setOfNames := Set new.
	submorphs do: [:m |
		(m isKindOf: ScratchSpriteMorph) ifTrue: [
			setOfNames addAll: m scenes]].

	^ setOfNames asArray sort, (Array
		with: '-'
		with: 'record' localized, ScratchTranslator ellipsesSuffix
		with: 're-record' localized, ScratchTranslator ellipsesSuffix)

]

{ #category : #accessing }
ScratchStageMorph >> scratchServer [

	^ scratchServer

]

{ #category : #accessing }
ScratchStageMorph >> scratchServer: anObject [

	scratchServer := anObject.

]

{ #category : #accessing }
ScratchStageMorph >> sensorBoard [

	^ sensorBoard

]

{ #category : #accessing }
ScratchStageMorph >> sensorBoard: aSensorBoardMorph [

	sensorBoard := aSensorBoardMorph.

]

{ #category : #'looks ops' }
ScratchStageMorph >> setHPanTo: aNumber [
	"Set my horizontal pan to the given offset."

	hPan := aNumber truncated.
	self changed.


]

{ #category : #'sound ops' }
ScratchStageMorph >> setTempoTo: aNumber [

	tempoBPM := (aNumber asNumberNoError within: 20 and: 500).

]

{ #category : #'looks ops' }
ScratchStageMorph >> setVPanTo: aNumber [
	"Set my vertical pan to the given offset."

	vPan := aNumber truncated.
	self changed.


]

{ #category : #'looks ops' }
ScratchStageMorph >> setZoomTo: percent [
	"Set my zoom to the given percent."

	zoom := percent truncated.
	self changed.

]

{ #category : #'looks ops' }
ScratchStageMorph >> showBackground: costumeNameOrIndex [
	"This is lookLike: for the stage..."

	self lookLike: costumeNameOrIndex.

]

{ #category : #accessing }
ScratchStageMorph >> showMotorBlocks [

	^ showMotorBlocks

]

{ #category : #accessing }
ScratchStageMorph >> showMotorBlocks: aBoolean [

	showMotorBlocks := aBoolean.

]

{ #category : #'looks ops' }
ScratchStageMorph >> showScene: sceneName [

	(sceneStates includesKey: sceneName) ifTrue: [
		self showBackground: (sceneStates at: sceneName)].

	submorphs do: [:m |
		(m isKindOf: ScratchSpriteMorph) ifTrue: [
			m setScene: sceneName]].

]

{ #category : #accessing }
ScratchStageMorph >> sprites [

	^ sprites

]

{ #category : #'event handling' }
ScratchStageMorph >> stageShot [

	| result |
	result := ScratchFileChooserDialog
		chooseNewFileDefault: ''
		title: 'Save Stage Shot'
		type: #stageShot.
	result = #cancelled ifTrue: [^ self].
	result size > 0 ifTrue: [self exportFileName: result].

]

{ #category : #drawing }
ScratchStageMorph >> stageShotForm [
	"Answer a stage shot of me and my submorphs."

	^ self stageShotSized: self width @ self height

]

{ #category : #drawing }
ScratchStageMorph >> stageShotSized: size [
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
ScratchStageMorph >> stampCostume: aSprite [
	"Stamp a copy of the given sprite on my pen trails form."

	self createOrResizeTrailsForm.
	aSprite filteredForm
		displayOn: penTrailsForm
		at: (aSprite position - self topLeft)
		rule: Form paint.

]

{ #category : #'event handling' }
ScratchStageMorph >> startDrag: evt [
	"Ignore drag events."

]

{ #category : #'scratch processes/events' }
ScratchStageMorph >> startProcessFor: topBlock [
	"Start a process to run the given block or stack of blocks. Return the new process."

	| sequence proc |
	sequence := topBlock blockSequence.
	sequence first isHatBlock ifTrue: [
		sequence := sequence allButFirst].  "skip hat block"

	topBlock scratchProc ifNotNil: [topBlock stop].

	proc := PhratchProcess new
		topBlock: topBlock;
		expression: sequence.
	topBlock scratchProc: proc.

	(runningBlocks includes: topBlock) ifFalse: [runningBlocks addLast: topBlock].

	^ proc

]

{ #category : #byob }
ScratchStageMorph >> startProcessForSequence: anArray [
	"Start a process to run the given block or stack of blocks. Return the new process."

	| sequence proc topBlock |
	sequence := anArray last.
	topBlock := sequence first.
	sequence first isHatBlock ifTrue: [
		sequence := sequence allButFirst].  "skip hat block"

	topBlock scratchProc ifNotNil: [topBlock stop].

	proc := PhratchProcess new
		topBlock: topBlock;
		scriptList: anArray;
		expression: sequence.
	topBlock scratchProc: proc.
	(runningBlocks includes: topBlock) ifFalse: [runningBlocks addLast: topBlock].

	^ proc

]

{ #category : #nesting }
ScratchStageMorph >> step [

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
ScratchStageMorph >> stepProcesses [
	"Run each Scratch process until it gives up control, then filter out any processes that have terminated."
	"Details: Iterate over a copy of processes to allow processes to stop themselves. During development, the error catcher makes it difficult to track down errors, so it can be disabled."

	| proc |
"	sensorBoard processIncomingData."

	PhratchProcess blockHighlightMSecs = 0 ifTrue: [^ self stepProcessesTurbo].

	inProcessStep ifTrue: [^ self].
	inProcessStep := true.
	ScratchFrameMorph useErrorCatcher
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
ScratchStageMorph >> stepProcessesTurbo [
	"Run each Scratch process until it gives up control, then filter out any processes that have terminated. Do this repeatedly until time is up."

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
ScratchStageMorph >> stopAll [
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
"	WeDoPlugin resetWeDo."
	self stopPlaying.
	self allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [m stopPlaying]].

	DebuggerFrameMorph allInstancesDo: [:df | df delete ].

	(sFrame := self ownerOrYourselfThatIsA: ScratchFrameMorph) ifNotNil: [
		sFrame scriptsPane allMorphsDo: [:m |
			(m respondsTo: #stop) ifTrue: [m stop].
			(m respondsTo: #litUp:) ifTrue: [m litUp: false]].
		World startSteppingSubmorphsOf: sFrame].

	World startSteppingSubmorphsOf: self.

]

{ #category : #'scratch processes/events' }
ScratchStageMorph >> stopAllProcesses [
	"Stop all running Scratch processes."

	| allObjs |
	"clear all processes, including those with error feedback"
	allObjs := submorphs select: [:m | m isKindOf: ScriptableScratchMorph].
	allObjs := allObjs copyWith: self.
	allObjs do: [:obj |
		(obj blocksBin isKindOf: Morph) ifTrue: [
			obj blocksBin submorphs do: [:b |
				(b isKindOf: BlockMorph) ifTrue: [b clearProcess]]]].

	runningBlocks := OrderedCollection new.
	inProcessStep := false.

]

{ #category : #byob }
ScratchStageMorph >> stopAllScriptsFor: eventName [

"	remember to implement this in the mesh network later -jens"
"	scratchServer ifNotNil: [scratchServer queueBroadcast: name]."

	"stop scripts"
	submorphs do: [:m | (m isKindOf: ScriptableScratchMorph) ifTrue: [
		m stopScriptsFor: eventName]].
	self stopScriptsFor: eventName 

]

{ #category : #'scratch processes/events' }
ScratchStageMorph >> stopAllSounds [
	"Stop all sounds and MIDI notes/drums."

	SoundPlayer shutDown.
	self midiAllNotesOff.


]

{ #category : #'scratch processes/events' }
ScratchStageMorph >> stopAsks [
	"Stop/close any ask that is currently on the screen."

	PhratchPrompterMorph allInstancesDo: [:m | m stopAsk].
	PhratchPrompterMorph clearLastAnswer.

]

{ #category : #'object i/o' }
ScratchStageMorph >> storeFieldsOn: anObjStream [

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
ScratchStageMorph >> tempo [

	^ tempoBPM

]

{ #category : #drawing }
ScratchStageMorph >> thumbnailForm [
	"Answer a thumbnail of me and my submorphs."

	^ self stageShotSized: (160@120)

]

{ #category : #byob }
ScratchStageMorph >> togglePause [

	self isPaused
		ifTrue: [self resumeAllProcesses]
		ifFalse: [self pauseAllProcesses] 
]

{ #category : #'event handling' }
ScratchStageMorph >> transformFrom: uberMorph [
	"Return a transform to map coorinates of uberMorph, a morph above me in my owner chain, into the coordinates of my submorphs."

	| transform |
	self isQuarterSize ifFalse: [^ super transformFrom: uberMorph].

	transform := MorphicTransform offset: (self position // -2) angle: 0.0 scale: 0.5.
	owner == uberMorph ifTrue: [^ transform].
	owner ifNil: [^ transform].
	^ (owner transformFrom: uberMorph) composedWith: transform


]

{ #category : #midi }
ScratchStageMorph >> tryToOpenMidiPort [
	"Attempt to open the MIDI port. First try the port selected by the user, if any. If that port number is not a MIDI output port, try to find another port number. If all measures fail, leave midiPort set to nil."

	| possiblePorts dir portNum |
	OSPlatform isUnix ifTrue: [midiPort := nil. ^ self].

	possiblePorts := (0 to: SimpleMIDIPort primPortCount - 1) select: [:i |
		dir := SimpleMIDIPort primPortDirectionalityOf: i.
		(dir = 2) | (dir = 3)].  "out or in/out port"

	possiblePorts size = 0 ifTrue: [midiPort := nil. ^ self].  "no midi ports"


	(possiblePorts includes: midiPortNum)
		ifTrue: [portNum := midiPortNum]  "use the port requested by the user"
		ifFalse: [portNum := possiblePorts first].  "use the first available port"
			
	[midiPort := SimpleMIDIPort openOnPortNumber: portNum. midiPort ensureOpen] 
		ifError: [midiPort := nil].

]

{ #category : #byob }
ScratchStageMorph >> unloadAllUnusedCustomBlocks [

	'updating...' 
		displayProgressAt: Display center - (32@5)  "Sensor cursorPoint"
		from: 0 to: ((self allMorphs) select: [:m| m isKindOf: ScriptableScratchMorph]) size
		during: [:bar | | i | i := 0.

	{self}, self sprites do: [:obj |
		i := i + 1. bar value: i.
		obj unloadUnusedCustomBlocks]]

]

{ #category : #'event handling' }
ScratchStageMorph >> unlockedMorphsAt: aPoint addTo: mList [
	"Adjust aPoint to handle quarter-size case if necessary."

	| p |
	self isQuarterSize ifFalse: [
		super unlockedMorphsAt: aPoint addTo: mList.
		^ mList].

	(self containsPoint: aPoint) ifFalse: [^ mList]. "quick elimination"
	p := self position + (2 * (aPoint - self position)).

	submorphs size > 0 ifTrue: [
		submorphs do: [:m | m unlockedMorphsAt: p addTo: mList]].
	mList addLast: self.

	^ mList

]

{ #category : #'pen support' }
ScratchStageMorph >> updatePenPositionFor: aSprite [
	"Update the given sprites pen position if necessary. Used to avoid drawing glitches when going between normal and presentation mode."

	lastPenPositions ifNil: [^ self].  "no pens are down"
	(lastPenPositions includes: aSprite) ifTrue: [
		lastPenPositions at: aSprite put: aSprite penPosition].

]

{ #category : #accessing }
ScratchStageMorph >> updateSpritesList [
	"Populate the sprites list, which keeps track of the ordering of the sprite thumbnails"

	| frame |
	frame := self ownerOrYourselfThatIsA: ScratchFrameMorph.
	frame ifNil: [^ self].
	sprites := OrderedCollection new.
	frame libraryPane spriteThumbnails do: [:m | m target ifNotNil: [sprites addLast: m target]].

]

{ #category : #drawing }
ScratchStageMorph >> updateStageDisplay [
	"Redraw the damaged areas of this stage directly onto the display. Assumes that no other morph is in front of me."

	| root damageList |
	root := owner.
	[root owner notNil] whileTrue: [root := root owner].
	(root respondsTo: #damageRecorder) ifFalse: [^ self].

	damageList := root damageRecorder filteredDamageWithin: self bounds.
	damageList size > 0 ifTrue: [self incrRedraw: damageList].

]

{ #category : #'pen support' }
ScratchStageMorph >> updateTrailsForm [
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
ScratchStageMorph >> userSelectSpriteDefault: defaultSprite butNotAnyOf: excludeArray [

	| menu current |
	menu := MenuMorphNG new defaultTarget: self.
	(defaultSprite isKindOf: ScratchSpriteMorph)
		ifTrue: [current := defaultSprite objName]
		ifFalse: [current := 'none'].
	menu title: 'current parent: ', current.
	sprites do: [:each |
		(excludeArray includes: each) ifFalse: [
			menu add: each objName value: each]].
	menu addLine.
	menu add: 'none' value: #null.
	^ (menu defaultTarget: #null; popUpInWorld; selectedValue) 

]
