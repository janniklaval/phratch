Class {
	#name : #BlockEditorFrameMorph,
	#superclass : #DialogBoxMorph,
	#instVars : [
		'headerMorph',
		'bodyMorph',
		'hat',
		'answerField',
		'definition',
		'template',
		'receiver',
		'bin',
		'atomicityToggle',
		'resizeMorph',
		'resizeOffset'
	],
	#classVars : [
		'UserPos',
		'UserSize'
	],
	#category : #'Phratch-BYOB'
}

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph class >> initialize [
	"BlockEditorFrameMorph initialize"
	self resetDimensions
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph class >> minExtent [
	^400 @ 300.
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph class >> resetDimensions [
	UserPos := nil.
	UserSize := self minExtent.
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph class >> setUserPos: aPoint size: anExtent [
	UserPos := aPoint.
	UserSize := anExtent.
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> adjustExtentToAnswerField [

	| answerExt newExt |
	answerExt := self minExtentForAnswer.
	answerExt > self extent
		ifTrue: [ newExt := answerExt min: World extent ]
		ifFalse: [ newExt := self extent ].
	self extent: newExt
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> allBlocks [
	| all ans |
	all := OrderedCollection new.
	hat nextBlock ifNotNil: [
		all addAll: (hat nextBlock allMorphs select: [:m |
			m isKindOf: BlockMorph])].
	answerField ifNotNil: [
		ans := answerField allMorphs select: [:m |
			m isKindOf: BlockMorph].
		ans size > 0 ifTrue: [
			all addAll: ans]].
	^ all
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> allBlocksFor: id [
	^ self allBlocks select: [:b |
		b isCustomBlock and: [
			b id = id]]
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> buildAnswerField [
	| spacer ans |

	(answerField isKindOf: ReporterBlockDropTargetMorph) ifTrue: [
		mainColumn replaceSubmorph: answerField 
						by: (answerField := Morph new extent: 0@0)].		

	spacer := answerField.
	#none = definition type
		ifTrue: [^ self].
	ans := definition answer.
	(ans isKindOf: BlockMorph)
		ifTrue: [ans refreshAttributeArgs].
	#boolean = definition type
		ifTrue: [answerField := ReporterBlockDropTargetMorph booleanLabelled: 'report' localized argument: ans]
		ifFalse: [
			ans ifNil: [ans := 'something' localized ].
			answerField := ReporterBlockDropTargetMorph labelled: 'report' localized argument: ans].
	mainColumn replaceSubmorph: spacer by: answerField.
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> buildAtomicityToggle [

	| labelFont  |

	atomicityToggle ifNotNil: [atomicityToggle delete].

	labelFont := (ScratchFrameMorph getFont: #UploadTagLabel).

	atomicityToggle := ToggleButton
		onForm: (ScratchFrameMorph skinAt: #watcherButtonPressed)
		offForm: (ScratchFrameMorph skinAt: #watcherButton).

	atomicityToggle
		target: self;
		width: 80;
		actionSelector: #toggleAtomicity;
		borderWidth: 0;
		label: 'atomic' localized
		font: labelFont;
		setLabelColor: (Color gray: 0.3);

		setProperty: #balloonText toValue: 'execute as single block' localized.

	mainColumn addMorph: atomicityToggle.
	atomicityToggle on. 
	self updateAtomicityToggle.


]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> buildScript [
	|nb b|
	nb := hat nextBlock.
	nb ifNotNil: [nb delete].	
	definition body ifNotNil: [
		b := definition body fullCopy.
		b refreshAttributeArgs.
		b position: hat position.
		hat nextBlock: b]
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> cascade [
	| sf match findMatch |
	sf := self scratchFrame.
	sf purgeBlockEditors.
	findMatch := [ match := sf blockEditors detect: [:editor |
		editor ~= self and: [
			editor position = self position]]
		ifNone: [nil]].
	findMatch value.
	[match isNil] whileFalse: [
		self position: match position + (0@20).
		findMatch value]
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> centerOnScreen [

	super centerOnScreen.
	self updateResizeMorph
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> definition [
	^definition
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> definition: aCustomBlockDefinition [

	| def |
	def := aCustomBlockDefinition.

	hat ifNotNil: [
		def body: hat nextBlock.
		hat delete ].

	(answerField isKindOf: ReporterBlockDropTargetMorph) ifTrue: [
		def type = #none
			ifTrue: [def answer: nil]
			ifFalse: [def answer: answerField argument]].

	definition := def.
	template := receiver newCustomBlockFor: def.
	template isTemplate: true.
	template addLabel.
	hat := ProcedureHatBlockMorph on: template.
	bin addMorph:(hat position: bin position + (10@10)).

	self buildScript.
"	self buildVariables."
	self buildAtomicityToggle.
	self buildAnswerField.
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> extent: aPoint [
	
	| w newExtent min|

	min := self class minExtent max: self minExtentForAnswer.

	newExtent := aPoint max: min.

	bounds extent = newExtent ifFalse: [
		self changed.
		bounds := bounds topLeft extent: newExtent.
		self layoutChanged.
		self changed].

	self fixLayoutForExtent: newExtent.

	UserPos isNil & resizeOffset isNil ifTrue: [
		w := self world.
		w ifNotNil: [ aPoint = self extent ifFalse: [
			self position: w center - (self extent // 2)]]].  "center on screen"

	self keepOnScreen

]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> fixLayoutForExtent: aPoint [

	| bFrame bScroller |

	super fixLayoutForExtent: aPoint.

	titleBin ifNotNil: [ titleBin width: aPoint x " - 40" ].

	bin ifNil: [^ self].

	bScroller := bin owner.
	bFrame := bScroller owner.

	bFrame extent: aPoint - (70 @ (120 + answerField height)).
	bScroller extent: bFrame extent.

	self updateResizeMorph
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> getUserResponse [
	"Wait for the user to respond, then report their response. The symbol #cancel is returned if the user wishes to cancel the operation. True/false is returned if they respond yes/no, and a string is returned if this this a string input dialog and they don't cancel."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop."

	| w |
	self openInWorld.

	UserPos isNil 
		ifTrue: [ self centerOnScreen ]
		ifFalse: [self snapToUserDimensions ].
	self cascade.
		
	w := self world.
	self buttons size > 0 ifTrue: [
		w activeHand newKeyboardFocus: self buttons last].
	tabFields size > 0 ifTrue: [
		w activeHand newKeyboardFocus: (tabFields at: 1)].

	done := false.
	[done] whileFalse: [w doOneCycle].  "wait for user to press a button"

	^ response

]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> handlesMouseDown: evt [
	^true
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> hat [
	^hat
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> initialize [
	| line container sl |

	super initialize.
	self title: 'Block Editor' localized.
	resizeMorph := ScratchResizeMorph ofType: #corner.
	line := AlignmentMorph newRow
		color: Color transparent.

	answerField := Morph new extent: 0@0.
	mainColumn addMorph: answerField.
	mainColumn addMorph: line.

	container := Morph new 	color: Color transparent.

	sl := ScrollFrameMorph2 new
		growthFraction: 0.0;
		color: ScratchFrameMorph scriptsPaneColor.

	bin := ScratchScriptsMorph new.
	sl contents: bin.

	line addMorphBack: container.

	sl extent: container extent.
	container addMorph: sl.

	self addMorph: resizeMorph.



]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> instancesOf: aCustomBlockId [

	| binInstances ansInstances |
	binInstances := bin allMorphs select: [:m|
		((m isKindOf: CustomCommandBlockMorph) or: [
			m isKindOf: CustomReporterBlockMorph]) and: [
				m id = aCustomBlockId]].
	#none = definition type 
		ifTrue: [^binInstances ].
	(answerField argument isKindOf: BlockMorph) ifFalse: [
		^ binInstances].
	ansInstances := answerField argument allMorphs select: [:m|
		(m isKindOf: CustomReporterBlockMorph) and: [
		m id = aCustomBlockId]].

	^binInstances, ansInstances

]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> justDroppedInto: aMorph event: evt [
	"Never embed myself in a morph (e.g. the Stage)."

	super justDroppedInto: aMorph event: evt.
	self keepOnScreen

]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> keepOnScreen [

	| min |
	min := self class minExtent max: self minExtentForAnswer.

	self left < 0 ifTrue: [ self left: 0].
	self top < 0 ifTrue: [ self top: 0].

	self right > Display extent x
		ifTrue: [ resizeOffset 
			ifNil: [ 
				self left: ((Display extent x - self width) max: 0).
				(self right > Display extent x and: [self width > min x])
					ifTrue: [self width: Display extent x - self left ]]
			ifNotNil: [self width: Display extent x - self left]].

	self bottom > Display extent y
		ifTrue: [ resizeOffset 
			ifNil: [	
				self top: ((Display extent y - self height) max: 0). 
				(self bottom > Display extent y and: [self height > min y])
					ifTrue: [self height: Display extent y - self top]]
			ifNotNil: [self height: Display extent y - self top]].


]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> minExtentForAnswer [
	answerField ifNil: [^self class minExtent].
	^ answerField extent + (60 @ 180) min: World extent.

]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> mouseDown: evt [
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	| p |
	p := evt cursorPoint.
	((resizeMorph bounds expandBy: 4) containsPoint: p)
		ifFalse: [evt hand grabMorph: self]
		ifTrue: [resizeOffset := self bottomRight - p]

]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> mouseMove: evt [

	resizeOffset ifNotNil: [
		self extent: (evt cursorPoint - self topLeft) + resizeOffset ]


]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> mouseUp: evt [

	resizeOffset := nil.

]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> position: aPoint [

	super position: aPoint.
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> receiver: aScriptableScratchMorph [
	receiver := aScriptableScratchMorph
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> rememberUserDimensions [
	self class setUserPos: self position size: self extent
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> scratchFrame [
	^receiver ownerOrYourselfThatIsA: ScratchFrameMorph
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> snapToUserDimensions [

	self extent: UserSize.
	UserPos ifNotNil: [
		self position: UserPos ].

]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> step [
	resizeOffset notNil | (owner isKindOf: HandMorph)
		ifTrue: [^self ].
	self keepOnScreen 

]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> template [
	^template
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> toggleAtomicity [
	definition toggleAtomicity.
	self updateAtomicityToggle

]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> topArgMorphAt: aRectangle exclude: aMorph [
	"Give feedback about possible drop targets."

	(answerField isKindOf: ReporterBlockDropTargetMorph) 
		ifFalse: [^nil].
	^answerField topArgMorphAt: aRectangle exclude: aMorph
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> updateAtomicityToggle [
	definition isAtomic
		ifTrue: [atomicityToggle on]
		ifFalse: [atomicityToggle off].

]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> updateResizeMorph [
	resizeMorph ifNotNil: [
		resizeMorph position: self bottomRight - bottomRightForm width ]

]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> wantsDroppedMorph: aMorph event: evt [

	(answerField isKindOf: ReporterBlockDropTargetMorph) 
		ifFalse: [^false].
	^answerField wantsDroppedMorph: aMorph event: evt	
]

{ #category : #'as yet unclassified' }
BlockEditorFrameMorph >> yes [
	"Yes button was pressed."
	| stage sf |

	self rememberUserDimensions.
	self allMorphs do: [:each| 
		(each isKindOf: BlockMorph) ifTrue: [ each litUp: false].
		(each isKindOf: StringFieldMorph) ifTrue: [each keyboardFocusChange: false]].
	definition body: hat nextBlock.
	#none = definition type ifFalse: [
		definition answer: answerField argument ].

	stage := receiver ownerOrYourselfThatIsA: ScratchStageMorph.
	receiver
		updateCustomBlockDefinitionId: definition id with: definition;
		updateLocalId: definition id withSpec: definition userSpec.

	(definition isGlobal not and: [stage notNil])
		ifFalse: [
			(stage sprites, {stage} copyWithout: receiver) do: [:obj |
				obj
					updateCustomBlockDefinitionId: definition id with: definition;
					updateOnlyLocalId: definition id withSpec: definition userSpec]].	

	sf := receiver ownerOrYourselfThatIsA: ScratchFrameMorph.
	sf viewerPane categoryChanged: 'variables'.
	#none = definition category ifFalse: [
		sf viewerPane categoryChanged: definition category asString ].
	^ super yes
		

]
