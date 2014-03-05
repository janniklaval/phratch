"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #DoBroadcastAndWait,
	#superclass : #PhratchCommandHandler,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
DoBroadcastAndWait class >> handlesQuery: sel [

	^ sel == #doBroadcastAndWait
]

{ #category : #protocol }
DoBroadcastAndWait >> defaultArguments [

	^ (self model ownerOrYourselfThatIsA: PhratchStageMorph) 
		ifNotNil: [:stage | Array with: stage defaultEventName]
		ifNil: [ super defaultArguments ]
]
