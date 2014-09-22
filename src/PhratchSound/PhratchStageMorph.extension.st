Extension { #name : #PhratchStageMorph }

{ #category : #'*PhratchSound' }
PhratchStageMorph >> closeMIDI [
	"Close the MIDI port and clear the note player dictionary."

	midiPort ifNotNil: [
		midiPort close.
		midiPort := nil].
	notePlayerDict := Dictionary new.

]

{ #category : #'*PhratchSound' }
PhratchStageMorph >> midiAllNotesOff [
	"If the MIDI port is open, send an 'all notes off' command on every channel."

	midiPort ifNil: [^ self].
	midiPort ensureOpenIfFail: [self closeMIDI].
	notePlayerDict do: [:player | player noteOff].

]

{ #category : #'*PhratchSound' }
PhratchStageMorph >> midiPortNum [

	^ midiPortNum

]

{ #category : #'*PhratchSound' }
PhratchStageMorph >> midiPortNum: anInteger [

	midiPortNum := anInteger.


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
PhratchStageMorph >> openMIDI [
	"Prompt the user to select a MIDI port number, then open it."

	| possiblePorts dir menu |
	self closeMIDI.
	possiblePorts := (0 to: SimpleMIDIPort primPortCount - 1)
		select: [ :i | 
			dir := SimpleMIDIPort primPortDirectionalityOf: i.
			{2 . 3} includes: dir ].	"out or in/out port"
	possiblePorts size = 0
		ifTrue: [ ^ self inform: 'No MIDI ports currently available.' ].
	menu := MenuMorph new
		defaultTarget: self;
		title: 'MIDI port:' localized;
		yourself.
	possiblePorts
		do: [ :i | 
			menu
				add: (SimpleMIDIPort portDescription: i)
				target: self
				selector: #midiPortNum:
				argument: i ].
	menu popUpInWorld.
	self tryToOpenMidiPort
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

{ #category : #'*PhratchSound' }
PhratchStageMorph >> tryToOpenMidiPort [
	"Attempt to open the MIDI port. First try the port selected by the user, if any. If that port number is not a MIDI output port, try to find another port number. If all measures fail, leave midiPort set to nil."

	| possiblePorts dir portNum |
	Smalltalk os isUnix
		ifTrue: [ 
			midiPort := nil.
			^ self ].
	possiblePorts := (0 to: SimpleMIDIPort primPortCount - 1)
		select: [ :i | 
			dir := SimpleMIDIPort primPortDirectionalityOf: i.
			{2 . 3} includes: dir ].	"out or in/out port"
	possiblePorts size = 0
		ifTrue: [ 
			midiPort := nil.
			^ self ].	"no midi ports"
	portNum := (possiblePorts includes: midiPortNum)
		ifTrue: [ midiPortNum ]
		ifFalse: [ possiblePorts first ].	"use the port requested by the user"	"use the first available port"
	[ 
	midiPort := SimpleMIDIPort openOnPortNumber: portNum.
	midiPort ensureOpen ] ifError: [ midiPort := nil ]
]
