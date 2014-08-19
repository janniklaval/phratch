Class {
	#name : #PhratchSoundRecorderDialogMorph,
	#superclass : #DialogBoxMorph,
	#instVars : [
		'recorder',
		'timerMorph',
		'currentMode',
		'recordMeter',
		'modeButtonsPane',
		'client',
		'duration',
		'savedMeterLevels',
		'curStep',
		'recorderBackgroundLeft',
		'recorderBackgroundCenter',
		'recorderBackgroundRight'
	],
	#category : #PhratchSound
}

{ #category : #'instance creation' }
PhratchSoundRecorderDialogMorph class >> forClient: aScriptablePhratchMorph [
	"SoundRecorderDialogMorph forClient: "

	| dialog |
	dialog := self new
		withButtonsForYes: false
			no: false
			okay: true
			cancel: true;
		client: aScriptablePhratchMorph;
		title: 'Sound Recorder' translated;
		yourself.
	^ dialog getUserResponse
]

{ #category : #initialization }
PhratchSoundRecorderDialogMorph >> buttonType: type action: actionSelector [
	"Answer a new button with the given type and selector. The button target will be me and it will use custom forms."

	| onForm offForm overForm disabledForm |
	onForm := PhratchFrameMorph skinAt: ('record', type, 'ButtonPressed').
	offForm := PhratchFrameMorph skinAt: ('record', type, 'Button').
	overForm := PhratchFrameMorph skinAt: ('record', type, 'ButtonOver').
	disabledForm := PhratchFrameMorph skinAt: ('record', type, 'ButtonDisabled').

	^ ToggleButton new
		isMomentary: false;
		onForm: onForm offForm: offForm overForm: overForm;
		label: '' font: (PhratchFrameMorph getFont: #SoundRecorderButton);
		target: self;
		actionSelector: actionSelector;
		yourself.

]

{ #category : #'button commands' }
PhratchSoundRecorderDialogMorph >> cancelled [
	"Cancel button was pressed."

	recorder pause.
	recorder clearRecordedSound.
	super cancelled.

]

{ #category : #accessing }
PhratchSoundRecorderDialogMorph >> client: anObject [

	client := anObject.

]

{ #category : #initialization }
PhratchSoundRecorderDialogMorph >> convertToMmss: aNumber [
	"Answer a string of the form MM:SS. For displaying a time in seconds as hours, minutes, and seconds."

	| mm ss |
	mm := ((aNumber // 60) \\ 60) printString.
	"mm size < 2 ifTrue: [mm := '0', mm]."
	ss := (aNumber \\ 60) printString.
	ss size < 2 ifTrue: [ss := '0', ss].
	^ mm, ':', ss

]

{ #category : #drawing }
PhratchSoundRecorderDialogMorph >> drawOn: aCanvas [

	| p clipC lastX |

	super drawOn: aCanvas.

	"draw recorder meter background, scalable"
	recorderBackgroundCenter ifNil: [^ self].

	clipC := aCanvas copyClipRect: self fullBounds.
	p := (self bounds topLeft + (20@(recordMeter top - self top - 3))) + (recorderBackgroundLeft width@0).
	clipC paintImage: recorderBackgroundLeft at: (self bounds topLeft + (20@(recordMeter top - self top - 3))).
	lastX := (self bounds right - 66) - (recorderBackgroundRight width).
	[p x <= lastX] whileTrue: [
		clipC paintImage: recorderBackgroundCenter at: p.
		p := (p x + recorderBackgroundCenter width) @ p y].
	clipC paintImage: recorderBackgroundRight at: ((self bounds right - 66) - recorderBackgroundRight width)@(self bounds top + (recordMeter top - self top - 3)).

]

{ #category : #initialization }
PhratchSoundRecorderDialogMorph >> initialize [

	super initialize.

	self makeModeButtonsPane.
	self makeRecordMeter.
	self makeRecordTimer.

	recorder := ScriptablePhratchMorph soundRecorder stopRecording.
	recorder recordLevel: 0.5.
	savedMeterLevels := OrderedCollection new.
	curStep := 1.
	
	duration := 0.
	self setMode: #stop.
	self setMode: #play isDisabled: true.

	"fixes layout"
	mainColumn centering: #topLeft.
	self extent: 380@145.

]

{ #category : #initialization }
PhratchSoundRecorderDialogMorph >> makeModeButtonsPane [

	| button tempBin |

	modeButtonsPane := AlignmentMorph newRow vResizing: #shrinkWrap.
	modeButtonsPane color: Color transparent.
	self flag:'remove record because does not work'.
	#(play stop "record") do: [:n |
		button := (self buttonType: n asString capitalized action: n).
		button setProperty: #balloonText toValue: n asString localized.
		modeButtonsPane addMorphBack: button].

	tempBin := AlignmentMorph newRow
		color: Color transparent;
		cellPositioning: #leftCenter;
		centering: #center;
		yourself.
	tempBin
		addMorphBack: modeButtonsPane;
		addMorphBack: buttonRow.
	mainColumn addMorphBack: tempBin.
	bottomSpacer delete.
	bottomSpacer := nil.

]

{ #category : #initialization }
PhratchSoundRecorderDialogMorph >> makeRecordMeter [

	recorderBackgroundLeft := (PhratchFrameMorph skinAt: #recorderBackgroundLeft).
	recorderBackgroundCenter := (PhratchFrameMorph skinAt: #recorderBackgroundCenter).
	recorderBackgroundRight := (PhratchFrameMorph skinAt: #recorderBackgroundRight).

	recordMeter := PhratchRecordMeter new.
	mainColumn
		addMorphFront: (Morph new extent: 5@5; color: Color transparent;
		yourself);
		addMorphFront: recordMeter.

]

{ #category : #initialization }
PhratchSoundRecorderDialogMorph >> makeRecordTimer [

	"timer"
	timerMorph := StringMorph  "morph to display the duration"
		contents: (self convertToMmss: 0)
		font: (PhratchFrameMorph getFont: #SoundRecorderTimer).
	timerMorph color: Color darkGray.
	fileInfoColumn
		addMorphBack: (Morph new extent: (5@5); color: Color transparent;
		yourself);
		addMorphBack: timerMorph.

]

{ #category : #'button commands' }
PhratchSoundRecorderDialogMorph >> play [

	recorder pause.
	recorder playback.
	curStep := 1.
	self
		setMode: #play;
		setMode: #record isDisabled: true.
	self changed.
]

{ #category : #'button commands' }
PhratchSoundRecorderDialogMorph >> record [
	recorder isActive
		ifTrue: [ ^ self ].
	recorder clearRecordedSound.
	recorder resumeRecording.
	savedMeterLevels := OrderedCollection new.
	duration := 0.
	self
		setMode: #record;
		setMode: #play isDisabled: false.
	self changed
]

{ #category : #'button commands' }
PhratchSoundRecorderDialogMorph >> setMode: aSymbol [
	"Update the highlighting of my tool buttons."

	| modeButtons |
	currentMode := aSymbol.
	modeButtons := modeButtonsPane submorphs select: [:m | m isToggleButton].

	modeButtons do: [:b |
		b actionSelector = currentMode
			ifTrue: [b isDisabled: false. b on]
			ifFalse: [b off]].

]

{ #category : #'button commands' }
PhratchSoundRecorderDialogMorph >> setMode: aSymbol isDisabled: aBoolean [

	| modeButtons |
	modeButtons := modeButtonsPane submorphs select: [:m | m isToggleButton].

	modeButtons do: [:b |
		b actionSelector = aSymbol ifTrue: [b isDisabled: aBoolean]].

]

{ #category : #stepping }
PhratchSoundRecorderDialogMorph >> startStepping [
	"Make the level meter active when dropped into the world. Do nothing if already recording. Note that this will cause other recorders to stop recording..."

	"meter is updated while paused"

	super startStepping.
	recorder isPaused
		ifFalse: [ ^ self ].
	SoundRecorder allSubInstancesDo: [ :r | r stopRecording ].	"stop all other sound recorders"
	recorder pause
]

{ #category : #stepping }
PhratchSoundRecorderDialogMorph >> step [

	| m |
	recorder isPaused
		ifTrue: [(currentMode = #play)
			ifTrue: [
				(recorder recordedSound notNil and: [recorder recordedSound isPlaying])
					ifTrue: [
						duration := recorder recordedSound millisecondsSinceStart // 1000.
						(curStep < savedMeterLevels size) 
							ifTrue: [recordMeter setLevel: (savedMeterLevels at: curStep)].
						curStep := curStep + 1.
						self updateTime]
					ifFalse: [self stop]]
			ifFalse: [recordMeter setLevel: 0.0]]
		ifFalse: [
			duration := duration + 0.2.
			self updateTime.
			m := recorder meterLevel*3.
			recordMeter setLevel: m.
			savedMeterLevels add: m.].
		
]

{ #category : #stepping }
PhratchSoundRecorderDialogMorph >> stepTime [

	"^ 50"
	^ 200.

]

{ #category : #'button commands' }
PhratchSoundRecorderDialogMorph >> stop [

	recorder isActive ifTrue: [
		self play.
		recorder pause.
		"curStep := 1.
		recorder trim: 1300 normalizedVolume: 80.0"].
	self
		setMode: #stop;
		setMode: #play isDisabled: false;
		setMode: #record isDisabled: false.
	
	recorder recordedSound
		ifNil: [duration := 0.0]
		ifNotNil: [duration := recorder recordedSound duration].
	self updateTime.
	self changed.

]

{ #category : #stepping }
PhratchSoundRecorderDialogMorph >> stopStepping [
	"Turn off recording."

	super stopStepping.
	recorder stopRecording.

]

{ #category : #stepping }
PhratchSoundRecorderDialogMorph >> updateTime [

	timerMorph contents: (self convertToMmss: duration rounded).

]

{ #category : #'button commands' }
PhratchSoundRecorderDialogMorph >> yes [

	| samples samplingRate snd |
	self stop.
	samples := recorder condensedSamples.
	samplingRate := recorder samplingRate.
	samplingRate = 44100 ifTrue: [
		samples := samples downSampledLowPassFiltering: false.
		samplingRate := 22050].
	snd := SampledSound samples: samples samplingRate: samplingRate.
	(client notNil and: [samples size > 0]) ifTrue: [
		client saveSound: snd name: 'recording' localized,'1'].
	recorder clearRecordedSound.
	super yes.

]
