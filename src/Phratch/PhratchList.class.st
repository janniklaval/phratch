Class {
	#name : #PhratchList,
	#superclass : #OrderedCollection,
	#instVars : [
		'lastChanged'
	],
	#category : #'Phratch-Objects'
}

{ #category : #updating }
PhratchList >> changed [

	lastChanged := Time millisecondClockValue. 
	super changed
]

{ #category : #'list ops' }
PhratchList >> clear [

	self removeAll.
	self changed.

]

{ #category : #accessing }
PhratchList >> contents [

	^ self
]

{ #category : #accessing }
PhratchList >> contents: anOrderedCollection [

	self removeAll.
	self addAll: anOrderedCollection.
	self changed

]

{ #category : #'list ops' }
PhratchList >> deleteLineAt: aNumber [

	self removeIndex: aNumber.
	self changed
]

{ #category : #'initialize-release' }
PhratchList >> initialize [
	
	super initialize.
	lastChanged := Time millisecondClockValue
]

{ #category : #'list ops' }
PhratchList >> insertLine: anObject at: aNumber [

	self add: anObject afterIndex: aNumber - 1.
	self changed
]

{ #category : #'as yet unclassified' }
PhratchList >> isPhratchList [

	^ true
]

{ #category : #accessing }
PhratchList >> lastChanged [

	^ lastChanged
]

{ #category : #'list ops' }
PhratchList >> lineAt: aNumber [

	^ self at: aNumber
]

{ #category : #'list ops' }
PhratchList >> lineCount [

	^ self size

]

{ #category : #'list ops' }
PhratchList >> setLineAt: aNumber to: newContents [

	[self at: aNumber put: newContents] ifError: [self add: newContents].
	self changed
]
