Class {
	#name : #PhratchCategoryList,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #accessing }
PhratchCategoryList class >> color [
	^(Color h: 18 s: 0.92 v: 0.85)
]

{ #category : #'class initialization' }
PhratchCategoryList class >> initialize [ 	
	"self initialize"
	super initialize.
	visible  := false.
]

{ #category : #accessing }
PhratchCategoryList class >> label [
	^'list'
]
