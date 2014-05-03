"
A ScratchProcess is what brings a stack of blocks to life. The process keeps track of which block to run next, evaluates block arguments, handles control structures, and so forth.

The ScratchFrameMorph is the scheduler, telling each process when to run by calling its runStep method. The runStep method will execute some number of blocks, then voluntarily yield control so that the ScratchFrameMorph can run another process. The etiquette is that a process should yield control at the end of every loop iteration, and while it is running a timed command (e.g. ""wait 5 secs"") or a synchronous command (e.g. ""broadcast xxx and wait"").

Structure:
  stackFrame		the ScratchStackFrame describing the current state of this process
  readyToYield		boolean indicating whether to yield control to another process
  errorFlag			boolean indicating whether an error was encountered
  readyToTerminate	boolean indicating whether the stop method has been called

"
Class {
	#name : #PhratchProcess,
	#superclass : #Object,
	#instVars : [
		'stackFrame',
		'topBlock',
		'readyToYield',
		'errorFlag',
		'readyToTerminate',
		'blockVarList',
		'answer',
		'atomicityList',
		'tempVars',
		'scriptList',
		'isPaused',
		'timeOffset',
		'blockToDebug',
		'nextBlockToDebug',
		'doneWithDebugging'
	],
	#classVars : [
		'BlockHighlightMSecs'
	],
	#category : #'Phratch-Execution Engine'
}

{ #category : #'class variables' }
PhratchProcess class >> blockHighlightMSecs [

	^ BlockHighlightMSecs

]

{ #category : #'class variables' }
PhratchProcess class >> blockHighlightMSecs: aNumber [

	BlockHighlightMSecs := aNumber.

]

{ #category : #'class initialization' }
PhratchProcess class >> initialize [
"self initialize"
	BlockHighlightMSecs := 1.

]

{ #category : #accessing }
PhratchProcess >> answer [
	^answer
]

{ #category : #'private-evaluation' }
PhratchProcess >> applyPrimitive [
	"Apply the current expression (which must be a CommandBlock) to the current arguments (which must all have been evaluated)."

	| value |
	value := stackFrame expression evaluateWithArgs: stackFrame arguments.

	"save the return value in the parent frame before popStackFrame because popFrame adds a frame while single-stepping"
	self returnValueToParentFrame: value.
	self popStackFrame.


]

{ #category : #'private-evaluation' }
PhratchProcess >> applyTimedCommand [
	"Applies the current command to the already evaluated list of arguments over a particular time interval."

	| block arguments currentTime startTime args totalMSecs elapsedMSecs |
	block := stackFrame expression.
	arguments := stackFrame arguments.

	"Do we still need to evaluate more arguments?"
	arguments size < block argumentCount ifTrue: [^ self evaluateNextArgument].
	arguments := block coerceArgs: arguments.

	"Record or get the time when command was first invoked."
	currentTime := Time millisecondClockValue.
	startTime := stackFrame startTime.
	startTime ifNil: [  "first call; just set starting time and value"
		timeOffset := nil.
		args := arguments asArray, (Array with: 0 with: nil).
		stackFrame startValue: (block receiver perform: block selector withArguments: args).
		stackFrame startTime: currentTime.
		readyToYield := true.
		^ self].

	isPaused ifTrue: [
		timeOffset ifNil: [
			timeOffset := currentTime - startTime].
		readyToYield := true.
		^ self].

	timeOffset ifNotNil: [
		
		startTime := currentTime - timeOffset.
		stackFrame startTime: startTime ]. "resume after pause -jens"

	timeOffset := nil.

	"Call primitive time command with its arguments and the elapsed time in seconds"
	totalMSecs := arguments last * 1000.
	block selector = #glideSecs:toX:y:elapsed:from: ifTrue: [totalMSecs := arguments first * 1000].
	block selector = #mwait:elapsed:from: ifTrue: [totalMSecs := arguments last].
	({ #drum:duration:elapsed:from: . #noteOn:duration:elapsed:from:} includes: block selector)
		ifTrue: [totalMSecs := (60000 * arguments second) / block receiver tempo].
	block selector = #rest:elapsed:from:
		ifTrue: [totalMSecs := (60000 * arguments first) / block receiver tempo].

	elapsedMSecs := currentTime - startTime.

	currentTime < startTime ifTrue: [elapsedMSecs := totalMSecs].  "clock wrap"
	args := arguments asArray, (Array with: elapsedMSecs with: stackFrame startValue).
	block receiver perform: block selector withArguments: args.

	"If not done, then we leave stack as is and yield."
	elapsedMSecs < totalMSecs ifTrue: [
		readyToYield := true.
		^ self].

	"Pop this command off the stack and return."
	self popStackFrame


]

{ #category : #'BYOB-variables' }
PhratchProcess >> bindStopBlocksIn: blockSequence to: aStackFrame [

	blockSequence do: [:block |
		block allMorphsDo: [:m |
			((m isCommandBlockMorph) and: [(#(doStopBlock doAnswer) includes: m selector )]) ifTrue: [
				m stopFrame: aStackFrame]]]
]

{ #category : #'BYOB-variables' }
PhratchProcess >> bindVarsIn: blockSequence to: aVariableFrame [

	blockSequence do: [:block |
		block allMorphsDo: [:m | 
			((m isVariableBlockMorph) | (m isSetterBlockMorph)
			and: [m isSpecialForm & (aVariableFrame scope includes: m variable)]) ifTrue: [
				m receiver: aVariableFrame ]]].
]

{ #category : #'BYOB-variables' }
PhratchProcess >> changeVar [

	| block arguments argExp environment |

	block := stackFrame expression.
	arguments := stackFrame arguments.

	"Evaluate the arg if we haven't already."
	arguments size = 0
		ifTrue:	[argExp := block argumentAt: 2.
				^self pushStackFrame: (PhratchStackFrame new expression: argExp)].

	(block receiver isVariableFrame) 
		ifTrue: [ environment := block receiver ]
		ifFalse: [ (blockVarList notNil and: [blockVarList isEmpty not])
			ifTrue: [ environment := blockVarList last ]].
	environment ifNotNil: [
		environment changeVar: (block argumentAt: 1) evaluate by: arguments first ].
	self popStackFrame.
]

{ #category : #'private-special forms' }
PhratchProcess >> closeCustomBlock [

	blockVarList ifNotNil: [  blockVarList size > 0 ifTrue: [
		blockVarList removeLast.
		atomicityList removeLast.
		scriptList removeLast ]].
	stackFrame ifNotNil: [self popStackFrame ].

	nextBlockToDebug ifNotNil: [self nextStep]
	

]

{ #category : #'BYOB-pause/resume' }
PhratchProcess >> currentBlock [
	stackFrame ifNil: [^nil].
	(stackFrame expression isBlockMorph)
		ifFalse: [^nil].
	^ stackFrame expression
]

{ #category : #'BYOB-variables' }
PhratchProcess >> currentEnvironment [
	"private"

	blockVarList ifNotNil: [
		blockVarList size > 0 ifTrue: [
			^ blockVarList last]].
	^ nil
]

{ #category : #'private-special forms' }
PhratchProcess >> doAnswer [
	"Evaluates its argument, and returns the value to the frame from which the current method was called."

	| value args zap |
	args := stackFrame arguments.	"Evaluate the argument, if necessary."
	args size < stackFrame expression argumentCount
		ifTrue: [ ^ self evaluateNextArgument ].	"Remember the return value."
	value := args size > 0
		ifTrue: [ args first ]
		ifFalse: [ nil ].
	answer := value.
	zap := [ 
	[ stackFrame isNil or: [ stackFrame expression = #closeCustomBlock ] ] whileFalse: [ self popStackFrame ].
	self closeCustomBlock ].
	zap value.	"get out of a custom C-shape command slot"
	[ 
	stackFrame notNil
		and: [ (stackFrame expression isArray) and: [ stackFrame expression first isMultiArgCommandBlockMorph ] ] ]
		whileTrue: [ 
			zap value.
			zap value ].
	[ stackFrame notNil and: [ stackFrame parentFrame notNil and: [ stackFrame parentFrame expression = #shouldYield ] ] ]
		whileTrue: [ 
			zap value.
			zap value ].
	self returnValueToParentFrame: value.
	stackFrame ifNotNil: [ self popStackFrame ]
]

{ #category : #'private-special forms' }
PhratchProcess >> doApplyEval [
	"execute a user-defined block"

	| block script lambda varsFrame parms emptySlots nestedLambdas argsList stage stopFrame |

	"self isAtomic." "allow escaping out of infinite recursion"
	block := stackFrame expression.

	"evaluate arguments, if necessary"

	stackFrame arguments size < block argumentCount
		ifTrue: [^ self evaluateNextArgument].

	#doCustomBlock = block selector
		ifTrue: [
			lambda := block.
			argsList := stackFrame arguments]
		ifFalse: [
			lambda := stackFrame arguments first.
			argsList := #().
			stackFrame arguments size > 2  ifTrue: [
				(block selector endsWith: 'BlockWithArgList') ifTrue: [
					argsList := stackFrame arguments third asArray].
				(block selector endsWith: 'BlockWithArgs') ifTrue: [
					argsList := stackFrame arguments copyFrom: 3 to: stackFrame arguments size]]].

	script := lambda sequence collect: [:eachBlock | eachBlock fullCopy].
	atomicityList ifNil: [atomicityList := OrderedCollection new].
	atomicityList add: lambda isAtomic.
	blockVarList ifNil: [blockVarList := OrderedCollection new].
	blockVarList add: (VariableFrame forNames: lambda allVarNames).
	varsFrame := blockVarList last.


	"Step 0:  If the block being called provides explicit formal parameters
	(INPUT NAMES), then replace every formal parameter reference in the body
	with the corresponding actual argument value.  Do not do any automatic
	substitution of arguments into empty/default slots.  Otherwise:

	Step 1:  If the total number of empty + default input slots in the
	block being called is exactly equal to the number of actual arguments
	provided (no special treatment for explicit empty actual arguments -- it's
	the empty string as the argument), 	then fill every empty + default slot 
	with the corresponding actual argument.

	Step 2:  If step 1 fails, but the total number of empty (not default) input
	slots in the block being called is exactly equal to the number of actual
	arguments provided, then fill every empty (not default) slot with the
	corresponding actual argument.

	Step 3:  If steps 1 and 2 fail, but the number of actual arguments
	provided is 1, then fill every empty (not default) slot with that argument.

	Step 4:  If steps 1-3 fail, do not do any automatic substitution at all.

	Variadic inputs"


 	"bind formal parameters"

	parms := lambda parameterNames.
	parms size > 0
		ifTrue: [
			1 to: parms size do: [:i|
				argsList size >= i ifTrue: [
					varsFrame setVar: (parms at: i) to: (argsList at: i)]]]

		ifFalse: [ argsList size > 0 ifTrue: [

			"distribute implicit parameters"

			"collect all empty slots and nested lambdas"

			emptySlots := OrderedCollection new.
			"emptyDefaults := OrderedCollection new."
			nestedLambdas := OrderedCollection new.
			script do: [:eachBlock |
				eachBlock allMorphs do: [:m |
					(m isArgMorph) 
						ifTrue: [
							m isEmptySlot ifTrue: [
								emptySlots add: m.

"--- rule 1 commented out for now -------------------------------------------------------------------------------------------------

								default := m defaultValue.
								default ifNotNil: [
									emptyDefaults add: m ]

------------------------------------------------------------------------------------------------------------------------------------------"

															]]
						ifFalse: [ (m isLambdaBlockMorph)
							ifTrue: [nestedLambdas add: m]]]].

			"remove slots in nested lambdas from list"
			nestedLambdas do: [:l |
				emptySlots removeAllSansError: l allMorphs.

"--- rule 1 commented out for now -------------------------------------------------------------------------------------------------

				emptyDefaults removeAll: l allMorphs 

------------------------------------------------------------------------------------------------------------------------------------------"


														].


"--- rule 1 commented out for now -------------------------------------------------------------------------------------------------

			emptyDefaults size = argsList size
				ifTrue: [
	
					""fill every empty+default slot with the corresponding actual argument,
					substitute empty string for default value""
	
					1 to: emptySlots size do: [:i |
						| obj slot |
						slot := emptySlots at: i.
	
						""empty variadic inputs absorb all ensuing values""
						(slot isMultiArgMorph) 
							ifTrue: [ obj := PhratchListMorph on: argsList from: i to: argsList size]
							ifFalse: [
								obj := argsList at: i.
								(obj isReporterBlockMorph)
									ifTrue: [ obj := obj evaluate ]
									ifFalse: [ obj = '' asUTF8 
										ifTrue: [ obj := slot defaultValue]]].
						slot implicitValue: obj ]]

				ifFalse: [


------------------------------------------------------------------------------------------------------------------------------------------"

						 (emptySlots size = argsList size or: [argsList size > emptySlots size and: [emptySlots size > 0 and: [emptySlots last isMultiArgMorph]]])
					ifTrue: [
						"fill every empty (not default) slot with the corresponding actual argument"
	
						1 to: emptySlots size do: [:i |
							| obj slot |
							slot := emptySlots at: i.
		
							"empty variadic inputs absorb all ensuing values"
							(slot isMultiArgMorph) 
								ifTrue: [ obj := PhratchListMorph on: argsList from: i to: argsList size]
								ifFalse: [
									obj := argsList at: i.
									(obj isReporterBlockMorph)
										ifTrue: [ obj := obj evaluate ]].
							slot implicitValue: obj ]]
	
					ifFalse: [argsList size = 1 ifTrue: [

						"put the single parameter into every empty slot"

						| prm |
						prm := argsList first.
						(prm isReporterBlockMorph)
							ifTrue: [prm := prm evaluate ].
						emptySlots do: [:slot|
							(slot isMultiArgMorph)
								ifTrue: [slot implicitValue: (PhratchListMorph with: prm)]
								ifFalse: [slot implicitValue: prm]]]]]"]"].

	scriptList ifNil: [scriptList := OrderedCollection new].
	scriptList add: script.

	self bindVarsIn: script to: varsFrame.

	"bind externalized local vars"

	#doCustomBlock = block selector ifTrue: [
		| templates aliases argMorphs |

		templates := block definition templates.
		templates ifNotNil: [
			argMorphs := block argMorphs.
			aliases := Dictionary new.
			templates keysDo: [:i |
				aliases at: (argMorphs at: i) variable put: (templates at: i)].
			argsList do: [:eachArg | (eachArg isLambdaBlockMorph) ifTrue: [
				aliases keysDo: [:vName |
					eachArg bind: vName to: varsFrame as: (aliases at: vName)]]]]].

	(block isReporter and: [lambda isFunction]) ifFalse: [self popStackFrame].

	(block selector beginsWith: 'doFork')
		ifTrue: [
			stage := block receiver ownerOrYourselfThatIsAPhratchStageMorph.
			"self popStackFrame."
			stage startProcessForSequence: scriptList]
		ifFalse: [
			stopFrame := PhratchStackFrame new expression: #closeCustomBlock.
			self pushStackFrame: stopFrame.
			(#(doCustomBlock doAnswer) includes: block selector) ifTrue: [
				self bindStopBlocksIn: script to: stopFrame].
			self pushStackFrame: (PhratchStackFrame new expression: script)]
]

{ #category : #'private-special forms' }
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

{ #category : #'private-special forms' }
PhratchProcess >> doBroadcastAndWait [
	"Broadcast an event and wait until all processes started by that broadcast have terminated."

	| block args eventName stage procs arg vars|
	block := stackFrame expression.
	args := stackFrame arguments.

	"first time: send the event and collect a list of processes"
	args size = 0
		ifTrue: [
			eventName := block args first asString.
			eventName = '0' ifTrue: [
				arg := block argMorphs first.
				blockVarList ifNotNil: [blockVarList isEmpty ifFalse: [
					vars := blockVarList last.
					eventName := (vars getVar: arg variable) asString ]]].
			stage := block receiver ownerOrYourselfThatIsAPhratchStageMorph.
			procs := stage broadcastEventNamed: eventName with: 0]
		ifFalse: [
			procs := args first].

	"if all processes have stopped, pop this frame and we're done."
	(procs select: [:p | p isRunning]) size = 0 ifTrue: [^ self popStackFrame].

	"Set up the wait loop. We need to:
		1.  yield to another process
		2.  evaluate the termination expression again
	Push these onto stack in reverse order."

	"2.  evaluate this block again"
	"(Remove the current frame and replace it with one that will force the termination expression to be re-evaluated.)"
	self popStackFrameNoUnhightlight.
	self pushStackFrame: (PhratchStackFrame new expression: block; addArgument: procs;
		yourself).

	"1.  yield to another process"
	self pushStackFrame: (PhratchStackFrame new shouldYield: true).

]

{ #category : #'private-special forms' }
PhratchProcess >> doCallBlockWithArgList [
	self doApplyEval
]

{ #category : #'private-special forms' }
PhratchProcess >> doCallBlockWithArgs [
	self doApplyEval
]

{ #category : #'private-special forms' }
PhratchProcess >> doCustomBlock [
	self doApplyEval
]

{ #category : #'private-special forms' }
PhratchProcess >> doDeclareVariables [
	| block env |
	block := stackFrame expression.
	env := (blockVarList notNil and: [ blockVarList size > 0 ])
		ifTrue: [ blockVarList last ]
		ifFalse: [ tempVars ].
	block variables do: [ :var | env add: var ].
	(scriptList notNil and: [ scriptList size > 0 ])
		ifTrue: [ self bindVarsIn: scriptList last to: env ]
		ifFalse: [ self bindVarsIn: block blockSequence to: env ].
	self popStackFrame
]

{ #category : #'private-special forms' }
PhratchProcess >> doForever [
	"Executes one iteration of a forever loop."

	"Right now, the forever special form is at the top of the stack.  We're going to add two more things on top of this:  (1) a frame for evaluating the blocks in the forever block, and (2) a frame that just results in yielding control.  That way we'll evaluate the contents of the block, give up control, and do it all again."

	| blocks |
	"Remember blocks to evaluate before we clobber the stack."
	blocks := stackFrame expression firstBlockList.	

	"When we're all done with these blocks, we want to yield."
	self pushStackFrame: (PhratchStackFrame new shouldYield: true).

	"First, we want to evaluate the blocks inside the loop."
	self pushStackFrame: (PhratchStackFrame new expression: blocks).

]

{ #category : #'private-special forms' }
PhratchProcess >> doForeverIf [
	"Executes one iteration of a forever loop."

	| block args |
	block := stackFrame expression.
	args := stackFrame arguments.

	"evaluate the condition if we haven't yet"
	args size < 1 ifTrue: [^ self evaluateNextArgument].

	"remove the current frame and replace it with one that will force the test expression to be re-evaluated."
	self popStackFrameNoUnhightlight.
	self pushStackFrame: (PhratchStackFrame new expression: block).
	self pushStackFrame: (PhratchStackFrame new shouldYield: true). "yield after possibly running body"

	"if the condition was true, run the body"
	args first = true ifTrue: [
		self pushStackFrame: (PhratchStackFrame new expression: block firstBlockList)].


]

{ #category : #'private-special forms' }
PhratchProcess >> doFork [

	self doApplyEval
]

{ #category : #'private-special forms' }
PhratchProcess >> doForkBlockWithArgList [
	self doApplyEval
]

{ #category : #'private-special forms' }
PhratchProcess >> doForkBlockWithArgs [
	self doApplyEval
]

{ #category : #'private-special forms' }
PhratchProcess >> doIf [
	"Evaluate the current expression (which must be an if)."

	| block arguments argExp |
	
	block := stackFrame expression.
	arguments := stackFrame arguments.

	"Evaluate the arg if we haven't already."
	arguments size = 0
		ifTrue:	[argExp := block argumentAt: 1.
				^self pushStackFrame: (PhratchStackFrame new expression: argExp)].

	"We can pop this expression off the stack either way."
	self popStackFrame.

	"If the predicate was false, just return."
	arguments first = true
		ifFalse: [^self].

	"Since the predicate was true, evaluate the body of the if."
	self pushStackFrame: (PhratchStackFrame new expression: block firstBlockList).
]

{ #category : #'private-special forms' }
PhratchProcess >> doIfElse [
	"Evaluate the current expression (which must be an if-then-else)."

	| block arguments argExp |
	block := stackFrame expression.
	arguments := stackFrame arguments.

	"evaluate the arg if we haven't already."
	arguments size = 0 ifTrue: [
		argExp := block argumentAt: 1.
		^ self pushStackFrame: (PhratchStackFrame new expression: argExp)].

	"we can pop this expression off the stack either way"
	self popStackFrame.

	arguments first = true
		ifTrue: [self pushStackFrame: (PhratchStackFrame new expression: block trueBlockList)]
		ifFalse: [self pushStackFrame: (PhratchStackFrame new expression: block falseBlockList)].

]

{ #category : #'private-special forms' }
PhratchProcess >> doMakeNewList [
	| block list |

	block := stackFrame expression.

	"evaluate arguments, if necessary"
	stackFrame arguments size < block argumentCount
		ifTrue: [^ self evaluateNextArgument].

	list := PhratchListMorph new.
	list listName: '' target: nil.
	stackFrame arguments do: [:arg |	
		list insertLine: (ScriptablePhratchMorph new asListElement: arg) at: (list lineCount + 1) ].
	list updateCountMorph.
	list fixLayout.

	answer := list.
	self returnValueToParentFrame: list.
	self popStackFrame

]

{ #category : #'BYOB-pause/resume' }
PhratchProcess >> doPauseThread [

	self nextStep.
	self popStackFrame.


]

{ #category : #'BYOB-pause/resume' }
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

{ #category : #'private-special forms' }
PhratchProcess >> doRepeat [
	"Handles one iteration of a repeat block."

	| arguments argExp block counter frame |

	block := stackFrame expression.
	arguments := stackFrame arguments.

	"If we haven't done so yet, evaluate the argument to repeat."
	arguments size < 1
		ifTrue:	[argExp := block argumentAt: 1.
				^self pushStackFrame: (PhratchStackFrame new expression: argExp)].

	"If the number of times to repeat is 0, then we're done."
	counter := arguments first asNumberNoError.
	counter <= 0 ifTrue:	[^ self popStackFrame].

	"Pop this instruction from the stack."
	self popStackFrameNoUnhightlight.

	"At top of stack should now be:
		1.  evaluate body of repeat block.
		2.  yield.
		3.  evaluate repeat block with decremented counter value.
	Need to add these to the stack in reverse order."

	"3.  evaluate repeat block with decremented counter value."
	frame := PhratchStackFrame new
				expression:		block;
				addArgument:	counter - 1;
		yourself.
	self pushStackFrame: frame.

	"2.  yield."
	self isAtomic ifFalse: [ self pushStackFrame: (PhratchStackFrame new shouldYield: true) ].

	"1.  evaluate body of repeat block."
	self pushStackFrame: (PhratchStackFrame new expression: block firstBlockList).
]

{ #category : #'private-special forms' }
PhratchProcess >> doReport [
	self doApplyEval
]

{ #category : #'private-special forms' }
PhratchProcess >> doReturn [
	"Evaluates its argument, and returns the value to the frame from which the current method was called."

	| value args |
	args := stackFrame arguments.	"Evaluate the argument, if necessary."
	args size < stackFrame expression argumentCount
		ifTrue: [ ^ self evaluateNextArgument ].	"Remember the return value."
	value := args size > 0
		ifTrue: [ args first ]
		ifFalse: [ nil ].	"Pop until we're out of frames to pop, or we hit a return marker."
	[ stackFrame isNil ] whileFalse: [ self popStackFrame ].
	stackFrame
		ifNotNil: [ 
			self returnValueToParentFrame: value.
			self popStackFrame ]
]

{ #category : #'private-special forms' }
PhratchProcess >> doRun [
	self doApplyEval
]

{ #category : #'private-special forms' }
PhratchProcess >> doRunBlockWithArgList [
	self doApplyEval
]

{ #category : #'private-special forms' }
PhratchProcess >> doRunBlockWithArgs [
	self doApplyEval
]

{ #category : #'private-special forms' }
PhratchProcess >> doStopBlock [
	"stops the current custom block"

	| stopFrame |
	stopFrame := stackFrame expression stopFrame.

	self popStackFrame.

	[stackFrame parentFrame isNil or: [stackFrame == stopFrame]] whileFalse: [
		stackFrame := stackFrame parentFrame].

	stackFrame ifNotNil: [
		self popStackFrame].


]

{ #category : #'private-special forms' }
PhratchProcess >> doUntil [
	"Evaluates the current until-loop expression."

	^self doUntil: true.
]

{ #category : #'private-special forms' }
PhratchProcess >> doUntil: terminatingBoolean [
	"Evaluates the current while or until loop expression until the loop condition evaluates to the boolean terminating value."

	| args block |

	block := stackFrame expression.
	args := stackFrame arguments.

	"Evaluate the condition if we haven't yet."
	args size < 1
		ifTrue: [^self evaluateNextArgument].

	"If the condition matches the terminatingBoolean, pop this frame and we're done."
	args first = terminatingBoolean = true ifTrue: [^self popStackFrame].

	"Set up for an iteration of the while loop.  We need to:
		1.  evaluate the body
		2.  yield to another process
		3.  evaluate the while/until block again
	Push these onto stack in reverse order."

	"3.  evaluate the while/until block again"
	"(We remove the current frame and replace it with one that will force the argument to be re-evaluated.)"
	self popStackFrameNoUnhightlight.
	self pushStackFrame: (PhratchStackFrame new expression: block).

	"2.  yield to another process"
	self isAtomic ifFalse: [self pushStackFrame: (PhratchStackFrame new shouldYield: true)].
	
	"1.  evaluate the body"
	self pushStackFrame: (PhratchStackFrame new expression: block firstBlockList).

]

{ #category : #'private-special forms' }
PhratchProcess >> doWaitUntil [
	"Evaluates the the wait condition until it evaluates to true."

	| block args hasBoolean|
	block := stackFrame expression.
	args := stackFrame arguments.
	
	hasBoolean := block submorphs last submorphs size > 0.

	hasBoolean ifFalse: [^ self popStackFrame].
	"evaluate the termination expression if we haven't yet."
	args size < 1 ifTrue: [^ self evaluateNextArgument].

	"if the termination condition is met, pop this frame and we're done."
	args first = true ifTrue: [^ self popStackFrame].

	"Set up for waitUntil loop. We need to:
		1.  yield to another process
		2.  evaluate the termination expression again
	Push these onto stack in reverse order."

	"2.  evaluate this block again"
	"(Remove the current frame and replace it with one that will force the termination expression to be re-evaluated.)"
	self popStackFrameNoUnhightlight.
	self pushStackFrame: (PhratchStackFrame new expression: block).

	"1.  yield to another process"
	self pushStackFrame: (PhratchStackFrame new shouldYield: true).

]

{ #category : #'private-special forms' }
PhratchProcess >> doWhile [
	"Evaluates the current while-loop expression."
	
	^self doUntil: false.
]

{ #category : #'panther actions' }
PhratchProcess >> doWithCamOpen [
	"Evaluate the current expression (which must be a do w/ cam open)."

	| block success |

	block := stackFrame expression.
	"arguments := stackFrame arguments."

	"Evaluate the arg if we haven't already.
	arguments size = 0
		ifTrue:	[argExp := block argumentAt: 1.
				^self pushStackFrame: (ScratchStackFrame new expression: argExp)]."

	success := false.
	(CameraPlugin openCamera: 1 width: 480 height: 360) ifNotNil: [
			CameraPlugin waitForCameraStart.
			(CameraPlugin frameExtent: 1) x = 0 ifFalse: [
				success := true]].
	"We can pop this expression off the stack either way."
	self popStackFrame.

	"If the camera wasn't opened, just return."
	success ifFalse: [^ self].

	ScriptablePhratchMorph cameraOpened.

	"Since the camera was opened, set up to
		1. evaluate the body of the do
		2. close the camera
	We must do these in reverse order."

	"2. close the camera"
	self pushStackFrame: (PhratchStackFrame new expression: (CommandBlockMorph new selector: #closeCamera; receiver: (block receiver);
		yourself)).


	self pushStackFrame: (PhratchStackFrame new expression: block firstBlockList).
]

{ #category : #accessing }
PhratchProcess >> errorFlag [
	"Answer true if this process has stopped due to an error."

	^ errorFlag

]

{ #category : #accessing }
PhratchProcess >> errorFlag: aBoolean [
	"Set the error flag for this process."

	| customBlocks |
	stackFrame expression isArray
		ifTrue: [ ^ self ].
	errorFlag := aBoolean.
	stackFrame expression showError.
	stackFrame expression topBlock showErrorFeedback.
	customBlocks := stackFrame expression receiver customBlocksContaining: stackFrame expression.
	customBlocks isEmpty
		ifTrue: [ ^ self ].
	topBlock allMorphs
		do: [ :m | 
			(customBlocks includes: m)
				ifTrue: [ m showError ] ].
	topBlock showErrorFeedback
]

{ #category : #'private-evaluation' }
PhratchProcess >> evaluateCommandFor: aStageMorph [
	"Evaluates the current block. If the argument is non-nil, redraw the stage."

	| expression |
	expression := stackFrame expression.
	BlockHighlightMSecs > 1 ifTrue: [expression litUp: true].

	((blockToDebug notNil and: [blockToDebug ~= self currentBlock]) or: [
		self currentBlock = nextBlockToDebug]) ifTrue: [
			((PhratchFrameMorph someInstance viewMode = #presentation) | doneWithDebugging) ifFalse: [
				self pause.
				DebuggerFrameMorph new on: self]].

	expression isSpecialForm ifTrue: [^ self evaluateSpecialForm].

	stackFrame ifNil: [
		answer isNil ifFalse: [ ^self]].


	"evaluate arguments, if necessary"
	stackFrame arguments size < expression argumentCount
		ifTrue: [^ self evaluateNextArgument].

	expression isTimed ifTrue: [^ self applyTimedCommand].

	self applyPrimitive.

self flag: 'maybe should be remove because not necesary'.
	aStageMorph ifNotNil: [
		aStageMorph updateTrailsForm.
		self isAtomic ifTrue: [^self].
		BlockHighlightMSecs = 1 ifTrue: [  "normal (non-turbo) mode; redraw after each cmd"
			World displayWorldSafely]].

]

{ #category : #'private-evaluation' }
PhratchProcess >> evaluateFor: aStageMorph [
	"Evaluates the current expression in the current environment for the given StageMorph."

	| expression |
	stackFrame shouldYield ifTrue: [^ self yield].
	expression := stackFrame expression.

	(expression isSymbol) ifTrue: [
		(#closeCustomBlock = expression) ifTrue: [
		^self closeCustomBlock]].

	stackFrame shouldUnlight ifTrue: [
		expression litUp: false.
		^ self popStackFrame].

	(expression isReporterScriptBlockMorph) ifTrue: [
		self returnValueToParentFrame: expression evaluate.
		^ self popStackFrame ].

	expression isCollection ifTrue: [^ self evaluateSequence].
	expression isArgMorph ifTrue: [^ self evaluateSelfEvaluating].
	expression isBlockMorph ifTrue: [^ self evaluateCommandFor: aStageMorph].

	self error: 'Unknown expression type:  ', expression printString.

]

{ #category : #'private-evaluation' }
PhratchProcess >> evaluateNextArgument [
	"Evaluates the next argument of the command in expression.  Requires that expression be a block that takes more args than are already evaluated in the current stack frame."

	| argumentExpression |

	argumentExpression := stackFrame expression argumentAt: stackFrame arguments size + 1. 

	stackFrame expression selector = #doCustomBlock ifTrue: [
		((argumentExpression isReporterBlockMorph) and: [
			#(unevaluated unevaluatedBoolean) includes: argumentExpression declaredType]) ifTrue: [
				argumentExpression := argumentExpression asLambda ]].

	self pushStackFrame: (PhratchStackFrame new expression: argumentExpression).
]

{ #category : #'private-evaluation' }
PhratchProcess >> evaluateSelfEvaluating [
	"The easiest case. Evaluate a number, color, or any self-evaluating expression."

	| value |
	value := stackFrame expression evaluate.
	self returnValueToParentFrame: value.
	self popStackFrame.

]

{ #category : #'private-evaluation' }
PhratchProcess >> evaluateSequence [
	"Requires that the current expression be a collection of blocks.  Evaluates the block in the current expression (which is a list of blocks) at the given pc."

	| blocks pc |

	blocks := stackFrame expression.
	pc := stackFrame pc.

	pc > blocks size
		ifTrue:	[self popStackFrame]
		ifFalse:	[stackFrame pc: pc + 1.
				self pushStackFrame: (PhratchStackFrame new expression: (blocks at: pc))].


]

{ #category : #'private-evaluation' }
PhratchProcess >> evaluateSpecialForm [
	"Evaluates the current special form expression.  Requires that no arguments have been evaluated, and that the current expression be a special form."

	|sel|

	stackFrame ifNil: [^ self].
	sel := stackFrame expression selector.
	sel ifNil: [sel := #nop].
	(#(getBlockVar: getVar:) includes: sel) ifTrue: [^self getVar].
	(#(setBlockVar:to: setVar:to:) includes: sel) ifTrue: [^self setVar].
	(#(changeBlockVar:by: changeVar:by:) includes: sel) ifTrue: [^self changeVar].

	self perform: sel.
]

{ #category : #accessing }
PhratchProcess >> expression: expression [
	"Sets the expression to evaluate. This can be a single block or a collection of blocks. It should only be called before running the process."

	stackFrame ifNotNil: [self error: 'Cannot modify expression'].
	stackFrame := PhratchStackFrame new expression: expression.

]

{ #category : #'BYOB-variables' }
PhratchProcess >> getVar [

	| vars block value|
	block := stackFrame expression.
	(block receiver isVariableFrame)
		ifTrue: [value := block evaluate]
		ifFalse: [
			value := 0.
			blockVarList ifNotNil: [blockVarList isEmpty ifFalse: [
				vars := blockVarList last.
				value := vars getVar: block variable ]]]. 
	self returnValueToParentFrame: value. 
	self popStackFrame.
]

{ #category : #'BYOB-variables' }
PhratchProcess >> getVarNamed: vName [ 
	"strictly dynamic without bindings!"

	| env block |
	block := stackFrame expression.
	(blockVarList notNil and: [blockVarList size > 0]) ifTrue: [
		env := blockVarList last.
		(env scope includes: vName)
			ifTrue: [ ^ env getVar: vName ]].
	(tempVars scope includes: vName)
		ifTrue: [^ tempVars getVar: vName ].
	^ block receiver getVar: vName

]

{ #category : #accessing }
PhratchProcess >> includesDeletedReceiver [
	"Answer true if I contain a block whose receiver has been deleted."

	self stackAsArray do: [:b |

		(b isCommandBlockMorph) ifTrue:[
			b receiver isNil
				ifTrue: [^ true ]
				ifFalse: [(b receiver isVariableFrame)
					ifFalse: [b receiver owner isNil ifTrue: [
						^ true]]]]].

	^ false

]

{ #category : #accessing }
PhratchProcess >> includesReceiver: anObject [
	"Answer true if I have the given object as a block receiver."

	^ self stackAsArray anySatisfy: [ :frm | (frm respondsTo: #receiver) and: [ frm receiver == anObject ] ]
]

{ #category : #initialization }
PhratchProcess >> initialize [

	stackFrame := nil.
	readyToYield := false.
	errorFlag := false.
	readyToTerminate := false.
	isPaused := false.
	doneWithDebugging := false.
	tempVars := VariableFrame new

]

{ #category : #'BYOB-variables' }
PhratchProcess >> isAtomic [

	| stopButtonRect presenter frame |

	presenter := World findA: PhratchPresenterMorph.

	presenter notNil
		ifTrue: [ stopButtonRect := presenter buttons fourth bounds ].
		
	frame := World findA: PhratchFrameMorph.	
	frame notNil
		ifTrue: [ stopButtonRect := (frame valueOfProperty: #stopAllButton) bounds].

	(Sensor anyButtonPressed and: [stopButtonRect containsPoint: Sensor cursorPoint]) ifTrue: [
		self stop.
		PhratchFrameMorph allInstances do: [:sf| sf stopAll]].

	(Sensor keyPressed: 27) ifTrue: [
			Sensor flushKeyboard.
			ScriptablePhratchMorph noviceMode ifFalse: [
				Display flash: stopButtonRect].
			^ false ].

	atomicityList ifNil: [^false].
	(atomicityList size = 0) ifTrue: [^false].
	Sensor flushKeyboard.
	^atomicityList last



]

{ #category : #'BYOB-pause/resume' }
PhratchProcess >> isPaused [
	^isPaused ifNil: [^ isPaused := false]
]

{ #category : #accessing }
PhratchProcess >> isRunning [
	"Answer true if I am still running, have not encountered an error, and don't refer to any deleted objects."

	^ (stackFrame notNil and:
	   [errorFlag not and:
	   [self includesDeletedReceiver not]])

]

{ #category : #'BYOB-pause/resume' }
PhratchProcess >> jumpOver [
	| cb |
	cb := self currentBlock.
	blockToDebug := nil.
	nextBlockToDebug := cb nextBlock.
	isPaused := false
]

{ #category : #'BYOB-pause/resume' }
PhratchProcess >> nextStep [

	blockToDebug := self currentBlock. 
	nextBlockToDebug := nil.
	isPaused := false
]

{ #category : #'BYOB-variables' }
PhratchProcess >> nop [

	self returnValueToParentFrame: 0.
	self popStackFrame.
]

{ #category : #'BYOB-pause/resume' }
PhratchProcess >> pause [
	timeOffset := nil.
	isPaused := true
]

{ #category : #accessing }
PhratchProcess >> popStackFrame [
	"Pops the current stack frame off the top of the stack, so that the next one becomes the current frame."

	|  frame   |

	frame := stackFrame.
	stackFrame := stackFrame parentFrame.

	frame expression.

	"this effectively disables Scratch's so called single stepping mechanism, a sacrifice that let's us catch up with Scratch speed again,
	-jens"
	^self.

	"and this is the old code"

	"self isAtomic ifTrue: [^self ].

	BlockHighlightMSecs > 0 ifTrue: [
		(frame shouldUnlight not and: [command isBlockMorph]) ifTrue: [
			""We push a new frame for unlighting this command.""
			unlightFrame := PhratchStackFrame new
				expression: command.
			self pushStackFrame: unlightFrame]]."

]

{ #category : #'private-stack' }
PhratchProcess >> popStackFrameNoUnhightlight [
	"Pops the current stack frame off the top of the stack, so that the next one becomes the current frame. Do not add a stack frame to unhighlight this block. Use this method when a block will re-evaluated, such 'wait until'."

	stackFrame := stackFrame parentFrame.


]

{ #category : #'private-stack' }
PhratchProcess >> pushStackFrame: aPhratchStackFrame [
	"Pushes the given new stack frame onto the top of the stack, so that it becomes the current stack frame."

	aPhratchStackFrame parentFrame: stackFrame.
	stackFrame := aPhratchStackFrame.

]

{ #category : #'BYOB-pause/resume' }
PhratchProcess >> resume [

	blockToDebug := nil.
	nextBlockToDebug := nil.
	isPaused := false.
	doneWithDebugging := true

]

{ #category : #'private-stack' }
PhratchProcess >> returnValueToParentFrame: anObject [
	"Append the given object to the argument list of my parent frame."

	| f obj |
	obj := anObject.
	(anObject isLambdaBlockMorph) ifTrue: [
		obj := anObject fullCopy.
		obj fixInitialFrame].
	stackFrame ifNil: [^ self].
	f := stackFrame parentFrame.
	[f notNil and: [f shouldUnlight ] ] whileTrue: [
		f := f parentFrame]. 

	f ifNotNil: [f addArgument: obj].

	((blockToDebug isBlockMorph) and: [self currentBlock isReporterBlockMorph]) ifTrue: [
			((PhratchFrameMorph someInstance viewMode = #presentation) | doneWithDebugging) ifFalse: [
				self pause. 
				DebuggerFrameMorph new on: self returnValue: obj]].


]

{ #category : #'entry points' }
PhratchProcess >> runStepFor: aStageMorph [
	"Evaluates the current expression, then the next, etc., until the next yield."

	| expr isTimed |
	"evaluate blocks until we're ready to yield"

	isTimed := stackFrame notNil and: [
		(stackFrame expression isBlockMorph) and: [
			stackFrame expression isTimed]].

	(self isPaused and: [isTimed not]) ifTrue: [ ^ self].

	readyToYield := false.
	[readyToYield or: [stackFrame isNil]] whileFalse: [
		self evaluateFor: aStageMorph].

	readyToTerminate ifTrue: [
		"pop all stack frames, unlighting enclosing blocks:"
		[stackFrame isNil] whileFalse: [
			expr := stackFrame expression.
			(expr isBlockMorph) ifTrue: [expr litUp: false].
			self popStackFrame]].


]

{ #category : #'BYOB-variables' }
PhratchProcess >> scriptList: anOrderedCollection [

	scriptList := anOrderedCollection
]

{ #category : #'BYOB-variables' }
PhratchProcess >> setVar [

	| block arguments argExp environment |

	block := stackFrame expression.
	arguments := stackFrame arguments.

	"Evaluate the arg if we haven't already."
	arguments size = 0
		ifTrue:	[argExp := block argumentAt: 2.
				^self pushStackFrame: (PhratchStackFrame new expression: argExp)].

	(block receiver isVariableFrame) 
		ifTrue: [ environment := block receiver ]
		ifFalse: [ (blockVarList notNil and: [blockVarList isEmpty not])
			ifTrue: [ environment := blockVarList last ]].

	environment ifNotNil: [
		environment setVar: (block argumentAt: 1) evaluate to: arguments first ].
	self popStackFrame.

]

{ #category : #'private-stack' }
PhratchProcess >> stackAsArray [
	"Returns an array describing the contents of the stack.  Useful for debugging."

	| frame collection |

	frame := stackFrame.
	collection := OrderedCollection new.
	
	[frame isNil] whileFalse:
		[collection add: frame expression.
		frame := frame parentFrame].

	^collection asArray
]

{ #category : #'entry points' }
PhratchProcess >> stepUntilDoneFor: aStageMorph [

	[self isRunning] whileTrue: [
		self isAtomic. "allow escaping out of forever loops in #showValue situations. -jens"
		Sensor keyboardPressed.
		self runStepFor: aStageMorph]

]

{ #category : #'entry points' }
PhratchProcess >> stop [
	"Permanently terminates this process."

	stackFrame ifNotNil: [stackFrame "stopMIDI;" stopTalkThinkAsk].
	readyToYield := true.
	readyToTerminate := true.
	topBlock ifNotNil: [topBlock phratchProc: nil].

]

{ #category : #'BYOB-variables' }
PhratchProcess >> temporaryVariables [
	^tempVars
]

{ #category : #accessing }
PhratchProcess >> topBlock: aBlock [

	topBlock := aBlock.

]

{ #category : #copying }
PhratchProcess >> veryDeepCopyWith: ignored [

	^ nil
]

{ #category : #'private-evaluation' }
PhratchProcess >> yield [
	"Sets a flag indicating that we're ready to yield to another process."

	readyToYield := true.

	isPaused ifFalse: [
		self popStackFrame ].
]
