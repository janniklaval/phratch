"
I am a Scratch blocks palette viewer. I have a set of ToggleButtons that allow selection of a blocks category to view and a scrollable area showing the blocks in the currently selected category.

"
Class {
	#name : #PhratchViewerMorph,
	#superclass : #DividedImageFrameMorph,
	#instVars : [
		'target',
		'pageViewer',
		'currentCategory',
		'catButtonsExtent'
	],
	#category : #'Phratch-UI-Panes'
}

{ #category : #accessing }
PhratchViewerMorph >> catButtonsExtent [

	^ catButtonsExtent

]

{ #category : #accessing }
PhratchViewerMorph >> categoryChanged: aString [
	"The given category has changed (e.g., due to a variable or script add/remove). If it's the current category, update my contents. Otherwise, do nothing."

	self target ifNil: [^ self].
	currentCategory = aString ifTrue: [self updateContents].

]

{ #category : #accessing }
PhratchViewerMorph >> currentCategory [

	^ currentCategory

]

{ #category : #accessing }
PhratchViewerMorph >> currentCategory: aString [

	World activeHand newKeyboardFocus: nil.
	currentCategory := aString.
	self lightUpSelectorForCurrentCategory.
	self updateContents.

]

{ #category : #drawing }
PhratchViewerMorph >> drawBackgroundOn: aCanvas [
	"Draw my background."

	color isTransparent ifTrue: [^ self].

	aCanvas
		fillRectangle: (self topLeft extent: (self width @ catButtonsExtent y))
		color: color.

]

{ #category : #geometry }
PhratchViewerMorph >> extent: aPoint [

	super extent: aPoint.
	pageViewer ifNotNil: [pageViewer extent: self extent - (pageViewer position - self position)].

]

{ #category : #initialization }
PhratchViewerMorph >> initialize [

	super initialize.
	self hasDropShadow: false.
	self
		initFrontFromForm: (PhratchFrameMorph skinAt: #blocksPaletteFrameTransparent2)
		topSectionHeight: 120.
	self middleBarLeftMargin: 5 rightMargin: 0.
	color := (Color r: 0.584 g: 0.603 b: 0.623).
	pageViewer := ScrollFrameMorph new growthFraction: 0.1.
	self addMorphBack: (pageViewer position: self position + (0@120)).
	self target: nil.
	self extent: 214@500.

]

{ #category : #testing }
PhratchViewerMorph >> isPhratchViewerMorph [

	^ true
]

{ #category : #private }
PhratchViewerMorph >> lightUpSelectorForCurrentCategory [

	submorphs do: [:m |
		(m isResizableToggleButton) ifTrue: [
			m arguments first = currentCategory
				ifTrue: [m on]
				ifFalse: [m off]]].

]

{ #category : #accessing }
PhratchViewerMorph >> pageViewer [

	^ pageViewer

]

{ #category : #initialization }
PhratchViewerMorph >> rebuildCategorySelectors [
	| catList maxExtent buttons label offForm onForm overForm b pad leftColumnX rightColumnX x y |
	catList := ((PhratchCategory allSubclasses select: [ :e | e visible ]) sort: [ :e :f | e order < f order ]) asArray.	"First, delete the old category buttons"
	submorphs
		do: [ :m | 
			(m isResizableToggleButton)
				ifTrue: [ m delete ] ].	"Create new buttons, keeping track of the maximum extent."
	maxExtent := 75 @ 0.
	buttons := catList
		collect: [ :cat | 
			label := (PhratchTranslator translationFor: cat label asString) capitalized.
			
			offForm := PhratchFrameMorph offFormBasicColor: cat color.
			onForm := PhratchFrameMorph onFormBasicColor: cat color.
			overForm := PhratchFrameMorph overFormBasicColor: cat color.
			
			b :=  ResizableToggleButton new offForm: offForm onForm: onForm overForm: overForm .
			b
				label: label font: (PhratchFrameMorph getFont: #Category);
				setLabelColor: Color white;
				target: self;
				actionSelector: #currentCategory:;
				arguments: (Array with: cat label);
				toggleButtonMode: true;
				toggleMode: false.
			b leftJustifyInset: 10 .
			maxExtent := maxExtent max: b extent + (3 @ -6).
			b ].	"calculate catButtonsExtent"
	pad := 15.	"padding on left, right, and betwen the button columns"
	catButtonsExtent := (2 * maxExtent x + (3 * pad)) @ ((catList size + 1) // 2 * (maxExtent y + 6) + 25).	"place the buttons"
	leftColumnX := self left + 12 + pad.
	rightColumnX := leftColumnX + maxExtent x + pad.
	x := leftColumnX.
	y := self top + 17.
	1 to: buttons size do: [ :i | 
		b := buttons at: i.
		b extent: maxExtent.
		self addMorph: (b position: x @ y).
		i even
			ifTrue: [ 
				x := leftColumnX.
				y := y + b height + 6 ]
			ifFalse: [ x := rightColumnX ] ].
	self width: catButtonsExtent x.
	pageViewer position: self position + (0 @ catButtonsExtent y).
	topSectionHeight := catButtonsExtent y - 4
]

{ #category : #accessing }
PhratchViewerMorph >> refresh [
	"Refresh the palette for the current category."

	self currentCategory: currentCategory.

]

{ #category : #accessing }
PhratchViewerMorph >> target [

	^ target

]

{ #category : #accessing }
PhratchViewerMorph >> target: aPhratchObject [
	"Start viewing the given object, if not object, return an empty viewer."

	| categories |
	target := aPhratchObject.
	aPhratchObject ifNil: [
		^ self currentCategory: 'none'].

	"keep the same category selected if possible"
	categories := target blockCategories.
	(categories includes: currentCategory)
		ifTrue: [self currentCategory: currentCategory]
		ifFalse: [self currentCategory: categories first].

	self isInWorld ifTrue: [self world startSteppingSubmorphsOf: self].

]

{ #category : #private }
PhratchViewerMorph >> updateContents [

	| p |
	self target ifNil: [
		pageViewer contents: (Morph new color: PhratchFrameMorph palettePaneColor).
		^ self].

	p := self target viewerPageForCategory: currentCategory.
	p color: PhratchFrameMorph palettePaneColor.

	pageViewer contents: p.
	self isInWorld ifTrue: [self world startSteppingSubmorphsOf: p].
	p fixLayout.

]
