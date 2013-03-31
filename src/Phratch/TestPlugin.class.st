"
This is the ""hello, world"" of pluggable primitives. It contains a primitive to add two numbers. You can use it to test your process for building pluggable primitives.

To translate this primitive, just do:
	TestPlugin translate

Now comes the hardest part--figuring out how to build a dynamically linked library (DLL) for your platform. Once you've built it, you should put the DLL file (e.g. ""TestPlugin.dll"") in the same folder as the Squeak executable that you are using.

To test the plugin, do:
	TestPlugin add: 3 to: 4

This should return the number '7'. If you get a primitive failed error, something went wrong. Possible problems are:
  1. DLL not in same folder as Squeak executable
  2. failure to export your primitive function and ""setInterpreter()"" from the DLL
  3. bad file or module name. (Be sure that the DLL file name is something like ""TestPlugin.dll"". On Mac Classic, make sure the Shared Library name is """"TestPlugin"".)

"
Class {
	#name : #TestPlugin,
	#superclass : #InterpreterPlugin,
	#category : #'Phratch-Primitives-Plugins'
}

{ #category : #testing }
TestPlugin class >> add: n1 to: n2 [
	"TestPlugin add: 3 to: 4"
	"Note: This should return a number if the plugin works. Some platforms do not support unloadPlugin: (that is, they don't support DLL unloading at all), so you may have to quit and restart Squeak to get the VM to find a newly-built plugin."

	Smalltalk unloadPlugin: 'TestPlugin'.  "unloads old version of plugin, if any"
	^ self primAdd: n1 to: n2

]

{ #category : #translation }
TestPlugin class >> declareCVarsIn: aCCodeGenerator [
	"self translate"

	super declareCVarsIn: aCCodeGenerator.
	aCCodeGenerator cExtras: '
#include <string.h>'.

]

{ #category : #testing }
TestPlugin class >> primAdd: n1 to: n2 [
	"This is the call to the add primitive."

	<primitive: 'primitiveAdd' module: 'TestPlugin'>
	self primitiveFailed

]

{ #category : #testing }
TestPlugin class >> primFetchString: anInteger [
	"This is the call to the fetchString primitive."
	"self primFetchString: 0"

	<primitive: 'primitiveFetchString' module: 'TestPlugin'>
	self primitiveFailed

]

{ #category : #primitives }
TestPlugin >> primitiveAdd [
	"Add two numbers."

	| operand1 operand2 result |
	self export: true.

	operand1 := interpreterProxy stackIntegerValue: 1.
	operand2 := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed ifTrue: [^ nil].

	result := operand1 + operand2.

	interpreterProxy pop: 3
		thenPush: (interpreterProxy integerObjectOf: result).  "pop args, leave rcvr on stack"
	^ nil

]

{ #category : #primitives }
TestPlugin >> primitiveFetchString [
	"Answer a new Squeak String object whose contents is copied from a C string. Takes one argument which is used to choose which string to return."

	| s0 s1 src dst in count resultOop |
	self export: true.
	self var: 's0' declareC: 'char s0[] = "zero"'.
	self var: 's1' declareC: 'char s1[] = "non-zero"'.
	self var: 'src' declareC: 'char* src'.
	self var: 'dst' declareC: 'char* dst'.

	in := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed ifTrue: [^ nil].

	in = 0 ifTrue: [src := s0] ifFalse: [src := s1].
	count := self cCode: 'strlen(src)'.

	resultOop := interpreterProxy instantiateClass: interpreterProxy classString indexableSize: count.

	dst := self cCoerce: (interpreterProxy firstIndexableField: resultOop) to: 'char *'.
	0 to: count - 1 do: [:i | dst at: i put: (src at: i)].

	interpreterProxy pop: 2 thenPush: resultOop.  "pop arg and rcvr, push result"
	^ nil


]
