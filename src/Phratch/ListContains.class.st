"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #ListContains,
	#superclass : #PhratchCommandHandler,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
ListContains class >> handlesQuery: sel [

	^ sel == #list:contains:
]

{ #category : #protocol }
ListContains >> defaultArguments [
	| defaultArgs |
	
	defaultArgs := super defaultArguments.
	defaultArgs size >= 2
		ifTrue: [ 
			defaultArgs at: 1 put: self model defaultListName.
			defaultArgs at: 2 put: (defaultArgs at: 2) localized ].
		
	^ defaultArgs
]
