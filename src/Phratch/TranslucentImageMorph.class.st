Class {
	#name : #TranslucentImageMorph,
	#superclass : #ImageMorph,
	#instVars : [
		'transparency'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'as yet unclassified' }
TranslucentImageMorph class >> bezelDiameter: d width: w baseColor: baseColor inset: insetFlag [
	"Answer a Form for a circular bezel with the given diameter and border width. Assume the light source is the top-left corner."

	| hue sat bri baseTheta f blt rOuter rInner center vector r angle newBri newSat |
	hue := baseColor hue.
	sat := baseColor saturation.
	bri := baseColor brightness.

	baseTheta := (-1@(-1)) theta.  "light comes from top-left"
	insetFlag ifTrue: [baseTheta := baseTheta + Float pi].

	f := Form extent: d@d depth: 16.
	blt := BitBlt bitPokerToForm: f.
	rOuter := d / 2.0.
	rInner := rOuter - w.
	center := rOuter truncated asPoint.
	0 to: d - 1 do: [:y |
		0 to: d - 1 do: [:x |
			vector := (x@y) - center.
			r := vector r.
			(r < rOuter and: [r >= rInner]) ifTrue: [
				angle := vector theta - baseTheta.
				newBri := ((bri + (angle cos / 4.0)) max: 0.0) min: 1.0.
				newSat := sat - (angle cos / 6.0) abs.
				blt pixelAt: x@y put: ((Color h: hue s: newSat v: newBri) pixelValueForDepth: f depth)]]].
	^ f

]

{ #category : #'as yet unclassified' }
TranslucentImageMorph class >> glowDiameter: d color: glowColor on: onFlag [
	"Answer a form containing a circular gradiant of the given diameter and color with the brightest point in the center (like an indicator light or LED). If onFlag is true, it is bright (on), otherwise it is dark (off)."

	| hue sat baseBri divider f blt radius center r c |
	hue := glowColor hue.
	sat := glowColor saturation.
	baseBri := onFlag ifTrue: [1.1] ifFalse: [0.5].
	divider := onFlag ifTrue: [1.6] ifFalse: [3.0].
	f := Form extent: d@d depth: 32.
	blt := BitBlt bitPokerToForm: f.
	radius := d / 2.0.
	center := radius truncated asPoint.
	0 to: d - 1 do: [:y |
		0 to: d - 1 do: [:x |
			r := ((x@y) - center) r.
			r < radius ifTrue: [
				c := Color h: hue s: sat v: baseBri - (r / (divider * radius)).
				blt pixelAt: x@y put: (c pixelValueForDepth: f depth)]]].
	^ f

]

{ #category : #'as yet unclassified' }
TranslucentImageMorph class >> includeInNewMorphMenu [

	^ true

]

{ #category : #'as yet unclassified' }
TranslucentImageMorph class >> indicatorDiameter: d borderWidth: w borderColor: bColor isInset: insetFlag onColor: onColor isOn: onFlag [
	"Answer a form for an indicator light with a bezel around it. Examples:
	(ImageMorph indicatorDiameter: 15 borderWidth: 2 borderColor: Color gray
		isInset: true onColor: Color red isOn: true) display.
	(ImageMorph indicatorDiameter: 15 borderWidth: 2 borderColor: Color gray
		isInset: true onColor: Color red isOn: false) display."

	| f |
	f := self bezelDiameter: d width: w baseColor: bColor inset: insetFlag.
	(self glowDiameter: (d - (2 * w)) color: onColor on: onFlag)
		displayOn: f at: w@w rule: Form paint.
	^ f

]

{ #category : #drawing }
TranslucentImageMorph >> drawOn: aCanvas [

	| clipC |
	clipC := aCanvas copyClipRect: self bounds.
	clipC translucentImage: image  at: self bounds origin.

]

{ #category : #initialization }
TranslucentImageMorph >> initialize [

	super initialize.
	transparency := 1.0.
]

{ #category : #'event handling' }
TranslucentImageMorph >> mouseLeave: evt [

	PhratchToolTipMorph clearToolTips.

]

{ #category : #accessing }
TranslucentImageMorph >> transparency [

	^ transparency

]

{ #category : #accessing }
TranslucentImageMorph >> transparency: aNumber [

	transparency := aNumber.
	self changed.

]
