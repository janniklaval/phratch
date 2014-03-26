Class {
	#name : #PhratchCategoryVariables,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #accessing }
PhratchCategoryVariables class >> color [
	^(Color h: 25 s: 0.88 v: 0.95)
]

{ #category : #accessing }
PhratchCategoryVariables class >> label [
	^'variables'
]

{ #category : #accessing }
PhratchCategoryVariables class >> order [
	^8
]

{ #category : #drawing }
PhratchCategoryVariables class >> viewerPageFor: aScriptablePhratchMorph [ 

	"Answer a morph containing my variables."

	| page addButton deleteButton hasVars stage x y maxX |
	page := PhratchBlockPaletteMorph new
		color: (Color r: 0.8 g: 0.8 b: 1.0);
		borderWidth: 0;
		yourself.

	addButton := PhratchFrameMorph
		buttonLabel: 'Make a variable' localized
		selector: #addGlobalVariable.
	(aScriptablePhratchMorph isPhratchSpriteMorph) ifTrue: [addButton actionSelector: #addVariable].

	deleteButton := PhratchFrameMorph
		buttonLabel: 'Delete a variable' localized
		selector: #deleteVariable.

	x := 13.
	page addMorph: (addButton target: aScriptablePhratchMorph; position: x@7;
		yourself).
	y := addButton bottom + 3.

	hasVars := aScriptablePhratchMorph varNames size > 0.
	(stage := aScriptablePhratchMorph ownerOrYourselfThatIsA: PhratchStageMorph) ifNotNil: [
		stage varNames size > 0 ifTrue: [hasVars := true]].

	hasVars ifTrue: [
		page addMorph: (deleteButton target: aScriptablePhratchMorph; position: x@y;
		yourself).
		y := deleteButton bottom + 10.

		y := aScriptablePhratchMorph addVariableReportersTo: page x: x y: y.
		y := y + 12  ].

	y := aScriptablePhratchMorph addGenericVariableBlocksTo: page x: x y: y.

	y := aScriptablePhratchMorph addGenericListBlocksTo: page y: y.
	page updateWatcherButtonsForFrame: (aScriptablePhratchMorph ownerOrYourselfThatIsA: PhratchFrameMorph).

	aScriptablePhratchMorph addCustomBlocksTo: page y: y.

	maxX := page submorphs inject: 0 into: [:t :m | t max: m right].
	page extent: (maxX + 10) @ y.
	^ page
]
