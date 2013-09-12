"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #GotoXy,
	#superclass : #Query,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
GotoXy class >> handlesQuery: sel [

	^ sel == #gotoX:y:
]

{ #category : #protocol }
GotoXy >> defaultArguments [
	| position |
	
	position := self model referencePosition.
	
	^ Array 
		with: position x rounded 
		with: position y rounded
]
