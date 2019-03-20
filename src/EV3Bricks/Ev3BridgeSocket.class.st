Class {
	#name : #Ev3BridgeSocket,
	#superclass : #Ev3Bridge,
	#category : #EV3Bricks
}

{ #category : #'instance-creation' }
Ev3BridgeSocket class >> newWithBrick: aBrick [
	|aBlock|
	
	aBlock := self new.
	aBlock brick: aBrick.
	^ aBlock
]

{ #category : #'instance-creation' }
Ev3BridgeSocket class >> newWithIp: anIp [

	| ev3 datagram |
	ev3 := Ev3BridgeSocket new.
	ev3 waitForEv3Datagram: anIp.

	datagram := OCNDatagramPacket new.
	datagram data: 'Serial-Number: ', ev3 serialNumber , '\x0d\x0aPort: 5555\x0d\x0aName: EV3\x0d\x0aProtocol: EV3\x0d\x0a'.
	datagram sourceIP: anIp port: ev3 ev3UdpPort type: OCNIpv4Address.
	ev3 datagram: datagram.
	
	ev3 initializeConnectionInformation.
	ev3 allowTCPConnection.
	ev3 establishConnection.
	^ev3
]

{ #category : #'as yet unclassified' }
Ev3BridgeSocket >> establishConnection [
	
	"It connects to the brick using TCP/IP on port 5555 and it uses this connection to send the unlock message. The brick should  reply with a 16 byte TCP/IP message with the following text: 'Accept:EV340' indicating that the connection has been established. After that you should be able to send commands to the brick over a WiFi connection."
	
	| data ip |
	
	ip := OCNIpv4Address newFromString: self ev3Ip.
	ip port: self ev3Port.
	
	socket ifNotNil: [ socket destroy ].
	
	socket :=Socket newTCP.
	socket connectTo: ip ip  port: self ev3Port.	
	
	socket sendData: 'GET /target?sn=', self serialNumber , 'VMTP1.0\r\nProtocol: EV3'.
	socket waitForDataFor: 3.
	data := socket receiveData.
	^ self assert: ((data beginsWith: 'Accept:EV340') or: [data = '']).
]

{ #category : #connection }
Ev3BridgeSocket >> send: aCommand [
	|toSend|
	toSend:= aCommand prepareToSend.
	Transcript show: 'Sending:'; cr; show: toSend hex; cr.

	^ socket sendData: toSend.
]
