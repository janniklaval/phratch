"
I am a Scratch variable readout/editor. I can view both variables and reporter values. I support various display modes.

"
Class {
	#name : #WatcherMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'titleMorph',
		'readout',
		'readoutFrame',
		'watcher',
		'lastTargetName',
		'isSpriteSpecific',
		'isLarge',
		'lastPosition',
		'sliderMin',
		'sliderMax',
		'phratchSlider',
		'isColor'
	],
	#category : #'Phratch-UI-Watchers'
}

{ #category : #initialization }
WatcherMorph >> buildReadout [
	"Build my readout component morphs."

	isColor ifFalse: [
		readout := PhratchUpdatingStringMorph new
		contents: '';
		floatPrecision: 0.1;
		stepTime: 100.
	readout
		font: (PhratchFrameMorph getFont: #Watcher);
		forceUnicodeRendering: true;
		target: self target;
		color: Color white.]
	ifTrue: [
		readout := UpdatingColorMorph new
			color: (Color black);
			stepTime: 100].
	readoutFrame := WatcherReadoutFrameMorph new addMorph: readout.

]

{ #category : #'event handling' }
WatcherMorph >> click: evt [

	evt hand toolType = 'CutTool' ifTrue: [
		evt shiftPressed ifFalse: [evt hand toolType: nil].
		PhratchFrameMorph putInClipboard: self.
		self aboutToBeGrabbedBy: evt hand.
		self delete].

]

{ #category : #'falta adaptar' }
WatcherMorph >> convertFromOldWatcher [
	"Convert myself from old watcher structure to the current structure."

	| o p target selector param wasLarge showSlider oldRange c |
	o := self owner.
	p := self position.
	target := readout target.
	selector := readout getSelector.
	(selector = #getUserVar:) ifTrue: [selector := #getVar:].  "update selector"
	param := readout parameter.
	wasLarge := readoutFrame isLarge.
	showSlider := phratchSlider notNil.
	oldRange := self sliderRange.

	self delete; removeAllMorphs; initialize.
	self
		position: p;
		target: target selector: selector parameter: param;
		sliderRange: oldRange.
	self layoutForViewer.

	selector = #getVar:
		ifTrue: [self setCategoryColor: target variableBlockColor]
		ifFalse: [
			c := ScriptablePhratchMorph blockColorDict at: selector ifAbsent: [nil].
			c ifNotNil: [self setCategoryColor: c]].

	o addMorph: self.
	self updateTargetName.
	wasLarge ifTrue: [self showLargeReadout].
	showSlider ifTrue: [self showSlider].

]

{ #category : #copying }
WatcherMorph >> copyRecordingIn: dict [
	"Overridden to copy my readout if it is not currently showing. This avoids accidentally sharing the readout morph with the original Watcher that is being copied. If the readout is showing, it is copied by the fullCopy operation, so we don't need to copy it."

	| result |
	result := super copyRecordingIn: dict.
	readoutFrame owner ifNil: [result readoutFrame: readoutFrame fullCopy].
	^ result

]

{ #category : #'right button menu' }
WatcherMorph >> delete [

	super delete.
	PhratchFrameMorph allInstancesDo: [:frame | frame deletingWatcher].

]

{ #category : #'falta adaptar' }
WatcherMorph >> doubleClick: evt [
	"Toggle slider/large readout view if I'm in the work pane."

	(self owner isKindOf: PhratchStageMorph) ifFalse: [^ self].  "ignore if not on stage"

	phratchSlider ifNotNil: [^ self showLargeReadout]. "slider -> large readout"
	isLarge ifTrue: [^ self showSmallReadout].  "large readout -> small readout"
	self isVariableWatcher
		ifTrue: [self showSlider]  "small readout -> slider"
		ifFalse: [self showLargeReadout].  "small readout -> large readout"

]

{ #category : #accessing }
WatcherMorph >> evaluate [
	"Answer the value of my variable."

	^ readout valueFromTargetOrNil

]

{ #category : #accessing }
WatcherMorph >> eventHandler [ 
	self assureExtension.
	^ super eventHandler
]

{ #category : #'object i/o' }
WatcherMorph >> fieldsVersion [

	^ 5

]

{ #category : #accessing }
WatcherMorph >> getAssociatedSprite [
	"Return my target."

	^ self target

]

{ #category : #accessing }
WatcherMorph >> getSelector [

	^ readout getSelector

]

{ #category : #accessing }
WatcherMorph >> getVariable [

	readout parameter notNil
		ifTrue: [^ readout parameter]
		ifFalse: [^ readout getSelector]

]

{ #category : #'event handling' }
WatcherMorph >> handlesMouseDown: evt [

	^ self world notNil
]

{ #category : #'right button menu' }
WatcherMorph >> hideSlider [

	phratchSlider ifNotNil: [
		sliderMin := phratchSlider minVal.
		sliderMax := phratchSlider maxVal.
		phratchSlider delete.
		phratchSlider := nil].

]

{ #category : #'object i/o' }
WatcherMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		titleMorph
		readout
		readoutFrame
		phratchSlider
		watcher) from: anObjStream.
	watcher ifNotNil: [watcher useRoundedCorners].
	classVersion = 1 ifTrue: [^ self].
	
	"fields added in version 2"
	self initFieldsNamed: #(
		isSpriteSpecific
		unused
	) from: anObjStream.

	"fields added in version 4"
	classVersion < 4 ifTrue: [^ self].
	self initFieldsNamed: #(
		sliderMin
		sliderMax
	) from: anObjStream.

	"fields added in version 5"
	classVersion < 5 ifTrue: [^ self].
	self initFieldsNamed: #(
		isLarge
		isColor
	) from: anObjStream.

]

{ #category : #initialization }
WatcherMorph >> initialize [

	super initialize.
	titleMorph := StringMorph contents: '???'.
	titleMorph font: (PhratchFrameMorph getFont: #Watcher).
	readout := readoutFrame := phratchSlider := nil.
	lastTargetName := nil.
	isSpriteSpecific := true.
	isLarge := false.
	isColor := false.
	sliderMin := 0.
	sliderMax := 100.
	watcher := AlignmentMorph new
		color: Color transparent;
		borderWidth: 0;
		inset: 0;
		listDirection: #leftToRight;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		cellPositioning: #leftCenter;
		centering: #center.
	self 
		color: (Color r: (193/255) g: (196/255) b: (199/255));
		borderWidth: 1;
		borderColor: (Color r: (148/255) g: (145/255) b: (145/255));
		listDirection: #topToBottom;
		centering: #center;
		inset: 2;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		buildReadout;
		useRoundedCorners;
		addMorphBack: watcher;
		addMorphBack: (Morph new color: Color transparent; extent: 5@1).

]

{ #category : #'panther actions' }
WatcherMorph >> isColor [

	^ isColor
]

{ #category : #'panther actions' }
WatcherMorph >> isColor: aBoolean [

	isColor := aBoolean.
]

{ #category : #accessing }
WatcherMorph >> isLarge [

	^ isLarge

]

{ #category : #accessing }
WatcherMorph >> isReporter [

	^ true

]

{ #category : #private }
WatcherMorph >> isVariableWatcher [
	"Answer true if I am watching a variable."

	^ readout getSelector = #getVar:

]

{ #category : #'dropping/grabbing' }
WatcherMorph >> justDroppedInto: aMorph event: evt [

	(aMorph isKindOf: PhratchStageMorph) ifTrue: [
		super justDroppedInto: aMorph event: evt.
		self world ifNotNil: [self world startSteppingSubmorphsOf: self].
		^ self].

	"delete me if dropped anywhere but the stage"
	lastPosition ifNil: [lastPosition := (self formerPosition ifNil: [0@0])].
	self position: lastPosition.
	^ self delete

]

{ #category : #accessing }
WatcherMorph >> languageChanged [
	"Force label update after switching languages."

	lastTargetName := nil.
	self updateTargetName.
	readout target: readout target.  "forces contents to update"
	titleMorph extent: (PhratchTranslator stringExtent: titleMorph contents font: titleMorph font).
	(readout contents isKindOf: Form) ifTrue: [
		readout extent: readout contents extent + (10 @ 10).
		^self ].
	readout extent: (PhratchTranslator stringExtent: readout contents font: readout font).

]

{ #category : #private }
WatcherMorph >> layoutForViewer [

	watcher removeAllMorphs.
	PhratchTranslator isRTL
		ifTrue: [watcher
			addMorphBack: (Morph new color: color; extent: 2@0);
			addMorphBack: readoutFrame;
			addMorphBack: (AlignmentMorph new color: color; width: 4; hResizing: #rigid);
			addMorphBack: titleMorph;
			addMorphBack: (Morph new color: color; extent: 3@0)]
		ifFalse: [watcher
			addMorphBack: (Morph new color: color; extent: 3@0);
			addMorphBack: titleMorph;
			addMorphBack: (AlignmentMorph new color: color; width: 4; hResizing: #rigid);
			addMorphBack: readoutFrame;
			addMorphBack: (Morph new color: color; extent: 2@0)].

]

{ #category : #accessing }
WatcherMorph >> layoutStyle [
	"Return a symbol indicating my current layout type: small, slider, large."

	phratchSlider notNil ifTrue: [^ #slider].
	^ self isLarge ifTrue: [#large] ifFalse: [#small]

]

{ #category : #accessing }
WatcherMorph >> layoutStyle: aSymbol [
	"Set my layout style to one of: #small, #slider, #large."

	self layoutForViewer.
	#slider = aSymbol ifTrue: [^ self showSlider].
	#large = aSymbol ifTrue: [^ self showLargeReadout].
	self showSmallReadout.

]

{ #category : #copying }
WatcherMorph >> mapReceiver: oldObj to: newObj [
	"Used in cloning an object to make blocks that refererred to the original object new refer to the new copy."

	readout target == oldObj ifTrue: [readout target: newObj].

]

{ #category : #'event handling' }
WatcherMorph >> mouseDown: evt [

	evt rightButtonPressed ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu].

	evt hand waitForClicksOrDrag: self event: evt.

]

{ #category : #accessing }
WatcherMorph >> parameter [

	^ readout parameter

]

{ #category : #copying }
WatcherMorph >> readoutFrame: readoutFrameMorph [
	"Fix up my readout when copying."

	readoutFrame := readoutFrameMorph.
	readout := readoutFrameMorph firstSubmorph.

]

{ #category : #private }
WatcherMorph >> replace: argStr with: translatedArg in: s [
	"Answer a copy of the given string in which the first (only) occurance of argStr is replaced by translatedArg."

	| i |
	i := s findString: argStr startingAt: 1.
	i = 0 ifTrue: [^ s].
	^ ((s copyFrom: 1 to: i - 1), translatedArg, (s copyFrom: i + argStr size to: s size))

]

{ #category : #private }
WatcherMorph >> replaceArgIn: aString with: arg [

	| i str |
	str := aString.
	i := str findString: '$'.
	((i > 0) and: [i < str size]) ifTrue: [
		((str at: (i + 1)) isLetter) ifFalse: [^ str].
		(str indexOf: $$ startingAt: (i + 1)) > 0 ifFalse: [^ str].
		str := (str copyFrom: 1 to: i - 1), arg, (str copyFrom: (str indexOf: $$ startingAt: (i + 1)) + 1 to: str size)].
	^ str
]

{ #category : #'right button menu' }
WatcherMorph >> rightButtonMenu [

	| menu hasSlider |
	(self ownerOrYourselfThatIsA: PhratchStageMorph) ifNil: [^ self].

	menu := MenuMorph new defaultTarget: self.
	hasSlider := self isVariableWatcher and: [phratchSlider notNil].

	hasSlider not & isLarge not
		ifTrue: [menu add: '* ', 'normal readout' localized,' *'	action: #showSmallReadout]
		ifFalse: [menu add: '  ', 'normal readout' localized		action: #showSmallReadout].

	hasSlider not & isLarge
		ifTrue: [menu add: '* ', 'large readout' localized, ' *'		action: #showLargeReadout]
		ifFalse: [menu add: '  ', 'large readout' localized			action: #showLargeReadout].

	self isVariableWatcher ifTrue: [
		phratchSlider
			ifNil: [menu add: '  ', 'slider' localized action: #showSlider]
			ifNotNil: [
				menu add: '* ', 'slider' localized,' *' action: #showSlider.
				menu addLine.
				menu add: '  ', 'set slider min and max' localized action: #setSliderMinAndMax]].

	menu addLine.
	menu add: '  ',  'hide' localized action: #delete.
	menu invokeModal.

]

{ #category : #'dropping/grabbing' }
WatcherMorph >> rootForGrabOf: aMorph [
	"Allow myself to be extracted."

	(owner notNil and: [owner isPartsBin])
		ifTrue: [^ super rootForGrabOf: aMorph]
		ifFalse: [^ self].

]

{ #category : #accessing }
WatcherMorph >> selectorAndArg [
	"Answer an array containing my selector and argument (if any)."

	^ Array with: readout getSelector with: readout parameter
]

{ #category : #initialization }
WatcherMorph >> setCategoryColor: aColor [

	readoutFrame color: aColor.

]

{ #category : #'falta adaptar' }
WatcherMorph >> setSliderMinAndMax [

	| newRange |
	newRange := SliderRangeDialog initialMin: sliderMin max: sliderMax.
	newRange ifNil: [^ self].

	sliderMin := newRange first.
	sliderMax := newRange last.
	phratchSlider ifNotNil: [
		phratchSlider
			minVal: sliderMin;
			maxVal: sliderMax;
			truncate: (sliderMin isInteger & sliderMax isInteger);
			updateSliderPosition].

]

{ #category : #'right button menu' }
WatcherMorph >> showLargeReadout [

	self hideSlider.

	isLarge := true.
	isColor ifFalse: [
		readout font: (PhratchFrameMorph getFont: #WatcherLarge)].
	readoutFrame
		borderColor: (Color gray: 3);
		fixLayout.
	watcher removeAllMorphs; addMorphBack: readoutFrame.
	self
		inset: 0;
		color: Color transparent;
		borderColor: Color transparent;
		cornerStyle: #square.

]

{ #category : #'falta adaptar' }
WatcherMorph >> showSlider [

	self hideSlider.
	self showSmallReadout.

	phratchSlider := WatcherSliderMorph new
		target: readout target;
		actionSelector: #setVar:to:;
		arguments: (Array with: self getVariable);
		truncate: (sliderMin isInteger & sliderMax isInteger);
		minVal: sliderMin;
		maxVal: sliderMax;
		sliderThickness: 0;
		height: 10;
		width: self width - 12.

	self addMorphBack: phratchSlider.
	self world ifNotNil: [self world startSteppingSubmorphsOf: phratchSlider].
	phratchSlider updateSliderPosition.

]

{ #category : #'right button menu' }
WatcherMorph >> showSmallReadout [

	self hideSlider.

	isLarge := false.
	isColor ifFalse: [
		readout font: (PhratchFrameMorph getFont: #Watcher)].
	readoutFrame
		borderColor: Color white;
		fixLayout.
	self
		inset: 2;
		color: (Color r: (193/255) g: (196/255) b: (199/255));
		borderColor: (Color r: (148/255) g: (145/255) b: (145/255));
		cornerStyle: #rounded.

	self layoutForViewer.
]

{ #category : #accessing }
WatcherMorph >> sliderRange [
	"Return an array containting the slider max and min."

	^ Array with: sliderMin with: sliderMax

]

{ #category : #accessing }
WatcherMorph >> sliderRange: anArray [
	"Set the slider max and min."

	sliderMin := anArray first.
	sliderMax := anArray second.

]

{ #category : #'event handling' }
WatcherMorph >> startDrag: evt [

	self world ifNil: [^ self].  "don't pick me up if in presentation mode"
	lastPosition := self position.
	super startDrag: evt.

]

{ #category : #stepping }
WatcherMorph >> step [

	self updateTargetName.
	readoutFrame ifNotNil: [readoutFrame fixLayout].
	phratchSlider ifNotNil: [
		(World activeHand hasMouseFocus: phratchSlider) ifFalse: [
			phratchSlider width: self width - 12.
			phratchSlider updateSliderPosition]].

]

{ #category : #stepping }
WatcherMorph >> stepTime [

	^ 100

]

{ #category : #'object i/o' }
WatcherMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		titleMorph
		readout
		readoutFrame
		phratchSlider
		watcher
		isSpriteSpecific
		unused
		sliderMin
		sliderMax
		isLarge
		isColor
	) on: anObjStream.
	      

]

{ #category : #accessing }
WatcherMorph >> target [

	^ readout target

]

{ #category : #accessing }
WatcherMorph >> target: anObject [

	readout target: anObject.

]

{ #category : #'falta adaptar' }
WatcherMorph >> target: anObject selector: selector parameter: parameter [
	"Initialize this watcher. If parameter is not nil, then this watcher is used to access user-defined variables or parameterized reporters."

	readout
		target: anObject;
		getSelector: selector asSymbol;
		parameter: parameter.

	isSpriteSpecific := ScriptablePhratchMorph isSpriteSpecificTarget: anObject selector: selector.
]

{ #category : #accessing }
WatcherMorph >> titleMorph [

	^ titleMorph

]

{ #category : #accessing }
WatcherMorph >> titleMorph: anObject [

	titleMorph := anObject.

]

{ #category : #private }
WatcherMorph >> translatedName [
	"Answer the name for this watcher based on my selector and argument. The names of reporters are translated into the current language. The names of variables are left untouched."

	| sel spec result param |
	readout target ifNil: [^ 'xxx'].
	sel := readout getSelector.
	(#(getVar: reportColor: ) includes: sel) ifTrue: [^ readout parameter].

	spec := readout target blockSpecForSelector: sel.
	spec ifNil: [^ sel].

	result := PhratchTranslator translationFor: spec.
	param := readout parameter.
	param ifNil: [param := ''].

	(param isKindOf: String) ifTrue: [result := self replaceArgIn: result with: param] ifFalse: [result := self replaceArgIn: result with: '[]'].
	
	"#sensor: = sel ifTrue: [
		result := self replace: '$SensorNames$' with: (PhratchTranslator translationFor: param) in: result].
	#sensorPressed: = sel ifTrue: [
		result := self replace: '$SensorBooleans$' with: (PhratchTranslator translationFor: param) in: result]."

	^ result
]

{ #category : #private }
WatcherMorph >> updateTargetName [
	"Check if I should display my target's name."

	| targetName |
	(self ownerOrYourselfThatIsA: HandMorph) ifNotNil: [^ self].  "do nothing when in a HandMorph"
	isLarge ifTrue: [^ self].  "don't show target or var name if large readout showing"

	targetName := readout target objName.
	(lastTargetName = targetName) ifTrue: [^ self].  "no change"

	isSpriteSpecific
		ifTrue: [titleMorph contents: targetName, ' ', self translatedName]
		ifFalse: [titleMorph contents: self translatedName].

	lastTargetName := targetName.

]

{ #category : #'event handling' }
WatcherMorph >> wantsKeyboardFocusFor: aSubmorph [
	"Don't allow shift-click editing of my label."

	^ false

]
