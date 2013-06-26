Class {
	#name : #PhratchCategoryNone,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #'as yet unclassified' }
PhratchCategoryNone class >> color [
	^(Color lightGray)
]

{ #category : #'as yet unclassified' }
PhratchCategoryNone class >> initialize [ 	
	"self initialize"
	super initialize.
	Visible  := false.
]

{ #category : #'as yet unclassified' }
PhratchCategoryNone class >> label [
	^'none'
]

{ #category : #'as yet unclassified' }
PhratchCategoryNone class >> order [
	^0
]
