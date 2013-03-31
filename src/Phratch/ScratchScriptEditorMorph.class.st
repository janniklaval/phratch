"
I am a viewer for the scripts and media closet of a Scratch object. I have a heading row containing the object name (editable) and a drop-down menu icon. Below that is a scrollable content area.

"
Class {
	#name : #ScratchScriptEditorMorph,
	#superclass : #DividedImageFrameMorph,
	#instVars : [
		'thumbnailMorph',
		'nameMorph',
		'pageViewerMorph',
		'rotationButtons',
		'lockButton',
		'readoutMorphs',
		'penReadout',
		'currentCategory',
		'tabPaneMorph',
		'deleteButton'
	],
	#category : #'Phratch-UI-Panes'
}

{ #category : #'menu/button ops' }
ScratchScriptEditorMorph >> addComment: anEvent [

	| c scriptsMorph |
	scriptsMorph := (pageViewerMorph allMorphs select: [: m | m isKindOf: ScratchScriptsMorph]) first.
	scriptsMorph addMorph: (c := ScratchCommentMorph new position: anEvent position).
	World activeHand newKeyboardFocus: c commentMorph.

]

{ #category : #byob }
ScratchScriptEditorMorph >> addCustomBlock [

	self target addCustomBlock
]

{ #category : #private }
ScratchScriptEditorMorph >> addDeleteButton [
	"Add button to delete sprite."

	self deleteDeleteButton.

	deleteButton := ToggleButton
		onForm: (ScratchFrameMorph skinAt: #deleteSprite)
		offForm: (ScratchFrameMorph skinAt: #deleteSprite)
		overForm: (ScratchFrameMorph skinAt: #deleteSprite).

	deleteButton
		target: self;
		actionSelector: #deleteSprite;
		setBalloonText: 'Delete this sprite' localized;
		actWhen: #buttonUp;
		isMomentary: true;
		position: (lockButton right + 27)@(nameMorph top + ((nameMorph height - deleteButton height) / 2)).

	self addMorph: deleteButton.

]

{ #category : #private }
ScratchScriptEditorMorph >> addLockButton [
	"Add button to set sprite locked status."

	self deleteLockButton.

	lockButton := ToggleButton
		onForm: (ScratchFrameMorph skinAt: #locked)
		offForm: (ScratchFrameMorph skinAt: #unlocked).

	lockButton
		target: self;
		actionSelector: #toggleSpriteDraggable;
		setBalloonText: 'draggable on website?' localized;
		actWhen: #buttonUp;
		isMomentary: true;
		position: (nameMorph right + 4)@(nameMorph top + ((nameMorph height - lockButton height) / 2)).

	self addMorph: lockButton.
	self updateLockButton.

]

{ #category : #initialization }
ScratchScriptEditorMorph >> addNameBox [

	nameMorph := UpdatingStringFieldMorph new
		font: (ScratchFrameMorph getFont: #UpdatingStringField);
		rightJustify: ScratchTranslator isRTL;
		acceptWhenFocusLost: true;
		position: thumbnailMorph topRight + (17@(thumbnailMorph height * 0.12)).

	self addMorphBack: nameMorph.

]

{ #category : #private }
ScratchScriptEditorMorph >> addReadouts [
	"Add readouts for my target's position and direction."

	| x y label readout s |
	self deleteReadouts.
	readoutMorphs := OrderedCollection new.

	x := nameMorph left.
	y := nameMorph bottom + 5.

	#(('x' xpos) ('y' ypos)('direction' heading)) do: [:spec |

		(ScratchTranslator isRTL and: [(spec at: 1) = 'x' or: [(spec at: 1) = 'y']])
			ifTrue: [s := (':', spec first) asUTF8]
			ifFalse: [s := (spec first localized, ScratchTranslator colonSuffix)].

		label := ScratchStringMorph new
			contents: s;
			font: (ScratchFrameMorph getFont: #XYReadout);
			position: x@y.

		readout := (UpdatingStringMorph on: self target selector: spec second)
			font: (ScratchFrameMorph getFont: #XYReadoutBold);
			forceUnicodeRendering: true;
			color: (Color gray: 0.2);
			contents: '-000';  "this sets the readout size"
			growable: false;
			stepTime: 100;
			position: (label right + 4)@y.

		ScratchTranslator isRTL ifTrue:[
			readout rightJustify: true].

		self addMorph: label; addMorph: readout.
		readoutMorphs add: label; add: readout.

		readout startStepping.
		x := readout right + 2].

	ScratchTranslator isRTL ifTrue: [
		readoutMorphs reversed do: [: m |
			readoutMorphs remove: m.
			readoutMorphs add: m]].

	penReadout := Morph new extent: 15@5.
	penReadout position: (lockButton right + 4)@(nameMorph top + ((nameMorph height - penReadout height) / 2));
		color: Color transparent.
	self addMorph: penReadout.
	readoutMorphs add: penReadout.
	penReadout startStepping.

	readoutMorphs := readoutMorphs asArray.

]

{ #category : #private }
ScratchScriptEditorMorph >> addRotationButtons [
	"Add buttons to set the rotation style."

	| specs x y style button |
	self deleteRotationButtons.
	(self target respondsTo: #rotationStyle:) ifFalse: [^ self].

	specs := #(
		(Smooth		'can rotate')
		(Flip		'only face left-right')
		(None		'don''t rotate')).

	x := self left + 13.
	y := self top + 18.
	specs do: [:pair |
		style := pair first.
		button := ToggleButton
			onForm: (ScratchFrameMorph skinAt: ('rotStyle', style, 'On'))
			offForm: (ScratchFrameMorph skinAt: ('rotStyle', style))
			overForm: (ScratchFrameMorph skinAt: ('rotStyle', style, 'Over')).
		button
			target: self;
			arguments: (Array with: style);
			actionSelector: #setRotationStyle:;
			setBalloonText: pair second localized;
			actWhen: #buttonDown;
			position: x@y.
		self addMorph: button.
		rotationButtons := rotationButtons copyWith: button.
		y := y + button height + 2].

	self updateRotationButtonHighlight.

]

{ #category : #'menu/button ops' }
ScratchScriptEditorMorph >> animateRotationStyle [

	| style thumbForm wasFlipped currentRotation pen center rotatedForm doFlip |
	style := self target rotationStyle.

	thumbnailMorph updateThumbnail.
	thumbForm := thumbnailMorph form deepCopy.
	currentRotation := self target rotationDegrees rounded.
	wasFlipped := ((currentRotation \\ 360) >= 90) & ((currentRotation \\ 360) <= 270).

	thumbnailMorph showDirection: false.

	pen := (PhratchPen newOnForm: thumbnailMorph form) color: Color white.
	center := thumbnailMorph form center.
	currentRotation to: currentRotation + 360 by: 12 do: [:i |
		rotatedForm := thumbForm.  "no rotation by default"
		style = #normal ifTrue: [rotatedForm := thumbForm rotateBy: i].
		style = #leftRight ifTrue: [
			doFlip := ((i \\ 360) >= 90) & ((i \\ 360) <= 270).
			wasFlipped ifTrue: [doFlip := doFlip not].
			doFlip ifTrue: [rotatedForm := thumbForm flipBy: #horizontal centerAt: 0@0]].

		thumbnailMorph form fill: thumbnailMorph form boundingBox fillColor: Color transparent.
		rotatedForm
			displayOn: thumbnailMorph form
			at: (thumbnailMorph extent - rotatedForm extent) // 2
			rule: Form paint.
		pen place: center.
		pen goto: center + (Point r: 22 degrees: i).
		thumbnailMorph changed.

		World displayWorldSafely.
		(Delay forMilliseconds: 20) wait].

	thumbnailMorph showDirection: true.
	thumbnailMorph updateThumbnail.

]

{ #category : #accessing }
ScratchScriptEditorMorph >> bareMinimumWidth [
	"Answer the bare minimum width for this pane to be useable."

	lockButton ifNil: [^ 100].
	^ lockButton right - self left
]

{ #category : #accessing }
ScratchScriptEditorMorph >> categoryChanged: aString [
	"If the given category is my current category, update my contents. Otherwise, do nothing."

	self target ifNil: [^ self].
	currentCategory = aString ifTrue: [self currentCategory: aString].

]

{ #category : #drawing }
ScratchScriptEditorMorph >> cleanUp [
	"Align all scripts vertically in alphabetical order"

	| scriptsMorph |
	scriptsMorph := (pageViewerMorph allMorphs select: [:c | c isKindOf: ScratchScriptsMorph]) first.
	scriptsMorph cleanUp.
	pageViewerMorph
		updateContentsExtent;
		updateScrollbars.


]

{ #category : #initialization }
ScratchScriptEditorMorph >> createTabPane [

	| tabOnForm tabOffForm tabID tabLabel |

	"create tab pane"
	tabPaneMorph := ScratchTabPaneMorph new.
	tabPaneMorph
		borderWidth: 0;
		color: Color transparent;
		targetPane: self.

	tabOnForm := (ScratchFrameMorph skinAt: #tabOn).
	tabOffForm := (ScratchFrameMorph skinAt: #tabOff).

	"add the tabs"
	#(Scripts Costumes Sounds) do: [:spec |
		tabID := spec asString.
		tabLabel := tabID localized.
		tabPaneMorph
			createTab: tabID
			withLabel: tabLabel
			onForm: tabOnForm
			offForm: tabOffForm].

	"set current tab and add to frame"
	tabPaneMorph currentTab: 'Scripts'.
	self addMorph: tabPaneMorph.

]

{ #category : #accessing }
ScratchScriptEditorMorph >> currentCategory [

	^ currentCategory


]

{ #category : #accessing }
ScratchScriptEditorMorph >> currentCategory: aString [

	| xOffset |
	currentCategory := aString.
	self target ifNil: [^ self].
	xOffset := 0.

	World activeHand newKeyboardFocus: nil.

	currentCategory = 'Scripts' ifTrue: [
		pageViewerMorph contents: self target blocksBin].
	currentCategory = 'Costumes' ifTrue: [
		pageViewerMorph contents: (self target costumesPage: xOffset)].
	currentCategory = 'Sounds' ifTrue: [
		pageViewerMorph contents: (self target soundsPage: xOffset)].

	pageViewerMorph contents color: ScratchFrameMorph scriptsPaneColor.

	self world ifNotNil: [self world startSteppingSubmorphsOf: pageViewerMorph contents].


]

{ #category : #private }
ScratchScriptEditorMorph >> deleteDeleteButton [
	"Delete my delete button."

	deleteButton ifNotNil: [
		deleteButton delete.
		deleteButton := nil].

]

{ #category : #private }
ScratchScriptEditorMorph >> deleteLockButton [
	"Delete my lock button."

	lockButton ifNotNil: [
		lockButton delete.
		lockButton := nil].

]

{ #category : #private }
ScratchScriptEditorMorph >> deleteReadouts [
	"Delete the position/rotation readouts."

	readoutMorphs do: [:m | m delete].
	readoutMorphs := #().

]

{ #category : #private }
ScratchScriptEditorMorph >> deleteRotationButtons [
	"Delete the rotation style buttons."

	rotationButtons do: [:m | m delete].
	rotationButtons := #().

]

{ #category : #'menu/button ops' }
ScratchScriptEditorMorph >> deleteSprite [
	"Ask the user if they want to delete the currently selected sprite"

	| response |
	response := DialogBoxMorph askWithCancel: 'Delete this sprite?' localized.
	response = #cancelled ifTrue: [^ self].
	response ifTrue: [thumbnailMorph target undoableDeleteSprite].

]

{ #category : #drawing }
ScratchScriptEditorMorph >> drawBackgroundOn: aCanvas [
	"Draw my background."

	color isTransparent ifTrue: [^ self].

	aCanvas
		fillRectangle: (self topLeft corner: pageViewerMorph topRight)
		color: color.

]

{ #category : #drawing }
ScratchScriptEditorMorph >> drawSubmorphsOn: aCanvas [
	"Display submorphs back to front."

	submorphs reverseDo: [:m |
		(m = tabPaneMorph) ifFalse: [aCanvas fullDrawMorph: m]].

]

{ #category : #geometry }
ScratchScriptEditorMorph >> extent: aPoint [

	super extent: aPoint.
	pageViewerMorph ifNotNil: [
		pageViewerMorph extent: self extent - (pageViewerMorph position - self position)].

]

{ #category : #geometry }
ScratchScriptEditorMorph >> fixLayout [

	| y x |
	"layout readout morphs vertically"
	y := nameMorph bottom + 5.
	readoutMorphs do: [:m |
		m position: m left@y].

	"layout readout and name morphs horizontally"
	nameMorph position: (thumbnailMorph topRight + (17@(thumbnailMorph height * 0.12))).
	x := nameMorph left.
	readoutMorphs do: [:m |
		m position: x@m top.
		x := m right + 5].

	"layout lock and pen morphs"
	lockButton ifNotNil: [
		lockButton position: (nameMorph right + 4)@(nameMorph top + ((nameMorph height - lockButton height) / 2)).
		penReadout position: (lockButton right + 4)@(nameMorph top + ((nameMorph height - penReadout height) / 2))].

	"place tab morph"
	(readoutMorphs size > 1) ifTrue: [
		topSectionHeight := (readoutMorphs at: 1) bottom - self top + tabPaneMorph height + 5].
	tabPaneMorph
		width: self width;
		position: (self left + 15) @ (self top + topSectionHeight - tabPaneMorph height + 1).

	"place scripts scroll pane"
	pageViewerMorph position: (self left @ (self top + topSectionHeight)).
	self extent: self extent. "force resize of page viewer morph"

]

{ #category : #drawing }
ScratchScriptEditorMorph >> fullDrawOn: aCanvas [
	"Draw my frame in front of my submorphs."

	| clipC |
	self visible ifFalse: [^ self].
	(self hasProperty: #errorOnDraw) ifTrue:[^ self drawErrorOn: aCanvas].
	(aCanvas isVisible: self fullBounds) ifFalse: [^ self].

	"myBox has integer position and extent and has a potentially inset bottom"
	myBox := bounds truncated.
	clipC := aCanvas copyClipRect: myBox.

	frameInFront
		ifTrue: [
			self drawOn: clipC.
			self drawSubmorphsOn: clipC.
			self drawFrameOn: clipC.
			aCanvas fullDrawMorph: tabPaneMorph]
		ifFalse: [
			self drawOn: clipC.
			self drawSubmorphsOn: clipC].

]

{ #category : #accessing }
ScratchScriptEditorMorph >> getTabTop [
	"Used by ScratchFrameMorph when creating the tab pane. This returns the y position of where the top of the tabs should align. This situation is unfortunate (tabs should probaby be part of ScratchScriptEditorMorph), but we'll fix it later."

	ScratchFrameMorph isXO ifTrue: [^ thumbnailMorph bottom + 20].
	(readoutMorphs size > 0)
		ifTrue: [^ (readoutMorphs at: 1) bottom + 6]
		ifFalse: [^ nameMorph bottom + 5 + (ScratchTranslator stringExtent: '0' font: (ScratchFrameMorph getFont: #XYReadoutBold)) y + 6].

]

{ #category : #'event handling' }
ScratchScriptEditorMorph >> handlesMouseOverDragging: evt [

	| m |
	evt hand submorphs size = 1 ifFalse: [^ false].
	m := evt hand firstSubmorph.

	^ m isKindOf: BlockMorph.

]

{ #category : #initialization }
ScratchScriptEditorMorph >> initialize [

	super initialize.
	self
		initFrontFromForm: (ScratchFrameMorph skinAt: #scriptPaneFrameTransparent2)
		topSectionHeight: 90.
	self color: (Color r: (149/255) g: (154/255) b: (159/255)).

	thumbnailMorph := ScratchThumbnailMorph new.
	self addMorph: (thumbnailMorph position: self position + (37@16)).

	self addNameBox.

	pageViewerMorph := ScrollFrameMorph2 new
		growthFraction: 0.1;
		color: ScratchFrameMorph scriptsPaneColor.
	self addMorph: (pageViewerMorph position: (self left @ (self top + topSectionHeight))).

	rotationButtons := #().
	readoutMorphs := #().
	self target: nil.
	thumbnailMorph extent: 50@50.
	self extent: 300@400.
	self createTabPane.

]

{ #category : #'event handling' }
ScratchScriptEditorMorph >> mouseEnterDragging: evt [
	"Switch the tabs to script if a block is current being dragged"

	(currentCategory = 'Scripts') ifFalse:[
		self currentCategory: 'Scripts'.
		tabPaneMorph currentTab: 'Scripts'].

]

{ #category : #stepping }
ScratchScriptEditorMorph >> saveScriptsToImage [
	"Take a snapshot of all scripts for a sprite and save as a GIF file"

	| fName saveForm |

	saveForm := pageViewerMorph contents screenshot.

	fName := ScratchFileChooserDialog
		chooseNewFileDefault: ''
		title: 'Save Scripts Snapshot'
		type: #scriptsSnapshot.
	fName = #cancelled ifTrue: [^ self].
	fName size = 0 ifTrue: [^ self].

	(fName asLowercase endsWith: '.gif') ifFalse: [fName := fName, '.gif'].
	saveForm writeGIFFileNamed: fName.

]

{ #category : #'menu/button ops' }
ScratchScriptEditorMorph >> scriptsMenu: aPosition [
	"Present a menu of Scratch script operations."

	| menu choice |
	self target ifNil: [^ self].
	menu := MenuMorph new defaultTarget: self.
	menu add: 'clean up' action: #cleanUp.
	menu add: 'save picture of scripts' action: #saveScriptsToImage.
	menu add: 'add comment' action: #addComment:.
	menu add: 'undo last drop' action: #undoDrop.
	menu addLine.
	menu add: 'make a block' action: #addCustomBlock.

	choice := menu localize invokeModal: true.
	choice ifNil: [^ self].
	choice = #addComment:
		ifTrue: [self perform: choice with: aPosition]
		ifFalse: [self perform: choice].

]

{ #category : #'menu/button ops' }
ScratchScriptEditorMorph >> setRotationStyle: aSymbol [

	aSymbol == #Smooth ifTrue: [self target setRotationStyle: 1].
	aSymbol == #Flip ifTrue: [self target setRotationStyle: 2].
	aSymbol == #None ifTrue: [self target setRotationStyle: 0].

"
	self updateRotationButtonHighlight.

	(self target respondsTo: #rotationDegrees:) ifFalse: [^ self].
	self animateRotationStyle.

"
]

{ #category : #private }
ScratchScriptEditorMorph >> showOrHideReadouts [
	"If this is a sprite, show the position and direction readouts and the rotation style buttons. Otherwise, hide them."

	self deleteRotationButtons; deleteLockButton; deleteReadouts.

	nameMorph
		font: nameMorph font;
		width: nameMorph height * 4;
		rightJustify: ScratchTranslator isRTL.

	(self target isKindOf: ScratchSpriteMorph) ifTrue: [
		self addRotationButtons; addLockButton; addReadouts.
		World ifNotNil: [World startSteppingSubmorphsOf: self]].

]

{ #category : #stepping }
ScratchScriptEditorMorph >> step [

	currentCategory = 'Costumes' ifTrue: [self updateCostumeSelection].

	(penReadout isNil or: [penReadout owner ~= self]) ifTrue: [^ self].
	self target penDown
		ifTrue: [penReadout color: self target penColor]
		ifFalse: [penReadout color: Color transparent].

]

{ #category : #stepping }
ScratchScriptEditorMorph >> stepTime [

	^ 50

]

{ #category : #accessing }
ScratchScriptEditorMorph >> tabPane [

	^ tabPaneMorph
]

{ #category : #accessing }
ScratchScriptEditorMorph >> target [

	^ nameMorph target

]

{ #category : #accessing }
ScratchScriptEditorMorph >> target: aScratchObjectOrNil [
	"Start viewing the given object or no object."

	| sFrame nameSel |
	World activeHand newKeyboardFocus: nil.
	(aScratchObjectOrNil isNil or:
	 [aScratchObjectOrNil isScriptable not]) ifTrue: [
		thumbnailMorph target: nil.
		nameMorph target: nil; contents: 'no object '.
		pageViewerMorph contents: (Morph new color: Color red).

		(sFrame := self ownerOrYourselfThatIsA: ScratchFrameMorph) ifNotNil: [
			sFrame viewerPane target: nil].

		self showOrHideReadouts.
		^ self].

	thumbnailMorph target: aScratchObjectOrNil.

	nameSel := (aScratchObjectOrNil isKindOf: ScratchStageMorph)
		ifTrue: [nil]
		ifFalse: [#objName:].
	nameMorph
		target: aScratchObjectOrNil;
		getSelector: #objName;
		putSelector: nameSel.

	self showOrHideReadouts.
	self fixLayout.

]

{ #category : #'menu/button ops' }
ScratchScriptEditorMorph >> toggleSpriteDraggable [
	"Add buttons to set the rotation style."

	self target draggable: self target draggable not.
	self updateLockButton.

]

{ #category : #'menu/button ops' }
ScratchScriptEditorMorph >> undoDrop [

	| scriptsMorph |
	scriptsMorph := (pageViewerMorph allMorphs select: [: m | m isKindOf: ScratchScriptsMorph]) first.
	scriptsMorph undoLastDrop

]

{ #category : #private }
ScratchScriptEditorMorph >> updateCostumeSelection [
	"Update the currently selected costume if the costumes tab is selected."

	| currentCostume |
	currentCategory = 'Costumes' ifFalse: [^ self].
	currentCostume := self target costume.

	pageViewerMorph contents submorphsDo: [:m |
		((m isKindOf: MediaItemMorph) and:
		 [m media isImage]) ifTrue: [
			m highlight: (m media = currentCostume)]].

]

{ #category : #private }
ScratchScriptEditorMorph >> updateLockButton [

	lockButton ifNil: [^ self].
	self target draggable
		ifTrue: [lockButton off]
		ifFalse: [lockButton on].

]

{ #category : #private }
ScratchScriptEditorMorph >> updateRotationButtonHighlight [
	"Highlight the appropriate rotation style button. Do nothing if my target is not a sprite."

	| style sym |
	(self target isKindOf: ScratchSpriteMorph) ifFalse: [^ self].

	style := self target rotationStyle.
	style = #normal ifTrue: [sym := #Smooth].
	style = #leftRight ifTrue: [sym := #Flip].
	style = #none ifTrue: [sym := #None].

	rotationButtons do: [:m |
		sym = m arguments first ifTrue: [m on] ifFalse: [m off]].

]
