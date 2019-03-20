Extension { #name : #ColorForm }

{ #category : #'*PhratchObjStream' }
ColorForm >> privateColors [

	^ colors

]

{ #category : #'*PhratchObjStream' }
ColorForm >> privateColors: anObject [

	colors := anObject.
	cachedDepth := nil.
	cachedColormap := nil.

]
