"
I represent a literal value such as a number or string. I can be edited by typing or a value can be chosen from a pull-down menu.

"
Class {
	#name : #ExpressionArgMorphWithMenu,
	#superclass : #ExpressionArgMorph,
	#instVars : [
		'menuMorph',
		'getMenuSelector',
		'specialValue'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #'class initialization' }
ExpressionArgMorphWithMenu class >> initialize [
	"self initialize"

	DropDownMenuForm := Form
		extent: 7@4
		depth: 1
		fromArray: #(4261412864 2080374784 939524096 268435456)
		offset: 0@0.
	DropDownMenuForm := DropDownMenuForm colorReduced.  "become a ColorForm"
	DropDownMenuForm colors:
		(Array with: Color transparent with: (Color gray: 0.25)).

]

{ #category : #accessing }
ExpressionArgMorphWithMenu >> defaultValue: anObject [

	((#(listIndexMenu listIndexForDeleteMenu) includes: getMenuSelector) and:
	 [anObject isKindOf: String])
		ifTrue: [self specialValue: anObject]
		ifFalse: [super defaultValue: anObject].


]

{ #category : #menus }
ExpressionArgMorphWithMenu >> directionMenu [
	"Provides a drop-down menu for setting the sprite direction."

	| menu |
	menu := MenuMorph new defaultTarget: nil.
	#(	('right' 90)
		('left' -90)
		('up' 0)
		('down' 180)
	) do: [:pair |
		menu
			add: '(' "asUTF8", pair second printString, ') ', pair first localized
			target: self
			selector: #stringExpression:
			argument: pair second asString].
	^ menu

]

{ #category : #evaluation }
ExpressionArgMorphWithMenu >> evaluate [
	| expr |
	"Answer the result of evaluating my expression in the context of the given PhratchProcess."

	(self isEmptySlot and: [implicitValue notNil])
		ifTrue: [^implicitValue].

	specialValue ifNotNil: [^ specialValue].


"	^ super evaluate"

	expr := labelMorph savedContents.
	isNumber
		ifTrue: [ ^ expr asNumberNoError]
		ifFalse: [^ expr]. 





]

{ #category : #'object i/o' }
ExpressionArgMorphWithMenu >> fieldsVersion [

	^ 2

]

{ #category : #private }
ExpressionArgMorphWithMenu >> fixArgLayout [

	| dx |
	dx := 9.
	super fixArgLayout.
	menuMorph ifNil: [^ self].
	self width: self width + dx.
	menuMorph position: (self right - dx - 2)@(self top + (self height // 3)).
	(thisContext sender receiver isKindOf: StringFieldMorph) ifTrue: [
		"clear only when user edit my label, but not on other arg layout changes"
		specialValue := nil].

]

{ #category : #'event handling' }
ExpressionArgMorphWithMenu >> handlesMouseDown: evt [

	^ menuMorph notNil

]

{ #category : #'object i/o' }
ExpressionArgMorphWithMenu >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		menuMorph
		getMenuSelector
	) from: anObjStream.

	classVersion = 1 ifTrue: [^ self].

	"field added in version 2"
	self initFieldsNamed: #(
		specialValue
	) from: anObjStream.

]

{ #category : #BYOB }
ExpressionArgMorphWithMenu >> isEmptySlot [
	specialValue ifNotNil: [
		^ specialValue = ' ' asUTF8].
	^super isEmptySlot
]

{ #category : #menus }
ExpressionArgMorphWithMenu >> listIndexForDeleteMenu [

	| menu |
	menu := MenuMorphNG new .
	#('1' last) do: [:s | menu add: s  printString 
			value: s  asString].
	menu addLine.
	menu add: #all  printString 
			value: #all  asString.
	menu localize.
	^ menu

]

{ #category : #menus }
ExpressionArgMorphWithMenu >> listIndexMenu [

	| menu |
	menu := MenuMorph new defaultTarget: nil.
	#('1' last any) do: [:s | menu add: s  printString 
			target: self
			selector: #stringExpression:
			argument: s  asString].
	menu localize.
	^ menu

]

{ #category : #menus }
ExpressionArgMorphWithMenu >> menuSelector [

	^ getMenuSelector


]

{ #category : #menus }
ExpressionArgMorphWithMenu >> menuSelector: menuSelector [
	"Add a drop-down menu button with the given selector. The selector should result in a menu whose action items are values that can be put into this type argument, typically numbers or strings."

	menuMorph := ImageMorph new form: DropDownMenuForm.
	getMenuSelector := menuSelector.
	self addMorphFront: menuMorph.
	self fixArgLayout.

]

{ #category : #menus }
ExpressionArgMorphWithMenu >> midiDrumMenu [
	"Provides a drop-down menu for setting the drum number."

	| menu |
	menu := MenuMorphNG new defaultTarget: self.
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
			value: pair second asString].
	
	menu invokeModal.
	^ menu

]

{ #category : #menus }
ExpressionArgMorphWithMenu >> midiInstrumentMenu [
	"Provides a drop-down menu for setting the instrument number."

	| menu |
	menu := MenuMorphNG  new.
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

{ #category : #'event handling' }
ExpressionArgMorphWithMenu >> mouseDown: evt [

	| rcvr menu choice |
	menuMorph ifNil: [^ super mouseDown: evt].
	(evt cursorPoint x < (menuMorph left - 1)) ifTrue: [^ super mouseDown: evt].

	(getMenuSelector notNil and:
	 [(owner isKindOf: BlockMorph) and: 
	 [(rcvr := owner receiver) notNil]]) ifFalse: [^ Beeper beep].
	menu := rcvr perform: getMenuSelector.
	(menu isKindOf: PhratchNoteSelector) ifTrue: [
		menu position: owner bottomLeft + (((owner width - menu width) // 2) @ -4).
		].
	choice := menu selectedValue.
	choice ifNil: [^ self].
	evt hand newKeyboardFocus: nil.  "close mini-editor, if any"
	(#(listIndexMenu listIndexForDeleteMenu) includes: getMenuSelector) ifTrue: [
		^ self specialValue: choice].

	isNumber
		ifTrue: [self numExpression: choice]
		ifFalse: [self stringExpression: choice].


]

{ #category : #menus }
ExpressionArgMorphWithMenu >> numberInParens: aNumber [

	^" (String  with: 16r200E) asUTF8," '(' "asUTF8", aNumber printString, ') ' asMacRoman 

]

{ #category : #accessing }
ExpressionArgMorphWithMenu >> specialValue: aString [
	"A special value is a menu selection such as 'last' for a list index that appears as a string in a number if field. If the user edits the field, then it only accepts numeric input. The argumet is retained in the specialValue instance variable."

	isNumber := true.
	labelMorph contents: aString localized.
	labelMorph
		isNumeric: true;
		position: self position + (0@1).
	self fixArgLayout.
	specialValue := aString.

]

{ #category : #'object i/o' }
ExpressionArgMorphWithMenu >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		menuMorph
		getMenuSelector
		specialValue
	) on: anObjStream.

]
