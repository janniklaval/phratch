Class {
	#name : #SerialPort2,
	#superclass : #Object,
	#instVars : [
		'portNum'
	],
	#category : #'Phratch-Primitives-Plugins'
}

{ #category : #enumeration }
SerialPort2 class >> portNames [
	"Answer a collection of serial port names."

	^ (1 to: PhratchPlugin portCount)
		collect: [:i | PhratchPlugin portName: i]

]

{ #category : #'open/close' }
SerialPort2 >> assertOpen [
	"Raise an error if the port is not open."

	self isOpen ifFalse: [self error: 'serial port is not open'].

]

{ #category : #'open/close' }
SerialPort2 >> close [
	"Close the serial port. Do nothing if it is already closed."

	portNum ifNil: [^ self].
	self flushInputBuffer.
	PhratchPlugin closePort: portNum.
	portNum := nil.

]

{ #category : #'input/output' }
SerialPort2 >> flushInputBuffer [
	"Discard bytes until the input buffer is empty. Answer the number of bytes read."

	| count buf n |
	count := 0.
	buf := ByteArray new: 2000.
	[(n := PhratchPlugin readPort: portNum into: buf) > 0] whileTrue: [count := count + n].
	^ count

]

{ #category : #'open/close' }
SerialPort2 >> isOpen [
	"Answer true if this serial port is open."

	portNum ifNil: [^ false].
	(PhratchPlugin isPortOpen: portNum)
		ifTrue: [^ true]
		ifFalse: [portNum := nil. ^ false].

]

{ #category : #'input/output' }
SerialPort2 >> next: byteCount [
	"Answer a ByteArray of length byteCount with the next byteCount bytes read from this port. Wait indefinitely until enough bytes arrive."

	| result buf n |
	self assertOpen.
	result := ByteArray new: 0.
	[result size < byteCount] whileTrue: [
		buf := ByteArray new: byteCount - result size.
		n := PhratchPlugin readPort: portNum into: buf.
		n > 0
			ifTrue: [result := result, (buf copyFrom: 1 to: n)]
			ifFalse: [(Delay forMilliseconds: 10) wait]].
	^ result


]

{ #category : #'input/output' }
SerialPort2 >> nextPut: anInteger [
	"Send the given byte out this serial port. The port must be open."

	self nextPutAll: (ByteArray with: anInteger).

]

{ #category : #'input/output' }
SerialPort2 >> nextPutAll: aStringOrByteArray [
	"Send the given bytes out this serial port. The port must be open."

	self isOpen ifFalse: [^ self].
	PhratchPlugin writePort: portNum data: aStringOrByteArray.

]

{ #category : #'open/close' }
SerialPort2 >> openPortNamed: aString baud: baudRate [
	"Open the serial port with the given name at the given speed."

	self close.
	portNum := PhratchPlugin openPortNamed: aString baud: baudRate.
	portNum < 0 ifTrue: [portNum := nil].

]

{ #category : #'input/output' }
SerialPort2 >> readByteArray [
	"Answer a ByteArray read from this serial port. Answer an empty ByteArray if no data is available. The port must be open."

	| buf count |
	self isOpen ifFalse: [^ ByteArray new].
	buf := ByteArray new: 2000.
	count := PhratchPlugin readPort: portNum into: buf.
	count <= 0 ifTrue: [^ ByteArray new].
	^ buf copyFrom: 1 to: count

]

{ #category : #'input/output' }
SerialPort2 >> readString [
	"Answer a String read from this serial port. Answer an empty String if no data is available. The port must be open."

	| buf count |
	self isOpen ifFalse: [^ String new].
	buf := String new: 1000.
	count := PhratchPlugin readPort: portNum into: buf.
	count <= 0 ifTrue: [^ String new].
	^ buf copyFrom: 1 to: count

]

{ #category : #options }
SerialPort2 >> setOption: optionNum to: anInteger [
	"Set the given option to the given value."

	PhratchPlugin port: portNum setOption: optionNum to: anInteger.

]
