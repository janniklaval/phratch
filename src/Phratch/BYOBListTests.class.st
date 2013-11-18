Class {
	#name : #BYOBListTests,
	#superclass : #TestCase,
	#category : #'Phratch-Tests'
}

{ #category : #tests }
BYOBListTests >> test [

	| myList morphs |
	myList := BYOBList new.
	morphs := OrderedCollection new.
	3 timesRepeat: [
		morphs add: ((PhratchListMorph on: myList) "openInWorld;" startStepping)].
	"morphs do: [:aMorph |
		aMorph hide]."
	self assert: true.
]
