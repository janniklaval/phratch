Class {
	#name : #PhratchPluginTests,
	#superclass : #TestCase,
	#classVars : [
		'TestFileName'
	],
	#category : #'Phratch-Tests'
}

{ #category : #tests }
PhratchPluginTests >> brightnessShiftTest [
	"self brightnessShiftTest"

	| f fOut shift |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := f deepCopy.
	"[Sensor anyButtonPressed] whileFalse: ["
		shift := ((Sensor cursorPoint x - Display center x) * 220) // Display width.
		PhratchPlugin primShiftBrightness: f bits into: fOut bits by: shift.
		"fOut display""]".

]

{ #category : #tests }
PhratchPluginTests >> filterBenchmark: count [
	"self filterBenchmark: 100"

	| f fOut s msecs |
	s := (WriteStream on: String new) cr.
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := f deepCopy.
	msecs := [ count timesRepeat: [ PhratchPlugin primShiftHue: f bits into: fOut bits byDegrees: 100 ] ] timeToRun.
	s
		nextPutAll: 'hue shift: ';
		nextPutAll: (msecs / count) printString;
		nextPutAll: ' msecs';
		cr.
	"fOut display."
	msecs := [ count timesRepeat: [ PhratchPlugin primShiftBrightness: f bits into: fOut bits by: 50 ] ] timeToRun.
	s
		nextPutAll: 'brightness shift: ';
		nextPutAll: (msecs  / count) printString;
		nextPutAll: ' msecs';
		cr.
	"fOut display."
	msecs := [ 
	count
		timesRepeat: [ 
			PhratchPlugin
				primFisheye: f bits
				into: fOut bits
				width: f width
				power: 300 ] ] timeToRun.
	s
		nextPutAll: 'fisheye: ';
		nextPutAll: (msecs / count) printString;
		nextPutAll: ' msecs';
		cr.
	"fOut display."
	msecs := [ 
	count
		timesRepeat: [ 
			PhratchPlugin
				primWhirl: f bits
				into: fOut bits
				width: f width
				angle: 1000 ] ] timeToRun.
	s
		nextPutAll: 'whirl: ';
		nextPutAll: (msecs / count) printString;
		nextPutAll: ' msecs';
		cr.
	"fOut display."
	msecs := [ count timesRepeat: [ fOut display ] ] timeToRun.
	s
		nextPutAll: 'display: ';
		nextPutAll: (msecs / count) printString;
		nextPutAll: ' msecs';
		cr.
	^ s contents
]

{ #category : #tests }
PhratchPluginTests >> fisheyeTest [
	"self fisheyeTest"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := f deepCopy.
	"f display."
	100 to: 300 by: 10 do: [:power |
		PhratchPlugin primFisheye: f bits into: fOut bits width: f width power: power.
		"fOut display"].

]

{ #category : #tests }
PhratchPluginTests >> fisheyeTest2: power [
	"self fisheyeTest2: 100"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := f deepCopy.
	"f display."
	PhratchPlugin primFisheye: f bits into: fOut bits width: f width power: power.
"	fOut display."

]

{ #category : #tests }
PhratchPluginTests >> hueShiftTest [
	"self hueShiftTest"

	| f fOut shift |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := f deepCopy.
	"[Sensor anyButtonPressed] whileFalse: ["
		shift := ((Sensor cursorPoint x - Display center x) * 380 * 2) // Display width.
		PhratchPlugin primShiftHue: f bits into: fOut bits byDegrees: shift.
		"fOut display""]".

]

{ #category : #tests }
PhratchPluginTests >> setUp [
	TestFileName :=  (FileSystem workingDirectory / 'ScratchSkin' / 'defaultSpriteCostume.png') fullName
]

{ #category : #tests }
PhratchPluginTests >> testBrightnessShift [
	self brightnessShiftTest.
	self assert: true.
]

{ #category : #tests }
PhratchPluginTests >> testFilterBenchmark [
	self filterBenchmark: 100.
	self assert:true.
]

{ #category : #tests }
PhratchPluginTests >> testFisheye [
	self fisheyeTest.
	self assert: true.
]

{ #category : #tests }
PhratchPluginTests >> testFisheye2 [
	self fisheyeTest2: 100.
	self assert: true.
]

{ #category : #tests }
PhratchPluginTests >> testHueShift [
	self hueShiftTest.
	self assert: true.
]

{ #category : #tests }
PhratchPluginTests >> testVideo [
	self videoTest.
	self assert: true.
]

{ #category : #tests }
PhratchPluginTests >> testWhirl [
	self whirlTest.
	self assert: true.
]

{ #category : #tests }
PhratchPluginTests >> videoTest [
	"A quick test of video input. Displays video on the screen until the mouse is pressed."
	"CameraPlugin videoTest"

	| f startTime frameCount msecs fps |
	(CameraPlugin openCamera: 1 width: 320 height: 240) ifNil: [^ CameraPlugin inform: 'no camera'].
	CameraPlugin waitForCameraStart.
	(CameraPlugin frameExtent: 1) x = 0 ifTrue: [^ CameraPlugin inform: 'no camera'].
	f := Form extent: (CameraPlugin frameExtent: 1) depth: 32.
	frameCount := 0.
	startTime := 0.
	
		CameraPlugin getFrameForCamera: 1 into: f bits.
		
			startTime ifNil: [startTime := Time millisecondClockValue].
			frameCount := frameCount + 1.
		"	f display."
	Sensor waitNoButton.
	msecs := Time millisecondClockValue - startTime.
	CameraPlugin closeCamera: 1.
	fps := (frameCount * 1000) // msecs.
	
	^ frameCount printString, ' frames at ', fps printString, ' frames/sec'
]

{ #category : #tests }
PhratchPluginTests >> whirlTest [
	"self whirlTest"

	| f fOut degrees |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := f deepCopy.
	"[Sensor anyButtonPressed] whileFalse: ["
		degrees := ((Sensor cursorPoint x - Display center x) * 450 * 2) // Display width.
		PhratchPlugin primWhirl: f bits into: fOut bits width: f width angle: degrees.
		"fOut display""]".

]
