Class {
	#name : #PhratchCategoryRos,
	#superclass : #PhratchCategory,
	#category : #PhratchROS
}

{ #category : #'as yet unclassified' }
PhratchCategoryRos class >> color [
	^(Color h: 25 s: 0.88 v: 0.85)
]

{ #category : #'as yet unclassified' }
PhratchCategoryRos class >> label [
	^'ros'
]

{ #category : #'as yet unclassified' }
PhratchCategoryRos class >> order [
	^11
]

{ #category : #'as yet unclassified' }
PhratchCategoryRos class >> viewerPageFor: aScriptablePhratchMorph [

		"Answer a morph containing my variables."

	| page x y maxX addButton |
	page := PhratchBlockPaletteMorph new
		color: (Color r: 0.8 g: 0.8 b: 1.0);
		borderWidth: 0.

	addButton := PhratchFrameMorph
		buttonLabel: 'Connect to ROS' localized
		selector: #addRos.
	
	x := 13.
	y:= 10.
	page addMorph: (addButton target: aScriptablePhratchMorph; position: x@7).
	y := addButton bottom + 3.

	aScriptablePhratchMorph addGenericROSBlocksTo: page x: x y: y.
	maxX := page submorphs inject: 0 into: [:t :m | t max: m right].
	page extent: (maxX + 10) @ y.
	^ page

]
