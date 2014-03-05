"
I am a viewer for the scripts and media closet of a Scratch object. I have a heading row containing the object name (editable) and a drop-down menu icon. Below that is a scrollable content area.

"
Class {
	#name : #PhratchScriptEditorMorph,
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
		'tabPaneMorph'
	],
	#category : #'Phratch-UI-Panes'
}

{ #category : #'menu/button ops' }
PhratchScriptEditorMorph >> addComment: anEvent [

	| c scriptsMorph |
	scriptsMorph := (pageViewerMorph allMorphs select: [: m | m isKindOf: PhratchScriptsMorph]) first.
	scriptsMorph addMorph: (c := PhratchCommentMorph new position: anEvent position).
	World activeHand newKeyboardFocus: c commentMorph.

]

{ #category : #byob }
PhratchScriptEditorMorph >> addCustomBlock [

	self target addCustomBlock
]

{ #category : #private }
PhratchScriptEditorMorph >> addLockButton [
	"Add button to set sprite locked status."

	self deleteLockButton.

	lockButton := ToggleButton
		onForm: (PhratchFrameMorph skinAt: #locked)
		offForm: (PhratchFrameMorph skinAt: #unlocked).

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
PhratchScriptEditorMorph >> addNameBox [

	nameMorph := UpdatingStringFieldMorph new
		font: (PhratchFrameMorph getFont: #UpdatingStringField);
		rightJustify: false;
		acceptWhenFocusLost: true;
		position: thumbnailMorph topRight + (17@(thumbnailMorph height * 0.12));
		yourself.

	self addMorphBack: nameMorph.

]

{ #category : #private }
PhratchScriptEditorMorph >> addReadouts [
	"Add readouts for my target's position and direction."

	| x y label readout s |
	self deleteReadouts.
	readoutMorphs := OrderedCollection new.
	x := nameMorph left.
	y := nameMorph bottom + 5.
	#(#('x' #xpos) #('y' #ypos) #('direction' #heading))
		do: [ :spec | 
			s :=  spec first localized , ':'.
			label := StringMorph new
				contents: s;
				font: (PhratchFrameMorph getFont: #XYReadout);
				position: x @ y;
		yourself.
			readout := (UpdatingStringMorph on: self target selector: spec second)
				font: (PhratchFrameMorph getFont: #XYReadoutBold);
				forceUnicodeRendering: true;
				color: (Color gray: 0.2);
				contents: '-000';
				growable: false;
				stepTime: 100;
				position: (label right + 4) @ y;
		yourself.	"this sets the readout size"
			self
				addMorph: label;
				addMorph: readout.
			readoutMorphs
				add: label;
				add: readout.
			readout startStepping.
			x := readout right + 2 ].
	penReadout := Morph new extent: 15 @ 5.
	penReadout
		position: (lockButton right + 4) @ (nameMorph top + ((nameMorph height - penReadout height) / 2));
		color: Color transparent.
	self addMorph: penReadout.
	readoutMorphs add: penReadout.
	penReadout startStepping.
	readoutMorphs := readoutMorphs asArray
]

{ #category : #private }
PhratchScriptEditorMorph >> addRotationButtons [
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
			onForm: (PhratchFrameMorph skinAt: ('rotStyle', style, 'On'))
			offForm: (PhratchFrameMorph skinAt: ('rotStyle', style))
			overForm: (PhratchFrameMorph skinAt: ('rotStyle', style, 'Over')).
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
PhratchScriptEditorMorph >> animateRotationStyle [
	| style thumbForm wasFlipped currentRotation pen center rotatedForm doFlip |
	style := self target rotationStyle.
	thumbnailMorph updateThumbnail.
	thumbForm := thumbnailMorph form deepCopy.
	currentRotation := self target rotationDegrees rounded.
	wasFlipped := currentRotation \\ 360 between: 90 and: 270.
	thumbnailMorph showDirection: false.
	pen := (PhratchPen newOnForm: thumbnailMorph form) color: Color white.
	center := thumbnailMorph form center.
	currentRotation to: currentRotation + 360 by: 12 do: [ :i | 
		rotatedForm := thumbForm.	"no rotation by default"
		style = #normal
			ifTrue: [ rotatedForm := thumbForm rotateBy: i ].
		style = #leftRight
			ifTrue: [ 
				doFlip := i \\ 360 between: 90 and: 270.
				wasFlipped
					ifTrue: [ doFlip := doFlip not ].
				doFlip
					ifTrue: [ rotatedForm := thumbForm flipBy: #horizontal centerAt: 0 @ 0 ] ].
		thumbnailMorph form fill: thumbnailMorph form boundingBox fillColor: Color transparent.
		rotatedForm displayOn: thumbnailMorph form at: (thumbnailMorph extent - rotatedForm extent) // 2 rule: Form paint.
		pen place: center.
		pen goto: center + (Point r: 22 degrees: i).
		thumbnailMorph changed.
		World displayWorldSafely.
		(Delay forMilliseconds: 20) wait ].
	thumbnailMorph showDirection: true.
	thumbnailMorph updateThumbnail
]

{ #category : #accessing }
PhratchScriptEditorMorph >> bareMinimumWidth [
	"Answer the bare minimum width for this pane to be useable."

	lockButton ifNil: [^ 100].
	^ lockButton right - self left
]

{ #category : #accessing }
PhratchScriptEditorMorph >> categoryChanged: aString [
	"If the given category is my current category, update my contents. Otherwise, do nothing."

	self target ifNil: [^ self].
	currentCategory = aString ifTrue: [self currentCategory: aString].

]

{ #category : #drawing }
PhratchScriptEditorMorph >> cleanUp [
	"Align all scripts vertically in alphabetical order"

	| scriptsMorph |
	scriptsMorph := (pageViewerMorph allMorphs select: [:c | c isKindOf: PhratchScriptsMorph]) first.
	scriptsMorph cleanUp.
	pageViewerMorph
		updateContentsExtent;
		updateScrollbars.


]

{ #category : #initialization }
PhratchScriptEditorMorph >> createTabPane [

	| tabOnForm tabOffForm tabID tabLabel |

	"create tab pane"
	tabPaneMorph := PhratchTabPaneMorph new.
	tabPaneMorph
		borderWidth: 0;
		color: Color transparent;
		targetPane: self.

	tabOnForm := (PhratchFrameMorph skinAt: #tabOn).
	tabOffForm := (PhratchFrameMorph skinAt: #tabOff).

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
PhratchScriptEditorMorph >> currentCategory [

	^ currentCategory


]

{ #category : #accessing }
PhratchScriptEditorMorph >> currentCategory: aString [

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

	pageViewerMorph contents color: PhratchFrameMorph scriptsPaneColor.

	self world ifNotNil: [self world startSteppingSubmorphsOf: pageViewerMorph contents].


]

{ #category : #private }
PhratchScriptEditorMorph >> deleteLockButton [
	"Delete my lock button."

	lockButton ifNotNil: [
		lockButton delete.
		lockButton := nil].

]

{ #category : #private }
PhratchScriptEditorMorph >> deleteReadouts [
	"Delete the position/rotation readouts."

	readoutMorphs do: [:m | m delete].
	readoutMorphs := #().

]

{ #category : #private }
PhratchScriptEditorMorph >> deleteRotationButtons [
	"Delete the rotation style buttons."

	rotationButtons do: [:m | m delete].
	rotationButtons := #().

]

{ #category : #'menu/button ops' }
PhratchScriptEditorMorph >> deleteSprite [
	"Ask the user if they want to delete the currently selected sprite"

	| response |
	response := DialogBoxMorph askWithCancel: 'Delete this sprite?' localized.
	response = #cancelled ifTrue: [^ self].
	response ifTrue: [thumbnailMorph target undoableDeleteSprite].

]

{ #category : #drawing }
PhratchScriptEditorMorph >> drawBackgroundOn: aCanvas [
	"Draw my background."

	color isTransparent ifTrue: [^ self].

	aCanvas
		fillRectangle: (self topLeft corner: pageViewerMorph topRight)
		color: color.

]

{ #category : #drawing }
PhratchScriptEditorMorph >> drawSubmorphsOn: aCanvas [
	"Display submorphs back to front."

	submorphs reverseDo: [:m |
		(m = tabPaneMorph) ifFalse: [aCanvas fullDrawMorph: m]].

]

{ #category : #geometry }
PhratchScriptEditorMorph >> extent: aPoint [

	super extent: aPoint.
	pageViewerMorph ifNotNil: [
		pageViewerMorph extent: self extent - (pageViewerMorph position - self position)].

]

{ #category : #geometry }
PhratchScriptEditorMorph >> fixLayout [

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
PhratchScriptEditorMorph >> fullDrawOn: aCanvas [
	"Draw my frame in front of my submorphs."

	| clipC |
	self visible
		ifFalse: [ ^ self ].
	(self hasProperty: #errorOnDraw)
		ifTrue: [ ^ self drawErrorOn: aCanvas ].
	(aCanvas isVisible: self fullBounds)
		ifFalse: [ ^ self ].	"myBox has integer position and extent and has a potentially inset bottom"
	myBox := bounds truncated.
	clipC := aCanvas copyClipRect: myBox.
	self drawOn: clipC.
	self drawSubmorphsOn: clipC.
	frameInFront
		ifFalse: [ ^ self ].
	self drawFrameOn: clipC.
	aCanvas fullDrawMorph: tabPaneMorph
]

{ #category : #'event handling' }
PhratchScriptEditorMorph >> handlesMouseOverDragging: evt [

	| m |
	evt hand submorphs size = 1 ifFalse: [^ false].
	m := evt hand firstSubmorph.

	^ m isKindOf: BlockMorph.

]

{ #category : #initialization }
PhratchScriptEditorMorph >> initialize [

	super initialize.
	self
		initFrontFromForm: (PhratchFrameMorph skinAt: #scriptPaneFrameTransparent2)
		topSectionHeight: 90.
	self color: (Color r: (149/255) g: (154/255) b: (159/255)).

	thumbnailMorph := PhratchThumbnailMorph new.
	self addMorph: (thumbnailMorph position: self position + (37@16)).

	self addNameBox.

	pageViewerMorph := ScrollFrameMorph new
		growthFraction: 0.1;
		color: PhratchFrameMorph scriptsPaneColor;
		yourself.
	self addMorph: (pageViewerMorph position: (self left @ (self top + topSectionHeight))).

	rotationButtons := #().
	readoutMorphs := #().
	self target: nil.
	thumbnailMorph extent: 50@50.
	self extent: 300@400.
	self createTabPane.

]

{ #category : #'event handling' }
PhratchScriptEditorMorph >> mouseEnterDragging: evt [
	"Switch the tabs to script if a block is current being dragged"

	currentCategory = 'Scripts'
		ifTrue: [ ^ self ].
	self currentCategory: 'Scripts'.
	tabPaneMorph currentTab: 'Scripts'
]

{ #category : #stepping }
PhratchScriptEditorMorph >> saveScriptsToImage [
	"Take a snapshot of all scripts for a sprite and save as a GIF file"

	| fName saveForm |

	saveForm := pageViewerMorph contents screenshot.

	fName := PhratchFileChooserDialog
		chooseNewFileDefault: ''
		title: 'Save Scripts Snapshot'
		type: #scriptsSnapshot.
	fName = #cancelled ifTrue: [^ self].
	fName size = 0 ifTrue: [^ self].

	(fName asLowercase endsWith: '.gif') ifFalse: [fName := fName, '.gif'].
	saveForm writeGIFFileNamed: fName.

]

{ #category : #'menu/button ops' }
PhratchScriptEditorMorph >> scriptsMenu: aPosition [
	"Present a menu of Phratch script operations."

	| menu choice |
	self target ifNil: [ ^ self ].
	menu := MenuMorph new defaultTarget: self.
	menu add: 'clean up' translated action: #cleanUp.
	menu add: 'save picture of scripts' translated action: #saveScriptsToImage.
	menu add: 'add comment' translated action: #addComment:.
	menu add: 'undo last drop' translated action: #undoDrop.
	menu addLine.
	menu add: 'make a block' translated action: #addCustomBlock.
	choice := menu localize invokeModal: true.
	choice ifNil: [ ^ self ].
	choice = #addComment:
		ifTrue: [ self perform: choice with: aPosition ]
		ifFalse: [ self perform: choice ]
]

{ #category : #'menu/button ops' }
PhratchScriptEditorMorph >> setRotationStyle: aSymbol [

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
PhratchScriptEditorMorph >> showOrHideReadouts [
	"If this is a sprite, show the position and direction readouts and the rotation style buttons. Otherwise, hide them."

	self
		deleteRotationButtons;
		deleteLockButton;
		deleteReadouts.
	nameMorph
		font: nameMorph font;
		width: nameMorph height * 4;
		rightJustify: false.
	(self target isKindOf: PhratchSpriteMorph)
		ifFalse: [ ^ self ].
	self
		addRotationButtons;
		addLockButton;
		addReadouts.
	World ifNotNil: [ World startSteppingSubmorphsOf: self ]
]

{ #category : #stepping }
PhratchScriptEditorMorph >> step [

	currentCategory = 'Costumes' ifTrue: [self updateCostumeSelection].

	(penReadout isNil or: [penReadout owner ~= self]) ifTrue: [^ self].
	((self target isKindOf: PhratchSpriteMorph)  and: [self target penDown])
		ifTrue: [penReadout color: self target penColor]
		ifFalse: [penReadout color: Color transparent].

]

{ #category : #stepping }
PhratchScriptEditorMorph >> stepTime [

	^ 50

]

{ #category : #accessing }
PhratchScriptEditorMorph >> tabPane [

	^ tabPaneMorph
]

{ #category : #accessing }
PhratchScriptEditorMorph >> target [

	^ nameMorph target

]

{ #category : #accessing }
PhratchScriptEditorMorph >> target: aPhratchObjectOrNil [
	"Start viewing the given object or no object."

	| sFrame nameSel |
	World activeHand newKeyboardFocus: nil.
	(aPhratchObjectOrNil isNil or:
	 [aPhratchObjectOrNil isScriptable not]) ifTrue: [
		thumbnailMorph target: nil.
		nameMorph target: nil; contents: 'no object '.
		pageViewerMorph contents: (Morph new color: Color red).

		(sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNotNil: [
			sFrame viewerPane target: nil].

		self showOrHideReadouts.
		^ self].

	thumbnailMorph target: aPhratchObjectOrNil.

	nameSel := (aPhratchObjectOrNil isKindOf: PhratchStageMorph)
		ifTrue: [nil]
		ifFalse: [#objName:].
	nameMorph
		target: aPhratchObjectOrNil;
		getSelector: #objName;
		putSelector: nameSel.

	self showOrHideReadouts.
	self fixLayout.

]

{ #category : #'menu/button ops' }
PhratchScriptEditorMorph >> toggleSpriteDraggable [
	"Add buttons to set the rotation style."

	self target draggable: self target draggable not.
	self updateLockButton.

]

{ #category : #'menu/button ops' }
PhratchScriptEditorMorph >> undoDrop [

	| scriptsMorph |
	scriptsMorph := (pageViewerMorph allMorphs select: [: m | m isKindOf: PhratchScriptsMorph]) first.
	scriptsMorph undoLastDrop

]

{ #category : #private }
PhratchScriptEditorMorph >> updateCostumeSelection [
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
PhratchScriptEditorMorph >> updateLockButton [

	lockButton ifNil: [^ self].
	self target draggable
		ifTrue: [lockButton off]
		ifFalse: [lockButton on].

]

{ #category : #private }
PhratchScriptEditorMorph >> updateRotationButtonHighlight [
	"Highlight the appropriate rotation style button. Do nothing if my target is not a sprite."

	| style sym |
	(self target isKindOf: PhratchSpriteMorph) ifFalse: [^ self].

	style := self target rotationStyle.
	style = #normal ifTrue: [sym := #Smooth].
	style = #leftRight ifTrue: [sym := #Flip].
	style = #none ifTrue: [sym := #None].

	rotationButtons do: [:m |
		sym = m arguments first ifTrue: [m on] ifFalse: [m off]].

]
