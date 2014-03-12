Extension { #name : #CommentBlockMorph }

{ #category : #'*PhratchObjStream' }
CommentBlockMorph >> asBlockTuple [

	^ Array
		with: #comment:
		with: commentMorph contents
		with: isShowing

]
