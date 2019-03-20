"
An Ev3BrickButton is xxxxxxxxx.

"
Class {
	#name : #Ev3Screen,
	#superclass : #Ev3Block,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3Screen class >> fontType [
	^ { #Small -> 0 . #Medium -> 1 . #Large -> 2} asDictionary.
]

{ #category : #'as yet unclassified' }
Ev3Screen class >> height [

	^ 128
]

{ #category : #'as yet unclassified' }
Ev3Screen class >> topLineHeight [

	^ 10
]

{ #category : #'as yet unclassified' }
Ev3Screen class >> uiColor [
	^ { #Background -> 0 . #Foreground -> 1} asDictionary.
]

{ #category : #'as yet unclassified' }
Ev3Screen class >> width [

	^ 178
]

{ #category : #'as yet unclassified' }
Ev3Screen >> cleanUI [

	^ self cleanUIreply: false
]

{ #category : #'as yet unclassified' }
Ev3Screen >> cleanUIreply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #UIDraw).
	command appendByte: (Ev3Command uiDrawSubCodes at: #Clean).
					
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawCircleColor: aColor x0: x0 y0: y0 radius: r filled: filled [

	^ self drawCircleColor: aColor x0: x0 y0: y0 radius: r filled: filled reply: false
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawCircleColor: aColor x0: x0 y0: y0 radius: r filled: filled reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #UIDraw).
	filled ifTrue:[
		command appendByte: (Ev3Command uiDrawSubCodes at: #FillCircle).
	] ifFalse: [ 
		command appendByte: (Ev3Command uiDrawSubCodes at: #Circle).
	].
	command appendByte: (Ev3Screen uiColor at: aColor).
	
	command addInt16Value: (x0 min: (Ev3Screen width -1) max: 0).
	command addInt16Value: (y0 min: (Ev3Screen height -1) max: 0).
	command addInt16Value: r.
					
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawDottedLineColor: aColor x0: x0 y0: y0 x1: x1 y1: y1 onPixels: on offPixels: off [ 
	
	^ self drawDottedLineColor: aColor x0: x0 y0: y0 x1: x1 y1: y1 onPixels: on offPixels: off reply: false
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawDottedLineColor: aColor x0: x0 y0: y0 x1: x1 y1: y1 onPixels: on offPixels: off reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #UIDraw).
	command appendByte: (Ev3Command uiDrawSubCodes at: #DotLine).
	command appendByte: (Ev3Screen uiColor at: aColor).
	
	command addInt16Value: (x0 min: (Ev3Screen width -1) max: 0).
	command addInt16Value: (y0 min: (Ev3Screen height -1) max: 0).
	command addInt16Value: (x1 min: (Ev3Screen width -1) max: 0).
	command addInt16Value: (y1 min: (Ev3Screen height -1) max: 0).
	command addInt16Value: on.
	command addInt16Value: off.
					
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawFillWindowColor: aColor y0: y0 y1: y1 [ 

	^ self drawFillWindowColor: aColor y0: y0 y1: y1 reply: false
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawFillWindowColor: aColor y0: y0 y1: y1 reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #UIDraw).
	command appendByte: (Ev3Command uiDrawSubCodes at: #FillWindow).
	command appendByte: (Ev3Screen uiColor at: aColor).
	
	
	command addInt16Value: (y0 min: (Ev3Screen height -1) max: 0).
	command addInt16Value: (y1 min: (Ev3Screen height -1) max: 0).
					
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawImageColor: aColor x0: x0 y0: y0 path: aDevicePathToBmpFile [
	
	^ self drawImageColor: aColor x0: x0 y0: y0 path: aDevicePathToBmpFile reply: false
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawImageColor: aColor x0: x0 y0: y0 path: aDevicePathToBmpFile reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #UIDraw).
	command appendByte: (Ev3Command uiDrawSubCodes at: #BmpFile).
	command appendByte: (Ev3Screen uiColor at: aColor).
	command addInt16Value: (x0 min: (Ev3Screen width -1) max: 0).
	command addInt16Value: (y0 min: (Ev3Screen height -1) max: 0).
	command appendString: aDevicePathToBmpFile constantParameterType: (Ev3Command constantParameterType at: #Value ).
					
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawInverseRectangleX0: x0 y0: y0 width: w height: h [
	
	^ self drawInverseRectangleX0: x0 y0: y0 width: w height: h reply: false
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawInverseRectangleX0: x0 y0: y0 width: w height: h reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #UIDraw).
	command appendByte: (Ev3Command uiDrawSubCodes at: #InverseRect).
	
	
	command addInt16Value: (x0 min: (Ev3Screen width -1) max: 0).
	command addInt16Value: (y0 min: (Ev3Screen height -1) max: 0).
	command addInt16Value: (w min: (Ev3Screen width -1) max: 0).
	command addInt16Value: (h min: (Ev3Screen height -1) max: 0).
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawLineColor: aColor x0: x0 y0: y0 x1: x1 y1: y1 [
	
	^ self drawLineColor: aColor x0: x0 y0: y0 x1: x1 y1: y1 reply: false
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawLineColor: aColor x0: x0 y0: y0 x1: x1 y1: y1 reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #UIDraw).
	command appendByte: (Ev3Command uiDrawSubCodes at: #Line).
	command appendByte: (Ev3Screen uiColor at: aColor).
	
	command addInt16Value: (x0 min: (Ev3Screen width -1) max: 0).
	command addInt16Value: (y0 min: (Ev3Screen height -1) max: 0).
	command addInt16Value: (x1 min: (Ev3Screen width -1) max: 0).
	command addInt16Value: (y1 min: (Ev3Screen height -1) max: 0).
	
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawPixelColor: aColor x0: x0 y0: y0 [
	
	^ self drawPixelColor: aColor x0: x0 y0: y0 reply: false
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawPixelColor: aColor x0: x0 y0: y0 reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #UIDraw).
	command appendByte: (Ev3Command uiDrawSubCodes at: #Pixel).
	command appendByte: (Ev3Screen uiColor at: aColor).
	command addInt16Value: (x0 min: (Ev3Screen width -1) max: 0).
	command addInt16Value: (y0 min: (Ev3Screen height -1) max: 0).
					
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawRectangleColor: aColor x0: x0 y0: y0 width: w height: h filled: filled [
	
	^ self drawRectangleColor: aColor x0: x0 y0: y0 width: w height: h filled: filled reply: false
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawRectangleColor: aColor x0: x0 y0: y0 width: w height: h filled: filled reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #UIDraw).
	filled ifTrue:[
		command appendByte: (Ev3Command uiDrawSubCodes at: #FillRect).
	] ifFalse: [ 
		command appendByte: (Ev3Command uiDrawSubCodes at: #Rect).
	].
	command appendByte: (Ev3Screen uiColor at: aColor).
	command addInt16Value: (x0 min: (Ev3Screen width -1) max: 0).
	command addInt16Value: (y0 min: (Ev3Screen height -1) max: 0).
	command addInt16Value: (w min: (Ev3Screen width -1) max: 0).
	command addInt16Value: (h min: (Ev3Screen height -1) max: 0).
					
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawTextColor: aColor x0: x0 y0: y0  text: aString [
	
	^ self drawTextColor: aColor x0: x0 y0: y0  text: aString reply: false
]

{ #category : #'as yet unclassified' }
Ev3Screen >> drawTextColor: aColor x0: x0 y0: y0  text: aString reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #UIDraw).
	command appendByte: (Ev3Command uiDrawSubCodes at: #Text).
	command appendByte: (Ev3Screen uiColor at: aColor).
	
	command addInt16Value: (x0 min: (Ev3Screen width -1) max: 0).
	command addInt16Value: (y0 min: (Ev3Screen height -1) max: 0).
	command appendString: aString constantParameterType: (Ev3Command constantParameterType at: #Value ).
				
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Screen >> enableTopLine: boolForTopLine [
	
	^ self enableTopLine: boolForTopLine reply: false
]

{ #category : #'as yet unclassified' }
Ev3Screen >> enableTopLine: boolForTopLine reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #UIDraw).
	command appendByte: (Ev3Command uiDrawSubCodes at: #Topline).
	
	boolForTopLine ifTrue: [ 
		command appendByte: 1.
	] ifFalse: [ 
		command appendByte: 0.
	].
					
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Screen >> selectFontType: aFontType [ 
	
	^ self selectFontType: aFontType reply: false
]

{ #category : #'as yet unclassified' }
Ev3Screen >> selectFontType: aFontType reply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #UIDraw).
	command appendByte: (Ev3Command uiDrawSubCodes at: #SelectFont).
	command appendByte: (Ev3Screen fontType at: aFontType).
					
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]

{ #category : #'as yet unclassified' }
Ev3Screen >> updateUI [
	
	^ self updateUIReply: false
]

{ #category : #'as yet unclassified' }
Ev3Screen >> updateUIReply: aBool [

	|command reply|
	command := Ev3Command newGlobal: 0 local: 0 sequence: (self currentSequenceNumber) reply: aBool.
	command appendByte: (Ev3Command byteCodes at: #UIDraw).
	command appendByte: (Ev3Command uiDrawSubCodes at: #Update).
					
	reply := self brick sendCommand: command withReply: aBool.
	^reply
]
