Class {
	#name : #PhratchCategoryPen,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #accessing }
PhratchCategoryPen class >> color [
	^(Color h: 165 s: 1 v: 0.63)
]

{ #category : #accessing }
PhratchCategoryPen class >> label [
	^'pen'
]

{ #category : #accessing }
PhratchCategoryPen class >> order [
	^7
]
