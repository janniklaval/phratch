Class {
	#name : #BlockWrapper,
	#superclass : #Wrapper,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #'as yet unclassified' }
BlockWrapper >> copyFrom: anInteger to: anotherInteger [

	^ self data copyFrom: anInteger to: anotherInteger
]

{ #category : #'as yet unclassified' }
BlockWrapper >> selector [ 

	^ (data at: 3) asSymbol
]
