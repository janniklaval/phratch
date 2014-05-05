Extension { #name : #PhratchSpriteMorph }

{ #category : #'*PhratchLooks' }
PhratchSpriteMorph >> addCostTyped: aString [
	"Add a new costume to the sprite"
	<phratchItem: 'add $NewCostume$ to costumes' kind: #- category: 'looks' defaultValues: #() subCategory: #a2 special: #()>
	self addCostumeTyped: aString.
]

{ #category : #'*PhratchLooks' }
PhratchSpriteMorph >> area [
	"Compute the area based on the height and width of the sprite"
	<phratchItem: 'area' kind: #ReporterWatcherBlockMorph category: 'looks' defaultValues: #() subCategory: #a4 special: #()>
^self height * self width
]

{ #category : #'*PhratchLooks' }
PhratchSpriteMorph >> changeStretchBy: delta [
	"Change my horizontal aspect ratio by the given amount."
	<phratchItem: 'change horizontal stretch by $Number$%' kind: #- category: 'looks' defaultValues: #() subCategory: #a5 special: #()>
	| currentStretch |
	currentStretch := (100.0 * scalePoint x) / scalePoint y.
	self setStretchTo: (currentStretch + delta).

]

{ #category : #'*PhratchLooks' }
PhratchSpriteMorph >> changeVStretchBy: delta [
	"Change my vertical aspect ratio by the given amount."
	<phratchItem: 'change vertical stretch by $Number$%' kind: #- category: 'looks' defaultValues: #() subCategory: #a5 special: #()>
	| currentVStretch |
	currentVStretch := (100.0 * scalePoint y) / scalePoint x.
	self setVStretchTo: (currentVStretch + delta).
]

{ #category : #'*PhratchLooks' }
PhratchSpriteMorph >> deleteCostAt: aNumber [
	"Delete the given costume"
	<phratchItem: 'delete costume $Number$' kind: #- category: 'looks' defaultValues: #(1) subCategory: #a2 special: #()>
	self deleteCostumeAt: aNumber.
]

{ #category : #'*PhratchLooks' }
PhratchSpriteMorph >> goBackByLayers: aNumber [
	"Decrease my layer by (i.e., move me towards the back by) the given number of layers."
	<phratchItem: 'go back $Number$ layers' kind: #- category: 'looks' defaultValues: #(1) subCategory: #a7 special: #()>
	self setLayerTo: self layer + aNumber truncated
]

{ #category : #'*PhratchLooks' }
PhratchSpriteMorph >> goUpByLayers: aNumber [
	"Decrease my layer by (i.e., move me towards the back by) the given number of layers."
	<phratchItem: 'come up $Number$ layers' kind: #- category: 'looks' defaultValues: #(1) subCategory: #a7 special: #()>
	self setLayerTo: self layer - aNumber truncated
]

{ #category : #'*PhratchLooks' }
PhratchSpriteMorph >> hFlip [
	"Make my costume an horizontal flip"
	<phratchItem: 'horizontal flip' kind: #- category: 'looks' defaultValues: #() subCategory: #a5 special: #()>
    costume form: (self form flipBy: #horizontal centerAt: 0 @ 0).
    self costumeChanged
]

{ #category : #'*PhratchLooks' }
PhratchSpriteMorph >> hScale [
	"Answer my horizontal stretch."
	<phratchItem: 'horizontal stretch' kind: #ReporterBlockMorph category: 'looks' defaultValues: #() subCategory: #a5 special: #()>
	^ (100 * scalePoint x) rounded
]

{ #category : #'*PhratchLooks' }
PhratchSpriteMorph >> nextCostume [
	"Show the next costume in my costumes list."
	<phratchItem: 'next costume' kind: #- category: 'looks' defaultValues: #() subCategory: #a1 special: #()>
	
	super nextCostume.

]

{ #category : #'*PhratchLooks' }
PhratchSpriteMorph >> perimeter [
"Return the perimeter based on the width and height"
	<phratchItem: 'perimeter' kind: #ReporterWatcherBlockMorph category: 'looks' defaultValues: #() subCategory: #a4 special: #()>
^ (2 * self height) + (2 * self width)
]

{ #category : #'*PhratchLooks' }
PhratchSpriteMorph >> replaceCost: name with: sel [
	"Replace the given costume"
	<phratchItem: 'replace costume $Number$ with $NewCostume$' kind: #- category: 'looks' defaultValues: #(1) subCategory: #a2 special: #()>
	self replaceCostume: name with: sel.
]

{ #category : #'*PhratchLooks' }
PhratchSpriteMorph >> setStretchTo: percent [
	"Set x stretch percent relative to y. For example, a stretch of 200 stretches x by a factor of two relative to y while a stretch of 50 compresses x by a factor of two. As my stretch is changed, my x scale changes but my y scale remains the same."
	<phratchItem: 'set horizontal stretch to $Number$%' kind: #- category: 'looks' defaultValues: #(100) subCategory: #a5 special: #()>
	| baseScale origExtent minStretch maxStretch newStretchFactor |
	baseScale := scalePoint y.
	origExtent := self costumeForm extent.
	minStretch := 8.0 / (baseScale * origExtent x).  "min width 8 pixels"
	maxStretch := 500.0 / (baseScale * origExtent x). "max width 500 pixels"
	newStretchFactor := ((percent max: 0) / 100.0) within: minStretch and: maxStretch.
	self scalePoint: baseScale * (newStretchFactor @ 1.0).

]

{ #category : #'*PhratchLooks' }
PhratchSpriteMorph >> setVStretchTo: percent [
	"Set y stretch percent relative to x. For example, a stretch of 200 stretches yt by a factor of two relative to x while a stretch of 50 compresses y by a factor of two. As my stretch is changed, my y scale changes but my x scale remains the same."
	<phratchItem: 'set vertical stretch to $Number$%' kind: #- category: 'looks' defaultValues: #(100) subCategory: #a5 special: #()>
	| baseScale origExtent minStretch maxStretch newStretchFactor |
	baseScale := scalePoint x.
	origExtent := self costumeForm extent.
	minStretch := 8.0 / (baseScale * origExtent y).  "min height 8 pixels"
	maxStretch := 500.0 / (baseScale * origExtent y). "max height 500 pixels"
	newStretchFactor := ((percent max: 0) / 100.0) within: minStretch and: maxStretch.
	self scalePoint: baseScale * (1.0 @ newStretchFactor).
]

{ #category : #'*PhratchLooks' }
PhratchSpriteMorph >> vFlip [
	"Flip vertically myself"
	<phratchItem: 'vertical flip' kind: #- category: 'looks' defaultValues: #() subCategory: #a5 special: #()>
    costume form: (self form flipBy: #vertical centerAt: 0 @ 0).
    self costumeChanged
]

{ #category : #'*PhratchLooks' }
PhratchSpriteMorph >> vScale [
	"Stretch vertically myself"
	<phratchItem: 'vertical stretch' kind: #ReporterBlockMorph category: 'looks' defaultValues: #() subCategory: #a5 special: #()>
	^ (100 * scalePoint y) rounded
]
