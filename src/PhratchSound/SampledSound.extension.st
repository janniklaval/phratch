Extension { #name : #SampledSound }

{ #category : #'*PhratchSound' }
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
