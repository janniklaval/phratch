Class {
	#name : #PhratchResizeMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'type'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'instance creation' }
PhratchResizeMorph class >> ofType: aSymbol [
	"#edge #corner"
	
	(aSymbol = #edge)
		ifTrue: [^ self new form: (PhratchFrameMorph skinAt: #resizeIconEdge); type: aSymbol;
		yourself]
		ifFalse: [^ self new form: (PhratchFrameMorph skinAt: #resizeIconCorner); type: aSymbol;
		yourself].

]

{ #category : #accessing }
PhratchResizeMorph >> form: aForm [

	(self submorphs at: 1) form: aForm.
	self extent: (self submorphs at: 1) extent.

]

{ #category : #'event handling' }
PhratchResizeMorph >> handlesMouseOver: evt [

	^ true

]

{ #category : #initialization }
PhratchResizeMorph >> initialize [

	super initialize.
	self
		color: Color transparent;
		orientation: #vertical;
		centering: #center;
		cellPositioning: #topCenter;
		hResizing: #rigid;
		vResizing: #rigid;
		inset: 0;
		borderWidth: 0.
	self
		addMorph: ImageMorph new.

]

{ #category : #'event handling' }
PhratchResizeMorph >> mouseEnter: evt [

	(type = #edge)
		ifTrue: [World activeHand showTemporaryCursor: Cursor resizeHorizontally]
		ifFalse: [World activeHand showTemporaryCursor: Cursor resizeCorner].

]

{ #category : #'event handling' }
PhratchResizeMorph >> mouseLeave: evt [

	World activeHand showTemporaryCursor: nil.

]

{ #category : #'event handling' }
PhratchResizeMorph >> type: aSymbol [
	type := aSymbol.
	type = #edge
		ifFalse: [ ^ self ].
	self addMorphBack: (AlignmentMorph newSpacer: Color transparent).
	self addMorphFront: (AlignmentMorph newSpacer: Color transparent)
]
