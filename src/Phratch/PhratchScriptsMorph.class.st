"
I hold the scripts and partially assembled scripts for a ScriptableScratchMorph.

"
Class {
	#name : #PhratchScriptsMorph,
	#superclass : #PasteUpMorph,
	#instVars : [
		'feedbackMorph',
		'screenshooting',
		'lambdaMorph',
		'droppedBlock',
		'droppedBottom',
		'kickedOutReporter',
		'nestedStack'
	],
	#category : #'Phratch-UI-Panes'
}

{ #category : #'event handling' }
PhratchScriptsMorph >> cleanUp [
	"Align all scripts vertically in alphabetical order"

	| sortedBlocks y collectedBlocks bTop bBottom cm bHeight |
	collectedBlocks := OrderedCollection new.
	submorphs do: [:m | 
		((m isKindOf: BlockMorph) 
		or: [(m isKindOf: PhratchCommentMorph) and: [m anchor isNil]]) 
			ifTrue:[collectedBlocks add: m]].

	sortedBlocks := collectedBlocks copy sorted: [:s1 :s2 | s1 top < s2 top].

	y := 20.
	(owner isKindOf: ScrollFrameMorph2) ifTrue: [
		owner hScrollPixels: 0.
		owner vScrollPixels: 0].
	sortedBlocks do: [:s |
		PhratchTranslator isRTL
			ifTrue: [(owner isKindOf: ScrollFrameMorph2)
				ifTrue: [s position: (owner left + owner visibleExtent x - s width - 29)@(self top + y)]
				ifFalse: [s position: (self right - s width - 20)@(self top + y)]]
			ifFalse: [s position: self position + (20@y)].

		bTop := s top.
		bBottom := s fullBounds bottom.
		cm := s commentMorph.
		cm notNil ifTrue: [
			cm step.
			bBottom := bBottom max: cm bottom].
		bHeight := bBottom - bTop.

		y := y + bHeight + 15].

	self layoutChanged.

]

{ #category : #drawing }
PhratchScriptsMorph >> drawOn: aCanvas [
	"Fill with my texture patch. Fill with a solid color if there is no texture in the current skin dictionary."

	| patchF clipC y x |

	self isScreenshooting ifTrue: [
		aCanvas fillRectangle: self bounds color: Color transparent.
		^ self].

	patchF := PhratchFrameMorph skinAt: #scriptsPaneTexture ifAbsent: [
		aCanvas fillRectangle: self bounds color: color.
		^ self].

	clipC := aCanvas copyClipRect: self bounds.
	y := self top.
	[y <= self bottom] whileTrue: [
		x := self left.
		[x <= self right] whileTrue: [
			clipC paintImage: patchF at: x@y.
			x := x + patchF width].
		y := y + patchF height].

]

{ #category : #'object i/o' }
PhratchScriptsMorph >> fieldsVersion [
	"I depend on my superclass for object i/o. Currently, thos methods are inherited from Morph."

	^ 1

]

{ #category : #'event handling' }
PhratchScriptsMorph >> handlesMouseDown: evt [
	
	^ true
]

{ #category : #initialization }
PhratchScriptsMorph >> initialize [

	super initialize.
	color := Color white.
	borderWidth := 0.
	self enableDragNDrop: true.

]

{ #category : #'parts bin' }
PhratchScriptsMorph >> isPartsBin [
	^ false
]

{ #category : #screenshot }
PhratchScriptsMorph >> isScreenshooting [

	^ screenshooting ifNil: [screenshooting := false]

]

{ #category : #byob }
PhratchScriptsMorph >> makeNewBlock [

	| be sf |
	be := self ownerOrYourselfThatIsA: BlockEditorFrameMorph.
	be ifNil: [^self].
	sf := be phratchFrame.
	sf ifNil: [^self].
	sf scriptsPane target addCustomBlock

]

{ #category : #byob }
PhratchScriptsMorph >> migrateBlockVars [

	| be |
	be := self ownerOrYourselfThatIsA: BlockEditorFrameMorph.
	be ifNil: [^self ].
 	be definition migrateBlockVars.
	be buildScript
]

{ #category : #'event handling' }
PhratchScriptsMorph >> mouseDown: evt [

	| m |
	evt hand newKeyboardFocus: nil.

	evt redButtonPressed ifTrue: [ 
		evt hand toolType: nil.
		^owner mouseDown: evt].

	evt hand toolType ifNotNil: [
		"revert to normal cursor"
		evt hand toolType: nil.
		^ self].

	evt rightButtonPressed ifTrue: [
		Sensor waitNoButton.
		(m := self ownerOrYourselfThatIsA: PhratchScriptEditorMorph) ifNil: [^ self rightButtonMenu].
		(m target notNil and: [m currentCategory = 'Scripts'])
			ifTrue: [m scriptsMenu: evt hand position].
		^ self].

	evt hand waitForClicksOrDrag: self event: evt.
]

{ #category : #'event handling' }
PhratchScriptsMorph >> mouseEnterDragging: evt [
	"Switch the tabs to script if a block is current being dragged"

	| scriptEditorMorph |
	scriptEditorMorph := self ownerOrYourselfThatIsA: PhratchScriptEditorMorph.
	(scriptEditorMorph currentCategory = 'Scripts') ifFalse:[
		scriptEditorMorph currentCategory: 'Scripts'].

]

{ #category : #'event handling' }
PhratchScriptsMorph >> mouseHold: evt [

	| m |
	(m := self ownerOrYourselfThatIsA: PhratchScriptEditorMorph) ifNil: [^ self].
	(m target notNil and: [m currentCategory = 'Scripts'])
		ifTrue: [m scriptsMenu: evt hand position].

]

{ #category : #'event handling' }
PhratchScriptsMorph >> mouseMove: evt [ 
	owner mouseMove: evt
]

{ #category : #'event handling' }
PhratchScriptsMorph >> mouseUp: evt [

	evt hand toolType ifNil: [owner mouseUp: evt]
]

{ #category : #undo }
PhratchScriptsMorph >> recordDroppedBlock: aBlockMorph bottom: stackBottom kickedOut: aReporter [

	droppedBlock := aBlockMorph.
	droppedBottom := stackBottom.
	kickedOutReporter := aReporter. 
	nestedStack := nil
]

{ #category : #undo }
PhratchScriptsMorph >> recordNestedStack: aBlockMorph [
	nestedStack := aBlockMorph
]

{ #category : #'event handling' }
PhratchScriptsMorph >> rightButtonMenu [

	| menu be |
	menu := MenuMorph new defaultTarget: self.
	menu add: 'clean up' action: #cleanUp.
	menu add: 'save picture of scripts' action: #saveScriptsToImage.
	be := self ownerOrYourselfThatIsA: BlockEditorFrameMorph.
	be ifNotNil: [ be definition varNames size > 0 ifTrue: [
		menu add: 'turn block variables into script variables' action: #migrateBlockVars]].
	menu add: 'undo last drop' action: #undoLastDrop.
	menu addLine.
	menu add: 'make a block' action: #makeNewBlock.

	menu localize; popUpInWorld.

]

{ #category : #screenshot }
PhratchScriptsMorph >> saveScriptsToImage [
	"Take a snapshot of all scripts for a sprite and save as a GIF file"

	| fName saveForm |

	saveForm := self screenshot.

	fName := PhratchFileChooserDialog
		chooseNewFileDefault: ''
		title: 'Save Scripts Snapshot'
		type: #scriptsSnapshot.
	fName = #cancelled ifTrue: [^ self].
	fName size = 0 ifTrue: [^ self].

	(fName asLowercase endsWith: '.gif') ifFalse: [fName := fName, '.gif'].
	saveForm writeGIFFileNamed: fName.

]

{ #category : #screenshot }
PhratchScriptsMorph >> screenshot [
	"answer a Form of myself apt for exporting"

	| saveForm leftX topY rightX bottomY |

	screenshooting := true.
	self changed.
	saveForm := self imageForm.

	"clip"

	leftX := submorphs anyOne left.
	topY := submorphs anyOne top.
	rightX := submorphs anyOne right.
	bottomY := submorphs anyOne bottom.
	(self allMorphs select: [:m | m ~= self]) do: [:m |
		leftX := leftX min: m left.
		topY := topY min: m top.
		rightX := rightX max: m right.
		bottomY := bottomY max: m bottom].
	saveForm := saveForm copy: (((leftX @ topY) - self position) rect: ((rightX @ bottomY) - self position)).

	screenshooting := false.
	self changed.
	^ saveForm

]

{ #category : #stepping }
PhratchScriptsMorph >> showCommentDropFeedback [

	| hand comment target r |

	hand := World activeHand.
	comment := hand firstSubmorph.
	target := comment attachTargetIn: self.
	target ifNil: [^ self].

	r := target bounds.

	((target isKindOf: CBlockMorph) and: [target firstBlockList size > 0])
		ifTrue: [r := r merge: target firstBlockList first fullBounds].
	(target isKindOf: IfElseBlockMorph)
		ifTrue: [
			(target trueBlockList size > 0)
				ifTrue: [r := r merge: target trueBlockList first fullBounds].
			(target falseBlockList size > 0)
				ifTrue: [r := r merge: target falseBlockList first fullBounds]].
	feedbackMorph
		bounds: (r expandBy: 3);
		color: Color transparent;
		borderColor: (comment topBarColor).
	self addMorphFront: feedbackMorph.

]

{ #category : #drawing }
PhratchScriptsMorph >> showDeleteFeedback [
	"Display feedback for the scissors tool."

	| h cutBlock r |
	h := World activeHand.
	(cutBlock := self topBlockMorphAt: h cursorPoint exclude: nil) ifNil: [^ self].
	((cutBlock isKindOf: CSlotMorph) or: [cutBlock isKindOf: OSlotMorph])
		ifTrue: [cutBlock := cutBlock owner].
	r := cutBlock bounds.
	((cutBlock isKindOf: CBlockMorph) and: [cutBlock firstBlockList size > 0])
		ifTrue: [r := r merge: cutBlock firstBlockList first fullBounds].
	(cutBlock isKindOf: HatBlockMorph)
		ifTrue: [r := cutBlock fullBounds].
	feedbackMorph
		bounds: (r expandBy: 3);
		color: Color transparent;
		borderColor: (Color r: 212/255 g: 40/255 b: 40/255).
	feedbackMorph on: #mouseDown send: #click: to: cutBlock.
	self addMorphFront: feedbackMorph.

]

{ #category : #stepping }
PhratchScriptsMorph >> step [
	"Give feedback about possible drop targets."

	| feedbackColor h b targetArg targetAssoc targetP targetBlock |

	feedbackMorph
		ifNil: [feedbackMorph := BorderedMorph new borderWidth: 3]  "create feedback morph if necessary"
		ifNotNil: [feedbackMorph delete].  "remove old feedback"
	feedbackColor := Color white.
	feedbackMorph useSquareCorners.

	lambdaMorph
		ifNotNil: [lambdaMorph delete. lambdaMorph := nil].  "remove old lambda feedback"

	h := World activeHand.
	h toolType = 'CutTool' ifTrue: [^ self showDeleteFeedback].

	(self bounds containsPoint: h position) ifFalse: [^ self].
	h submorphCount = 1 ifFalse: [^ self].
	b := h firstSubmorph.
	(b isKindOf: PhratchCommentMorph) ifTrue: [^ self showCommentDropFeedback].
	(b isKindOf: BlockMorph) ifFalse: [^ self].

	b isReporter ifTrue: [ "reporter block"
		(targetArg := self topArgMorphAt: b bounds exclude: nil) ifNil: [^ self].
		(targetArg acceptsTypeOf: b) ifFalse: [^ self].
		feedbackMorph
			bounds: (targetArg bounds expandBy: 5);
			color: (feedbackColor alpha: 0.4);
			borderColor: feedbackColor;
			useRoundedCorners.

		(targetArg isKindOf: OSlotMorph) ifTrue: [
			feedbackMorph
				bounds: (targetArg bounds expandBy: 8)].

		((targetArg isKindOf: SpecialArgMorph) 
		and: [(#(reporterslot booleanslot) includes: targetArg type)
		and: [targetArg owner notNil 
		and: [(#(function functionWithArgs) includes: targetArg owner selector) not]]]) ifTrue: [
			feedbackMorph
				color: (feedbackColor);
				bounds: (targetArg bounds insetBy: 3).
			lambdaMorph := ImageMorph new form: ((b imageForm outlineWidth: 3 color: Color gray depth: 8) 
														withOutlineColor: Color lightGray lighter width: 1)].
	
		lambdaMorph ifNotNil: [
			lambdaMorph position: b position - 4.
			h addMorphBack: lambdaMorph].

		^ self addMorphFront: feedbackMorph].

	"non-reporter (i.e. command block or hat block)"
	targetAssoc := b closestAttachTargetIn: self.
	targetAssoc ifNil: [
		(b bottomBlock isKindOf: CBlockMorph) ifFalse: [
			targetAssoc := b bottomBlock closestAttachTargetIn: self.
			targetAssoc ifNotNil:[
				(targetAssoc value owner isKindOf: BlockMorph) ifTrue:[
					targetAssoc := nil]]]].
	targetAssoc ifNil: [^ self].

	targetP := targetAssoc key.
	targetBlock := targetAssoc value.
	feedbackMorph borderColor: feedbackColor; color: feedbackColor.

	"subtract the attachment point x from the width so that the feedback in CBlock won't stick out"
	PhratchTranslator isRTL
		ifTrue: [feedbackMorph extent: (targetP x - targetBlock left)@5.
			self addMorphFront: (feedbackMorph position: targetP - (feedbackMorph width@0))]
		ifFalse: [feedbackMorph extent: (targetBlock right - targetP x)@5.
			self addMorphFront: (feedbackMorph position: targetP)].

]

{ #category : #stepping }
PhratchScriptsMorph >> stepTime [

	^ 50

]

{ #category : #stepping }
PhratchScriptsMorph >> topArgMorphAt: aRectangle exclude: aMorph [
	"Give feedback about possible drop targets."

	| stack argM area targetArg |
	"find the top block or stack under the given point, excluding the given morph"

	area := [:morph |
			| space |
			space := morph bounds.
			({CSlotMorph. OSlotMorph} includes: morph class)
				ifTrue: [space := morph bounds expandBy: 5].
			((morph isKindOf: SpecialArgMorph) and: [
				#(reporterslot booleanslot) includes: morph type])
					ifTrue: [space := morph bounds insetBy: 8 ].
			space].

	stack := submorphs
		detect: [:m | (m ~~ aMorph) and: [(m isKindOf: BlockMorph) and: [m fullBounds intersects: aRectangle]]]
		ifNone: [^ nil].


	targetArg := (stack allMorphs) detect: [:m | (m isKindOf: ArgMorph) 
									and: [(m bounds containsPoint: World activeHand position)
									and: [m acceptsDroppedReporters]]] 
										ifNone: [nil].

	targetArg ifNotNil: [^ targetArg].

	stack allMorphsDo: [:b |
		((b isKindOf: CommandBlockMorph) and:
		 [(b isKindOf: HatBlockMorph) not]) ifTrue: [
			1 to: b argumentCount do: [:i |
				argM := b argumentAt: i.
	
				(argM isKindOf: MultiArgMorph) ifTrue: [
					argM elements do: [:elmt |
						((area value: elmt) intersects: aRectangle) ifTrue: [
							^elmt]]].

				(((area value: argM) intersects: aRectangle) and:
				 [argM acceptsDroppedReporters])
					ifTrue: [^ argM]]].
		(b isKindOf: WhenHatBlockMorph) ifTrue: [
			argM := b argMorph.
			((argM bounds intersects: aRectangle) and:
			 [argM acceptsDroppedReporters])
				ifTrue: [^ argM]]].
	^ nil

]

{ #category : #stepping }
PhratchScriptsMorph >> topBlockMorphAt: aPoint exclude: aMorph [
	"Give feedback about possible drop targets."

	| stack answer blocksUnderHand |
	stack := submorphs
		detect: [:m | (m isKindOf: BlockMorph) and: [m fullBounds containsPoint: aPoint]]
		ifNone: [^ nil].

	blocksUnderHand := OrderedCollection new.
	stack allMorphsDo: [:s | ((s isKindOf: BlockMorph) and: [s bounds containsPoint: aPoint]) 
		ifTrue: 	[blocksUnderHand addLast: s]
	].
	
	(blocksUnderHand isEmpty) ifTrue: [^ nil]
	ifFalse: [answer := blocksUnderHand first. ^ answer]	


]

{ #category : #undo }
PhratchScriptsMorph >> undoLastDrop [

	| arg next |
	droppedBlock ifNil: [^self ].
	(droppedBlock isKindOf: ReporterBlockMorph) ifTrue: [
		kickedOutReporter notNil 
			ifTrue: [ droppedBlock owner replaceArgMorph: droppedBlock by: kickedOutReporter]
			ifFalse: [(droppedBlock owner isKindOf: BlockMorph)
				ifTrue: [
					arg := droppedBlock owner argMorphToReplace: droppedBlock.
					arg ifNotNil: [droppedBlock owner replaceArgMorph: droppedBlock by: arg]]].
		^self activeHand attachMorph: droppedBlock ].

	next := droppedBottom nextBlock.
	nestedStack ifNotNil: [next := nestedStack ].
	next ifNotNil: [droppedBlock owner addMorph: next ].
	(droppedBlock owner isKindOf: BlockMorph) ifTrue: [
		next ifNotNil: 
			[ droppedBlock owner attachBlock: next]].

	self activeHand attachMorph: droppedBlock
]