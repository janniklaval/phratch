Extension { #name : #PhratchSpriteMorph }

{ #category : #'*PhratchColor' }
PhratchSpriteMorph >> color: sensitiveColor sees: soughtColor [
	"Return true if any of my pixels of sensitiveColor intersect with pixels of soughtColor in the world."
	<phratchItem: 'color $ScreenColor$ is touching $ScreenColor$?' kind: #BooleanBlockMorph category: 'sensing' defaultValues: #() subCategory: #sensor special: #()>
	| r myImage sensitivePixelsMask map index imageBelowMe result |
	r := self bounds intersect: owner bounds.
	r area = 0 ifTrue: [^ false].

	"make a mask with 1 where pixel = sensitiveColor, 0 elsewhere"
	myImage := self imageForm asFormOfDepth: 16.
	sensitivePixelsMask := Form extent: myImage extent depth: 1.
	map := Bitmap new: (1 bitShift: (myImage depth min: 15)).
	map at: (index := sensitiveColor indexInMap: map) put: 1.
	sensitivePixelsMask
		copyBits: ((r origin - self position) extent: r extent)
		from: myImage form
		at: 0@0
		colorMap: map.

	"grab an image of the world below me"
	imageBelowMe := owner patchAt: r without: self andNothingAbove: false.

	"intersect world pixels of the color we're looking for with sensitive pixels mask"
	map at: index put: 0.  "clear map and reuse it"
	map at: (soughtColor indexInMap: map) put: 1.

	sensitivePixelsMask
		copyBits: imageBelowMe boundingBox
		from: imageBelowMe at: 0@0 clippingBox: imageBelowMe boundingBox
		rule: Form and
		fillColor: nil
		map: map.
	result := (sensitivePixelsMask tallyPixelValues at: 2) > 0.
	result ifTrue: [^true].
	^(subsprites collect: [:sub | sub color: sensitiveColor sees: soughtColor ]) includes: true 


]

{ #category : #'*PhratchColor' }
PhratchSpriteMorph >> touchingColor: soughtColor [
	"Answer true if any of my non-transparent pixels touch pixels of the given color in the world."
	<phratchItem: 'touching color $ScreenColor$?' kind: #BooleanBlockMorph category: 'sensing' defaultValues: #() subCategory: #sensor special: #()>
	| r myImage sensitivePixelsMask map imageBelowMe result |
	r := self bounds intersect: owner bounds.
	r area = 0 ifTrue: [^ false].

	"make a mask with 0 where transparent, 1 elsewhere"
	myImage := self imageForm asFormOfDepth: 16.
	sensitivePixelsMask := Form extent: myImage extent depth: 1.
	map := Bitmap new: (1 bitShift: (myImage depth min: 15)).
	map atAllPut: 1.
	map at: (Color transparent indexInMap: map) put: 0.
	sensitivePixelsMask
		copyBits: ((r origin - self position) extent: r extent)
		from: myImage form
		at: 0@0
		colorMap: map.

	"grab an image of the world below me"
	imageBelowMe := owner patchAt: r withoutWatchersAnd: self andNothingAbove: false.

	"intersect world pixels of the color we're looking for with sensitive pixels mask"
	map atAllPut: 0.  "clear map and reuse it"
	map at: (soughtColor indexInMap: map) put: 1.
	sensitivePixelsMask
		copyBits: imageBelowMe boundingBox
		from: imageBelowMe at: 0@0 clippingBox: imageBelowMe boundingBox
		rule: Form and
		fillColor: nil
		map: map.

	result := (sensitivePixelsMask tallyPixelValues at: 2) > 0.  "true if any pixels are 1"
	result ifTrue: [^true].
	^(subsprites collect: [:sub | sub touchingColor: soughtColor ]) includes: true.


]
