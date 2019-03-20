Extension { #name : #EventHatMorph }

{ #category : #'*PhratchObjStream' }
EventHatMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its event name."

	^ Array with: #phratch with: '' with: self class name with: self eventName

]
