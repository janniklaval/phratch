Class {
	#name : #PhratchServerV1,
	#superclass : #Object,
	#instVars : [
		'stage',
		'userName',
		'serverSocket',
		'incomingUDPSocket',
		'incoming',
		'outgoing',
		'newOutgoing',
		'peerNames',
		'sensors',
		'lastSentValues',
		'outgoingBroadcasts',
		'in'
	],
	#category : #'Phratch-Networking'
}

{ #category : #utilities }
PhratchServerV1 class >> getIPAddressFromServer [
	"Attempt to get my IP address from the AddressServer in bounded time. Returns nil if unsuccessful."
	"[self getIPAddressFromServer] msecs"

	| serverAddr sock msg |
	serverAddr := #(18 85 18 78) asByteArray.
	sock := MessageSocket new.
	sock connectTo: serverAddr port: 54330 waitSecs: 4.
	sock isConnected ifFalse: [^ nil].
	sock sendMessage: 'lookup'.
	20 timesRepeat: [
		sock sendData.
		(msg := sock nextMessage) ifNotNil: [sock destroy. ^ msg].
		(Delay forMilliseconds: 100) wait].

	"timed out"
	sock destroy.
	^ nil

]

{ #category : #utilities }
PhratchServerV1 class >> portNumber [
	"Answer the port number for the Phratch server."

	^ 42000
]

{ #category : #server }
PhratchServerV1 >> acceptNewConnections [
	"Accept new connections, if any. Also process any newly connected outgoing sockets."

	| newSock |
	[serverSocket notNil and: [serverSocket isConnected]] whileTrue: [
		newSock := serverSocket accept.
		incoming addLast: (MessageSocket new on: newSock)].

	newOutgoing size = 0 ifTrue: [^ self].
	newOutgoing copy do: [:sock |
		sock isConnected ifTrue: [  "a new outgoing connection has been made"
			newOutgoing remove: sock ifAbsent: [].
			outgoing add: sock.
			lastSentValues := Dictionary new].  "force all variables to updated"
		(sock socket isWaitingForConnection or: [sock isConnected]) ifFalse: [
			newOutgoing remove: sock ifAbsent: [].
			sock destroy]].

]

{ #category : #accessing }
PhratchServerV1 >> addOutgoingTo: ipAddressString [
	"Add an outgoing connection to the given address. Fail if a connection cannot be made in bounded amount of time. Answer true if the connection was added successfully."

	| addr sock ok |
	addr := NetNameResolver addressForName: ipAddressString timeout: 5.
	sock := MessageSocket new.
	ok := sock connectTo: addr port: PhratchServer portNumber waitSecs: 5.
	ok ifFalse: [sock destroy. ^ false].

	sock sendMessage: 'add-peer ', userName.
	outgoing add: sock.
	^ true

]

{ #category : #'incoming commands' }
PhratchServerV1 >> dispatch: aString socket: requestSock [
	"Dispatch an incoming command from a remote Phratch."

	| cmd op |
	cmd := self parse: aString.
	cmd size = 0 ifTrue: [^ 'missing command name'].
	(cmd first isKindOf: String) ifFalse: [^ 'command name must be a string'].
	op := cmd first asLowercase.

	'add-peer' = op ifTrue: [^ self doAddPeer: cmd socket: requestSock].
	'broadcast' = op ifTrue: [^ self doBroadcast: cmd].
	'sensor-update' = op ifTrue: [^ self doSensorUpdate: cmd].
	'who' = op ifTrue: [^ self doWho: cmd socket: requestSock].

	^ 'unknown command'

]

{ #category : #'incoming commands' }
PhratchServerV1 >> doAddPeer: cmd socket: requestSock [
	"Handle a add-peer command: add-peer <peerName>"

	| peerName addr sock |
	cmd size = 2 ifFalse: [^ self].
	((peerName := cmd at: 2) isKindOf: String) ifFalse: [^ self].

	addr := requestSock socket remoteAddress.
	peerNames at: addr put: peerName.
	sock := MessageSocket new connectTo: addr port: self class portNumber.
	newOutgoing add: sock.

]

{ #category : #'incoming commands' }
PhratchServerV1 >> doBroadcast: cmd [
	"Handle a broadcast command: broadcast <event-name>"

	| evtName |
	cmd size = 2 ifFalse: [^ self].
	((evtName := cmd at: 2) isKindOf: String) ifFalse: [^ self].

	stage ifNotNil: [stage broadcastEventNamed: evtName with: 0].

]

{ #category : #'incoming commands' }
PhratchServerV1 >> doSensorUpdate: cmd [
	"Handle a sensor update command: sensor-update [<sensor-name> <sensor-value>]"

	| i sName sValue |
	i := 2.
	[i < cmd size] whileTrue: [
		sName := cmd at: i.
		sValue := cmd at: i + 1.
		((sName isKindOf: String) and: [sValue isKindOf: Number])
			ifTrue: [sensors at: sName put: sValue].
		i := i + 1].


]

{ #category : #'incoming commands' }
PhratchServerV1 >> doWho: cmd socket: requestSocket [
	"Handle a who command: who"

	requestSocket sendMessage: userName.

]

{ #category : #initialization }
PhratchServerV1 >> initialize [

	userName := 'anonymous'.
	incoming := OrderedCollection new.
	outgoing := OrderedCollection new.
	newOutgoing := OrderedCollection new.
	peerNames := Dictionary new.
	sensors := Dictionary new.
	lastSentValues := Dictionary new.
	outgoingBroadcasts := OrderedCollection new.

]

{ #category : #accessing }
PhratchServerV1 >> isConnected [
	"Answer true if this Phratch server has any external connections."

	incoming size > 0 ifTrue: [^ true].
	outgoing size > 0 ifTrue: [^ true].
	newOutgoing size > 0 ifTrue: [^ true].
	^ false

]

{ #category : #server }
PhratchServerV1 >> openServerSocket [
	"Open a socket on my port and get ready to accept connections."

	Socket initializeNetwork.
	self shutdownServer.
	serverSocket := Socket new.
	serverSocket listenOn: self class portNumber backlogSize: 20.

	incomingUDPSocket := Socket newUDP setPort: self class portNumber.

]

{ #category : #'command parsing' }
PhratchServerV1 >> parse: aString [
	"PhratchServer new parse: 'test abc 1 -1 .01 -.01 true false'"

	| out token |
	in := ReadStream on: aString asString.
	out := OrderedCollection new.
	[in atEnd] whileFalse: [
		token := self readNext.
		token ifNotNil: [out addLast: token]].
	^ out asArray

]

{ #category : #'incoming commands' }
PhratchServerV1 >> processCommandFrom: requestSock [
	"Handle a command from the given socket. Do nothing if there is none."

	| msg result errMsg |
	msg := requestSock nextMessage.
	msg ifNil: [^ self].
	msg size = 0 ifTrue: [requestSock sendMessage: 'PhratchServer 0.1 alpha'. ^ self].

	result := [self dispatch: msg asString socket: requestSock] ifError: [:err :rcvr | err].
	(result isKindOf: String) ifTrue: [
		"string result is an error message; no response sent if command succeeded"
		errMsg := 'PhratchServer error: ', result.
		requestSock sendMessage: errMsg].

]

{ #category : #server }
PhratchServerV1 >> processIncomingCommands [
	"Process incoming commands from my peers."
	"NOTE: Broadcast events are added to the outgoingBroadcasts queue as a side-effect of re-broadcasting them locally. To avoid having broadcasts bounce from peer to peer forever, the outgoingBroadcasts queue is cleard after incoming commands have been processed."

	incoming copy do: [:sock |
		sock isConnected
			ifTrue: [
				self processCommandFrom: sock.
				sock sendData]
			ifFalse: [
				sock destroy.
				incoming remove: sock ifAbsent: []]].

	self processUDPCommands.
	outgoingBroadcasts := outgoingBroadcasts species new.

]

{ #category : #server }
PhratchServerV1 >> processUDPCommands [
	"Process incoming UDP commands."

	| buf n msg |
	incomingUDPSocket ifNil: [^ self].
	buf := String new: 3000.
	[true] whileTrue: [
		n := [incomingUDPSocket receiveDataInto: buf] ifError: [0].
		n = 0 ifTrue: [^ self].

		msg := buf copyFrom: 1 to: n.
		[self dispatch: msg socket: nil] ifError: []].

]

{ #category : #accessing }
PhratchServerV1 >> queueBroadcast: aString [
	"Queue the given broadcast event to be sent to my peers."

	(#(	'Phratch-KeyPressedEvent'
		'Phratch-MouseClickEvent'
	) includes: aString) ifTrue: [^ self].

	outgoingBroadcasts addLast: aString.

]

{ #category : #'command parsing' }
PhratchServerV1 >> readNext [
	"Read the next command line token from 'in' or nil if there are not more tokens. A token is a quoted string, a number, a boolean, or an unquoted string with no embedded whitespace. Strings that start with a digit or minus sign must be quoted to avoid being treated as an integer."

	| ch s |
	"skip white space"
	[in atEnd not and: [in peek asciiValue <= 32]]
		whileTrue: [in next].
	in atEnd ifTrue: [^ nil].

	ch := in peek.
	ch = $" ifTrue: [^ self readQuotedString].
	(ch = $-) | (ch = $.) | ch isDigit ifTrue: [^ self readNumber].

	"unquoted string or boolean"
	s := self readString.
	'true' = s ifTrue: [^ true].
	'false' = s ifTrue: [^ false].
	^ s

]

{ #category : #'command parsing' }
PhratchServerV1 >> readNumber [

	| s sign |
	s := self readString.
	sign := 1.
	s first = $- ifTrue: [s := s copyFrom: 2 to: s size. sign := -1].
	s first = $. ifTrue: [s := '0', s].  "add leading zero"
	^ s asNumber * sign

]

{ #category : #'command parsing' }
PhratchServerV1 >> readQuotedString [

	| result ch |
	result := WriteStream on: String new.
	in next.  "skip opening quote"
	[in atEnd] whileFalse: [
		ch := in next.
		ch = $" ifTrue: [^ result contents].
		result nextPut: ch].

	^ result contents

]

{ #category : #'command parsing' }
PhratchServerV1 >> readString [

	| result ch |
	result := WriteStream on: String new.
	[in atEnd] whileFalse: [
		ch := in peek.
		ch asciiValue <= 32 ifTrue: [^ result contents].
		result nextPut: in next].

	^ result contents

]

{ #category : #variables }
PhratchServerV1 >> recordVariableValues [
	"Record the current values of my global variables."

	lastSentValues := Dictionary new.

	stage ifNotNil: [
		stage varNames do: [:v | lastSentValues at: v put: (stage getVar: v)]].

]

{ #category : #server }
PhratchServerV1 >> sendOutgoingCommands [
	"Send broadcasts and variable updates to my peers."

	| varUpdateMsg |
	self someVariableHasChanged
		ifTrue: [varUpdateMsg := self variableUpdateMessage]
		ifFalse: [varUpdateMsg := nil].

	outgoing copy do: [:sock |
		sock isConnected
			ifTrue: [
				varUpdateMsg ifNotNil: [sock sendMessage: varUpdateMsg].
				outgoingBroadcasts do: [:evt | sock sendMessage: 'broadcast "', evt, '"'].
				sock sendData]
			ifFalse: [
				sock destroy.
				outgoing remove: sock ifAbsent: []]].

	self recordVariableValues.


]

{ #category : #accessing }
PhratchServerV1 >> sensorNames [

	^ sensors keys asArray sort


]

{ #category : #accessing }
PhratchServerV1 >> sensorValueFor: sensorName [
	"Answer the value for the given virtual sensor or nil if the given sensor name is not found."

	^ sensors at: sensorName ifAbsent: [nil]


]

{ #category : #server }
PhratchServerV1 >> shutdownServer [
	"Destroy all open sockets."

	serverSocket ifNotNil: [
		serverSocket destroy.
		serverSocket := nil].

	incomingUDPSocket ifNotNil: [
		incomingUDPSocket destroy.
		incomingUDPSocket := nil].

	incoming do: [:sock | sock destroy].
	outgoing do: [:sock | sock destroy].
	newOutgoing do: [:sock | sock destroy].

	incoming := incoming species new.
	outgoing := incoming species new.
	newOutgoing := incoming species new.

	peerNames := peerNames species new.
	sensors := sensors species new.
	lastSentValues := lastSentValues species new.
	outgoingBroadcasts := outgoingBroadcasts species new.

]

{ #category : #variables }
PhratchServerV1 >> someVariableHasChanged [
	"Answer true if a global variable has changed since I last sent variable updates to my peers."

	| lastVal |
	stage ifNil: [^ false].

	stage varNames do: [:v |
		lastVal := lastSentValues at: v ifAbsent: [nil].
		lastVal ifNil: [^ true].
		(lastVal = (stage getVar: v)) ifFalse: [^ true]].

	^ false

]

{ #category : #accessing }
PhratchServerV1 >> stage: aPhratchStageMorph [

	stage := aPhratchStageMorph.

]

{ #category : #server }
PhratchServerV1 >> stepServer [
	"Do one server step."
	"Note: processIncomingCommands clears outgoingBroadcasts, so do sendOutgoingCommands first."

	self acceptNewConnections.
	self sendOutgoingCommands.
	self processIncomingCommands.

]

{ #category : #accessing }
PhratchServerV1 >> userName [

	^ userName

]

{ #category : #accessing }
PhratchServerV1 >> userName: aString [

	userName := aString.

]

{ #category : #variables }
PhratchServerV1 >> variableUpdateMessage [
	"Answer a variable update message for all variables whose values have not already been sent."

	| msg currentValue lastValue |
	msg := WriteStream on: String new.
	msg nextPutAll: 'sensor-update '.
	stage varNames do: [:varName |
		currentValue := stage getVar: varName.
		lastValue := lastSentValues at: varName ifAbsent: [nil].
		lastValue = currentValue ifFalse: [
			msg nextPutAll: '"', userName, '-', varName, '" '.
			msg nextPutAll: currentValue printString]].

	^ msg contents

]
