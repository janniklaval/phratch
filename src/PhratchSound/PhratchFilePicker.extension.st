Extension { #name : #PhratchFilePicker }

{ #category : #'*PhratchSound' }
PhratchFilePicker >> startPlayingSound: fullName [
	"Attempt to play the sound with given name."

	self stopPlayingSound.
	sound := (fullName asLowercase endsWith: '.mp3')
		ifTrue: [ [ StreamingMP3Sound onFileNamed: fullName ] ifError: [ nil ] ]
		ifFalse: [ [ SampledSound fromFileNamed: fullName ] ifError: [ nil ] ].
	sound
		ifNotNil: [ 
			(sound respondsTo: #volume:)
				ifTrue: [ sound volume: 1.0 ].
			sound play ]
]
