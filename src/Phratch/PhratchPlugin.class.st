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
	#superclass : #InterpreterPlugin,
	#category : #'Phratch-Primitives-Plugins'
}

{ #category : #'serial port primitives' }
PhratchPlugin class >> closePort: portNum [
	"Close the given port."
	"self closePort: 1"

	<primitive: 'primClose' module: #ScratchPlugin>

]

{ #category : #translation }
PhratchPlugin class >> declareCVarsIn: aCCodeGenerator [
	"self translate"

	super declareCVarsIn: aCCodeGenerator.
	aCCodeGenerator cExtras: '
#include "scratchOps.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>'.

]

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

{ #category : #'OS utilities' }
PhratchPlugin class >> isHidden: fullPath [
	"Return true if file or folder with the given path should be hidden from the user. Return false if the primitive fails."
	"self isHidden: 'testfile.txt'"

	OSPlatform isMacOSX ifTrue: [^ false].
	((fullPath endsWith: ':\') and: [fullPath size = 3]) ifTrue: [^ false].

	^ self primIsHidden: fullPath

]

{ #category : #'serial port primitives' }
PhratchPlugin class >> isPortOpen: portNum [
	"Answer true if the given serial port is open."
	"self isPortOpen: 1"

	<primitive: 'primIsPortOpen' module: #ScratchPlugin>
	^ false

]

{ #category : #'serial port primitives' }
PhratchPlugin class >> openPortNamed: portName baud: baudRate [
	"Open the port with the given name at the given baud rate. Answer the port number to use for further operations on the given port or -1 if the port could not be opened."
	"self openPortNamed: '/dev/cu.USA19QW3b1P1.1' baud: 9600"

	<primitive: 'primOpenPortNamed' module: #ScratchPlugin>
	^ -1

]

{ #category : #'OS utilities' }
PhratchPlugin class >> pluginAvailable [
	"self pluginAvailable"

	| f r |
	f := Form extent: 1@1 depth: 32.
	[r := self primShiftHue: f bits into: f bits byDegrees: 180] ifError: [^ false].
	^ r notNil


]

{ #category : #'serial port primitives' }
PhratchPlugin class >> port: portNum setOption: optionNum to: anInteger [
	"Set the given serial port option to the given value. Do nothing if the option is not defined. See the class comment for the list of options."

	<primitive: 'primSetOption' module: #ScratchPlugin>

]

{ #category : #'serial port primitives' }
PhratchPlugin class >> portCount [
	"Answer the number of serial ports. Answer 0 if there are no ports or if this primitive fails."
	"self portCount"

	<primitive: 'primPortCount' module: #ScratchPlugin>
	^ 0

]

{ #category : #'serial port primitives' }
PhratchPlugin class >> portCountOrNil [
	"Answer the number of serial ports. Answer nil if this primitive fails."
	"self portCountOrNil"

	<primitive: 'primPortCount' module: #ScratchPlugin>
	^ nil

]

{ #category : #'serial port primitives' }
PhratchPlugin class >> portName: portIndex [
	"Answer the name of the serial port with the given index. Answer nil if there is no port with the given index."
	"self portName: 1"

	<primitive: 'primPortName' module: #ScratchPlugin>
	^ nil

]

{ #category : #'image filter primitives' }
PhratchPlugin class >> primBlur: inBitmap into: outBitmap width: w [
	"Blur all the non-transparent pixels in the given 32-bit image bitmap, storing the result in outBitmap. The two bitmaps must be the same size. Each call to this primitive does one Gausian blur step."

	<primitive: 'primitiveBlur' module: #ScratchPlugin>
	self primitiveFailed

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

{ #category : #'OS utilities' }
PhratchPlugin class >> primGetFolderPathOrNil: anInteger [
	"Return the folder path for the given ID. Folder ID's are:
		1	home
		2	desktop
		3	documents
		4	my pictures
		5	my music.
	Return nil if the primitive fails."
	"self primGetFolderPathOrNil: 1"

	<primitive: 'primitiveGetFolderPath' module: #ScratchPlugin>
	self halt:'should remove'.
	^ nil

]

{ #category : #'image scale primitives' }
PhratchPlugin class >> primHalfSizeAverage: srcBits w: srcW h: srcH into: dstBits w: dstW h: dstH srcX: x1 srcY: y1 dstX: x2 dstY: y2 dstW: w dstH: h [
	"Display the source form at half-size onto the destination form at the given location by averaging the colors a 2x2 cell. Does not handle alpha or transparency. Return nil if the target rectangle does not fit entirely within the destination form."

	<primitive: 'primitiveHalfSizeAverage' module: #ScratchPlugin>
	^ nil

]

{ #category : #'OS utilities' }
PhratchPlugin class >> primIsHidden: fullPath [
	"Return true if file or folder with the given path should be hidden from the user. Return false if the primitive fails."
	"self primIsHidden: 'testfile.txt'"

	<primitive: 'primitiveIsHidden' module: #ScratchPlugin>
	^ false

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
	ScriptablePhratchMorph noviceMode ifTrue:[
		^Beeper beep]
	ifFalse:[
		^self primitiveFailed: 'ScratchPlugin primitive failed'
		]

]

{ #category : #'serial port primitives' }
PhratchPlugin class >> readPort: portNum into: buffer [
	"Read from the given port into the given ByteArray or String and answer the number of bytes read."
	"self readPort: 1 into: (ByteArray new: 10)"

	<primitive: 'primRead' module: #ScratchPlugin>
	^ 0

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

{ #category : #'serial port primitives' }
PhratchPlugin class >> writePort: portNum data: buffer [
	"Write data from the given ByteArray or String to the given port and answer the number of bytes written."
	"self writePort: 1 into: (ByteArray new: 10)"

	<primitive: 'primWrite' module: #ScratchPlugin>
	^ 0

]

{ #category : #private }
PhratchPlugin >> bitmap: bitmap at: i putH: hue s: saturation v: brightness [

	| hI hF p q t v outPix |
	self inline: true.
	self var: 'bitmap' declareC: 'unsigned int *bitmap'.

	hI := hue // 60.  "integer part of hue (0..5)"
	hF := hue \\ 60.  "fractional part ofhue"
	p := (1000 - saturation) * brightness.
	q := (1000 - ((saturation * hF) // 60)) * brightness.
	t := (1000 - ((saturation * (60 - hF)) // 60)) * brightness.

	v := (brightness * 1000) // 3922.
	p := p // 3922.
	q := q // 3922.
	t := t // 3922.

	0 = hI ifTrue: [outPix := ((v bitShift: 16) + (t bitShift: 8) + p)].
	1 = hI ifTrue: [outPix := ((q bitShift: 16) + (v bitShift: 8) + p)].
	2 = hI ifTrue: [outPix := ((p bitShift: 16) + (v bitShift: 8) + t)].
	3 = hI ifTrue: [outPix := ((p bitShift: 16) + (q bitShift: 8) + v)].
	4 = hI ifTrue: [outPix := ((t bitShift: 16) + (p bitShift: 8) + v)].
	5 = hI ifTrue: [outPix := ((v bitShift: 16) + (p bitShift: 8) + q)].

	outPix = 0 ifTrue: [outPix := 1].  "convert transparent to 1"
	bitmap at: i put: outPix.
	^ 0

]

{ #category : #private }
PhratchPlugin >> checkedFloatPtrOf: oop [
	"Return an unsigned int pointer to the first indexable word of oop, which must be a words object."

	self inline: true.
	self returnTypeC: 'double *'.

	interpreterProxy success: (interpreterProxy isWordsOrBytes: oop).
	interpreterProxy failed ifTrue: [^ 0].
	^ self cCoerce: (interpreterProxy firstIndexableField: oop) to: 'double *'

]

{ #category : #private }
PhratchPlugin >> checkedUnsignedIntPtrOf: oop [
	"Return an unsigned int pointer to the first indexable word of oop, which must be a words object."

	self inline: true.
	self returnTypeC: 'unsigned int *'.

	interpreterProxy success: (interpreterProxy isWords: oop).
	interpreterProxy failed ifTrue: [^ 0].
	^ self cCoerce: (interpreterProxy firstIndexableField: oop) to: 'unsigned int *'

]

{ #category : #private }
PhratchPlugin >> hueFromR: r G: g B: b min: min max: max [
	"Answer the hue, an angle between 0 and 360."

	| span result |
	self inline: true.
	span := max - min.
	span = 0
		ifTrue: [ ^ 0 ].
	result := r = max
		ifTrue: [ 60 * (g - b) // span ]
		ifFalse: [ 
			g = max
				ifTrue: [ 120 + (60 * (b - r) // span) ]
				ifFalse: [ 240 + (60 * (r - g) // span) ] ].
	result < 0
		ifTrue: [ ^ result + 360 ].
	^ result
]

{ #category : #private }
PhratchPlugin >> interpolate: pix1 and: pix2 frac: frac2 [
	"Answer the interpolated pixel value between the given two pixel values. If either pixel is zero (transparent) answer the other pixel. If both pixels are  transparent, answer transparent. The fraction is between 0 and 1023, out of a total range of 1024."

	| frac1 r g b result |
	self inline: true.

	pix1 = 0 ifTrue: [^ pix2].  "pix1 is transparent"
	pix2 = 0 ifTrue: [^ pix1].  "pix2 is transparent"

	frac1 := 1024 - frac2.
	r := ((frac1 * ((pix1 bitShift: -16) bitAnd: 16rFF)) + (frac2 * ((pix2 bitShift: -16) bitAnd: 16rFF))) // 1024.
	g := ((frac1 * ((pix1 bitShift: -8) bitAnd: 16rFF)) + (frac2 * ((pix2 bitShift: -8) bitAnd: 16rFF))) // 1024.
	b := ((frac1 * (pix1 bitAnd: 16rFF)) + (frac2 * (pix2 bitAnd: 16rFF))) // 1024.
	result := (r bitShift: 16) + (g bitShift: 8) + b.
	result = 0 ifTrue: [result := 1].
	^ result

]

{ #category : #private }
PhratchPlugin >> interpolatedFrom: bitmap x: xFixed y: yFixed width: w height: h [
	"Answer the interpolated pixel value from the given bitmap at the given point. The x and y coordinates are fixed-point integers with 10 bits of fraction (i.e. they were multiplied by 1024, then truncated). If the given point is right on an edge, answer the nearest edge pixel value. If it is entirely outside of the image, answer 0 (transparent)."

	| x y xFrac yFrac index topPix bottomPix |
	self inline: true.
	self var: 'bitmap' declareC: 'unsigned int *bitmap'.

	x := xFixed bitShift: -10.
	(x < -1 or: [x >= w]) ifTrue: [^ 0].
	y := yFixed bitShift: -10.
	(y < -1 or: [y >= h]) ifTrue: [^ 0].

	xFrac := xFixed bitAnd: 1023.
	x = -1 ifTrue: [x := 0. xFrac := 0].  "left edge"
	x = (w - 1) ifTrue: [xFrac := 0].  "right edge"

	yFrac := yFixed bitAnd: 1023.
	y = -1 ifTrue: [y := 0. yFrac := 0].  "top edge"
	y = (h - 1) ifTrue: [yFrac := 0].  "bottom edge"

	index := (y * w) + x "for squeak: + 1".
	topPix := (bitmap at: index) bitAnd: 16rFFFFFF.
	xFrac > 0 ifTrue: [
		topPix := self interpolate: topPix and: ((bitmap at: index + 1) bitAnd: 16rFFFFFF) frac: xFrac].

	yFrac = 0 ifTrue: [^ topPix].  "no y fraction, so just use value from top row"

	index := ((y + 1) * w) + x "for squeak: + 1".
	bottomPix := (bitmap at: index) bitAnd: 16rFFFFFF.
	xFrac > 0 ifTrue: [
		bottomPix := self interpolate: bottomPix and: ((bitmap at: index + 1) bitAnd: 16rFFFFFF) frac: xFrac].

	^ self interpolate: topPix and: bottomPix frac: yFrac

]

{ #category : #'serial port' }
PhratchPlugin >> primClose [
	"Close the given serial port."

	| portNum |
	self export: true.
	portNum := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed ifTrue: [^ nil].

	self cCode: 'SerialPortClose(portNum)'.

	interpreterProxy pop: 1.  "pop arg, leave rcvr on stack"
	^ 0

]

{ #category : #'serial port' }
PhratchPlugin >> primGetOption [
	"Return the given option value for the given serial port."

	| portNum attrNum result |
	self export: true.
	portNum := interpreterProxy stackIntegerValue: 1.
	attrNum := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed ifTrue: [^ nil].

	result := self cCode: 'SerialPortGetOption(portNum, attrNum)'.
	result = -1 ifTrue: [interpreterProxy success: false. ^ 0].

	interpreterProxy pop: 3.  "pop args and rcvr, push result"
	interpreterProxy pushInteger: result.
	^ 0

]

{ #category : #'serial port' }
PhratchPlugin >> primIsPortOpen [
	"Answer the true if the given port is open."

	| portNum result |
	self export: true.
	portNum := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed ifTrue: [^ 0].

	result := self cCode: 'SerialPortIsOpen(portNum)'.

	interpreterProxy pop: 2.  "pop arg and rcvr"
	interpreterProxy pushBool: result ~= 0.  "push result"
	^ 0

]

{ #category : #'serial port' }
PhratchPlugin >> primOpenPortNamed [
	"Open the port with the given name and baud rate."

	| nameStr src nameOop baudRate count portNum |
	self export: true.
	self var: 'nameStr' declareC: 'char nameStr[1000]'.
	self var: 'src' declareC: 'char * src'.

	nameOop := interpreterProxy stackValue: 1.
	baudRate := interpreterProxy stackIntegerValue: 0.

	((interpreterProxy isIntegerObject: nameOop) or:
	 [(interpreterProxy isBytes: nameOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].

	interpreterProxy failed ifTrue: [^ 0].

	src := self cCoerce: (interpreterProxy firstIndexableField: nameOop) to: 'char *'.
	count := interpreterProxy stSizeOf: nameOop.
	0 to: count - 1 do: [:i | nameStr at: i put: (src at: i)].
	nameStr at: count put: 0.

	portNum := self cCode: 'SerialPortOpenPortNamed(nameStr, baudRate)'.
	portNum = -1 ifTrue: [interpreterProxy success: false. ^ 0].

	interpreterProxy	"pop args and rcvr, push result"
		pop: 3
		thenPush: (interpreterProxy integerObjectOf: portNum).

	^ 0

]

{ #category : #'serial port' }
PhratchPlugin >> primPortCount [
	"Answer the number of serial ports."

	| result |
	self export: true.

	result := self cCode: 'SerialPortCount()'.
	result = -1 ifTrue: [interpreterProxy success: false. ^ 0].

	interpreterProxy
		pop: 1 thenPush: (interpreterProxy integerObjectOf: result).  "pop rcvr, push result"
	^ 0

]

{ #category : #'serial port' }
PhratchPlugin >> primPortName [
	"Get the name for the port with the given number. Fail if the port number is greater than the number of available ports. Port numbering starts with 1."

	| portIndex nameStr count resultOop dst |
	self export: true.
	self var: 'nameStr' declareC: 'char nameStr[1000]'.
	self var: 'dst' declareC: 'char* dst'.

	portIndex := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed ifTrue: [^ 0].

	self cCode: 'SerialPortName(portIndex, nameStr, 1000)'.

	count := self cCode: 'strlen(nameStr)'.
	count = 0 ifTrue: [
		interpreterProxy success: false.
		^ 0].

	resultOop := interpreterProxy instantiateClass: interpreterProxy classString indexableSize: count.
	dst := self cCoerce: (interpreterProxy firstIndexableField: resultOop) to: 'char *'.
	0 to: count - 1 do: [:i | dst at: i put: (nameStr at: i)].

	interpreterProxy pop: 2 thenPush: resultOop.  "pop arg and rcvr, push result"
	^ 0

]

{ #category : #'serial port' }
PhratchPlugin >> primRead [
	"Read data from the given serial port into the given buffer (a ByteArray or String). Answer the number of bytes read."

	| portNum bufOop bufPtr bufSize bytesRead |
	self export: true.
	self var: 'bufPtr' declareC: 'char *bufPtr'.

	portNum := interpreterProxy stackIntegerValue: 1.
	bufOop := interpreterProxy stackValue: 0.

	((interpreterProxy isIntegerObject: bufOop) or:
	 [(interpreterProxy isBytes: bufOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	bufPtr := self cCoerce: (interpreterProxy firstIndexableField: bufOop) to: 'char *'.
	bufSize := interpreterProxy stSizeOf: bufOop.
	interpreterProxy failed ifTrue: [^ nil].

	bytesRead := self cCode: 'SerialPortRead(portNum, bufPtr, bufSize)'.

	interpreterProxy pop: 3.  					"pop args and rcvr"
	interpreterProxy pushInteger: bytesRead.	"push result"
	^ 0

]

{ #category : #'serial port' }
PhratchPlugin >> primSetOption [
	"Return the given option value for the given serial port."

	| portNum attrNum attrValue result |
	self export: true.
	portNum := interpreterProxy stackIntegerValue: 2.
	attrNum := interpreterProxy stackIntegerValue: 1.
	attrValue := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed ifTrue: [^ nil].

	result := self cCode: 'SerialPortSetOption(portNum, attrNum, attrValue)'.
	result = -1 ifTrue: [interpreterProxy success: false. ^ 0].

	interpreterProxy pop: 3.  "pop args; leave rcvr on stack"
	^ 0

]

{ #category : #'serial port' }
PhratchPlugin >> primWrite [
	"Write data to the given serial port from the given buffer (a ByteArray or String). Answer the number of bytes written."

	| portNum bufOop bufPtr bufSize bytesWritten |
	self export: true.
	self var: 'bufPtr' declareC: 'char *bufPtr'.

	portNum := interpreterProxy stackIntegerValue: 1.
	bufOop := interpreterProxy stackValue: 0.

	((interpreterProxy isIntegerObject: bufOop) or:
	 [(interpreterProxy isBytes: bufOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].
	bufPtr := self cCoerce: (interpreterProxy firstIndexableField: bufOop) to: 'char *'.
	bufSize := interpreterProxy stSizeOf: bufOop.
	interpreterProxy failed ifTrue: [^ nil].

	bytesWritten := self cCode: 'SerialPortWrite(portNum, bufPtr, bufSize)'.

	interpreterProxy pop: 3.  					"pop args and rcvr"
	interpreterProxy pushInteger: bytesWritten.	"push result"
	^ 0

]

{ #category : #'other filters' }
PhratchPlugin >> primitiveBlur [
	| inOop outOop width in out sz height n rTotal gTotal bTotal pix outPix |
	self export: true.
	self var: 'in' declareC: 'unsigned int *in'.
	self var: 'out' declareC: 'unsigned int *out'.
	inOop := interpreterProxy stackValue: 2.
	outOop := interpreterProxy stackValue: 1.
	width := interpreterProxy stackIntegerValue: 0.
	in := self checkedUnsignedIntPtrOf: inOop.
	out := self checkedUnsignedIntPtrOf: outOop.
	sz := interpreterProxy stSizeOf: inOop.
	interpreterProxy success: (interpreterProxy stSizeOf: outOop) = sz.
	interpreterProxy failed
		ifTrue: [ ^ nil ].
	height := sz // width.
	1 to: height - 2 do: [ :y | 
		1 to: width - 2 do: [ :x | 
			n := rTotal := gTotal := bTotal := 0.
			-1 to: 1 do: [ :dY | 
				-1 to: 1 do: [ :dX | 
					pix := (in at: (y + dY) * width + (x + dX)) bitAnd: 16rFFFFFF.	"add 1 when testing in Squeak"
					pix = 0
						ifFalse: [ 
							"skip transparent pixels"
							rTotal := rTotal + ((pix bitShift: -16) bitAnd: 16rFF).
							gTotal := gTotal + ((pix bitShift: -8) bitAnd: 16rFF).
							bTotal := bTotal + (pix bitAnd: 16rFF).
							n := n + 1 ] ] ].
			outPix := n = 0
				ifTrue: [ 0 ]
				ifFalse: [ (rTotal // n bitShift: 16) + (gTotal // n bitShift: 8) + (bTotal // n) ].
			out at: y * width + x put: outPix	"add 1 when testing in Squeak" ] ].
	interpreterProxy pop: 3.	"pop args, leave rcvr on stack"
	^ 0
]

{ #category : #'hsv filters' }
PhratchPlugin >> primitiveBrightnessShift [
	| inOop outOop shift in sz out pix r g b max min hue saturation brightness |
	self export: true.
	self var: 'in' declareC: 'unsigned int *in'.
	self var: 'out' declareC: 'unsigned int *out'.
	inOop := interpreterProxy stackValue: 2.
	outOop := interpreterProxy stackValue: 1.
	shift := interpreterProxy stackIntegerValue: 0.
	in := self checkedUnsignedIntPtrOf: inOop.
	sz := interpreterProxy stSizeOf: inOop.
	out := self checkedUnsignedIntPtrOf: outOop.
	interpreterProxy success: (interpreterProxy stSizeOf: outOop) = sz.
	interpreterProxy failed
		ifTrue: [ ^ nil ].
	0 to: sz - 1 do: [ :i | 
		pix := (in at: i) bitAnd: 16rFFFFFF.
		pix = 0
			ifFalse: [ 
				"skip pixel values of 0 (transparent)"
				r := (pix bitShift: -16) bitAnd: 16rFF.
				g := (pix bitShift: -8) bitAnd: 16rFF.
				b := pix bitAnd: 16rFF.	"find min and max color components"
				max := min := r.
				max := max max: g.
				max := max max: b.
				min := min min: g.
				min := min min: b.	"find current hue with range 0 to 360"
				hue := self
					hueFromR: r
					G: g
					B: b
					min: min
					max: max.	"find current saturation and brightness with range 0 to 1000"
				saturation := max = 0
					ifTrue: [ 0 ]
					ifFalse: [ (max - min) * 1000 // max ].
				brightness := max * 1000 // 255.	"compute new brigthness"
				brightness := brightness + (shift * 10).
				brightness := brightness min: 1000.
				brightness := brightness max: 0.
				self
					bitmap: out
					at: i
					putH: hue
					s: saturation
					v: brightness ] ].
	interpreterProxy pop: 3.	"pop args, leave rcvr on stack"
	^ 0
]

{ #category : #scaling }
PhratchPlugin >> primitiveDoubleSize [

	| in out inOop outOop inW inH outW outH dstX dstY baseIndex pix i |
	self export: true.
	self var: 'in' declareC: 'int *in'.
	self var: 'out' declareC: 'int *out'.

	inOop := interpreterProxy stackValue: 7.
	inW := interpreterProxy stackIntegerValue: 6.
	inH := interpreterProxy stackIntegerValue: 5.
	outOop := interpreterProxy stackValue: 4.
	outW := interpreterProxy stackIntegerValue: 3.
	outH := interpreterProxy stackIntegerValue: 2.
	dstX := interpreterProxy stackIntegerValue: 1.
	dstY := interpreterProxy stackIntegerValue: 0.

	in := self checkedUnsignedIntPtrOf: inOop.
	out := self checkedUnsignedIntPtrOf: outOop.
	interpreterProxy success: (dstX + (2 * inW)) < outW.
	interpreterProxy success: (dstY + (2 * inH)) < outH.
	interpreterProxy failed ifTrue: [^ nil].

	0 to: inH - 1 do: [:y |
		baseIndex := ((dstY + (2 * y)) * outW) + dstX.
		0 to: inW - 1 do: [:x |
			pix := in at: x + (y * inW).
			i := baseIndex + (2 * x).
			out at: i put: pix.
			out at: i + 1 put: pix.
			out at: i + outW put: pix.
			out at: i + outW + 1 put: pix]].

	interpreterProxy pop: 8.  "pop args, leave rcvr on stack"
	^ 0

]

{ #category : #'other filters' }
PhratchPlugin >> primitiveFisheye [

	| inOop outOop width in out sz height centerX centerY dx dy ang pix power r srcX srcY scaledPower |
	self export: true.
	self var: 'in' declareC: 'unsigned int *in'.
	self var: 'out' declareC: 'unsigned int *out'.
	self var: 'scaleX' declareC: 'double scaleX'.
	self var: 'scaleY' declareC: 'double scaleY'.
	self var: 'whirlRadians' declareC: 'double whirlRadians'.
	self var: 'radiusSquared' declareC: 'double radiusSquared'.
	self var: 'dx' declareC: 'double dx'.
	self var: 'dy' declareC: 'double dy'.
	self var: 'd' declareC: 'double d'.
	self var: 'factor' declareC: 'double factor'.
	self var: 'ang' declareC: 'double ang'.
	self var: 'sina' declareC: 'double sina'.
	self var: 'cosa' declareC: 'double cosa'.
	self var: 'r' declareC: 'double r'.
	self var: 'scaledPower' declareC: 'double scaledPower'.

	inOop := interpreterProxy stackValue: 3.
	outOop := interpreterProxy stackValue: 2.
	width := interpreterProxy stackIntegerValue: 1.
	power := interpreterProxy stackIntegerValue: 0.
	in := self checkedUnsignedIntPtrOf: inOop.
	out := self checkedUnsignedIntPtrOf: outOop.
	sz := interpreterProxy stSizeOf: inOop.
	interpreterProxy success: ((interpreterProxy stSizeOf: outOop) = sz).
	interpreterProxy failed ifTrue: [^ nil].

	"calculate height, center, scales, radius, whirlRadians, and radiusSquared"
	height := sz // width.
	centerX := width // 2.
	centerY := height // 2.

	height := sz // width.
	centerX := width // 2.
	centerY := height // 2.
	scaledPower := power / 100.0.

	0 to: width - 1 do: [:x |
		0 to: height - 1 do: [:y |
			dx := (x - centerX) / centerX asFloat.
			dy := (y - centerY) / centerY asFloat.
			r := ((dx * dx) + (dy * dy)) sqrt raisedTo: scaledPower.
			r <= 1.0
				ifTrue: [
					ang := self cCode: 'atan2(dy,dx)'.
					srcX := (1024 * (centerX + ((r * ang cos) * centerX))) asInteger.
					srcY := (1024 * (centerY + ((r * ang sin) * centerY))) asInteger]
				ifFalse: [
					srcX := 1024 * x.
					srcY := 1024 * y].
			pix := self interpolatedFrom: in
					x: srcX
					y: srcY
					width: width
					height: height.
			out at: ((y * width) + x "+ 1 for Squeak") put: pix]].

	interpreterProxy pop: 4.  "pop args, leave rcvr on stack"
	^ 0

]

{ #category : #'os functions' }
PhratchPlugin >> primitiveGetFolderPath [
	"Get the path for the special folder with given ID. Fail if the folder ID is out of range."

	| nameStr dst folderID count resultOop |
	self export: true.
	self var: 'nameStr' declareC: 'char nameStr[2000]'.
	self var: 'dst' declareC: 'char* dst'.

	folderID := interpreterProxy stackIntegerValue: 0.
	interpreterProxy failed ifTrue: [^ 0].

	self cCode: 'GetFolderPathForID(folderID, nameStr, 2000)'.

	count := self cCode: 'strlen(nameStr)'.
	resultOop := interpreterProxy instantiateClass: interpreterProxy classString indexableSize: count.
	dst := self cCoerce: (interpreterProxy firstIndexableField: resultOop) to: 'char *'.
	0 to: count - 1 do: [:i | dst at: i put: (nameStr at: i)].

	interpreterProxy pop: 2 thenPush: resultOop.  "pop arg and rcvr, push result"
	^ 0

]

{ #category : #scaling }
PhratchPlugin >> primitiveHalfSizeAverage [

	| in inW inH out outW outH srcX srcY dstX dstY dstW dstH srcIndex dstIndex pixel r g b |
	self export: true.
	self var: 'in' declareC: 'int *in'.
	self var: 'out' declareC: 'int *out'.

	in := self checkedUnsignedIntPtrOf: (interpreterProxy stackValue: 11).
	inW := interpreterProxy stackIntegerValue: 10.
	inH := interpreterProxy stackIntegerValue: 9.
	out := self checkedUnsignedIntPtrOf: (interpreterProxy stackValue: 8).
	outW := interpreterProxy stackIntegerValue: 7.
	outH := interpreterProxy stackIntegerValue: 6.
	srcX := interpreterProxy stackIntegerValue: 5.
	srcY := interpreterProxy stackIntegerValue: 4.
	dstX := interpreterProxy stackIntegerValue: 3.
	dstY := interpreterProxy stackIntegerValue: 2.
	dstW := interpreterProxy stackIntegerValue: 1.
	dstH := interpreterProxy stackIntegerValue: 0.

	interpreterProxy success: (srcX >= 0) & (srcY >= 0).
	interpreterProxy success: (srcX + (2 * dstW)) <= inW.
	interpreterProxy success: (srcY + (2 * dstH)) <= inH.
	interpreterProxy success: (dstX >= 0) & (dstY >= 0).
	interpreterProxy success: (dstX + dstW) <= outW.
	interpreterProxy success: (dstY + dstH) <= outH.
	interpreterProxy failed ifTrue: [^ nil].

	0 to: dstH - 1 do: [:y |
		srcIndex := (inW * (srcY + (2 * y))) + srcX.
		dstIndex := (outW * (dstY + y)) + dstX.
		0 to: dstW - 1 do: [:x |
			pixel := in at: srcIndex.
			r := pixel bitAnd: 16rFF0000.
			g := pixel bitAnd: 16rFF00.
			b := pixel bitAnd: 16rFF.

			pixel := in at: srcIndex + 1.
			r := r + (pixel bitAnd: 16rFF0000).
			g := g + (pixel bitAnd: 16rFF00).
			b := b + (pixel bitAnd: 16rFF).

			pixel := in at: srcIndex + inW.
			r := r + (pixel bitAnd: 16rFF0000).
			g := g + (pixel bitAnd: 16rFF00).
			b := b + (pixel bitAnd: 16rFF).

			pixel := in at: srcIndex + inW + 1.
			r := r + (pixel bitAnd: 16rFF0000).
			g := g + (pixel bitAnd: 16rFF00).
			b := b + (pixel bitAnd: 16rFF).

			"store combined RGB into target bitmap"
			out at: dstIndex put:
				(((r bitShift: -2) bitAnd: 16rFF0000) bitOr:
				(((g bitShift: -2) bitAnd: 16rFF00) bitOr: (b bitShift: -2))).

			srcIndex := srcIndex + 2.
			dstIndex := dstIndex + 1]].

	interpreterProxy pop: 12.  "pop args, leave rcvr on stack"
	^ 0

]

{ #category : #'hsv filters' }
PhratchPlugin >> primitiveHueShift [
	| inOop outOop shift in sz out pix r g b max min brightness saturation hue |
	self export: true.
	self var: 'in' declareC: 'unsigned int *in'.
	self var: 'out' declareC: 'unsigned int *out'.
	inOop := interpreterProxy stackValue: 2.
	outOop := interpreterProxy stackValue: 1.
	shift := interpreterProxy stackIntegerValue: 0.
	in := self checkedUnsignedIntPtrOf: inOop.
	sz := interpreterProxy stSizeOf: inOop.
	out := self checkedUnsignedIntPtrOf: outOop.
	interpreterProxy success: (interpreterProxy stSizeOf: outOop) = sz.
	interpreterProxy failed
		ifTrue: [ ^ nil ].
	0 to: sz - 1 do: [ :i | 
		pix := (in at: i) bitAnd: 16rFFFFFF.
		pix = 0
			ifFalse: [ 
				"skip pixel values of 0 (transparent)"
				r := (pix bitShift: -16) bitAnd: 16rFF.
				g := (pix bitShift: -8) bitAnd: 16rFF.
				b := pix bitAnd: 16rFF.	"find min and max color components"
				max := min := r.
				max := max max: g.
				max := max max: b.
				min := min min: g.
				min := min min: b.	"find current brightness (v) and  saturation with range 0 to 1000"
				brightness := max * 1000 // 255.
				saturation := max = 0
					ifTrue: [ 0 ]
					ifFalse: [ (max - min) * 1000 // max ].
				brightness < 110
					ifTrue: [ 
						"force black to a very dark, saturated gray"
						brightness := 110.
						saturation := 1000 ].
				saturation := saturation max: 90.	"force a small color change on grays"
				hue := brightness = 110 | (saturation = 90)
					ifTrue: [ 0 ]
					ifFalse: [ 
						self
							hueFromR: r
							G: g
							B: b
							min: min
							max: max ].	"tint all blacks and grays the same"
				hue := (hue + shift + 360000000) \\ 360.	"compute new hue"
				self
					bitmap: out
					at: i
					putH: hue
					s: saturation
					v: brightness ] ].
	interpreterProxy pop: 3.	"pop args, leave rcvr on stack"
	^ 0
]

{ #category : #'os functions' }
PhratchPlugin >> primitiveIsHidden [
	"Answer true if the file or folder with the given path should be hidden from the user. On Windows, this is the value of the 'hidden' file property."

	| pathOop src count fullPath result |
	self export: true.
	self var: 'fullPath' declareC: 'char fullPath[1000]'.
	self var: 'src' declareC: 'char * src'.

	pathOop := interpreterProxy stackValue: 0.

	((interpreterProxy isIntegerObject: pathOop) or:
	 [(interpreterProxy isBytes: pathOop) not]) ifTrue: [
		interpreterProxy success: false].

	interpreterProxy failed ifTrue: [^ 0].

	src := self cCoerce: (interpreterProxy firstIndexableField: pathOop) to: 'char *'.
	count := interpreterProxy stSizeOf: pathOop.
	count >= 1000 ifTrue: [interpreterProxy success: false. ^ 0].
	0 to: count - 1 do: [:i | fullPath at: i put: (src at: i)].
	fullPath at: count put: 0.

	result := self cCode: 'IsFileOrFolderHidden(fullPath)'.

	interpreterProxy pop: 2.  "pop arg and rcvr"
	interpreterProxy pushBool: result ~= 0.  "push result"
	^ 0


]

{ #category : #'os functions' }
PhratchPlugin >> primitiveOpenURL [
	"Open a web browser on the given URL."

	| urlStr src urlOop count |
	self export: true.
	self var: 'urlStr' declareC: 'char urlStr[2000]'.
	self var: 'src' declareC: 'char * src'.

	urlOop := interpreterProxy stackValue: 0.

	((interpreterProxy isIntegerObject: urlOop) or:
	 [(interpreterProxy isBytes: urlOop) not]) ifTrue: [
		interpreterProxy success: false].

	interpreterProxy failed ifTrue: [^ 0].

	src := self cCoerce: (interpreterProxy firstIndexableField: urlOop) to: 'char *'.
	count := interpreterProxy stSizeOf: urlOop.
	count >= 2000 ifTrue: [interpreterProxy success: false. ^ 0].
	0 to: count - 1 do: [:i | urlStr at: i put: (src at: i)].
	urlStr at: count put: 0.

	self cCode: 'OpenURL(urlStr)'.

	interpreterProxy pop: 1.  "pop arg, leave rcvr on stack"
	^ 0


]

{ #category : #scaling }
PhratchPlugin >> primitiveScale [
	"Scale using bilinear interpolation."

	| inOop inW inH outOop outW outH in out inX inY xIncr yIncr outPix w1 w2 w3 w4 t p1 p2 p3 p4 tWeight |
	self export: true.
	self var: 'in' declareC: 'int *in'.
	self var: 'out' declareC: 'int *out'.
	inOop := interpreterProxy stackValue: 5.
	inW := interpreterProxy stackIntegerValue: 4.
	inH := interpreterProxy stackIntegerValue: 3.
	outOop := interpreterProxy stackValue: 2.
	outW := interpreterProxy stackIntegerValue: 1.
	outH := interpreterProxy stackIntegerValue: 0.
	interpreterProxy success: (interpreterProxy stSizeOf: inOop) = (inW * inH).
	interpreterProxy success: (interpreterProxy stSizeOf: outOop) = (outW * outH).
	in := self checkedUnsignedIntPtrOf: inOop.
	out := self checkedUnsignedIntPtrOf: outOop.
	interpreterProxy failed
		ifTrue: [ ^ nil ].
	inX := inY := 0.	"source x and y, scaled by 1024"
	xIncr := inW * 1024 // outW.	"source x increment, scaled by 1024"
	yIncr := inH * 1024 // outH.	"source y increment, scaled by 1024"
	0 to: outH - 1 do: [ :outY | 
		inX := 0.
		0 to: outW - 1 do: [ :outX | 
			"compute weights, scaled by 2^20"
			w1 := (1024 - (inX bitAnd: 1023)) * (1024 - (inY bitAnd: 1023)).
			w2 := (inX bitAnd: 1023) * (1024 - (inY bitAnd: 1023)).
			w3 := (1024 - (inX bitAnd: 1023)) * (inY bitAnd: 1023).
			w4 := (inX bitAnd: 1023) * (inY bitAnd: 1023).	"get source pixels"
			t := (inY >> 10) * inW + (inX >> 10).
			p1 := in at: t.
			p2 := inX >> 10 < (inW - 1)
				ifTrue: [ in at: t + 1 ]
				ifFalse: [ p1 ].
			inY >> 10 < (inH - 1)
				ifTrue: [ t := t + inW ].	"next row"
			p3 := in at: t.
			p4 := inX >> 10 < (inW - 1)
				ifTrue: [ in at: t + 1 ]
				ifFalse: [ p3 ].	"deal with transparent pixels"
			tWeight := 0.
			p1 = 0
				ifTrue: [ 
					p1 := p2.
					tWeight := tWeight + w1 ].
			p2 = 0
				ifTrue: [ 
					p2 := p1.
					tWeight := tWeight + w2 ].
			p3 = 0
				ifTrue: [ 
					p3 := p4.
					tWeight := tWeight + w3 ].
			p4 = 0
				ifTrue: [ 
					p4 := p3.
					tWeight := tWeight + w4 ].
			p1 = 0
				ifTrue: [ 
					p1 := p3.
					p2 := p4 ].	"both top pixels were transparent; use bottom row"
			p3 = 0
				ifTrue: [ 
					p3 := p1.
					p4 := p2 ].	"both bottom pixels were transparent; use top row"
			outPix := 0.
			tWeight < 500000
				ifTrue: [ 
					"compute an (opaque) output pixel if less than 50% transparent"
					t := w1 * (p1 >> 16 bitAnd: 255) + (w2 * (p2 >> 16 bitAnd: 255)) + (w3 * (p3 >> 16 bitAnd: 255))
						+ (w4 * (p4 >> 16 bitAnd: 255)).
					outPix := (t >> 20 bitAnd: 255) << 16.
					t := w1 * (p1 >> 8 bitAnd: 255) + (w2 * (p2 >> 8 bitAnd: 255)) + (w3 * (p3 >> 8 bitAnd: 255))
						+ (w4 * (p4 >> 8 bitAnd: 255)).
					outPix := outPix bitOr: (t >> 20 bitAnd: 255) << 8.
					t := w1 * (p1 bitAnd: 255) + (w2 * (p2 bitAnd: 255)) + (w3 * (p3 bitAnd: 255)) + (w4 * (p4 bitAnd: 255)).
					outPix := outPix bitOr: (t >> 20 bitAnd: 255).
					outPix = 0
						ifTrue: [ outPix := 1 ] ].
			out at: outY * outW + outX put: outPix.
			inX := inX + xIncr ].
		inY := inY + yIncr ].
	interpreterProxy pop: 6.	"pop args, leave rcvr on stack"
	^ 0
]

{ #category : #'os functions' }
PhratchPlugin >> primitiveSetWindowTitle [
	"Set the title of the Phratch window."

	| titleStr src titleOop count |
	self export: true.
	self var: 'titleStr' declareC: 'char titleStr[1000]'.
	self var: 'src' declareC: 'char * src'.

	titleOop := interpreterProxy stackValue: 0.

	((interpreterProxy isIntegerObject: titleOop) or:
	 [(interpreterProxy isBytes: titleOop) not]) ifTrue: [
		interpreterProxy success: false].

	interpreterProxy failed ifTrue: [^ 0].

	src := self cCoerce: (interpreterProxy firstIndexableField: titleOop) to: 'char *'.
	count := interpreterProxy stSizeOf: titleOop.
	count >= 1000 ifTrue: [interpreterProxy success: false. ^ 0].
	0 to: count - 1 do: [:i | titleStr at: i put: (src at: i)].
	titleStr at: count put: 0.

	self cCode: 'SetScratchWindowTitle(titleStr)'.

	interpreterProxy pop: 1.  "pop arg, leave rcvr on stack"
	^ 0


]

{ #category : #'os functions' }
PhratchPlugin >> primitiveShortToLongPath [
	"On Windows, convert a short file/path name into a long one. Fail on other platforms."

	| shortPath longPath ptr shortPathOop result count resultOop |
	self export: true.
	self var: 'shortPath' declareC: 'char shortPath[1000]'.
	self var: 'longPath' declareC: 'char longPath[1000]'.
	self var: 'ptr' declareC: 'char * ptr'.

	shortPathOop := interpreterProxy stackValue: 0.

	((interpreterProxy isIntegerObject: shortPathOop) or:
	 [(interpreterProxy isBytes: shortPathOop) not]) ifTrue: [
		interpreterProxy success: false. ^ 0].

	ptr := self cCoerce: (interpreterProxy firstIndexableField: shortPathOop) to: 'char *'.
	count := interpreterProxy stSizeOf: shortPathOop.
	count >= 1000 ifTrue: [interpreterProxy success: false. ^ 0].
	0 to: count - 1 do: [:i | shortPath at: i put: (ptr at: i)].
	shortPath at: count put: 0.

	result := self cCode: 'WinShortToLongPath(shortPath, longPath, 1000)'.
	result = -1 ifTrue: [interpreterProxy success: false. ^ 0].

	count := self cCode: 'strlen(longPath)'.
	resultOop := interpreterProxy instantiateClass: interpreterProxy classString indexableSize: count.
	ptr := self cCoerce: (interpreterProxy firstIndexableField: resultOop) to: 'char *'.
	0 to: count - 1 do: [:i | ptr at: i put: (longPath at: i)].

	interpreterProxy pop: 2 thenPush: resultOop.  "pop arg and rcvr, push result"
	^ 0

]

{ #category : #'other filters' }
PhratchPlugin >> primitiveWhirl [
	| inOop outOop width degrees in out sz height centerX centerY radius scaleX scaleY whirlRadians radiusSquared dx dy d factor ang sina cosa pix |
	self export: true.
	self var: 'in' declareC: 'unsigned int *in'.
	self var: 'out' declareC: 'unsigned int *out'.
	self var: 'scaleX' declareC: 'double scaleX'.
	self var: 'scaleY' declareC: 'double scaleY'.
	self var: 'whirlRadians' declareC: 'double whirlRadians'.
	self var: 'radiusSquared' declareC: 'double radiusSquared'.
	self var: 'dx' declareC: 'double dx'.
	self var: 'dy' declareC: 'double dy'.
	self var: 'd' declareC: 'double d'.
	self var: 'factor' declareC: 'double factor'.
	self var: 'ang' declareC: 'double ang'.
	self var: 'sina' declareC: 'double sina'.
	self var: 'cosa' declareC: 'double cosa'.
	inOop := interpreterProxy stackValue: 3.
	outOop := interpreterProxy stackValue: 2.
	width := interpreterProxy stackIntegerValue: 1.
	degrees := interpreterProxy stackIntegerValue: 0.
	in := self checkedUnsignedIntPtrOf: inOop.
	out := self checkedUnsignedIntPtrOf: outOop.
	sz := interpreterProxy stSizeOf: inOop.
	interpreterProxy success: (interpreterProxy stSizeOf: outOop) = sz.
	interpreterProxy failed
		ifTrue: [ ^ nil ].	"calculate height, center, scales, radius, whirlRadians, and radiusSquared"
	height := sz // width.
	centerX := width // 2.
	centerY := height // 2.
	centerX < centerY
		ifTrue: [ 
			radius := centerX.
			scaleX := centerY asFloat / centerX.
			scaleY := 1.0 ]
		ifFalse: [ 
			radius := centerY.
			scaleX := 1.0.
			scaleY := centerY < centerX
				ifTrue: [ centerX asFloat / centerY ]
				ifFalse: [ 1.0 ] ].
	whirlRadians := -3.141592653589793 * degrees / 180.0.
	radiusSquared := (radius * radius) asFloat.
	0 to: width - 1 do: [ :x | 
		0 to: height - 1 do: [ :y | 
			dx := scaleX * (x - centerX) asFloat.
			dy := scaleY * (y - centerY) asFloat.
			d := dx * dx + (dy * dy).
			d < radiusSquared
				ifTrue: [ 
					"inside the whirl circle"
					factor := 1.0 - (d sqrt / radius).
					ang := whirlRadians * (factor * factor).
					sina := ang sin.
					cosa := ang cos.
					pix := self
						interpolatedFrom: in
						x: (1024.0 * ((cosa * dx - (sina * dy)) / scaleX + centerX)) asInteger
						y: (1024.0 * ((sina * dx + (cosa * dy)) / scaleY + centerY)) asInteger
						width: width
						height: height.
					out at: width * y + x put: pix	"for Squeak: + 1" ] ] ].
	interpreterProxy pop: 4.	"pop args, leave rcvr on stack"
	^ 0
]
