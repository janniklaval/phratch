Extension { #name : #SoundBuffer }

{ #category : #'*PhratchObjStream' }
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

{ #category : #'*PhratchObjStream' }
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
