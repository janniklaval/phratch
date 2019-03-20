Extension { #name : #KeyEventHatMorph }

{ #category : #'*PhratchObjStream' }
KeyEventHatMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	^ Array
		with: #phratch
		with: ''
		with: self class name
		with: scriptNameMorph choice

]
