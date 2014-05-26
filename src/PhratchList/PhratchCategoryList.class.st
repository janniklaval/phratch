Class {
	#name : #PhratchCategoryList,
	#superclass : #PhratchCategory,
	#category : #PhratchList
}

{ #category : #accessing }
PhratchCategoryList class >> color [
	^(Color h: 18 s: 0.92 v: 0.85)
]

{ #category : #'class initialization' }
PhratchCategoryList class >> initialize [ 	
	"self initialize"
	super initialize.
	visible  := true.
]

{ #category : #accessing }
PhratchCategoryList class >> label [
	^'list'
]

{ #category : #accessing }
PhratchCategoryList class >> order [
	^8.5
]

{ #category : #accessing }
PhratchCategoryList class >> viewerPageFor: aScriptablePhratchMorph [ 

	"Answer a morph containing my variables."

	| page      y maxX |
	page := PhratchBlockPaletteMorph new
		color: (Color r: 0.8 g: 0.8 b: 1.0);
		borderWidth: 0;
		yourself.
	y := 3.
	y := aScriptablePhratchMorph addGenericListBlocksTo: page y: y.
	page updateWatcherButtonsForFrame: (aScriptablePhratchMorph ownerOrYourselfThatIsAPhratchFrameMorph).

	aScriptablePhratchMorph addCustomBlocksTo: page y: y.

	maxX := page submorphs inject: 0 into: [:t :m | t max: m right].
	page extent: (maxX + 10) @ y.
	^ page
]
