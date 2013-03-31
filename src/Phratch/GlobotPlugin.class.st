Class {
	#name : #GlobotPlugin,
	#superclass : #InterpreterPlugin,
	#category : #'Phratch-Primitives-Plugins'
}

{ #category : #primitives }
GlobotPlugin class >> closePort [
	"Close the Globot port."
	"self closePort"

	<primitive: 'primClosePort' module: 'GlobotPlugin'>

]

{ #category : #translation }
GlobotPlugin class >> declareCVarsIn: aCCodeGenerator [
	"self translate"

	super declareCVarsIn: aCCodeGenerator.
	aCCodeGenerator cExtras: '
#include <windows.h>

/* Globot Functions */
int GlobotOpenPortNamed(char *portName, int baudRate);
void GlobotPortClose(void);

int GlobotPortRead(char *bufPtr, int bufSize);
int GlobotPortWrite(char *bufPtr, int bufSize);
void GlobotPortFlush(void);
'.

]

{ #category : #primitives }
GlobotPlugin class >> openPortNamed: portName baud: baudRate [
	"Open the port with the given name at the given baud rate. Fail if the port could not be opened."
	"self openPortNamed: 'COM1' baud: 9600"

	<primitive: 'primOpenPortNamed' module: 'GlobotPlugin'>

]

{ #category : #primitives }
GlobotPlugin class >> readInto: buffer [
	"Read from the given port into the given ByteArray or String and answer the number of bytes read."
	"self readInto: (ByteArray new: 10)"

	<primitive: 'primRead' module: 'GlobotPlugin'>
	^ 0

]

{ #category : #testing }
GlobotPlugin class >> test [
	"self test"

	| buf n |
	self openPortNamed: 'COM1' baud: 38400.
	self writeFrom: (1 to: 100) asByteArray.
	buf := ByteArray new: 5000.
	(Delay forMilliseconds: 1500) wait.
	n := self readInto: buf.
	self closePort.
	^ buf copyFrom: 1 to: n


]

{ #category : #primitives }
GlobotPlugin class >> writeFrom: buffer [
	"Write data from the given ByteArray or String to the Globot port and answer the number of bytes written."
	"self writeFrom: (0 to: 100) asByteArray"

	<primitive: 'primWrite' module: 'GlobotPlugin'>
	^ 0

]

{ #category : #'translated prims' }
GlobotPlugin >> primClosePort [
	"Close the given Globot port."

	self export: true.
	self cCode: 'GlobotPortClose()'.
	"leave rcvr on stack"
	^ 0

]

{ #category : #'translated prims' }
GlobotPlugin >> primFlush [
	"Flush the given Globot port."

	self export: true.
	self cCode: 'GlobotPortFlush()'.
	"leave rcvr on stack"
	^ 0

]

{ #category : #'translated prims' }
GlobotPlugin >> primOpenPortNamed [
	"Open the port with the given name and baud rate."

	| nameStr src nameOop baudRate count portNum |
	self export: true.
	self var: 'nameStr' declareC: 'char nameStr[1000]'.
	self var: 'src' declareC: 'char * src'.

	nameOop := interpreterProxy stackValue: 1.
	baudRate := interpreterProxy stackIntegerValue: 0.
	((interpreterProxy isIntegerObject: nameOop) or:
	 [(interpreterProxy isBytes: nameOop) not]) ifTrue: [
		interpreterProxy success: false].
	interpreterProxy failed ifTrue: [^ 0].

	src := self cCoerce: (interpreterProxy firstIndexableField: nameOop) to: 'char *'.
	count := interpreterProxy stSizeOf: nameOop.
	0 to: count - 1 do: [:i | nameStr at: i put: (src at: i)].
	nameStr at: count put: 0.

	portNum := self cCode: 'GlobotOpenPortNamed(nameStr, baudRate)'.
	portNum = -1 ifTrue: [interpreterProxy success: false. ^ 0].

	interpreterProxy pop: 2. "pop args; leave rcvr on stack"
	^ 0

]

{ #category : #'translated prims' }
GlobotPlugin >> primRead [
	"Read data from the given Globot port into the given buffer (a ByteArray or String). Answer the number of bytes read."

	| bufOop bufPtr bufSize byteCount |
	self export: true.
	self var: 'bufPtr' declareC: 'char *bufPtr'.

	bufOop := interpreterProxy stackValue: 0.
	((interpreterProxy isIntegerObject: bufOop) or:
	 [(interpreterProxy isBytes: bufOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	bufPtr := self cCoerce: (interpreterProxy firstIndexableField: bufOop) to: 'char *'.
	bufSize := interpreterProxy stSizeOf: bufOop.
	interpreterProxy failed ifTrue: [^ 0].

	byteCount := self cCode: 'GlobotPortRead(bufPtr, bufSize)'.
	byteCount < 0 ifTrue: [
		interpreterProxy success: false.
		^ 0].

	interpreterProxy pop: 2.  					"pop args and rcvr"
	interpreterProxy pushInteger: byteCount.	"push result"
	^ 0

]

{ #category : #'translated prims' }
GlobotPlugin >> primWrite [
	"Write data to the given Globot port from the given buffer (a ByteArray or String). Answer the number of bytes written."

	| bufOop bufPtr bufSize byteCount |
	self export: true.
	self var: 'bufPtr' declareC: 'char *bufPtr'.

	bufOop := interpreterProxy stackValue: 0.
	((interpreterProxy isIntegerObject: bufOop) or:
	 [(interpreterProxy isBytes: bufOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	bufPtr := self cCoerce: (interpreterProxy firstIndexableField: bufOop) to: 'char *'.
	bufSize := interpreterProxy stSizeOf: bufOop.
	interpreterProxy failed ifTrue: [^ 0].

	byteCount := self cCode: 'GlobotPortWrite(bufPtr, bufSize)'.
	byteCount < 0 ifTrue: [
		interpreterProxy success: false.
		^ 0].

	interpreterProxy pop: 2.  					"pop args and rcvr"
	interpreterProxy pushInteger: byteCount.	"push result"
	^ 0

]
