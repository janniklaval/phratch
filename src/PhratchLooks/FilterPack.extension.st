Extension { #name : #FilterPack }

{ #category : #'*PhratchLooks' }
FilterPack >> brightnessShift [

	^ brightnessShift

]

{ #category : #'*PhratchLooks' }
FilterPack >> brightnessShift: aNumber [

	brightnessShift := aNumber within: -100 and: 100.
	reapply := true.

]

{ #category : #'*PhratchLooks' }
FilterPack >> fisheye [

	^ fisheye

]

{ #category : #'*PhratchLooks' }
FilterPack >> fisheye: aNumber [

	fisheye := aNumber.
	reapply := true.

]

{ #category : #'*PhratchLooks' }
FilterPack >> hueShift [

	^ hueShift

]

{ #category : #'*PhratchLooks' }
FilterPack >> hueShift: aNumber [

	hueShift := aNumber \\ 200.
	reapply := true.

]

{ #category : #'*PhratchLooks' }
FilterPack >> mosaicCount [

	^ mosaicCount

]

{ #category : #'*PhratchLooks' }
FilterPack >> mosaicCount: aNumber [

	mosaicCount := aNumber.
	reapply := true.

]

{ #category : #'*PhratchLooks' }
FilterPack >> pixelateCount [

	^ pixelateCount

]

{ #category : #'*PhratchLooks' }
FilterPack >> pixelateCount: aNumber [

	pixelateCount := aNumber.
	reapply := true.

]

{ #category : #'*PhratchLooks' }
FilterPack >> whirl [

	^ whirl

]

{ #category : #'*PhratchLooks' }
FilterPack >> whirl: aNumber [

	whirl := aNumber.
	reapply := true.

]
