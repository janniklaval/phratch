Extension { #name : #SoundBuffer }

{ #category : #'*Phratch' }
SoundBuffer >> beginsWith: aCollection [
	"Return true if I begin with the samples in the given collection (usually a SoundBuffer or Array)."

	self size >= aCollection size ifFalse: [^ false].
	1 to: aCollection size do: [:i |
		(self at: i) = (aCollection at:i) ifFalse: [^ false]].

	^ true

]

{ #category : #'*Phratch-Extensions' }
SoundBuffer >> reverseEndiannessStereo: stereoFlag [
	"Swap the bytes of each 16-bit word, using a fast BitBlt hack. If stereoFlag is true the channels must also be reversed."

	| hack blt |
	hack := Form new hackBits: self.
	blt := (BitBlt toForm: hack) sourceForm: hack.
	blt combinationRule: Form reverse.  "XOR"
	blt sourceY: 0; destY: 0; height: self size.
	blt width: 1. "one-byte wide columns"
	stereoFlag
		ifTrue: [
			blt sourceX: 0; destX: 3; copyBits.  "swap byte-wide columns 0 and 3 using XOR"
			blt sourceX: 3; destX: 0; copyBits.
			blt sourceX: 0; destX: 3; copyBits.
			blt sourceX: 1; destX: 2; copyBits.  "swap byte-wide columns 1 and 2 using XOR"
			blt sourceX: 2; destX: 1; copyBits.
			blt sourceX: 1; destX: 2; copyBits]
		ifFalse: [
			blt sourceX: 0; destX: 1; copyBits.  "swap byte-wide columns 0 and 1 using XOR"
			blt sourceX: 1; destX: 0; copyBits.
			blt sourceX: 0; destX: 1; copyBits.
			blt sourceX: 2; destX: 3; copyBits.  "swap byte-wide columns 2 and 3 using XOR"
			blt sourceX: 3; destX: 2; copyBits.
			blt sourceX: 2; destX: 3; copyBits].

]

{ #category : #'*Phratch-Extensions' }
SoundBuffer >> storeBigEndianOn: aBinaryStream stereo: stereo [
	"Store my samples onto the given stream in big-endian format (most-significant byte first)."

	| reverseBytes |
	reverseBytes := Smalltalk isBigEndian not.

	(aBinaryStream isKindOf: StandardFileStream)
		ifTrue: [  "optimization for file streams: store directly to file"
			reverseBytes ifTrue: [self reverseEndiannessStereo: stereo].
			aBinaryStream next: (self size // 2) putAll: self startingAt: 1.  "size is in 32-bit words"
			reverseBytes ifTrue: [self reverseEndiannessStereo: stereo]]
		ifFalse: [  "for non-file streams:"
			reverseBytes & stereo ifTrue: [self swapStereoChannels].
			1 to: self monoSampleCount do: [:i | aBinaryStream int16: (self at: i)].
			reverseBytes & stereo ifTrue: [self swapStereoChannels]].
]

{ #category : #'*Phratch-Extensions' }
SoundBuffer >> swapStereoChannels [
	"Swap my left and right stereo channels."

	| hack blt |
	hack := Form new hackBits: self.
	blt := (BitBlt toForm: hack) sourceForm: hack.
	blt combinationRule: Form reverse.  "XOR"
	blt sourceY: 0; destY: 0; height: self size; width: 2.

	blt sourceX: 0; destX: 2; copyBits.  "swap 16-bit words using XOR"
	blt sourceX: 2; destX: 0; copyBits.
	blt sourceX: 0; destX: 2; copyBits.

]
