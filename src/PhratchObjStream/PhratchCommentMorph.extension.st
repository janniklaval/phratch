Extension { #name : #PhratchCommentMorph }

{ #category : #'*PhratchObjStream' }
PhratchCommentMorph >> tupleSequence [
	"Answer an array with a single tuple describing this comment."

	anchor isNil
		ifTrue: [
			^ Array with:
				(Array
					with: #phratch
					with: ''
					with: #phratchComment
					with: commentMorph contents
					with: isShowing
					with: self width)]
		ifFalse: [
			^ Array with:
				((Array
					with: #phratch
					with: ''), 
					(Array with: #phratchComment
						with: commentMorph contents
						with: isShowing
						with: self width
						with: anchor blockID))]

]
