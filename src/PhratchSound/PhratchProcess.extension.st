Extension { #name : #PhratchProcess }

{ #category : #'*PhratchSound' }
PhratchProcess >> doPlaySoundAndWait [
	"Play a sound and block until it has finished playing."

	| block args soundName snd |
	block := stackFrame expression.
	args := stackFrame arguments.

	"first time: send the event and collect a list of processes"
	args size = 0
		ifTrue: [
			soundName := block args first.
			snd := block receiver soundNamed: soundName ifAbsent: [^ self popStackFrame].
			snd playFromStart]
		ifFalse: [
			snd := args first].

	"if sound has stopped, pop this frame and we're done"
	snd isPlaying ifFalse: [ ^ self popStackFrame].

	"Set up the wait loop. We need to:
		1.  yield to another process
		2.  evaluate our termination condition again
	Push these onto stack in reverse order."

	"2.  evaluate this block again"
	"(Remove the current frame and replace it with one that will force the termination condition to be re-evaluated.)"
	self popStackFrameNoUnhightlight.
	self pushStackFrame: (PhratchStackFrame new
		expression: block;
		addArgument: snd;
		yourself).

	"1.  yield to another process"
	self pushStackFrame: (PhratchStackFrame new shouldYield: true).

]
