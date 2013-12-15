"
I am a Scratch sound media object. A sound can be played under script control but (obviously) it cannot be used as a costume because it is not a visual media.

"
Class {
	#name : #SoundMedia,
	#superclass : #PhratchMedia,
	#instVars : [
		'originalSound',
		'volume',
		'playingSound',
		'compressedSampleRate',
		'compressedBitsPerSample',
		'compressedData',
		'savedSound'
	],
	#classVars : [
		'PlaceholderSound'
	],
	#category : #'Phratch-Objects'
}

{ #category : #'class initialization' }
SoundMedia class >> initialize [
	"self initialize"

	PlaceholderSound := SampledSound samples: SoundBuffer new samplingRate: 22050.

]

{ #category : #accessing }
SoundMedia >> balance [ 

	^50
]

{ #category : #compressing }
SoundMedia >> compressBitsPerSample: bits saveOriginal: saveFlag [
	"Compress my sound if possible. Return true if compression is done."

	| samples |
	self isBuiltInSound
		ifTrue: [ ^ false ].	"don't compress built-in sounds"
	compressedData ifNotNil: [ ^ false ].	"don't recompress"
	((originalSound isKindOf: SampledSound) not or: [ originalSound isStereo ])
		ifTrue: [ ^ false ].
	savedSound := saveFlag
		ifTrue: [ originalSound ]
		ifFalse: [ nil ].
	samples := originalSound samples.
	compressedSampleRate := originalSound originalSamplingRate.
	[ compressedSampleRate >= 32000 ]
		whileTrue: [ 
			samples := samples downSampledLowPassFiltering: false.
			compressedSampleRate := compressedSampleRate // 2 ].
	compressedBitsPerSample := bits.
	compressedData := (ADPCMCodec newBitsPerSample: bits) encodeSoundBuffer: samples.
	^ true
]

{ #category : #compressing }
SoundMedia >> compressedBitsPerSample [

	^ compressedBitsPerSample

]

{ #category : #compressing }
SoundMedia >> compressedData [

	^ compressedData

]

{ #category : #compressing }
SoundMedia >> compressedSampleRate [

	^ compressedSampleRate

]

{ #category : #accessing }
SoundMedia >> currentSeconds: ignored [
	"Currently, this doesn't do anything. It should jump to the given seconds offset."


]

{ #category : #compressing }
SoundMedia >> decompress [
	"Decompress sound from compressed data so result of compression can be heard. Do nothing if sound is not compressed."

	| samples |
	compressedData ifNil: [^ self].

	samples := (ADPCMCodec newBitsPerSample: compressedBitsPerSample)
		decodeCompressedData: compressedData.
	originalSound := SampledSound
		samples: samples
		samplingRate: compressedSampleRate.


]

{ #category : #'scratch ops' }
SoundMedia >> exportFilename: fileName for: stageOrSprite [
	"Export my sound to a file with the given name."

	| fName f |
	fName := fileName.
	(fName asLowercase endsWith: '.wav') ifFalse: [fName := fName, '.wav'].
	f := StandardFileStream newPhratchFileNamed: fName.
	f ifNil: [^ self].  "could not create or open file for writing"
	f binary.
	originalSound storeWAVSamplesOn: f.
	f close.

]

{ #category : #accessing }
SoundMedia >> infoString [
	"Answer a string for this media, typically something about its size."

	^ self totalSeconds hhmmss
	

]

{ #category : #initialize }
SoundMedia >> initialize [

	super initialize.
	mediaName := 'pop' localized.
	originalSound := ScriptablePhratchMorph popSound.
	volume := 100.

]

{ #category : #compressing }
SoundMedia >> isBuiltInSound [
	"Answer true if my sound is one of the Phratch builtin sounds."

	((mediaName = 'pop') and:
	 [originalSound samples size = ScriptablePhratchMorph popSound samples size])
		ifTrue: [^ true].
	((mediaName = 'meow') and:
	 [originalSound samples size = ScriptablePhratchMorph meowSound samples size])
		ifTrue: [^ true].

	^ false

]

{ #category : #'scratch ops' }
SoundMedia >> isPlaying [
	"Answer true if my sound is playing."

	^ (playingSound notNil and: [playingSound isPlaying])

]

{ #category : #accessing }
SoundMedia >> isSound [
	"Answer true if I am a sound media object."

	^ true

]

{ #category : #accessing }
SoundMedia >> loadFile: fName [
	"Read my samples from a sound file."

	| snd errorString sndName mergedBuf |

	(fName) exists
		ifFalse: [^ self inform: 'File not found' withDetails: fName].

	errorString := nil.
	sndName :=  fName basename.
	UIManager default informUserDuring: [:bar |
		bar label: 'Reading ', sndName, '...'.
		[snd := SampledSound fromFileNamed: fName fullName] ifError: [:err :rcvr |
			snd := nil.
			errorString := err].

		snd ifNotNil: [
			snd isStereo ifTrue: [  "merge stereo to mono"
				bar label: 'Converting ', sndName, 'to mono...'.
				mergedBuf := snd sounds first samples.
				mergedBuf mixIn: snd sounds second samples.
				snd := SampledSound
					samples: mergedBuf
					samplingRate: snd sounds first originalSamplingRate].

			snd originalSamplingRate > 22050 ifTrue: [  "downsample to save space"
				bar label: 'Downsampling ', sndName, '...'.
				snd := SampledSound
					samples: (snd samples downSampledLowPassFiltering: false)
					samplingRate: snd originalSamplingRate / 2]]].

	errorString ifNotNil: [^ self error: errorString]. 
	self sound: snd.

]

{ #category : #accessing }
SoundMedia >> mediaSizeInKilobytes [
	"Returns the storage size of this sound in kilobytes, rounded to the nearest kilobyte."

	| bytes |
	bytes := 0.
	compressedData
		ifNil: [
			(originalSound isKindOf: MixedSound)
				ifTrue: [
					originalSound sounds do: [:snd |
						bytes := bytes + (2 * snd samples monoSampleCount)]]
				ifFalse: [
					bytes := 2 * originalSound samples monoSampleCount]]
		ifNotNil: [bytes := compressedData size].

	^ (bytes + 512) // 1024

]

{ #category : #accessing }
SoundMedia >> mediaType [
	"Answer a string describing this type of media."

	^ 'sound'

]

{ #category : #'scratch ops' }
SoundMedia >> pausePlaying [
	"Pauses sound playback."

	playingSound ifNotNil: [playingSound pause].

]

{ #category : #'scratch ops' }
SoundMedia >> playFrom: startSecs to: endSecs [
	"Play the given portion of the sound. The start and end offsets are in seconds at the original sound's sampling rate regardless of the current playback rate."

	| totalSecs sampleCount startIndex endIndex snd |
	self pausePlaying.
	originalSound ifNil: [^ self].
	totalSecs := self totalSeconds.
	sampleCount := originalSound samples monoSampleCount.
	startIndex := (startSecs * sampleCount // totalSecs) max: 1.
	endIndex := (endSecs * sampleCount // totalSecs) min: sampleCount.
	startIndex < endIndex ifFalse: [^ self].

	playingSound := MixedSound new.
	snd := (SampledSound new
		setSamples: originalSound samples
		from: startIndex to: endIndex
		samplingRate: originalSound originalSamplingRate
		loudness: 1.0).
	playingSound add: snd pan: (self balance / 100.0) volume: (volume / 100.0).
	playingSound play.

]

{ #category : #'scratch ops' }
SoundMedia >> playFromStart [
	"Play my sound from beginning to end."

	self playFrom: 0 to: self totalSeconds.

]

{ #category : #accessing }
SoundMedia >> savedSound [

	^ savedSound

]

{ #category : #compressing }
SoundMedia >> shareSoundWith: aSoundMedia [
	"Share my sound and compressed sound with the given SoundMedia."

	self sound: aSoundMedia sound.
	compressedSampleRate := aSoundMedia compressedSampleRate.
	compressedBitsPerSample := aSoundMedia compressedBitsPerSample.
	compressedData := aSoundMedia compressedData.
	savedSound := aSoundMedia savedSound.

]

{ #category : #accessing }
SoundMedia >> sound [

	^ originalSound

]

{ #category : #accessing }
SoundMedia >> sound: aSampledSound [
	"Set my sound."

	self pausePlaying.
	playingSound := nil.
	originalSound := (SampledSound
		samples: aSampledSound samples
		samplingRate: aSampledSound originalSamplingRate).
	compressedSampleRate := compressedBitsPerSample := compressedData := nil.
	savedSound := nil.

]

{ #category : #'scratch ops' }
SoundMedia >> startPlaying [
	"Resume playing if the sound was paused before the end. Otherwise, start playing from the beginning."

	(playingSound isNil or:
	 [playingSound isEmpty or:
	 [playingSound samplesRemaining = 0]])
		ifTrue: [self playFromStart]
		ifFalse: [playingSound resumePlaying].

]

{ #category : #'scratch ops' }
SoundMedia >> thumbnailFormExtent: extent [
	"Answer a Form of the given extent containing a thumbnail of me containing the sound icon."

	| offForm onForm f icon |
	offForm := PhratchFrameMorph skinAt: #scratchSound.
	onForm := PhratchFrameMorph skinAt: #scratchSoundOn.
	f := (ColorForm extent: extent depth: 8).
	playingSound
		ifNil: [icon := offForm]
		ifNotNil: [icon := self isPlaying ifTrue: [onForm] ifFalse: [offForm]].
	icon displayOn: f at: (f extent - icon extent) // 2 rule: Form paint.
	^ f

]

{ #category : #'scratch ops' }
SoundMedia >> totalSeconds [

	originalSound
		ifNil: [^ 0]
		ifNotNil: [^ originalSound samples size asFloat / originalSound originalSamplingRate].

]

{ #category : #copying }
SoundMedia >> updateReferencesUsing: aDictionary [
	"Nil out my playing sound."

	"super updateReferencesUsing: aDictionary."
	playingSound := nil.

]

{ #category : #accessing }
SoundMedia >> volume [

	^ volume

]

{ #category : #accessing }
SoundMedia >> volume: aNumber [
	"Set my volume, a number between 0 and 100."

	volume := (aNumber rounded max: 0) min: 100.
	playingSound ifNotNil: [
		playingSound setPan: (self balance / 100.0) volume: (volume / 100.0) for: 1]. 

]
