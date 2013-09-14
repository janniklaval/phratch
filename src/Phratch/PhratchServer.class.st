"
This class supports peer-to-peer collaboration between Scratch instances or between Scratch and other applications that want to interact with Scratch.

Scratch 1.3 includes an experimental extension feature that supports interaction between Scratch and other programs.

Three kinds of interaction are supported:

  a. sharing broadcasts (in both directions)
  b. virtual sensors
  c. Scratch's global variables are made visible

Note that peers can read, but not change, each other's global variables.

Non-Scratch applications can use these mechanisms to control Scratch projects by sending broadcasts and virtual sensors available to Scratch. For example, a music sequencer might send Scratch broadcasts to synchronize animations to music. Or, Scratch can be used to control another application or (through some intermediary program) external hardware devices.

Topology

The network topology is a star, with one Scratch acting as the session host. Clients connect to this host. In addition to processing incoming messages from clients, the host forwards a message from one client to all other clients. The advantage of the star topology is that only the host must have a public IP address and be able to accept incoming TCP/IP connections; the clients may be bethind firewalls that do Network Address Translation (NAT) or disallow incoming connections. The disadvantages of the star toplogy are (a) messages must be forwarded by the host, increasing latency and (b) the host cannot leave the session. However, the star topology is eaiser for distributed users to set up and understand.

A common use of this mechanism is to provide additional sensors to Scratch or allow Scratch to control an external program. In that case, latency is typically very low.

Protocol

The experimental extension feature is enabled using the right-button menu on one of the two sensor blocks. When remote sensors are enabled, Scratch listens for connections on port 42001. 

Once a connection is established, messages are sent in both directions over the socket connection.

Each message consists of a four-byte size, most-significant byte first, followed by the message itself:

	<size: 4 bytes><msg: size bytes>

The four-byte size field is not counted as part of the message size. Thus, the empty message is four zero bytes.

The message up to the first whitespace character (any byte <= 32 is considered whitespace) is interpreted to as a case-insensitive command that is used to decide what to do with the rest of the message. Messages may eventually be used to transmit sprites or media, so large amounts of binary binary data in arbitrary formats may follow the initial command string.

The most common messages are human-readable strings made up of the following elements:

  - unquoted words with no embedded whitespace (cat, dog, mouse)
  - quoted strings (""three word string"", ""embedded """"quotation marks"""" are doubled"")
  - signed decimal numbers (1, -1, 3.14, -1.2, .1, -.2)
  - booleans (true or false)

Common Commands

The command set will get extended over time, so clients should just skip any commands that they do not understand. Here are the two most useful ones:

	broadcast <string>
	sensor-update [<var-name> <new-value>]

A sensor update command is followed by zero or more (variable name, value) pairs. Variable names are strings. Values are either numbers or strings.

Scratch outputs these commands when broadcasts or global variable changes occur. Scratch also responds to these commands. Broadcast commands sent to Scratch cause a broadcast to occur. Sensor-update commands update the values of virtual sensors available in the sensor block drop-down menu.

"
Class {
	#name : #PhratchServer,
	#superclass : #Object,
	#instVars : [
		'stage',
		'userName',
		'serverSocket',
		'incomingUDPSocket',
		'peerSockets',
		'peerNames',
		'sensors',
		'lastSentValues',
		'incomingBroadcasts',
		'outgoingBroadcasts',
		'in',
		'broadcastCache'
	],
	#category : #'Phratch-Networking'
}

{ #category : #utilities }
PhratchServer class >> portNumber [
	"Answer the port number for the Phratch server."

	^ 42001
]

{ #category : #'private-server' }
PhratchServer >> acceptNewConnections [
	"Accept new connections, if any. Also process any newly connected outgoing sockets."

	| newSock |
	serverSocket ifNil: [^ self].
	[serverSocket isConnected] whileTrue: [
		newSock := serverSocket accept.
		peerSockets addLast: (MessageSocket new on: newSock).
		self resendAllVars].

]

{ #category : #'private-variables' }
PhratchServer >> broadcastMessageFor: aString [
	"Answer a message to broadcast the given string."

	| msg |
	msg := WriteStream on: String new.
	msg nextPutAll: 'broadcast '.
	self putString: aString on: msg.

	^ msg contents

]

{ #category : #accessing }
PhratchServer >> broadcastsSeen [

	^ broadcastCache asArray sort

]

{ #category : #'server control' }
PhratchServer >> clearCaches [

	broadcastCache := broadcastCache species new.
	sensors := sensors species new.
	lastSentValues := lastSentValues species new.
	self resend: 'send-vars' toPeersExcept: nil.

]

{ #category : #'private-incoming commands' }
PhratchServer >> dispatch: aString from: requestSock [
	"Dispatch an incoming command from a remote Phratch."

	| cmd op |
	aString size = 0
		ifTrue: [ 
			requestSock sendMessage: 'version "PhratchServer 0.1 alpha"'.
			^ self ].
	op := self opcodeFrom: aString.
	op size = 0
		ifTrue: [ ^ self ].
	(#('broadcast' 'sensor-update' 'peer-name' 'send-vars' 'sprite') includes: op)
		ifFalse: [ ^ self ].
	'sprite' = op
		ifTrue: [ 
			cmd := self parseMixedMsg: aString.
			self doSprite: cmd from: requestSock.
			^ self resend: aString toPeersExcept: requestSock ].
	cmd := self parse: aString.
	'broadcast' = op
		ifTrue: [ 
			self doBroadcast: cmd from: requestSock.
			^ self resend: aString toPeersExcept: requestSock ].
	'sensor-update' = op
		ifTrue: [ 
			self doSensorUpdate: cmd from: requestSock.
			^ self resend: aString toPeersExcept: requestSock ].
	'peer-name' = op
		ifTrue: [ ^ self doPeerName: cmd from: requestSock ].
	'send-vars' = op
		ifFalse: [ ^ self ].
	self doSendVars: cmd from: requestSock.
	^ self resend: aString toPeersExcept: requestSock
]

{ #category : #'private-incoming commands' }
PhratchServer >> doBroadcast: cmd from: requestSocket [
	"Handle a broadcast command: broadcast <event-name>"

	| evtName |
	cmd size = 2 ifFalse: [^ self].
	((evtName := cmd at: 2) isKindOf: String) ifFalse: [^ self].

	incomingBroadcasts add: evtName.
	broadcastCache add: evtName.

]

{ #category : #'private-incoming commands' }
PhratchServer >> doPeerName: cmd from: requestSock [
	"Handle a peer-name command: peer-name <peerName>"

	| peerName |
	cmd size = 2 ifFalse: [^ self].
	((peerName := cmd at: 2) isKindOf: String) ifFalse: [^ self].

	peerNames at: requestSock put: peerName.
	self dispatch: 'send-vars' from: nil.

]

{ #category : #'private-incoming commands' }
PhratchServer >> doSendVars: cmd from: requestSock [
	"Handle a variable send request: send-vars"

	"force all my global variables to be re-transmitted"
	lastSentValues := lastSentValues species new.

]

{ #category : #'private-incoming commands' }
PhratchServer >> doSensorUpdate: cmd from: requestSocket [
	"Handle a sensor update command: sensor-update [<sensor-name> <sensor-value>]"

	| i sName sValue |
	i := 2.
	[i < cmd size] whileTrue: [
		sName := cmd at: i.
		sValue := cmd at: i + 1.
		(sName isKindOf: String)
			ifTrue: [sensors at: sName put: sValue].
		i := i + 2].

]

{ #category : #'private-incoming commands' }
PhratchServer >> doSprite: cmd from: requestSock [
	"Handle a sprite command: sprite <senderName> <spriteData>"

	| sf spriteData|
	cmd size = 3 ifFalse: [^ self].
	((spriteData := cmd at: 3) isKindOf: ByteArray) ifFalse: [^ self].
	sf := stage ownerOrYourselfThatIsA: PhratchFrameMorph.
	sf ifNil: [^self].
	sf importSpriteOrProject: spriteData

]

{ #category : #'server control' }
PhratchServer >> endPhratchSession [
	"Close all sockets. If I am hosting, this will end the session for everyone. If I am only a client, then I will leave the session but the session itself can continue to exist."

	self shutdownServer.


]

{ #category : #initialization }
PhratchServer >> initialize [

	userName := 'anonymous'.
	peerSockets :=  OrderedCollection new.
	peerNames := IdentityDictionary new.
	sensors := Dictionary new.
	lastSentValues := Dictionary new.
	incomingBroadcasts := OrderedCollection new.
	outgoingBroadcasts := OrderedCollection new.
	broadcastCache := Set new.

]

{ #category : #'server control' }
PhratchServer >> isHosting [
	"Answer true if this is the host of a Phratch session."

	^ serverSocket notNil

]

{ #category : #'private-incoming commands' }
PhratchServer >> opcodeFrom: aString [
	"Answer the command opcode for the given message. The opcode is the unquoted string at the beginning of the message up to the first whitespace character."

	| i |
	i := 1.
	[i <= aString size and: [(aString at: i) asciiValue > 32]]
		whileTrue: [i := i + 1].

	^ (aString copyFrom: 1 to: i - 1) asLowercase

]

{ #category : #'private-command parsing' }
PhratchServer >> parse: aString [
	"PhratchServer new parse: 'test abc 1 -1 .01 -.01 true false'"

	| out token |
	in := ReadStream on: aString asString.
	out := OrderedCollection new.
	[in atEnd] whileFalse: [
		token := self readNext.
		token ifNotNil: [out addLast: token]].
	^ out asArray

]

{ #category : #'private-command parsing' }
PhratchServer >> parseMixedMsg: aString [
	"answer an Array containting both textual and binary information:
	op <senderName> <binaryData>"

	| op senderName i binaryData |
	op := self opcodeFrom: aString.
	i := aString findString: String crlf.
	i = 0 ifTrue: [^self error: 'delimiter for binary data not found'].
	senderName := aString copyFrom: op size + 2 to: i-1.
	binaryData := aString copyFrom: i + 2  to: aString size.
	^Array with: op with: senderName with: binaryData asByteArray

]

{ #category : #'private-incoming commands' }
PhratchServer >> processCommandFrom: requestSock [
	"Handle a command from the given socket. Do nothing if there are no messages."

	| msg |
	(msg := requestSock nextMessage) ifNil: [^ self].

	[self dispatch: msg asString from: requestSock]
		ifError: [:err :rcvr | PhratchError error].

]

{ #category : #'private-server' }
PhratchServer >> processIncomingBroadcasts [
	"NOTE: Broadcast events are added to the outgoingBroadcasts queue as a side-effect of re-broadcasting them locally. To avoid having broadcasts bounce from peer to peer forever, the outgoingBroadcasts queue is cleard after incoming commands have been processed."

	stage ifNotNil: [
		incomingBroadcasts do: [:evtName |
			stage broadcastEventNamed: evtName with: 0]].

	incomingBroadcasts := incomingBroadcasts species new: 100.
	outgoingBroadcasts := outgoingBroadcasts species new: 100.

]

{ #category : #'private-server' }
PhratchServer >> processIncomingCommands [
	"Process incoming commands from my peers."

	peerSockets copy do: [:sock |
		sock isConnected
			ifTrue: [
				self processCommandFrom: sock.
				sock sendData]
			ifFalse: [
				sock destroy.
				peerSockets remove: sock ifAbsent: []]].

	self processUDPCommands.

]

{ #category : #'private-server' }
PhratchServer >> processUDPCommands [
	"Process incoming UDP commands."

	| buf n msg |
	incomingUDPSocket ifNil: [^ self].
	buf := String new: 3000.
	[true] whileTrue: [
		n := [incomingUDPSocket receiveDataInto: buf] ifError: [0].
		n = 0 ifTrue: [^ self].

		msg := buf copyFrom: 1 to: n.
		[self dispatch: msg from: nil] ifError: []].

]

{ #category : #'private-variables' }
PhratchServer >> putString: aString on: aStream [
	"Append the given string to the given stream. Double any embedded double-quote characters."

	aStream nextPut: $".
	aString do: [:ch |
		aStream nextPut: ch.
		ch = $" ifTrue: [aStream nextPut: ch]].
	aStream nextPut: $".

]

{ #category : #'private-server' }
PhratchServer >> queueBroadcast: aString [
	"Queue the given broadcast event to be sent to my peers."

	self sessionInProgress ifFalse: [^ self].

	(#(	'Phratch-KeyPressedEvent'
		'Phratch-MouseClickEvent'
		'Phratch-StartClicked'
	) includes: aString) ifTrue: [^ self].

	outgoingBroadcasts add: aString.

]

{ #category : #'private-command parsing' }
PhratchServer >> readNext [
	"Read the next command line token from 'in' or nil if there are not more tokens. A token is a quoted string, a number, a boolean, or an unquoted string with no embedded whitespace. Strings that start with a digit or minus sign must be quoted to avoid being treated as an integer."

	| ch s |
	"skip white space"
	[in atEnd not and: [in peek asciiValue <= 32]]
		whileTrue: [in next].
	in atEnd ifTrue: [^ nil].

	ch := in peek.
	ch = $" ifTrue: [^ self readQuotedString].
	(({$- . $.} includes: ch) or:[ ch isDigit]) ifTrue: [^ self readNumber].

	"unquoted string or boolean"
	s := self readString.
	'true' = s ifTrue: [^ true].
	'false' = s ifTrue: [^ false].
	^ s

]

{ #category : #'private-command parsing' }
PhratchServer >> readNumber [

	| orig s sign |
	s := self readString.
	orig := s.
	sign := 1.
	s first = $- ifTrue: [s := s copyFrom: 2 to: s size. sign := -1].

	s size < 1 ifTrue: [^ orig]. "needed for BYOB, -jens"

	s first = $. ifTrue: [s := '0', s].  "add leading zero"
	^ s asNumber * sign

]

{ #category : #'private-command parsing' }
PhratchServer >> readQuotedString [

	| result ch |
	result := WriteStream on: String new.
	in next.  "skip opening quote"
	[in atEnd] whileFalse: [
		ch := in next.
		ch = $" ifTrue: [
			in peek = $"
				ifTrue: [in skip: 1]
				ifFalse: [^ result contents]].
		result nextPut: ch].

	^ result contents

]

{ #category : #'private-command parsing' }
PhratchServer >> readString [

	| result ch |
	result := WriteStream on: String new.
	[in atEnd] whileFalse: [
		ch := in peek.
		ch asciiValue <= 32 ifTrue: [^ result contents].
		result nextPut: in next].

	^ result contents

]

{ #category : #'private-variables' }
PhratchServer >> recordVariableValues [
	"Record the current values of my global variables."

	lastSentValues := Dictionary new.

	stage ifNotNil: [
		stage varNames do: [:v | lastSentValues at: v put: (stage getVar: v)]].

]

{ #category : #'private-incoming commands' }
PhratchServer >> resend: msgString toPeersExcept: requestSocket [
	"Handle a broadcast command: broadcast <event-name>"

	peerSockets do: [:sock |
		sock ~= requestSocket ifTrue: [sock sendMessage: msgString]].

]

{ #category : #'private-variables' }
PhratchServer >> resendAllVars [
	"Force all my global variables to be re-transmitted."

	lastSentValues := lastSentValues species new.

]

{ #category : #'private-server' }
PhratchServer >> sendOutgoingCommands [
	"Send broadcasts and variable updates to my peers."

	| varUpdateMsg |
	varUpdateMsg := self someVariableHasChanged
		ifTrue: [ self variableUpdateMessage ]
		ifFalse: [ nil ].
	peerSockets copy
		do: [ :sock | 
			sock isConnected
				ifTrue: [ 
					varUpdateMsg ifNotNil: [ sock sendMessage: varUpdateMsg ].
					outgoingBroadcasts do: [ :evt | sock sendMessage: (self broadcastMessageFor: evt) ].
					sock sendData ]
				ifFalse: [ 
					sock destroy.
					peerSockets remove: sock ifAbsent: [  ] ] ].
	self recordVariableValues
]

{ #category : #'private-sprites' }
PhratchServer >> sendSprite: aPhratchSpriteMorph [
	"send the given sprite to all peers"

	| msg |
	msg := self spriteMessageFor: aPhratchSpriteMorph.
	peerSockets copy do: [:sock |
		sock isConnected
			ifTrue: [
				sock sendMessage: msg.
				sock sendData]
			ifFalse: [
				sock destroy.
				peerSockets remove: sock ifAbsent: []]].
]

{ #category : #accessing }
PhratchServer >> sensorNames [

	^ sensors keys asArray sort


]

{ #category : #'server control' }
PhratchServer >> sessionInProgress [
	"Answer true if this Phratch server has any external connections."

	^ (peerSockets size > 0) | (serverSocket notNil)


]

{ #category : #'server control' }
PhratchServer >> shutdownServer [
	"Destroy all open sockets."

	serverSocket ifNotNil: [
		serverSocket destroy.
		serverSocket := nil].

	incomingUDPSocket ifNotNil: [
		incomingUDPSocket destroy.
		incomingUDPSocket := nil].

	peerSockets do: [:sock | sock destroy].
	peerSockets := peerSockets species new.

	peerNames := peerNames species new.
	sensors := sensors species new.
	lastSentValues := lastSentValues species new.
	outgoingBroadcasts := outgoingBroadcasts species new.

]

{ #category : #'private-variables' }
PhratchServer >> someVariableHasChanged [
	"Answer true if a global variable has changed since I last sent variable updates to my peers."

	| lastVal |
	stage ifNil: [^ false].

	stage varNames do: [:v |
		lastVal := lastSentValues at: v ifAbsent: [nil].
		lastVal ifNil: [^ true].
		(lastVal = (stage getVar: v)) ifFalse: [^ true]].

	^ false

]

{ #category : #'private-sprites' }
PhratchServer >> spriteMessageFor: aPhratchSpriteMorph [
	"answer a valid msg for the given sprite: sprite <senderName><crlf><binaryData>"

	|msg|
	msg := WriteStream on: (ByteArray new: 100000).
	msg 
		nextPutAll: 'sprite ' asByteArray;
		nextPutAll: userName asByteArray;
		nextPutAll: String crlf asByteArray;
		nextPutAll: aPhratchSpriteMorph serialized.
	^msg contents 
		
]

{ #category : #accessing }
PhratchServer >> stage: aPhratchStageMorph [

	stage := aPhratchStageMorph.

]

{ #category : #'server control' }
PhratchServer >> startHosting [
	"Open a socket on my port and start accepting connections."

	Socket initializeNetwork.
	self shutdownServer.

	serverSocket := Socket new.
	serverSocket listenOn: self class portNumber backlogSize: 20.

	incomingUDPSocket := Socket newUDP setPort: self class portNumber.

]

{ #category : #'server control' }
PhratchServer >> stepServer [
	"Do one server step."
	"Note: processIncomingCommands clears outgoingBroadcasts, so do sendOutgoingCommands first."

	self sessionInProgress ifFalse: [^ self].
	self acceptNewConnections.
	self sendOutgoingCommands.
	self processIncomingCommands.
	self processIncomingBroadcasts.


]

{ #category : #accessing }
PhratchServer >> userName [

	^ userName

]

{ #category : #accessing }
PhratchServer >> userName: aString [

	userName := aString.

]

{ #category : #'private-variables' }
PhratchServer >> variableUpdateMessage [
	"Answer a variable update message for all variables whose values have not already been sent."

	| msg currentValue lastValue v |
	msg := WriteStream on: String new.
	msg nextPutAll: 'sensor-update '.
	stage varNames do: [:varName |
		currentValue := stage getVar: varName.
		lastValue := lastSentValues at: varName ifAbsent: [nil].
		lastValue = currentValue ifFalse: [
			self putString: varName on: msg.
			msg space.
			v := stage interpretStringAsNumberIfPossible: currentValue.
			v isNumber
				ifTrue: [msg nextPutAll: v printString]
				ifFalse: [self putString: v asString on: msg].
			msg space]].

	^ msg contents

]
