"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #ConcatenateWith,
	#superclass : #PhratchCommandHandler,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
ConcatenateWith class >> handlesQuery: sel [

	^ sel == #concatenate:with:
]

{ #category : #protocol }
ConcatenateWith >> defaultArguments [
	
	^ Array with: 'hello ' localized with: 'world' localized
]
