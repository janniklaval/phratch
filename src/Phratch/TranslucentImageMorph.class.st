Class {
	#name : #TranslucentImageMorph,
	#superclass : #ImageMorph,
	#instVars : [
		'transparency'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #drawing }
TranslucentImageMorph >> drawOn: aCanvas [

	| clipC |
	clipC := aCanvas copyClipRect: self bounds.
	clipC translucentImage: image  at: self bounds origin.

]

{ #category : #initialization }
TranslucentImageMorph >> initialize [

	super initialize.
	transparency := 1.0.
]

{ #category : #'event handling' }
TranslucentImageMorph >> mouseLeave: evt [

	PhratchToolTipMorph clearToolTips.

]

{ #category : #accessing }
TranslucentImageMorph >> transparency [

	^ transparency

]

{ #category : #accessing }
TranslucentImageMorph >> transparency: aNumber [

	transparency := aNumber.
	self changed.

]
