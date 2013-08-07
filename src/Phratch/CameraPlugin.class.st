Class {
	#name : #CameraPlugin,
	#superclass : #InterpreterPlugin,
	#category : #'Phratch-Primitives-Plugins'
}

{ #category : #'camera ops' }
CameraPlugin class >> camera: cameraNum getParam: paramNum [
	"Answer the given parameter for the given camera."

	<primitive: 'primGetParam' module: 'CameraPlugin'>
	^ nil

]

{ #category : #'camera ops' }
CameraPlugin class >> cameraIsAvailable [
	"Answer true if at least one camera is available."

	| enableCamera |
	enableCamera := false.
	^ enableCamera and: [(self cameraName: 1) notNil]

]

{ #category : #'camera ops' }
CameraPlugin class >> cameraIsOpen: cameraNum [
	"Answer true if the camera is open."

	^ (self packedFrameExtent: cameraNum) > 0

]

{ #category : #'camera ops' }
CameraPlugin class >> cameraName: cameraNum [
	"Answer the name of the given camera. Answer nil if there is no camera with the given number."

	<primitive: 'primCameraName' module: 'CameraPlugin'>
	^ nil

]

{ #category : #'camera ops' }
CameraPlugin class >> closeCamera: cameraNum [
	"Close the camera. Do nothing if it was not open."

	<primitive: 'primCloseCamera' module: 'CameraPlugin'>
	^nil
]

{ #category : #translation }
CameraPlugin class >> declareCVarsIn: aCCodeGenerator [
	"self translate"

	super declareCVarsIn: aCCodeGenerator.
	aCCodeGenerator cExtras: '
#include "cameraOps.h"
#include <string.h>
'.
]

{ #category : #'camera ops' }
CameraPlugin class >> frameExtent: cameraNum [
	"Answer the frame extent of the currently open camera, or zero if the camera isn't open."

	| packedExtent |
	packedExtent := self packedFrameExtent: cameraNum.
	^ (packedExtent bitShift: -16) @ (packedExtent bitAnd: 16rFFFF) 
]

{ #category : #'camera ops' }
CameraPlugin class >> getFrameForCamera: cameraNum into: aBitmap [
	"Copy a camera frame into the given Bitmap. The Bitmap should be for a Form of depth 32 that is the same width and height as the current camera frame. Fail if the camera is not open or if the bitmap is not the right size. If successful, answer the number of frames received from the camera since the last call. If this is zero, then there has been no change."

	<primitive: 'primGetFrame' module: 'CameraPlugin'>
	^ 0
]

{ #category : #'camera ops' }
CameraPlugin class >> openCamera: cameraNum width: frameWidth height: frameHeight [
	"Open the given camera requesting the given frame dimensions. The camera number is usually 1 since you typically have only one camera plugged in. If the camera does not support the exact frame dimensions, an available frame size with width >= the requested width is selected."

	<primitive: 'primOpenCamera' module: 'CameraPlugin'>
	^ nil

]

{ #category : #'camera ops' }
CameraPlugin class >> packedFrameExtent: cameraNum [
	"Answer the extent of the currently open camera packed in an integer. The top 16 bits are the width, the low 16 bits are the height. Answer zero if the camera isn't open."

	<primitive: 'primFrameExtent' module: 'CameraPlugin'>
	^ 0

]

{ #category : #'camera ops' }
CameraPlugin class >> waitForCameraStart [
	"Wait for the camera to get it's first frame (indicated by a non-zero frame extent. Timeout after a few seconds."
	"self waitForCameraStart"

	| startTime |
	startTime := Time millisecondClockValue.
	[(Time millisecondClockValue - startTime) < 2000] whileTrue: [
		(self packedFrameExtent: 1) > 0 ifTrue: [^ self].
		(Delay forMilliseconds: 50) wait].
]

{ #category : #primitives }
CameraPlugin >> primCameraName [
	"Get the name for the camera with the given number. Fail if the camera number is greater than the number of available cameras."

	| cameraNum nameStr count resultOop dst |
	self export: true.
	self var: 'nameStr' declareC: 'char* nameStr'.
	self var: 'dst' declareC: 'char* dst'.
	cameraNum := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed
		ifTrue: [ ^ 0 ].
	nameStr := self cCode: 'CameraName(cameraNum)'.
	nameStr isNil
		ifTrue: [ 
			interpreterProxy success: false.
			^ 0 ].
	count := self cCode: '(int) strlen(nameStr)'.
	resultOop := interpreterProxy instantiateClass: interpreterProxy classString indexableSize: count.
	dst := self cCoerce: (interpreterProxy firstIndexableField: resultOop) to: 'char *'.
	0 to: count - 1 do: [ :i | dst at: i put: (nameStr at: i) ].
	interpreterProxy pop: 2 thenPush: resultOop.	"pop arg and rcvr, push result"
	^ 0
]

{ #category : #primitives }
CameraPlugin >> primCloseCamera [
	"Close the camera. Do nothing if it was not open."

	| cameraNum |
	self export: true.
	cameraNum := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed ifTrue: [^ 0].

	self cCode: 'CameraClose(cameraNum)'.

	interpreterProxy pop: 1.  "pop arg, leave rcvr on stack"
	^ 0

]

{ #category : #primitives }
CameraPlugin >> primFrameExtent [
	"Answer the frame extent of the given camera, or zero if the camera is not open. The extent is 16 bits of width and height packed into a single integer."

	| cameraNum e |
	self export: true.
	cameraNum := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed ifTrue: [^ 0].

	e := self cCode: 'CameraExtent(cameraNum)'.

	interpreterProxy pop: 2 thenPush: (interpreterProxy integerObjectOf: e).  "pop rcvr & arg, push int result"
	^ 0

]

{ #category : #primitives }
CameraPlugin >> primGetFrame [
	"Copy a camera frame into the given Bitmap. The Bitmap should be for a Form of depth 32 that is the same width and height as the current camera frame. Fail if the camera is not open or if the bitmap is not the right size. If successful, answer the number of frames received from the camera since the last call. If this is zero, then there has been no change."

	| cameraNum bitmapOop bitmap pixCount result |
	self export: true.
	self var: 'bitmap' declareC: 'unsigned char *bitmap'.

	cameraNum := interpreterProxy stackIntegerValue: 1.
	bitmapOop := interpreterProxy stackValue: 0.
	((interpreterProxy isIntegerObject: bitmapOop) or:
	 [(interpreterProxy isWords: bitmapOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	bitmap := self cCoerce: (interpreterProxy firstIndexableField: bitmapOop) to: 'unsigned char *'.
	pixCount := interpreterProxy stSizeOf: bitmapOop.

	result := self cCode: 'CameraGetFrame(cameraNum, bitmap, pixCount)'.
	result < 0 ifTrue: [
		interpreterProxy success: false.
		^ 0].

	interpreterProxy pop: 3 thenPush: (interpreterProxy integerObjectOf: result).  "pop rcvr & args, push int result"
	^ 0


]

{ #category : #primitives }
CameraPlugin >> primGetParam [
	"Answer the given integer parameter of the given camera."

	| cameraNum paramNum result |
	self export: true.
	cameraNum := interpreterProxy stackIntegerValue: 1.
	paramNum := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed ifTrue: [^ 0].

	result := self cCode: 'CameraGetParam(cameraNum, paramNum)'.

	interpreterProxy pop: 3 thenPush: (interpreterProxy integerObjectOf: result).  "pop rcvr & args, push int result"
	^ 0

]

{ #category : #primitives }
CameraPlugin >> primOpenCamera [
	"Open a camera. Takes one argument, the index of the device to open."

	| cameraNum desiredFrameWidth desiredFrameHeight ok |
	self export: true.

	cameraNum := interpreterProxy stackIntegerValue: 2.
	desiredFrameWidth := interpreterProxy stackIntegerValue: 1.
	desiredFrameHeight := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed ifTrue: [^ 0].

	ok := self cCode: 'CameraOpen(cameraNum, desiredFrameWidth, desiredFrameHeight)'.
	ok = 0 ifTrue: [
		interpreterProxy success: false.
		^ 0].

	interpreterProxy pop: 3.  "pop args, leave rcvr on stack"
	^ 0

]
