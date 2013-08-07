"
I implement a fixed-order chain of image effects. Only the active filters are applied.
"
Class {
	#name : #FilterPack,
	#superclass : #Object,
	#instVars : [
		'resultForm',
		'cachedForm',
		'reapply',
		'brightnessShift',
		'hueShift',
		'saturationShift',
		'fisheye',
		'whirl',
		'blur',
		'mosaicCount',
		'pixelateCount',
		'pointillizeSize',
		'pointillizeForm',
		'randSeed',
		'waterRippleRate',
		'waterArray1',
		'waterArray2'
	],
	#category : #'Phratch-Objects'
}

{ #category : #filtering }
FilterPack >> applyFiltersTo: srcForm [
	"Apply all currently active filters to the given source form and answer the resulting filtered form. The argument Form itself is not changed."

	self applyStaticFiltersTo: (srcForm asFormOfDepth: 32).

	"apply the dynamic filters"
	pointillizeSize = 0 ifFalse: [self applyPointillizeFilter].
	waterRippleRate = 0 ifFalse: [self applyWaterRippleFilter].

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
FilterPack >> applyPointillizeFilter [
	"Pointillize the image with rectanges as big as 'size'."

	| sz dot offset colorMap count alpha bitblt x y thisColorPix |
	pointillizeForm ifNil: [pointillizeForm := cachedForm deepCopy].
	sz := pointillizeSize asInteger abs.
	sz := sz min: ((pointillizeForm width min: pointillizeForm height) // 2).
	dot := Form dotOfSize: sz.
	offset := sz // 2.
	colorMap := Bitmap new: 2.
	colorMap at: 1 put: 0.  "transparent"
	count := (pointillizeForm width * pointillizeForm height) // (50 * sz).
	alpha := 120.  "alpha can be 0 to 255"

	bitblt := (BitBlt toForm: pointillizeForm)
		sourceForm: dot;
		sourceRect: dot boundingBox;
		combinationRule: 31;  "alpha paint with constant alpha"
		colorMap: colorMap;
		yourself.

	1 to: count do: [:i |
		x := self rand \\ pointillizeForm width.
		y := self rand \\ pointillizeForm height.
		thisColorPix := cachedForm bits at: ((y * pointillizeForm width) + x + 1).
		colorMap at: 2 put: thisColorPix.
		bitblt destOrigin: (x - offset)@(y - offset); copyBitsTranslucent: alpha].

	resultForm := pointillizeForm deepCopy.


]

{ #category : #private }
FilterPack >> applyStaticFiltersTo: srcForm [
	"Apply all active static filters."

	| fOut tmp |
	resultForm := srcForm deepCopy.
	resultForm unhibernate.

	hueShift = 0 ifFalse: [
		PhratchPlugin primShiftHue: resultForm bits
			into: resultForm bits byDegrees: (1.8 * hueShift) asInteger].
	saturationShift = 0 ifFalse: [
		PhratchPlugin primShiftSaturation: resultForm bits
			into: resultForm bits by: saturationShift asInteger].
	brightnessShift = 0 ifFalse: [
		PhratchPlugin primShiftBrightness: resultForm bits
			into: resultForm bits by: brightnessShift asInteger].

	whirl = 0 ifFalse: [
		fOut := resultForm deepCopy.
		PhratchPlugin primWhirl: resultForm bits
			into: fOut bits width: resultForm width angle: whirl asInteger.
		resultForm := fOut].

	fisheye = 0 ifFalse: [
		"Note: The primitive takes power >= 0 where 100 is normal, >100 is fisheye, <100 is blackhole effect"
		PhratchPlugin
			primFisheye: resultForm bits copy  "copy the source bits"
			into: resultForm bits
			width: resultForm width
			power: ((fisheye asInteger + 100) max: 0)].

	pixelateCount abs >= 5 ifTrue: [self applyPixelateFilter].
	mosaicCount abs >= 5 ifTrue: [self applyMosaicFilter].

	blur = 0 ifFalse: [
		fOut := resultForm deepCopy.
		(blur asInteger min: 100) timesRepeat: [
			PhratchPlugin primBlur: resultForm bits into: fOut bits width: resultForm width.
			tmp := resultForm.
			resultForm := fOut.
			fOut := tmp]].
		
	cachedForm := resultForm.
	
	

]

{ #category : #private }
FilterPack >> applyWaterRippleFilter [

	| fOut ripply |
	fOut := cachedForm deepCopy.
	waterArray1 ifNil: [waterArray1 := ByteArray new: (8 * fOut width * fOut height)].
	waterArray2 ifNil: [waterArray2 := ByteArray new: (8 * fOut width * fOut height)].
	ripply := (100.0 * (waterRippleRate abs / fOut width) sqrt) asInteger max: 1.

	PhratchPlugin
		primWaterRipples1: cachedForm bits
		into: fOut bits
		width: fOut width asInteger
		dropNum: ripply
		array1: waterArray1
		array2: waterArray2.

	resultForm := fOut.

]

{ #category : #accessing }
FilterPack >> blur [

	^ blur

]

{ #category : #accessing }
FilterPack >> blur: aNumber [

	blur := aNumber within: 0 and: 100.
	reapply := true.

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

	cachedForm := nil.
	reapply := true.

]

{ #category : #filtering }
FilterPack >> filtersActive [
	"Answer true if any filters are active."

	reapply ifTrue: [^ true].
	^ (pointillizeSize ~= 0) | (waterRippleRate ~= 0)


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

	resultForm := cachedForm := nil.
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

{ #category : #accessing }
FilterPack >> pointillizeSize [

	^ pointillizeSize

]

{ #category : #accessing }
FilterPack >> pointillizeSize: aSize [

	pointillizeSize := aSize max: 0.
	reapply := true.

]

{ #category : #private }
FilterPack >> rand [
	"This is a cheap, integer random generator from the old Apple Smalltalk. It's not statistically good, but it is very fast. Answers an integer between 0 and 65535."

	randSeed ifNil: [randSeed := Time millisecondClockValue bitAnd: 65535].
	randSeed := (13849 + (27181 * randSeed)) bitAnd: 65535.
	^ randSeed

]

{ #category : #filtering }
FilterPack >> resetAllFilters [

	resultForm := cachedForm := nil.

	hueShift := 0.
	saturationShift := 0.
	brightnessShift := 0.
	mosaicCount := 0.
	pixelateCount := 0.
	fisheye := 0.
	whirl := 0.
	blur := 0.

	pointillizeSize := 0.
	pointillizeForm := nil.

	waterRippleRate := 0.
	waterArray1 := waterArray2 := nil.

]

{ #category : #accessing }
FilterPack >> resultForm [

	^ resultForm

]

{ #category : #accessing }
FilterPack >> saturationShift [

	^ saturationShift

]

{ #category : #accessing }
FilterPack >> saturationShift: aNumber [

	saturationShift := aNumber.
	reapply := true.

]

{ #category : #accessing }
FilterPack >> waterRippleRate [

	^ waterRippleRate

]

{ #category : #accessing }
FilterPack >> waterRippleRate: rate [
	
	waterRippleRate := rate max: 0.
	reapply := true.

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
