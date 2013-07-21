Class {
	#name : #CameraMedia,
	#superclass : #PhratchMedia,
	#instVars : [
		'cameraNum',
		'frameExtent',
		'frameForm',
		'prevFrameForm',
		'historyForm'
	],
	#category : #'Phratch-Objects'
}

{ #category : #playing }
CameraMedia >> colorTrackStep [

	| p |
	p := frameForm extent // 2.

	frameForm fill: (p - (15@3) extent: 30@6) fillColor: Color yellow.
	frameForm fill: (p - (3@15) extent: 6@30) fillColor: Color yellow.

]

{ #category : #accessing }
CameraMedia >> compositeForm [

	^ self form

]

{ #category : #private }
CameraMedia >> ensureCameraOpen [
	"Try to open a camera. Do nothing if the camera is already open. Set cameraNum to -1 if no camera is available."

	| i |
	((cameraNum > 0) and: [CameraPlugin cameraIsOpen: cameraNum]) ifTrue: [^ self].

	frameForm := nil.
	cameraNum := -1.
	i := 1.
	[(i <= 8) and: [cameraNum < 0]] whileTrue: [
		(CameraPlugin cameraName: i) ifNotNil: [
			(CameraPlugin openCamera: i width: frameExtent x height: frameExtent y) ifNotNil: [
				frameForm := Form extent: (CameraPlugin frameExtent: i) depth: 32.
				frameExtent := frameForm extent.
				(Delay forMilliseconds: 400) wait.
				cameraNum := i]].
		i := i + 1].

]

{ #category : #accessing }
CameraMedia >> form [

	frameForm ifNotNil: [^ frameForm].
	^ (Form extent: frameExtent depth: 2) fillColor: Color gray

]

{ #category : #accessing }
CameraMedia >> frameExtent [
	^ frameExtent

]

{ #category : #accessing }
CameraMedia >> frameExtent: aPoint [

	frameExtent := aPoint.

]

{ #category : #accessing }
CameraMedia >> infoString [

	^ frameForm
		ifNil: ['not open']
		ifNotNil: [frameForm width printString, 'x', frameForm height printString]

]

{ #category : #initialization }
CameraMedia >> initialize [

	super initialize.
	mediaName := 'camera'.
	cameraNum := -1.
	frameExtent := 320@240.
	frameForm := nil.

]

{ #category : #accessing }
CameraMedia >> isMovie [
	"Pretend to be a movie."

	^ true

]

{ #category : #accessing }
CameraMedia >> mediaName: aString [
	"Do nothing."

]

{ #category : #playing }
CameraMedia >> mediaStep [
	"Make sure the camera is open, if possible, then get the next frame. Answer true if successful."

	| n |
	self ensureCameraOpen.
	cameraNum < 0 ifTrue: [^ false].  "no camera"

	n := CameraPlugin getFrameForCamera: cameraNum into: frameForm bits.
	n = 0 ifTrue: [^ false].  "no new frame"

	PhratchFrameMorph cameraMode = #motion ifTrue: [self motionStep].
	PhratchFrameMorph cameraMode = #colorTrack ifTrue: [self colorTrackStep].

	^ n ~~ 0

]

{ #category : #accessing }
CameraMedia >> mediaType [
	"Answer a string describing this type of media."

	^ 'camera'

]

{ #category : #playing }
CameraMedia >> motionStep [

	(prevFrameForm isNil or:
	 [prevFrameForm extent ~= frameForm extent]) ifTrue: [
		prevFrameForm := frameForm deepCopy].

	(historyForm isNil or:
	 [historyForm extent ~= frameForm extent]) ifTrue: [
		historyForm := ColorForm extent: frameForm extent depth: 8.
		historyForm colors:
			(Array with: Color transparent), (Array new: 255 withAll: Color blue)].

	"VideoSensorPlugin
		motionHistoryMap: frameForm bits
		and: prevFrameForm
		bits to: historyForm bits
		threshold: 40
		historyCount: 4."

	prevFrameForm bits: frameForm bits copy.  "optimization"
	historyForm displayOn: frameForm at: 0@0 rule: Form paint.

]

{ #category : #accessing }
CameraMedia >> rotationCenter [
	"Answer my center."

	^ frameExtent // 2

]

{ #category : #playing }
CameraMedia >> suspendPlaying [

	cameraNum > 0 ifTrue: [
		CameraPlugin closeCamera: cameraNum.
		frameForm := prevFrameForm := historyForm :=  nil.
		cameraNum := -1].


]

{ #category : #accessing }
CameraMedia >> thumbnailFormExtent: extent [
	"Answer a Form of the given extent containing a thumbnail of me."

	| f scale shrunk |
	f := (ColorForm extent: extent depth: 16) fillColor: Color gray.
	frameForm ifNotNil: [
		scale := (f width / frameForm width) min: (f height / frameForm height).
		shrunk := (frameForm asFormOfDepth: 16) magnify: frameForm boundingBox by: scale smoothing: 1.
		shrunk displayOn: f at: (f extent - shrunk extent) // 2 rule: Form paint].
	^ f

]
