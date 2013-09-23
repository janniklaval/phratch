Class {
	#name : #BYOBListTests,
	#superclass : #TestCase,
	#category : #'Phratch-Tests'
}

{ #category : #tests }
BYOBListTests >> test [

	| myList |
	myList := BYOBList new.
	3 timesRepeat: [
		(PhratchListMorph on: myList) openInWorld; startStepping]
]
