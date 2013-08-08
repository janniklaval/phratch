Class {
	#name : #PhratchCategory,
	#superclass : #Object,
	#classInstVars : [
		'visible'
	],
	#category : #'Phratch-Categories'
}

{ #category : #accessing }
PhratchCategory class >> color [
	^(Color h: 0 s: 0.81 v: 0.83)
]

{ #category : #drawing }
PhratchCategory class >> initialize [
	visible  := true
]

{ #category : #accessing }
PhratchCategory class >> label [
	^'Generic Category'
]

{ #category : #accessing }
PhratchCategory class >> order [
	^0
]

{ #category : #drawing }
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

{ #category : #drawing }
PhratchCategory class >> visible [
	visible ifNil: [ visible := true ].
	^visible.
]

{ #category : #drawing }
PhratchCategory class >> visible: aBoolean [
	visible := aBoolean
]
