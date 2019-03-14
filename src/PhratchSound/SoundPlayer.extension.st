Extension { #name : #SoundPlayer }

{ #category : #'*PhratchSound' }
SoundPlayer class >> clearPausedSounds [

	PausedSounds := OrderedCollection new
]

{ #category : #'*PhratchSound' }
SoundPlayer class >> pauseAll [
	self clearPausedSounds.
	ActiveSounds do: [:each |
		self pausedSounds add: each.
		self pauseSound: each ]
]

{ #category : #'*PhratchSound' }
SoundPlayer class >> pausedSounds [

	^ PausedSounds ifNil: [OrderedCollection new]
]

{ #category : #'*PhratchSound' }
SoundPlayer class >> resumeAll [

	ActiveSounds addAll: self pausedSounds.
	ActiveSounds do: [:each | 
		self resumePlaying: each quickStart: true ]
]
