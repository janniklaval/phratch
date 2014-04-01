Class {
	#name : #PhratchCategoryMotion,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #accessing }
PhratchCategoryMotion class >> color [
	^(Color h: 225 s: 0.65 v: 0.83)
]

{ #category : #accessing }
PhratchCategoryMotion class >> label [
	^'motion'
]

{ #category : #accessing }
PhratchCategoryMotion class >> order [
	^1
]

{ #category : #drawing }
PhratchCategoryMotion class >> viewerPageFor: aScriptablePhratchMorph [ 

		| bin isStage font x y m |
	bin := PhratchBlockPaletteMorph new.

	(aScriptablePhratchMorph isPhratchStageMorph)
		ifTrue: [
			isStage := true.
			]
		ifFalse: [
			isStage := false.
			aScriptablePhratchMorph ownerOrYourselfThatIsAPhratchStageMorph.
			].

	(isStage) ifTrue: [
		font := (PhratchFrameMorph getFont: #ViewerPage).
		x := 20.
		y := 12.
		m := StringMorph contents: 'Stage selected:' localized font: font.
		bin addMorph: (m color: Color white; position: x@y;
		yourself).
		m := StringMorph contents: 'No motion blocks' localized font: font.
		bin addMorph: (m color: Color white; position: x@(y + 17);
		yourself).
		^ bin].

	x := 12.
	y := 10.
	(aScriptablePhratchMorph blocksFor: 'motion') do: [:blockOrSym |
		({#- . #~ . #=} includes: blockOrSym)
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
