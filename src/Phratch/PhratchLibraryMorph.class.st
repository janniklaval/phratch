"
I am a Scratch library viewer. I display thumbnails of all the Scratch objects that exist in the world including the stage. Clicking on one of these thumbnails views the associated scratch object.

"
Class {
	#name : #PhratchLibraryMorph,
	#superclass : #DividedImageFrameMorph,
	#instVars : [
		'scrollPane',
		'stagePane',
		'itemExtent',
		'spritePane',
		'buttonPane',
		'spriteLabel'
	],
	#category : #'Phratch-UI-Panes'
}

{ #category : #private }
PhratchLibraryMorph >> addThumbnailFor: aMorph [
	"Add a thumbnail for the given morph."

	| newThumbnail |
	newThumbnail := LibraryItemMorph new. 
	newThumbnail extent: itemExtent thumbWidth: 50.
	newThumbnail  target: aMorph.
	(newThumbnail target isPhratchStageMorph)
		ifTrue: [stagePane addMorph: newThumbnail]
		ifFalse: [scrollPane contents addMorphBack: newThumbnail].
	newThumbnail step.

]

{ #category : #initialization }
PhratchLibraryMorph >> buildPanes [
	"Build my scroll pane."

	| bin |
	stagePane := Morph new
		color: Color transparent;
		position: self position + (7@0);
		yourself.

	bin := PhratchSpriteLibraryMorph new
		color: Color transparent;
		borderWidth: 0;
		yourself.

	scrollPane := ScrollFrameMorph new
		color: Color transparent;
		contents: bin;
		showHorizontalScrollbar: false;
		yourself.

	spritePane := Morph new
		color: Color gray;
		position: self position;
		yourself.
	spriteLabel := self buildSpriteLabel.
	buttonPane := self makeNewSpriteButtons: (self ownerOrYourselfThatIsAPhratchFrameMorph).

	self addMorph: spritePane.
	self addMorph: spriteLabel.
	self addMorph: buttonPane.
	self addMorph: scrollPane.
	self addMorph: stagePane.

]

{ #category : #initialization }
PhratchLibraryMorph >> buildSpriteLabel [

	^ StringMorph new
		font: (PhratchFrameMorph getFont: #Tab);
		color: Color white;
		contents: 'New sprite:' localized;
		yourself

]

{ #category : #initialization }
PhratchLibraryMorph >> clearLibrary [
	"Remove all library items. My step method will re-add items for existing objects."

	| sFrame |
	stagePane removeAllMorphs.
	scrollPane contents removeAllMorphs.
	scrollPane vScrollRelative: 0.

	spriteLabel delete.
	spriteLabel := self buildSpriteLabel.

	sFrame := self ownerOrYourselfThatIsAPhratchFrameMorph.
	(sFrame isNil or:
	 [sFrame viewMode = #normal]) ifTrue: [
		self addMorph: spriteLabel].

	buttonPane delete.
	buttonPane := self makeNewSpriteButtons: sFrame.
	self addMorph: buttonPane.

	topSectionHeight := ((spriteLabel height + 10) max: 40).
	self fixLayout.

]

{ #category : #BYOB }
PhratchLibraryMorph >> doesNotUnderstand: aMessage [ 

	| sel frame |
	sel := self spriteThumbnails detect: [:tn |
		tn target objName = aMessage selector] ifNone: [nil].
	sel ifNil: [	^ super doesNotUnderstand: aMessage].

	frame := self ownerOrYourselfThatIsAPhratchFrameMorph.
	frame ifNil: [^ self].

	sel select.
	frame viewerPane target: sel target.
	sel target viewBlocksAndScriptsQuickly.
	sel childrenMenu


]

{ #category : #drawing }
PhratchLibraryMorph >> drawBackgroundOn: aCanvas [
	"Draw my background."

	| r |
	"color isTransparent ifTrue: [^ self]."
	color := Color gray darker.

	aCanvas fillRectangle: (myBox insetBy: 7) color: color.

	r := ((stagePane right + 3) @ (myBox top + topSectionHeight + 12)) extent: (1 @ (myBox height - topSectionHeight - 30)).
	aCanvas fillRectangle: r color: (Color gray: 0.3).

	r := (r origin + (1@0)) extent: (1 @ r height).
	aCanvas fillRectangle: r color: Color gray.

]

{ #category : #geometry }
PhratchLibraryMorph >> extent: aRectangle [

	| nameHeight |
	super extent: aRectangle.
	scrollPane isNil | stagePane isNil ifTrue: [^ self].
	
	nameHeight := (PhratchTranslator stringExtent: ('Sprite1' localized) font: (PhratchFrameMorph getFont: #LibraryItemName)) y.
	itemExtent := 54@(54 + nameHeight).

	stagePane width: itemExtent x + 0.
	scrollPane left: stagePane right.

	self fixLayout.

]

{ #category : #geometry }
PhratchLibraryMorph >> fixLayout [
	"Position and size thumbnails."

	| libPane x y rMargin sFrame mm |
	scrollPane isNil | stagePane isNil | spritePane isNil
		ifTrue: [ ^ self ].
	spritePane width: self width.
	spritePane height: topSectionHeight.
	spriteLabel position: (self left + 15) @ (self top + (topSectionHeight // 2) - (spriteLabel height // 2) + 3).
	sFrame := self ownerOrYourselfThatIsAPhratchFrameMorph.
	(sFrame isNil or: [ sFrame viewMode = #normal ])
		ifTrue: [ buttonPane position: (spriteLabel right + 10) @ (self top + (topSectionHeight // 2) - (buttonPane height // 2) + 3) ]
		ifFalse: [ buttonPane position: (self left + 12) @ (self top + (topSectionHeight // 2) - (buttonPane height // 2) + 3) ].
	stagePane height = self height
		ifFalse: [ stagePane height: self height ].
	scrollPane height = self height
		ifFalse: [ scrollPane height: self height - topSectionHeight ].
	scrollPane width = (self right - stagePane right)
		ifFalse: [ scrollPane width: self right - stagePane right ].
	scrollPane position: scrollPane left @ (self top + topSectionHeight + 3).
	stagePane position: stagePane left @ (self top + topSectionHeight + 3).
	libPane := scrollPane contents.
	x := libPane left + 8.
	y := libPane top + 7.
	rMargin := x + scrollPane width - 5.
	libPane submorphs
		do: [ :m | 
			x + m width > rMargin
				ifTrue: [ 
					x := libPane left + 8 .
					y := y + m height ].
			m position: x @ y.
			x := x + m width ].
	stagePane submorphCount > 0
		ifFalse: [ ^ self ].
	mm := stagePane firstSubmorph.
	mm
		position:
			stagePane topLeft + ((stagePane extent - stagePane firstSubmorph extent) // 2) + (0 @ 15) - (0 @ topSectionHeight)
]

{ #category : #initialization }
PhratchLibraryMorph >> initialize [

	super initialize.
	self buildPanes.
	self
		initFrontFromForm: (PhratchFrameMorph skinAt: 'spriteLibraryPaneFrameTransparent2')
		topSectionHeight: ((spriteLabel height + 10) max: 40).
	self middleBarLeftMargin: 0 rightMargin: 6.
	self extent: 200@100.

]

{ #category : #testing }
PhratchLibraryMorph >> isPhratchLibraryMorph [

	^ true
]

{ #category : #initialization }
PhratchLibraryMorph >> makeNewSpriteButtons: aPhratchFrameMorph [
	"Return a morph containing a set of new sprite buttons."

	| panel buttonSpecs buttons button butonExtent x |
	panel := Morph new color: Color transparent.

	buttonSpecs := #(
		"	icon name				selector					tooltip"
		(newSpritePaint			addSpecialSprite"paintSpriteMorph"		'Paint new sprite')
		(newSpriteLibrary		addSpriteMorph			'Choose new sprite from file')
		(newSpriteSurprise 	surpriseSpriteMorph		'Get surprise sprite')
		"(newSpriteLibrary 		addSpecialSprite		'Choose a special sprite')"
	).

	buttons := buttonSpecs collect: [:spec |
		button := ToggleButton new
			onForm: (PhratchFrameMorph skinAt: (spec at: 1))
			offForm: (PhratchFrameMorph skinAt: (spec at: 1)).

		button
			target: aPhratchFrameMorph;
			actionSelector: (spec at: 2);
			setProperty: #balloonText toValue: (spec at: 3) localized.
		button].

	butonExtent := 37@27.
	x := 0.
	buttons do: [:b |
		b extent: butonExtent.
		panel addMorph: (b position: x@1).
		x := x + 5 + b width].

	panel extent: x@(butonExtent y + 1).

	^ panel

]

{ #category : #accessing }
PhratchLibraryMorph >> spriteThumbnails [

	^ scrollPane contents submorphs

]

{ #category : #stepping }
PhratchLibraryMorph >> step [
	"Update my thumbnail list if morphs have been added or deleted."

	| sFrame workPane morphsWithThumbnails doLayout workPaneObjects |
	
	(sFrame := self ownerOrYourselfThatIsAPhratchFrameMorph) ifNil: [^ self].
	sFrame paintingInProgress
		ifTrue: [^ self]
		ifFalse: [scrollPane owner ifNil: [self addMorph: scrollPane]].

	workPane := sFrame workPane.

	"remove thumbnails for any objects that have been deleted"
	morphsWithThumbnails := IdentitySet new.
	doLayout := false.
	scrollPane contents submorphs do: [:m |
		(m target isNil or: [m target owner isNil])
			ifTrue: [m delete. doLayout := true]
			ifFalse: [morphsWithThumbnails add: m target]].
	stagePane submorphs do: [:m |
		(m target isNil or: [m target owner isNil])
			ifTrue: [m delete. doLayout := true]
			ifFalse: [morphsWithThumbnails add: m target]].

	"add thumbnail for the background, if necessary"
	(morphsWithThumbnails includes: workPane) ifFalse: [
		self addThumbnailFor: workPane.
		doLayout := true].

	"add thumbnails for any new objects"
	workPaneObjects := workPane sprites select: [:s |
		(s isScriptablePhratchMorph) and: [s isScriptable & s isClone not]].
	workPaneObjects do: [:m |
		(morphsWithThumbnails includes: m) ifFalse: [
			self addThumbnailFor: m.
			doLayout := true]].

	doLayout ifTrue: [
		self changed.
		self fixLayout.
		self isInWorld ifTrue: [self world startSteppingSubmorphsOf: self]].

	self updateHighlight.

]

{ #category : #stepping }
PhratchLibraryMorph >> stepTime [

	^ 500

]

{ #category : #private }
PhratchLibraryMorph >> unhighlightAll [

	scrollPane contents submorphs do: [:m | m highlight: false].
	stagePane submorphs do: [:m | m highlight: false].

]

{ #category : #private }
PhratchLibraryMorph >> updateHighlight [

	| sFrame viewedObj |
	(sFrame := self ownerOrYourselfThatIsAPhratchFrameMorph) ifNil: [^ self].
	viewedObj := sFrame viewerPane target.

	scrollPane contents submorphs do: [:m | 
		m highlight: (m target = viewedObj)].
	stagePane submorphs do: [:m | 
		m highlight: (m target = viewedObj)].

]
