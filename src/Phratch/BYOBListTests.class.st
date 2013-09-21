Class {
	#name : #BYOBListTests,
	#superclass : #TestCase,
	#category : #'Phratch-Tests'
}

{ #category : #'as yet unclassified' }
BYOBListTests >> test [

	| myList |
	myList := BYOBList new.
	3 timesRepeat: [
		(PhratchListMorph on: myList) openInWorld; startStepping]
]
