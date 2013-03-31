"
This class is used to fetch variables from a Message Server.

Here is some test code (copy into a Workspace window to try it):
  fetcher := ScratchGlobalFetcher new fetchVar: 'tammy-y' fromServer: '66.30.112.27'.
  fetcher succeeded
  fetcher getResult

The step method of ScratchFrameMorph would check for fetchers that have succeeded and then getResult and put it into the global variables cache. It should also check for failure (inProgress would be false and suceeded also false) and delete those fetchers.

"
Class {
	#name : #PhratchGlobalFetcher,
	#superclass : #HTTPFetcher,
	#instVars : [
		'varName',
		'request'
	],
	#category : #'Phratch-Networking'
}

{ #category : #private }
PhratchGlobalFetcher >> fetchVar: aString [
	"Start fetching the given variable from the default Message server."

	portNumber := MsgServerTestTammy portNumber.
	self stopDownload.
	request := '\get\' , aString.
	self startFetchProcess.

]

{ #category : #private }
PhratchGlobalFetcher >> fetchVar: aString fromServer: serverNameString [
	"Start fetching the given variable from the given Message server. Numeric server name strings such as '127.0.0.1' are allowed."

	portNumber := MsgServerTestTammy portNumber.
	self stopDownload.
	serverName := serverNameString.
	request := '\get\' , aString.
	self startFetchProcess.

]

{ #category : #requests }
PhratchGlobalFetcher >> getAllVars [
	"Start fetching the given variable from the default Message server."

	portNumber := MsgServerTestTammy portNumber.
	self stopDownload.
	request := '/allvars'.
	self startFetchProcess.

]

{ #category : #private }
PhratchGlobalFetcher >> getResponse [
	"Get data until the socket is closed by the server."

	| buf byteCount |
	buf := ByteArray new: 5000.

	[socket isConnected] whileTrue: [
		self sleepAWhile.
		[(byteCount := socket readInto: buf startingAt: 1) > 0] whileTrue: [
			downloadedData nextPutAll: (buf copyFrom: 1 to: byteCount)].
		self isDone ifTrue: [^ self]].

]

{ #category : #private }
PhratchGlobalFetcher >> getResult [
	"Answer true if I've received a complete message from the server."

	| buf |
	self endWithSuccess.
	buf := self rawData.
	^ (buf copyFrom: 5 to: buf size) asString

]

{ #category : #private }
PhratchGlobalFetcher >> httpFetch [
	"Carry out the HTTP getch operation."

	self connectToServer.
	self sendRequest.
	self getResponse.
	self isDone
		ifTrue: [self endWithSuccess]
		ifFalse: [self abort: 'incomplete message from Message Server'].

]

{ #category : #private }
PhratchGlobalFetcher >> initialize [

	super initialize.
	serverName := 'the-view.dyndns.org'.
]

{ #category : #private }
PhratchGlobalFetcher >> isDone [
	"Answer true if I've received a complete message from the server."

	| buf count |
	buf := downloadedData contents.
	buf size < 4 ifTrue: [^ false].
	count := (ReadStream on: buf) uint32.
	^ buf size = (count + 4)
]

{ #category : #requests }
PhratchGlobalFetcher >> request: requestString [
	"Start fetching the given variable from the default Message server."

	portNumber := MsgServerTestTammy portNumber.
	self stopDownload.
	request := requestString.
	self startFetchProcess.

]

{ #category : #private }
PhratchGlobalFetcher >> request: aString fromServer: serverNameString [
	"Start fetching the given variable from the given Message server. Numeric server name strings such as '127.0.0.1' are allowed."

	portNumber := MsgServerTestTammy portNumber.
	self stopDownload.
	serverName := serverNameString.
	request := aString.
	self startFetchProcess.

]

{ #category : #private }
PhratchGlobalFetcher >> sendGetRequest [
	"Send an Scratch GET request."

	| requestString s requestMsg i byteCount |
	requestString := '/get/', varName.
	s := WriteStream on: ByteArray new.
	s uint32: requestString size.
	s nextPutAll: requestString asByteArray.
	requestMsg := s contents.

	i := 1.
	[socket isConnected and: [i < requestMsg size]] whileTrue: [
		byteCount := socket sendDataNoWait: requestMsg startIndex: i.
		byteCount > 0 ifTrue: [i := i + byteCount].
		i < requestMsg size ifTrue: [self sleepAWhile]].

]

{ #category : #private }
PhratchGlobalFetcher >> sendRequest [
	"Send an Scratch GET request."

	| s i byteCount finalRequest |
	s := WriteStream on: ByteArray new.
	s uint32: request size.
	s nextPutAll: request asByteArray.
	finalRequest := s contents.

	i := 1.
	[socket isConnected and: [i < finalRequest size]] whileTrue: [
		byteCount := socket sendDataNoWait: finalRequest startIndex: i.
		byteCount > 0 ifTrue: [i := i + byteCount].
		i < finalRequest size ifTrue: [self sleepAWhile]].

]
