Class {
	#name : #PhratchCategoryList,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #'as yet unclassified' }
PhratchCategoryList class >> color [
	^(Color h: 18 s: 0.92 v: 0.85)
]

{ #category : #'as yet unclassified' }
PhratchCategoryList class >> initialize [ 	
	"self initialize"
	super initialize.
	Visible  := false.
]

{ #category : #'as yet unclassified' }
PhratchCategoryList class >> label [
	^'list'
]

{ #category : #'as yet unclassified' }
PhratchCategoryList class >> order [
	^0
]
