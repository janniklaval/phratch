"
I am a Scratch movie media object. I hold the state and the current frame of a movie costume for a Scratch object.

"
Class {
	#name : #MovieMedia,
	#superclass : #PhratchMedia,
	#instVars : [
		'fileName',
		'fade',
		'fadeColor',
		'zoom',
		'hPan',
		'vPan',
		'msecsPerFrame',
		'currentFrame',
		'moviePlaying',
		'movieFile',
		'sound',
		'origForm',
		'outForm',
		'appearanceChanged',
		'lastFrameMSecs'
	],
	#category : #'Phratch-Objects'
}

{ #category : #private }
MovieMedia >> advanceFrameWithSound [
	"Used in the step method when a movie that has sound is playing."

	| syncMSecs msecs desiredFrame currFrame |
	sound isPlaying ifFalse: [^ self startPlaying].  "loop back to beginning"

	syncMSecs := -70.  "fudge factor to get better sound/video sync"
	msecs := sound millisecondsSinceStart - SoundPlayer bufferMSecs + syncMSecs.
	desiredFrame := (msecs // msecsPerFrame) + 1.
	desiredFrame := desiredFrame min: (movieFile videoFrames: 0).
	currFrame := movieFile videoGetFrame: 0.
	desiredFrame = currFrame ifFalse: [self showFrame: desiredFrame].

]

{ #category : #'file ops' }
MovieMedia >> basicLoadFile: fullName [
	"Load an image or movie from the file with the given name. If the movie has sound, this intializes the sound as well."

	| extension sndIcon |
	( fullName) exists
		ifFalse: [^ self inform: 'File not found: ', fullName].

	self closeMovieFile.
	extension := ((fullName) extension) asLowercase.

"	((extension = 'jmv') and:
	 [JPEGMovieFile isJPEGMovieFile: fullName]) ifTrue: [
		movieFile := JPEGMovieFile new openFileNamed: fullName.
		movieFile hasAudio ifTrue: [
			sound := movieFile audioPlayerForChannel: 1]]."
	
	((#('mpg' 'mpeg' 'mp3') includes: extension) and:
	 [MPEGFile isFileValidMPEG: fullName]) ifTrue: [
		movieFile := MPEGFile openFile: fullName.
		movieFile hasAudio ifTrue: [
			sound := movieFile audioPlayerForChannel: 1]].

	movieFile ifNotNil: [
		movieFile hasVideo
			ifTrue: [
				origForm := Form
					extent: (movieFile videoFrameWidth: 0)@(movieFile videoFrameHeight: 0)
					depth: (Display depth max: 16)]
			ifFalse: [  "audio only"
				msecsPerFrame := 10000.
				origForm := (Form extent: 32@24 depth: 4) fillColor: Color blue.
				sndIcon := PhratchFrameMorph skinAt: #scratchSound.
				sndIcon displayOn: origForm at: (origForm extent - sndIcon extent) // 2.
				sound ifNil: ["no audio either! close the file"
					movieFile closeFile.
					movieFile := nil]].
		outForm := origForm deepCopy.
		fileName := fullName.
		^ self].

	"if not a movie, try to open image file"
	origForm := Form fromFileNamed: fullName.
	outForm := origForm deepCopy.
	fileName := fullName.

]

{ #category : #'file ops' }
MovieMedia >> closeMovieFile [

	movieFile ifNotNil: [movieFile closeFile].
	sound ifNotNil: [sound pause].
	movieFile := nil.
	sound := nil.

	origForm := (Form extent: 8@8 depth: 4) fillColor: Color lightGray.
	outForm := origForm deepCopy.
	self updateOutForm.

]

{ #category : #private }
MovieMedia >> currentFrame: frameIndex [

	| proportion |
	(self movieFileIsOpen and: [movieFile hasVideo]) ifFalse: [^ self].
	proportion := ((frameIndex / self frameCount) max: 0.0) min: 1.0.
	self currentSeconds: proportion * (movieFile duration: 1).

]

{ #category : #'movie ops' }
MovieMedia >> currentSeconds: seconds [
	"Jump to the given seconds offset."

	| fraction totalFrames totalSecs |
	sound
		ifNotNil: [ 
			fraction := (seconds asFloat / sound duration max: 0.0) min: 1.0.
			sound soundPosition: seconds asFloat / sound duration ].
	(movieFile notNil and: [ movieFile hasVideo ])
		ifTrue: [ 
			totalFrames := movieFile videoFrames: 0.
			fraction
				ifNil: [ 
					totalSecs := totalFrames asFloat / (movieFile videoFrameRate: 0).
					fraction := totalSecs > 0
						ifTrue: [ seconds / totalSecs ]
						ifFalse: [ 0 ] ].
			self showFrame: fraction * totalFrames ].
	lastFrameMSecs := Time millisecondClockValue
]

{ #category : #accessing }
MovieMedia >> fade [
	"Answer my fade, a number between 0 and 100."

	^ fade

]

{ #category : #accessing }
MovieMedia >> fadeColor [

	^ fadeColor

]

{ #category : #'object i/o' }
MovieMedia >> fieldsVersion [

	^ 1

]

{ #category : #accessing }
MovieMedia >> fileName [

	^ fileName

]

{ #category : #accessing }
MovieMedia >> form [

	^ outForm

]

{ #category : #'movie ops' }
MovieMedia >> frameCount [

	movieFile ifNil: [^ 1].
	(self movieFileIsOpen and: [movieFile hasVideo])
		ifTrue: [^ movieFile videoFrames: 0]
		ifFalse: [^ 1].

]

{ #category : #accessing }
MovieMedia >> hPan [

	^ hPan

]

{ #category : #accessing }
MovieMedia >> infoString [
	"Answer a string for this media, typically something about its size."

	^ self totalSeconds hhmmss

]

{ #category : #'object i/o' }
MovieMedia >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		fileName
		fade
		fadeColor
		zoom
		hPan
		vPan
		msecsPerFrame
		currentFrame
		moviePlaying
	) from: anObjStream.
	self openAfterLoad.

]

{ #category : #initialization }
MovieMedia >> initialize [

	super initialize.
	fileName := ''.
	movieFile := nil.
	fade := 100.
	fadeColor := Color black.
	zoom := 100.
	hPan := 0.
	vPan := 0.
	msecsPerFrame := 100.
	currentFrame := 1.
	moviePlaying := false.
	movieFile := nil.
	sound := nil.
	origForm := (Form extent: 8@8 depth: 4) fillColor: Color lightGray.
	outForm := origForm deepCopy.

]

{ #category : #accessing }
MovieMedia >> isMovie [

	^ true

]

{ #category : #'movie ops' }
MovieMedia >> isPlaying [

	sound ifNotNil: [moviePlaying := sound isPlaying].
	^ moviePlaying

]

{ #category : #'file ops' }
MovieMedia >> loadFile: relativeFilePath [
	"Load an image or movie from the file with the given name. If the movie has sound, this intializes the sound as well."

	self basicLoadFile: relativeFilePath.	"reset fade, pan, zoom, and sound"
	fade := 100.
	zoom := 100.
	hPan := vPan := 0.	"set frame rate"
	movieFile
		ifNotNil: [ 
			msecsPerFrame := movieFile hasVideo
				ifTrue: [ 1000.0 / (movieFile videoFrameRate: 0) ]
				ifFalse: [ 1000 ] ].	"audio only"
	outForm := origForm deepCopy.
	self showFrame: 1
]

{ #category : #stepping }
MovieMedia >> mediaStep [

	appearanceChanged := false.
	self step.
	^ appearanceChanged


]

{ #category : #accessing }
MovieMedia >> mediaType [
	"Answer a string describing this type of media."

	^ 'movie'

]

{ #category : #private }
MovieMedia >> movieFileIsOpen [
	"Answer true if I have an open movie file. If movie is not nil but is not currently open, try to reopen it."

	movieFile ifNil: [^ false].
	movieFile fileHandle ifNil: [
		"try to reopen the file:"
		movieFile := nil.
		self basicLoadFile: fileName].

	^ movieFile notNil

]

{ #category : #'file ops' }
MovieMedia >> openAfterLoad [
	"Attempt to re-open my file. Do nothing if the file is not found."

	| fullName |
	fullName := self projectDirectory , fileName.
	(fullName exists) ifFalse: [^ self].

	[self basicLoadFile: fileName] ifError: [^ self].
	self currentFrame: currentFrame.
	self updateOutForm.  "update output form for still images"

]

{ #category : #'file ops' }
MovieMedia >> projectDirectory [

	^ FileSystem workingDirectory

]

{ #category : #private }
MovieMedia >> renderingChanged [
	"Update my output form after changing a rendering parameter. If the movie is playing at a fairly high frame rate, do nothing because the next frame will be displayed shortly."

	(moviePlaying and: [msecsPerFrame < 100]) ifTrue: [^ self].  "next frame will be drawn soon"
	self updateOutForm.

]

{ #category : #'movie ops' }
MovieMedia >> resumePlaying [
	"This method is called when switching costumes. If I was playing when I was switched out, resume playing."

	moviePlaying
		ifFalse: [ ^ self ].
	moviePlaying := false.
	self startPlaying
]

{ #category : #accessing }
MovieMedia >> rotationCenter [
	"Answer my center."

	^ outForm extent // 2

]

{ #category : #accessing }
MovieMedia >> rotationCenter: ignored [
	"Do nothing; my rotation center is always the center of the movie frame."

]

{ #category : #private }
MovieMedia >> showFrame: frameIndex [
	"Go to the given frame.  updates only video, not sound."

	self movieFileIsOpen ifFalse: [^ self].
	movieFile hasVideo ifFalse: [^ self].
	currentFrame := frameIndex rounded max: 1.
	movieFile videoSetFrame: currentFrame stream: 0.
	movieFile videoReadFrameInto: origForm stream: 0.
	self updateOutForm.

]

{ #category : #accessing }
MovieMedia >> sound [

	^ sound

]

{ #category : #'movie ops' }
MovieMedia >> startPlaying [
	| frameIndex |
	self isPlaying
		ifTrue: [ ^ self ].
	self stopPlaying.
	movieFile isNil
		ifTrue: [ ^ self ].
	movieFile hasAudio
		ifTrue: [ 
			movieFile hasVideo
				ifTrue: [ 
					currentFrame >= (self frameCount - 3)
						ifTrue: [ 
							"start over if very close to end"
							currentFrame := 1 ].
					sound reset.
					sound soundPosition: currentFrame / self frameCount.
					frameIndex := sound millisecondsSinceStart // msecsPerFrame.	"MPEGFile plugin can crash on seeks to last few frames, so limit max frameIndex:"
					frameIndex := (frameIndex max: 1) min: (movieFile videoFrames: 0) - 3.
					movieFile videoSetFrame: frameIndex - 1 stream: 0.
					self showFrame: frameIndex ].
			SoundPlayer stopReverb.
			sound resumePlaying ]
		ifFalse: [ 
			movieFile hasVideo
				ifTrue: [ 
					frameIndex := (currentFrame max: 0) min: (movieFile videoFrames: 0) - 3.
					movieFile videoSetFrame: frameIndex stream: 0 ].
			sound := nil ].
	lastFrameMSecs := Time millisecondClockValue.
	moviePlaying := true
]

{ #category : #stepping }
MovieMedia >> step [
	"If I have a movie file and it is playing, advance to the next frame if it is time."

	| now deltaT newFrame |
	moviePlaying
		ifFalse: [ ^ self ].
	self movieFileIsOpen
		ifFalse: [ 
			moviePlaying := false.
			^ self ].
	movieFile hasVideo
		ifFalse: [ ^ self ].	"no video"
	sound ifNotNil: [ ^ self advanceFrameWithSound ].	"sync frame rate to sound"
	now := Time millisecondClockValue.
	deltaT := now - lastFrameMSecs.
	(deltaT < 0 or: [ deltaT >= msecsPerFrame ])
		ifFalse: [ ^ self ].
	newFrame := currentFrame + (deltaT // msecsPerFrame).
	newFrame > self frameCount
		ifTrue: [ newFrame := 1 ].
	self showFrame: newFrame.
	lastFrameMSecs := now
]

{ #category : #'movie ops' }
MovieMedia >> stopPlaying [

	sound ifNotNil: [sound pause].
	moviePlaying := false.

]

{ #category : #'object i/o' }
MovieMedia >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		fileName
		fade
		fadeColor
		zoom
		hPan
		vPan
		msecsPerFrame
		currentFrame
		moviePlaying
	) on: anObjStream.

]

{ #category : #'movie ops' }
MovieMedia >> suspendPlaying [
	"This method is called when switching costumes. Stop playing, but leave the moviePlaying flag alone."

	| tmp |
	tmp := moviePlaying.
	self stopPlaying.
	moviePlaying := tmp.


]

{ #category : #accessing }
MovieMedia >> thumbnailFormExtent: extent [
	"Answer a Form of the given extent containing a thumbnail of me."

	| f scale shrunk icon |
	f := (ColorForm extent: extent depth: 16) fillWhite.
	self movieFileIsOpen ifFalse: [^ f].

	movieFile hasVideo ifTrue: [
		movieFile videoSetFrame: 1 stream: 0.
		movieFile videoReadFrameInto: origForm stream: 0.
		scale := (f width / origForm width) min: (f height / origForm height).
		shrunk := origForm magnify: origForm boundingBox by: scale smoothing: 2.
		shrunk displayOn: f at: (f extent - shrunk extent) // 2 rule: Form paint.
		^ f].

	movieFile hasAudio ifTrue: [
		icon := PhratchFrameMorph skinAt: #scratchSound.
		icon displayOn: f at: (f extent - icon extent) // 2 rule: Form paint].

	^ f

]

{ #category : #'movie ops' }
MovieMedia >> totalSeconds [

	movieFile ifNil: [^ 0].
	self movieFileIsOpen ifFalse: [^ 0].
	^ movieFile duration: 0

]

{ #category : #private }
MovieMedia >> updateOutForm [
	"Update my output form."

	| srcRect |
	appearanceChanged := true.
	origForm ifNil: [^ self].  "do nothing during initialization"
	((zoom = 100) & (hPan = 0) & (vPan = 0) and:
	 [outForm extent = origForm extent])
		ifTrue: [  "optimization: no scaling"
			origForm displayOn: outForm]
		ifFalse: [  "scaling needed"
			srcRect := Rectangle
				center: (origForm boundingBox center + (hPan@vPan negated))
				extent: (origForm extent / (zoom asFloat / 100.0)).

			(WarpBlt toForm: outForm)
				sourceForm: origForm;
				colorMap: (origForm colormapIfNeededForDepth: outForm depth);
				cellSize: 1;  "installs a colormap"
				combinationRule: Form over;
				copyQuad: srcRect innerCorners toRect: outForm boundingBox].

	fade < 100 ifTrue: [  "handle fade"
		(BitBlt toForm: outForm)
			destRect: outForm boundingBox;
			fillColor: fadeColor;
			combinationRule: 30;
			copyBitsTranslucent: (2.55 * (100 - fade)) truncated]
ifFalse: [  "workaround to show black around edges when zoomed"
	(BitBlt toForm: outForm)
		destRect: outForm boundingBox;
		fillColor: Color black;
		combinationRule: 30;
		copyBitsTranslucent: 1]. 

	self changed.

]

{ #category : #accessing }
MovieMedia >> vPan [

	^ vPan

]

{ #category : #accessing }
MovieMedia >> zoom [
	"Answer my zoom. 100 is normal size, 200 is double size, 50 is half size."

	^ zoom

]

{ #category : #accessing }
MovieMedia >> zoom: aNumber [
	"Set my movie zoom. 100 is normal size. Values greater than 100 magnify or zoom in; values less than 100 shrink the movie within the frame."

	| newZoom |
	newZoom := (aNumber truncated min: 2000) max: 1.
	newZoom = zoom
		ifTrue: [ ^ self ].
	zoom := newZoom.
	self renderingChanged
]
