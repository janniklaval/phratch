Class {
	#name : #PhratchCategoryOther,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #'as yet unclassified' }
PhratchCategoryOther class >> color [
	^(Color lightGray)
]

{ #category : #'as yet unclassified' }
PhratchCategoryOther class >> initialize [ 	
	"self initialize"
	super initialize.
	Visible  := false.
]

{ #category : #'as yet unclassified' }
PhratchCategoryOther class >> label [
	^'other'
]

{ #category : #'as yet unclassified' }
PhratchCategoryOther class >> order [
	^0
]
