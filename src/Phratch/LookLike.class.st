"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #LookLike,
	#superclass : #PhratchCommandHandler,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
LookLike class >> handlesQuery: sel [

	^ sel == #lookLike:
]

{ #category : #protocol }
LookLike >> defaultArguments [

	self model costumeNames ifEmpty: [ ^'' ].
	^ Array with: self model costumeNames last
]
