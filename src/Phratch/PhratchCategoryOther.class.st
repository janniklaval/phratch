"
I represent the other category of phratch
"
Class {
	#name : #PhratchCategoryOther,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #accessing }
PhratchCategoryOther class >> color [
	^(Color lightGray)
]

{ #category : #'class initialization' }
PhratchCategoryOther class >> initialize [ 	
	"self initialize"
	super initialize.
	visible  := false.
]

{ #category : #accessing }
PhratchCategoryOther class >> label [
	^'other'
]
