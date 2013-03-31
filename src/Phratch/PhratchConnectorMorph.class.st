Class {
	#name : #PhratchConnectorMorph,
	#superclass : #Morph,
	#instVars : [
		'point2',
		'point1'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'as yet unclassified' }
PhratchConnectorMorph >> drawOn: aCanvas [

	(point1 isNil | point2 isNil) ifTrue: [^ self].
	aCanvas line: point1 to: point2 width: 1 color: color

]

{ #category : #'as yet unclassified' }
PhratchConnectorMorph >> from: p1 to: p2 [

	| left right top bottom |
	((point1 = p1) & (point2 = p2)) ifTrue: [^ self].

	point1 := p1.
	point2 := p2.

	left := point1 x min: point2 x.
	right := point1 x max: point2 x.
	top := point1 y min: point2 y.
	bottom := point1 y max: point2 y.

	self position: left @ top.
	self extent: ((right - left) @ ((bottom - top) max: 1)).


]

{ #category : #'as yet unclassified' }
PhratchConnectorMorph >> rootForGrabOf: aMorph [
	"prevent the receiver from being picked up"

	^ nil

]
