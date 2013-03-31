"
I represent a scriptable morph in the library pane. I display a thumbnail of the morph, its name, and some information about it.

"
Class {
	#name : #LibraryItemMorph,
	#superclass : #Morph,
	#instVars : [
		'target',
		'thumbnailMorph',
		'nameMorph',
		'scriptCountMorph',
		'isSelected',
		'rolloverOn',
		'lastUpdateMSecs',
		'highlightForm',
		'currentForm',
		'thumbWidth',
		'rolloverForm',
		'rotationToggleMorph'
	],
	#classVars : [
		'InfoFont',
		'NameFont'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'dropping/grabbing' }
LibraryItemMorph >> acceptDroppingMorph: aMorph event: evt [
	"Copy the dropped scripts of another object into its target."

	(aMorph isKindOf: MediaItemMorph) ifTrue: [
		target addMediaItem: aMorph media copy.
		evt hand rejectDropMorph: aMorph event: evt].

	(aMorph isKindOf: BlockMorph) ifTrue: [
		evt hand rejectDropMorph: aMorph event: evt.
		target addStack: aMorph fullCopy].

	(aMorph isKindOf: ScratchCommentMorph) ifTrue: [
		evt hand rejectDropMorph: aMorph event: evt.
		target addComment: aMorph fullCopy].

]

{ #category : #drawing }
LibraryItemMorph >> areasRemainingToFill: aRectangle [
	"Drawing optimization. Since I clip drawing of my submorphs, this method tells Morphic that it isn't necessary to draw any morphs covered by me. This is a little lie because I have rounded corners."
	
	^ aRectangle areasOutside: self bounds

]

{ #category : #initialization }
LibraryItemMorph >> buildRotationToggleMorph [

	| x y onForm offForm |
	onForm := ((ScratchFrameMorph skinAt: #rotStyleSmooth) magnifyBy: 0.9).
	offForm := ((ScratchFrameMorph skinAt: #rotStyleNone) magnifyBy: 0.9).
	rotationToggleMorph := ToggleButton
							onForm: onForm
							offForm: offForm.
	x := onForm width.
	y := onForm height.
	rotationToggleMorph
		position: (self right - x) @ (self top + y);
		target: self;
		actionSelector: #toggleRotationRule.
	self addMorph: rotationToggleMorph.

]

{ #category : #initialization }
LibraryItemMorph >> buildSubmorphs [
	"LibraryItemMorph open"

	thumbnailMorph := ImageMorph new
		form: (ColorForm extent: thumbWidth@thumbWidth depth: 16) fillWhite;
		position: ((self width - thumbWidth) // 2) @ 0.
	self addMorph: thumbnailMorph.

	nameMorph := StringMorph new
		font: (ScratchFrameMorph getFont: #LibraryItemName);
		position: 0 @ (thumbnailMorph bottom -2).
	self addMorph: nameMorph.

	"scriptCountMorph := StringMorph new
		font: (ScratchFrameMorph getFont: #LibraryItemInfo);
		contents: '';
		position: 0 @ nameMorph bottom.
	self addMorph: scriptCountMorph."

	self color: Color transparent.

	self buildRotationToggleMorph

]

{ #category : #BYOB }
LibraryItemMorph >> childrenMenu [
	"Present the children menu on a sprite icon"

	| menu library frame |
	library := self ownerOrYourselfThatIsA: ScratchLibraryMorph.
	library ifNil: [^ self].
	frame := self ownerOrYourselfThatIsA: ScratchFrameMorph.
	frame ifNil: [^ self].

	menu := MenuMorphNG new defaultTarget: self.
	library spriteThumbnails do: [:tn |
		(tn target prototype == self target) ifTrue: [
			menu addIcon: tn imageForm 
			tooltip: tn target objName 
			value: tn target objName]].

	menu localize; popUpInWorld.

]

{ #category : #accessing }
LibraryItemMorph >> color [

	currentForm
		ifNil: [^ color]
		ifNotNil: [^ currentForm color].

]

{ #category : #drawing }
LibraryItemMorph >> drawOn: aCanvas [
	"Draw my selected or rollover state if necessary."

	currentForm ifNotNil: [currentForm drawOn: aCanvas].

]

{ #category : #drawing }
LibraryItemMorph >> drawSubmorphsOn: aCanvas [
	"Clip submorph drawing to my bounds."

	| r |
	r := self bounds.
	rolloverOn | isSelected ifTrue: [r := r insetBy: 3].
	super drawSubmorphsOn: (aCanvas copyClipRect: r).


]

{ #category : #initialization }
LibraryItemMorph >> extent: aRectangle thumbWidth: w [

	lastUpdateMSecs := -1.
	self extent: aRectangle.
	thumbWidth := w.

	self buildSubmorphs.
	self target: nil.
	isSelected := nil.
	rolloverOn := false.
	highlightForm := ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: #librarySelected).
	highlightForm extent: self extent.
	rolloverForm := ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: #libraryRollover).
	rolloverForm extent: self extent.
	currentForm := nil.
	self highlight: false.

]

{ #category : #'event handling' }
LibraryItemMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #'event handling' }
LibraryItemMorph >> handlesMouseOverDragging: evt [

	| m |
	evt hand submorphs size = 1 ifFalse: [^ false].
	m := evt hand firstSubmorph.
	^ ((m isKindOf: BlockMorph) or: [(m isKindOf: MediaItemMorph) or: [m isKindOf: ScratchCommentMorph]])

]

{ #category : #accessing }
LibraryItemMorph >> highlight: aBoolean [

	| labelColor |
	isSelected = aBoolean ifTrue: [^ self].

	isSelected := aBoolean.
	isSelected
		ifTrue: [
			rolloverOn := false.
			highlightForm extent: self extent.
			currentForm := highlightForm.
			self addMorphBack: (currentForm position: (self position + (0@0))).
			labelColor := Color white]
		ifFalse: [
			currentForm ifNotNil: [
				currentForm delete.
				currentForm := nil].
			labelColor := Color gray: 0.8].

	nameMorph color: labelColor.
	"scriptCountMorph color: labelColor darker."
	self changed.

]

{ #category : #'dropping/grabbing' }
LibraryItemMorph >> justDroppedInto: aMorph event: evt [
	"When I am dropped into the viewer pane or the script editor, then delete the sprite associated with me."
	
	| targets |

	((self target isKindOf: ScratchSpriteMorph) and: [
	(aMorph isKindOf: ScratchStageMorph)]) ifTrue: [
		targets := aMorph sprites select: [:each| 
			each containsPoint: aMorph adjustedCursorPoint ].
		targets size > 0
			ifTrue: [self target stickTo: targets first]
			ifFalse: [self target unhinge]].

	self delete.
true ifTrue: [^ self].

	"delete me when dropped on the blocks palette or the script editor"
	(((aMorph ownerOrYourselfThatIsA: ScratchViewerMorph) notNil) 
		or: [(aMorph ownerOrYourselfThatIsA: ScratchScriptEditorMorph) notNil]) ifTrue: [
		^ self target undoableDeleteSprite].

	"blocks cannot be dropped onto the stage"
	(owner isKindOf: ScratchStageMorph) ifTrue: [
		^ evt hand rejectDropMorph: self event: evt].

]

{ #category : #'event handling' }
LibraryItemMorph >> mouseDown: evt [
	"Handle a mouse click. Left click either sets me as a target, deletes me, or copies me.  Shift left click makes me reappear in the middle of the screen.  Holding left button drags me. Right button brings up a menu."

	| duplicate frame |

	(evt hand toolType = 'CutTool') & (evt rightButtonPressed not) ifTrue: [
		evt shiftPressed ifFalse: [evt hand toolType: nil].
		(target notNil and:
		 [(target isKindOf: ScratchStageMorph) not]) ifTrue: [
			self target undoableDeleteSprite].
		^ self].
	
	(evt hand toolType = 'CopyTool') & (evt rightButtonPressed not) ifTrue: [
		evt shiftPressed ifFalse: [evt hand toolType: nil].
		(target notNil and:
		 [(target isKindOf: ScratchStageMorph) not]) ifTrue: [
			duplicate := self target duplicate.
			self world activeHand
				attachMorph: duplicate;
				formerOwner: self target owner position: self target owner center].
		^ self].

	target ifNotNil: [
		evt shiftPressed ifTrue: [self select. ^ self target makeVisible].
		evt rightButtonPressed
			ifTrue: [
				Sensor waitNoButton. 
				(target isKindOf: ScratchStageMorph) 
					ifTrue: [^ self stageMenu]
					ifFalse: [^ self rightButtonMenu]]
			ifFalse:	[
				target closeBlockEditor.
				self select.
				frame := self ownerOrYourselfThatIsA: ScratchFrameMorph.
				"Set the viewerPane target to my target so I stay highlighted while I am being dragged. This is sort of a hack because my target is not actually being viewed until the mouseUp: command is called."
				frame viewerPane target: self target.
				evt hand waitForClicksOrDrag: self event: evt]].

]

{ #category : #'event handling' }
LibraryItemMorph >> mouseEnterDragging: evt [

	"| m s |

	m := BorderedMorph new
		color: Color gray lighter lighter;
		borderWidth: 1;
		borderColor: Color gray;
		useRoundedCorners.
	s := StringMorph
		contents: ('Copy to ', target objName)
		font: (ScratchFrameMorph getFont: #Button).
	s color: Color white.
	m
		addMorph: (s position: (5@2));
		width: s width + 10;
		height: s height + 5.
	(evt hand submorphs at: 1) addCopyTooltip: (m)."

	isSelected ifTrue: [^ self].

	rolloverOn := true.
	currentForm := rolloverForm.
	self addMorphBack: (currentForm position: (self position + (0@0))).
	self changed.

]

{ #category : #'event handling' }
LibraryItemMorph >> mouseHold: evt [

	(target isKindOf: ScratchStageMorph) ifFalse: [self rightButtonMenu].

]

{ #category : #'event handling' }
LibraryItemMorph >> mouseLeaveDragging: evt [

	"(evt hand submorphs at: 1) removeCopyTooltip."

	isSelected ifTrue: [^ self].

	rolloverOn := false.
	currentForm ifNotNil: [
		currentForm delete.
		currentForm := nil].
	self changed.

]

{ #category : #'event handling' }
LibraryItemMorph >> mouseUp: evt [
	"View my target if it is not already beeing viewed."

	| frame |
	frame := self ownerOrYourselfThatIsA: ScratchFrameMorph.
	frame ifNil: [^ self].
	self target ifNil: [^ self]. "deleted"

	self select.
	frame scriptsPane target = self target ifFalse: [
		self target viewBlocksAndScripts].

]

{ #category : #'dropping/grabbing' }
LibraryItemMorph >> rejectDropEvent: evt [
	"Reject being dropped by the given event."

	evt hand rejectDropMorph: self event: evt.

]

{ #category : #'right button menu' }
LibraryItemMorph >> rightButtonMenu [
	"Present the right button menu."

	| menu stage |
	menu := MenuMorphNG new defaultTarget: self target.
	menu add: 'show' action: #makeVisible.
	menu add: 'export this sprite' action: #exportObject.

	stage := self target ownerOrYourselfThatIsA: ScratchStageMorph.
	stage ifNotNil: [
		(stage scratchServer notNil and: 
		[stage scratchServer sessionInProgress])
			ifTrue: [
				menu add: 'share this sprite' action: #shareObject ]].

	menu addLine.
	menu add: 'duplicate' action: #duplicateNoAttach.
	menu add: 'delete' action: #undoableDeleteSprite.
	(self target isKindOf: ScratchSpriteMorph) ifTrue: [
		menu addLine.
		menu add: 'clone' action: #spawn.
		menu add: 'parent...' action: #choosePrototype.
		self target instances size > 0 ifTrue: [
			self haltOnce.
			menu add: 'children...' action: [self childrenMenu]].
		self target isNested ifTrue: [
			menu addLine ].
		self target hasSubsprites ifTrue: [
			menu add: 'detach all subsprites' action: #unhingeAll ].
		self target ownerSprite ifNotNil: [
			menu add: 'detach from ', self target ownerSprite objName action: #unhinge  ]].
	menu localize; invokeModal.

]

{ #category : #'event handling' }
LibraryItemMorph >> select [

	(self ownerOrYourselfThatIsA: ScratchLibraryMorph) unhighlightAll. "unhighlight others"
	self highlight: true.
	World displayWorldSafely. "force immediate feedback"

]

{ #category : #BYOB }
LibraryItemMorph >> stageMenu [
	"Present the right button menu on the stage icon"

	| menu library frame |
	library := self ownerOrYourselfThatIsA: ScratchLibraryMorph.
	library ifNil: [^ self].
	frame := self ownerOrYourselfThatIsA: ScratchFrameMorph.
	frame ifNil: [^ self].

	menu := MenuMorphNG  new defaultTarget: self.
	"menu beHorizontal."
	library spriteThumbnails do: [:tn |
		tn target prototype ifNil: [
			menu addIcon: tn imageForm 
			tooltip: tn target objName 
			value: tn target objName ]].
	(menu localize; invokeModal).
	^menu selectedValue.

]

{ #category : #'event handling' }
LibraryItemMorph >> startDrag: evt [

	(self target isKindOf: ScratchStageMorph) ifTrue: [^ self]. "cannot drag stage thumbnail"

	(self ownerOrYourselfThatIsA: ScratchLibraryMorph)
		ifNil: [evt hand grabMorph: self]
		ifNotNil: [evt hand attachMorph: self fullCopy].

]

{ #category : #stepping }
LibraryItemMorph >> step [
	"Optimization: Don't update unless the costume has changed."

	| changeTime stage frame |
	target ifNil: [
		(frame := (self ownerOrYourselfThatIsA: ScratchFrameMorph)) ifNotNil: [
			(stage := frame workPane) ifNotNil: [
				stage updateSpritesList]].
		^ self].
	target world isNil ifTrue: [target := nil. ^ self].
	changeTime := target costumeChangeMSecs.
	changeTime = lastUpdateMSecs ifFalse: [
		self updateThumbnail.
		lastUpdateMSecs := changeTime].
"	Sensor anyButtonPressed ifFalse: [self updateNameAndInfo]."
	self updateNameAndInfo

]

{ #category : #accessing }
LibraryItemMorph >> target [

	^ target

]

{ #category : #accessing }
LibraryItemMorph >> target: aMorph [

	target := aMorph.
	self updateThumbnail.

]

{ #category : #private }
LibraryItemMorph >> toggleRotationRule [

	(self target isKindOf: ScratchStageMorph)
		ifTrue: [^ self].
	self target toggleRotationRule.
	self updateRotationToggleMorph
]

{ #category : #private }
LibraryItemMorph >> truncatedLabel [
	"Answer the label string to used as the name morph."

	| ellipses s w n |

	nameMorph contents = target objName ifFalse: [
		n := target objName.
		ellipses := ScratchTranslator ellipsesSuffix asUTF32.
		1 to: n size do: [:i |
			s := n copyFrom: 1 to: i.
			w := nameMorph stringWidth: (s asUTF32, ellipses).
			w > (self width - 3) ifTrue: [
				^ (n copyFrom: 1 to: i - 1) asUTF32, ellipses]]].

	^ target objName

]

{ #category : #initialization }
LibraryItemMorph >> updateNameAndInfo [

	| w y txt |

	txt := ((target objName asUTF8, ' (' asUTF8, 'Scripts' localized, ScratchTranslator colonSuffix, ' ' asUTF8, target scripts size printString asUTF8,')' asUTF8) asUTF8).

	target prototype ifNotNil: [
		txt := (txt, ' kind of: ' asUTF8, target prototype objName asUTF8) asUTF8].

	self
		setProperty: #balloonText
		toValue: txt.

	nameMorph ifNotNil:[
		(target isKindOf: ScriptableScratchMorph) ifFalse: [
			nameMorph contents: '<no object>'.
			scriptCountMorph contents: ''.
			^ self].

		nameMorph contents = target objName ifFalse: [
			nameMorph contents: self truncatedLabel.
			nameMorph left: self left + ((self width - nameMorph width) // 2) + 1]].

	scriptCountMorph ifNotNil: [
		w := 0.
		target scripts size > 0
			ifTrue: [
				w > 0 ifTrue: [w := w + 2].
				scriptCountMorph contents: 'Scripts' localized, ScratchTranslator colonSuffix, ' ', target scripts size printString.
				w := w + scriptCountMorph width + 2]
			ifFalse: [
				scriptCountMorph contents: ''].

		"layout info morph row"
		y := nameMorph bottom.
		w > 0 ifTrue: [
			scriptCountMorph position: (self left + ((self width - (scriptCountMorph width)) // 2))@y]].

]

{ #category : #initialization }
LibraryItemMorph >> updateRotationToggleMorph [

	rotationToggleMorph ifNil: [
		self buildRotationToggleMorph ].
	(self target isNil
		or: [(self target isKindOf: ScratchStageMorph)
		or: [self target ownerSprite isNil]])
		ifTrue: [
			rotationToggleMorph isHidden: true.
			^self ]
		ifFalse: [rotationToggleMorph isHidden: false].
	rotationToggleMorph
		position: (self right - rotationToggleMorph width - 2) @ (self top + 2).
	self target rotateWithOwner
		ifTrue: [rotationToggleMorph on]
		ifFalse: [rotationToggleMorph off]

]

{ #category : #stepping }
LibraryItemMorph >> updateThumbnail [

	| f e r form smallSize anchor subs |

	self updateRotationToggleMorph.

	form := thumbnailMorph form.
	form fillColor: Color transparent.
	target ifNil: [
		thumbnailMorph changed.
		^ self].

	self updateRotationToggleMorph.

	smallSize := (form height // 3) @ (form height // 3).

	((target isKindOf: ScratchSpriteMorph) and: [target hasSubsprites]) ifTrue: [
		1 to: (target subsprites size min: 3) do: [:idx|
			subs := ((target subsprites at: idx) imageForm asFormOfDepth: 16) toThumbnail: smallSize borderWidth: 0 borderColor: Color transparent.
			subs displayOn: form at: (form width - (subs width*idx)) @ (form height - subs height) ]].


	anchor := ((target isKindOf: ScratchSpriteMorph) and: [target ownerSprite notNil]).

	f := target imageForm asFormOfDepth: 16.
	((f width <= form width) & (f height <= form height)) ifTrue: [
		"target's image fits without shrinking"
		f displayOn: form at: ((form extent - f extent) // 2).
		thumbnailMorph changed.
		^ self].


	f width > f height 
		ifTrue: [e := form width @ ((f height * form width) // f width)]
		ifFalse: [e := ((f width * form height) // f height) @ form height].
	e := e max: (8@8).
	r := Rectangle center: (form extent // 2) extent: e.

	(WarpBlt toForm: form)
		sourceForm: f;
		cellSize: 2;  "do smoothing; this also installs a colormap"
		combinationRule: Form paint;
		copyQuad: f boundingBox innerCorners toRect: (r insetBy: 2).

	anchor ifTrue: [
		(WarpBlt toForm: form)
			sourceForm: (target ownerSprite imageForm asFormOfDepth: 16);
			cellSize: 2;  "do smoothing; this also installs a colormap"
			combinationRule: Form paint;
			copyQuad: f boundingBox innerCorners toRect: (0@0 extent: smallSize).

		"anchor displayOn: form at: 0@0"].

	thumbnailMorph changed.

]

{ #category : #'dropping/grabbing' }
LibraryItemMorph >> wantsDroppedMorph: aMorph event: evt [
	"Answer true if the given morph is a script, costume, sound or comment."

	^ (aMorph isKindOf: BlockMorph) or: [
		(aMorph isKindOf: MediaItemMorph) or: [
			aMorph isKindOf: ScratchCommentMorph]]

]
