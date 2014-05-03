"
I am a monophonic MIDI note player. I remember the midiPort, channel, volume, and currently playing note, if any. Playing a note will first turn off the note currently playing, if any.


"
Class {
	#name : #PhratchNotePlayer,
	#superclass : #Object,
	#instVars : [
		'midiPort',
		'channel',
		'volume',
		'midiKey',
		'snd'
	],
	#category : #PhratchSound
}

{ #category : #accessing }
PhratchNotePlayer >> channel [

	^ channel

]

{ #category : #accessing }
PhratchNotePlayer >> channel: aNumber [
	"Change my MIDI channel. This first turns off any notes in progress on the current channel."

	channel := aNumber rounded within: 1 and: 16.

]

{ #category : #playing }
PhratchNotePlayer >> drumOff [
	"Turn of the currently sounding drum, if any."

	midiKey ifNotNil: [
		midiPort ifNotNil: [midiPort midiCmd: 16r90 channel: 9 byte: midiKey byte: 0].
		midiKey := nil].

	snd ifNotNil: [
		snd stopGracefully.
		snd := nil].

]

{ #category : #playing }
PhratchNotePlayer >> drumOn: aNumber [
	"Play the given drum number at the current volume level. The drum number is defined by the General MIDI spec, which you can find on the web. The absolute value of the rounded drum number is used."

	| vol |
	midiKey := aNumber rounded abs within: 0 and: 127.
	midiPort
		ifNil: [
			snd := (SampledSound
					samples: SampledSound coffeeCupClink
					samplingRate: 11025) copy.
			snd
				setPitch: (AbstractSound pitchForMIDIKey: midiKey)
				dur: 1000
				loudness: ((volume / 500.0) within: 0.0 and: 1.0).
			snd play]
		ifNotNil: [
			vol := (1.27 * volume) rounded within: 0 and: 127.
			midiPort midiCmd: 16r90 channel: 9 byte: midiKey byte: vol].

]

{ #category : #initialization }
PhratchNotePlayer >> initialize [

	midiPort := nil.
	channel := 1.
	volume := 100.
	midiKey := nil.

]

{ #category : #accessing }
PhratchNotePlayer >> instrument: aNumber [
	"Set the MIDI instrument number between 1 and 128. Instrument number 1 is piano. The instrument numbers are defined by the General MIDI specification; you can find the list of instruments on the web."

	| instr |
	instr := aNumber rounded within: 1 and: 128.
	midiPort ifNotNil: [
		midiPort midiCmd: 16rC0 channel: (channel - 1) byte: (instr - 1)].

]

{ #category : #accessing }
PhratchNotePlayer >> midiPort: aMIDIPort [

	midiPort := aMIDIPort.

]

{ #category : #playing }
PhratchNotePlayer >> noteOff [
	"Turn of the currently sounding note, if any."

	midiKey ifNotNil: [
		midiPort ifNotNil: [midiPort midiCmd: 16r90 channel: (channel - 1) byte: midiKey byte: 0].
		midiKey := nil].

	snd ifNotNil: [
		snd stopGracefully.
		snd := nil].

]

{ #category : #playing }
PhratchNotePlayer >> noteOn: aNumber [
	"Play the given note at the current volume level. The note number gives the piano key number where 60 is middle-C and there are 12 keys per octave.  The absolute value of the note number is used."

	| vol |
	midiKey := aNumber rounded abs within: 0 and: 127.
	midiPort
		ifNil: [
			snd := FMSound organ1.
			snd
				setPitch: (AbstractSound pitchForMIDIKey: midiKey)
				dur: 1000
				loudness: ((volume / 100.0) within: 0.0 and: 1.0).
			snd play]
		ifNotNil: [
			vol := (1.27 * volume) rounded within: 0 and: 127.
			midiPort midiCmd: 16r90 channel: (channel - 1) byte: midiKey byte: vol].


]

{ #category : #accessing }
PhratchNotePlayer >> volume [

	^ volume

]

{ #category : #accessing }
PhratchNotePlayer >> volume: aNumber [
	"Set my volume in the range 0-100."

	volume := aNumber.

]
