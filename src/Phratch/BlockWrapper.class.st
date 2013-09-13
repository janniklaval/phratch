Class {
	#name : #BlockWrapper,
	#superclass : #Wrapper,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #copying }
BlockWrapper >> copyFrom: anInteger to: anotherInteger [

	^ self data copyFrom: anInteger to: anotherInteger
]

{ #category : #accessing }
BlockWrapper >> selector [ 

	^ (data at: 3) asSymbol
]
