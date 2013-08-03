Class {
	#name : #ElementsButtonMorph,
	#superclass : #Morph,
	#instVars : [
		'target',
		'selector'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #drawing }
ElementsButtonMorph >> borderColorDark [
	^color twiceDarker
]

{ #category : #drawing }
ElementsButtonMorph >> borderColorLight [
	^color twiceLighter lighter
]

{ #category : #drawing }
ElementsButtonMorph >> borderColorVeryDark [
	^color twiceDarker darker
]

{ #category : #drawing }
ElementsButtonMorph >> borderColorVeryLight [
	^color twiceLighter twiceLighter lighter
]

{ #category : #accessing }
ElementsButtonMorph >> borderWidth [
	^1

]

{ #category : #'event handling' }
ElementsButtonMorph >> handlesMouseDown: evt [
	^ true

]

{ #category : #private }
ElementsButtonMorph >> labelColor [
	^Color white
]

{ #category : #private }
ElementsButtonMorph >> labelFont [
	^StrikeFont fontName: 'VerdanaBold' size: 12
]

{ #category : #'event handling' }
ElementsButtonMorph >> mouseDown: evt [
	target perform: selector
]

{ #category : #accessing }
ElementsButtonMorph >> selector: aSelector [
	selector := aSelector
]

{ #category : #accessing }
ElementsButtonMorph >> target: anObject [
	target := anObject
]
