Class {
	#name : #PhratchCategoryPure,
	#superclass : #PhratchCategory,
	#category : #PhratchPure
}

{ #category : #'as yet unclassified' }
PhratchCategoryPure class >> color [
	^(Color h: 220 s: 0.85 v: 0.725)
]

{ #category : #'as yet unclassified' }
PhratchCategoryPure class >> label [
	^'pure'
]

{ #category : #'as yet unclassified' }
PhratchCategoryPure class >> order [
	^11
]

{ #category : #'as yet unclassified' }
PhratchCategoryPure class >> viewerPageFor: aScriptablePhratchMorph [

		"Answer a morph containing my variables."

	| page "addButton" x y maxX "addButton2" |
	page := PhratchBlockPaletteMorph new
		color: (Color r: 0.8 g: 0.8 b: 1.0);
		borderWidth: 0.
"
	addButton := PhratchFrameMorph
		buttonLabel: 'Make kompai1' localized
		selector: #addKompai1.

	addButton2 := PhratchFrameMorph
		buttonLabel: 'Make kompai2' localized
		selector: #addKompai2.
	"
	x := 13.
	"page addMorph: (addButton target: aScriptablePhratchMorph; position: x@7).
	y := addButton bottom + 3.
	
	y := y + 0.
	page addMorph: (addButton2 target: aScriptablePhratchMorph; position: x@30).
	y := addButton2 bottom + 3."
	y:= 3.
	aScriptablePhratchMorph addGenericPureBlocksTo: page x: x y: y.
	maxX := page submorphs inject: 0 into: [:t :m | t max: m right].
	page extent: (maxX + 10) @ y.
	^ page

]
