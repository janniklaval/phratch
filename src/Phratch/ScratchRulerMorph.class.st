Class {
	#name : #ScratchRulerMorph,
	#superclass : #RectangleMorph,
	#instVars : [
		'max',
		'min',
		'marks',
		'graph',
		'sigDigs'
	],
	#category : #'Phratch-Sound'
}

{ #category : #'instance creation' }
ScratchRulerMorph class >> graphMorph: aScratchGraphMorph [

	^ self new graph: aScratchGraphMorph; extent: (aScratchGraphMorph extent x)@20.

	
]

{ #category : #drawing }
ScratchRulerMorph >> drawOn: aCanvas [

	| space bigSpace currVal s ss |
	
	"the amt of space btw each bar.  big Space = the amt of space btw each big bar"
	space := (self extent x/marks) truncated max: 1.
	bigSpace := 5* space asFloat.

	graph ifNotNil: [ss := graph editor origSamplingRate]
		   ifNil: [ss := 1].


	currVal := (min/ss) asFloat roundTo: 0.01.  "the value of where we are in teh rule"

	aCanvas fillRectangle: (Rectangle origin: (self left)@(self top) corner: (self right)@(self bottom)) color: Color lightGray.
	self removeAllMorphs.

	(self left) to: (self right) by: space do: 
		[:pos |
			(pos - (self left)) \\ bigSpace = 0
				ifTrue: [aCanvas line: (pos truncated)@((self top) truncated) to: (pos truncated)@((self top + 5) truncated) color: Color black.
				s := ScratchStringMorph contents: (currVal asString).
				s center: (pos truncated)@(self top + 12).
				self addMorph: s.]
				ifFalse: [aCanvas line: (pos truncated)@(self top truncated) to: (pos truncated)@((self top + 1) truncated) color: Color black.]. 
			currVal := currVal + ((max-min)/(marks*ss)) roundTo: 0.01. ].





]

{ #category : #accessing }
ScratchRulerMorph >> graph: aScratchGraphMorph [

	graph := aScratchGraphMorph.
]

{ #category : #initialize }
ScratchRulerMorph >> initialize [
	
	super initialize.
	min := 0.0.
	max := 100.
	marks := 20.0.
	sigDigs := 1. 
	graph := nil. "used specifically to coord with ScratchGraphMorph"

	self borderWidth: 1.
	self extent: 200@20.
	self color: Color white.
]

{ #category : #accessing }
ScratchRulerMorph >> marks: aNumber [
	marks := aNumber.
	self changed.
]

{ #category : #accessing }
ScratchRulerMorph >> min: aMin max: aMax [

	min := aMin.
	max := aMax.
	self changed.
]

{ #category : #accessing }
ScratchRulerMorph >> sigDigs: aNumber [

	sigDigs := aNumber truncated.
	self changed.
]

{ #category : #stepping }
ScratchRulerMorph >> step [
	
	| graphStart graphEnd |
	graph ifNil: [^self].

	self extent x = graph extent x
		ifFalse: [self extent: (graph extent x)@(self extent y).].


	graphStart := graph startIndex min: graph data size.
	graphEnd := graphStart + (graph bounds width/graph scale) min: graph data size.
	
	(min = graphStart and:[ max = graphEnd])
		ifFalse: [ min := graphStart.
				  max := graphEnd truncated.
				  self changed.].
]
