Extension { #name : #ListContentsBlockMorph }

{ #category : #'*PhratchObjStream' }
ListContentsBlockMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	^ (Array new: 4)
		at: 1 put: #phratch;
		at: 2 put: self rcvr;
		at: 3 put: #listNamed:;
		at: 4 put: commandSpec;
		yourself


]
