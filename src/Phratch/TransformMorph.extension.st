Extension { #name : #TransformMorph }

{ #category : #'*Phratch-Extensions' }
TransformMorph >> unlockedMorphsAt: aPoint addTo: mList [
	"Return a collection of all morphs in this morph structure that contain the given point.  Map through my transform.  Must do this recursively because of transforms.  "
	| p |
	self isLocked ifTrue: [^ mList].
	(self containsPoint: aPoint) ifFalse:
		["TransformMorph clips to bounds"
		^ mList].
	p := transform globalPointToLocal: aPoint.
	submorphs do: [:m | m unlockedMorphsAt: p addTo: mList].
	mList addLast: self.
	^ mList

]
