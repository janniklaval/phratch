Extension { #name : #SoundPlayer }

{ #category : #'*PhratchSound' }
SoundPlayer classSide >> clearPausedSounds [

	PausedSounds := OrderedCollection new
]

{ #category : #'*PhratchSound' }
SoundPlayer classSide >> pauseAll [
	self clearPausedSounds.
	ActiveSounds do: [:each |
		self pausedSounds add: each.
		self pauseSound: each ]
]

{ #category : #'*PhratchSound' }
SoundPlayer classSide >> pausedSounds [

	^ PausedSounds ifNil: [OrderedCollection new]
]

{ #category : #'*PhratchSound' }
SoundPlayer classSide >> resumeAll [

	ActiveSounds addAll: self pausedSounds.
	ActiveSounds do: [:each | 
		self resumePlaying: each quickStart: true ]
]
