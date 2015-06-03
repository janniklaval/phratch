"
I represent the Control category of phratch
"
Class {
	#name : #PhratchCategoryControl,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #accessing }
PhratchCategoryControl class >> color [
	^(Color h: 41 s: 0.85 v: 0.9)
]

{ #category : #accessing }
PhratchCategoryControl class >> label [
	^'control'
]

{ #category : #accessing }
PhratchCategoryControl class >> order [
	^2
]
