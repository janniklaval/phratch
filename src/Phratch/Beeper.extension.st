Extension { #name : #Beeper }

{ #category : #'*Phratch' }
Beeper >> play [
	"This is how the default Beeper makes a beep,
	by sending beep to the default sound service.
	The sound system will check if sounds are enabled."

	Smalltalk globals at: #SoundService ifPresent: [:soundService |
		soundService default beep]
]