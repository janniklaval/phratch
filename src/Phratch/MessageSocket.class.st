"
I transmit and receive ""messages"", where a message is simply a String or ByteArray that is treated as an atomic unit of communication. When sending, I queue messages for transmission and stream them out in order. When receiving, I gather the incoming data into discrete messages. This allows clients code to treat message transmission as an atomic action; the sender can ""send and forget"" and the receiver will never see an incomplete message. Messages are transmitted as a four-byte size field followed by the bytes of the message. 

Notes:

1. Zero-length messages are allowed.

2. Since messages are buffered in memory in their entirety, this facility is not appropriate for transmitting large pieces of data (i.e., many megabytes) such as large sound or movie files, unless both ends have enough heap space to buffer the data.

3. The sender should call sendData and the receiver should call nextMessage frequently; these are the methods that actually feed data through the socket connection.

"
Class {
	#name : #MessageSocket,
	#superclass : #Object,
	#instVars : [
		'socket',
		'inSizeBuf',
		'inSizeIndex',
		'inBuf',
		'inIndex',
		'outgoingMessages',
		'outBuf',
		'outIndex',
		'isHttp'
	],
	#category : #'Phratch-Networking'
}

{ #category : #S4A }
MessageSocket >> addHttpHeader: msg [
|resp|
resp := String new.
resp := 
	'HTTP/1.1 200 OK', String crlf,
	'User-Agent: S4A 1.4', String crlf,
	'Content-Length: ', (msg size) asString, String crlf,
     'Access-Control-Allow-Origin: *', String    crlf, 
	'Content-Type: text/html',String crlf,
	String crlf,
	msg.

^ resp.

]

{ #category : #connection }
MessageSocket >> connectTo: serverAddress port: serverPortNumber [
	"Attempt to open a connection to the give port of the given host. Does not wait until the connection is established. Destroys previous socket, if any."

	Socket initializeNetwork.
	socket ifNotNil: [socket destroy].
	socket := Socket newTCP.
	(socket notNil and: [socket isValid]) ifTrue: [
		socket setOption: 'TCP:=NODELAY' value: true].
	socket connectTo: serverAddress port: serverPortNumber.

]

{ #category : #connection }
MessageSocket >> deadlineSecs: secs [
	"Return a deadline time the given number of seconds from now."

	^ Time millisecondClockValue + (secs * 1000)

]

{ #category : #connection }
MessageSocket >> destroy [
	"Destroy my socket, breaking the connection. Do nothing if it the socket is nil."

	socket ifNotNil: [
		socket destroy.
		socket := nil].

]

{ #category : #S4A }
MessageSocket >> httpContent: msg [ 
	| index byte cmd |
	index := msg asString findString: String crlf , String crlf."end of header 13,10,13,10"
	index > 0 ifFalse: [^ nil].
	index := index + 4.
	cmd := OrderedCollection new.
	[index < msg size & ((byte := msg byteAt: index) >= 32)]
		whileTrue: [
			cmd add: byte.
			index := index + 1].
	
	^ cmd asByteArray
]

{ #category : #initialization }
MessageSocket >> initialize [
	"Initialize this message socket."

	socket := nil.
	inSizeBuf := ByteArray new: 4.
	inSizeIndex := 1.
	inBuf := nil.
	inIndex := 1.
	outgoingMessages := OrderedCollection new.
	outBuf := nil.
	outIndex := 1.
	lastActivityTime := Time totalSeconds.
	isHttp := false

]

{ #category : #connection }
MessageSocket >> isConnected [
	"Answer true if my socket is connected."

	^ socket notNil and: [socket isConnected]

]

{ #category : #S4A }
MessageSocket >> isHttpCompleted: msg [ 
	| index |
	index := msg asString findString: String crlf , String crlf. "end of header 13,10,13,10"
	(index > 0 and: [(msg asString findString: 'POST') > 0])
		ifTrue: [(msg byteAt: index + 4) >= 32 ifFalse: [index := 0]]. "test first byte of data"
	^ index > 0
]

{ #category : #connection }
MessageSocket >> nextMessage [
	"Processing any data available on my socket and answer the next complete message, if any. Answer nil if the current messsage is not yet complete or if the socket is not connected."
	"Details: If msgBuf is nil, then we are in the process of reading the four-byte size field. Otherwise, we are in the process of reading the current message into msgBuf."

	| n sz msg|
	(socket notNil and: [socket isConnected]) ifFalse: [^ nil].

	inBuf ifNil: [
		n := socket readInto: inSizeBuf startingAt: inSizeIndex.
		n > 0 ifTrue: [lastActivityTime := Time totalSeconds].
		inSizeIndex := inSizeIndex + n.
		inSizeIndex > 4 ifTrue: [  "received message size; allocate the message buffer"
			sz := (ReadStream on: inSizeBuf) uint32.
			sz = 0 ifTrue: [    "empty message"
				inSizeIndex := 1.
				^ ByteArray new].
			isHttp := ((inSizeBuf  asString = 'POST') or: [inSizeBuf  asString = 'GET '] ).
			isHttp ifTrue: 
				[sz := 2048.
				 inBuf := ByteArray new: sz.
				 1 to: 4 do: [:i | inBuf byteAt: i put: (inSizeBuf byteAt: i)].	
				 inIndex := 5]
			ifFalse: [ 
				sz > 1000000 ifTrue: [ sz := 1000000. "msg size over a megabyte; check available space"
				sz > (Smalltalk garbageCollect - 1000000) ifTrue: [
					self error: 'message too big; bad size field?']].			
				inBuf := ByteArray new: sz.
				inIndex := 1]]].

	inBuf ifNotNil: [
	     n := socket readInto: inBuf startingAt: inIndex.
		n > 0 ifTrue: [lastActivityTime := Time totalSeconds].
		inIndex := inIndex + n.		
		((inIndex > inBuf size) or: [isHttp and: [self isHttpCompleted: inBuf]]) ifTrue: [  "received complete message; reset and answer it"
			msg := inBuf.
			inBuf := nil.
			inSizeIndex := 1.  "ready to read size field of the next message"		
			isHttp ifTrue: [
				msg := self processHttpMsg: msg.
				msg size = 0 ifTrue: [Transcript show: '?';cr].
				Transcript show: msg;cr.].
	  ^ msg]].

	^ nil

]

{ #category : #initialization }
MessageSocket >> on: aSocket [
	"Initialize this message socket on the given socket."

	self initialize.
	socket := aSocket.
	(socket notNil and: [socket isValid]) ifTrue: [
		socket setOption: 'TCP:=NODELAY' value: true].

]

{ #category : #S4A }
MessageSocket >> processGetMsg: msg [ 
	| start end byte cmd |
	start := msg asString findString: 'broadcast'.
	start > 0 ifFalse: [
		start := msg asString findString: 'sensor-update'].
	start > 0 ifFalse: [
		start := msg asString findString: 'send-vars'].
	start > 0 ifFalse: [
		start := msg asString findString: 'send-messages'].
	start > 0 ifFalse: [
		start := msg asString findString: 'vars-update'].

	start > 0 ifFalse: [
		start := msg asString findString: 'GET / HTTP'.
		(start > 0) ifTrue: [ ^ ByteArray new]].

	start > 0 ifFalse: [^ msg].
	
	end := (msg asString findString: 'HTTP') - 1.
	cmd := OrderedCollection new.
	start to: end do: 
		[:n | 
		byte := msg byteAt: n.
		byte = 47 ifTrue: [byte := 32]. "/"
		byte = 61 ifTrue: [byte := 32]. "="
		cmd add: byte].
	^ cmd asByteArray.
]

{ #category : #S4A }
MessageSocket >> processHttpMsg: msg [ 
	(msg asString findString: 'POST')	> 0
		ifTrue: [^ self httpContent: msg]
		ifFalse: [^ self processGetMsg: msg]
]

{ #category : #requests }
MessageSocket >> request: aByteArrayOrString [
	"Send the given message to the server and answer its reply message. Answer nil if the connection is broken before the transaction is complete. Wait indefinitely for the reply as long as the connection is unbroken."

	| reply sending |
	self sendMessage: aByteArrayOrString.
	[self isConnected] whileTrue: [
		sending := self sendData.
		reply := self nextMessage.
		reply ifNotNil: [^ reply].
		sending ifFalse: [socket waitForDataUntil: (self deadlineSecs: 1)]].

	"connection was broken"
	self destroy.  "close my end"
	^ nil

]

{ #category : #S4A }
MessageSocket >> sendData [
	"Send some more data, if possible. Answer true if there is more data to be sent. This method should be called frequently by the client. It does nothing if there are no messages to send, or if the socket is not connected or ready to accept data. If outBuf is not a bytes object (i.e., a ByteArray or String) then assume it is a positionable stream and let sendStreamData send it."

	| buf n msg |
 	(socket notNil and: [socket isConnected]) ifFalse: [^ false].
	socket waitForSendDoneUntil: (self deadlineSecs: 1).

	outBuf ifNil: [  "not currently sending"
		outgoingMessages size = 0 ifTrue: [^ false].  "no more message to send"
		socket sendDone ifFalse: [^ true].  "still sending last data"
		outgoingMessages last class isBytes ifFalse: [^ self sendStreamData].
		buf := WriteStream on: (ByteArray new: 2000).
		[outgoingMessages size > 0] whileTrue: [
			msg := outgoingMessages removeFirst.
			isHttp ifTrue: [
				buf nextPutAll: (self addHttpHeader: msg) asByteArray]
			ifFalse: [ 			
				buf uint32: msg size.
				buf nextPutAll: msg asByteArray.
			].
		].
		outBuf := buf contents.
		outIndex := 1].

	outBuf ifNotNil: [  "currently sending outBuf"
		outBuf class isBytes ifFalse: [^ self sendStreamData].
		n := socket sendDataNoWait: outBuf startIndex: outIndex.
		n > 0 ifTrue: [
			lastActivityTime := Time totalSeconds.
			outIndex := outIndex + n.
			outIndex > outBuf size ifTrue: [outBuf := nil]]].

	^ true

]

{ #category : #sending }
MessageSocket >> sendMessage: aByteArray [
	"Add this message to the list of messages to be sent."

	outgoingMessages addLast: aByteArray.

]

{ #category : #sending }
MessageSocket >> sendStreamData [
	"Private! Used by sendData only when outBuf is a positionable stream. Send some data from outBuf, if possible. Set outBuf to nil when the entire stream has been sent. Always answer true. "

	| tempBuf n |
	tempBuf := outBuf next: 10000.  "read up to 10000 bytes from the stream"
	outBuf skip: tempBuf size negated.
	n := socket sendDataNoWait: tempBuf startIndex: 1.
	n > 0 ifTrue: [
		lastActivityTime := Time totalSeconds.
		outBuf skip: n.
		outBuf atEnd ifTrue: [outBuf := nil]]. "finished sending outbuf"

	^ true

]

{ #category : #connection }
MessageSocket >> socket [
	"Answer my socket."

	^ socket

]

{ #category : #receiving }
MessageSocket >> waitForData [
	"Wait a little while for data to arrive. Return when data arrives or when the deadline time is reached, whichever comes first. Calling this allows other threads to run while this thread is waiting for data."

	^ socket waitForDataUntil: (self deadlineSecs: 1)

]
