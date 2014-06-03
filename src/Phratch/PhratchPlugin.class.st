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

{ #category : #'image filter primitives' }
PhratchPlugin class >> primFisheye: inBitmap into: outBitmap width: w power: anInteger [
	"Do a fisheye lens transform of the given 32-bit image bitmap by the given power, storing the result in outBitmap. The two bitmaps must be the same size. Power is 0 for no change, > 0 for fisheye, < 0 for black hole effect."

	<primitive: 'primitiveFisheye' module: #ScratchPlugin>
	self primitiveFailed

]

{ #category : #'OS utilities' }
PhratchPlugin class >> primOpenURL: aString [
	"Open a browser window on the given URL. Do nothing if the primitive fails."
	"self primOpenURL: 'http://www.google.com'"

	<primitive: 'primitiveOpenURL' module: #ScratchPlugin>
	DialogBoxMorph inform: 'Could not open this file' localized
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
