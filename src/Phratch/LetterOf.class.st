"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #LetterOf,
	#superclass : #PhratchCommandHandler,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
LetterOf class >> handlesQuery: sel [

	^ sel == #letter:of:
]

{ #category : #protocol }
LetterOf >> defaultArguments [
	
	^ Array with: 1 with: 'world' localized 
]
