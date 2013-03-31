"
This plugin measures and renders Unicode (UTF8) strings.

"
Class {
	#name : #UnicodePlugin,
	#superclass : #InterpreterPlugin,
	#category : #'Phratch-Primitives-Plugins'
}

{ #category : #translation }
UnicodePlugin class >> declareCVarsIn: aCCodeGenerator [
	"self translate"

	super declareCVarsIn: aCCodeGenerator.
	aCCodeGenerator cExtras: '
int unicodeClipboardGet(unsigned short *utf16, int utf16Length);
void unicodeClipboardPut(unsigned short *utf16, int utf16Length);
int unicodeClipboardSize(void);
void unicodeDrawString(char *utf8, int utf8Length, int *wPtr, int *hPtr, unsigned int *bitmapPtr);
int unicodeGetFontList(char *str, int strLength);
int unicodeGetXRanges(char *utf8, int utf8Length, int *resultPtr, int resultLength);
void unicodeMeasureString(char *utf8, int utf8Length, int *wPtr, int *hPtr);
void unicodeSetColors(int fgRed, int fgGreen, int fgBlue, int bgRed, int bgGreen, int bgBlue, int mapBGToTransparent);
void unicodeSetFont(char *fontName, int fontSize, int boldFlag, int italicFlag, int antiAliasFlag);
'
]

{ #category : #utilities }
UnicodePlugin class >> drawString: utf8 on: f [

	^ self primDrawString: utf8 w: f width h: f height bits: f bits

]

{ #category : #utilities }
UnicodePlugin class >> getFontList [
	"Answer a list of fonts."
	"self getFontList"

	| buf count result |
	buf := String new: 100000.
	count := self primGetFontListInto: buf.
	result := (buf copyFrom: 1 to: count) lines asSet asArray.
	result := result select: [:s |
		s size > 0 and: [('.#@' includes: s first) not]].

	^ result sort


]

{ #category : #primitives }
UnicodePlugin class >> primCliboardPut: aSoundBuffer size: anInteger [
	"Save the given UTF16 string (a SoundBuffer to the clipboard as Unicode text.."

	<primitive: 'primitiveClipboardPut' module: 'UnicodePlugin'>

]

{ #category : #primitives }
UnicodePlugin class >> primClipboardSize [
	"Return the number of UTF16 characters in the clipboard."

	<primitive: 'primitiveClipboardSize' module: 'UnicodePlugin'>
	^ 0

]

{ #category : #primitives }
UnicodePlugin class >> primDrawString: utf8 w: w h: h bits: aBitmap [
	"Draw a UTF-8 string onto a 32-bit deep bitmap of the given dimensions. Use the current font and colors. Return the extent of the rendered string (even if it is larger or smaller than the bitmap)."

	<primitive: 'primitiveDrawString' module: 'UnicodePlugin'>
	self primitiveFailed

]

{ #category : #primitives }
UnicodePlugin class >> primGetCliboardInto: aSoundBuffer [
	"Copy the clipboard into the given SoundBuffer as UTF16 format. Return the number of UTF16 characters."

	<primitive: 'primitiveClipboardGet' module: 'UnicodePlugin'>
	^ 0

]

{ #category : #primitives }
UnicodePlugin class >> primGetFontListInto: aString [
	"Copy a list of available fonts into the given string, one per line, and return the number of characters in the result."

	<primitive: 'primitiveGetFontList' module: 'UnicodePlugin'>
	^ 0

]

{ #category : #primitives }
UnicodePlugin class >> primGetXRanges: utf8 into: aBitmap [
	"Compute the starting and ending X coordiantes for the characters of the given UTF-8 string when rendered with the current font. Return the number of start/stop pairs or -1 if there is an error. The results are stored into the given Bitmap object, which should have room for at least two times the number of Unicode code points in the given string. (A conservative estimate of the number of codepoints is the number of utf8 bytes.)"

	<primitive: 'primitiveGetXRanges' module: 'UnicodePlugin'>
	self primitiveFailed

]

{ #category : #primitives }
UnicodePlugin class >> primMeasureString: utf8 [
	"Return the extent of the given UTF-8 string when rendered with the current font."

	<primitive: 'primitiveMeasureString' module: 'UnicodePlugin'>
	self primitiveFailed

]

{ #category : #primitives }
UnicodePlugin class >> primSetColorfgRed: r1 fgGreen: g1 fgBlue: b1 bgRed: r2 bgGreen: g2 bgBlue: b2 mapBGToTransparent: aBoolean [
	"Set the text foreground and background colors. If mapBGToTransparent is true, then the background color is mapped to transparent (but it is still used for anti-aliasing). This typically adds 20-30% to the rendering time--more for larger fonts."

	<primitive: 'primitiveSetColors' module: 'UnicodePlugin'>
	self primitiveFailed

]

{ #category : #primitives }
UnicodePlugin class >> primSetFont: fontName size: fontSize bold: boldFlag italic: italicFlag antialias: antialiasFlag [
	"Set the font characteristics to be used on subsequent calls to draw or measure strings."

	<primitive: 'primitiveSetFont' module: 'UnicodePlugin'>
	self primitiveFailed

]

{ #category : #utilities }
UnicodePlugin class >> rawXRanges: utf8 [
	"Anwer the raw xRange array for the given Unicode string."

	| ranges count |
	ranges := Bitmap new: 2 * utf8 size.
	count := UnicodePlugin primGetXRanges: utf8 into: ranges.
	count < 0 ifTrue: [self error: 'Error in Unicode XRange primitive'].
	^ (ranges copyFrom: 1 to: 2 * count) asArray


]

{ #category : #utilities }
UnicodePlugin class >> setColorFG: fgColor BG: bgColor bgTransparent: aBoolean [
	"Set my foreground and background colors. The background color is used for antialiasing. If bgTransparent is true the background is mapped to transparent where no text appears."

	self primSetColorfgRed: fgColor r255 fgGreen: fgColor g255 fgBlue: fgColor b255
					bgRed: bgColor r255 bgGreen: bgColor g255 bgBlue: bgColor b255
		mapBGToTransparent: aBoolean.

]

{ #category : #testing }
UnicodePlugin class >> test1 [
	"self test1"

	| s f extent |
	s := 'ÅØÖABC abc 123' asUTF8.
	self primSetFont: 'Times' size: 21 bold: false italic: false antialias: true.
	self primSetColorfgRed: 255 fgGreen: 255 fgBlue: 255 bgRed: 100 bgGreen: 20 bgBlue: 120 mapBGToTransparent: false.
	f := Form extent:(self primMeasureString: s) depth: 32.
	extent := self drawString: s on: f.
	(f magnifyBy: 4) displayOn: Display at: 10@10 rule: Form paint.
	^ extent

]

{ #category : #testing }
UnicodePlugin class >> test2 [
	"self test2"

	| f y |
	self primSetFont: 'Times' size: 36 bold: false italic: false antialias: true.
	self setColorFG: Color black BG: Color white bgTransparent: false.
	y := 5.
	self testStrings do: [:s |
		f := Form extent: 800@50 depth: 32.
		self drawString: s on: f.
		f displayOn: Display at: 5@y rule: Form paint.
		y := y + f height].

]

{ #category : #testing }
UnicodePlugin class >> test3 [
	"Display fillWhite. self test3"

	| y extent f extent2 |
	self primSetFont: 'Times' size: 36 bold: false italic: false antialias: true.
	self setColorFG: Color black BG: Color white bgTransparent: false.
	y := 5.
	^ self testStrings collect: [:s |
		extent := self primMeasureString: s.
		f := Form extent: extent depth: 32.
		extent2 := self drawString: s on: f.
		Display fill: ((5@y) - 1 extent: extent + 2) fillColor: Color green.
		f displayOn: Display at: 5@y rule: Form paint.
		y := y + extent y + 5.
		Array with: extent with: extent2]


]

{ #category : #testing }
UnicodePlugin class >> test4 [
	"Tests the xRangesFor: primitive."
	"self test4"

	| f e rList |
	UnicodePlugin primSetColorfgRed: 0 fgGreen: 0 fgBlue: 0
		bgRed: 255 bgGreen: 255 bgBlue: 255 mapBGToTransparent: false.

	self testStrings do: [:s |
		self primSetFont: 'Times' size: 48 bold: false italic: false antialias: true.
		f := Form extent:(self primMeasureString: s) depth: 32.
		e := self drawString: s on: f.
		rList := self xRangesFor: s.

		rList do: [:r |
			f display.
			Display reverse: ((r first@0) corner: (r second@e y)).
			Sensor keyboardPressed. "this allows you to interrupt by hitting alt-."
			(Delay forMilliseconds: 200) wait].

		Display fill: f boundingBox fillColor: Color white].

	Display restore.


]

{ #category : #testing }
UnicodePlugin class >> testStrings [
	"Answer a set of test strings in various languages/character sets."

	^ '√âg get eti√∞ gler √°n √æess a√∞ mei√∞a mig.
ÿ£ŸÜÿß ŸÇÿßÿØÿ± ÿπŸÑŸâ ÿ£ŸÉŸÑ ÿßŸÑÿ≤ÿ¨ÿßÿ¨ Ÿà Ÿáÿ∞ÿß ŸÑÿß Ÿäÿ§ŸÑŸÖŸÜŸä.
‡§Æ‡•à‡§Ç ‡§ï‡§æ‡§Å‡§ö ‡§ñ‡§æ ‡§∏‡§ï‡§§‡§æ ‡§π‡•Ç‡§Å, ‡§Æ‡•Å‡§ù‡•á ‡§â‡§∏ ‡§∏‡•á ‡§ï‡•ã‡§à ‡§™‡•Ä‡§°‡§æ ‡§®‡§π‡•Ä‡§Ç ‡§π‡•ã‡§§‡•Ä.
◊ê◊ô◊ö ◊ß◊¢◊ü ◊¢◊°◊ü ◊í◊ú◊ê÷∏◊ñ ◊ê◊ï◊ü ◊¢◊° ◊ò◊ï◊ò ◊û◊ô◊® ◊†◊ô◊©◊ò ◊∞◊≤
ÊàëËÉΩÂêû‰∏ãÁéªÁíÉËÄå‰∏ç‰º§Ë∫´‰Ωì„ÄÇ
ÁßÅ„ÅØ„Ç¨„É©„Çπ„ÇíÈ£ü„Åπ„Çâ„Çå„Åæ„Åô„ÄÇ„Åù„Çå„ÅØÁßÅ„ÇíÂÇ∑„Å§„Åë„Åæ„Åõ„Çì„ÄÇ
ÎÇòÎäî Ïú†Î¶¨Î•º Î®πÏùÑ Ïàò ÏûàÏñ¥Ïöî. Í∑∏ÎûòÎèÑ ÏïÑÌîÑÏßÄ ÏïäÏïÑÏöî
‡∏â‡∏±‡∏ô‡∏Å‡∏¥‡∏ô‡∏Å‡∏£‡∏∞‡∏à‡∏Å‡πÑ‡∏î‡πâ ‡πÅ‡∏ï‡πà‡∏°‡∏±‡∏ô‡πÑ‡∏°‡πà‡∏ó‡∏≥‡πÉ‡∏´‡πâ‡∏â‡∏±‡∏ô‡πÄ‡∏à‡πá‡∏ö
ŸÖŸÜ ÿ∫Ÿäÿ± abc ÿßŸÑŸÖŸÖŸÉŸÜ 123 ŸÉÿ™ÿßÿ®ÿ© ÿßŸÑŸÖŸÑŸÅ' lines

]

{ #category : #utilities }
UnicodePlugin class >> xRangesFor: utf8 [
	"Anwer an array of (leftX, rightX) pairs for the given Unicode string. There will be an entry in the resulting array for each UTF character in the input string, even when characters combine. Thus, in general, the x ranges for characters can overlap."

	| ranges count result left right |
	ranges := Bitmap new: 2 * utf8 size.
	count := UnicodePlugin primGetXRanges: utf8 into: ranges.
	count < 0 ifTrue: [self error: 'Error in Unicode XRange primitive'].
	count = 0 ifTrue: [count := utf8 size]. "workaround in case primitive fails"
	result := Array new: count.
	1 to: result size do: [:i |
		left := ranges at: (2 * i) - 1.
		right := ranges at: 2 * i.
		left <= right
			ifTrue: [result at: i put: (Array with: left with: right)]
			ifFalse: [result at: i put: (Array with: right with: left)]].

	^ result

]

{ #category : #utility }
UnicodePlugin >> asCString: stringOop [
	"Return a C char * pointer into the given Squeak string object."
	"Warning: A Squeak string is not necessarily null-terminated."
	"Warning: the resulting pointer may become invalid after the next garbage collection and should only be using during the current primitive call."

	self inline: false.
	self returnTypeC: 'char *'.

	((interpreterProxy isIntegerObject: stringOop) or:
	 [(interpreterProxy isBytes: stringOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].

	^ self cCoerce: (interpreterProxy firstIndexableField: stringOop) to: 'char *'

]

{ #category : #utility }
UnicodePlugin >> cWordsPtr: oop minSize: minSize [
	"Return a C pointer to the first indexable field of oop, which must be a words object of at least the given size."
	"Warning: the resulting pointer may become invalid after the next garbage collection and should only be using during the current primitive call."

	self inline: false.
	self returnTypeC: 'void *'.

	interpreterProxy success:
		((interpreterProxy isIntegerObject: oop) not and:
		 [(interpreterProxy isWords: oop) and:
		 [(interpreterProxy stSizeOf: oop) >= minSize]]).
	interpreterProxy failed ifTrue: [^ 0].
	^ self cCoerce: (interpreterProxy firstIndexableField: oop) to: 'void *'

]

{ #category : #utility }
UnicodePlugin >> copyString: stringOop into: stringPtr max: maxChars [
	"Copy the Squeak string into a temporary buffer and add a terminating null byte. Fail if there is not sufficent space in the buffer."

	| srcPtr count |
	self inline: false.
	self var: 'stringPtr' declareC: 'char *stringPtr'.
	self var: 'srcPtr' declareC: 'char *srcPtr'.

	((interpreterProxy isIntegerObject: stringOop) or:
	 [(interpreterProxy isBytes: stringOop) not]) ifTrue: [
		interpreterProxy success: false.
		^ 0].

	count := interpreterProxy stSizeOf: stringOop.
	count < maxChars ifFalse: [
		interpreterProxy success: false.
		^ 0].

	srcPtr := self cCoerce: (interpreterProxy firstIndexableField: stringOop) to: 'char *'.
	1 to: count do: [:i | self cCode: '*stringPtr++ = *srcPtr++'].
	self cCode: '*stringPtr = 0'.
	^ 0

]

{ #category : #primitives }
UnicodePlugin >> primitiveClipboardGet [
	"Read the clipboard into the given UTF16 string.."

	| utf16Oop utf16 utf16Length count |
	self export: true.
	self var: 'utf16' declareC: 'unsigned short *utf16'.

	utf16Oop := interpreterProxy stackValue: 0.

	((interpreterProxy isIntegerObject: utf16Oop) or:
	 [(interpreterProxy isWords: utf16Oop) not]) ifTrue: [
		interpreterProxy success: false].

	interpreterProxy failed ifTrue: [^ 0].

	utf16 := self cCoerce: (interpreterProxy firstIndexableField: utf16Oop) to: 'unsigned short *'.
	utf16Length := 2 * (interpreterProxy stSizeOf: utf16Oop).

	count := self cCode: 'unicodeClipboardGet(utf16, utf16Length)'.

	interpreterProxy pop: 2
		thenPush: (interpreterProxy integerObjectOf: count).

	^ 0

]

{ #category : #primitives }
UnicodePlugin >> primitiveClipboardPut [
	"Set the clipboard to a UTF16 string.."

	| strOop count utf16 utf16Length |
	self export: true.
	self var: 'utf16' declareC: 'unsigned short *utf16'.

	strOop := interpreterProxy stackValue: 1.
	count := interpreterProxy stackIntegerValue: 0.

	((interpreterProxy isIntegerObject: strOop) or:
	 [(interpreterProxy isWords: strOop) not]) ifTrue: [
		interpreterProxy success: false].

	interpreterProxy failed ifTrue: [^ 0].

	utf16 := self cCoerce: (interpreterProxy firstIndexableField: strOop) to: 'unsigned short *'.
	utf16Length := 2 * (interpreterProxy stSizeOf: strOop).
	((count >= 0) & (count < utf16Length)) ifTrue: [utf16Length := count].

	self cCode: 'unicodeClipboardPut(utf16, utf16Length)'.

	interpreterProxy pop: 2.  "pop args, leave rcvr on stack"
	^ 0

]

{ #category : #primitives }
UnicodePlugin >> primitiveClipboardSize [

	| count |
	self export: true.

	count := self cCode: 'unicodeClipboardSize()'.

	interpreterProxy pop: 1
		thenPush: (interpreterProxy integerObjectOf: count).
	^ 0

]

{ #category : #primitives }
UnicodePlugin >> primitiveDrawString [

	| utf8Oop utf8 w h bitmapOop bitmapPtr utf8Length result |
	self export: true.
	self var: 'utf8' declareC: 'char *utf8'.
	self var: 'bitmapPtr' declareC: 'void *bitmapPtr'.

	utf8Oop := interpreterProxy stackValue: 3.
	utf8 := self asCString: utf8Oop.
	w := interpreterProxy stackIntegerValue: 2.
	h := interpreterProxy stackIntegerValue: 1.
	bitmapOop := interpreterProxy stackValue: 0.
	bitmapPtr := self cWordsPtr: bitmapOop minSize: w * h.
	interpreterProxy failed ifTrue: [^ nil].

	utf8Length := interpreterProxy stSizeOf: utf8Oop.
	self cCode: 'unicodeDrawString(utf8, utf8Length, &w, &h, bitmapPtr)'.

	result := interpreterProxy makePointwithxValue: w yValue: h.
	interpreterProxy pop: 5 thenPush: result.
	^ 0

]

{ #category : #primitives }
UnicodePlugin >> primitiveGetFontList [


	| strOop str strLength count |
	self export: true.
	self var: 'str' declareC: 'char *str'.

	strOop := interpreterProxy stackValue: 0.
	str := self asCString: strOop.
	interpreterProxy failed ifTrue: [^ nil].

	strLength := interpreterProxy stSizeOf: strOop.
	count := self cCode: 'unicodeGetFontList(str, strLength)'.

	interpreterProxy pop: 2
		thenPush: (interpreterProxy integerObjectOf: count).
	^ 0

]

{ #category : #primitives }
UnicodePlugin >> primitiveGetXRanges [

	| utf8Oop utf8 resultOop resultPtr utf8Length count resultLength |
	self export: true.
	self var: 'utf8' declareC: 'char *utf8'.
	self var: 'resultPtr' declareC: 'int *resultPtr'.

	utf8Oop := interpreterProxy stackValue: 1.
	utf8 := self asCString: utf8Oop.

	resultOop := interpreterProxy stackValue: 0.
	resultPtr := self cWordsPtr: resultOop minSize: 0.
	interpreterProxy failed ifTrue: [^ nil].

	utf8Length := interpreterProxy stSizeOf: utf8Oop.
	resultLength := interpreterProxy stSizeOf: resultOop.
	count := self cCode: 'unicodeGetXRanges(utf8, utf8Length, resultPtr, resultLength)'.

	interpreterProxy pop: 3 thenPush: (interpreterProxy integerObjectOf: count).
	^ 0

]

{ #category : #primitives }
UnicodePlugin >> primitiveMeasureString [

	| utf8Oop utf8 utf8Length w h result |
	self export: true.
	self var: 'utf8' declareC: 'char *utf8'.

	utf8Oop := interpreterProxy stackValue: 0.
	utf8 := self asCString: utf8Oop.
	interpreterProxy failed ifTrue: [^ nil].

	w := h := 0.
	utf8Length := interpreterProxy stSizeOf: utf8Oop.
	self cCode: 'unicodeMeasureString(utf8, utf8Length, &w, &h)'.

	result := interpreterProxy makePointwithxValue: w yValue: h.
	interpreterProxy pop: 2 thenPush: result.
	^ 0

]

{ #category : #primitives }
UnicodePlugin >> primitiveSetColors [

	| fgRed fgGreen fgBlue bgRed bgGreen bgBlue mapBGToTransparent |
	self export: true.

	fgRed := interpreterProxy stackIntegerValue: 6.
	fgGreen := interpreterProxy stackIntegerValue: 5.
	fgBlue := interpreterProxy stackIntegerValue: 4.
	bgRed := interpreterProxy stackIntegerValue: 3.
	bgGreen := interpreterProxy stackIntegerValue: 2.
	bgBlue := interpreterProxy stackIntegerValue: 1.
	mapBGToTransparent := interpreterProxy booleanValueOf: (interpreterProxy stackValue: 0).
	interpreterProxy failed ifTrue: [^ nil].

	self cCode: 'unicodeSetColors(fgRed, fgGreen, fgBlue, bgRed, bgGreen, bgBlue, mapBGToTransparent)'.

	interpreterProxy pop: 7.
	^ 0

]

{ #category : #primitives }
UnicodePlugin >> primitiveSetFont [

	| fontName fontSize boldFlag italicFlag antiAliasFlag |
	self export: true.
	self var: 'fontName' declareC: 'char fontName[200]'.

	self copyString: (interpreterProxy stackValue: 4) into: fontName max: 200.
	fontSize := interpreterProxy stackIntegerValue: 3.
	boldFlag := interpreterProxy booleanValueOf: (interpreterProxy stackValue: 2).
	italicFlag := interpreterProxy booleanValueOf: (interpreterProxy stackValue: 1).
	antiAliasFlag := interpreterProxy booleanValueOf: (interpreterProxy stackValue: 0).
	interpreterProxy failed ifTrue: [^ nil].

	self cCode: 'unicodeSetFont(fontName, fontSize, boldFlag, italicFlag, antiAliasFlag)'.

	interpreterProxy pop: 5.
	^ 0

]
