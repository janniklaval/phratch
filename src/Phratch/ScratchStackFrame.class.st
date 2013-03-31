"
A ScratchStackFrame describes the state of a ScratchProcess.

Each ScratchProcess has a pointer to a ScratchStackFrame containing its state. Whenever the ScratchProcess yields control, its ScratchStackFrame tells it exactly where it left off.

Structure:
  parentFrame	the ScratchStackFrame to return to when this one has been evaluated.
  expression		ArgMorph, BlockMorph, a collection of blocks to evaluate,
					#shouldYield or #returnMarker
  arguments		the OrderedCollection of arg values computed so far (if expression is a BlockMorph)
  pc				the index of the next block to evaluate (if expression is a Collection)
  startTime		the time at which evaluation began (if expression is a timed CommandBlockMorph)
  startValue		the starting value for interpolation (if expression is a timed CommandBlockMorph)
  shouldUnlight	a Boolean that indicates if we should unlight the current expression (a block)

"
Class {
	#name : #ScratchStackFrame,
	#superclass : #Object,
	#instVars : [
		'parentFrame',
		'expression',
		'arguments',
		'pc',
		'startTime',
		'startValue',
		'shouldUnlight'
	],
	#category : #'Phratch-Execution Engine'
}

{ #category : #accessing }
ScratchStackFrame >> addArgument: aValue [
	"Adds this value to the list of evaluated arguments available in this stack frame."

	arguments add: aValue.

]

{ #category : #accessing }
ScratchStackFrame >> arguments [
	"Answers the values of the arguments to be sent to the current command."

	^ arguments

]

{ #category : #accessing }
ScratchStackFrame >> expression [

	^ expression

]

{ #category : #accessing }
ScratchStackFrame >> expression: anExpression [

	expression := anExpression.

]

{ #category : #initialization }
ScratchStackFrame >> initialize [

	parentFrame := nil.
	expression := nil.
	arguments := OrderedCollection new. 
	pc := 1.
	shouldUnlight := false.

]

{ #category : #accessing }
ScratchStackFrame >> parentFrame [

	^ parentFrame

]

{ #category : #accessing }
ScratchStackFrame >> parentFrame: aScratchStackFrame [
	"Sets this frame's parent frame."

	parentFrame := aScratchStackFrame.

]

{ #category : #accessing }
ScratchStackFrame >> pc [
	"Answers the current program counter."

	^ pc

]

{ #category : #accessing }
ScratchStackFrame >> pc: anInteger [
	"Set the program counter to the current index, indicating the next block to evaluate."

	pc := anInteger.

]

{ #category : #accessing }
ScratchStackFrame >> printOn: aStream [

	aStream nextPutAll: '[', expression printString, ' ', shouldUnlight printString, ']'.
]

{ #category : #accessing }
ScratchStackFrame >> shouldUnlight [

	^ shouldUnlight

]

{ #category : #accessing }
ScratchStackFrame >> shouldUnlight: aBoolean [

	shouldUnlight := aBoolean.

]

{ #category : #accessing }
ScratchStackFrame >> shouldYield [
	"Answers true iff this is a dummy frame simply indicating that the process should yield control."

	^ expression = #shouldYield

]

{ #category : #accessing }
ScratchStackFrame >> shouldYield: aBoolean [
	"Makes this into a special stack frame that tells the evaluator to yield control to another process. When this flag is set, the rest of the stack frame is ignored."

	aBoolean
		ifTrue: [expression := #shouldYield]
		ifFalse: [self error: 'Should not call shouldYield: with false.'].

]

{ #category : #accessing }
ScratchStackFrame >> startTime [

	^ startTime

]

{ #category : #accessing }
ScratchStackFrame >> startTime: mSecs [
	"Record the starting time for an interpolating command."
	
	startTime := mSecs.

]

{ #category : #accessing }
ScratchStackFrame >> startValue [

	^ startValue

]

{ #category : #accessing }
ScratchStackFrame >> startValue: aTime [
	"Record the starting value for an interpolating command."
	
	startValue := aTime.

]

{ #category : #accessing }
ScratchStackFrame >> stopMIDI [

	(self startValue isKindOf: ScratchNotePlayer)
		ifTrue: [startValue noteOff].

]

{ #category : #accessing }
ScratchStackFrame >> stopMotors [

	| motorName |
	(expression isKindOf: CommandBlockMorph) ifTrue: [
		#motorOnFor:elapsed:from: = expression selector ifTrue: [
			motorName := startValue.
			expression receiver motorOff: motorName]].

]

{ #category : #accessing }
ScratchStackFrame >> stopTalkThinkAsk [

	| s |
	(expression isKindOf: CommandBlockMorph) ifTrue: [
		((#say:duration:elapsed:from: = expression selector) |
		 (#think:duration:elapsed:from: = expression selector)) ifTrue: [
			expression receiver sayNothing].

		#doAsk = expression selector ifTrue: [
			(s := expression receiver ownerOrYourselfThatIsA: ScratchStageMorph) ifNotNil: [s stopAsks]]].

]
