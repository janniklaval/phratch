Extension { #name : #ColorForm }

{ #category : #'*Phratch-Extensions' }
ColorForm >> equals: aForm [
	"Answer true if the receiver is exactly the same as the given Form."

	^ (super equals: aForm) and: [self colors = aForm colors]
]

{ #category : #'*Phratch-Extensions' }
ColorForm >> hibernateForPhratch [
	"Make myself take up less space. See comment in Form>hibernate."

	super hibernate.
	self clearColormapCache.

]
