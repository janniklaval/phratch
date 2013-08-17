Extension { #name : #FormCanvas }

{ #category : #'*Phratch-Extensions' }
FormCanvas >> grafPort [

	^port
]

{ #category : #'*Phratch-Extensions' }
FormCanvas >> text: s bounds: boundsRect font: fontOrNil kern: kern color: c [

	self drawString: s in: boundsRect font: fontOrNil color: c
]
