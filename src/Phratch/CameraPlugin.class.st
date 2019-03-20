"
I am the plugin to connect the Camera
"
Class {
	#name : #CameraPlugin,
	#superclass : #Object,
	#category : #'Phratch-Plugins'
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
