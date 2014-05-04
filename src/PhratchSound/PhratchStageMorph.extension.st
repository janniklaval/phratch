Extension { #name : #PhratchStageMorph }

{ #category : #'*PhratchSound' }
PhratchStageMorph >> attribute: attr [
	"Answer the value of my variable or built-in attribute with the given name. Answer zero if I have no attribute or variable with the given name."

	| a |
	
	(attr isCommandBlockMorph)
		ifTrue: [^ attr fullCopy newScriptOwner: self; yourself] 		"self blockLike: attr body]".

	a := attr asString.
	(vars includesKey: a) ifTrue: [^ vars at: a].
	(self allLocalBlockIds includes: a) ifTrue: [ ^self lambda: a ].

	a := a localized.
	'background #' localized = a ifTrue: [^ self backgroundIndex].
	'costume #' localized = a ifTrue: [^ self backgroundIndex].
	'volume' localized = a ifTrue: [^ self volume].
	^ 0

]

{ #category : #'*PhratchSound' }
PhratchStageMorph >> initialize [

	super initialize.
	color := Color white.
	self enableDragNDrop: true.
	objName := 'Stage' localized.
	costume := self defaultImageMedia.
	media := OrderedCollection with: costume with: SoundMedia new.
	hPan := 0.
	vPan := 0.
	runningBlocks := OrderedCollection new.
	inProcessStep := false.
	midiPortNum := -1.
	notePlayerDict := Dictionary new.
	sprites := OrderedCollection new.

]

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
PhratchStageMorph >> stopAllSounds [
	"Stop all sounds and MIDI notes/drums."

	SoundPlayer shutDown.
	self midiAllNotesOff.


]

{ #category : #'*PhratchSound' }
PhratchStageMorph >> tempo [

	^ tempoBPM

]
