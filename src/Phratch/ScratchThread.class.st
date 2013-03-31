"
This class may eventually replace ScratchProcess and ScratchStackFrame. The current version operates on tuples rather than on command blocks. It was written as a test before implementing the same code in Java for the Java Scratch player.

"
Class {
	#name : #ScratchThread,
	#superclass : #Object,
	#instVars : [
		'sprite',
		'cmds',
		'ip',
		'stack',
		'yield',
		'done',
		'startTime',
		'tmp'
	],
	#classVars : [
		'SystemCommands'
	],
	#category : #'Phratch-Execution Engine'
}

{ #category : #'class initialization' }
ScratchThread class >> initialize [
	"self initialize"

	SystemCommands := IdentitySet new.
	SystemCommands addAll: #(
		doForever doForeverIf doIf doRepeat doReturn
		doBroadcastAndWait doPlaySoundAndWait doWaitUntil).

]

{ #category : #'var cmds' }
ScratchThread >> changeVar: anArray [
	"Read a variable and return its value."
	"Format of anArray is: (#changeVariable <varName> <setOrChangeSelector> <arg>)"

	| arg |
	arg := self evalArg: (anArray at: 4).
	#setVar:to: = (anArray at: 3)
		ifTrue: [sprite setVar: (anArray at: 2) to: arg]
		ifFalse: [sprite changeVar: (anArray at: 2) by: arg].

]

{ #category : #'system cmds' }
ScratchThread >> doBroadcastAndWait [
	"Broadcast a message and wait until all threads started by that message have stopped."

	self halt.  "not yet implemented"

]

{ #category : #'system cmds' }
ScratchThread >> doForever [
	"Execute my enclosed blocks forever."

	| cmd |
	cmd := cmds at: ip.
	self evalCmdList: (cmd at: 2).

]

{ #category : #'system cmds' }
ScratchThread >> doIf [
	"Execute my enclosed blocks if my condition expression evaluates to true."

	| cmd |
	cmd := cmds at: ip.
	(self evalArg: (cmd at: 2)) ifTrue: [
		self evalCmdList: (cmd at: 3)].

]

{ #category : #'system cmds' }
ScratchThread >> doRepeat [
	"Execute my enclosed blocks the number of times given by my argument. tmp is used to count down the iterations."

	| cmd |
	cmd := cmds at: ip.
	tmp ifNil: [  "first time"
		tmp := self evalArg: (cmd at: 2)].
	tmp <= 0 ifTrue: [^ self].  "repeat is finished"

	tmp := tmp - 1.
	self evalCmdList: (cmd at: 3).

]

{ #category : #'system cmds' }
ScratchThread >> doReturn [
	"Stop this thread and yield."

	done := yield := true.

]

{ #category : #'system cmds' }
ScratchThread >> doWaitUntil [
	"Test an expression and proceed only when it becomes true (i.e. yield if it is false)."

	| cmd |
	cmd := cmds at: ip.
	(self evalArg: (cmd at: 2)) ifFalse: [yield := true].

]

{ #category : #private }
ScratchThread >> evalArg: anObject [
	"Evaluate the given argument. If it is a list (array), then it is an expression that must be evaluated. Otherwise it is a constant value that can be returned."

	(anObject isKindOf: Array) ifTrue: [^ self evalCommand: anObject].
	^ anObject

]

{ #category : #private }
ScratchThread >> evalCmdList: anArrayOrNil [
	"Evaluate the given sequence of commands. A nil argument means to execute the empty list of commands."

	self pushState.
	anArrayOrNil
		ifNil: [cmds := #()]
		ifNotNil: [cmds := anArrayOrNil].
	ip := 0.

]

{ #category : #private }
ScratchThread >> evalCommand: anArray [
	"Evaluate the given command and return it's value."

	| selector args |
	selector := anArray first asSymbol.

	selector = #readVariable ifTrue: [^ self readVar: anArray].
	selector = #changeVariable ifTrue: [^ self changeVar: anArray].

	(SystemCommands includes: selector) ifTrue: [
		^ self perform: selector].

	args := (2 to: anArray size) collect: [:i | self evalArg: (anArray at: i)].

	(args size = 1 and: [#(abs not sqrt) includes: selector]) ifTrue: [
		^ (args at: 1) perform: selector].
		
	(args size = 2 and: [selector isInfix]) ifTrue: [  "binary math/logic ops"
		^ (args at: 1) perform: selector with: (args at: 2)].

	sprite perform: selector withArguments: args.

]

{ #category : #'entry points' }
ScratchThread >> isRunning [

	^ done not

]

{ #category : #private }
ScratchThread >> popState [
	"Restore the last state pushed onto the stack."

	| oldState |
	(stack isNil or: [stack size = 0]) ifTrue: [
		cmds := #().
		ip := 1.
		done := yield := true.
		^ self].

	oldState := stack removeLast.
	cmds := oldState at: 1.
	ip := oldState at: 2.
	startTime := oldState at: 3.
	tmp := oldState at: 4.

]

{ #category : #private }
ScratchThread >> pushState [
	"Save my current state on the stack."

	stack addLast: (Array
		with: cmds
		with: ip
		with: startTime
		with: tmp).

]

{ #category : #'var cmds' }
ScratchThread >> readVar: anArray [
	"Read a variable and return its value."

]

{ #category : #'entry points' }
ScratchThread >> runUntilYield [
	"Execute commands until it is time to yield control, a 'done' command is executed, or it is time to yield control."

	ip > cmds size ifTrue: [done := true].
	done ifTrue: [^ self].

	yield := false.
	[yield] whileFalse: [
		self evalCommand: (cmds at: ip).
		yield ifFalse: [ip := ip + 1].
		ip > cmds size ifTrue: [
			self popState.
			yield := true]].


]

{ #category : #'entry points' }
ScratchThread >> startOn: anArrayOfCommands sprite: aSprite [

	sprite := aSprite.
	cmds := anArrayOfCommands.
	ip := 1.
	stack := OrderedCollection new.
	yield := false.
	done := false.
	startTime := nil.		"used by timed commands like glide"
	tmp := nil.			"used by timed commands and repeat"

]

{ #category : #'entry points' }
ScratchThread >> stop [

	done := true.


]
