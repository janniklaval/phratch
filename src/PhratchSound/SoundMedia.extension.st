Extension { #name : #SoundMedia }

{ #category : #'*PhratchSound' }
SoundMedia >> playFromStart [
	"Play my sound from beginning to end."

	self playFrom: 0 to: self totalSeconds.

]
