"
I implement a fixed-order chain of image effects. Only the active filters are applied.
"
Class {
	#name : #FilterPack,
	#superclass : #Object,
	#instVars : [
		'resultForm',
		'reapply',
		'brightnessShift',
		'hueShift',
		'fisheye',
		'whirl',
		'mosaicCount',
		'pixelateCount'
	],
	#category : #PhratchLooks
}

{ #category : #filtering }
FilterPack >> applyFiltersTo: srcForm [
	"Apply all currently active filters to the given source form and answer the resulting filtered form. The argument Form itself is not changed."

	self applyStaticFiltersTo: (srcForm asFormOfDepth: 32).

	reapply := false.
	^ resultForm

]

{ #category : #private }
FilterPack >> applyMosaicFilter [
	"The absolute value of the raw mosaic value plus 15 is divided by 10, so 10 gives a 2x2 mosaic. This is to make the range scale of this filter similar to other filters such as whirl."

	| factor w h tempForm warpBlt pts destRect |
	factor := ((((mosaicCount abs + 10) // 10) max: 1) min: resultForm width) min: resultForm height.
	w := resultForm width // factor.
	h := resultForm height // factor.

	"build a grid of (factor x factor) shrunk-down copies in tempForm"
	tempForm := Form extent: (w * factor)@(h * factor) depth: 32.
	warpBlt := (WarpBlt toForm: tempForm)
		sourceForm: resultForm;
		combinationRule: Form over;
		yourself.
	pts := resultForm boundingBox corners.
	0 to: factor - 1 do: [:i |
		0 to: factor - 1 do: [:j |
			destRect := ((i * w) @ (j * h)) extent: (w@h).
			warpBlt copyQuad: pts toRect: destRect]].

	"rescale into resultForm"
	warpBlt := (WarpBlt toForm: resultForm)
		sourceForm: tempForm;
		combinationRule: Form over;
		yourself.
	warpBlt
		copyQuad: tempForm boundingBox corners
		toRect: resultForm boundingBox.


]

{ #category : #private }
FilterPack >> applyPixelateFilter [
	"The absolute value of the raw pixelateCount plus 10 is divided by 10, so 10 gives a 2x2 pixels. This is to make the range scale of this filter similar to other filters such as whirl."

	| factor w h smallImage warpBlt |
	factor := ((pixelateCount abs + 10) // 10) max: 1.
	w := (resultForm width // factor) max: 1.
	h := (resultForm height // factor) max: 1.

	"first, scale the image down"
	smallImage := Form extent: w@h depth: 32.
	warpBlt := (WarpBlt toForm: smallImage)
		sourceForm: resultForm;
		cellSize: 1;  "no smoothing"
		combinationRule: Form over;
		yourself.
	warpBlt copyQuad: resultForm boundingBox corners toRect: smallImage boundingBox.

	"now, scale the small image back up to full size"
	"NOTE: to keep Warpblt from running off the edge for large factors, we reduce the
	  source quad extent by one pixel"
	warpBlt := (WarpBlt toForm: resultForm)
		sourceForm: smallImage;
		combinationRule: Form over;
		yourself.
	warpBlt
		copyQuad: (0@0 extent: smallImage extent - 1) corners
		toRect: resultForm boundingBox.

]

{ #category : #private }
FilterPack >> applyStaticFiltersTo: srcForm [
	"Apply all active static filters."

	| fOut |
	resultForm := srcForm deepCopy.
	resultForm unhibernate.

	hueShift = 0 ifFalse: [
		resultForm := resultForm collectColors: [ :color |
			Color h: (color hue + hueShift)
				s: color saturation
				v: color brightness
				alpha: color alpha].			
	].
	brightnessShift = 0 ifFalse: [
		resultForm := resultForm collectColors: [ :color |
			color adjustBrightness: (brightnessShift / 100)]].

	whirl = 0 ifFalse: [
		fOut := resultForm deepCopy.
		fOut := fOut whirl: whirl asInteger.
		"PhratchPlugin primWhirl: resultForm bits
			into: fOut bits width: resultForm width angle: whirl asInteger."
		resultForm := fOut].

	fisheye = 0 ifFalse: [
		"Note: The primitive takes power >= 0 where 100 is normal, >100 is fisheye, <100 is blackhole effect"
		
		resultForm := resultForm fishEye: ((fisheye asInteger + 100) max: 0).
		"PhratchPlugin
			primFisheye: resultForm bits copy
			into: resultForm bits
			width: resultForm width
			power: ((fisheye asInteger + 100) max: 0)"].

	pixelateCount abs >= 5 ifTrue: [self applyPixelateFilter].
	mosaicCount abs >= 5 ifTrue: [self applyMosaicFilter].
	
	

]

{ #category : #accessing }
FilterPack >> brightnessShift [

	^ brightnessShift

]

{ #category : #accessing }
FilterPack >> brightnessShift: aNumber [

	brightnessShift := aNumber within: -100 and: 100.
	reapply := true.

]

{ #category : #filtering }
FilterPack >> clearFilterCaches [
	"Clear my caches. This should be called when the costume changes."

	reapply := true.

]

{ #category : #filtering }
FilterPack >> filtersActive [
	"Answer true if any filters are active."

	^ reapply

]

{ #category : #accessing }
FilterPack >> fisheye [

	^ fisheye

]

{ #category : #accessing }
FilterPack >> fisheye: aNumber [

	fisheye := aNumber.
	reapply := true.

]

{ #category : #accessing }
FilterPack >> hueShift [

	^ hueShift

]

{ #category : #accessing }
FilterPack >> hueShift: aNumber [

	hueShift := aNumber \\ 200.
	reapply := true.

]

{ #category : #initialize }
FilterPack >> initialize [

	resultForm := nil.
	reapply := true.
	self resetAllFilters.

]

{ #category : #accessing }
FilterPack >> mosaicCount [

	^ mosaicCount

]

{ #category : #accessing }
FilterPack >> mosaicCount: aNumber [

	mosaicCount := aNumber.
	reapply := true.

]

{ #category : #accessing }
FilterPack >> pixelateCount [

	^ pixelateCount

]

{ #category : #accessing }
FilterPack >> pixelateCount: aNumber [

	pixelateCount := aNumber.
	reapply := true.

]

{ #category : #filtering }
FilterPack >> resetAllFilters [

	resultForm := nil.

	hueShift := 0.
	brightnessShift := 0.
	mosaicCount := 0.
	pixelateCount := 0.
	fisheye := 0.
	whirl := 0.
]

{ #category : #accessing }
FilterPack >> resultForm [

	^ resultForm

]

{ #category : #accessing }
FilterPack >> whirl [

	^ whirl

]

{ #category : #accessing }
FilterPack >> whirl: aNumber [

	whirl := aNumber.
	reapply := true.

]
