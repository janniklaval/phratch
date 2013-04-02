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
	#name : #PhratchStackFrame,
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
PhratchStackFrame >> addArgument: aValue [
	"Adds this value to the list of evaluated arguments available in this stack frame."

	arguments add: aValue.

]

{ #category : #accessing }
PhratchStackFrame >> arguments [
	"Answers the values of the arguments to be sent to the current command."

	^ arguments

]

{ #category : #accessing }
PhratchStackFrame >> expression [

	^ expression

]

{ #category : #accessing }
PhratchStackFrame >> expression: anExpression [

	expression := anExpression.

]

{ #category : #initialization }
PhratchStackFrame >> initialize [

	parentFrame := nil.
	expression := nil.
	arguments := OrderedCollection new. 
	pc := 1.
	shouldUnlight := false.

]

{ #category : #accessing }
PhratchStackFrame >> parentFrame [

	^ parentFrame

]

{ #category : #accessing }
PhratchStackFrame >> parentFrame: aPhratchStackFrame [
	"Sets this frame's parent frame."

	parentFrame := aPhratchStackFrame.

]

{ #category : #accessing }
PhratchStackFrame >> pc [
	"Answers the current program counter."

	^ pc

]

{ #category : #accessing }
PhratchStackFrame >> pc: anInteger [
	"Set the program counter to the current index, indicating the next block to evaluate."

	pc := anInteger.

]

{ #category : #accessing }
PhratchStackFrame >> printOn: aStream [

	aStream nextPutAll: '[', expression printString, ' ', shouldUnlight printString, ']'.
]

{ #category : #accessing }
PhratchStackFrame >> shouldUnlight [

	^ shouldUnlight

]

{ #category : #accessing }
PhratchStackFrame >> shouldUnlight: aBoolean [

	shouldUnlight := aBoolean.

]

{ #category : #accessing }
PhratchStackFrame >> shouldYield [
	"Answers true iff this is a dummy frame simply indicating that the process should yield control."

	^ expression = #shouldYield

]

{ #category : #accessing }
PhratchStackFrame >> shouldYield: aBoolean [
	"Makes this into a special stack frame that tells the evaluator to yield control to another process. When this flag is set, the rest of the stack frame is ignored."

	aBoolean
		ifTrue: [expression := #shouldYield]
		ifFalse: [self error: 'Should not call shouldYield: with false.'].

]

{ #category : #accessing }
PhratchStackFrame >> startTime [

	^ startTime

]

{ #category : #accessing }
PhratchStackFrame >> startTime: mSecs [
	"Record the starting time for an interpolating command."
	
	startTime := mSecs.

]

{ #category : #accessing }
PhratchStackFrame >> startValue [

	^ startValue

]

{ #category : #accessing }
PhratchStackFrame >> startValue: aTime [
	"Record the starting value for an interpolating command."
	
	startValue := aTime.

]

{ #category : #accessing }
PhratchStackFrame >> stopMIDI [

	(self startValue isKindOf: PhratchNotePlayer)
		ifTrue: [startValue noteOff].

]

{ #category : #accessing }
PhratchStackFrame >> stopMotors [

	| motorName |
	(expression isKindOf: CommandBlockMorph) ifTrue: [
		#motorOnFor:elapsed:from: = expression selector ifTrue: [
			motorName := startValue.
			expression receiver motorOff: motorName]].

]

{ #category : #accessing }
PhratchStackFrame >> stopTalkThinkAsk [

	| s |
	(expression isKindOf: CommandBlockMorph) ifTrue: [
		((#say:duration:elapsed:from: = expression selector) |
		 (#think:duration:elapsed:from: = expression selector)) ifTrue: [
			expression receiver sayNothing].

		#doAsk = expression selector ifTrue: [
			(s := expression receiver ownerOrYourselfThatIsA: PhratchStageMorph) ifNotNil: [s stopAsks]]].

]
