"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #DoPlaySoundAndWait,
	#superclass : #PhratchCommandHandler,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
DoPlaySoundAndWait class >> handlesQuery: sel [

	^ sel == #doPlaySoundAndWait
]

{ #category : #protocol }
DoPlaySoundAndWait >> defaultArguments [

	| list |
	
	list := self model soundNames.
	
	^ list size <= 2
		ifTrue: [ Array with: '' ]
		ifFalse: [ Array with: (list at: list size - 2) ]
]
