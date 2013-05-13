Extension { #name : #ScriptablePhratchMorph }

{ #category : #'*PhratchPure' }
ScriptablePhratchMorph >> addGenericPureBlocksTo: page x: x y: startY [
	"Add the generic variable blocks to the given page starting at the given y offset. Answer the new y."

	| y |
	y := startY.

	(self blocksFor: 'pure') do: [:blockOrSym |
		(blockOrSym = #-) | (blockOrSym = #~)
			ifTrue: [
				(blockOrSym = #-) ifTrue: [y := y + 15].	"insert a full space"
				(blockOrSym = #~) ifTrue: [y := y + 5]]	"insert a half space"
			ifFalse: [
				y := self createBlock: blockOrSym atPosition: x@y onPage: page.
				page submorphs last color: (ScriptablePhratchMorph blockColorFor: 'colors')]].

	^ y
]

{ #category : #'*PhratchPure' }
ScriptablePhratchMorph class >> blockColorFor: aCategory [
	"Answer the block color for the given category."

	'control' = aCategory ifTrue: [^ (Color h: 41 s: 0.85 v: 0.9)].
	'motion' = aCategory ifTrue: [^ (Color h: 225 s: 0.65 v: 0.83)].
	'motor' = aCategory ifTrue: [^ (Color h: 220 s: 0.85 v: 0.725)].
	'looks' = aCategory ifTrue: [^ (Color h: 264 s: 0.62 v: 0.89)].
	'pen' = aCategory ifTrue: [^ (Color h: 165 s: 1 v: 0.63)].
	'operators' = aCategory ifTrue: [^ (Color h: 93 s: 0.9 v: 0.76)].
	'sound' = aCategory ifTrue: [^ (Color h: 296 s: 0.66 v: 0.85)].
	'sensing' = aCategory ifTrue: [^ (Color h: 200 s: 0.98 v: 0.86)].
	'variables' = aCategory ifTrue: [^ (Color h: 25 s: 0.88 v: 0.95)].
	'list' = aCategory ifTrue: [^ ListBlockColor].
	'files' = aCategory ifTrue: [^ (Color r: 0.17254901960784313725490196078431 g: 0.47058823529411764705882352941176 b: 0.76470588235294117647058823529412)].
	'colors' = aCategory ifTrue: [^ (Color h: 0 s: 0 v: 0.25)].
	'custom' = aCategory ifTrue: [^ (Color h: 200 s: 0.2 v: 0.5)].
	'pure' = aCategory ifTrue: [^ (Color h: 220 s: 0.85 v: 0.725)].
	(#('none' 'other') includes: aCategory) ifTrue: [^ Color lightGray ].


	^ (Color h: 0 s: 0.81 v: 0.83)  "a shade of red"

]

{ #category : #'*PhratchPure' }
ScriptablePhratchMorph >> viewerPageForCategory: aCategoryName [
	"Answer a morph containing blocks for the given category for use in the given PhratchViewer."

	| bin x y |
	aCategoryName = 'variables' ifTrue: [^ self variablesPage].
	aCategoryName = 'colors' ifTrue: [^ self viewerPageForColors].
	aCategoryName = 'motion' ifTrue: [^ self viewerPageForMotion].
	aCategoryName = 'sensing' ifTrue: [^ self viewerPageForSensing].
	aCategoryName = 'pure' ifTrue: [^ self viewerPageForPure].

	bin := PhratchBlockPaletteMorph new.
	x := 12.
	y := 10.
	(self blocksFor: aCategoryName) do: [:blockOrSym |
		(blockOrSym = #-) | (blockOrSym = #~) | (blockOrSym = #=)
			ifTrue: [
				(blockOrSym = #-) ifTrue: [y := y + 15].  "insert a full space"
				(blockOrSym = #~) ifTrue: [y := y + 5].  "insert a half space"
				(blockOrSym = #=) ifTrue: [
					y := y + 7.
					bin addMorph: ((ImageMorph new form: (PhratchFrameMorph skinAt: #connector)) position: x@y).
					y := y + 20]]  "insert a line"
			ifFalse: [
				y := self createBlock: blockOrSym atPosition: x@y onPage: bin]].

	^ bin

]

{ #category : #'*PhratchPure' }
ScriptablePhratchMorph >> viewerPageForPure [
	"Answer a morph containing my variables."

	| page addButton x y maxX addButton2 |
	page := PhratchBlockPaletteMorph new
		color: (Color r: 0.8 g: 0.8 b: 1.0);
		borderWidth: 0.

	addButton := PhratchFrameMorph
		buttonLabel: 'Make kompai1' localized
		selector: #addKompai1.
	"(self isKindOf: PhratchSpritePureMorph) ifFalse: [addButton actionSelector: #addKompai1WithAlert]."

	addButton2 := PhratchFrameMorph
		buttonLabel: 'Make kompai2' localized
		selector: #addKompai2.
	"(self isKindOf: PhratchSpritePureMorph) ifFalse: [addButton actionSelector: #addKompai2WithAlert]."
	
	x := 13.
	page addMorph: (addButton target: self; position: x@7).
	y := addButton bottom + 3.
	
	y := y + 0.
	page addMorph: (addButton2 target: self; position: x@30).
	y := addButton2 bottom + 3.

	"self addGenericPureBlocksTo: page x: x y: y."
	maxX := page submorphs inject: 0 into: [:t :m | t max: m right].
	page extent: (maxX + 10) @ y.
	^ page

]
