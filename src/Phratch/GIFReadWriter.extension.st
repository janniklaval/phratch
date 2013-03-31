Extension { #name : #GIFReadWriter }

{ #category : #'*Phratch-UI-Support' }
GIFReadWriter >> nextImageSet [
	| t1 t2 |
	stream class == ReadWriteStream
		ifFalse: 
			[(stream respondsTo: #binary)
				ifTrue: [stream binary].
			self on: (ReadWriteStream with: stream contentsOfEntireFile)].
	t1 := OrderedCollection new.
	self readHeader.
	t2 := nil.
	[(t2 := self readBody) isNil]
		whileFalse: [t1 addLast: t2].
	self close.
	^ t1 asArray collect: [:t3 | t3 colorReduced]
]
