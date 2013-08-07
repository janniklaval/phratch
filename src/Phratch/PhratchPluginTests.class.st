Class {
	#name : #PhratchPluginTests,
	#superclass : #TestCase,
	#classVars : [
		'TestFileName'
	],
	#category : #'Phratch-Tests'
}

{ #category : #tests }
PhratchPluginTests >> blurTest: count [
	"PhratchPlugin blurTest: 10"

	| f outBits |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	f display.
	count timesRepeat: [
		outBits := f bits copy.
		PhratchPlugin primBlur: f bits into: outBits width: f width.
		f bits: outBits.
		f display].

]

{ #category : #tests }
PhratchPluginTests >> brightnessShiftTest [
	"self brightnessShiftTest"

	| f fOut shift |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := f deepCopy.
	[Sensor anyButtonPressed] whileFalse: [
		shift := ((Sensor cursorPoint x - Display center x) * 220) // Display width.
		PhratchPlugin primShiftBrightness: f bits into: fOut bits by: shift.
		fOut display].

]

{ #category : #tests }
PhratchPluginTests >> doubleTest [
	"self doubleTest"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (2 * f extent) + 20 depth: 32.
	PhratchPlugin primDouble: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height x: 9 y: 10.
	fOut display.


]

{ #category : #tests }
PhratchPluginTests >> filterBenchmark: count [
	"self filterBenchmark: 100"

	| f fOut s msecs |
	s := (WriteStream on: String new) cr.
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := f deepCopy.
	msecs := [ count timesRepeat: [ PhratchPlugin primShiftHue: f bits into: fOut bits byDegrees: 100 ] ] msecs.
	s
		nextPutAll: 'hue shift: ';
		nextPutAll: (msecs asFloat / count roundTo: 0.01) printString;
		nextPutAll: ' msecs';
		cr.
	fOut display.
	msecs := [ count timesRepeat: [ PhratchPlugin primShiftBrightness: f bits into: fOut bits by: 50 ] ] msecs.
	s
		nextPutAll: 'brightness shift: ';
		nextPutAll: (msecs asFloat / count roundTo: 0.01) printString;
		nextPutAll: ' msecs';
		cr.
	fOut display.
	msecs := [ count timesRepeat: [ PhratchPlugin primShiftSaturation: f bits into: fOut bits by: 50 ] ] msecs.
	s
		nextPutAll: 'saturation shift: ';
		nextPutAll: (msecs asFloat / count roundTo: 0.01) printString;
		nextPutAll: ' msecs';
		cr.
	fOut display.
	msecs := [ 
	count
		timesRepeat: [ 
			PhratchPlugin
				primFisheye: f bits
				into: fOut bits
				width: f width
				power: 300 ] ] msecs.
	s
		nextPutAll: 'fisheye: ';
		nextPutAll: (msecs asFloat / count roundTo: 0.01) printString;
		nextPutAll: ' msecs';
		cr.
	fOut display.
	msecs := [ 
	count
		timesRepeat: [ 
			PhratchPlugin
				primWhirl: f bits
				into: fOut bits
				width: f width
				angle: 1000 ] ] msecs.
	s
		nextPutAll: 'whirl: ';
		nextPutAll: (msecs asFloat / count roundTo: 0.01) printString;
		nextPutAll: ' msecs';
		cr.
	fOut display.
	msecs := [ count timesRepeat: [ fOut display ] ] msecs.
	s
		nextPutAll: 'display: ';
		nextPutAll: (msecs asFloat / count roundTo: 0.01) printString;
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
	f display.
	100 to: 300 by: 10 do: [:power |
		PhratchPlugin primFisheye: f bits into: fOut bits width: f width power: power.
		fOut display].

]

{ #category : #tests }
PhratchPluginTests >> fisheyeTest2: power [
	"self fisheyeTest2: 100"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := f deepCopy.
	f display.
	PhratchPlugin primFisheye: f bits into: fOut bits width: f width power: power.
	fOut display.

]

{ #category : #tests }
PhratchPluginTests >> halfSizeAverageTest [
	"self halfSizeAverageTest"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: f extent // 2 depth: 32.
	PhratchPlugin
		primHalfSizeAverage: f bits w: f width h: f height
		into: fOut bits w: fOut width h: fOut height
		srcX: 0 srcY: 0
		dstX: 0 dstY: 0 dstW: fOut width dstH: fOut height.
	f display.
	fOut display.


]

{ #category : #tests }
PhratchPluginTests >> halfSizeDiagonalTest [
	"self halfSizeDiagonalTest"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: f extent // 2 depth: 32.
	PhratchPlugin
		primHalfSizeDiagonal: f bits w: f width h: f height
		into: fOut bits w: fOut width h: fOut height
		srcX: 0 srcY: 0
		dstX: 0 dstY: 0 dstW: fOut width dstH: fOut height.
	f display.
	fOut display.


]

{ #category : #tests }
PhratchPluginTests >> hueShiftTest [
	"self hueShiftTest"

	| f fOut shift |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := f deepCopy.
	[Sensor anyButtonPressed] whileFalse: [
		shift := ((Sensor cursorPoint x - Display center x) * 380 * 2) // Display width.
		PhratchPlugin primShiftHue: f bits into: fOut bits byDegrees: shift.
		fOut display].

]

{ #category : #tests }
PhratchPluginTests >> interpolationTest: scale [
	"Answer a copy of the given form scaled by the given factor using linear interpolation."
	"(self interpolationTest: 1.5) display"

	| scaleP srcForm outExtent fOut w h outW pix outH |
	scaleP := scale asPoint.
	(scaleP x <= 0 or: [scaleP y <= 0]) ifTrue: [PhratchPlugin error: 'bad scale factor'].
	srcForm := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	outExtent := (srcForm extent * scaleP) truncated.
	(outExtent x > 1000 or: [outExtent y > 1000]) ifTrue: [PhratchPlugin error: 'result width or height will be > 1000 pixels'].
	fOut := Form extent: outExtent depth: 32.
	w := srcForm width.
	h := srcForm height.
	outW := fOut width.
	outH := fOut height.
	0 to: fOut width - 1 do: [:x |
		0 to: fOut height - 1 do: [:y |
			pix := PhratchPlugin
				primInterpolate: srcForm bits
				width: srcForm width
				x: (x * w * 1024) // outW
				y:  (y * h * 1024) // outH.
			fOut bits at: ((y * outW) + x + 1) put: pix]].
	^ fOut

]

{ #category : #tests }
PhratchPluginTests >> saturationShiftTest [
	"self saturationShiftTest"

	| f fOut shift |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := f deepCopy.
	[Sensor anyButtonPressed] whileFalse: [
		shift := ((Sensor cursorPoint x - Display center x) * 220) // Display width.
		PhratchPlugin primShiftSaturation: f bits into: fOut bits by: shift.
		fOut display].

]

{ #category : #tests }
PhratchPluginTests >> scaleTest: scale [
	"self scaleTest: 1.5"

	| f fOut |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := Form extent: (f extent * scale) rounded depth: 32.
	PhratchPlugin primScale: f bits w: f width h: f height into: fOut bits w: fOut width h: fOut height.
	fOut display.


]

{ #category : #tests }
PhratchPluginTests >> testFileName: aString [
	"Set the name of an image file for testing."
	"self testFileName: 'hammy.jpg'"
	"self testFileName: 'JohnMugShotBW.jpg'"

	TestFileName := aString.

]

{ #category : #tests }
PhratchPluginTests >> videoTest [
	"A quick test of video input. Displays video on the screen until the mouse is pressed."
	"CameraPlugin videoTest"

	| f n startTime frameCount msecs fps |
	(CameraPlugin openCamera: 1 width: 320 height: 240) ifNil: [^ CameraPlugin inform: 'no camera'].
	CameraPlugin waitForCameraStart.
	(CameraPlugin frameExtent: 1) x = 0 ifTrue: [^ CameraPlugin inform: 'no camera'].
	f := Form extent: (CameraPlugin frameExtent: 1) depth: 32.
	frameCount := 0.
	startTime := nil.
	[Sensor anyButtonPressed] whileFalse: [
		n := CameraPlugin getFrameForCamera: 1 into: f bits.
		n > 0 ifTrue: [
			startTime ifNil: [startTime := Time millisecondClockValue].
			frameCount := frameCount + 1.
			f display]].
	Sensor waitNoButton.
	msecs := Time millisecondClockValue - startTime.
	CameraPlugin closeCamera: 1.
	fps := (frameCount * 1000) // msecs.
	^ frameCount printString, ' frames at ', fps printString, ' frames/sec'
]

{ #category : #tests }
PhratchPluginTests >> waterRipples1ModuleTest [
	"Smalltalk unloadPlugin: self name"

	"self waterRipples1ModuleTest"

	| f fOut ripply aArray bArray |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := f deepCopy.
	aArray := ByteArray new: f width * f height * 8 withAll: 0.
	bArray := ByteArray new: f width * f height * 8 withAll: 0.
	[ Sensor anyButtonPressed ]
		whileFalse: [ 
			ripply := Sensor cursorPoint x max: 1.
			ripply := ((ripply / fOut width) sqrt * 16.0) asInteger.
			ripply := ripply max: 1.
			ripply printString display.
			PhratchPlugin
				primWaterRipples1: f bits
				into: fOut bits
				width: f width
				dropNum: ripply
				array1: aArray
				array2: bArray.
			fOut displayAt: 10 @ 30 ]
]

{ #category : #tests }
PhratchPluginTests >> waterRipples1ModuleTest: n [
	"Smalltalk unloadPlugin: self name"
	"self waterRipples1ModuleTest: 100"

	| f fOut aArray bArray |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := f deepCopy.
	aArray := ByteArray new: (f width * f height) * 8 withAll: 0.
	bArray := ByteArray new: (f width * f height) * 8 withAll: 0.

	PhratchPlugin primWaterRipples1: f bits
		into: fOut bits
		width: f width
		dropNum: n
		array1: aArray
		array2: bArray.
	[Sensor anyButtonPressed] whileFalse: [
		PhratchPlugin primWaterRipples1: f bits
			into: fOut bits
			width: f width
			dropNum: 1
			array1: aArray
			array2: bArray.
		fOut displayAt: 10@30].

]

{ #category : #tests }
PhratchPluginTests >> waterRipplesTime: n [
	"Smalltalk unloadPlugin: self name"
	"self waterRipplesTime: 100"

	| f fOut aArray bArray |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := f deepCopy.
	aArray := ByteArray new: (f width * f height) * 8 withAll: 0.
	bArray := ByteArray new: (f width * f height) * 8 withAll: 0.

	PhratchPlugin primWaterRipples1: f bits
		into: fOut bits
		width: f width
		dropNum: n
		array1: aArray
		array2: bArray.

	^ [100 timesRepeat: [
		PhratchPlugin primWaterRipples1: f bits
			into: fOut bits
			width: f width
			dropNum: 100
			array1: aArray
			array2: bArray]] msecs.

]

{ #category : #tests }
PhratchPluginTests >> whirlTest [
	"self whirlTest"

	| f fOut degrees |
	f := (Form fromFileNamed: TestFileName) asFormOfDepth: 32.
	fOut := f deepCopy.
	[Sensor anyButtonPressed] whileFalse: [
		degrees := ((Sensor cursorPoint x - Display center x) * 450 * 2) // Display width.
		PhratchPlugin primWhirl: f bits into: fOut bits width: f width angle: degrees.
		fOut display].

]
