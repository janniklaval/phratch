Extension { #name : #PhratchSpriteMorph }

{ #category : #'*PhratchPen' }
PhratchSpriteMorph >> changePenHueBy: aNumber [
	"Change the pen hue by given number."
	<phratchItem: 'change pen color by $Number$' kind: #- category: 'pen' defaultValues: #() subCategory: #a3 special: #()>
	self setPenHueTo: penHue + aNumber.


]

{ #category : #'*PhratchPen' }
PhratchSpriteMorph >> changePenShadeBy: aNumber [
	"Change the pen shade (lightness) by given number"
	<phratchItem: 'change pen shade by $Number$' kind: #- category: 'pen' defaultValues: #() subCategory: #a3 special: #()>
	self setPenShadeTo: penShade + aNumber.

]

{ #category : #'*PhratchPen' }
PhratchSpriteMorph >> changePenSizeBy: aNumber [
	"Change my pen width."
	<phratchItem: 'change pen size by $Number$' kind: #- category: 'pen' defaultValues: #(1) subCategory: #a3 special: #()>
	self penSize: penSize + aNumber.

]

{ #category : #'*PhratchPen' }
PhratchSpriteMorph >> passivePenDown: aBoolean [

	| m |
	(aBoolean isBoolean)
		ifFalse: [^ self error: 'expecting a boolean'].
	penDown := aBoolean.
	penColor ifNil: [penColor := Color black].  "initialize if necessary"
	penSize ifNil: [penSize := 1].  "initialize if necessary"

	(m := self ownerOrYourselfThatIsAPhratchStageMorph)
		ifNotNil: [m penUpOrDownChangeFor: self].

	self propagate: #penDown

]

{ #category : #'*PhratchPen' }
PhratchSpriteMorph >> passivePenSize: aNumber [
	"Set my pen width."

	penSize := aNumber asNumberNoError rounded min: (PhratchFrameMorph workpaneExtent x * 2) max: 1.

	self propagate: #penSize

]

{ #category : #'*PhratchPen' }
PhratchSpriteMorph >> passiveSetPenHueTo: aNumber [
	"Set the pen hue to given number between 0 and 200. (That makes 100 the 'maximum' distance away from the original color on the color wheel.)"

	penHue := aNumber asNumberNoError \\ 200.
	self setPenShadeTo:  penShade.  "compute and set penColor"

	self propagate: #penColor

]

{ #category : #'*PhratchPen' }
PhratchSpriteMorph >> passiveSetPenShadeTo: aNumber [
	"Set the pen shade (lightness) to given number between 0 and 100. A shade of 0 is black, 100 is white, and 50 is fully saturated color."
	"Details: We don't want to get all the way to pure black or white, so we divide the range 0..50 by a number > 50 when computing the fraction of the original color to mix with black or white."

	| normalizeShade scale k |
	penShade := aNumber asNumberNoError asFloat \\ 200.0.
	penColor := Color h: (360.0 * penHue) / 200.0 s: 1.0 v: 1.0.
	normalizeShade := penShade > 100.0 ifTrue: [200.0 - penShade] ifFalse: [penShade].

	(normalizeShade closeTo: 50.0) ifTrue: [^ self].  "pure color"

	scale := 1.0 / 60.0.
	k := 1.0 - (50.0 * scale).
	normalizeShade < 50.0 ifTrue: [
		penColor := penColor mixed: (scale * normalizeShade) + k with: Color black].
	normalizeShade > 50.0 ifTrue: [
		penColor := penColor mixed: 1.0 - (scale * (normalizeShade - 50.0)) with: Color white].

	self propagate: #penShade

]

{ #category : #'*PhratchPen' }
PhratchSpriteMorph >> penDown: aBoolean [

	self undeleteAttribute: #penDown.
	self passivePenDown: aBoolean
]

{ #category : #'*PhratchPen' }
PhratchSpriteMorph >> penHue [
	"Return my pen hue"
	<phratchItem: 'pen hue' kind: #ReporterWatcherBlockMorph category: 'pen' defaultValues: #() subCategory: #a1 special: #()>
	| att |
	att := #penColor.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ penHue
]

{ #category : #'*PhratchPen' }
PhratchSpriteMorph >> penShade [
	"Return my pen shade"
	<phratchItem: 'pen shade' kind: #ReporterWatcherBlockMorph category: 'pen' defaultValues: #() subCategory: #a1 special: #()>
	| att |
	att := #penShade.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ penShade
]

{ #category : #'*PhratchPen' }
PhratchSpriteMorph >> penSize: aNumber [
	"Set my pen width."
	<phratchItem: 'set pen size to $Number$' kind: #- category: 'pen' defaultValues: #(1) subCategory: #a3 special: #()>
	self undeleteAttribute: #penSize.
	self passivePenSize: aNumber
]

{ #category : #'*PhratchPen' }
PhratchSpriteMorph >> putPenDown [
	"Put down my drawing pen (i.e. start drawing a pen trail)."
	<phratchItem: 'pen down' kind: #- category: 'pen' defaultValues: #() subCategory: #a2 special: #()>
	self penDown: true.

]

{ #category : #'*PhratchPen' }
PhratchSpriteMorph >> putPenUp [
	"Put up my drawing pen (i.e. stop drawing a pen trail)."
	<phratchItem: 'pen up' kind: #- category: 'pen' defaultValues: #() subCategory: #a2 special: #()>
	self penDown: false.

]

{ #category : #'*PhratchPen' }
PhratchSpriteMorph >> setPenHueTo: aNumber [
	"Set the pen hue to given number between 0 and 200. (That makes 100 the 'maximum' distance away from the original color on the color wheel.)"
	<phratchItem: 'set pen color to $Number$' kind: #- category: 'pen' defaultValues: #(0) subCategory: #a3 special: #()>
	self undeleteAttribute: #penColor.
	self passiveSetPenHueTo: aNumber
]

{ #category : #'*PhratchPen' }
PhratchSpriteMorph >> setPenShadeTo: aNumber [
	"Set the pen shade (lightness) to given number between 0 and 100. A shade of 0 is black, 100 is white, and 50 is fully saturated color."
	"Details: We don't want to get all the way to pure black or white, so we divide the range 0..50 by a number > 50 when computing the fraction of the original color to mix with black or white."
	<phratchItem: 'set pen shade to $Number$' kind: #- category: 'pen' defaultValues: #(50) subCategory: #a3 special: #()>
	self undeleteAttribute: #penShade.
	self passiveSetPenShadeTo: aNumber
]

{ #category : #'*PhratchPen' }
PhratchSpriteMorph >> stampCostume [
	"Stamp a copy of my current costume on the pen trails layer."
	<phratchItem: 'stamp' kind: #- category: 'pen' defaultValues: #() subCategory: #a4 special: #()>
	| m |
	self step.  "update costume if necessary"
	(m := self ownerOrYourselfThatIsAPhratchStageMorph)
		ifNotNil: [m stampCostume: self].

]
