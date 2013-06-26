Class {
	#name : #PhratchCategorySensing,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #'as yet unclassified' }
PhratchCategorySensing class >> color [
	^(Color h: 200 s: 0.98 v: 0.86)
]

{ #category : #'as yet unclassified' }
PhratchCategorySensing class >> label [
	^'sensing'
]

{ #category : #'as yet unclassified' }
PhratchCategorySensing class >> order [
	^4
]

{ #category : #'as yet unclassified' }
PhratchCategorySensing class >> viewerPageFor: aScriptablePhratchMorph [ 

	| bin x y |
	bin := PhratchBlockPaletteMorph new.
	x := 12.
	y := 10.
	(aScriptablePhratchMorph blocksFor: 'sensing') do: [:blockOrSym |
		(blockOrSym = #-) | (blockOrSym = #~) |  (blockOrSym = #=)
			ifTrue: [
				(blockOrSym = #-) ifTrue: [y := y + 15].  "insert a full space"
				(blockOrSym = #~) ifTrue: [y := y + 5].  "insert a half space"
				(blockOrSym = #=) ifTrue: [
					y := y + 7.
					bin addMorph: ((ImageMorph new form: (PhratchFrameMorph skinAt: #connector)) position: x@y).
					y := y + 20]]  "insert a line"
			ifFalse: [
				y := aScriptablePhratchMorph createBlock: blockOrSym atPosition: x@y onPage: bin]].

	^ bin

]
