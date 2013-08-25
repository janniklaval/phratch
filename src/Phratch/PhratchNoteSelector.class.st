Class {
	#name : #PhratchNoteSelector,
	#superclass : #BorderedMorph,
	#instVars : [
		'selectedVal',
		'labelMorph',
		'notePlayer'
	],
	#category : #'Phratch-Sound'
}

{ #category : #initialization }
PhratchNoteSelector >> buildKeyboard: nOctaves baseOctave: baseOctave keyWidth: whiteW [
	"Build keyboard for the given number of octaves starting with the given octave."

	| whiteH blackW blackH octaveStart octavePt nWhite nBlack noteR key xOffset |
	self removeAllMorphs.
	self extent: 5@5.  "adjusted later"
	whiteH := (3.3 * whiteW) rounded.
	blackW := (0.57 * whiteW) rounded.
	blackW even ifTrue: [blackW := blackW - 1].
	blackH := (0.6 * whiteH) rounded.
	0 to: nOctaves do: [:i |
		octaveStart := 12 * (baseOctave + i).
		octavePt := self innerBounds topLeft + (((7 * whiteW * i) - 1) @ -1).

		i < nOctaves
			ifTrue: [nWhite := 7. nBlack := 5]
			ifFalse: [nWhite := 1. nBlack := 0].  "only one 'C' key in top octave"

		1 to: nWhite do: [:j | 
			noteR := (octavePt + (((j - 1) * whiteW) @ 0)) extent: (whiteW + 1) @ whiteH.
			key := PhratchNoteSelectorKeyMorph newBounds: noteR.
			key midiKey: octaveStart + (#(0 2 4 5 7 9 11) at: j).
			self addMorph: key].

		1 to: nBlack do: [:j |
			xOffset := (whiteW * (#(1 2 4 5 6) at: j)) - (blackW // 2).
			noteR := (octavePt + (xOffset @ 0)) extent: blackW @ blackH.
			key := PhratchNoteSelectorKeyMorph newBounds: noteR.
			key midiKey: octaveStart + (#(1 3 6 8 10) at: j).
			self addMorph: key]].

	self extent: (self fullBounds extent + borderWidth - 1).

]

{ #category : #'event handling' }
PhratchNoteSelector >> handlesMouseDown: evt [

	^ true

]

{ #category : #initialization }
PhratchNoteSelector >> initialize [

	super initialize.
	selectedVal := nil.  "if nothing is ever selected, then don't return anything"
	notePlayer := nil.
	self buildKeyboard: 2 baseOctave: 4 keyWidth: 13.
	self setUpNoteDisplay.

]

{ #category : #'event handling' }
PhratchNoteSelector >> mouseMove: evt [

	| keyMorph k |
	evt anyButtonPressed ifFalse: [^ self].
	keyMorph := submorphs
		detect: [:m |
			(m containsPoint: evt cursorPoint) and:
			[m isKindOf: PhratchNoteSelectorKeyMorph]]
		ifNone: [nil].
	keyMorph
		ifNil: [self turnOffNote]
		ifNotNil: [
			k := keyMorph midiKey.
			k = selectedVal ifTrue: [^ self].
			self turnOffNote.
			keyMorph highlight: true.
			self turnOnNote: k.
			selectedVal := k].

]

{ #category : #'event handling' }
PhratchNoteSelector >> selectedValue [

	^self startUp
]

{ #category : #initialization }
PhratchNoteSelector >> setNotePlayer: thePlayer [

	notePlayer := thePlayer.

]

{ #category : #initialization }
PhratchNoteSelector >> setUpNoteDisplay [

	| height rectMorph |
	height := 20.

	"set up the rect morph which holds the note text"
	rectMorph := BorderedMorph new
		color: Color white;
		position: self bottomLeft - (0@2);
		extent: (self width @ height);
		yourself.
	self extent: self fullBounds extent.
	self addMorph: rectMorph.

	labelMorph := StringMorph new.
	labelMorph position: rectMorph position + (0@4).
	rectMorph addMorph: labelMorph.
	self extent: self fullBounds extent.

	self updateNoteDisplay: 60.

]

{ #category : #private }
PhratchNoteSelector >> shutDown [
	"closes everything up, and destroys the morph"
	self turnOffNote.
	self delete.
]

{ #category : #interaction }
PhratchNoteSelector >> startUp [
	"Waits for the user to click a value or to click outside, then returns the selected note or nil."

	| w result done |
	self openInWorld.
	w := self world.
"	Sensor waitNoButton. " "start with mouse up"
	w doOneCycle.
	w activeHand newMouseFocus: self.
	selectedVal := nil.
	done := false.
	[done] whileFalse: [
		(w activeHand hasMouseFocus: self) ifFalse: [done := true].
		w doOneCycle].

	result := selectedVal.
	self shutDown.
	^ result

]

{ #category : #stepping }
PhratchNoteSelector >> step [

	| keyMorph |
	Sensor anyButtonPressed ifTrue: [^ self].
	keyMorph := submorphs
		detect: [:m |
			(m containsPoint: Sensor lastMousePosition) and:
			[m isKindOf: PhratchNoteSelectorKeyMorph]]
		ifNone: [^ self].

	self updateNoteDisplay: keyMorph midiKey.

]

{ #category : #stepping }
PhratchNoteSelector >> stepTime [

	^ 100


]

{ #category : #private }
PhratchNoteSelector >> turnOffNote [

	submorphs do: [:m | (m isKindOf: PhratchNoteSelectorKeyMorph) ifTrue: [m highlight: false]].
	notePlayer ifNotNil: [notePlayer noteOff].
	selectedVal := nil.

]

{ #category : #private }
PhratchNoteSelector >> turnOnNote: midiKey [

	selectedVal := midiKey.
	self updateNoteDisplay: midiKey.
	notePlayer ifNotNil: [notePlayer noteOn: midiKey].

]

{ #category : #private }
PhratchNoteSelector >> updateNoteDisplay: noteNum [

	| s |
	s := #('C' 'C#' 'D' 'Eb' 'E' 'F' 'F#' 'G' 'G#' 'A' 'Bb' 'B') at: ((noteNum rem: 12) + 1).
	labelMorph
		contents: s, ' (' , noteNum asString, ')';
		centerInOwner.

]
