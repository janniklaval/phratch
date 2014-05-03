Extension { #name : #ScriptablePhratchMorph }

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> changeTempoBy: aNumber [
	"Change the tempo by the given value."
	<phratchItem: 'change tempo by $Number$' kind: #- category: 'sound' defaultValues: #(20) subCategory: #a5 special: #()>
	self setTempoTo: self tempo + aNumber.

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> changeVolumeBy: aNumber [
	"Change the volume by the given value."
	<phratchItem: 'change volume by $Number$' kind: #- category: 'sound' defaultValues: #(-10) subCategory: #a4 special: #()>
	self setVolumeTo: volume + aNumber.

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> drum: midiKey duration: beats elapsed: elapsedMSecs from: aNotePlayer [
	"play drum with the given parameters"
	<phratchItem: 'play drum $Drums$ for $Number$ beats' kind: #TimeBlockMorph category: 'sound' defaultValues: #(48 0.2) subCategory: #a2 special: #()>
	| stage player |
	aNotePlayer ifNil: [  "first call, start playing the drum"
		(stage := self ownerOrYourselfThatIsAPhratchStageMorph) ifNil: [^ PhratchNotePlayer new].
		(player := stage notePlayerFor: self) ifNil: [^ PhratchNotePlayer new].
		^ [player copy drumOn: midiKey] on: Error do:[stage stopAllSounds. player copy drumOn: midiKey ]].

	elapsedMSecs >= ((60000 * beats) // self tempo) ifTrue: [aNotePlayer drumOff].

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> midiInstrument: aNumber [
	"Set the MIDI instrument used for note sounds."
	<phratchItem: 'set instrument to $Instruments$' kind: #- category: 'sound' defaultValues: #(1) subCategory: #a3 special: #()>
	| stage player |
	(stage := self ownerOrYourselfThatIsAPhratchStageMorph) ifNil: [^ self].
	(player := stage notePlayerFor: self) ifNotNil: [
		[player instrument: aNumber] on: Error do:[stage stopAllSounds. player instrument: aNumber ]  ].

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> noteOn: midiKey duration: beats elapsed: elapsedMSecs from: aNotePlayer [
	"Play the given note"
	<phratchItem: 'play note $Notes$ for $Number$ beats' kind: #TimeBlockMorph category: 'sound' defaultValues: #(60 0.5) subCategory: #a3 special: #()>
	| stage player |
	aNotePlayer ifNil: [  "first call, start playing the note"
		(stage := self ownerOrYourselfThatIsAPhratchStageMorph) ifNil: [^ PhratchNotePlayer new].
		(player := stage notePlayerFor: self) ifNil: [^ PhratchNotePlayer new].
		^ [player noteOn: midiKey] on: Error do:[stage stopAllSounds. player noteOn: midiKey ] ].

	elapsedMSecs >= ((60000 * beats) // self tempo) ifTrue: [aNotePlayer noteOff].

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> noteSelector [
	"Returns an instance of a NoteSelector for selecting notes. This object behaves like a CustomMenu."

	| stageMorph notePlayer |
	stageMorph := (self ownerOrYourselfThatIsAPhratchStageMorph).
	stageMorph ifNil: [^ self midiNoteMenu].
	notePlayer := stageMorph notePlayerFor: self.
	notePlayer ifNil: [^ self midiNoteMenu].

	^ (PhratchNoteSelector new setNotePlayer: notePlayer)

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> rest: duration elapsed: elapsed from: ignored [
	"Do nothing; just wait for the time interval to elapse."
	<phratchItem: 'rest for $Number$ beats' kind: #TimeBlockMorph category: 'sound' defaultValues: #(0.2) subCategory: #a2 special: #()>
	^ nil

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> tempo [
	"Return the tempo"
	<phratchItem: 'tempo' kind: #ReporterWatcherBlockMorph category: 'sound' defaultValues: #() subCategory: #a5 special: #()>
	| stage |
	(stage := self ownerOrYourselfThatIsAPhratchStageMorph) ifNil: [^ 60].
	^ stage tempo

]
