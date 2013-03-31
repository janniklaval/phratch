Class {
	#name : #ElementsButtonMorph,
	#superclass : #Morph,
	#instVars : [
		'target',
		'selector'
	],
	#category : #'Phratch-BYOB-Elements-UI'
}

{ #category : #'as yet unclassified' }
ElementsButtonMorph >> borderColorDark [
	^color twiceDarker
]

{ #category : #'as yet unclassified' }
ElementsButtonMorph >> borderColorLight [
	^color twiceLighter lighter
]

{ #category : #'as yet unclassified' }
ElementsButtonMorph >> borderColorVeryDark [
	^color twiceDarker darker
]

{ #category : #'as yet unclassified' }
ElementsButtonMorph >> borderColorVeryLight [
	^color twiceLighter twiceLighter lighter
]

{ #category : #'as yet unclassified' }
ElementsButtonMorph >> borderWidth [
	^1

]

{ #category : #'as yet unclassified' }
ElementsButtonMorph >> handlesMouseDown: evt [
	^ true

]

{ #category : #'as yet unclassified' }
ElementsButtonMorph >> labelColor [
	^Color white
]

{ #category : #'as yet unclassified' }
ElementsButtonMorph >> labelFont [
	^StrikeFont fontName: 'VerdanaBold' size: 12
]

{ #category : #'as yet unclassified' }
ElementsButtonMorph >> mouseDown: evt [
	target perform: selector
]

{ #category : #'as yet unclassified' }
ElementsButtonMorph >> selector: aSelector [
	selector := aSelector
]

{ #category : #'as yet unclassified' }
ElementsButtonMorph >> target: anObject [
	target := anObject
]
