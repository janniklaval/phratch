"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #LineCountOfList,
	#superclass : #PhratchCommandHandler,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
LineCountOfList class >> handlesQuery: sel [

	^ sel == #lineCountOfList:
]

{ #category : #protocol }
LineCountOfList >> defaultArguments [
	| defaultArgs |
	
	defaultArgs := super defaultArguments.
	defaultArgs := defaultArgs copyWith: self model defaultListName.
		
	^ defaultArgs
]
