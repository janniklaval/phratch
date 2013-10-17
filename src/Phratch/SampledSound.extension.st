Extension { #name : #SampledSound }

{ #category : #'*Phratch-Extensions' }
SampledSound >> currentPosition [
	"Answer the current position of the playback head in seconds since the start of this sound (at the original sampling)."

	| sampleIndex |
	sampleIndex := indexHighBits + (scaledIndex >> IncrementFractionBits).
	^ sampleIndex asFloat / originalSamplingRate

]

{ #category : #'*Phratch-Extensions' }
SampledSound >> equals: aSampledSound [
	"Answer true if the receiver is exactly the same as the given SampledSound."

	self == aSampledSound ifTrue: [^ true].

	self class = aSampledSound class ifFalse: [^ false].
	(originalSamplingRate = aSampledSound originalSamplingRate) ifFalse: [^ false].

	^ samples = aSampledSound samples

]

{ #category : #'*Phratch-Extensions' }
SampledSound >> fieldsVersion [

	^ 2

]

{ #category : #'*Phratch-Extensions' }
SampledSound classSide >> findWAVEChunk: chunkID in: aBinaryStream ifAbsent: notFoundBlock [
	"Search the given stream from its beginning for a chunk with the given four-letter id and answer the size of the chunk. The stream is left positioned at the start of the chunk data. If  no chunk of the given type is found, answer the result of evaluating notFoundBlock."

	| id count |
	aBinaryStream position: 0.
	id := (aBinaryStream next: 4) asString.
	id = 'RIFF' ifFalse: [^ self error: 'Not a RIFF file'].
	aBinaryStream skip: 4.  "skip total length"

	id := (aBinaryStream next: 4) asString.
	id = 'WAVE' ifFalse: [^ self error: 'Not a WAVE file'].

	[aBinaryStream atEnd] whileFalse: [
		id := (aBinaryStream next: 4) asString.
		count := aBinaryStream littleEndianUint32.
		id = chunkID ifTrue: [^ count].
		aBinaryStream skip: (count roundUpTo: 2)].  "skip this chunk. round size up to next even number"

	^ notFoundBlock value

]

{ #category : #'*Phratch-Extensions' }
SampledSound classSide >> fromFileNamed: fileName [
	"Read a sound from the file of the given name. The resulting sound may be a SampledSound (mono) or a MixedSound (stereo)."
	"(SampledSound fromFileNamed: 'test.aif') play"

	| f id snd |
	f := (FileStream readOnlyFileNamed: fileName) binary.
	id := (f next: 4) asString.
	f position: 0.
	id = 'RIFF' ifTrue: [snd := self readWAVFrom: f].
	id = 'FORM' ifTrue: [snd := self readAIFFrom: f].
	id = '.snd' ifTrue: [snd := self readSNDFrom: f].
	f close.

	snd ifNotNil: [^ snd].

	([MPEGFile isFileValidMPEG: fileName] ifError: [false]) ifTrue: [
		snd := self readMP3FromFileNamed: (fileName)].

	snd ifNil: [self error: 'Unrecognized audio file format'].

	^ snd

]

{ #category : #'*Phratch-Extensions' }
SampledSound >> initFieldsFrom: anObjStream version: classVersion [

	self initFieldsNamed: #(
		envelopes
		scaledVol
		initialCount
		samples
		originalSamplingRate
		samplesSize
		scaledIncrement
	) from: anObjStream.

	classVersion = 1 ifFalse: [^ self].

	self initFieldsNamed: #(
		scaledInitialIndex 
	) from: anObjStream.
]

{ #category : #'*Phratch-Extensions' }
SampledSound classSide >> readAIFFrom: aBinaryStream [
	"Read a sound in AIFF format from the given stream."

	| aiff channels samplingRate |
	aiff := AIFFFileReader new.
	aiff readFromStream: aBinaryStream mergeIfStereo: true skipDataChunk: false.
	channels := aiff channelData size.
	samplingRate := aiff samplingRate.

	"build sound object"
	channels = 1 ifTrue: [^ self samples: (aiff channelData at: 1) samplingRate: samplingRate].
	channels = 2 ifTrue: [
		^ MixedSound new
			add: (self samples: (aiff channelData at: 1) samplingRate: samplingRate) pan: 0.0;
			add: (self samples: (aiff channelData at: 2) samplingRate: samplingRate) pan: 1.0;
			yourself].

	 self error: 'Unsupported number of channels: ', channels printString.
]

{ #category : #'*Phratch-Extensions' }
SampledSound classSide >> readMP3FromFileNamed: fileName [
	"Read a sound in MP3 format from the file with the given name. Answer true if successful."

	| mpegFile channels sampleCount samplingRate buf1 snd buf2 |
	(MPEGFile isFileValidMPEG: fileName) ifFalse: [^ self error: 'Bad MP3 file: ', fileName].
	mpegFile := MPEGFile openFile: fileName.
	channels := mpegFile audioChannels: 0. "assume sound track is in stream 0"
	channels > 2 ifTrue: [
		mpegFile close.
		^ self error: 'Unsupported number of channels: ', channels printString].

	sampleCount := mpegFile audioSamples: 0.
	samplingRate := mpegFile audioSampleRate: 0.
	buf1 := SoundBuffer newMonoSampleCount: sampleCount.
	mpegFile audioReadBuffer: buf1 stream: 0 channel: 0.

	"build sound object"
	channels = 1 ifTrue: [snd := self samples: buf1 samplingRate: samplingRate].
	channels = 2 ifTrue: [
		buf2 := SoundBuffer newMonoSampleCount: sampleCount.
		mpegFile audioReReadBuffer: buf2 stream: 0 channel: 1.
		snd := MixedSound new
			add: (self samples: buf1 samplingRate: samplingRate) pan: 0.0;
			add: (self samples: buf2 samplingRate: samplingRate) pan: 1.0;
			yourself].

	mpegFile closeFile.
	^ snd
]

{ #category : #'*Phratch-Extensions' }
SampledSound classSide >> readSNDFrom: aBinaryStream [
	"Read a sound in Sun Audio format from the given stream."
	"A few formats in use:
		1	muLaw
		2	8-bit linear
		3	16-bit linear"

	| id hdrSize count encoding samplingRate channels data leftAndRight |
	"read the header"
	id := (aBinaryStream next: 4) asString.
	id = '.snd'
		ifFalse: [ ^ self error: 'Not a Sun Audio (.au) file' ].
	hdrSize := aBinaryStream uint32.
 	count := aBinaryStream uint32.
	encoding := aBinaryStream uint32.
	samplingRate := aBinaryStream uint32.
	channels := aBinaryStream uint32.
	aBinaryStream skip: hdrSize - 24.	"check the format"
	(encoding between: 1 and: 3)
		ifFalse: [ ^ self error: 'Unsupported Sun Audio (.au) format: ' , encoding printString ].
	encoding = 1
		ifTrue: [ data := self uLawDecode: (aBinaryStream next: count) ].
	encoding = 2
		ifTrue: [ data := self convert8bitSignedTo16Bit: (aBinaryStream next: count) ].
	encoding = 3
		ifTrue: [ 
			data := SoundBuffer newMonoSampleCount: count // 2.
			aBinaryStream next: count // 4 into: data startingAt: 1.	"size is in 32-bit words"
			Smalltalk isBigEndian
				ifFalse: [ data reverseEndiannessStereo: channels = 2 ] ].	"build sound object"
	channels = 1
		ifTrue: [ ^ self samples: data samplingRate: samplingRate ].
	channels = 2
		ifTrue: [ 
			leftAndRight := data splitStereo.
			^ MixedSound new
				add: (self samples: leftAndRight first samplingRate: samplingRate) pan: 0.0;
				add: (self samples: leftAndRight last samplingRate: samplingRate) pan: 1.0;
				yourself ].
	self error: 'Unsupported number of channels: ' , channels printString
]

{ #category : #'*Phratch-Extensions' }
SampledSound classSide >> readWAVFrom: aBinaryStream [
	"Answer a new instance of me from the windows WAV file with the given name. Currently, only formats 1 (uncompressed 8-bit or 16-bit) and 7 (muLaw) WAV files can be read."
	"A few formats in use:
		 1	PCM audio in integer format
		 2	Microsoft adaptive PCM
		 7	muLaw
		17	Intel DVI:=ADPCM
		85	ISO/MPEG Layer 3"

	| count header s encoding channels samplingRate bitsPerSample data leftAndRight |
	count := self findWAVEChunk: 'fmt ' in: aBinaryStream ifAbsent: [^ self error: 'Bad WAV file'].
	header := aBinaryStream next: count.

	"process format chunk"
	s := ReadStream on: header.
	encoding := s littleEndianUint16.
	channels := s littleEndianUint16.
	samplingRate := s littleEndianUint32.
	s littleEndianUint32.  "average bytes per second"
	s littleEndianUint16.  "block alignment"
	bitsPerSample := s littleEndianUint16.

	"check the format"
	({1 . 7} includes: encoding) ifFalse: [
		^ self error: 'Unsupported WAV format: ', encoding printString].
	({8 . 16} includes: bitsPerSample) ifFalse: [
		^ self error: 'Unsupported wave bits/sample: ', bitsPerSample printString].

	"read samples"
	count := self findWAVEChunk: 'data' in: aBinaryStream ifAbsent: [^ self error: 'Bad WAV file'].

	bitsPerSample = 8
		ifTrue: [
			data := aBinaryStream next: count.
			encoding = 1 ifTrue: [data := self convert8bitUnsignedTo16Bit: data].
			encoding = 7 ifTrue: [data := self uLawDecode: data]]
		ifFalse: [
			data := SoundBuffer newMonoSampleCount: count // 2.
			aBinaryStream next: (count // 4) into: data startingAt: 1.  "size is in 32-bit words"
			Smalltalk isBigEndian ifTrue: [data reverseEndiannessStereo: (channels = 2)]].

	"build sound object"
	channels = 1 ifTrue: [^ self samples: data samplingRate: samplingRate].
	channels = 2 ifTrue: [
		leftAndRight := data splitStereo.
		^ MixedSound new
			add: (self samples: leftAndRight first samplingRate: samplingRate) pan: 0.0;
			add: (self samples: leftAndRight last samplingRate: samplingRate) pan: 1.0;
			yourself].

	 self error: 'Unsupported number of channels: ', channels printString.
]

{ #category : #'*Phratch-Extensions' }
SampledSound >> setSamples: anArray from: startIndex to: endIndex samplingRate: rate loudness: loudness [
	"Initialize me to play the given range of the given array at the given sampling rate."

	| buf |
	anArray class isWords
		ifFalse: [ 
			"convert the subarray into a SoundBuffer"
			buf := SoundBuffer fromArray: (anArray copyFrom: startIndex to: endIndex).
			^ self setSamples: buf samplingRate: rate ].
	samples := anArray class isWords
		ifTrue: [ anArray ]
		ifFalse: [ SoundBuffer fromArray: anArray ].
	samplesSize := samples size.
	originalSamplingRate := rate.
	self loudness: loudness.
	initialCount := (endIndex - (startIndex - 1)) * SoundPlayer samplingRate // rate.
	self reset
]

{ #category : #'*Phratch-Extensions' }
SampledSound >> storeFieldsOn: anObjStream [

	self storeFieldsNamed: #(
		envelopes
		scaledVol
		initialCount
		samples
		originalSamplingRate
		samplesSize
		scaledIncrement
	"	scaledInitialIndex " "version 1"
	) on: anObjStream.

]
