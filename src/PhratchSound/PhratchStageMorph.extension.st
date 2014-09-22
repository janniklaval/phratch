Extension { #name : #PhratchStageMorph }

{ #category : #'*PhratchSound' }
PhratchStageMorph >> notePlayerFor: aPhratchObject [
	"Answer a note player for the given object, creating one if necessary. Open the MIDI port if necessary."

	| deletedMorphs channelUsage ch newCh newPlayer |
	midiPort ifNil: [self tryToOpenMidiPort].

	(notePlayerDict includesKey: aPhratchObject) ifTrue: [
		^ notePlayerDict at: aPhratchObject].

	"remove deleted morphs from the note player dictionary"
	deletedMorphs := notePlayerDict keys select: [:m | m owner isNil].
	deletedMorphs do: [:m | notePlayerDict removeKey: m].

	"find the channel used by the fewest objects"
	channelUsage := Array new: 16 withAll: 0.
	channelUsage at: 10 put: 1000000.  "make sure channel 10 (drums) is not chosen"
	notePlayerDict do: [:player |
		ch := player channel.
		channelUsage at: ch put: (channelUsage at: ch) + 1].
	newCh := channelUsage indexOf: channelUsage min.

	newPlayer := PhratchNotePlayer new
		channel: newCh;
		midiPort: midiPort;
		instrument: 1;
		yourself.
	notePlayerDict at: aPhratchObject put: newPlayer.

	^ newPlayer

]

{ #category : #'*PhratchSound' }
PhratchStageMorph >> setTempoTo: aNumber [

	tempoBPM := (aNumber asNumberNoError within: 20 and: 500).

]

{ #category : #'*PhratchSound' }
PhratchStageMorph >> stopAllSounds [
	"Stop all sounds and MIDI notes/drums."

	SoundPlayer shutDown.
	self midiAllNotesOff.


]

{ #category : #'*PhratchSound' }
PhratchStageMorph >> tempo [

	^ tempoBPM

]
