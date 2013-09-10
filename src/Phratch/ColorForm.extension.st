Extension { #name : #ColorForm }

{ #category : #'*Phratch-Extensions' }
ColorForm >> hibernateForPhratch [
	"Make myself take up less space. See comment in Form>hibernate."

	super hibernate.
	self clearColormapCache.

]

{ #category : #'*Phratch-Extensions' }
ColorForm >> privateColors [

	^ colors

]

{ #category : #'*Phratch-Extensions' }
ColorForm >> privateColors: anObject [

	colors := anObject.
	cachedDepth := nil.
	cachedColormap := nil.

]
