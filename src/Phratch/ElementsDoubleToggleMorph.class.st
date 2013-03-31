Class {
	#name : #ElementsDoubleToggleMorph,
	#superclass : #ElementsToggleButtonMorph,
	#instVars : [
		'chooser'
	],
	#category : #'Phratch-BYOB-Elements-UI'
}

{ #category : #'as yet unclassified' }
ElementsDoubleToggleMorph >> chooser: aSelector [
	chooser selector: aSelector
]

{ #category : #'as yet unclassified' }
ElementsDoubleToggleMorph >> fitMorphs [
	| bw x y |
	chooser ifNil: [^super fitMorphs].
	bw := self borderWidth.
	self height: label height + (bw * 2).
	y := self top + bw.

	chooser extent: (label height @ label height) * 2//3.
	chooser position: self left + bw @ self top + (label height - chooser height // 2).

	x := chooser right + bw + (self width - label width // 2).

	label position: x@ y.

]

{ #category : #'as yet unclassified' }
ElementsDoubleToggleMorph >> initialize [
	super initialize.
	chooser := TriangleButtonMorph new
				target: self;
				selector: #test.
	self addMorph: chooser.
	self fitMorphs
]

{ #category : #'as yet unclassified' }
ElementsDoubleToggleMorph >> selector: anObject [
	super selector: anObject.
	chooser selector: anObject
]

{ #category : #'as yet unclassified' }
ElementsDoubleToggleMorph >> target: anObject [
	super target: anObject.
	chooser target: anObject
]

{ #category : #'as yet unclassified' }
ElementsDoubleToggleMorph >> test [
	self inform: 'Hi'
]
