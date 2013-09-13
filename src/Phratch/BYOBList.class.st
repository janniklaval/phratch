Class {
	#name : #BYOBList,
	#superclass : #Object,
	#instVars : [
		'contents',
		'lastChanged'
	],
	#category : #'Phratch-Objects'
}

{ #category : #demo }
BYOBList class >> test [
	"BYOBList test"

	| myList |
	myList := BYOBList new.
	3 timesRepeat: [
		(PhratchListMorph on: myList) openInWorld; startStepping]
]

{ #category : #accessing }
BYOBList >> at: index [

	^ contents at: index
]

{ #category : #updating }
BYOBList >> changed [

	lastChanged := Time millisecondClockValue. 
	super changed
]

{ #category : #'list ops' }
BYOBList >> clear [

	contents := OrderedCollection new.
	self changed.

]

{ #category : #'list ops' }
BYOBList >> contains: anObject [

	^ contents includes: anObject
]

{ #category : #accessing }
BYOBList >> contents [

	^ contents
]

{ #category : #accessing }
BYOBList >> contents: anOrderedCollection [

	contents := anOrderedCollection.
	self changed

]

{ #category : #'list ops' }
BYOBList >> deleteLineAt: aNumber [

	contents removeIndex: aNumber.
	self changed
]

{ #category : #'initialize-release' }
BYOBList >> initialize [
	contents := OrderedCollection new.
	lastChanged := Time millisecondClockValue
]

{ #category : #'list ops' }
BYOBList >> insertLine: anObject at: aNumber [

	contents add: anObject afterIndex: aNumber - 1.
	self changed
]

{ #category : #accessing }
BYOBList >> lastChanged [

	^ lastChanged
]

{ #category : #'list ops' }
BYOBList >> lineAt: aNumber [

	^ contents at: aNumber
]

{ #category : #'list ops' }
BYOBList >> lineCount [

	^ contents size

]

{ #category : #'list ops' }
BYOBList >> setLineAt: aNumber to: newContents [

	[contents at: aNumber put: newContents] ifError: [contents add: newContents].
	self changed
]

{ #category : #accessing }
BYOBList >> size [
	^ contents size
]
