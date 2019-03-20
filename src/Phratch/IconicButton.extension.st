Extension { #name : #IconicButton }

{ #category : #'*Phratch-Extensions' }
IconicButton >> labelGraphic: aForm borderWidth: borderW [
	"Use this method to make small iconic buttons that don't give pressed feedback."

	| oldLabel graphic |
	(oldLabel := self findA: SketchMorph) ifNotNil: [oldLabel delete].
	graphic := SketchMorph withForm: aForm.
	self addMorph: (graphic position: self position + borderW; lock;
		yourself).
	self
		color: Color transparent;
		borderWidth: borderW;
		extent: (graphic extent + (2 * borderW)).

]
