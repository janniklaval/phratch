Extension { #name : #PhratchStageMorph }

{ #category : #'*PhratchSound' }
PhratchStageMorph >> stopAll [
	"Stop all processes and make sure I am stepping."

	| sFrame |
	World hands do: [:h | h newKeyboardFocus: nil; clearUnclaimedKeystrokes].
	Sensor clearKeystate.
	SoundPlayer stopPlayingAll.
	self class stopSoundRecorder.
	self stopAllProcesses.
	self stopAsks.
	self deleteAllClones.
	self midiAllNotesOff.
	self stopPlaying.
	self stopAllSounds.
	self allMorphsDo: [:m |
		(m isScriptablePhratchMorph) ifTrue: [m stopPlaying]].

	DebuggerFrameMorph allInstancesDo: [:df | df delete ].

	(sFrame := self ownerOrYourselfThatIsAPhratchFrameMorph) ifNotNil: [
		sFrame scriptsPane allMorphsDo: [:m |
			(m respondsTo: #stop) ifTrue: [m stop].
			(m respondsTo: #litUp:) ifTrue: [m litUp: false]].
		World startSteppingSubmorphsOf: sFrame].

	World startSteppingSubmorphsOf: self. 

]

{ #category : #'*PhratchSound' }
PhratchStageMorph >> tempo [

	^ tempoBPM

]
