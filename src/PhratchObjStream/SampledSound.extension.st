Extension { #name : #SampledSound }

{ #category : #'*PhratchObjStream' }
SampledSound >> fieldsVersion [

	^ 2

]

{ #category : #'*PhratchObjStream' }
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

{ #category : #'*PhratchObjStream' }
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
