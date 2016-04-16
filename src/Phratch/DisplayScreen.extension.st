Extension { #name : #DisplayScreen }

{ #category : #'*Phratch-Extensions' }
DisplayScreen >> fullScreenMode: aBoolean [
	"On platforms that support it, set full-screen mode to the value of the argument. (Note: you'll need to restore the Display after calling this primitive."
	"Display fullScreenMode: true. Display newDepth: Display depth"

	<primitive: 233>
	self primitiveFailed

]
