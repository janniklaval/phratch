Extension { #name : #GraphMorph }

{ #category : #'*PhratchSound' }
GraphMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'open wave editor' translated action: #openWaveEditor.
	aCustomMenu add: 'read file' translated action: #readDataFromFile.

]

{ #category : #'*PhratchSound' }
GraphMorph >> openWaveEditor [

	| scaleFactor scaledData editor |
	self data: data.  "make sure maxVal and minVal are current"
	scaleFactor := 32767 // ((minVal abs max: maxVal abs) max: 1).
	scaledData := SoundBuffer newMonoSampleCount: data size.
	1 to: data size do: [:i | scaledData at: i put: (scaleFactor * (data at: i)) truncated].
	editor := WaveEditor new
		data: scaledData;
		samplingRate: 11025;
		perceivedFrequency: 220.0;
		yourself.
	editor openInWorld.

]

{ #category : #'*PhratchSound' }
GraphMorph >> readDataFromFile [

	| fileName |
	fileName := UIManager default
		request: 'File name?' translated
		initialAnswer: ''.
	fileName isEmpty ifTrue: [^ self].
	(StandardFileStream isAFileNamed: fileName) ifFalse: [
		^ self inform: 'Sorry, I cannot find that file' translated].
	self data: (SampledSound fromAIFFfileNamed: fileName) samples.


]
