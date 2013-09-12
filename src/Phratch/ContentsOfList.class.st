"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #ContentsOfList,
	#superclass : #Query,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
ContentsOfList class >> handlesQuery: sel [

	^ sel == #contentsOfList:
]

{ #category : #protocol }
ContentsOfList >> defaultArguments [
	| defaultArgs |
	
	defaultArgs := super defaultArguments.
	defaultArgs := defaultArgs copyWith: self model defaultListName.
		
	^ defaultArgs
]
