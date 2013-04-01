Class {
	#name : #ReporterBlockDropTargetMorph,
	#superclass : #CommandBlockMorph,
	#instVars : [
		'isBoolean',
		'feedbackMorph',
		'lambdaMorph'
	],
	#category : #'Phratch-BYOB'
}

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph class >> booleanLabelled: aString argument: aMorphOrNumber [
	 | m |
	m := self new isBoolean: true; label: aString; color: Color  lightGray twiceLighter twiceLighter.
	(aMorphOrNumber isKindOf: ReporterBlockMorph) ifTrue: [m argument: aMorphOrNumber ].
	^m
]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph class >> labelled: aString [
	^self new label: aString
]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph class >> labelled: aString argument: aMorphOrNumber [
	^self new label: aString; argument: aMorphOrNumber
]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph >> argument [
	| am |
	am := argMorphs first.
	(am isKindOf: ReporterBlockMorph) ifTrue: [ ^am ].
	(am isKindOf: BooleanArgMorph) ifTrue: [^nil ].
	^am labelMorph contents
]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph >> argument: aMorphOrNumber [
	(aMorphOrNumber isKindOf: ReporterBlockMorph)
		ifTrue: [^self replaceArgMorph: argMorphs first by: aMorphOrNumber ].
	argMorphs first stringExpression: aMorphOrNumber
]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph >> drawOn: aCanvas [

	aCanvas fillRectangle: self bounds color: color.

]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph >> initialize [
	super initialize.
	isBoolean := false.
	self color: Color transparent
]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph >> isBoolean: aBoolean [
	isBoolean := aBoolean
]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph >> label: aString [
	|dropSpec|
	dropSpec := ' %s'.
	isBoolean ifTrue: [dropSpec := ' %b'].
	self commandSpec: aString, dropSpec
]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph >> labelColor [
	^Color gray: 0.3

]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph >> layoutChanged [
	| be |
	super layoutChanged.
	be := self ownerOrYourselfThatIsA: BlockEditorFrameMorph.
	be ifNotNil: [ be adjustExtentToAnswerField ]

]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph >> replaceSubmorph: oldMorph by: newMorph [
	| index itsPosition w |
	oldMorph stopStepping.
	itsPosition := oldMorph referencePositionInWorld.
	index := submorphs indexOf: oldMorph.
	(submorphs includes: newMorph) ifTrue: [ index := index -1 ].
	oldMorph privateDelete.
	self privateAddMorph: newMorph atIndex: index.
	newMorph referencePositionInWorld: itsPosition.
	(w := newMorph world) ifNotNil:
		[w startSteppingSubmorphsOf: newMorph].

]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph >> rightButtonMenu [


]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph >> rootForGrabOf: aMorph [
	"prevent myself from being extracted."

	^nil
]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph >> step [
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
	"h toolType = 'CutTool' ifTrue: [^ self showDeleteFeedback]."

	(self bounds containsPoint: h position) ifFalse: [ ^ self].
	h submorphCount = 1 ifFalse: [^ self].
	(self uncoveredAt: h cursorPoint) ifFalse: [^ self].

	b := h firstSubmorph.
	(b isKindOf: BlockMorph) ifFalse: [ ^ self].
	(b isKindOf: HatBlockMorph) ifTrue: [ ^ self ].

	b isReporter ifTrue: [ "reporter block"

		targetArg := (self allMorphs) detect: [:m | (m isKindOf: ArgMorph) and: [m bounds containsPoint: h position]] ifNone: [nil].
		targetArg ifNil: [

			(targetArg := self topArgMorphAt: b bounds exclude: nil) ifNil: [^ self]].

		(targetArg acceptsTypeOf: b) ifFalse: [ ^ self].
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
		and: [(targetArg owner isKindOf: ReporterScriptBlockMorph) not]]) ifTrue: [
			feedbackMorph
				color: (feedbackColor);
				bounds: (targetArg bounds insetBy: 3).
			lambdaMorph := ImageMorph new form: ((b imageForm outlineWidth: 3 color: Color gray depth: 8) 
														withOutlineColor: Color lightGray lighter width: 1)].
	
		lambdaMorph ifNotNil: [
			lambdaMorph position: b position - 4.
			h addMorphBack: lambdaMorph].

		h addMorph: feedbackMorph].




	"non-reporter (i.e. command block)"
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
			h addMorphFront: (feedbackMorph position: targetP - (feedbackMorph width@0))]
		ifFalse: [feedbackMorph extent: (targetBlock right - targetP x)@5.
			h addMorphFront: (feedbackMorph position: targetP)].
]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph >> stepTime [
	"Answer the desired time between steps in milliseconds. This default implementation requests that the 'step' method be called once every second."

	^0

]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph >> topArgMorphAt: aRectangle exclude: aMorph [
	"Give feedback about possible drop targets."

	| stack argM area |
	"find the top block or stack under the given point, excluding the given morph"

	area := [:morph |
			| space |
			space := morph bounds.
			({CSlotMorph. OSlotMorph} includes: morph class)
				ifTrue: [space := morph bounds expandBy: 5].
			((morph isKindOf: SpecialArgMorph) and: [
				#(reporterslot booleanslot) includes: morph type])
					ifTrue: [space := morph bounds insetBy: 8].
			space].

	stack := submorphs
		detect: [:m | (m ~~ aMorph) and: [(m isKindOf: BlockMorph) and: [m fullBounds intersects: aRectangle]]]
		ifNone: [ ^ self argumentAt: 1].

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
					ifTrue: [^ argM]]]].

	(stack isKindOf: ReporterBlockMorph "ReporterScriptBlockMorph")
		ifTrue: [^ stack]
		ifFalse: [^ nil].

]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph >> uncoveredAt: aPoint [
	"Return true if the receiver is not covered by any submorphs at the given point."

	| w morphsAbove be  |
	(w := self world) ifNil: [^ true].

	morphsAbove := w morphsAt: aPoint.
	(morphsAbove size = 0) ifTrue: [^ true ].

	be := self ownerOrYourselfThatIsA: DialogBoxMorph.

	morphsAbove do: [:m | ((m isKindOf: DialogBoxMorph) and: [m ~= be])
		ifTrue: [^ false ]].

	^ true
]

{ #category : #'as yet unclassified' }
ReporterBlockDropTargetMorph >> wantsDroppedMorph: aMorph event: evt [
	| topArg |

	(aMorph isKindOf: CommandBlockMorph) ifFalse: [^false ].
	topArg := self topArgMorphAt: aMorph bounds exclude: nil.
	topArg ifNil: [^ false].
	^ topArg acceptsTypeOf: aMorph 

]
