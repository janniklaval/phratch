"
I represent the None category of phratch
"
Class {
	#name : #PhratchCategoryNone,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #accessing }
PhratchCategoryNone class >> color [
	^(Color lightGray)
]

{ #category : #'class initialization' }
PhratchCategoryNone class >> initialize [ 	
	"self initialize"
	super initialize.
	visible  := false.
]

{ #category : #accessing }
PhratchCategoryNone class >> label [
	^'none'
]
