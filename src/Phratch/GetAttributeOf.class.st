"
I am part of a command pattern.

My command pattern entry point is the class side method #handlesQuery: which is used to filter the handler needed depending of the selector provided in the block spec.

Then, I am overriding #defaultArguments to provide my specific default values.
"
Class {
	#name : #GetAttributeOf,
	#superclass : #PhratchCommandHandler,
	#category : #'Phratch-DefaultArguments'
}

{ #category : #protocol }
GetAttributeOf class >> handlesQuery: sel [

	^ sel == #getAttribute:of:
]

{ #category : #protocol }
GetAttributeOf >> defaultArguments [
	
	| list defaultArgs |
	(self model ownerOrYourselfThatIsAPhratchStageMorph)
		ifNotNil: [:stage | 
			list := stage submorphs select: [ :m | m isPhratchSpriteMorph ].
			list sort: [ :stage1 :stage2 | stage1 objName asLowercase < stage2 objName asLowercase ].
			defaultArgs := list size > 0
				ifTrue: [ Array with: 'x position' with: list first ]
				ifFalse: [ Array with: 'background #' with: stage ] ]
		ifNil: [ defaultArgs := Array with: 'x position' with: self model ].
		
	^ defaultArgs
]
