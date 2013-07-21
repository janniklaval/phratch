Class {
	#name : #LabelFragmentBlockMorph,
	#superclass : #ReporterBlockMorph,
	#category : #'Phratch-Blocks'
}

{ #category : #'as yet unclassified' }
LabelFragmentBlockMorph >> addLabel [
	"Add a label for my command and arguments. This is the method that really creates the whole block."
	"Details: We remove all the pieces of this block, and then reassemble them, being careful not to destroy any argument morphs that we might still want to use. This is helpful if someone adds/removes parameters from a hat block."

	| tokens args nextArgIndex m next |
	commandSpec ifNil: [^ self].

	"we make sure not to remove the next block."
	next := self nextBlock.
	self removeAllMorphsIn: (self submorphs reject: [:t | t = next]).

	tokens := self parseCommandSpecPreservingBlanks: commandSpec.
	args := tokens select: [:s | CommandBlockMorph isArgSpec: s].

	"remove any excess arg morphs from the list."
	[argMorphs size > args size] whileTrue: [
		m := argMorphs last.
		argMorphs remove: m.

		"if the argument we're throwing out is anything complicated, we'd like to keep it around in the world."
		(m isKindOf: BlockMorph) ifTrue: [m openInWorld]].

	"create new arg morphs."
	[argMorphs size < args size] whileTrue: [
		argMorphs addLast: (self argMorphFor: (args at: argMorphs size + 1))].

	nextArgIndex := 1.

	tokens do: [:s |
		(CommandBlockMorph isArgSpec: s)
			ifTrue:	[
				m := argMorphs at: nextArgIndex.
				nextArgIndex := nextArgIndex + 1]
			ifFalse:	[
				m := self labelMorphFor: s].
		self addMorphBack: m].

	self isReporter ifTrue: [

		"attempt to embed ReporterScripts more gracefully. Has some issues, 
		commented out for now, (jens)"
		
		"self adjustReporterLayoutForLambda."
		
		m := submorphs last.
		((m isKindOf: ChoiceArgMorph) | (m isKindOf: SpriteArgMorph)) ifTrue: [  "add spacer"
			self addMorphBack: (Morph new color: Color transparent; extent: 2@5)]].

]

{ #category : #'as yet unclassified' }
LabelFragmentBlockMorph >> drawOn: aCanvas [ 

	| right topY bottomY xInset c toggle l t cArgs clip |
	self computeHighlightColors.

	l := OrderedCollection new.

	right := self width.
	topY := bottomY := self height // 2.
	self height even ifTrue: [topY := bottomY - 1].
	xInset := 0.
	toggle := 0.
	[topY >= 0] whileTrue: [
		topY = 0 ifTrue: [c := highlightColor1].
		topY = 1 ifTrue: [c := highlightColor2].
		topY > 1 ifTrue: [c := color].
		self addHLineFrom: xInset to: right - xInset y: topY color: c to: l.
		(topY > 1) & (xInset > 0) ifTrue: [
			self addPoint: xInset@topY 
				color: (toggle < 2 ifTrue: [shadowColor] ifFalse: [color])
				to: l.
			self addPoint: (right - xInset - 1)@topY 
				color: (toggle < 2 ifTrue: [color] ifFalse: [shadowColor])
				to: l].

		c := bottomY = (self height - 1) ifTrue: [shadowColor] ifFalse: [color].
		self addHLineFrom: xInset to: right - xInset y: bottomY color: c to: l.
		xInset > 0 ifTrue: [
			self addPoint: xInset@bottomY 
				color: (toggle > 1 ifTrue: [highlightColor1] ifFalse: [color])
				to: l.
			self addPoint: (right - xInset - 1)@bottomY 
				color: (toggle > 1 ifTrue: [color] ifFalse: [shadowColor])
				to: l].

		toggle < 2 
			ifTrue: [ 
				xInset := xInset + 1.2.
				toggle := toggle + 1 ]
			ifFalse: [
				xInset := xInset - 1.
				toggle := toggle + 1.
				toggle > 4 ifTrue: [
					toggle := 0]].
		bottomY := bottomY + 1.
		topY := topY - 1].

	cArgs := self nonControlFlowSubmorphs select: [:s | (s isKindOf: CArgSlotMorph) or: [s isKindOf: CReporterSlotMorph]].
	cArgs isEmpty 
		ifFalse: [
			cArgs do: [:ca |
				t := OrderedCollection new.
				l do: [:pair |
					self addAreasOf: pair first outside: ca bounds color: pair second to: t].
			l := t].
			t := OrderedCollection new.
			clip := (self right + 4 - (self height // 2) @ self top) corner: self bottomRight.
			l do: [:pair |
				self addAreasOf: pair first outside: clip color: pair second to: t].
			l := t].
	
	l do: [:pair |
		aCanvas fillRectangle: pair first color: pair second ].

]

{ #category : #'as yet unclassified' }
LabelFragmentBlockMorph >> fixBlockLayout [
	self fixBlockLayoutNoWrap.
	(self submorphs select: [:m | (m isKindOf: CArgSlotMorph) or: [m isKindOf: CReporterSlotMorph]]) do: [:m |
		m width: 50]
]

{ #category : #'as yet unclassified' }
LabelFragmentBlockMorph >> parseCommandSpecPreservingBlanks: aCommandSpec [
	"Answer an array of token strings containing my keywords and argument specs."
	"LabelFragmentBlockMorph new parseCommandSpecPreservingBlanks: '$22$2fr rdx'"
	| result len i j spec k |
	result := OrderedCollection new.
	spec := aCommandSpec.
	len := aCommandSpec size.

	i := 1.
	[(i < len) and: [(spec at: i) isSeparator]] whileTrue: [i := i + 1].
	[i <= len] whileTrue: [
		j := spec indexOf: $$ startingAt: i.
		j > 0
			ifTrue: [
				j > i ifTrue: [result addLast: (spec copyFrom: i to: j - 1)].
				j < len
					ifTrue: [k := j + 1.
						((spec at: k) isLetter | (spec at: k) isDigit) 	"digits added for BYOB  -Jens"
							ifTrue: [[(k+1 <= len) and: [(spec at: k+1) ~= $$]] whileTrue:[
								k := k + 1].
								(k >= len)
									ifTrue: [result addLast: (spec copyFrom: j to: len).
										i := len + 1]
									ifFalse: [result addLast: (spec copyFrom: j to: k+1).
										i := k+2]]
							ifFalse: [result addLast: '$'.
										i := j + 1]]
					ifFalse: [result addLast: '$'.
						i := j + 2]]
			ifFalse: [
				result addLast: (spec copyFrom: i to: len).
				i := len + 1]].

	result := result select: [:s | s ~= ' '].
	^ result asArray collect: [:s | s copyReplaceAll: '_' with: ' ' asTokens: false]

]
