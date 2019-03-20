Extension { #name : #TypeInReporterSlotMorph }

{ #category : #'*PhratchObjStream' }
TypeInReporterSlotMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	| blockTuple arg |
	
	blockTuple := Array new: 4.
	blockTuple
		at: 1 put: #phratch;
		at: 2 put: self rcvr;
		at: 3 put: selector.

	arg := self nestedBlock.
	(arg isKindOf: ReporterBlockMorph)
		ifTrue: [blockTuple at: 4 put: (Array with: argMorphs first asBlockTuple)]
		ifFalse: [blockTuple at: 4 put: arg evaluate]. 
	^ blockTuple
]
