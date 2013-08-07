"
I download files or pages via HTTP. All the work is done by a separate thread that does only a small amount of work at a time and sleeps for a while after each action. Since each action typically takes only a few milliseconds, I can run in the background without interferring with more time-critical tasks. Furthermore, if any problems occur I simply record the problem and set my status to 'failed'. Thus, some controlling application can check my status and take the appropriate action when I succeed or fail.

"
Class {
	#name : #HTTPFetcher,
	#superclass : #Object,
	#instVars : [
		'serverName',
		'address',
		'portNumber',
		'path',
		'downloadedData',
		'status',
		'failureReason',
		'transportProcess',
		'socket',
		'startMSecs',
		'totalMSecs'
	],
	#category : #'Phratch-Networking'
}

{ #category : #tests }
HTTPFetcher class >> test: n [
	"self test: 5"

	| zips |
	zips := #('01238' '02139' '22201' '22207' '10312' '90210' '94041' '33160').
	^ (1 to: n) collect: [:i |
		HTTPFetcher new
			startDownload: '/forecastrss?pi=', (zips at: (i \\ zips size) + 1), '&u=f'
			fromServer: 'weather.yahooapis.com']
]

{ #category : #private }
HTTPFetcher >> abort: aString [
	"Abort the current operation. The argument is string describing the reason for the failure."

	| p |
	self disconnectFromServer.
	status := #failure.
	failureReason := aString.
	transportProcess ifNotNil: [
		p := transportProcess.
		transportProcess := nil.
		p terminate].	"<- if the active process was the transportProcess, it stops here"

]

{ #category : #accessing }
HTTPFetcher >> bodyData [
	"Answer the downloaded data (a ByteArray) after the HTTP header. May be called before the fetch is complete to get partial data."

	| data cr headerEnd i |
	data := downloadedData contents.
	cr := 13.
	headerEnd := #(13 10 13 10) asByteArray.

	i := 1.
	[i < data size] whileTrue: [
		i := data indexOf: cr startingAt: i ifAbsent: [data size].
		(i < (data size - 4) and:
		 [(data copyFrom: i to: i + 3) = headerEnd])
			ifTrue: [^ data copyFrom: i + 4 to: data size].
		i := i + 1].

	^ ByteArray new  "did not find end of the HTTP header"

]

{ #category : #accessing }
HTTPFetcher >> bytesDownloaded [
	"Answer the total number of bytes downloaded, which includes the HTTP header."

	^ downloadedData size

]

{ #category : #private }
HTTPFetcher >> checkFirstLine [
	"Check that the first line of the response indicates success. If not, abort."

	| data i firstLine tokens err |
	data := downloadedData contents.
	i := data indexOf: 13 ifAbsent: [ ^ self abort: 'bad HTTP header' ].
	firstLine := (data copyFrom: 1 to: i - 1) asString.
	tokens := firstLine findTokens: ' '.
	(tokens size > 2 and: [ (tokens at: 2) size > 0 and: [ (tokens at: 2) first = $2 ] ])
		ifTrue: [ ^ self ].
	err := firstLine copyFrom: (tokens at: 1) size + (tokens at: 2) size + 2 to: firstLine size.
	^ self abort: err
]

{ #category : #private }
HTTPFetcher >> connectToServer [
	"Open a connection to the FTP server on the primary socket. Keep trying until a connection is established. Assume the address has already been looked up."

	self disconnectFromServer.

	socket := Socket new.
	[socket isConnected] whileFalse: [
		socket connectTo: address port: portNumber.
		[socket isWaitingForConnection] whileTrue: [self sleepAWhile].
		socket isConnected ifFalse: [
			socket destroy.
			socket := Socket new.
			self sleepAWhile]].

]

{ #category : #accessing }
HTTPFetcher >> contentLength [
	"Answer the content length from the HTTP header. Answer nil if the header has not yet been received."

	| header s |
	(header := self httpHeaderOrNil) ifNil: [^ nil].
	s := header lines
		detect: [:l | l asLowercase beginsWith: 'content-length: ']
		ifNone: [^ nil].
	s := (s copyFrom: ('content-length: ' size) to: s size) trimBoth.
	^ s asNumber + header size

]

{ #category : #private }
HTTPFetcher >> disconnectFromServer [
	"Close and destroy my sockets. Do nothing if already disconnected."

	startMSecs ifNotNil: [totalMSecs := Time millisecondClockValue - startMSecs].
	socket ifNotNil: [
		socket destroy.
		socket := nil].

]

{ #category : #private }
HTTPFetcher >> endWithSuccess [
	"Set my status to indicate success and terminate the transport process.."

	self disconnectFromServer.
	status ~~ #failure ifTrue: [status := #succeeded].
	transportProcess := nil.

]

{ #category : #status }
HTTPFetcher >> failureReason [
	"Answer a string describing the most recent failure. Answer the empty string if there has not been a failure or if the operation is still in progress."

	status == #failure ifFalse: [^ ''].
	^ failureReason

]

{ #category : #private }
HTTPFetcher >> getResponse [
	"Get data until the socket is closed by the server."

	| buf byteCount |
	buf := ByteArray new: 5000.

	[socket isConnected] whileTrue: [
		self sleepAWhile.
		[(byteCount := socket readInto: buf startingAt: 1) > 0] whileTrue: [
			downloadedData nextPutAll: (buf copyFrom: 1 to: byteCount)]].

	"read any final data from the socket buffer"
	[(byteCount := socket readInto: buf startingAt: 1) > 0] whileTrue: [
		downloadedData nextPutAll: (buf copyFrom: 1 to: byteCount)].

]

{ #category : #private }
HTTPFetcher >> httpFetch [
	"Carry out the HTTP getch operation."

	self connectToServer.
	self sendGetRequest.
	self getResponse.
	self checkFirstLine.
	self endWithSuccess.

]

{ #category : #accessing }
HTTPFetcher >> httpHeaderOrNil [
	"Answer a string containing the HTTP header or nil the full header has not yet been received."

	| data cr headerEnd i |
	data := downloadedData contents.
	cr := 13.
	headerEnd := #(13 10 13 10) asByteArray.

	i := 1.
	[i < data size] whileTrue: [
		i := data indexOf: cr startingAt: i ifAbsent: [data size].
		(i < (data size - 4) and:
		 [(data copyFrom: i to: i + 3) = headerEnd])
			ifTrue: [^ (data copyFrom: 1 to: i + 1) asString].
		i := i + 1].

	^ nil

]

{ #category : #status }
HTTPFetcher >> inProgress [
	"Answer true if the download is still in progress."

	^ status == #inProgress

]

{ #category : #initialization }
HTTPFetcher >> initialize [

	serverName := '127.0.0.1'.
	portNumber := 80.
	path := ''.
	downloadedData := WriteStream on: ByteArray new.
	status := #inProgress.
	failureReason := ''.
	transportProcess := nil.
	socket := nil.

]

{ #category : #private }
HTTPFetcher >> lookupAddress [

	| tries |
	(address notNil and: [failureReason size = 0]) ifTrue: [^ self].

	Socket initializeNetwork.
	tries := 0.
	address := nil.
	[address isNil & (tries < 5)] whileTrue: [
		address := NetNameResolver addressForName: serverName timeout: 200.
		address ifNil: [
			tries := tries + 1.
			(Delay forMilliseconds: 1500) wait]].

	address ifNil: [^ self abort: 'address not found'].

]

{ #category : #accessing }
HTTPFetcher >> path [

	^ path

]

{ #category : #private }
HTTPFetcher >> performWithErrorRecovery: aSymbol [
	"Send myself the given selector and ignore any errors that occur."

	[self perform: aSymbol]
		ifError: [:err :rcvr | self abort: err].

]

{ #category : #printing }
HTTPFetcher >> printOn: aStream [
	aStream
		nextPutAll: 'HTTPFetcher(';
		nextPutAll: status printString;
		nextPutAll: ' ';
		nextPutAll: totalMSecs printString;
		nextPutAll: ')'
]

{ #category : #private }
HTTPFetcher >> sendGetRequest [
	"Send an HTTP GET request."

	| request i byteCount |
	request :=
		'GET ', path, ' HTTP/1.0', String crlf,
		'Host: ', serverName, ':', portNumber printString, String crlf,
		String crlf.

	i := 1.
	[socket isConnected and: [i < request size]] whileTrue: [
		byteCount := socket sendDataNoWait: request startIndex: i.
		byteCount > 0 ifTrue: [i := i + byteCount].
		i < request size ifTrue: [self sleepAWhile]].

]

{ #category : #accessing }
HTTPFetcher >> serverName [

	^ serverName

]

{ #category : #private }
HTTPFetcher >> sleepAWhile [
	"Sleep for a while before proceeding. This frees CPU cycles for use by other processes."

	(Delay forMilliseconds: 100) wait.

]

{ #category : #downloading }
HTTPFetcher >> startDownload [
	"Start the download. Assume the server name and path have been set."

	self stopDownload.
	self startFetchProcess.

]

{ #category : #downloading }
HTTPFetcher >> startDownload: aString fromServer: serverNameString [
	"Start downloading the file or page with the given path from the given server. Numeric server name strings such as '127.0.0.1' are allowed. The path is the part of the URL after the server name. For example, it would be '/' for the URL http://www.google.com/"

	serverName := serverNameString.
	path := aString.
	self startDownload.


]

{ #category : #private }
HTTPFetcher >> startFetchProcess [
	"Start up the fetch process."

	self disconnectFromServer.
	transportProcess ifNotNil: [
		transportProcess terminate.
		transportProcess := nil].

	startMSecs := Time millisecondClockValue.
	self lookupAddress.

	downloadedData := WriteStream on: (ByteArray new: 10000).
	status := #inProgress.
	failureReason := ''.

	transportProcess := [self performWithErrorRecovery: #httpFetch] newProcess.
	transportProcess
		priority: Processor userInterruptPriority;
		resume.

]

{ #category : #downloading }
HTTPFetcher >> stopDownload [
	"Stop the download process and disconnect from the server."

	transportProcess ifNotNil: [
		status := #failure.
		failureReason := 'stopped'.
		transportProcess terminate.
		transportProcess := nil].

	self disconnectFromServer.

]

{ #category : #status }
HTTPFetcher >> succeeded [
	"Answer true if the download completed successfully."

	^ status == #succeeded

]
