Class {
	#name : #PhratchCategorySound,
	#superclass : #PhratchCategory,
	#category : #PhratchSound
}

{ #category : #accessing }
PhratchCategorySound class >> color [
	^(Color h: 296 s: 0.66 v: 0.85)
]

{ #category : #accessing }
PhratchCategorySound class >> initialize [ 	
	"self initialize"
	super initialize.
	visible  := false.
]

{ #category : #accessing }
PhratchCategorySound class >> label [
	^'sound'
]

{ #category : #accessing }
PhratchCategorySound class >> order [
	^5
]
