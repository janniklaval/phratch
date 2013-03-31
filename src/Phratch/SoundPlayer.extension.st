Extension { #name : #SoundPlayer }

{ #category : #'*Phratch-Compatibility' }
SoundPlayer classSide >> clearPausedSounds [

	PausedSounds := OrderedCollection new
]

{ #category : #'*Phratch-Compatibility' }
SoundPlayer classSide >> pauseAll [
	self clearPausedSounds.
	ActiveSounds do: [:each |
		self pausedSounds add: each.
		self pauseSound: each ]
]

{ #category : #'*Phratch-Compatibility' }
SoundPlayer classSide >> pausedSounds [

	^ PausedSounds ifNil: [OrderedCollection new]
]

{ #category : #'*Phratch-Compatibility' }
SoundPlayer classSide >> resumeAll [

	ActiveSounds addAll: self pausedSounds.
	ActiveSounds do: [:each | 
		self resumePlaying: each quickStart: true ]
]
