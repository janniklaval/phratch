Class {
	#name : #PhratchCategory,
	#superclass : #Object,
	#classInstVars : [
		'Visible'
	],
	#category : #'Phratch-Categories'
}

{ #category : #'as yet unclassified' }
PhratchCategory class >> color [
	^(Color h: 0 s: 0.81 v: 0.83)
]

{ #category : #'as yet unclassified' }
PhratchCategory class >> label [
	^'Generic Category'
]

{ #category : #'as yet unclassified' }
PhratchCategory class >> order [
	^0
]

{ #category : #'as yet unclassified' }
PhratchCategory class >> viewerPageFor: aScriptablePhratchMorph [
	| bin x y |
	bin := PhratchBlockPaletteMorph new.
	x := 12.
	y := 10.
	(aScriptablePhratchMorph blocksFor: self label) do: [:blockOrSym |
		(blockOrSym = #-) | (blockOrSym = #~) | (blockOrSym = #=)
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

{ #category : #'as yet unclassified' }
PhratchCategory class >> visible [
	Visible ifNil: [ Visible := true ].
	^Visible.
]

{ #category : #'as yet unclassified' }
PhratchCategory class >> visible: aBoolean [
	Visible := aBoolean
]
