Extension { #name : #Form }

{ #category : #'*Phratch-Extensions' }
Form >> colorNoAlphaAt: aPoint [
	"Answer the color in the pixel at the given point, ignoring alpha."

	^ Color colorFromPixelValue: (self pixelValueNoAlphaAt: aPoint) depth: depth

]

{ #category : #'*Phratch-Extensions' }
Form >> colorReduced8Bit [
	"Return an 8-bit ColorForm version of the receiver."

	| tally tallyDepth colorCount newForm cm oldPixelValues newFormColors nextColorIndex c |
	tally := self tallyPixelValues asArray.
	tallyDepth := (tally size log: 2) asInteger.
	colorCount := 0.
	tally do: [:n | n > 0 ifTrue: [colorCount := colorCount + 1]].
	(tally at: 1) = 0 ifTrue: [colorCount := colorCount + 1].  "include transparent even if it's not used"
	colorCount > 256 ifTrue: [^ self].  "cannot reduce"
	newForm := ColorForm extent: self extent depth: 8.

	"build an array of just the colors used, and a color map to translate
	 old pixel values to their indices into this color array"
	cm := Bitmap new: tally size.
	oldPixelValues := self colormapIfNeededForDepth: 32.
	newFormColors := Array new: colorCount.
	newFormColors at: 1 put: Color transparent.
	nextColorIndex := 2.
	2 to: cm size do: [:i |
		(tally at: i) > 0 ifTrue: [
			oldPixelValues = nil
				ifTrue: [c := Color colorFromPixelValue: i - 1 depth: tallyDepth]
				ifFalse: [c := Color colorFromPixelValue: (oldPixelValues at: i) depth: 32].
			newFormColors at: nextColorIndex put: c.
			cm at: i put: nextColorIndex - 1.  "pixel values are zero-based indices"
			nextColorIndex := nextColorIndex + 1]].

	"copy pixels into new ColorForm, mapping to new pixel values"
	newForm copyBits: self boundingBox
		from: self
		at: 0@0
		clippingBox: self boundingBox
		rule: Form over
		fillColor: nil
		map: cm.
	newForm colors: newFormColors.
	newForm offset: offset.
	^ newForm
]

{ #category : #'*Phratch-Extensions' }
Form >> couldBeColorReduced [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Form >> equals: aForm [
	"Answer true if the receiver is exactly the same as the given Form."

	self == aForm ifTrue: [^ true].

	self class = aForm class ifFalse: [^ false].
	self class = ColorForm ifTrue: [
		self colors = aForm colors  ifFalse: [^ false]].
	(width = aForm width) & (height = aForm height) ifFalse: [^ false].
	(depth = aForm depth) & (offset = aForm privateOffset) ifFalse: [^ false].

	bits class = aForm bits class ifFalse: [
		self hibernate.
		aForm hibernate].
	^ bits = aForm bits

]

{ #category : #'*Phratch-Extensions' }
Form >> fillRadialFromXColorBlock: colorBlock center: aPoint [
	"Horizontal Gradient Fill. Supply relative x in [0.0 ... 1.0] to colorBlock, and paint each pixel with the color that comes back."

	| canvas m div t |
	canvas := self getCanvas.
	self fill: self boundingBox fillColor: (colorBlock value: 1).
	m := width max: height.
	m > 1 ifFalse: [^ self].

	div := (m - 1) asFloat.
	(m - 1) negated to: 0 do: [:x |
		t := x abs.  
		canvas
			frameOval: (Rectangle center: aPoint extent: t@t)
			color: (colorBlock value: t asFloat / div)].

]

{ #category : #'*Phratch' }
Form >> hibernateForPhratch [

	self hibernate
]

{ #category : #'*Phratch-Extensions' }
Form >> oneBitShapeFill: aColor interiorPoint: aPoint [

	depth > 1 ifTrue: [self error: 'This call only meaningful for 1-bit forms'].

	(self findShapeAroundSeedBlock: [:f | f pixelValueAt: aPoint put: 1])
		displayOn: self
		at: 0@0
		clippingBox: self boundingBox
		rule: Form under
		fillColor: aColor.

]

{ #category : #'*Phratch' }
Form >> outlineEmbeddedAdjustedColor: color [

	| outline outTop outBottom w |

	w := 1.
	outline := self
		outlineWidth: w
		color: color
		depth: 8.

	outTop := outline copy: (0@0 extent: (outline extent x @ (outline extent y / 3))).
	outBottom := outline copy: (0@(outline extent y * 2 / 3 - 1) corner: outline extent + 1).

	outTop replaceColor: color withColor: color darker slightlyDarker.
	outBottom replaceColor: color withColor: color twiceLighter lighter slightlyLighter.

	(WarpBlt toForm: outline)
		sourceForm: outTop;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: outTop boundingBox corners toRect: outTop boundingBox.

	(WarpBlt toForm: outline)
		sourceForm: outBottom;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: outBottom boundingBox corners toRect: (0@(outline extent y * 2 / 3) rounded extent: outBottom extent).

	^ outline



]

{ #category : #'*Phratch' }
Form >> outlineEmbeddedColor: color width: w [

	| outline outTop outBottom |

	outline := self
		outlineWidth: w
		color: color
		depth: 8.

	outTop := outline copy: (0@0 extent: (outline extent x @ (outline extent y / 3))).
	outBottom := outline copy: (0@(outline extent y * 2 / 3 "- 1") corner: outline extent "+ 1").

	outTop replaceColor: color withColor: color darker slightlyDarker.
	outBottom replaceColor: color withColor: color twiceLighter lighter slightlyLighter.

	(WarpBlt toForm: outline)
		sourceForm: outTop;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: outTop boundingBox corners toRect: outTop boundingBox.

	(WarpBlt toForm: outline)
		sourceForm: outBottom;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: outBottom boundingBox corners toRect: (0@(outline extent y * 2 / 3) rounded extent: outBottom extent).

	^ outline



]

{ #category : #'*Phratch' }
Form >> outlineHalfEmbeddedAdjustedColor: color [

	| outline outTop outBottom w |

	w := 1.
	outline := self
		outlineWidth: w
		color: color
		depth: 8.

	outTop := outline copy: (0@0 extent: (outline extent x @ (outline extent y / 2) rounded)).
	outBottom := outline copy: (0@(outline extent y * 1 / 2 - 1) rounded corner: outline extent + 1).

	outTop replaceColor: color withColor: color darker slightlyDarker.
	outBottom replaceColor: color withColor: color twiceLighter lighter slightlyLighter.

	(WarpBlt toForm: outline)
		sourceForm: outTop;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: outTop boundingBox corners toRect: outTop boundingBox.

	(WarpBlt toForm: outline)
		sourceForm: outBottom;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: outBottom boundingBox corners toRect: (0@(outline extent y * 1 / 2) rounded extent: outBottom extent).

	^ outline



]

{ #category : #'*Phratch' }
Form >> outlineRaisedColor: color width: w [

	| outline outTop outBottom |

	outline := self
		outlineWidth: w
		color: color
		depth: 8.

	outTop := outline copy: (0@0 extent: (outline extent x @ (outline extent y / 3) rounded )).
	outBottom := outline copy: (0@(outline extent y * 2 / 3 - 1) rounded corner: outline extent + 1).

	outTop replaceColor: color withColor: color twiceLighter lighter slightlyLighter.
	outBottom replaceColor: color withColor: color darker slightlyDarker.

	(WarpBlt toForm: outline)
		sourceForm: outTop;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: outTop boundingBox corners toRect: outTop boundingBox.

	(WarpBlt toForm: outline)
		sourceForm: outBottom;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: outBottom boundingBox corners toRect: (0@(outline extent y * 2 / 3) rounded extent: outBottom extent).

	^ outline



]

{ #category : #'*Phratch-Extensions' }
Form >> outlineWidth: w color: outlineColor depth: resultDepth [
	"Answer a Form containing the outline of this Form."

	| mask cm outline neg result |
	"make a mask form with black for all non-transparent pixels"
	mask := Form extent: (self extent + w + w) depth: 2.
	cm := self newColorMap.
	cm atAllPut: (Color black pixelValueForDepth: mask depth).
	cm at: 1 put: 0.
	mask copyBits: self boundingBox from: self at: w@w colorMap: cm.

	"stamp the mask form onto a new form at various offsets"
	outline := Form extent: mask extent depth: mask depth.
	1 to: w do: [:pos |
		neg := pos negated.
		mask displayOn: outline at: pos@0 rule: Form paint.
		mask displayOn: outline at: neg@0 rule: Form paint.
		mask displayOn: outline at: 0@pos rule: Form paint.
		mask displayOn: outline at: 0@neg rule: Form paint.
		mask displayOn: outline at: pos@pos rule: Form paint.
		mask displayOn: outline at: pos@neg rule: Form paint.
		mask displayOn: outline at: neg@pos rule: Form paint.
		mask displayOn: outline at: neg@neg rule: Form paint].

	"cut out a hole with the original form"
	mask displayOn: outline at: 0@0 rule: Form erase.

	"copy the outline in the desired color onto the result form"
	result := Form extent: mask extent depth: resultDepth.
	cm := outline newColorMap.
	cm
		at: (Color black pixelValueForDepth: outline depth) + 1
		put: (outlineColor pixelValueForDepth: result depth).
	result copyBits: outline boundingBox from: outline at: 0@0 colorMap: cm.
	^ result

]

{ #category : #'*Phratch-Extensions' }
Form >> pixelValueNoAlphaAt: aPoint [ 
	"Answer the raw pixel value at the given point. The pixel value depends on the receiver's depth. If the depth is 32 and the pixel is not transparent, ignore alpha."

	| pixel |
	depth < 32 ifTrue: [^ self pixelValueAt: aPoint].
	pixel := (BitBlt bitPeekerFromForm: self) pixelAt: aPoint.
	pixel > 0 ifTrue: [pixel := pixel bitOr: 16rFF000000].  "treat as opaque"
	^ pixel

]

{ #category : #'*Phratch-Extensions' }
Form >> privateOffset [

	^ offset
]

{ #category : #'*Phratch-Extensions' }
Form >> shapeFillGradientFrom: fromColor to: toColor at: aPoint type: aSymbol [
	"Fill the area of similar colors around the given point with a gradient of the given type."

	| mapDepth maskForm map r newForm c |
	mapDepth := 9.  "can be 9 or 12"
	depth = 1 ifTrue: [^ self oneBitShapeFill: fromColor interiorPoint: aPoint].

	"map this form into a B/W mask form with 0's in areas of matching color"
	maskForm := Form extent: self extent depth: 1.
	map := Bitmap new: (1 bitShift: (depth min: mapDepth)) withAll: 1.
	depth <= 8
		ifTrue: [
			map at: (self pixelValueAt: aPoint) + 1 put: 0]
		ifFalse: [
			c := self colorNoAlphaAt: aPoint.
			map at: (c pixelValueForDepth: mapDepth) + 1 put: 0].
	maskForm copyBits: self boundingBox from: self at: 0@0 colorMap: map.

	"now fill the shape"
	maskForm := maskForm findShapeAroundSeedBlock:
		[:form | form pixelValueAt: aPoint put: 1].

	r := maskForm rectangleEnclosingPixelsNotOfColor: Color white.
	r area = 0 ifTrue:[^ self].  "zero width or height"

	newForm := Form extent: r extent depth: 32.
	aSymbol = #radial
		ifTrue: [
			newForm
				fillRadialFromXColorBlock: [:m | toColor mixed: m with: fromColor]
				center: aPoint - r origin]
		ifFalse: [
			aSymbol = #horizontal
				ifTrue: [newForm fillFromXColorBlock: [:m | toColor mixed: m with: fromColor]]
				ifFalse: [newForm fillFromYColorBlock: [:m | toColor mixed: m with: fromColor]]].

	"use the mask to cut out the shape"
	((BitBlt destForm: newForm sourceForm: maskForm
		fillColor: nil
		combinationRule: Form erase1bitShape	"Cut a hole in the picture with my mask"
		destOrigin: maskForm offset 
		sourceOrigin: r origin
		extent: self extent clipRect: self boundingBox)
			colorMap: (Bitmap with: 16rFFFFFFFF with: 0))
			copyBits.

	"copy the masked gradient shape into myself"
	self copy: newForm boundingBox
		from: newForm
		to: r origin
		rule: Form paint.
]

{ #category : #'*Phratch' }
Form >> toThumbnail: extent borderWidth: borderWidth borderColor: backgroundColor [
	"Answer a thumbnail with the specified extent, border width, and background color."

	| result e r p |
	result := Form extent: extent depth: 16.
	result fillColor: backgroundColor.
	result border: result boundingBox width: borderWidth.

	"calculate the rectangle to be used by the thumbnail image"
	self width > self height
		ifTrue: [e := result width @ ((self height * result width) // self width)]
		ifFalse: [e := ((self width * result height) // self height) @ result height].
	p := (result extent - e) // 2.
	r := p extent: e.

	(WarpBlt toForm: result)
		sourceForm: self;
		cellSize: 2;  "do smoothing; this also installs a colormap"
		combinationRule: Form over;
		copyQuad: self boundingBox innerCorners toRect: (r insetBy: (borderWidth + 1)).

	^ result


]

{ #category : #'*Phratch' }
Form >> withEmbeddedOutlineColor: color width: w [

	| outline |
	outline := self outlineEmbeddedColor: color width: w.
	(WarpBlt toForm: outline)
		sourceForm: self;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: outline boundingBox innerCorners toRect: (outline boundingBox translateBy: w).
	^outline
]

{ #category : #'*Phratch' }
Form >> withHalfEmbeddedOutlineColor: color [ 

	| outline |
	outline := self outlineHalfEmbeddedAdjustedColor: color.
	(WarpBlt toForm: outline)
		sourceForm: self;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: outline boundingBox innerCorners toRect: (outline boundingBox translateBy: 1).
	^outline
]

{ #category : #'*Phratch' }
Form >> withOutlineColor: aColor width: anInteger [

	| outline |
	outline := self
		outlineWidth: anInteger
		color: aColor
		depth: 8.
	(WarpBlt toForm: outline)
		sourceForm: self;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: outline boundingBox innerCorners toRect: (outline boundingBox translateBy: anInteger).
	^outline

]

{ #category : #'*Phratch' }
Form >> withRaisedOutlineColor: color width: w [

	| outline |
	outline := self outlineRaisedColor: color width: w.
	(WarpBlt toForm: outline)
		sourceForm: self;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: outline boundingBox innerCorners toRect: (outline boundingBox translateBy: w).
	^outline
]

{ #category : #'*Phratch-Extensions' }
Form >> writeBMPFileNamed: fName [
	"Display writeBMPfileNamed: 'display.bmp'"

	| fileName bhSize biSize biClrUsed bfOffBits rowBytes biSizeImage f colorValues rgb data |
	self unhibernate.
	depth = 2 ifTrue: [(self asFormOfDepth: 4) writeBMPFileNamed: fName. ^ self].
	depth = 16 ifTrue: [(self asFormOfDepth: 32) writeBMPFileNamed: fName. ^ self].

	(#(1 4 8 32) includes: depth) ifFalse: [self error: 'BMP file depth must be 1, 4, 8, or 32'].
	((fileName := fName) asUppercase endsWith: '.BMP')
		ifFalse: [fileName := fName , '.BMP'].
	bhSize := 14.		"# bytes in file header"
	biSize := 40.		"info header size in bytes"
	biClrUsed := depth = 32 ifTrue: [0] ifFalse: [1 << depth].	"number of color table entries"
	bfOffBits := biSize + bhSize + (4*biClrUsed).
	rowBytes := ((depth min: 24) * width + 31 // 32) * 4.
	biSizeImage := height * rowBytes.

 	f := StandardFileStream newPhratchFileNamed: fileName.
	f ifNil: [^ self].
	f binary.

	"write the file header"
	f position: 0.
	f littleEndianUint16: 19778.			"bfType = BM"
	f littleEndianUint32: bfOffBits + biSizeImage.	"total file size in bytes"
	f littleEndianUint32: 0.				"bfReserved"
	f littleEndianUint32: bfOffBits.		"offset of bitmap data from start of hdr (and file)"

	"write the bitmap info header"
	f position: bhSize.
	f littleEndianUint32: biSize.			"info header size in bytes"
	f littleEndianUint32: width.			"biWidth"
	f littleEndianUint32: height.			"biHeight"
	f littleEndianUint16: 1.				"biPlanes"
	f littleEndianUint16: (depth min: 24).	"biBitCount"
	f littleEndianUint32: 0.				"biCompression"
	f littleEndianUint32: biSizeImage.		"size of image section in bytes"
	f littleEndianUint32: 2800.			"biXPelsPerMeter"
	f littleEndianUint32: 2800.			"biYPelsPerMeter"
	f littleEndianUint32: biClrUsed.
	f littleEndianUint32: 0.				"biClrImportant"

	biClrUsed > 0 ifTrue: [
		"write color map; this works for ColorForms, too"
		colorValues := self colormapIfNeededForDepth: 32.
		1 to: biClrUsed do: [:i |
			rgb := colorValues at: i.
			0 to: 24 by: 8 do: [:j | f nextPut: (rgb >> j bitAnd: 16rFF)]]].

	'Writing image data' displayProgressAt: Sensor cursorPoint
		from: 1 to: height during: [:bar |
			1 to: height do: [:i |
				bar value: i.
				data := (self copy: (0@(height-i) extent: width@1)) bits.
				depth = 32
				ifTrue: [
					1 to: data size do: [:j | f littleEndianUint24: ((data at: j) bitAnd: 16rFFFFFF)].
					1 to: (data size*3)+3//4*4-(data size*3) do: [:j | f nextPut: 0 "pad to 32-bits"]]
				ifFalse: [
					1 to: data size do: [:j | f int32: (data at: j)]]]].
	f position = (bfOffBits + biSizeImage) ifFalse: [self halt].
	f close.
]

{ #category : #'*Phratch-Extensions' }
Form >> writeGIFFileNamed: fName [

	GIFReadWriter putForm: self onFileNamed: fName.

]
