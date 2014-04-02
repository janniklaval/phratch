Class {
	#name : #PhratchCategoryCustom,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #accessing }
PhratchCategoryCustom class >> color [
	^(Color h: 200 s: 0.2 v: 0.5)
]

{ #category : #'class initialization' }
PhratchCategoryCustom class >> initialize [ 	
	"self initialize"
	super initialize.
	visible  := false.
]

{ #category : #accessing }
PhratchCategoryCustom class >> label [
	^'custom'
]
