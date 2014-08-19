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
ScriptablePhratchMorph >> doPlaySoundAndWait [
	"Play the given sound and wait it finishes"
	<phratchItem: 'play sound $SoundNames$ until done' kind: #SpecialBlockMorph category: 'sound' defaultValues: #() subCategory: #a1 special: #()>
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
ScriptablePhratchMorph >> importMedia: fileName [
	"Import a new image from a file and add it to my media."

	|  extensionLoc elList baseName fList isFirst |
	extensionLoc := ( fileName) extension asLowercase.

	elList := OrderedCollection new.

	(#(aif aiff wav mp3) includes: extensionLoc) ifTrue: [
		baseName := self mediaNameFromFileName: fileName default: 'sound'.
		[elList addLast: (SoundMedia new loadFile: fileName)] ifError: [^ self]].

	(#(jpg jpeg gif bmp png) includes: extensionLoc) ifTrue: [
		baseName := self
			mediaNameFromFileName: fileName
			default: self defaultImageMedia mediaName.
		fList := OrderedCollection new.
		"extensionLoc = 'gif' 
			ifTrue: 
				[[fList := (GIFReadWriter new on: (FileStream oldFileNamed: fileName)) nextImageSet] ifError: [^ self]]
			ifFalse: 
				["[fList addLast: (Form fromFileNamed: fileName)] ifError: [^ self]"]".
		fList do: [:f | 
			elList addLast: (ImageMedia new form: (PhratchFrameMorph scaledFormForPaintEditor: f))]].

	elList isEmpty ifTrue: [^ self].  "unknown file type; ignore"

	isFirst := true.
	elList do: [:el | 
		el mediaName: (self unusedMediaNameFromBaseName: baseName).
		media addLast: el.
		isFirst ifTrue: [
			isFirst := false. 
			el isSound 
				ifTrue: [
					self undeleteAttribute: #sounds.
					self propagateSounds
					]
				ifFalse: [
					self lookLike: el mediaName.
					self undeleteAttribute: #costumes.
					self propagateCostumes]]].
	
	self updateMediaCategory.

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> importSound [
	"Import a new sound from a file and add it to my media."

	| result el newName |
	result := PhratchFileChooserDialog
		chooseExistingFileType: #sound
		extensions: #(aif aiff au wav mp3)
		title: 'Import Sound'.

	result = #cancelled ifTrue: [^ self].

	el := [SoundMedia new loadFile: result]
		ifError: [:err :rcvr |
			PhratchError errorWithDialog: err.
			nil].
	el ifNil: [^ self].

	newName := self mediaNameFromFileName: result default: 'sound'.
	el mediaName: (String withAll: (self unusedMediaNameFromBaseName: newName)).
	media addLast: el.
	self updateMediaCategory.

	self undeleteAttribute: #sounds.
	self propagateSounds
]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> isLoud [
	"Return true if the sound is playing"
	<phratchItem: 'loud?' kind: #BooleanWatcherBlockMorph category: 'sensing' defaultValues: #() subCategory: #a4 special: #()>
	^ self class soundRecorder meterLevel > 30

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> midiDrumMenu [
	"Provides a drop-down menu for setting the drum number."

	| menu |
	menu := MenuMorph new defaultTarget: self.
	#(	('Acoustic Bass Drum' 35)
		('Bass Drum 1' 36)
		('Side Stick' 37)
		('Acoustic Snare' 38)
		('Hand Clap' 39)
		('Electric Snare' 40)
		('Low Floor Tom' 41)
		('Closed Hi-Hat' 42)
		('High Floor Tom' 43)
		('Pedal Hi-Hat' 44)
		('Low Tom' 45)
		('Open Hi-Hat' 46)
		('Low-Mid Tom' 47)
		('Hi-Mid Tom' 48)
		('Crash Cymbal 1' 49)
		('High Tom' 50)
		('Ride Cymbal 1' 51)
		('Chinese Cymbal' 52)
		('Ride Bell' 53)
		('Tambourine' 54)
		('Splash Cymbal' 55)
		('Cowbell' 56)
		('Crash Cymbal 2' 57)
		('Vibraslap' 58)
		('Ride Cymbal 2' 59)
		('Hi Bongo' 60)
		('Low Bongo' 61)
		('Mute Hi Conga' 62)
		('Open Hi Conga' 63)
		('Low Conga' 64)
		('High Timbale' 65)
		('Low Timbale' 66)
		('High Agogo' 67)
		('Low Agogo' 68)
		('Cabasa' 69)
		('Maracas' 70)
		('Short Whistle' 71)
		('Long Whistle' 72)
		('Short Guiro' 73)
		('Long Guiro' 74)
		('Claves' 75)
		('Hi Wood Block' 76)
		('Low Wood Block' 77)
		('Mute Cuica' 78)
		('Open Cuica' 79)
		('Mute Triangle' 80)
		('Open Triangle' 81)
	) do: [:pair |
		menu
			add: (self numberInParens: pair second), (pair first localizedMIDI)
			value: pair second].
	menu invokeModal.
	^ menu 

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
ScriptablePhratchMorph >> midiInstrumentMenu [
	"Provides a drop-down menu for setting the instrument number."

	| menu |
	menu := MenuMorph  new.
	#(	('Acoustic Grand' 1)
		('Bright Acoustic' 2)
		('Electric Grand' 3)
		('Honky-Tonk' 4)
		('Electric Piano 1' 5)
		('Electric Piano 2' 6)
		('Harpsichord' 7)
		('Clavinet' 8)
		('Celesta' 9)
		('Glockenspiel' 10)
		('Music Box' 11)
		('Vibraphone' 12)
		('Marimba' 13)
		('Xylophone' 14)
		('Tubular Bells' 15)
		('Dulcimer' 16)
		('Drawbar Organ' 17)
		('Percussive Organ' 18)
		('Rock Organ' 19)
		('Church Organ' 20)
		('Reed Organ' 21)
		('Accordion' 22)
		('Harmonica' 23)
		('Tango Accordion' 24)
		('Nylon String Guitar' 25)
		('Steel String Guitar' 26)
		('Electric Jazz Guitar' 27)
		('Electric Clean Guitar' 28)
		('Electric Muted Guitar' 29)
		('Overdriven Guitar' 30)
		('Distortion Guitar' 31)
		('Guitar Harmonics' 32)
		('Acoustic Bass' 33)
		('Electric Bass (finger)' 34)
		('Electric Bass (pick)' 35)
		('Fretless Bass' 36)
		('Slap Bass 1' 37)
		('Slap Bass 2' 38)
		('Synth Bass 1' 39)
		('Synth Bass 2' 40)
		('Violin' 41)
		('Viola' 42)
		('Cello' 43)
		('Contrabass' 44)
		('Tremolo Strings' 45)
		('Pizzicato Strings' 46)
		('Orchestral Strings' 47)
		('Timpani' 48)
		('String Ensemble 1' 49)
		('String Ensemble 2' 50)
		('SynthStrings 1' 51)
		('SynthStrings 2' 52)
		('Choir Aahs' 53)
		('Voice Oohs' 54)
		('Synth Voice' 55)
		('Orchestra Hit' 56)
		('Trumpet' 57)
		('Trombone' 58)
		('Tuba' 59)
		('Muted Trumpet' 60)
		('French Horn' 61)
		('Brass Section' 62)
		('SynthBrass 1' 63)
		('SynthBrass 2' 64)
		('Soprano Sax' 65)
		('Alto Sax' 66)
		('Tenor Sax' 67)
		('Baritone Sax' 68)
		('Oboe' 69)
		('English Horn' 70)
		('Bassoon' 71)
		('Clarinet' 72)
		('Piccolo' 73)
		('Flute' 74)
		('Recorder' 75)
		('Pan Flute' 76)
		('Blown Bottle' 77)
		('Shakuhachi' 78)
		('Whistle' 79)
		('Ocarina' 80)
		('Lead 1 (square)' 81)
		('Lead 2 (sawtooth)' 82)
		('Lead 3 (calliope)' 83)
		('Lead 4 (chiff)' 84)
		('Lead 5 (charang)' 85)
		('Lead 6 (voice)' 86)
		('Lead 7 (fifths)' 87)
		('Lead 8 (bass+lead)' 88)
		('Pad 1 (new age)' 89)
		('Pad 2 (warm)' 90)
		('Pad 3 (polysynth)' 91)
		('Pad 4 (choir)' 92)
		('Pad 5 (bowed)' 93)
		('Pad 6 (metallic)' 94)
		('Pad 7 (halo)' 95)
		('Pad 8 (sweep)' 96)
		('FX 1 (rain)' 97)
		('FX 2 (soundtrack)' 98)
		('FX 3 (crystal)' 99)
		('FX 4 (atmosphere)' 100)
		('FX 5 (brightness)' 101)
		('FX 6 (goblins)' 102)
		('FX 7 (echoes)' 103)
		('FX 8 (sci-fi)' 104)
		('Sitar' 105)
		('Banjo' 106)
		('Shamisen' 107)
		('Koto' 108)
		('Kalimba' 109)
		('Bagpipe' 110)
		('Fiddle' 111)
		('Shanai' 112)
		('Tinkle Bell' 113)
		('Agogo' 114)
		('Steel Drums' 115)
		('Woodblock' 116)
		('Taiko Drum' 117)
		('Melodic Tom' 118)
		('Synth Drum' 119)
		('Reverse Cymbal' 120)
		('Guitar Fret Noise' 121)
		('Breath Noise' 122)
		('Seashore' 123)
		('Bird Tweet' 124)
		('Telephone Ring' 125)
		('Helicopter' 126)
		('Applause' 127)
		('Gunshot' 128)
	) do: [:pair |
		menu
			add: (self numberInParens: pair second), pair first localizedMIDI
			value: pair second asString].
	menu invokeModal.
	^ menu

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> midiNoteMenu [
	"Provides a drop-down menu for setting the note number."

	| menu midiKey noteName |
	menu := MenuMorph new defaultTarget: self.
	midiKey := 48.
	#(#low #middle)
		do: [ :oct | 
			#(#C 'C#' #D 'Eb' #E #F 'F#' #G 'Ab' #A 'Bb' #B)
				do: [ :n | 
					noteName := n = #C
						ifTrue: [ oct , ' ' , n ]
						ifFalse: [ n ].
					menu add: '(' , midiKey printString , ') ' , noteName value: midiKey.
					midiKey := midiKey + 1 ] ].
	menu add: '(72) high C' value: 72.
	menu invokeModal.
	^ menu
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
ScriptablePhratchMorph >> numberInParens: aNumber [

	^ '(' , aNumber printString, ') '

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> passiveSetVolumeTo: aNumber [

	| stage player |
	volume := aNumber asNumberNoError within: 0 and: 100.
	(stage := self ownerOrYourselfThatIsAPhratchStageMorph) ifNotNil: [
		(player := stage notePlayerFor: self) ifNotNil: [
			player volume: volume]].

	media do: [:snd |
		snd isSound ifTrue: [snd volume: volume]].

	self propagate: #volume


]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> playSound: soundName [
	"Play the given sound"
	<phratchItem: 'play sound $SoundNames$' kind: #- category: 'sound' defaultValues: #() subCategory: #a1 special: #()>
	| snd |
	snd := self soundNamed: soundName ifAbsent: [^ self].
	snd playFromStart.

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> recordSound [

	| frame |
	frame := self ownerOrYourselfThatIsAPhratchFrameMorph.
	frame ifNil: [^ PhratchError error: 'beep'.].
	frame stopAll.
	World submorphs do: [:m |
		(m isKindOf: PhratchSoundRecorderDialogMorph) ifTrue: [m delete]].

	PhratchSoundRecorderDialogMorph forClient: self.


]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> rest: duration elapsed: elapsed from: ignored [
	"Do nothing; just wait for the time interval to elapse."
	<phratchItem: 'rest for $Number$ beats' kind: #TimeBlockMorph category: 'sound' defaultValues: #(0.2) subCategory: #a2 special: #()>
	^ nil

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> saveSound: aSampledSound name: baseName [

	| sndItem |
	sndItem := SoundMedia new.
	sndItem mediaName: (self unusedMediaNameFromBaseName: baseName).
	media addLast: sndItem.

	sndItem sound: aSampledSound.
	self updateMediaCategory.

	self undeleteAttribute: #sounds.
	self propagateSounds

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> setTempoTo: aNumber [
	"Set the tempo"
	<phratchItem: 'set tempo to $Number$ bpm' kind: #- category: 'sound' defaultValues: #(60) subCategory: #a5 special: #()>
	| stage |
	(stage := self ownerOrYourselfThatIsAPhratchStageMorph) ifNil: [^ self].
	stage setTempoTo: aNumber.

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> setVolumeTo: aNumber [
	"Set the volume to the given value"
	<phratchItem: 'set volume to $Number$%' kind: #- category: 'sound' defaultValues: #(100) subCategory: #a4 special: #()>
	self undeleteAttribute: #volume.
	self passiveSetVolumeTo: aNumber

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> soundFromIndex: aNumber [
	"Return a sound for the given number--rounded and modulo the number of costumes. Return nil if there are not sounds."

	| soundList i |
	soundList := media select: [:m | m isSound].
	soundList size = 0 ifTrue: [^ nil].

	i := ((aNumber rounded - 1) \\ soundList size) + 1.
	^ soundList at: i

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> soundLevel [
	"Return the level of sound"
	<phratchItem: 'loudness' kind: #ReporterWatcherBlockMorph category: 'sensing' defaultValues: #() subCategory: #a4 special: #()>
	^ self class soundRecorder meterLevel

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> soundNamed: soundNameOrIndex ifAbsent: absentBlock [
	"Return a SoundMedia with the given name (ignoring case differences) or index. If there is none, return the result of evaluating the given block."

	| snd i |
	snd := nil.
	(soundNameOrIndex isString) ifTrue: [ "first, try using the argument as a sound name"
		snd := media
			detect: [:el | el isSound and: [el mediaName caseInsensitiveEqual: soundNameOrIndex]]
			ifNone: [nil].

		snd ifNil: [
			i := self interpretStringAsNumberIfPossible: soundNameOrIndex.
			i isNumber ifTrue: [
				snd := self soundFromIndex: i]].

		snd ifNil: [^ absentBlock value]].

	snd ifNil: [snd := self soundFromIndex: soundNameOrIndex asNumberNoError].

	snd
		ifNil: [^ absentBlock value]
		ifNotNil: [^ snd]


]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> soundNames [
	"Answer a list of my sound names. Suppress duplicates (ignoring case differences)."

	| result nm |
	result := OrderedCollection new.
	media do: [:el |
		el isSound ifTrue: [
			nm := el mediaName.
			(result anySatisfy: [:s | s caseInsensitiveEqual: nm])
				ifFalse: [result add: nm]]].
	self flag:'remove record because does not work'.
	"result addLast: '-'.
	result addLast: 'record' localized, '...'."
	^ result asArray

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph class >> soundRecorder [
	"Return the shared SoundRecorder. Create and start it, if necessary."

	Recorder ifNil: [
		Recorder := SoundRecorder new.
		Recorder startRecording].
	Recorder isActive ifFalse: [Recorder startRecording].
	^ Recorder

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> soundsPage: xOffset [
	"Answer a morph containing thumbnails of my sounds."

	| bin m y sounds n recBut impBut maxHeight yMargin xMargin separator |
	xMargin := 15.
	yMargin := 15.

	bin := PhratchBlockPaletteMorph new.

	m := StringMorph
		contents: 'New sound:' localized
		font: (PhratchFrameMorph getFont: #SoundsPage).
	m color: Color white.
	bin addMorph: m.

	recBut := PhratchFrameMorph buttonLabel: 'Record' localized selector: #recordSound.
	recBut target: self.
	self flag:'remove record because does not work'.
	"bin addMorph: recBut."

	impBut := PhratchFrameMorph buttonLabel: 'Import' localized selector: #importSound.
	impBut target: self.
	bin addMorph: impBut.

	maxHeight := (m height max: (impBut height max: recBut height)).
	m position: xMargin@(yMargin + ((maxHeight - m height) / 2)).
	recBut position: (m right + 4)@(yMargin + ((maxHeight - recBut height) / 2)).
	impBut position: (recBut right + 4)@(yMargin + ((maxHeight - impBut height) / 2)).

	separator := TiledImageMorph new tileForm: (PhratchFrameMorph skinAt: #costumeSeparatorTile).
	bin addMorph: (separator position: (xOffset + 17)@(yMargin + maxHeight + 5)).

	n := 0.
	y := yMargin + maxHeight + 9.
	sounds := media select: [:item | item isSound].
	sounds do: [:item |
		m := MediaItemMorph new.
		m phratchObj: self media: item; position: xOffset@y.
		m setNumber: (n := n + 1).
		bin addMorph: m.
		y := y + m height - 1].

	bin submorphs size > 0
		ifTrue: [separator width: bin firstSubmorph width - 14]
		ifFalse: [separator width: 240].

	^ bin

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> stopAllSounds [
	"Stop all sounds and MIDI notes/drums."
	<phratchItem: 'stop all sounds' kind: #- category: 'sound' defaultValues: #() subCategory: #a1 special: #()>
	| stage |
	stage := self ownerOrYourselfThatIsAPhratchStageMorph.
	stage ifNotNil: [stage stopAllSounds].

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> stopPlaying [
	"Stop playing all movies and sounds."

	| firstCostume |
	costume stopPlaying.
	self filterReset.
	self setVolumeTo: 100.	"reset volume"	"exit camera mode"
	(costume isKindOf: CameraMedia)
		ifFalse: [ ^ self ].
	firstCostume := media detect: [ :el | el isImage ] ifNone: [ ^ self ].
	self lookLike: firstCostume mediaName
]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> tempo [
	"Return the tempo"
	<phratchItem: 'tempo' kind: #ReporterWatcherBlockMorph category: 'sound' defaultValues: #() subCategory: #a5 special: #()>
	| stage |
	(stage := self ownerOrYourselfThatIsAPhratchStageMorph) ifNil: [^ 60].
	^ stage tempo

]

{ #category : #'*PhratchSound' }
ScriptablePhratchMorph >> volume [
	"Return the volume"
	<phratchItem: 'volume' kind: #ReporterWatcherBlockMorph category: 'sound' defaultValues: #() subCategory: #a4 special: #()>
	| att |
	att := #volume.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ volume

]
