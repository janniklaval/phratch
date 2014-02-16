Class {
	#name : #ProcedureHatBlockMorph,
	#superclass : #HatBlockMorph,
	#instVars : [
		'argMorph'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #'instance creation' }
ProcedureHatBlockMorph class >> on: aBlockMorph [
	^self new template: aBlockMorph
]

{ #category : #other }
ProcedureHatBlockMorph >> argMorph [

	self nonControlFlowSubmorphs do: [:m |
		(m isKindOf: ArgMorph) ifTrue: [^ m].
		((m isKindOf: BlockMorph) and: [m isCustomBlock]) ifTrue: [^ m]].
	^ nil

]

{ #category : #other }
ProcedureHatBlockMorph >> argMorphToReplace: aMorph [
	"Answer a new argument morph to be used to replace the given morph."

	aMorph ~= argMorph ifTrue: [^ nil].
	^ BooleanArgMorph new

]

{ #category : #other }
ProcedureHatBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	| argTuple |
	argTuple := (argMorph isKindOf: ArgMorph)
		ifTrue: [argMorph evaluate]
		ifFalse: [argMorph asBlockTuple].

	^ Array with: #phratch with: '' with: self class name with: argTuple

]

{ #category : #other }
ProcedureHatBlockMorph >> fixBlockLayout [
	"Update the positions of my submorphs."

	| x centerY nextB |
	argMorph ifNil: [^ self].  "happens during initialization"

	blockLayoutNeeded ifFalse: [^ self].
	cachedForm := nil.
	cachedFeedbackForm := nil.

	((argMorph isKindOf: ArgMorph) and: [argMorph owner = self])
		ifTrue: [argMorph fixArgLayout].
	self height: 26 + argMorph height.

	x := self left + 8.
	centerY := bounds center y + 5.
	self nonControlFlowSubmorphs do: [:m |
		m position: x@(centerY - (m height // 2)).
		x := x + m width + 5].

	self width: ((x + 4 - self left) max: self hatTopForm width).

	(nextB := self nextBlock) ifNotNil: [
		nextB top: self bottom - 4.
		nextB fixBlockLayout].

]

{ #category : #widgets }
ProcedureHatBlockMorph >> handlesMouseOver: evt [

	^ self argMorph isKindOf: BlockMorph

]

{ #category : #'event handling' }
ProcedureHatBlockMorph >> handlesMouseOverDragging: evt [

	^  self argMorph isKindOf: BlockMorph

]

{ #category : #other }
ProcedureHatBlockMorph >> helpScreenName [
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	^ 'whenHat'

]

{ #category : #initialization }
ProcedureHatBlockMorph >> initialize [

	super initialize.
	argMorph := ExpressionArgMorph new.

	self removeAllMorphs.
	self addMorphBack: argMorph.

]

{ #category : #'event handling' }
ProcedureHatBlockMorph >> mouseDown: evt [

	argMorph editSpec
]

{ #category : #'event handling' }
ProcedureHatBlockMorph >> mouseEnter: evt [

	self argMorph showEdgePlaceHolders
]

{ #category : #'event handling' }
ProcedureHatBlockMorph >> mouseEnterDragging: evt [

	"self argMorph showArgumentPlaceHolders"
]

{ #category : #'event handling' }
ProcedureHatBlockMorph >> mouseLeave: evt [

		self argMorph hideArgumentPlaceHolders
]

{ #category : #'event handling' }
ProcedureHatBlockMorph >> mouseLeaveDragging: evt [

	self argMorph hideArgumentPlaceHolders
]

{ #category : #other }
ProcedureHatBlockMorph >> nextBlock [
	"Answer the block following myself in the block sequence or nil if I am the last block in the sequence. Each block is a submorph of the previous block."

	^ self submorphs
		detect: [:m | (m isKindOf: BlockMorph) and: [m ~= argMorph]]
		ifNone: [nil]

]

{ #category : #other }
ProcedureHatBlockMorph >> printHatNameOn: aStream [
	"Append a human-readable string for this hat block's name to the given stream."

	aStream nextPutAll: 'when '.
	self printCodeSubmorph: argMorph on: aStream.
	aStream nextPutAll: ' becomes true'; cr.

]

{ #category : #other }
ProcedureHatBlockMorph >> replaceArgMorph: oldMorph by: newMorph [
	"Replace oldMorph with newMorph. This is done when dropping a reporter block onto my argument."

	argMorph := newMorph.
	self replaceSubmorph: oldMorph by: newMorph.
	self layoutChanged.

]

{ #category : #other }
ProcedureHatBlockMorph >> rootForGrabOf: aMorph [

	(owner isKindOf: PhratchScriptsMorph) ifTrue: [^nil].

	^ super rootForGrabOf: aMorph
]

{ #category : #'instance creation' }
ProcedureHatBlockMorph >> template: aBlock [
	self replaceArgMorph: self argMorph by: aBlock
]

{ #category : #copying }
ProcedureHatBlockMorph >> veryDeepFixupWith: deepCopier [
	"If fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals."

	super veryDeepFixupWith: deepCopier.
	argMorph := deepCopier references at: argMorph ifAbsent: [argMorph]

]
