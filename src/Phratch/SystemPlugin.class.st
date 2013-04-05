Class {
	#name : #SystemPlugin,
	#superclass : #InterpreterPlugin,
	#category : #'Phratch-Compatibility'
}

{ #category : #'as yet unclassified' }
SystemPlugin class >> declareCVarsIn: aCCodeGenerator [
	"self translate"

	super declareCVarsIn: aCCodeGenerator.
	aCCodeGenerator cExtras: '
#include <stdio.h>
 
void Launch(char *cmd)
{
	system (cmd);
}
'.
]

{ #category : #'as yet unclassified' }
SystemPlugin class >> primLaunch: appName [
	"self primLaunch: 'popup.exe'"
	"self primLaunch: 'popup Hello, World!'"

	<primitive: 'primitiveLaunch' module: 'SystemPlugin'>
]

{ #category : #'as yet unclassified' }
SystemPlugin >> primitiveLaunch [
	"Launch an external application"

	| appStr appSrc appOop count |
	self export: true.
	self var: 'appStr' declareC: 'char appStr[2000]'.

	self var: 'appSrc' declareC: 'char * appSrc'.

	appOop := interpreterProxy stackValue: 0.

	((interpreterProxy isIntegerObject: appOop) or:
	 [(interpreterProxy isBytes: appOop) not]) ifTrue: [
		interpreterProxy success: false].

	interpreterProxy failed ifTrue: [^ 0].

	appSrc := self cCoerce: (interpreterProxy firstIndexableField: appOop) to: 'char *'.
	count := interpreterProxy stSizeOf: appOop.
	count >= 2000 ifTrue: [interpreterProxy success: false. ^ 0].
	0 to: count - 1 do: [:i | appStr at: i put: (appSrc at: i)].
	appStr at: count put: 0.

	self cCode: 'Launch(appStr)'.

	interpreterProxy pop: 1.  "pop arg, leave rcvr on stack"
	^ 0


]
