"
I represent a monophonic sampled sound compressed with ADPCM Codec.

"
Class {
	#name : #CompressedMonoSound,
	#superclass : #Object,
	#instVars : [
		'originalSound',
		'samplingRate',
		'bitsPerSample',
		'data'
	],
	#category : #'Phratch-Sound'
}

{ #category : #'compress/decompress' }
CompressedMonoSound >> compressSound: aSound bitsPerSample: bits [

	| samples |
	originalSound := aSound.

	self assert: [originalSound isKindOf: SampledSound].
	self assert: [originalSound isStereo not].

	samples := originalSound samples.
	samplingRate := originalSound originalSamplingRate.
	samplingRate > 22050 ifTrue: [
		samples := samples downSampledLowPassFiltering: false.
		samplingRate := samplingRate // 2].

	bitsPerSample := bits.
	data := (ADPCMCodec newBitsPerSample: bits) encodeSoundBuffer: samples.

]

{ #category : #'compress/decompress' }
CompressedMonoSound >> data [

	^ data

]

{ #category : #'object i/o' }
CompressedMonoSound >> fieldsVersion [

	^ 1

]

{ #category : #'object i/o' }
CompressedMonoSound >> initFieldsFrom: anObjStream version: classVersion [

	self initFieldsNamed: #(
		samplingRate
		bitsPerSample
		data 
	) from: anObjStream.

]

{ #category : #initialization }
CompressedMonoSound >> initialize [

	samplingRate := 22050.
	bitsPerSample := 4.
	data := ByteArray new.

]

{ #category : #'compress/decompress' }
CompressedMonoSound >> originalSound [

	^ originalSound

]

{ #category : #initialization }
CompressedMonoSound >> samplingRate: rate bitsPerSample: bits data: aByteArray [

	samplingRate := rate.
	bitsPerSample := bits.
	data := aByteArray.

]

{ #category : #'object i/o' }
CompressedMonoSound >> storeFieldsOn: anObjStream [

	self storeFieldsNamed: #(
		samplingRate
		bitsPerSample
		data 
	) on: anObjStream.

]

{ #category : #'compress/decompress' }
CompressedMonoSound >> uncompressed [
	"Decode my data and answer an uncompressed SampledSound."

	^ SampledSound
		samples: ((ADPCMCodec newBitsPerSample: bitsPerSample) decodeCompressedData: data)
		samplingRate: samplingRate

]
