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
