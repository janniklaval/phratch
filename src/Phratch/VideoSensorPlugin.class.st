"
These primitives are used to analyze frames from a video camera. Camera images are 32-bit Forms. Analysis results are 8-bit deep forms where each pixel value measures some quantity at the given pixel location (e.g. brightness or the interframe difference).

"
Class {
	#name : #VideoSensorPlugin,
	#superclass : #InterpreterPlugin,
	#category : #'Phratch-Primitives-Plugins'
}

{ #category : #operations }
VideoSensorPlugin class >> brightnessMap: bitmap32 to: bitmap8 [
	"Map the brightness (max of RGB) of each pixel in a 32-bit bitmap to an 8-bit grayscale level in an 8-bit bitmap with the same number of pixels. Fail if the number of pixels is not a multiple of 4 or if two bitmaps are not the same number of pixels."

	<primitive: 'primBrightnessMap' module: 'VideoSensorPlugin'>

	self assert: [(bitmap32 size \\ 4) = 0].
	self assert: [bitmap32 size = (4 * bitmap8 size)].
	^ self primitiveFailed


]

{ #category : #operations }
VideoSensorPlugin class >> customMap32: bitmap32 to8: bitmap8 width: width p1: int1 p2: int2 p3: int3 [
	"Map each 32-bit RGB pixel value to an 8-bit grayscale level in an 8-bit bitmap with the same number of pixels. Fail if the number of pixels is not a multiple of 4 or if the two bitmaps have different numbers of pixels."

	<primitive: 'primCustom32to8' module: 'VideoSensorPlugin'>

	self assert: [(bitmap32 size \\ 4) = 0].
	self assert: [bitmap32 size = (4 * bitmap8 size)].
	^ self primitiveFailed

]

{ #category : #operations }
VideoSensorPlugin class >> customMap8: inBitmap8 to8: outBitmap8 width: width p1: int1 p2: int2 p3: int3 [
	"Map each input 8-bit pixel value to an 8-bit pixel value in an output bitmap with the same number of pixels. Fail if the number of pixels is not a multiple of 4 or if the two bitmaps have different numbers of pixels."

	<primitive: 'primCustom8to8' module: 'VideoSensorPlugin'>

	self assert: [inBitmap8 size \\ 4 = 0].
	self assert: [inBitmap8 size = outBitmap8 size].
	^ self primitiveFailed


]

{ #category : #operations }
VideoSensorPlugin class >> customMap8toInt: inBitmap8 width: width p1: int1 p2: int2 p3: int3 [
	"Analyze an 8-bit bitmap and return an integer value. This might be used, for example, to find the packed (x,y) center of some feature in the image. Fail if the number of pixels is not a multiple of 4."

	<primitive: 'primCustom8toInt' module: 'VideoSensorPlugin'>

	self assert: [inBitmap8 size \\ 4 = 0].
	^ self primitiveFailed


]

{ #category : #translation }
VideoSensorPlugin class >> declareCVarsIn: aCCodeGenerator [
	"self translate"

	super declareCVarsIn: aCCodeGenerator.
	aCCodeGenerator cExtras: '
void VideoSensorBrightnessMap(unsigned char* pBits32, unsigned char* pBits8, int pixCount);
void VideoSensorDifferenceMap(unsigned char* pBits32A, unsigned char* pBits32B, unsigned char* pBits8, int pixCount);
void VideoSensorCustom32to8(unsigned char* pBits32, unsigned char* pBits8, int pixCount, int width, int p1, int p2, int p3);
void VideoSensorCustom8to8(unsigned char* pBits8In, unsigned char* pBits8Out, int pixCount, int width, int p1, int p2, int p3);
int VideoSensorCustom8toInt(unsigned char* pBits8, int pixCount, int width, int p1, int p2, int p3);
void VideoSensorMotionHistoryMap(
	unsigned char* pBits32A, unsigned char* pBits32B, unsigned char* pBits8,
	int pixCount, int threshold, int historyCount);
int VideoSensorTrackColor(
	unsigned char* pBits32, int pixCount, int width, int rgb, int threshold);
'.
]

{ #category : #operations }
VideoSensorPlugin class >> differenceMap: bitmap32a and: bitmap32b to: bitmap8 [
	"Map the pixel by pixel difference (max of RGB diffs) between two 32-bit bitmap to an 8-bit grayscale level in an 8-bit bitmap with the same number of pixels. Fail if the number of pixels is not a multiple of 4 or if the three bitmaps are not the same number of pixels."

	<primitive: 'primDifferenceMap' module: 'VideoSensorPlugin'>

	self assert: [(bitmap32a size \\ 4) = 0].
	self assert: [bitmap32a size = bitmap32b size].
	self assert: [bitmap32a size = (4 * bitmap8 size)].
	^ self primitiveFailed


]

{ #category : #operations }
VideoSensorPlugin class >> motionHistoryMap: bitmap32a and: bitmap32b to: bitmap8 threshold: threshold historyCount: historyCount [
	"Map the pixel by pixel motion (motion detected if the max of RGB diffs >= threshold) between two 32-bit bitmaps into an 8-bit deep 'history map' of the motion. The value of each pixel in the history map reflects how recently motion occurred at that location. It it set to historyCount when motion occurs and decremented on each subsequent call that no motion occurs."

	<primitive: 'primMotionHistoryMap' module: 'VideoSensorPlugin'>

	self assert: [(bitmap32a size \\ 4) = 0].
	self assert: [bitmap32a size = bitmap32b size].
	self assert: [bitmap32a size = (4 * bitmap8 size)].
	^ self primitiveFailed


]

{ #category : #operations }
VideoSensorPlugin class >> motionHistoryTest [
	"A quick test of the motion history map feature. Displays video on the screen until the mouse is pressed."
	"self motionHistoryTest"

	| f fHist fPrev n startTime frameCount msecs fps fTmp |
	CameraPlugin openCamera: 1 width: 320 height: 240.
	(CameraPlugin frameExtent: 1) x = 0 ifTrue: [^ self inform: 'no camera'].
	f := Form extent: (CameraPlugin frameExtent: 0) depth: 32.
	fHist := ColorForm extent: (CameraPlugin frameExtent: 0) depth: 8.
	fHist colors: (Array with: Color transparent), (Array new: 255 withAll: Color blue).
	frameCount := 0.
	startTime := nil.
	[Sensor anyButtonPressed] whileFalse: [
		n := CameraPlugin getFrameForCamera: 1 into: f bits.
		n > 0 ifTrue: [
			startTime ifNil: [startTime := Time millisecondClockValue. fPrev := f deepCopy].
			frameCount := frameCount + 1.
			VideoSensorPlugin motionHistoryMap: f bits and: fPrev bits to: fHist bits threshold: 40 historyCount: 8.
			f display.
			fHist display.
			fTmp := f. f := fPrev. fPrev := fTmp]].
	msecs := Time millisecondClockValue - startTime.
	CameraPlugin closeCamera: 1.
	fps := (frameCount * 1000) // msecs.
	Sensor waitNoButton.
	self inform: frameCount printString, ' frames at ', fps printString, ' frames/sec'.
]

{ #category : #operations }
VideoSensorPlugin class >> primitiveTrackColorIn: bitmap32 width: width rgb: rgb threshold: threshold [
	"Track the given RGB value in a 32-bit bitmap and answer a non-negative integer representing the packed (x,y) point at the center of the tracked object (15 bits each for x and y). Answer -1 if the tracked object is not found."

	<primitive: 'primTrackColor' module: 'VideoSensorPlugin'>
	^ self primitiveFailed

]

{ #category : #operations }
VideoSensorPlugin class >> primitiveTrackIn: bitmap32 width: width rgb: rgb threshold: threshold [
	"Track the given RGB value in a 32-bit bitmap and answer a non-negative integer representing the packed (x,y) point at the center of the tracked object (15 bits each for x and y). Answer -1 if the tracked object is not found."

	<primitive: 'primTrackColor' module: 'VideoSensorPlugin'>
	^ self primitiveFailed

]

{ #category : #operations }
VideoSensorPlugin class >> trackColorIn: bitmap32 width: width rgb: rgb threshold: threshold [
	"Answer a Point giving the location of an object of the given color or nil if no object of that color is found in the given bitmap."

	| packed |
	packed := self primitiveTrackColorIn: bitmap32 width: width rgb: rgb threshold: threshold.
	packed < 0 ifTrue: [^ nil].
	^ ((packed bitShift: -15) bitAnd: 16r7FFF) @ (packed bitAnd: 16r7FFF)

]

{ #category : #primitives }
VideoSensorPlugin >> primBrightnessMap [
	"Map the brightness (max of RGB) of each pixel in a 32-bit bitmap to an 8-bit grayscale level in an 8-bit bitmap with the same number of pixels. Fail if the number of pixels is not a multiple of 4 or if two bitmaps are not the same number of pixels."

	| bitmap32Oop bitmap8Oop pixCount pBits32 pBits8 |
	self export: true.
	self var: 'pBits32' declareC: 'unsigned char *pBits32'.
	self var: 'pBits8' declareC: 'unsigned char *pBits8'.

	bitmap32Oop := interpreterProxy stackValue: 1.
	bitmap8Oop := interpreterProxy stackValue: 0.
	((interpreterProxy isIntegerObject: bitmap32Oop) or:
	 [(interpreterProxy isWords: bitmap32Oop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	pBits32 := self cCoerce: (interpreterProxy firstIndexableField: bitmap32Oop) to: 'unsigned char *'.
	pixCount := interpreterProxy stSizeOf: bitmap32Oop.
	interpreterProxy success: ((pixCount bitAnd: 3) = 0).

	((interpreterProxy isIntegerObject: bitmap8Oop) or:
	 [(interpreterProxy isWords: bitmap8Oop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	pBits8 := self cCoerce: (interpreterProxy firstIndexableField: bitmap8Oop) to: 'unsigned char *'.
	interpreterProxy success: (((interpreterProxy stSizeOf: bitmap8Oop) * 4) = pixCount).

	interpreterProxy failed ifTrue: [^ 0].

	self cCode: 'VideoSensorBrightnessMap(pBits32, pBits8, pixCount)'.

	interpreterProxy pop: 2.  "pop args, leave rcvr on stack"
	^ 0


]

{ #category : #primitives }
VideoSensorPlugin >> primCustom32to8 [
	"Map each 32-bit RGB pixel value to an 8-bit grayscale level in an 8-bit bitmap with the same number of pixels. Fail if the number of pixels is not a multiple of 4 or if the two bitmaps have different numbers of pixels."

	| bitmap32Oop bitmap8Oop width p1 p2 p3 pixCount pBits32 pBits8 |
	self export: true.
	self var: 'pBits32' declareC: 'unsigned char *pBits32'.
	self var: 'pBits8' declareC: 'unsigned char *pBits8'.

	bitmap32Oop := interpreterProxy stackValue: 5.
	bitmap8Oop := interpreterProxy stackValue: 4.
	width := interpreterProxy stackIntegerValue: 3.
	p1 := interpreterProxy stackIntegerValue: 2.
	p2 := interpreterProxy stackIntegerValue: 1.
	p3 := interpreterProxy stackIntegerValue: 0.

	((interpreterProxy isIntegerObject: bitmap32Oop) or:
	 [(interpreterProxy isWords: bitmap32Oop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	pBits32 := self cCoerce: (interpreterProxy firstIndexableField: bitmap32Oop) to: 'unsigned char *'.
	pixCount := interpreterProxy stSizeOf: bitmap32Oop.
	interpreterProxy success: ((pixCount bitAnd: 3) = 0).

	((interpreterProxy isIntegerObject: bitmap8Oop) or:
	 [(interpreterProxy isWords: bitmap8Oop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	pBits8 := self cCoerce: (interpreterProxy firstIndexableField: bitmap8Oop) to: 'unsigned char *'.
	interpreterProxy success: (((interpreterProxy stSizeOf: bitmap8Oop) * 4) = pixCount).

	interpreterProxy failed ifTrue: [^ 0].

	self cCode: 'VideoSensorCustom32to8(pBits32, pBits8, pixCount, width, p1, p2, p3)'.

	interpreterProxy pop: 6.  "pop args, leave rcvr on stack"
	^ 0


]

{ #category : #primitives }
VideoSensorPlugin >> primCustom8to8 [
	"Map each input 8-bit pixel value to an 8-bit pixel value in an output bitmap with the same number of pixels. Fail if the number of pixels is not a multiple of 4 or if the two bitmaps have different numbers of pixels."

	| inBitmapOop outBitmapOop width p1 p2 p3 pixCount pBits8In pBits8Out |
	self export: true.
	self var: 'pBits8In' declareC: 'unsigned char *pBits8In'.
	self var: 'pBits8Out' declareC: 'unsigned char *pBits8Out'.

	inBitmapOop := interpreterProxy stackValue: 5.
	outBitmapOop := interpreterProxy stackValue: 4.
	width := interpreterProxy stackIntegerValue: 3.
	p1 := interpreterProxy stackIntegerValue: 2.
	p2 := interpreterProxy stackIntegerValue: 1.
	p3 := interpreterProxy stackIntegerValue: 0.

	((interpreterProxy isIntegerObject: inBitmapOop) or:
	 [(interpreterProxy isWords: inBitmapOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	pBits8In := self cCoerce: (interpreterProxy firstIndexableField: inBitmapOop) to: 'unsigned char *'.
	pixCount := 4 * (interpreterProxy stSizeOf: inBitmapOop).

	((interpreterProxy isIntegerObject: outBitmapOop) or:
	 [(interpreterProxy isWords: outBitmapOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	pBits8Out := self cCoerce: (interpreterProxy firstIndexableField: outBitmapOop) to: 'unsigned char *'.
	interpreterProxy success: ((4 * (interpreterProxy stSizeOf: outBitmapOop)) = pixCount).

	interpreterProxy failed ifTrue: [^ 0].

	self cCode: 'VideoSensorCustom8to8(pBits8In, pBits8Out, pixCount, width, p1, p2, p3)'.

	interpreterProxy pop: 6.  "pop args, leave rcvr on stack"
	^ 0


]

{ #category : #primitives }
VideoSensorPlugin >> primCustom8toInt [
	"Analyze an 8-bit bitmap and return an integer value. This might be used, for example, to find the packed (x,y) center of some feature in the image. Fail if the number of pixels is not a multiple of 4."

	| inBitmapOop width p1 p2 p3 pBits8 pixCount result |
	self export: true.
	self var: 'pBits8' declareC: 'unsigned char *pBits8'.

	inBitmapOop := interpreterProxy stackValue: 4.
	width := interpreterProxy stackIntegerValue: 3.
	p1 := interpreterProxy stackIntegerValue: 2.
	p2 := interpreterProxy stackIntegerValue: 1.
	p3 := interpreterProxy stackIntegerValue: 0.

	((interpreterProxy isIntegerObject: inBitmapOop) or:
	 [(interpreterProxy isWords: inBitmapOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	pBits8 := self cCoerce: (interpreterProxy firstIndexableField: inBitmapOop) to: 'unsigned char *'.
	pixCount := 4 * (interpreterProxy stSizeOf: inBitmapOop).

	interpreterProxy failed ifTrue: [^ 0].

	result := self cCode: 'VideoSensorCustom8toInt(pBits8, pixCount, width, p1, p2, p3)'.

	interpreterProxy pop: 6 thenPush: (interpreterProxy integerObjectOf: result).  "pop args and rcvr, push int result"
	^ 0


]

{ #category : #primitives }
VideoSensorPlugin >> primDifferenceMap [
	"Map the pixel by pixel difference (max of RGB diffs) between two 32-bit bitmap to an 8-bit grayscale level in an 8-bit bitmap with the same number of pixels. Fail if the number of pixels is not a multiple of 4 or if the three bitmaps are not the same number of pixels."

	| bitmap32AOop bitmap32BOop bitmap8Oop pixCount pBits32A pBits32B pBits8 |
	self export: true.
	self var: 'pBits32A' declareC: 'unsigned char *pBits32A'.
	self var: 'pBits32B' declareC: 'unsigned char *pBits32B'.
	self var: 'pBits8' declareC: 'unsigned char *pBits8'.

	bitmap32AOop := interpreterProxy stackValue: 2.
	bitmap32BOop := interpreterProxy stackValue: 1.
	bitmap8Oop := interpreterProxy stackValue: 0.

	((interpreterProxy isIntegerObject: bitmap32AOop) or:
	 [(interpreterProxy isWords: bitmap32AOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	pBits32A := self cCoerce: (interpreterProxy firstIndexableField: bitmap32AOop) to: 'unsigned char *'.
	pixCount := interpreterProxy stSizeOf: bitmap32AOop.
	interpreterProxy success: ((pixCount bitAnd: 3) = 0).

	((interpreterProxy isIntegerObject: bitmap32BOop) or:
	 [(interpreterProxy isWords: bitmap32BOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	pBits32B := self cCoerce: (interpreterProxy firstIndexableField: bitmap32BOop) to: 'unsigned char *'.
	interpreterProxy success: ((interpreterProxy stSizeOf: bitmap32BOop) = pixCount).

	((interpreterProxy isIntegerObject: bitmap8Oop) or:
	 [(interpreterProxy isWords: bitmap8Oop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	pBits8 := self cCoerce: (interpreterProxy firstIndexableField: bitmap8Oop) to: 'unsigned char *'.
	interpreterProxy success: (((interpreterProxy stSizeOf: bitmap8Oop) * 4) = pixCount).

	interpreterProxy failed ifTrue: [^ 0].

	self cCode: 'VideoSensorDifferenceMap(pBits32A, pBits32B, pBits8, pixCount)'.

	interpreterProxy pop: 3.  "pop args, leave rcvr on stack"
	^ 0


]

{ #category : #primitives }
VideoSensorPlugin >> primMotionHistoryMap [
	"First, compute the pixel-by-pixel difference (max of RGB diffs) between two 32-bit bitmaps. If this differences is over the given threshold, set the corresponding pixel value in the 8-bit history bitmap to the historyCount parameter. Otherwise, decrement the current history value at that location, unless it is already zero. The result of this is that the history bitmap 'remembers' motion that has occurred over the past historyCount frames."
	"Note: the three input bitmaps must have the same number of pixels. The width of the bitmaps should be a multiple of four."

	| bitmap32AOop bitmap32BOop bitmap8Oop threshold historyCount pixCount pBits32A pBits32B pBits8 |
	self export: true.
	self var: 'pBits32A' declareC: 'unsigned char *pBits32A'.
	self var: 'pBits32B' declareC: 'unsigned char *pBits32B'.
	self var: 'pBits8' declareC: 'unsigned char *pBits8'.

	bitmap32AOop := interpreterProxy stackValue: 4.
	bitmap32BOop := interpreterProxy stackValue: 3.
	bitmap8Oop := interpreterProxy stackValue: 2.
	threshold := interpreterProxy stackIntegerValue: 1.
	historyCount := interpreterProxy stackIntegerValue: 0.

	((interpreterProxy isIntegerObject: bitmap32AOop) or:
	 [(interpreterProxy isWords: bitmap32AOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	pBits32A := self cCoerce: (interpreterProxy firstIndexableField: bitmap32AOop) to: 'unsigned char *'.
	pixCount := interpreterProxy stSizeOf: bitmap32AOop.
	interpreterProxy success: ((pixCount bitAnd: 3) = 0).

	((interpreterProxy isIntegerObject: bitmap32BOop) or:
	 [(interpreterProxy isWords: bitmap32BOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	pBits32B := self cCoerce: (interpreterProxy firstIndexableField: bitmap32BOop) to: 'unsigned char *'.
	interpreterProxy success: ((interpreterProxy stSizeOf: bitmap32BOop) = pixCount).

	((interpreterProxy isIntegerObject: bitmap8Oop) or:
	 [(interpreterProxy isWords: bitmap8Oop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	pBits8 := self cCoerce: (interpreterProxy firstIndexableField: bitmap8Oop) to: 'unsigned char *'.
	interpreterProxy success: (((interpreterProxy stSizeOf: bitmap8Oop) * 4) = pixCount).

	interpreterProxy failed ifTrue: [^ 0].

	self cCode: 'VideoSensorMotionHistoryMap(pBits32A, pBits32B, pBits8, pixCount, threshold, historyCount)'.

	interpreterProxy pop: 5.  "pop args, leave rcvr on stack"
	^ 0


]

{ #category : #primitives }
VideoSensorPlugin >> primTrackColor [
	"Compute the center of the largest area of pixels close to a particular color. The result is a packed positive integer with 15 bits for the x and y components or -1 if the tracked color is not found in the image."

	| bitmapOop width rgb threshold pBits32 pixCount result |
	self export: true.
	self var: 'pBits32' declareC: 'unsigned char *pBits32'.

	bitmapOop := interpreterProxy stackValue: 3.
	width := interpreterProxy stackIntegerValue: 2.
	rgb := interpreterProxy stackIntegerValue: 1.
	threshold := interpreterProxy stackIntegerValue: 0.

	((interpreterProxy isIntegerObject: bitmapOop) or:
	 [(interpreterProxy isWords: bitmapOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	pBits32 := self cCoerce: (interpreterProxy firstIndexableField: bitmapOop) to: 'unsigned char *'.
	pixCount := interpreterProxy stSizeOf: bitmapOop.

	interpreterProxy failed ifTrue: [^ 0].

	result := self cCode: 'VideoSensorTrackColor(pBits32, pixCount, width, rgb, threshold)'.

	interpreterProxy pop: 5 thenPush: (interpreterProxy integerObjectOf: result).  "pop args and rcvr, push int result"
	^ 0

]
