"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #Broadcast,
	#superclass : #Query,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
Broadcast class >> handlesQuery: sel [

	^ sel == #broadcast:
]

{ #category : #protocol }
Broadcast >> defaultArguments [

	^ (self model ownerOrYourselfThatIsA: PhratchStageMorph) 
		ifNotNil: [:stage | Array with: stage defaultEventName]
		ifNil: [ super defaultArguments ]
]
