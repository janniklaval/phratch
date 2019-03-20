"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #DeleteLineOfList,
	#superclass : #PhratchCommandHandler,
	#category : #PhratchList
}

{ #category : #protocol }
DeleteLineOfList class >> handlesQuery: sel [

	^ sel == #deleteLine:ofList:
]

{ #category : #protocol }
DeleteLineOfList >> defaultArguments [
	| defaultArgs |
	
	defaultArgs := super defaultArguments.
	defaultArgs size >= 1
				ifTrue: [ defaultArgs at: 1 put: (defaultArgs at: 1) localized ].
	defaultArgs := defaultArgs copyWith: self model defaultListName.
		
	^ defaultArgs
]
