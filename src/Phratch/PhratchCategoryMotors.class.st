Class {
	#name : #PhratchCategoryMotors,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #'as yet unclassified' }
PhratchCategoryMotors class >> color [
	^(Color h: 220 s: 0.85 v: 0.725)
]

{ #category : #'as yet unclassified' }
PhratchCategoryMotors class >> initialize [ 	
	"self initialize"
	super initialize.
	Visible  := false.
]

{ #category : #'as yet unclassified' }
PhratchCategoryMotors class >> label [
	^'motor'
]

{ #category : #'as yet unclassified' }
PhratchCategoryMotors class >> order [
	^0
]
