Extension { #name : #SoundMedia }

{ #category : #'*PhratchObjStream' }
SoundMedia >> fieldsVersion [

	^ 2

]

{ #category : #'*PhratchObjStream' }
SoundMedia >> initFieldsFrom: anObjStream version: classVersion [

	| samples |
	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		originalSound
		volume
	) from: anObjStream.

	classVersion = 1 ifTrue: [^ self].

	"fields added in version 2"
	self initFieldsNamed: #(
		compressedSampleRate
		compressedBitsPerSample
		compressedData
	) from: anObjStream.

	compressedData ifNotNil: [
		samples := (ADPCMCodec newBitsPerSample: compressedBitsPerSample)
			decodeCompressedData: compressedData.

		originalSound := SampledSound
			samples: samples
			samplingRate: compressedSampleRate].


]
