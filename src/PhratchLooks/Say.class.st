"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #Say,
	#superclass : #PhratchCommandHandler,
	#category : #PhratchLooks
}

{ #category : #protocol }
Say class >> handlesQuery: sel [

	^ sel == #say:
]

{ #category : #protocol }
Say >> defaultArguments [

	^ Array with: 'Hello!' localized
]
