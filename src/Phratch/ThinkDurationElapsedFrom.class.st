"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #ThinkDurationElapsedFrom,
	#superclass : #Query,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
ThinkDurationElapsedFrom class >> handlesQuery: sel [

	^ sel == #think:duration:elapsed:from:
]

{ #category : #protocol }
ThinkDurationElapsedFrom >> defaultArguments [

	^ Array 
		with: 'Hmm...' localized
		with: 2
]

{ #category : #protocol }
ThinkDurationElapsedFrom >> stopTalkThinkAsk [

	self model receiver sayNothing
]
