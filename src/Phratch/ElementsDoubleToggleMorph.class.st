Class {
	#name : #ElementsDoubleToggleMorph,
	#superclass : #ElementsToggleButtonMorph,
	#instVars : [
		'chooser'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #accessing }
ElementsDoubleToggleMorph >> chooser: aSelector [
	chooser selector: aSelector
]

{ #category : #private }
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

{ #category : #initialize }
ElementsDoubleToggleMorph >> initialize [
	super initialize.
	chooser := TriangleButtonMorph new
				target: self;
				selector: #test;
		yourself.
	self addMorph: chooser.
	self fitMorphs
]

{ #category : #accessing }
ElementsDoubleToggleMorph >> selector: anObject [
	super selector: anObject.
	chooser selector: anObject
]

{ #category : #accessing }
ElementsDoubleToggleMorph >> target: anObject [
	super target: anObject.
	chooser target: anObject
]

{ #category : #tests }
ElementsDoubleToggleMorph >> test [
	self inform: 'Hi'
]
