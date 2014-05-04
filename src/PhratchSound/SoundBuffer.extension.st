Extension { #name : #SoundBuffer }

{ #category : #'*PhratchSound' }
SoundBuffer >> mixIn: aSoundBuffer [
	"Answer mix the contents of the given SoundBuffers with the receiver. The receiver is modified."

	| n |
	n :=  self monoSampleCount min: aSoundBuffer monoSampleCount.
	1 to: n do: [:i | self at: i put: ((self at: i) + (aSoundBuffer at: i)) // 2].


]
