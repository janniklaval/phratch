Extension { #name : #Socket }

{ #category : #'*Phratch-Extensions' }
Socket >> readInto: aStringOrByteArray startingAt: aNumber [
	"Read data into the given buffer starting at the given index and return the number of bytes received. Note the given buffer may be only partially filled by the received data. If no data is available, do nothing and return zero."

	^ self primSocket: socketHandle
		receiveDataInto: aStringOrByteArray
		startingAt: aNumber
		count: aStringOrByteArray size - aNumber + 1
]

{ #category : #'*Phratch-Extensions' }
Socket >> sendDataNoWait: aStringOrByteArray startIndex: startIndex [
	"Send zero or more bytes of data from the given array starting at the given index, and return the number of bytes sent. Do not wait; if the socket is not ready to accept more data, just do nothing and return zero."

	^ self primSocket: self socketHandle
		sendData: aStringOrByteArray
		startIndex: startIndex
		count: aStringOrByteArray size + 1 - startIndex
]

{ #category : #'*Phratch-Extensions' }
Socket >> waitForSendDoneUntil: deadline [
	"Wait up until the given deadline for the current send operation to complete. Return true if it completes by the deadline, false if not."

	| sendDone |
	[self isConnected & (sendDone := self primSocketSendDone: socketHandle) not
			"Connection end and final data can happen fast, so test in this order"
		and: [Time millisecondClockValue < deadline]] whileTrue: [
			self writeSemaphore waitTimeoutMSecs: (deadline - Time millisecondClockValue)].

	^ sendDone
]
