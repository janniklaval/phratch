Extension { #name : #PhratchProcess }

{ #category : #'*PhratchDebugger' }
PhratchProcess >> doPauseThread [

	self nextStep.
	self popStackFrame.


]

{ #category : #'*PhratchDebugger' }
PhratchProcess >> doPauseThreadReporter [
	| value args |
	self nextStep.
	args := stackFrame arguments.	"Evaluate the argument, if necessary."
	args size < stackFrame expression argumentCount
		ifTrue: [ ^ self evaluateNextArgument ].	"Remember the return value."
	value := args size > 0
		ifTrue: [ args first ]
		ifFalse: [ nil ].
	answer := value.
	self returnValueToParentFrame: value.
	stackFrame ifNotNil: [ self popStackFrame ]
]

{ #category : #'*PhratchDebugger' }
PhratchProcess >> jumpOver [
	| cb |
	cb := self currentBlock.
	blockToDebug := nil.
	nextBlockToDebug := cb nextBlock.
	isPaused := false
]
