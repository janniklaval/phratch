Class {
	#name : #PhratchCategoryCustom,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #'as yet unclassified' }
PhratchCategoryCustom class >> color [
	^(Color h: 200 s: 0.2 v: 0.5)
]

{ #category : #'as yet unclassified' }
PhratchCategoryCustom class >> initialize [ 	
	"self initialize"
	super initialize.
	Visible  := false.
]

{ #category : #'as yet unclassified' }
PhratchCategoryCustom class >> label [
	^'custom'
]

{ #category : #'as yet unclassified' }
PhratchCategoryCustom class >> order [
	^0
]
