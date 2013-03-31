Class {
	#name : #MotionInputPlugin,
	#superclass : #InterpreterPlugin,
	#category : #'Phratch-Primitives-Plugins'
}

{ #category : #primitives }
MotionInputPlugin class >> autoCalibrateRed [
	"Automatically calibrate color tracking for the most red pixels in the current frame."

	<primitive: 'primAutoCalibrateRed' module: 'MotionPlugin1'>
	self primitiveFailed


]

{ #category : #primitives }
MotionInputPlugin class >> closeCamera [
	"Close the camera. Do nothing if it was not open."

	<primitive: 'primCloseCamera' module: 'MotionPlugin1'>
	self primitiveFailed


]

{ #category : #translation }
MotionInputPlugin class >> declareCVarsIn: aCCodeGenerator [
	"self translate"

	super declareCVarsIn: aCCodeGenerator.
	aCCodeGenerator cExtras: '
#include "VibaUI.h"
'.
]

{ #category : #primitives }
MotionInputPlugin class >> getAbsolutePosition [
	"Answer a Point giving the absolute position of the center of the tracked area."

	| packed |
	packed := self primGetAbsolutePosition.
	^ (packed bitShift: -16) @ (packed bitAnd: 16rFFFF)

]

{ #category : #primitives }
MotionInputPlugin class >> getDirection [
	"Answer an integer angle (0 to 359) indicating the direction of the tracked area. Zero is up, towards the top of the video frame, and the angle increases going clockwise."

	<primitive: 'primGetAngleOfMotion' module: 'MotionPlugin1'>
	^ 0

]

{ #category : #primitives }
MotionInputPlugin class >> getDirectionQuadrant [
	"Answer an integer in [0..5] indicating indicating the motion direction of the tracked area. The integers map to {none, up, down, left, right}. This may be phased out. See getDirection."

	<primitive: 'primGetDirection' module: 'MotionPlugin1'>
	^ 0

]

{ #category : #primitives }
MotionInputPlugin class >> getFrameInto: a32BitForm [
	"Get the current frame texture into the given Form. The form must be 32-bits deep and the same size as the camera frame."

	self assert: [a32BitForm depth = 32].
	self primGetFrame: a32BitForm bits width: a32BitForm width defaultAlpha: 0.


]

{ #category : #primitives }
MotionInputPlugin class >> getMotion [
	"Answer an integer between 0 and 1000, where 0 is no motion and 1000 is the maximum possible amount of motion."

	<primitive: 'primGetMotion' module: 'MotionPlugin1'>
	^ 0

]

{ #category : #primitives }
MotionInputPlugin class >> getRelativePosition [
	"Answer a Point giving the relative position of the center of the tracked area."

	| packed |
	packed := self primGetRelativePosition.
	^ (packed bitShift: -16) @ (packed bitAnd: 16rFFFF)

]

{ #category : #primitives }
MotionInputPlugin class >> isOpen [

	<primitive: 'primIsOpen' module: 'MotionPlugin1'>
	^ false
]

{ #category : #primitives }
MotionInputPlugin class >> openCamera: cameraNum width: w [
	"Open the camera with the given number at the given frame width. The first argument is usually 1 since you typically have only one camera plugged in."

	<primitive: 'primOpenCamera' module: 'MotionPlugin1'>
	self primitiveFailed

]

{ #category : #primitives }
MotionInputPlugin class >> primGetAbsolutePosition [
	"Answer a 32-bit integer where the top 16 bits are the x and the low 16 bits are the y of the absolute position of the center of the tracked area."

	<primitive: 'primGetAbsolutePosition' module: 'MotionPlugin1'>
	^ 0

]

{ #category : #primitives }
MotionInputPlugin class >> primGetFrame: aBitmap width: w defaultAlpha: defaultAlpha [
	"Get the current frame texture into the given bitmap."

	<primitive: 'primGetFrame' module: 'MotionPlugin1'>
	self primitiveFailed.

]

{ #category : #primitives }
MotionInputPlugin class >> primGetRelativePosition [
	"Answer a 32-bit integer where the top 16 bits are the x and the low 16 bits are the y of the absolute position of the center of the tracked area in relative coordinates (0..1000)."

	<primitive: 'primGetRelativePosition' module: 'MotionPlugin1'>
	^ 0

]

{ #category : #primitives }
MotionInputPlugin class >> setFramesToAverageForDirection: anInteger [
	"Set the number of frames over which to average to compute the angle of motion."

	<primitive: 'primSetNumberOfFramesToAverageForDirection' module: 'MotionPlugin1'>
	self primitiveFailed

]

{ #category : #primitives }
MotionInputPlugin class >> setTextureMode: anInteger [
	"Set the texture mode. The modes are:
		0 - show video with brush hits overlaid
		1 - show just brush hits
		2 - show just video
		3 - show nothing (all black)
	Brush hits are shown as pure red for the first tracked color, pure green for the second, and pure blue for the third. Note that in the :=Video and :=None modes, one bit of precision is borrowed from each channel, so that we can still use the internal texture to store brush hits for up to three tracked colors."

	<primitive: 'primSetTextureMode' module: 'MotionPlugin1'>
	self primitiveFailed

]

{ #category : #primitives }
MotionInputPlugin class >> setTrackingMode: anInteger [
	"Set the tracking mode. 0 is motion tracking, 1 is color tracking."

	<primitive: 'primSetTrackingMode' module: 'MotionPlugin1'>
	self primitiveFailed

]

{ #category : #primitives }
MotionInputPlugin class >> setTrackingRedMin: redMin max: redMax greenMin: greenMin max: greenMax blueMin: blueMin max: blueMax [
	"Set the tracking color."

	<primitive: 'primSetTrackingColor' module: 'MotionPlugin1'>
	self primitiveFailed

]

{ #category : #primitives }
MotionInputPlugin >> primAutoCalibrateRed [
	"Answer true if the camera is open."

	self export: true.
	self cCode: 'VibaUI:=AutoCalibrateForRed()'.
	"leave receiver on the stack"
	^ 0

]

{ #category : #primitives }
MotionInputPlugin >> primCloseCamera [
	"Close the camera. Do nothing if it was not open."

	self export: true.
	self cCode: 'VibaUI:=Deinit()'.

	"leave the receiver on the stack"
	^ 0

]

{ #category : #primitives }
MotionInputPlugin >> primGetAbsolutePosition [
	"Answer the absolute x-y position of tracking, packed as two positive 16-bit numbers in a single integer."

	| x y result |
	self export: true.
	x := self cCode: 'VibaUI:=GetX:=Absolute()'.
	y := self cCode: 'VibaUI:=GetY:=Absolute()'.
	result := (x bitShift: 16) + y.

	interpreterProxy
		pop: 1 thenPush: (interpreterProxy integerObjectOf: result).  "pop rcvr, push result"
	^ 0

]

{ #category : #primitives }
MotionInputPlugin >> primGetAngleOfMotion [
	"Answer the angle of motion: {none, up, down, left, right}."

	| result |
	self export: true.
	result := self cCode: 'VibaUI:=GetAngleOfMotion()'.

	interpreterProxy
		pop: 1 thenPush: (interpreterProxy integerObjectOf: result).  "pop rcvr, push result"
	^ 0

]

{ #category : #primitives }
MotionInputPlugin >> primGetDirection [
	"Answer a small integer indicating the quadrant of motion: {none, up, down, left, right}."

	| result |
	self export: true.
	result := self cCode: 'VibaUI:=GetDirectionOfMotion()'.

	interpreterProxy
		pop: 1 thenPush: (interpreterProxy integerObjectOf: result).  "pop rcvr, push result"
	^ 0

]

{ #category : #primitives }
MotionInputPlugin >> primGetFrame [
	"Copy the current frame into a 32-bit Squeak bitmap."

	| bitsOop width defaultAlpha buf byteCount r |
	self export: true.
	self var: 'buf' declareC: 'unsigned char *buf'.

	bitsOop := interpreterProxy stackValue: 2.
	width := interpreterProxy stackIntegerValue: 1.
	defaultAlpha := interpreterProxy stackIntegerValue: 0.

	interpreterProxy success: (interpreterProxy isWords: bitsOop).
	interpreterProxy failed ifTrue: [^ 0].
	buf := self cCoerce: (interpreterProxy firstIndexableField: bitsOop) to: 'unsigned char *'.
	byteCount := 4 * (interpreterProxy stSizeOf: bitsOop).

	r := self cCode: 'VibaUI:=StoreTexture(buf, width, byteCount, defaultAlpha)'.
	interpreterProxy success: (r = 0).
	interpreterProxy failed ifTrue: [^ 0].

	interpreterProxy pop: 3.  "pop args, leave rcvr on stack"
	^ 0

]

{ #category : #primitives }
MotionInputPlugin >> primGetMotion [
	"Close the camera. Do nothing if it was not open."

	| result |
	self export: true.
	result := self cCode: 'VibaUI:=GetMotion()'.

	interpreterProxy
		pop: 1 thenPush: (interpreterProxy integerObjectOf: result).  "pop rcvr, push result"
	^ 0

]

{ #category : #primitives }
MotionInputPlugin >> primGetRelativePosition [
	"Answer the relative x-y position of tracking, packed as two positive 16-bit numbers in a single integer. The range of each coordinate is 0..1000."

	| x y result |
	self export: true.
	x := self cCode: 'VibaUI:=GetX:=Normalized()'.
	y := self cCode: 'VibaUI:=GetY:=Normalized()'.
	result := (x bitShift: 16) + y.

	interpreterProxy
		pop: 1 thenPush: (interpreterProxy integerObjectOf: result).  "pop rcvr, push result"
	^ 0

]

{ #category : #primitives }
MotionInputPlugin >> primIsOpen [
	"Answer true if the camera is open."

	| result |
	self export: true.
	result := self cCode: 'VibaUI:=IsActive()'.

	interpreterProxy pop: 1.  "pop rcvr"
	interpreterProxy pushBool: result ~= 0.  "push result"
	^ 0

]

{ #category : #primitives }
MotionInputPlugin >> primOpenCamera [
	"Open a camera. Takes one argument, the index of the device to open."

	| cameraNum frameWidth resolutionIndex r |
	self export: true.

	cameraNum := interpreterProxy stackIntegerValue: 1.
	frameWidth := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed ifTrue: [^ 0].

	resolutionIndex := 4.  "default"
	frameWidth <= 160 ifTrue: [resolutionIndex := 0].
	frameWidth <= 176 ifTrue: [resolutionIndex := 1].
	frameWidth <= 320 ifTrue: [resolutionIndex := 2].
	frameWidth <= 352 ifTrue: [resolutionIndex := 3].
	frameWidth <= 640 ifTrue: [resolutionIndex := 4].

	r := self cCode: 'VibaUI:=Init(NULL, (enum eVibaUI:=Resolution) resolutionIndex, cameraNum)'.
	interpreterProxy success: (r = 0).
	interpreterProxy failed ifTrue: [^ 0].

	interpreterProxy pop: 2.  "pop args, leave rcvr on stack"
	^ 0

]

{ #category : #primitives }
MotionInputPlugin >> primSetNumberOfFramesToAverageForDirection [
	"Set the number of frames over which to average to compute the direction."

	| frameCount r |
	self export: true.

	frameCount := interpreterProxy stackIntegerValue: 0.
	interpreterProxy success: (frameCount > 0).
	interpreterProxy failed ifTrue: [^ 0].

	frameCount > 30 ifTrue: [frameCount := 30].

	r := self cCode: 'VibaUI:=SetNumFramesOverWhichToAverageDirection(frameCount)'.
	interpreterProxy success: (r = 0).
	interpreterProxy failed ifTrue: [^ 0].

	interpreterProxy pop: 1.  "pop arg, leave rcvr on stack"
	^ 0

]

{ #category : #primitives }
MotionInputPlugin >> primSetTextureMode [
	"Set the texture mode."

	| mode r |
	self export: true.

	mode := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed ifTrue: [^ 0].

	r := self cCode: 'VibaUI:=SetTextureMode((enum eVibaUI:=TextureMode) mode)'.
	interpreterProxy success: (r = 0).
	interpreterProxy failed ifTrue: [^ 0].

	interpreterProxy pop: 1.  "pop arg, leave rcvr on stack"
	^ 0

]

{ #category : #primitives }
MotionInputPlugin >> primSetTrackingColor [
	"Set the tracking color thresholds."

	| minRed maxRed minGreen maxGreen minBlue maxBlue r |
	self export: true.

	minRed := interpreterProxy stackIntegerValue: 5.
	maxRed := interpreterProxy stackIntegerValue: 4.
	minGreen := interpreterProxy stackIntegerValue: 3.
	maxGreen := interpreterProxy stackIntegerValue: 2.
	minBlue := interpreterProxy stackIntegerValue: 1.
	maxBlue := interpreterProxy stackIntegerValue: 0.

	interpreterProxy failed ifTrue: [^ 0].

	r := self cCode: 'VibaUI:=SetTrackingColor(
		minRed, maxRed, minGreen, maxGreen, minBlue, maxBlue)'.
	interpreterProxy success: (r = 0).
	interpreterProxy failed ifTrue: [^ 0].

	interpreterProxy pop: 6.  "pop args, leave rcvr on stack"
	^ 0

]

{ #category : #primitives }
MotionInputPlugin >> primSetTrackingMode [
	"Set the tracking mode."

	| mode r |
	self export: true.

	mode := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed ifTrue: [^ 0].

	r := self cCode: 'VibaUI:=SetMode((enum eVibaUI:=Mode) mode)'.
	interpreterProxy success: (r = 0).
	interpreterProxy failed ifTrue: [^ 0].

	interpreterProxy pop: 1.  "pop arg, leave rcvr on stack"
	^ 0

]
