"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #SetLineOfListTo,
	#superclass : #Query,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
SetLineOfListTo class >> handlesQuery: sel [

	^ sel == #setLine:ofList:to:
]

{ #category : #protocol }
SetLineOfListTo >> defaultArguments [
	| defaultArgs |
	
	defaultArgs := super defaultArguments.
	defaultArgs size >= 3
		ifTrue: [ 
			defaultArgs at: 2 put: self model defaultListName.
			defaultArgs at: 3 put: (defaultArgs at: 3) localized ].
		
	^ defaultArgs
]
