Class {
	#name : #PhratchCategoryMinecraft,
	#superclass : #PhratchCategory,
	#category : #MinecraftPhratch
}

{ #category : #'as yet unclassified' }
PhratchCategoryMinecraft class >> color [

	^ Color blue
]

{ #category : #'as yet unclassified' }
PhratchCategoryMinecraft class >> label [

	^ 'minecraft'
]

{ #category : #'as yet unclassified' }
PhratchCategoryMinecraft class >> order [

	^99
]

{ #category : #'as yet unclassified' }
PhratchCategoryMinecraft class >> viewerPageFor: aScriptablePhratchMorph [

		"Answer a morph containing my variables."

	| page x y maxX addButton |
	page := PhratchBlockPaletteMorph new
		color: (Color r: 0.8 g: 0.8 b: 1.0);
		borderWidth: 0.

	addButton := PhratchFrameMorph
		buttonLabel: 'Create Minecraft sprite' localized
		selector: #addMinecraft.
	
	x := 13.
	y:= 10.
	page addMorph: (addButton target: aScriptablePhratchMorph; position: x@7).
	y := addButton bottom + 3.

	"aScriptablePhratchMorph addGenericEv3BlocksTo: page x: x y: y."
	
	(aScriptablePhratchMorph blocksFor: self label) do: [:blockOrSym |
		(blockOrSym = #-) | (blockOrSym = #=) | (blockOrSym = #~)
			ifTrue: [
				(blockOrSym = #-) | (blockOrSym = #=) ifTrue: [
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
