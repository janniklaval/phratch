Extension { #name : #CBlockMorph }

{ #category : #'*Phratch-BYOB-ddddd-ddddd' }
CBlockMorph >> isCShape [

	^ true
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd' }
CBlockMorph >> nests: aCommandBlock [

	(nestedBlock isKindOf: BlockMorph) 
		ifFalse: [^ false].
	^nestedBlock blockSequence includes: aCommandBlock
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd' }
CBlockMorph >> tabFields [

	| nst nstfields fields nxt nxtFields |
	fields := OrderedCollection new.
	nxtFields := OrderedCollection new.

	fields := OrderedCollection new.
	self nonControlFlowSubmorphs do: [:m |
		(m isKindOf: ExpressionArgMorph)
			ifTrue: [fields add: m ]
			ifFalse: [(m respondsTo: #tabFields)
				ifTrue: [fields addAll: m tabFields ]]]. 

	nst := nestedBlock.
	nst ifNotNil: [
		nstfields := nst tabFields ].

	nxt := self nextBlock.
	nxt ifNotNil: [
		nxtFields := nxt tabFields ].

	nstfields ifNotNil: [
		fields := fields, nstfields ].
	nxtFields ifNotNil: [
		fields := fields, nxtFields ].

	^  fields
]
