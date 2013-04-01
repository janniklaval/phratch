Class {
	#name : #WhenHatBlockMorph,
	#superclass : #HatBlockMorph,
	#instVars : [
		'argMorph',
		'lastState'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #other }
WhenHatBlockMorph >> argMorph [

	submorphs do: [:m |
		(m isKindOf: ArgMorph) ifTrue: [^ m].
		(m isKindOf: ReporterBlockMorph) ifTrue: [^ m]].
	^ nil

]

{ #category : #other }
WhenHatBlockMorph >> argMorphToReplace: aMorph [
	"Answer a new argument morph to be used to replace the given morph."

	aMorph ~= argMorph ifTrue: [^ nil].
	^ BooleanArgMorph new

]

{ #category : #other }
WhenHatBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	| argTuple |
	argTuple := (argMorph isKindOf: ArgMorph)
		ifTrue: [argMorph evaluate]
		ifFalse: [argMorph asBlockTuple].

	^ Array with: #byob with: '' with: self class name with: argTuple

]

{ #category : #other }
WhenHatBlockMorph >> evaluateCondition [
	"Answer true if my condition is true."

	| arg |
	arg := submorphs detect: [:m | m isKindOf: ReporterBlockMorph] ifNone: [^ false].
	^ arg evaluate

]

{ #category : #other }
WhenHatBlockMorph >> fixBlockLayout [
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

{ #category : #other }
WhenHatBlockMorph >> helpScreenName [
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	^ 'whenHat'

]

{ #category : #initialization }
WhenHatBlockMorph >> initialize [

	| s1 s2 |
	super initialize.
	argMorph := BooleanArgMorph new.
	lastState := false.

	s1 := 'when' localized.
	s2 := 'is true' localized.
	self removeAllMorphs.
	self addMorphBack: ((PhratchStringMorph contents: s1 font: (PhratchFrameMorph getFont: #Label)) color: Color white).
	self addMorphBack: argMorph.
	self addMorphBack: ((PhratchStringMorph contents: s2 font: (PhratchFrameMorph getFont: #Label)) color: Color white).

]

{ #category : #other }
WhenHatBlockMorph >> nextBlock [
	"Answer the block following myself in the block sequence or nil if I am the last block in the sequence. Each block is a submorph of the previous block."

	^ self submorphs
		detect: [:m | (m isKindOf: BlockMorph) and: [m ~= argMorph]]
		ifNone: [nil]

]

{ #category : #other }
WhenHatBlockMorph >> printHatNameOn: aStream [
	"Append a human-readable string for this hat block's name to the given stream."

	aStream nextPutAll: 'when '.
	self printCodeSubmorph: argMorph on: aStream.
	aStream nextPutAll: ' becomes true'; cr.

]

{ #category : #other }
WhenHatBlockMorph >> replaceArgMorph: oldMorph by: newMorph [
	"Replace oldMorph with newMorph. This is done when dropping a reporter block onto my argument."

	argMorph := newMorph.
	self replaceSubmorph: oldMorph by: newMorph.
	self layoutChanged.

]

{ #category : #other }
WhenHatBlockMorph >> triggered [
	"Answer true if my condition has just become true."

	| condition |
	condition := self evaluateCondition.
	condition & lastState not ifTrue: [lastState := true. ^ true].  "trigger on false->true transition"
	lastState := condition.
	^ false

]

{ #category : #'as yet unclassified' }
WhenHatBlockMorph >> veryDeepFixupWith: deepCopier [
	"If fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals."

	super veryDeepFixupWith: deepCopier.
	argMorph := deepCopier references at: argMorph ifAbsent: [argMorph]

]
