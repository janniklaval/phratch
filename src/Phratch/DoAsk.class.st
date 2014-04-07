"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #DoAsk,
	#superclass : #PhratchCommandHandler,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
DoAsk class >> handlesQuery: sel [

	^ sel == #doAsk
]

{ #category : #protocol }
DoAsk >> defaultArguments [
	
	^ Array with: 'What''s your name?' localized
]

{ #category : #protocol }
DoAsk >> stopTalkThinkAsk [
	 | s |

	[(s := self model receiver ownerOrYourselfThatIsAPhratchStageMorph) ifNotNil: [ s stopAsks ] ] on: Error do: [PhratchError error: 'Cannot stop ask and stop bubbles' ]
]
