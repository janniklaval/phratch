Class {
	#name : #PhratchCategoryEv3More,
	#superclass : #PhratchCategory,
	#category : #EV3Phratch
}

{ #category : #'as yet unclassified' }
PhratchCategoryEv3More class >> color [
	^Color darkGray
]

{ #category : #'as yet unclassified' }
PhratchCategoryEv3More class >> label [
	^'ev3-exp'
]

{ #category : #'as yet unclassified' }
PhratchCategoryEv3More class >> order [
	^99
]

{ #category : #'as yet unclassified' }
PhratchCategoryEv3More class >> viewerPageFor: aScriptablePhratchMorph [

		"Answer a morph containing my variables."

	| page x y maxX |
	page := PhratchBlockPaletteMorph new
		color: (Color r: 0.8 g: 0.8 b: 1.0);
		borderWidth: 0.

	"addButton := PhratchFrameMorph
		buttonLabel: 'Connect Ev3' localized
		selector: #addEv3."
	
	x := 13.
	y:= 10.
	"page addMorph: (addButton target: aScriptablePhratchMorph; position: x@7).
	y := addButton bottom + 3."
	
	(aScriptablePhratchMorph blocksFor: self label) do: [:blockOrSym |
		(blockOrSym = #-) | (blockOrSym = #~)
			ifTrue: [
				(blockOrSym = #-) ifTrue: [
					y := y + 7.
					page addMorph: ((ImageMorph new form: (PhratchFrameMorph skinAt: #connector)) position: x@y).
					y := y + 20
					"y := y + 15"].	"insert a full space"
				(blockOrSym = #~) ifTrue: [y := y + 5]]	"insert a half space"
			ifFalse: [
				y := aScriptablePhratchMorph createBlock: blockOrSym atPosition: x@y onPage: page.
				page submorphs last color: (PhratchCategory blockColorFor: self label)]].
	
	
	
	maxX := page submorphs inject: 0 into: [:t :m | t max: m right].
	page extent: (maxX + 10) @ y.
	^ page

]
