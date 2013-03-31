Extension { #name : #FormCanvas }

{ #category : #'*Phratch-Extensions' }
FormCanvas >> grafPort [

	^port
]

{ #category : #'*Phratch-Extensions' }
FormCanvas >> text: s bounds: boundsRect font: fontOrNil kern: kern color: c [
"
	| scanner |
	scanner _
		MultiDisplayScanner quickPrintOn: form
			box: ((boundsRect translateBy: origin) intersect: clipRect) truncated
			font: fontOrNil
			color: (self shadowColor ifNil: [c]).
	scanner addKern: kern.
	scanner drawString: s at: boundsRect topLeft + origin.
"
	self drawString: s in: boundsRect font: fontOrNil color: c
]
