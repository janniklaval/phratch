Extension { #name : #PhratchProcess }

{ #category : #'*PhratchSensing' }
PhratchProcess >> doAsk [
	"Ask the user a question and wait until the user types some text and hits the accept button."

	| block args question prompter |

	block := stackFrame expression.
	args := stackFrame arguments.
	"first time (args size = 0): open prompter"
	args size = 0
		ifTrue: [
			block receiver promptInProgress ifTrue: [
				self pushStackFrame: (PhratchStackFrame new shouldYield: true).
				^ self].
			question := block args first "asString".
			prompter := block receiver promptForInput: question]
		ifFalse: [
			prompter := args first].

	"if all processes have stopped, pop this frame and we're done."
	prompter isDone ifTrue: [^ self popStackFrame].

	"Set up the wait loop. We need to:
		1.  yield to another process
		2.  evaluate the termination expression again
	Push these onto stack in reverse order."

	"2.  evaluate this block again"
	"(Remove the current frame and replace it with one that will force the termination expression to be re-evaluated.)"

	self popStackFrameNoUnhightlight.
	self pushStackFrame: (PhratchStackFrame new expression: block; addArgument: prompter;
	yourself).

	"1.  yield to another process"
	self pushStackFrame: (PhratchStackFrame new shouldYield: true).

]
