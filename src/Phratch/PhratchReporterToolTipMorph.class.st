Class {
	#name : #PhratchReporterToolTipMorph,
	#superclass : #PhratchToolTipMorph,
	#category : #'Phratch-UI-Support'
}

{ #category : #'instance creation' }
PhratchReporterToolTipMorph class >> string: str for: morph [

	^ self new
		message: str;
		target: morph;
		color: (Color r: 0.9 g: 0.9 b: 0.9);
		useRoundedCorners;
		borderWidth: 0.

]

{ #category : #accessing }
PhratchReporterToolTipMorph >> message: aString [
	| verts |
	super message: aString.
	verts := PhratchTranslator isRTL
		ifFalse: [ Array with: self bottomLeft + (2 @ 6) with: self bottomLeft + (5 @ 0) with: self bottomLeft + (10 @ 0) ]
		ifTrue: [ Array with: self bottomRight - (2 @ 0) + (0 @ 6) with: self bottomRight - (5 @ 0) with: self bottomRight - (10 @ 0) ].
	self
		addMorph:
			(PolygonMorph
				vertices: verts
				color: (Color r: 0.9 g: 0.9 b: 0.9)
				borderWidth: 0
				borderColor: Color yellow)
]

{ #category : #accessing }
PhratchReporterToolTipMorph >> messageFont [

	^ PhratchFrameMorph getFont: #ReporterToolTip

]
