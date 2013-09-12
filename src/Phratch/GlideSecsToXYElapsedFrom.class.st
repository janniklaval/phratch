"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #GlideSecsToXYElapsedFrom,
	#superclass : #Query,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
GlideSecsToXYElapsedFrom class >> handlesQuery: sel [

	^ sel == #glideSecs:toX:y:elapsed:from:
]

{ #category : #protocol }
GlideSecsToXYElapsedFrom >> defaultArguments [
	| position |
	
	position := self model referencePosition.
	
	^ Array 
		with: 1
		with: position x rounded 
		with: position y rounded
]
