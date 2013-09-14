"
This plugin combines a number of primitives needed by Scratch including:

  a. primitives that manipulate 24-bit color images (i.e. 32-bit deep Forms but alpha is ignored)
  b. primitive to open browsers, find the user's documents folder, set the window title and other host OS functions

This plugin includes new serial port primitives, including support for named serial ports. The underlying plugin code can support up to 32 simultaenously open ports.

Port options for Set/GetOption primitives:
  1. baud rate
  2. data bits
  3. stop bits
  4. parity type
  5. input flow control type
  6. output flow control type

Handshake lines (options 20-25 for Set/GetOption primitives):
  20. DTR	(output line)
  21. RTS	(output line)
  22. CTS	(input line)
  23. DSR	(input line)
  24. CD		(input line)
  25. RI		(input line)


"
Class {
	#name : #PhratchPlugin,
	#superclass : #Object,
	#category : #'Phratch-Plugins'
}

{ #category : #'image scale primitives' }
PhratchPlugin class >> halfSize: srcForm into: dstForm srcPoint: srcPoint dstRect: dstRect [
	"Display the source form at half-size onto the destination form at the given location. Use WarpBlt if the fast primitive fails."

	| result srcR |
	srcForm unhibernate.
	dstForm unhibernate.
	result := self primHalfSizeAverage: srcForm bits w: srcForm width h: srcForm height
		into: dstForm bits w: dstForm width h: dstForm height
		srcX: srcPoint x srcY: srcPoint y
		dstX: dstRect left dstY: dstRect top dstW: dstRect width dstH: dstRect height.
	result ifNotNil: [^ self].

	srcR := srcPoint extent: 2 * dstRect extent.
	(WarpBlt toForm: dstForm)
		sourceForm: srcForm;
		combinationRule: Form over;
		clipRect: dstRect;
		cellSize: 2;
		copyQuad: srcR corners toRect: dstRect.

]

{ #category : #'image scale primitives' }
PhratchPlugin class >> primDouble: srcBitmap w: srcWidth h: srcHeight into: dstBitmap w: dstWidth h: dstHeight x: dstX y: dstY [
	"Display the source form at double-size onto the destination form at the given location. Fails if the target rectangle does not fit entirely within the destination form."

	<primitive: 'primitiveDoubleSize' module: #ScratchPlugin>
	self primitiveFailed

]

{ #category : #'image filter primitives' }
PhratchPlugin class >> primFisheye: inBitmap into: outBitmap width: w power: anInteger [
	"Do a fisheye lens transform of the given 32-bit image bitmap by the given power, storing the result in outBitmap. The two bitmaps must be the same size. Power is 0 for no change, > 0 for fisheye, < 0 for black hole effect."

	<primitive: 'primitiveFisheye' module: #ScratchPlugin>
	self primitiveFailed

]

{ #category : #'image scale primitives' }
PhratchPlugin class >> primHalfSizeAverage: srcBits w: srcW h: srcH into: dstBits w: dstW h: dstH srcX: x1 srcY: y1 dstX: x2 dstY: y2 dstW: w dstH: h [
	"Display the source form at half-size onto the destination form at the given location by averaging the colors a 2x2 cell. Does not handle alpha or transparency. Return nil if the target rectangle does not fit entirely within the destination form."

	<primitive: 'primitiveHalfSizeAverage' module: #ScratchPlugin>
	^ nil

]

{ #category : #'OS utilities' }
PhratchPlugin class >> primOpenURL: aString [
	"Open a browser window on the given URL. Do nothing if the primitive fails."
	"self primOpenURL: 'http://www.google.com'"

	<primitive: 'primitiveOpenURL' module: #ScratchPlugin>
	DialogBoxMorph inform: 'Could not open this file' localized
]

{ #category : #'image scale primitives' }
PhratchPlugin class >> primScaleNoFail: srcBitmap w: srcWidth h: srcHeight into: dstBitmap w: dstWidth h: dstHeight [
	"Scale the source form to exactly fit the destination form using bilinear interpolation. Answer nil if I fail."

	<primitive: 'primitiveScale' module: #ScratchPlugin>
	^ nil

]

{ #category : #'OS utilities' }
PhratchPlugin class >> primSetWindowTitle: aString [
	"Set the title of the Phratch window to the given string. Do nothing if the primitive fails."
	"self primSetWindowTitle: 'hello!'"

	<primitive: 'primitiveSetWindowTitle' module: #ScratchPlugin>

]

{ #category : #'image filter primitives' }
PhratchPlugin class >> primShiftBrightness: inBitmap into: outBitmap by: shift [
	"Shift the brightness of all the non-transparent pixels in the given 32-bit image bitmap, storing the result in outBitmap. The shift should be an integer between -100 and 100. The two bitmaps must be the same size."

	<primitive: 'primitiveBrightnessShift' module: #ScratchPlugin>
	self primitiveFailed

]

{ #category : #'image filter primitives' }
PhratchPlugin class >> primShiftHue: inBitmap into: outBitmap byDegrees: shiftDegrees [
	"Shift the hue of all the non-transparent, non-black pixels in the given 32-bit image bitmap, storing the result in outBitmap. The shift should be an integer between -360 and 360. The two bitmaps must be the same size."

	<primitive: 'primitiveHueShift' module: #ScratchPlugin>
	self primitiveFailed.
	^ nil


]

{ #category : #'OS utilities' }
PhratchPlugin class >> primShortToLongPath: aString [
	"Convert the given Windows short-filename path into a long-filename path. On other platforms this primitive will just return the input string."
	"self primShortToLongPath: 'hello!'"

	<primitive: 'primitiveShortToLongPath' module: #ScratchPlugin>
	^ aString

]

{ #category : #'image filter primitives' }
PhratchPlugin class >> primWhirl: inBitmap into: outBitmap width: w angle: anAngle [
	"Whirl all the non-transparent pixels in the given 32-bit image bitmap by the given angle, storing the result in outBitmap. The two bitmaps must be the same size."

	<primitive: 'primitiveWhirl' module: #ScratchPlugin>
	self primitiveFailed

]

{ #category : #'primitive failure' }
PhratchPlugin class >> primitiveFailed [
	"Just beep rather than bringing up an error notifier."
	
	^ PhratchError primitiveFailed: 'ScratchPlugin primitive failed'

]

{ #category : #'image scale primitives' }
PhratchPlugin class >> scale: aForm by: scale [
	"Answer a 32-bit deep Form that's aForm scaled by the given factor. Scales using linear interpolation."

	| srcF scaledF r |
	srcF := aForm asFormOfDepth: 32.
	srcF unhibernate.
	scaledF := Form extent: (srcF extent * scale) rounded depth: 32.
	r := self
		primScaleNoFail: srcF bits w: srcF width h: srcF height
		into: scaledF bits w: scaledF width h: scaledF height.
	r ifNil: [^ srcF magnify: srcF boundingBox by: scale asFloat smoothing: 1].
	^ scaledF

]
