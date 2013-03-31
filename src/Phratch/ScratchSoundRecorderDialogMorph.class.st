Class {
	#name : #ScratchSoundRecorderDialogMorph,
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
	#category : #'Phratch-Sound'
}

{ #category : #'instance creation' }
ScratchSoundRecorderDialogMorph class >> forClient: aScriptableScratchMorph [
	"SoundRecorderDialogMorph forClient: "

	| dialog |
	dialog := super new
		withButtonsForYes: false no: false okay: true cancel: true;
		client: aScriptableScratchMorph;
		title: 'Sound Recorder'.
	^ dialog getUserResponse
]

{ #category : #initialization }
ScratchSoundRecorderDialogMorph >> buttonType: type action: actionSelector [
	"Answer a new button with the given type and selector. The button target will be me and it will use custom forms."

	| onForm offForm overForm disabledForm |
	onForm := ScratchFrameMorph skinAt: ('record', type, 'ButtonPressed').
	offForm := ScratchFrameMorph skinAt: ('record', type, 'Button').
	overForm := ScratchFrameMorph skinAt: ('record', type, 'ButtonOver').
	disabledForm := ScratchFrameMorph skinAt: ('record', type, 'ButtonDisabled').

	^ ToggleButton new
		isMomentary: false;
		onForm: onForm offForm: offForm overForm: overForm disabledForm: disabledForm;
		label: '' font: (ScratchFrameMorph getFont: #SoundRecorderButton);
		target: self;
		actionSelector: actionSelector.

]

{ #category : #'button commands' }
ScratchSoundRecorderDialogMorph >> cancelled [
	"Cancel button was pressed."

	recorder pause.
	recorder clearRecordedSound.
	super cancelled.

]

{ #category : #accessing }
ScratchSoundRecorderDialogMorph >> client: anObject [

	client := anObject.

]

{ #category : #initialization }
ScratchSoundRecorderDialogMorph >> convertToMmss: aNumber [
	"Answer a string of the form MM:SS. For displaying a time in seconds as hours, minutes, and seconds."

	| mm ss |
	mm := ((aNumber // 60) \\ 60) printString.
	"mm size < 2 ifTrue: [mm := '0', mm]."
	ss := (aNumber \\ 60) printString.
	ss size < 2 ifTrue: [ss := '0', ss].
	^ mm, ':', ss

]

{ #category : #drawing }
ScratchSoundRecorderDialogMorph >> drawOn: aCanvas [

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
ScratchSoundRecorderDialogMorph >> initialize [

	super initialize.

	self makeModeButtonsPane.
	self makeRecordMeter.
	self makeRecordTimer.

	recorder := ScriptableScratchMorph soundRecorder stopRecording.
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
ScratchSoundRecorderDialogMorph >> makeModeButtonsPane [

	| button tempBin |

	modeButtonsPane := AlignmentMorph newRow vResizing: #shrinkWrap.
	modeButtonsPane color: Color transparent.
	#(play stop record) do: [:n |
		button := (self buttonType: n asString capitalized action: n).
		button setProperty: #balloonText toValue: n asString localized.
		modeButtonsPane addMorphBack: button].

	tempBin := AlignmentMorph newRow
		color: Color transparent;
		cellPositioning: #leftCenter;
		centering: #center.
	tempBin
		addMorphBack: modeButtonsPane;
		addMorphBack: buttonRow.
	mainColumn addMorphBack: tempBin.
	bottomSpacer delete.
	bottomSpacer := nil.

]

{ #category : #initialization }
ScratchSoundRecorderDialogMorph >> makeRecordMeter [

	recorderBackgroundLeft := (ScratchFrameMorph skinAt: #recorderBackgroundLeft).
	recorderBackgroundCenter := (ScratchFrameMorph skinAt: #recorderBackgroundCenter).
	recorderBackgroundRight := (ScratchFrameMorph skinAt: #recorderBackgroundRight).

	recordMeter := ScratchRecordMeter new.
	mainColumn
		addMorphFront: (Morph new extent: 5@5; color: Color transparent);
		addMorphFront: recordMeter.

]

{ #category : #initialization }
ScratchSoundRecorderDialogMorph >> makeRecordTimer [

	"timer"
	timerMorph := ScratchStringMorph  "morph to display the duration"
		contents: (self convertToMmss: 0)
		font: (ScratchFrameMorph getFont: #SoundRecorderTimer).
	timerMorph color: Color darkGray.
	fileInfoColumn
		addMorphBack: (Morph new extent: (5@5); color: Color transparent);
		addMorphBack: timerMorph.

]

{ #category : #'button commands' }
ScratchSoundRecorderDialogMorph >> play [

	recorder pause.
	recorder playback.
	curStep := 1.
	self
		setMode: #play;
		setMode: #record isDisabled: true.
	self changed.
]

{ #category : #'button commands' }
ScratchSoundRecorderDialogMorph >> record [

	recorder isActive ifFalse:[
		recorder clearRecordedSound.
		recorder resumeRecording.
		savedMeterLevels := OrderedCollection new.
		duration := 0.
		self
			setMode: #record;
			setMode: #play isDisabled: false.
		self changed].

]

{ #category : #'button commands' }
ScratchSoundRecorderDialogMorph >> setMode: aSymbol [
	"Update the highlighting of my tool buttons."

	| modeButtons |
	currentMode := aSymbol.
	modeButtons := modeButtonsPane submorphs select: [:m | m isKindOf: ToggleButton].

	modeButtons do: [:b |
		b actionSelector = currentMode
			ifTrue: [b isDisabled: false. b on]
			ifFalse: [b off]].

]

{ #category : #'button commands' }
ScratchSoundRecorderDialogMorph >> setMode: aSymbol isDisabled: aBoolean [

	| modeButtons |
	modeButtons := modeButtonsPane submorphs select: [:m | m isKindOf: ToggleButton].

	modeButtons do: [:b |
		b actionSelector = aSymbol ifTrue: [b isDisabled: aBoolean]].

]

{ #category : #stepping }
ScratchSoundRecorderDialogMorph >> startStepping [
	"Make the level meter active when dropped into the world. Do nothing if already recording. Note that this will cause other recorders to stop recording..."

	super startStepping.
	recorder isPaused ifTrue: [
		SoundRecorder allSubInstancesDo: [:r | r stopRecording].  "stop all other sound recorders"
		recorder pause].  "meter is updated while paused"

]

{ #category : #stepping }
ScratchSoundRecorderDialogMorph >> step [

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
ScratchSoundRecorderDialogMorph >> stepTime [

	"^ 50"
	^ 200.

]

{ #category : #'button commands' }
ScratchSoundRecorderDialogMorph >> stop [

	recorder isActive ifTrue: [
		recorder pause.
		recorder trim: 1300 normalizedVolume: 80.0].
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
ScratchSoundRecorderDialogMorph >> stopStepping [
	"Turn off recording."

	super stopStepping.
	recorder stopRecording.

]

{ #category : #stepping }
ScratchSoundRecorderDialogMorph >> updateTime [

	timerMorph contents: (self convertToMmss: duration rounded).

]

{ #category : #'button commands' }
ScratchSoundRecorderDialogMorph >> yes [

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
