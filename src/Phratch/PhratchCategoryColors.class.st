Class {
	#name : #PhratchCategoryColors,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #accessing }
PhratchCategoryColors class >> color [
	^(Color h: 0 s: 0 v: 0.25)
]

{ #category : #accessing }
PhratchCategoryColors class >> label [
	^'colors'
]

{ #category : #accessing }
PhratchCategoryColors class >> order [
	^10
]

{ #category : #drawing }
PhratchCategoryColors class >> viewerPageFor: aScriptablePhratchMorph [
	| page addButton deleteButton showButton hideButton hasColors stage x y maxX |
	page := PhratchBlockPaletteMorph new
		color: (Color r: 0.8 g: 0.8 b: 1.0);
		borderWidth: 0;
		yourself.
	addButton := PhratchFrameMorph buttonLabel: 'make a color' localized selector: #addGlobalColor.
	(aScriptablePhratchMorph isPhratchSpriteMorph)
		ifTrue: [ addButton actionSelector: #addColor ].
	deleteButton := PhratchFrameMorph buttonLabel: 'Delete a color' localized selector: #deleteColor.
	showButton := PhratchFrameMorph buttonLabel: 'Show a color' localized selector: #showColor.
	hideButton := PhratchFrameMorph buttonLabel: 'Hide a color' localized selector: #hideColor.
	x := 13.
	page
		addMorph:
			(addButton
				target: aScriptablePhratchMorph;
				position: x @ 7;
		yourself).
	y := addButton bottom + 3.
	hasColors := aScriptablePhratchMorph colorNames size > 0.
	(stage := aScriptablePhratchMorph ownerThatIsAPhratchStageMorph)
		ifNotNil: [ 
			stage colorNames size > 0
				ifTrue: [ hasColors := true ] ].
	hasColors
		ifTrue: [ 
			page
				addMorph:
					(deleteButton
						target: aScriptablePhratchMorph;
						position: x @ y;
		yourself).
			y := deleteButton bottom + 3.
			page
				addMorph:
					(showButton
						target: aScriptablePhratchMorph;
						position: x @ y;
		yourself).
			y := showButton bottom + 3.
			page
				addMorph:
					(hideButton
						target: aScriptablePhratchMorph;
						position: x @ y;
		yourself).
			y := hideButton bottom + 10 ].
	
	(aScriptablePhratchMorph blocksFor: self label) do: [:blockOrSym |
		({#- . #~ } includes: blockOrSym)
			ifTrue: [
				(blockOrSym = #-) ifTrue: [y := y + 15].  "insert a full space"
				(blockOrSym = #~) ifTrue: [y := y + 5].  "insert a half space"
			]  "insert a line"
			ifFalse: [
				y := aScriptablePhratchMorph createBlock: blockOrSym atPosition: x@y onPage: page.
				page submorphs last color: (PhratchCategory blockColorFor: self label)
			]].
	
	
	
	maxX := page submorphs inject: 0 into: [ :t :m | t max: m right ].
	page extent: (maxX + 10) @ y.
	^ page
]
