"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #Think,
	#superclass : #PhratchCommandHandler,
	#category : #PhratchLooks
}

{ #category : #protocol }
Think class >> handlesQuery: sel [

	^ sel == #think:
]

{ #category : #protocol }
Think >> defaultArguments [

	^ Array with: 'Hmm...' localized
]
