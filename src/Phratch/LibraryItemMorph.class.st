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
		'isSelected',
		'rolloverOn',
		'lastUpdateMSecs',
		'highlightForm',
		'currentForm',
		'thumbWidth',
		'rolloverForm',
		'rotationToggleMorph'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'dropping/grabbing' }
LibraryItemMorph >> acceptDroppingMorph: aMorph event: evt [
	"Copy the dropped scripts of another object into its target."

	(aMorph isMediaItemMorph)
		ifTrue: [ 
			target addMediaItem: aMorph media copy.
			evt hand rejectDropMorph: aMorph event: evt ].
	(aMorph isBlockMorph)
		ifTrue: [ 
			evt hand rejectDropMorph: aMorph event: evt.
			target addStack: aMorph fullCopy ].
	(aMorph isPhratchCommentMorph)
		ifFalse: [ ^ self ].
	evt hand rejectDropMorph: aMorph event: evt.
	target addComment: aMorph fullCopy
]

{ #category : #drawing }
LibraryItemMorph >> areasRemainingToFill: aRectangle [
	"Drawing optimization. Since I clip drawing of my submorphs, this method tells Morphic that it isn't necessary to draw any morphs covered by me. This is a little lie because I have rounded corners."
	
	^ aRectangle areasOutside: self bounds

]

{ #category : #initialization }
LibraryItemMorph >> buildRotationToggleMorph [

	| x y onForm offForm |
	onForm := ((PhratchFrameMorph skinAt: #rotStyleSmooth) magnifyBy: 0.9).
	offForm := ((PhratchFrameMorph skinAt: #rotStyleNone) magnifyBy: 0.9).
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
		position: ((self width - thumbWidth) // 2) @ 0;
		yourself.
	self addMorph: thumbnailMorph.

	nameMorph := StringMorph new
		font: (PhratchFrameMorph getFont: #LibraryItemName);
		position: 0 @ (thumbnailMorph bottom -2);
		yourself.
	self addMorph: nameMorph.

	self color: Color transparent.

	self buildRotationToggleMorph

]

{ #category : #BYOB }
LibraryItemMorph >> childrenMenu [
	"Present the children menu on a sprite icon"

	| menu library frame |
	library := self ownerOrYourselfThatIsAPhratchLibraryMorph.
	library ifNil: [^ self].
	frame := self ownerOrYourselfThatIsAPhratchFrameMorph.
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
	highlightForm := ImageFrameMorph new initFromForm: (PhratchFrameMorph skinAt: #librarySelected).
	highlightForm extent: self extent.
	rolloverForm := ImageFrameMorph new initFromForm: (PhratchFrameMorph skinAt: #libraryRollover).
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
	^ ((m isBlockMorph) or: [(m isMediaItemMorph) or: [m isPhratchCommentMorph]])

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

{ #category : #testing }
LibraryItemMorph >> isLibraryItemMorph [

	^ true
]

{ #category : #'dropping/grabbing' }
LibraryItemMorph >> justDroppedInto: aMorph event: evt [
	"When I am dropped into the viewer pane or the script editor, then delete the sprite associated with me."
	
	| targets |

	((self target isPhratchSpriteMorph) and: [
	(aMorph isPhratchStageMorph)]) ifTrue: [
		targets := aMorph sprites select: [:each| 
			each containsPoint: aMorph adjustedCursorPoint ].
		targets size > 0
			ifTrue: [self target stickTo: targets first]
			ifFalse: [self target unhinge]].

	self delete.
	^ self.

	"delete me when dropped on the blocks palette or the script editor"
	"(((aMorph ownerOrYourselfThatIsAPhratchViewerMorph) notNil) 
		or: [(aMorph ownerOrYourselfThatIsAPhratchScriptEditorMorph) notNil]) ifTrue: [
		^ self target undoableDeleteSprite]."

	"blocks cannot be dropped onto the stage"
	"(owner isPhratchStageMorph) ifTrue: [
		^ evt hand rejectDropMorph: self event: evt]."

]

{ #category : #'event handling' }
LibraryItemMorph >> mouseDown: evt [
	"Handle a mouse click. Left click either sets me as a target, deletes me, or copies me.  Shift left click makes me reappear in the middle of the screen.  Holding left button drags me. Right button brings up a menu."

	| duplicate frame |

	(evt hand toolType = 'CutTool') & (evt rightButtonPressed not) ifTrue: [
		evt shiftPressed ifFalse: [evt hand toolType: nil].
		(target notNil and:
		 [(target isPhratchStageMorph) not]) ifTrue: [
			self target undoableDeleteSprite].
		^ self].
	
	(evt hand toolType = 'CopyTool') & (evt rightButtonPressed not) ifTrue: [
		evt shiftPressed ifFalse: [evt hand toolType: nil].
		(target notNil and:
		 [(target isPhratchStageMorph) not]) ifTrue: [
			duplicate := self target duplicate.
			self world activeHand
				attachMorph: duplicate].
		^ self].

	target ifNotNil: [
		evt shiftPressed ifTrue: [self select. ^ self target makeVisible].
		evt rightButtonPressed
			ifTrue: [
				Sensor waitNoButton. 
				(target isPhratchStageMorph) 
					ifTrue: [^ self stageMenu]
					ifFalse: [^ self rightButtonMenu]]
			ifFalse:	[
				target closeBlockEditor.
				self select.
				frame := self ownerOrYourselfThatIsAPhratchFrameMorph.
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
		font: (PhratchFrameMorph getFont: #Button).
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
	frame := self ownerOrYourselfThatIsAPhratchFrameMorph.
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

	| menu |
	menu := MenuMorphNG new defaultTarget: self target.
	menu add: 'show' translated action: #makeVisible.
	menu add: 'export this sprite' translated action: #exportObject.

	menu addLine.
	menu add: 'duplicate' translated action: #duplicateNoAttach.
	menu add: 'delete' translated action: #undoableDeleteSprite.
	(self target isPhratchSpriteMorph)
		ifTrue: [ 
			menu addLine.
			menu add: 'clone' translated action: #spawn.
			menu add: 'parent...' translated action: #choosePrototype.
			self target instances size > 0
				ifTrue: [ menu add: 'children...' action: [ self childrenMenu ] ].
			self target isNested
				ifTrue: [ menu addLine ].
			self target hasSubsprites
				ifTrue: [ menu add: 'detach all subsprites' translated action: #unhingeAll ].
			self target ownerSprite ifNotNil: [ menu add: 'detach from ' , self target ownerSprite objName action: #unhinge ] ].
	menu
		localize;
		invokeModal
]

{ #category : #'event handling' }
LibraryItemMorph >> select [

	(self ownerOrYourselfThatIsAPhratchLibraryMorph) unhighlightAll. "unhighlight others"
	self highlight: true.
	World displayWorldSafely. "force immediate feedback"

]

{ #category : #BYOB }
LibraryItemMorph >> stageMenu [
	"Present the right button menu on the stage icon"

	| menu library frame |
	library := self ownerOrYourselfThatIsAPhratchLibraryMorph.
	library ifNil: [^ self].
	frame := self ownerOrYourselfThatIsAPhratchFrameMorph.
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

	(self target isPhratchStageMorph) ifTrue: [^ self]. "cannot drag stage thumbnail"

	(self ownerOrYourselfThatIsAPhratchLibraryMorph)
		ifNil: [evt hand grabMorph: self]
		ifNotNil: [evt hand attachMorph: self fullCopy].

]

{ #category : #stepping }
LibraryItemMorph >> step [
	"Optimization: Don't update unless the costume has changed."

	| changeTime stage frame |
	target ifNil: [
		(frame := (self ownerOrYourselfThatIsAPhratchFrameMorph)) ifNotNil: [
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

	(self target isPhratchStageMorph)
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
		ellipses := '...'.
		1 to: n size do: [:i |
			s := n copyFrom: 1 to: i.
			w := nameMorph stringWidth: (s, ellipses).
			w > (self width - 3) ifTrue: [
				^ (n copyFrom: 1 to: i - 1), ellipses]]].

	^ target objName

]

{ #category : #initialization }
LibraryItemMorph >> updateNameAndInfo [

	| txt |

	txt := ((target objName, ' (', 'Scripts' localized, ': ', target scripts size printString,')')).

	target prototype ifNotNil: [
		txt := (txt, ' kind of: ', target prototype objName)].

	self
		setProperty: #balloonText
		toValue: txt.

	nameMorph ifNotNil:[
		(target isScriptablePhratchMorph) ifFalse: [
			nameMorph contents: '<no object>'.
			^ self].

		nameMorph contents = target objName ifFalse: [
			nameMorph contents: self truncatedLabel.
			nameMorph left: self left + ((self width - nameMorph width) // 2) + 1]].
]

{ #category : #initialization }
LibraryItemMorph >> updateRotationToggleMorph [

	rotationToggleMorph ifNil: [
		self buildRotationToggleMorph ].
	(self target isNil
		or: [(self target isPhratchStageMorph)
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
	target
		ifNil: [ 
			thumbnailMorph changed.
			^ self ].
	self updateRotationToggleMorph.
	smallSize := (form height // 3) @ (form height // 3).
	((target isPhratchSpriteMorph) and: [ target hasSubsprites ])
		ifTrue: [ 
			1 to: (target subsprites size min: 3) do: [ :idx | 
				subs := ((target subsprites at: idx) imageForm asFormOfDepth: 16)
					toThumbnail: smallSize
					borderWidth: 0
					borderColor: Color transparent.
				subs displayOn: form at: (form width - (subs width * idx)) @ (form height - subs height) ] ].
	anchor := (target isPhratchSpriteMorph) and: [ target ownerSprite notNil ].
	f := target imageForm asFormOfDepth: 16.
	f width <= form width & (f height <= form height)
		ifTrue: [ 
			"target's image fits without shrinking"
			f displayOn: form at: (form extent - f extent) // 2.
			thumbnailMorph changed.
			^ self ].
	e := f width > f height
		ifTrue: [ form width @ (f height * form width // f width) ]
		ifFalse: [ (f width * form height // f height) @ form height ].
	e := e max: 8 @ 8.
	r := Rectangle center: form extent // 2 extent: e.
	(WarpBlt toForm: form)
		sourceForm: f;
		cellSize: 2;
		combinationRule: Form paint;
		copyQuad: f boundingBox innerCorners toRect: (r insetBy: 2).	"do smoothing; this also installs a colormap"
	anchor
		ifTrue: [ 
			(WarpBlt toForm: form)
				sourceForm: (target ownerSprite imageForm asFormOfDepth: 16);
				cellSize: 2;
				combinationRule: Form paint;
				copyQuad: f boundingBox innerCorners toRect: (0 @ 0 extent: smallSize)	"do smoothing; this also installs a colormap"	"anchor displayOn: form at: 0@0" ].
	thumbnailMorph changed
]

{ #category : #'dropping/grabbing' }
LibraryItemMorph >> wantsDroppedMorph: aMorph event: evt [
	"Answer true if the given morph is a script, costume, sound or comment."

	^ (aMorph isBlockMorph) or: [
		(aMorph isMediaItemMorph) or: [
			aMorph isPhratchCommentMorph]]

]
