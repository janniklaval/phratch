"
I represent the Looks category of phratch
"
Class {
	#name : #PhratchCategoryLooks,
	#superclass : #PhratchCategory,
	#category : #PhratchLooks
}

{ #category : #accessing }
PhratchCategoryLooks class >> color [
	^(Color h: 264 s: 0.62 v: 0.89)
]

{ #category : #accessing }
PhratchCategoryLooks class >> label [
	^'looks'
]

{ #category : #accessing }
PhratchCategoryLooks class >> objectInterface [

	^ 
	{	"attribute					category		getter				setter				menu string			inheritable"
		#costumes			->	#(	looks			costumes			-					'costumes'			+			).
		#costumeIndex		->	#(	looks			costumeIndex		lookLike:			'costume #'			+			).
		#size				->	#(	looks			scale				setSizeTo:			'size'				+			).
		#isHidden			->	#(	looks			isHidden				setHideFlagTo:		'hidden?'			+			).
		#layer				->	#(	looks			layer				setLayerTo:			'layer'				+			).
																									
																									#color				->	#(	effects			colorEffect			colorEffect:			'color effect'		+			).
		#fisheye			->	#(	effects			fisheyeEffect		fisheyeEffect:		'fisheye effect'		+			).
		#whirl				->	#(	effects			whirlEffect			whirlEffect:			'whirl effect'		+			).
		#pixelate			->	#(	effects			pixelateEffect		pixelateEffect:		'pixelate effect'		+			).
		#mosaic				->	#(	effects			mosaicEffect		mosaicEffect:		'mosaic effect'		+			).
		#brightness			->	#(	effects			brightnessEffect		brightnessEffect:	'brightness'			+			).
		#ghost				->	#(	effects			transparencyEffect	transparencyEffect:	'ghost effect'		+			).
	} asDictionary
]

{ #category : #accessing }
PhratchCategoryLooks class >> order [
	^3
]
