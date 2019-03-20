Extension { #name : #WorldMorph }

{ #category : #'*Phratch-Extensions' }
WorldMorph >> abandonAllHalos [
	self haloMorphs do: [:m | m delete]
]

{ #category : #'*Phratch-Extensions' }
WorldMorph >> cycleWhileWaitingMSecs: waitMSecs doInput: doInputFlag doSteps: doStepFlag [
	"Perform the interactive loop repeatedly for the given number of milliseconds."

	| startT now |
	startT := Time millisecondClockValue.
	[((now := Time millisecondClockValue) < startT) or:
	 [(now - startT) < waitMSecs]] whileTrue: [
		doInputFlag ifTrue: [
			"process user input events"
			self handsDo: [:h |
				"self activeHand: h."
				h processEvents]].

		doStepFlag ifTrue: [self runStepMethods].
		self displayWorldSafely].
]

{ #category : #'*Phratch-Extensions' }
WorldMorph >> doOneCycleNoInput [
	"Do one cycle of the display and step loop without user input."

	self runStepMethods.
	self displayWorldSafely.

]
