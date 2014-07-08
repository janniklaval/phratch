Class {
	#name : #Ev3Bridge,
	#superclass : #Object,
	#instVars : [
		'serialNumber',
		'ev3Ip',
		'ev3Port',
		'ev3UdpPort',
		'ev3Name',
		'ev3Protocol',
		'socket',
		'datagram',
		'brick'
	],
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3Bridge >> allowTCPConnection [
	"To allow a TCP connection, we send an UDP messageto the port that broadcast the message. The contents of the data is irrelevant so just send a single byte. The important thing is that you send it to the source port that was used in the bricks broadcast message. Once this message has been sent the brick is ready to accept a TCP/IP connection."
	
	| udpSocket addr aDatagramPacket|

	addr := (OCNIpv4Address newFromString: self ev3Ip) port: self ev3UdpPort.

	aDatagramPacket := OCNDatagramPacket new.
	aDatagramPacket
		data: 'd'; 
		targetAddress: addr; 
		more: false.
	
	udpSocket := OCNUdpSocket newWithNetworkLibrary: (OCNNetworkLibraryProxyFactory proxyForLibraryClass: OCNSocketPluginLibrary).
	^ udpSocket send: aDatagramPacket
]

{ #category : #accessing }
Ev3Bridge >> brick [
	^ brick
]

{ #category : #accessing }
Ev3Bridge >> brick: anObject [
	brick := anObject
]

{ #category : #accessing }
Ev3Bridge >> datagram [
	
	^ datagram
]

{ #category : #accessing }
Ev3Bridge >> datagram: anObject [
	
	datagram := anObject
]

{ #category : #'as yet unclassified' }
Ev3Bridge >> disconnect [
		
	socket disconnect.
	socket := nil
]

{ #category : #accessing }
Ev3Bridge >> ev3Ip [
	
	^ ev3Ip
]

{ #category : #accessing }
Ev3Bridge >> ev3Ip: anObject [
	
	ev3Ip := anObject
]

{ #category : #accessing }
Ev3Bridge >> ev3Name [
	
	^ ev3Name
]

{ #category : #accessing }
Ev3Bridge >> ev3Name: anObject [
	
	ev3Name := anObject
]

{ #category : #accessing }
Ev3Bridge >> ev3Port [
	
	^ ev3Port
]

{ #category : #accessing }
Ev3Bridge >> ev3Port: anObject [
	
	ev3Port := anObject
]

{ #category : #accessing }
Ev3Bridge >> ev3Protocol [
	
	^ ev3Protocol
]

{ #category : #accessing }
Ev3Bridge >> ev3Protocol: anObject [
	
	ev3Protocol := anObject
]

{ #category : #accessing }
Ev3Bridge >> ev3UdpPort [
	
	^ ev3UdpPort
]

{ #category : #accessing }
Ev3Bridge >> ev3UdpPort: anObject [
	
	ev3UdpPort := anObject
]

{ #category : #'initialize-release' }
Ev3Bridge >> initializeConnectionInformation [

	"initialize the instance variables with the information given by the datagram"
	|data|
	data := (self datagram data subStrings: ':').

	self serialNumber: ((data at: 2)subStrings: '\') first withBlanksCondensed.
	self ev3Ip: self datagram sourceAddress ip.
	self ev3UdpPort: self datagram sourceAddress port.
	self ev3Port: (((data at: 3)subStrings: '\') first) asInteger.
	self ev3Name: ((data at: 4)subStrings: '\') first withBlanksCondensed.
	self ev3Protocol: ((data at: 5)subStrings: '\') first withBlanksCondensed.
]

{ #category : #accessing }
Ev3Bridge >> isConnected [
	
	socket ifNil: [ ^false ].
	^ socket isConnected
]

{ #category : #'as yet unclassified' }
Ev3Bridge >> populateWithDatagram [

	|contents|
	ev3UdpPort := datagram sourceAddress port.
	ev3Ip := datagram sourceAddress ip.
	contents := (datagram data asString) subStrings: String crlf.
	
	serialNumber := ((contents first) subStrings: ' ') last.
	ev3Port  := ((contents at: 2) subStrings: ' ') last asInteger.
	ev3Name  := ((contents at: 3) subStrings: ' ') last.
	ev3Protocol  := ((contents at: 4) subStrings: ' ') last.
]

{ #category : #connection }
Ev3Bridge >> receive [
	|received|
	received:= socket receiveData asByteArray.
	Transcript show: 'receiving:'; cr; show: received hex; cr.
	^ received.
 
	
]

{ #category : #accessing }
Ev3Bridge >> send: aCommand [
	
		self subclassResponsibility 
]

{ #category : #connection }
Ev3Bridge >> sendAndReceive: aCommand [

	socket isConnected ifTrue:[
		self send: aCommand.
		^ self receive.
 	] ifFalse: [  Ev3Exception signal: 'Ev3 not connected' ].
	
]

{ #category : #connection }
Ev3Bridge >> sendCommand: aCommand withReply: aBool [

	(aCommand isDirectCommand) ifTrue:[^ self sendDirectCommand: aCommand withReply: aBool sequence: aCommand sequenceNumber].
	(aCommand isSystemCommand) ifTrue:[^ self sendSystemCommand: aCommand withReply: aBool sequence: aCommand sequenceNumber].
	
]

{ #category : #connection }
Ev3Bridge >> sendDirectCommand: aCommand withReply: aBool sequence: aNumber [

	|reply|
	aBool ifTrue: [  
		reply := Ev3DirectReply newData: (self sendAndReceive: self).
		reply checkForError: aNumber.
	] ifFalse: [ 
		self send: aCommand. 
	].
	^reply
]

{ #category : #connection }
Ev3Bridge >> sendSystemCommand: aCommand withReply: aBool sequence: aNumber [

	|reply|
	aBool ifTrue: [  
		reply := Ev3SystemReply newData: (self sendAndReceive: self).
		reply checkForError: aNumber.
	] ifFalse: [ 
		self send: aCommand. 
	].
	^reply
]

{ #category : #accessing }
Ev3Bridge >> serialNumber [
	
	^ serialNumber
]

{ #category : #accessing }
Ev3Bridge >> serialNumber: anObject [
	
	serialNumber := anObject
]

{ #category : #accessing }
Ev3Bridge >> socket [
	
	^ socket
]

{ #category : #accessing }
Ev3Bridge >> socket: anObject [
	
	socket := anObject
]

{ #category : #'as yet unclassified' }
Ev3Bridge >> waitForEv3Datagram: ipAddress [
	
	"This method receive the message broadcasted every 10 seconds by the mindstorm"
	|udpSocket received |
	
	
	udpSocket := OCNUdpSocket newWithNetworkLibrary: (OCNNetworkLibraryProxyFactory proxyForLibraryClass: OCNSocketPluginLibrary).
	udpSocket setOption: 'SO_BROADCAST' value: true.
	udpSocket getOption: 'SO_BROADCAST'.
	udpSocket setPort: 3015.
	
	received := nil.
	1 to: 5 do:[:i |
		|ipFormatted|
		received ifNil: [received := ([udpSocket receive] on: Error do:[nil]) ].
		ipFormatted := ((ipAddress subStrings: '.') collect: [ :e | e asInteger ]) asByteArray.
		
		received ifNotNil:[
			received sourceAddress ip = ipFormatted ifFalse:[
				received := nil.
			]
		]
	].
	
	received ifNotNil: [ 
		self datagram: received.
		self populateWithDatagram.
	]
]
