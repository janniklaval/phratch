"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #SetSizeTo,
	#superclass : #PhratchCommandHandler,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
SetSizeTo class >> handlesQuery: sel [

	^ sel == #setSizeTo:
]

{ #category : #protocol }
SetSizeTo >> defaultArguments [
	| currentSize defaultArgs scalePoint |
	(self model isKindOf: PhratchStageMorph)
		ifTrue: [ 
			"no size ops for stage -jens"
			^ Array with: 100 ].
	scalePoint := self model scalePoint.
	currentSize := (100.0 * (scalePoint x max: scalePoint y)) rounded.
	defaultArgs := Array with: currentSize.
	^ defaultArgs
]
