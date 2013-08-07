Class {
	#name : #PhratchCategoryLooks,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #accessing }
PhratchCategoryLooks class >> color [
	^(Color h: 264 s: 0.62 v: 0.89)
]

{ #category : #accessing }
PhratchCategoryLooks class >> label [
	^'looks'
]

{ #category : #accessing }
PhratchCategoryLooks class >> order [
	^3
]
