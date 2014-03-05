"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #StringLength,
	#superclass : #PhratchCommandHandler,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
StringLength class >> handlesQuery: sel [

	^ sel == #stringLength:
]

{ #category : #protocol }
StringLength >> defaultArguments [

	^ Array with: 'world' localized
]
