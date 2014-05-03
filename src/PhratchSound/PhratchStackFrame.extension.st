Extension { #name : #PhratchStackFrame }

{ #category : #'*PhratchSound' }
PhratchStackFrame >> stopMIDI [

	(self startValue isKindOf: PhratchNotePlayer)
		ifTrue: [startValue noteOff].

]
