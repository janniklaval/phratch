Extension { #name : #Color }

{ #category : #'*Phratch-Extensions' }
Color >> b255 [
	"Answer my blue component as an integer in the range [0..255]. If I am the color black, answer 1 rather than 0 to avoid treating this color as transparent in paint mode."

	(rgb = 0 and: [self class = Color]) ifTrue: [^ 1].  "make black not be transparent"

	^ (rgb bitShift: -2) bitAnd: 255
]

{ #category : #'*Phratch-Extensions' }
Color >> g255 [
	"Answer my green component as an integer in the range [0..255]."

	^ (rgb bitShift: -12) bitAnd: 255
]

{ #category : #'*Phratch-Extensions' }
Color >> r255 [
	"Answer my red component as an integer in the range [0..255]."

	^ (rgb bitShift: -22) bitAnd: 255
]

{ #category : #'*Phratch-Extensions' }
Color >> setRgb: rgbValue [
	"Initialize this color."

	rgb == nil ifFalse: [self attemptToMutateError].
	rgb := rgbValue.
]
