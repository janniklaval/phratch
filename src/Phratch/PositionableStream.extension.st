Extension { #name : #PositionableStream }

{ #category : #'*Phratch-Extensions' }
PositionableStream >> littleEndianUint16 [
	"Answer the next unsigned, little-endian 16-bit integer from this (binary) stream."

	| n |
	n := self next.
	^ (self next bitShift: 8) + n

]

{ #category : #'*Phratch-Extensions' }
PositionableStream >> littleEndianUint16: anInteger [
	"Store the given unsigned, 16-bit integer on this (binary) stream least-significant byte first."

	(anInteger < 0) | (anInteger >= 16r10000)
		ifTrue: [self error: 'outside unsigned 16-bit integer range'].

	self nextPut: (anInteger digitAt: 1).
	self nextPut: (anInteger digitAt: 2).

]

{ #category : #'*Phratch-Extensions' }
PositionableStream >> littleEndianUint24 [
	"Answer the next unsigned, little-endian 24-bit integer from this (binary) stream."

	| bytes |
	bytes := self next: 3.
	^ (bytes at: 1) + ((bytes at: 2) bitShift: 8) + ((bytes at: 3) bitShift: 16)
]

{ #category : #'*Phratch-Extensions' }
PositionableStream >> littleEndianUint24: anInteger [
	"Store the given unsigned, 24-bit integer on this (binary) stream least-significant byte first."

	(anInteger < 0) | (anInteger >= 16r1000000)
		ifTrue: [self error: 'outside unsigned 24-bit integer range'].

	self nextPut: (anInteger digitAt: 1).
	self nextPut: (anInteger digitAt: 2).
	self nextPut: (anInteger digitAt: 3).

]

{ #category : #'*Phratch-Extensions' }
PositionableStream >> littleEndianUint32 [
	"Answer the next unsigned, little-endian 32-bit integer from this (binary) stream."
	"Add the most-signficant byte in last to avoid extra large-integer operations."

	| bytes |
	bytes := self next: 4.
	^ ((bytes at: 1) + ((bytes at: 2) bitShift: 8) + ((bytes at: 3) bitShift: 16)) +
		((bytes at: 4) bitShift: 24)

]

{ #category : #'*Phratch-Extensions' }
PositionableStream >> littleEndianUint32: anInteger [
	"Store the given unsigned, 32-bit integer on this (binary) stream least-significant byte first."

	(anInteger < 0) | (anInteger >= 16r100000000)
		ifTrue: [self error: 'outside unsigned 32-bit integer range'].

	self nextPut: (anInteger digitAt: 1).
	self nextPut: (anInteger digitAt: 2).
	self nextPut: (anInteger digitAt: 3).
	self nextPut: (anInteger digitAt: 4).

]
