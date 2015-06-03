"
* An interface to LibMPEG3
 * Author: Adam Williams <broadcast@earthling.net>
 * Page: heroine.linuxbox.com
 *
 * Modified to work with Squeak and on the Macintosh in Sept 2000
 * by John M McIntosh johnmci@smalltalkconsulting.com
 * The smalltalk code and the C code it produces is released under the 
 * Squeak licence. The libmpeg3 C code is co-licenced under either the Squeak
 * licence or the GNU LGPL by permission of Adam Williams.

"
Class {
	#name : #MPEGFile,
	#superclass : #Object,
	#instVars : [
		'pathToFile',
		'fileBits',
		'fileIndex'
	],
	#classVars : [
		'Registry'
	],
	#category : #PhratchSound
}

{ #category : #testing }
MPEGFile class >> isFileValidMPEG: path [
	"Answer true if this file is in an MPEG format I can read."

	<primitive: 'primitiveMPEG3CheckSig' module: 'Mpeg3Plugin'>
	self primitiveFailed

]

{ #category : #'instance creation' }
MPEGFile class >> openFile: aPath [
	^self new initialize openFile: aPath.
]

{ #category : #registry }
MPEGFile class >> register: anObject [
	self registry add: anObject
]

{ #category : #registry }
MPEGFile class >> registry [
	^Registry isNil
		ifTrue:[Registry := WeakRegistry new]
		ifFalse:[Registry].
]

{ #category : #registry }
MPEGFile class >> unregister: anObject [
	self registry remove: anObject ifAbsent:[]
]

{ #category : #audio }
MPEGFile >> audioChannels: aStream [
	"Returns -1 if error, otherwise returns audioChannels for stream aStream"
	self hasAudio ifFalse: [^ 0].
	^[self primAudioChannels: self fileHandle stream: aStream] ifError: [-1]

]

{ #category : #access }
MPEGFile >> audioGetSample: aStream [
	"Returns number of current sample, or -1 if error"
	self hasAudio ifFalse: [^-1].
	^[(self primGetSample: self fileHandle stream: aStream) asInteger] ifError: [-1]

]

{ #category : #audio }
MPEGFile >> audioReReadBuffer: aBuffer stream: aStreamNumber channel: aChannelNumber [
	"Used to read other channels after first ReadBuffer 
	Returns -1 if error, otherwise 0"
	self hasAudio ifFalse: [^-1].
	^[self audioReReadBuffer: aBuffer stream: aStreamNumber channel: aChannelNumber samples: (aBuffer size * aBuffer bytesPerElement // 2)] ifError: [-1]
]

{ #category : #audio }
MPEGFile >> audioReReadBuffer: aBuffer stream: aStreamNumber channel: aChannelNumber samples: aSampleNumber [
	"Used to read other channels after first ReadBuffer 
	Returns -1 if error, otherwise 0
	Note this call requires passing in the samples to read, ensure you get the number right"
	self hasAudio ifFalse: [^-1].
	^[self primAudioReReadBuffer: self fileHandle  buffer: aBuffer channel: aChannelNumber samples: aSampleNumber stream: aStreamNumber] ifError: [-1]
]

{ #category : #audio }
MPEGFile >> audioReadBuffer: aBuffer stream: aStreamNumber channel: aChannelNumber [ 
	"Returns -1 if error, otherwise 0"
	self hasAudio ifFalse: [^-1].
	^[self audioReadBuffer: aBuffer stream: aStreamNumber channel: aChannelNumber samples: (aBuffer size* aBuffer bytesPerElement)//2] ifError: [-1]
]

{ #category : #audio }
MPEGFile >> audioReadBuffer: aBuffer stream: aStreamNumber channel: aChannelNumber samples: aSampleNumber [
	"Returns -1 if error, otherwise 0
	Note this call requires passing in the samples to read, ensure you get the number right"
	self hasAudio ifFalse: [^-1].
	^[self primAudioReadBuffer: self fileHandle  buffer: aBuffer channel: aChannelNumber samples: aSampleNumber stream: aStreamNumber] ifError: [-1]
]

{ #category : #audio }
MPEGFile >> audioSampleRate: aStream [
	"Returns sample rate, or -1 if error"
	self hasAudio ifFalse: [^-1].
	^[self primSampleRate: self fileHandle stream: aStream] ifError: [-1]

]

{ #category : #audio }
MPEGFile >> audioSamples: aStream [
	"Returns -1 if error, 
	otherwise returns audioSamples for stream aStream"
	self hasAudio ifFalse: [^-1].
	^[(self primAudioSamples: self fileHandle stream: aStream) asInteger] ifError: [-1]

]

{ #category : #audio }
MPEGFile >> audioSetSample: aNumber stream: aStream [
	"Set number of targeted sample, returns 0 if ok, -1 if failure"
	self hasAudio ifFalse: [^-1].
	^[self primSetSample: self fileHandle sample: aNumber asFloat stream: aStream] ifError: [-1]

]

{ #category : #'file ops' }
MPEGFile >> closeFile [

	
	self fileHandle notNil ifTrue: [self primFileClose: self fileHandle].
	self fileHandle = fileBits ifTrue: [Smalltalk unregisterExternalObject: fileIndex].
	fileBits := nil.	
	fileIndex := 0.

]

{ #category : #access }
MPEGFile >> duration: streamIndex [
	"Answer my duration in seconds. If I have audio, this is the duration of my audio track. Otherwise, it computed from my frame count and frame rate."

	self hasAudio
		ifTrue: [^ (self audioSamples: streamIndex) asFloat / (self audioSampleRate: streamIndex)]
		ifFalse: [^ (self videoFrames: streamIndex) asFloat / (self videoFrameRate: streamIndex)].

]

{ #category : #access }
MPEGFile >> fileHandle [
	(Smalltalk externalObjects at: fileIndex ifAbsent: [^nil]) == fileBits 
		ifTrue: [^fileBits]
		ifFalse: [^nil].

]

{ #category : #access }
MPEGFile >> fileName [
	^pathToFile
]

{ #category : #'initialize-release' }
MPEGFile >> finalize [

	self closeFile.

]

{ #category : #audio }
MPEGFile >> hasAudio [
	"Returns true if file has audio"
	^self primHasAudio: self fileHandle 
]

{ #category : #video }
MPEGFile >> hasVideo [
	"Returns true if file has video"
	^self primHasVideo: self fileHandle 
]

{ #category : #'initialize-release' }
MPEGFile >> initialize [

	pathToFile := fileBits := fileIndex := nil.

]

{ #category : #access }
MPEGFile >> jumpToSeconds: seconds stream: streamIndex [
	"Set the position of the stream with the given index to the given number of seconds since the start."

	| index |
	seconds < 0 ifTrue: [^ self jumpToSeconds: 0 stream: streamIndex].
	self hasAudio
		ifTrue: [
			index := (seconds * (self audioSampleRate: streamIndex)) truncated.
			index := (index max: 0) min: (self audioSamples: streamIndex) - 1.
			self audioSetSample: index stream: streamIndex]
		ifFalse: [
			index := (seconds * (self videoFrameRate: streamIndex)) truncated.
			index := (index max: 0) min: (self videoFrames: streamIndex) - 1.
			self videoSetFrame: index stream: streamIndex].

]

{ #category : #'file ops' }
MPEGFile >> openFile: aPath [
	pathToFile := aPath.
	fileBits := self primFileOpen: aPath.
	fileBits notNil
		ifFalse: [ ^ self ].
	fileIndex := Smalltalk registerExternalObject: fileBits.
	self class register: self
]

{ #category : #primitives }
MPEGFile >> primAudioChannels: aHandle stream: aStream [
	<primitive: 'primitiveMPEG3AudioChannels' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primAudioReReadBuffer: aFileHandle  buffer: aBuffer channel: aChannel samples: aSampleNumber stream: aStreamNumber [
	<primitive: 'primitiveMPEG3ReReadAudio' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primAudioReadBuffer: aFileHandle  buffer: aBuffer channel: aChannel samples: aSampleNumber stream: aStreamNumber [
	<primitive: 'primitiveMPEG3ReadAudio' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primAudioSamples: aHandle stream: aStream [
	<primitive: 'primitiveMPEG3AudioSamples' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primDropFrame: aHandle frame: aNumberOfFrames stream: aStream [
	<primitive: 'primitiveMPEG3DropFrames' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primEndOfAudio: aHandle stream: aStream [
	<primitive: 'primitiveMPEG3EndOfAudio' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primEndOfVideo: aHandle stream: aStream [
	<primitive: 'primitiveMPEG3EndOfVideo' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primFileClose: aHandle [
	"Close the file"
	<primitive: 'primitiveMPEG3Close' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primFileOpen: aPath [
	"Open the file"
	<primitive: 'primitiveMPEG3Open' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primFrameRate: aHandle stream: aStream [
	<primitive: 'primitiveMPEG3FrameRate' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primGenerateToc: fileHandle useSearch: timecode doStreams: streams buffer: aString [
	<primitive: 'primitiveMPEG3GenerateToc' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primGetFrame: aHandle stream: aStream [
	<primitive: 'primitiveMPEG3GetFrame' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primGetPercentage: aHandle [
	<primitive: 'primitiveMPEG3TellPercentage' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primGetSample: aHandle stream: aStream [
	<primitive: 'primitiveMPEG3GetSample' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primGetTime: aFileHandle [
	<primitive: 'primitiveMPEG3GetTime' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primHasAudio: aHandle [
	<primitive: 'primitiveMPEG3HasAudio' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primHasVideo: aHandle [
	<primitive: 'primitiveMPEG3HasVideo' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primPreviousFrame: aHandle stream: aStream [
	<primitive: 'primitiveMPEG3PreviousFrame' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primSampleRate: aHandle stream: aStream [
	<primitive: 'primitiveMPEG3SampleRate' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primSeekPercentage: aHandle percentage: aNumber [
	<primitive: 'primitiveMPEG3SeekPercentage' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primSetCPUs: aHandle number: aNumber [
	"Not support on the macintosh below OS X"
	<primitive: 'primitiveMPEG3SetCpus' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primSetFrame: aHandle frame: aFrameNumber stream: aStream [
	<primitive: 'primitiveMPEG3SetFrame' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primSetMMX: aFileHandle useMMX: aValue [  
	<primitive: 'primitiveMPEG3SetMmx' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primSetSample: aHandle sample: aSampleNumber stream: aStream [
	<primitive: 'primitiveMPEG3SetSample' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primTotalAudioStreams: aFileHandle [ 
	<primitive: 'primitiveMPEG3TotalAStreams' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primTotalVideoStreams: aFileHandle [ 
	<primitive: 'primitiveMPEG3TotalVStreams' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primVideoFrames: aFileHandle  stream: aStream [
	<primitive: 'primitiveMPEG3VideoFrames' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primVideoHeight: aFileHandle  stream: aStream [
	<primitive: 'primitiveMPEG3VideoHeight' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #primitives }
MPEGFile >> primVideoReadNextFrameFor: aFileHandle into: aFormBuffer x: x y: y width: width height: height outWidth: aTargetWidth outHeight: aTargetHeight colorModel: colorModel stream: aStream bytesPerRow: aByteCount [
	<primitive: 'primitiveMPEG3ReadFrame' module: 'Mpeg3Plugin'>


]

{ #category : #primitives }
MPEGFile >> primVideoWidth: aFileHandle  stream: aStream [
	<primitive: 'primitiveMPEG3VideoWidth' module: 'Mpeg3Plugin'>
	self primitiveFailed
]

{ #category : #video }
MPEGFile >> videoFrameRate: aStream [
	"Returns video frame rate (float), -1 if error"
	self hasVideo ifFalse: [^-1].
	^[self primFrameRate: self fileHandle stream: aStream] ifError: [-1]

]

{ #category : #video }
MPEGFile >> videoFrames: aStream [
	"Total number of frames" 
	^(self primVideoFrames: self fileHandle stream: aStream) asInteger

]

{ #category : #video }
MPEGFile >> videoSetFrame: aFrameNumber stream: aStream [
	"Returns -1 if setFrame failed"
	self hasVideo ifFalse: [^-1].
	^[self primSetFrame: self fileHandle frame: aFrameNumber asFloat stream: aStream] ifError: [-1]

]
