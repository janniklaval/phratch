Class {
	#name : #PhratchCategoryMotors,
	#superclass : #PhratchCategory,
	#category : #'Phratch-Categories'
}

{ #category : #accessing }
PhratchCategoryMotors class >> color [
	^(Color h: 220 s: 0.85 v: 0.725)
]

{ #category : #'class initialization' }
PhratchCategoryMotors class >> initialize [ 	
	"self initialize"
	super initialize.
	visible  := false.
]

{ #category : #accessing }
PhratchCategoryMotors class >> label [
	^'motor'
]

{ #category : #accessing }
PhratchCategoryMotors class >> order [
	^0
]
