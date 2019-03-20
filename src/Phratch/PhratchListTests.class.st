Class {
	#name : #PhratchListTests,
	#superclass : #TestCase,
	#category : #'Phratch-Tests'
}

{ #category : #tests }
PhratchListTests >> test [

	| myList morphs |
	myList := PhratchList new.
	morphs := OrderedCollection new.
	3 timesRepeat: [
		morphs add: ((PhratchListMorph on: myList) "openInWorld;" startStepping)].
	"morphs do: [:aMorph |
		aMorph hide]."
	self assert: true.
]
