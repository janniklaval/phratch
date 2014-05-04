Extension { #name : #MPEGFile }

{ #category : #'*PhratchSound' }
MPEGFile >> audioGetSample: aStream [
	"Returns number of current sample, or -1 if error"
	self hasAudio ifFalse: [^-1].
	^[(self primGetSample: self fileHandle stream: aStream) asInteger] ifError: [-1]

]
