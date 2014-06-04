Class {
	#name : #PhratchPluginTests,
	#superclass : #TestCase,
	#classVars : [
		'TestFileName'
	],
	#category : #'Phratch-Tests'
}

{ #category : #tests }
PhratchPluginTests >> setUp [
	TestFileName :=  (FileSystem workingDirectory / 'ScratchSkin' / 'defaultSpriteCostume.png') fullName
]

{ #category : #tests }
PhratchPluginTests >> testVideo [
	self videoTest.
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
