"
This plugin is used to measure and display UTF-8 strings using Pango as the underlying rendering engine.

"
Class {
	#name : #PangoPlugin2,
	#superclass : #InterpreterPlugin,
	#category : #'Phratch-Primitives-Plugins'
}

{ #category : #translation }
PangoPlugin2 class >> declareCVarsIn: aCCodeGenerator [
	"self translate"

	super declareCVarsIn: aCCodeGenerator.
	aCCodeGenerator cExtras: '
void pango2DrawString(char *utf8, int utf8Length, int *wPtr, int *hPtr, unsigned char *bitmapPtr);
int pango2GetXRanges(char *utf8, int utf8Length, int *resultPtr, int resultLength);
void pango2MeasureString(char *utf8, int utf8Length, int *wPtr, int *hPtr, int *layoutDetailsPtr);
void pango2SetColors(int fgRed, int fgGreen, int fgBlue, int bgRed, int bgGreen, int bgBlue, int mapBGToTransparent);
void pango2SetFont(char *fontName, int fontSize, int boldFlag, int italicFlag, int antiAliasFlag);
void pango2SetLanguage(char* lang);
'.

]

{ #category : #utilities }
PangoPlugin2 class >> drawString: utf8 on: f [

	f unhibernate.
	self assert: [f depth = 32].
	^ self primDrawString: utf8 w: f width h: f height bits: f bits

]

{ #category : #primitives }
PangoPlugin2 class >> primDrawString: utf8 w: w h: h bits: aBitmap [
	"Draw a UTF-8 string onto a 32-bit deep bitmap of the given dimensions. Use the current font and colors. Return the extent of the rendered string (even if it is larger or smaller than the bitmap)."

	<primitive: 'primitiveDrawString' module: 'PangoPlugin2'>
	self primitiveFailed

]

{ #category : #primitives }
PangoPlugin2 class >> primGetXRanges: utf8 into: aBitmap [
	"Compute the starting and ending X coordiantes for the characters of the given UTF-8 string when rendered with the current font. Return the number of start/stop pairs or -1 if there is an error. The results are stored into the given Bitmap object, which should have room for at least two times the number of Unicode code points in the given string. (A conservative estimate of the number of codepoints is the number of utf8 bytes.)"

	<primitive: 'primitiveGetXRanges' module: 'PangoPlugin2'>
	self primitiveFailed

]

{ #category : #primitives }
PangoPlugin2 class >> primMeasureString: utf8 [
	"Return the extent of the given UTF-8 string when rendered with the current font."

	<primitive: 'primitiveMeasureString' module: 'PangoPlugin2'>
	self primitiveFailed

]

{ #category : #primitives }
PangoPlugin2 class >> primMeasureString: utf8 details: aBitmap [
	"Return the extent of the given UTF-8 string when rendered with the current font. Store the layout details into the given nine-element bitmap. On return, this bitmap contains:
	inkRect left, top, width, height
	logicalRect left, top, width, height
	baseline
All numbers are pixel offsets from the top-left corner of the Form into which the string will be rendered."

	<primitive: 'primitiveMeasureStringDetails' module: 'PangoPlugin2'>
	self primitiveFailed

]

{ #category : #primitives }
PangoPlugin2 class >> primSetColorfgRed: r1 fgGreen: g1 fgBlue: b1 bgRed: r2 bgGreen: g2 bgBlue: b2 mapBGToTransparent: aBoolean [
	"Set the text foreground and background colors. If mapBGToTransparent is true, then the background color is mapped to transparent (but it is still used for anti-aliasing). This typically adds 20-30% to the rendering time--more for larger fonts."

	<primitive: 'primitiveSetColors' module: 'PangoPlugin2'>
	self primitiveFailed

]

{ #category : #primitives }
PangoPlugin2 class >> primSetFont: fontName size: fontSize bold: boldFlag italic: italicFlag antialias: antialiasFlag [
	"Set the font characteristics to be used on subsequent calls to draw or measure strings."

	<primitive: 'primitiveSetFont' module: 'PangoPlugin2'>
	self primitiveFailed

]

{ #category : #primitives }
PangoPlugin2 class >> primSetLanguage: aString [
	"Set the language to the given ISO-3066 language tag."

	<primitive: 'primitiveSetLanguage' module: 'PangoPlugin2'>
	self primitiveFailed

]

{ #category : #utilities }
PangoPlugin2 class >> setColorFG: fgColor BG: bgColor bgTransparent: aBoolean [
	"Set my foreground and background colors. The background color is used for antialiasing. If bgTransparent is true the background is mapped to transparent where no text appears."

	self primSetColorfgRed: fgColor r255 fgGreen: fgColor g255 fgBlue: fgColor b255
					bgRed: bgColor r255 bgGreen: bgColor g255 bgBlue: bgColor b255
		mapBGToTransparent: aBoolean.

]

{ #category : #testing }
PangoPlugin2 class >> test1 [
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
PangoPlugin2 class >> test2 [
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
PangoPlugin2 class >> test3 [
	"Display fillWhite. self test3"

	| y details extent f |
	self primSetFont: 'Times' size: 36 bold: false italic: false antialias: true.
	self setColorFG: Color black BG: Color white bgTransparent: false.
	y := 5.
	^ self testStrings collect: [:s |
		details := Bitmap new: 9.
		extent := self primMeasureString: s details: details.
		f := Form extent: extent depth: 32.
		self drawString: s on: f.
		Display fill: ((5@y) - 1 extent: extent + 2) fillColor: Color green.
		f displayOn: Display at: 5@y rule: Form paint.
		Display fill: ((5@(y + details last)) extent: (f width@1)) fillColor: (Color yellow alpha: 0.2).
		y := y + extent y + 5.
		Array with: extent with: details asArray]


]

{ #category : #testing }
PangoPlugin2 class >> test4 [
	"Tests the xRangesFor: primitive."
	"self test4"

	| f e rList |
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
PangoPlugin2 class >> testArabic [
	"self testArabic"

	| s f extent |
	self primSetFont: 'Verdana' size: 24 bold: false italic: false antialias: true.
	self setColorFG: Color black BG: Color white bgTransparent: false.
	s := 'ÿ£ŸÜÿß ŸÇÿßÿØÿ± ÿπŸÑŸâ ÿ£ŸÉŸÑ ÿßŸÑÿ≤ÿ¨ÿßÿ¨ Ÿà Ÿáÿ∞ÿß ŸÑÿß Ÿäÿ§ŸÑŸÖŸÜŸä.'.
	f := Form extent: 600@50 depth: 32.
	extent := self drawString: s on: f.
	f displayOn: Display at: 10@10 rule: Form paint.

	f := Form extent: (self primMeasureString: s) depth: 32.
	extent := self drawString: s on: f.
	f displayOn: Display at: 10@100 rule: Form paint.

	^ extent

]

{ #category : #testing }
PangoPlugin2 class >> testArabic2 [
	"self testArabic2 asArray (1 5 486 37 0 0 488 38 31)"

	| s f extent details |
	self primSetFont: 'Verdana' size: 24 bold: false italic: false antialias: true.
	self setColorFG: Color black BG: Color white bgTransparent: false.
	s := 'ÿ£ŸÜÿß ŸÇÿßÿØÿ± ÿπŸÑŸâ ÿ£ŸÉŸÑ ÿßŸÑÿ≤ÿ¨ÿßÿ¨ Ÿà Ÿáÿ∞ÿß ŸÑÿß Ÿäÿ§ŸÑŸÖŸÜŸä.'.
	f := Form extent: 600@50 depth: 32.
	extent := self drawString: s on: f.
	f displayOn: Display at: 10@10 rule: Form paint.

	f := Form extent: (self primMeasureString: s) depth: 32.
	extent := self drawString: s on: f.
	f displayOn: Display at: 10@100 rule: Form paint.

	details := Bitmap new: 9.
	extent := self primMeasureString: s details: details.
	^ details

]

{ #category : #testing }
PangoPlugin2 class >> testCyrillic [
	"self testCyrillic"
	"Cyrillic is: U+0400 to U+052F"

	| lines ch y f extent |
	lines := OrderedCollection new.
	ch := 16r400.
	19 timesRepeat: [
		lines addLast: (UTF32 withAll: (ch to: ch + 15)) asUTF8.
		ch := ch + 16].
	self primSetFont: 'Times' size: 36 bold: false italic: false antialias: true.
	self setColorFG: Color black BG: Color white bgTransparent: false.
	y := 5.
	lines do: [:s |
		extent := self primMeasureString: s.
		f := Form extent: extent depth: 32.
		self drawString: s on: f.
		f displayOn: Display at: 5@y rule: Form paint.
		y := y + f height - 5].


]

{ #category : #testing }
PangoPlugin2 class >> testHanSubstitution: lang [
	"See if the language setting changes the rendering of certain Chinese/Japanese/Korean characters."
	"self testHanSubstitution: 'en'"
	"self testHanSubstitution: 'ko'"
	"self testHanSubstitution: 'ja'"
	"self testHanSubstitution: 'zh'"

	| s1 s2 y extent f |
	s1 := '"grass" (U+8349): Ëçâ'.
	s2 := '"one" in Chinese, Japanese, and Korean: Â£π, Â£±, ‰∏Ä'.

	self primSetLanguage: lang.
	self primSetFont: 'serif' size: 24 bold: false italic: true antialias: true.
	y := 5.
	{s1. s2} do: [:s |
		extent := self primMeasureString: s.
		f := Form extent: extent depth: 32.
		self drawString: s on: f.
		f displayOn: Display at: 5@y rule: Form paint.
		y := y + f height].

]

{ #category : #testing }
PangoPlugin2 class >> testKannada [
	"self testKannada"

	| lines ch y f extent |
	lines := OrderedCollection new.
	ch := 16rC80.
	8 timesRepeat: [
		lines addLast: (UTF32 withAll: (ch to: ch + 15)) asUTF8.
		ch := ch + 16].
	self primSetFont: 'Times' size: 36 bold: false italic: false antialias: true.
	self setColorFG: Color black BG: Color white bgTransparent: false.
	y := 5.
	lines do: [:s |
		extent := self primMeasureString: s.
		f := Form extent: extent depth: 32.
		self drawString: s on: f.
		f displayOn: Display at: 5@y rule: Form paint.
		y := y + f height - 5].


]

{ #category : #testing }
PangoPlugin2 class >> testStrings [
	"Answer a set of test strings in various languages/character sets."

	^ '√âg get eti√∞ gler √°n √æess a√∞ mei√∞a mig.
ÿ£ŸÜÿß ŸÇÿßÿØÿ± ÿπŸÑŸâ ÿ£ŸÉŸÑ ÿßŸÑÿ≤ÿ¨ÿßÿ¨ Ÿà Ÿáÿ∞ÿß ŸÑÿß Ÿäÿ§ŸÑŸÖŸÜŸä.
‡§Æ‡•à‡§Ç ‡§ï‡§æ‡§Å‡§ö ‡§ñ‡§æ ‡§∏‡§ï‡§§‡§æ ‡§π‡•Ç‡§Å, ‡§Æ‡•Å‡§ù‡•á ‡§â‡§∏ ‡§∏‡•á ‡§ï‡•ã‡§à ‡§™‡•Ä‡§°‡§æ ‡§®‡§π‡•Ä‡§Ç ‡§π‡•ã‡§§‡•Ä.
◊ê◊ô◊ö ◊ß◊¢◊ü ◊¢◊°◊ü ◊í◊ú◊ê÷∏◊ñ ◊ê◊ï◊ü ◊¢◊° ◊ò◊ï◊ò ◊û◊ô◊® ◊†◊ô◊©◊ò ◊∞◊≤
ÊàëËÉΩÂêû‰∏ãÁéªÁíÉËÄå‰∏ç‰º§Ë∫´‰Ωì„ÄÇ
ÁßÅ„ÅØ„Ç¨„É©„Çπ„ÇíÈ£ü„Åπ„Çâ„Çå„Åæ„Åô„ÄÇ„Åù„Çå„ÅØÁßÅ„ÇíÂÇ∑„Å§„Åë„Åæ„Åõ„Çì„ÄÇ
ÎÇòÎäî Ïú†Î¶¨Î•º Î®πÏùÑ Ïàò ÏûàÏñ¥Ïöî. Í∑∏ÎûòÎèÑ ÏïÑÌîÑÏßÄ ÏïäÏïÑÏöî
‡∏â‡∏±‡∏ô‡∏Å‡∏¥‡∏ô‡∏Å‡∏£‡∏∞‡∏à‡∏Å‡πÑ‡∏î‡πâ ‡πÅ‡∏ï‡πà‡∏°‡∏±‡∏ô‡πÑ‡∏°‡πà‡∏ó‡∏≥‡πÉ‡∏´‡πâ‡∏â‡∏±‡∏ô‡πÄ‡∏à‡πá‡∏ö
Kannada ‡≤π‡≤ø‡≤Ç‡≤¶‡≤£‡≤µ‡≤®‡≥ç‡≤®‡≥Å ‡≤∞‡≤™‡≥ç‡≤§‡≥Å‡≤Æ‡≤æ‡≤°‡≥Å
Hebrew ◊õ◊ú◊ô ◊ê◊ú◊ô◊§◊°◊î (◊¶◊ô◊ô◊® ◊ê◊ú◊ô◊§◊î ◊ê◊ï ◊ê◊ú◊ô◊§◊°◊î ◊¢◊ù ◊û◊ô◊ú◊ï◊ô)' lines

]

{ #category : #testing }
PangoPlugin2 class >> timeClearBG: clearBG antiAlias: antiAliasFlag [
	"Measure rendering time with various options. The first run for a given style make take longer as the fonts are loaded so the timing for the first runs should be ignored. It takes 20% to 30% more time to clear the background, except in the non-anti-alias case when the background is already transparent."
	"[self timeClearBG: false antiAlias: true] msecs"
	"[self timeClearBG: true antiAlias: true] msecs"
	"[self timeClearBG: false antiAlias: false] msecs"
	"[self timeClearBG: true antiAlias: false] msecs"

	| bg y extent f |
	bg := clearBG & antiAliasFlag not ifTrue: [0] ifFalse: [255].
	self primSetColorfgRed: 0 fgGreen: 0 fgBlue: 1
		bgRed: bg bgGreen: bg bgBlue: bg
		mapBGToTransparent: clearBG.

	self primSetFont: 'Helvetica Neue' size: 18 bold: false italic: false antialias: antiAliasFlag.
	y := 5.
	100 timesRepeat: [
		self testStrings do: [:s |
			extent := self primMeasureString: s.
			f := Form extent: extent depth: 32.
			self drawString: s on: f.
			"f displayOn: Display at: 5@y rule: Form paint."
			y := y + f height]].

]

{ #category : #utilities }
PangoPlugin2 class >> xRangesFor: utf8 [
	"Anwer an array of (leftX, rightX) pairs for the given Unicode string. There will be an entry in the resulting array for each UTF character in the input string, even when characters combine. Thus, in general, the x ranges for characters can overlap."

	| ranges count result left right |
	count := utf8 asUTF8 asUTF32 size.
	ranges := Bitmap new: 2 * count.
	count := PangoPlugin2 primGetXRanges: utf8 into: ranges.
	count < 0 ifTrue: [self error: 'Error in Unicode XRange primitive'].
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
PangoPlugin2 >> cString: stringOop [
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
PangoPlugin2 >> cWordsPtr: oop minSize: minSize [
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
PangoPlugin2 >> copyString: stringOop into: stringPtr max: maxChars [
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
PangoPlugin2 >> primitiveDrawString [

	| utf8Oop utf8 w h bitmapOop bitmapPtr utf8Length result |
	self export: true.
	self var: 'utf8' declareC: 'char *utf8'.
	self var: 'bitmapPtr' declareC: 'void *bitmapPtr'.

	utf8Oop := interpreterProxy stackValue: 3.
	utf8 := self cString: utf8Oop.
	w := interpreterProxy stackIntegerValue: 2.
	h := interpreterProxy stackIntegerValue: 1.
	bitmapOop := interpreterProxy stackValue: 0.
	bitmapPtr := self cWordsPtr: bitmapOop minSize: w * h.
	interpreterProxy failed ifTrue: [^ nil].

	utf8Length := interpreterProxy stSizeOf: utf8Oop.
	self cCode: 'pango2DrawString(utf8, utf8Length, &w, &h, bitmapPtr)'.

	result := interpreterProxy makePointwithxValue: w yValue: h.
	interpreterProxy pop: 5 thenPush: result.
	^ 0

]

{ #category : #primitives }
PangoPlugin2 >> primitiveGetXRanges [

	| utf8Oop utf8 resultOop resultPtr utf8Length count resultLength |
	self export: true.
	self var: 'utf8' declareC: 'char *utf8'.
	self var: 'resultPtr' declareC: 'int *resultPtr'.

	utf8Oop := interpreterProxy stackValue: 1.
	utf8 := self cString: utf8Oop.

	resultOop := interpreterProxy stackValue: 0.
	resultPtr := self cWordsPtr: resultOop minSize: 0.
	interpreterProxy failed ifTrue: [^ nil].

	utf8Length := interpreterProxy stSizeOf: utf8Oop.
	resultLength := interpreterProxy stSizeOf: resultOop.
	count := self cCode: 'pango2GetXRanges(utf8, utf8Length, resultPtr, resultLength)'.

	interpreterProxy pop: 3 thenPush: (interpreterProxy integerObjectOf: count).
	^ 0

]

{ #category : #primitives }
PangoPlugin2 >> primitiveMeasureString [

	| utf8Oop utf8 utf8Length w h result |
	self export: true.
	self var: 'utf8' declareC: 'char *utf8'.

	utf8Oop := interpreterProxy stackValue: 0.
	utf8 := self cString: utf8Oop.
	interpreterProxy failed ifTrue: [^ nil].

	w := h := 0.
	utf8Length := interpreterProxy stSizeOf: utf8Oop.
	self cCode: 'pango2MeasureString(utf8, utf8Length, &w, &h, (void *) 0)'.

	result := interpreterProxy makePointwithxValue: w yValue: h.
	interpreterProxy pop: 2 thenPush: result.
	^ 0

]

{ #category : #primitives }
PangoPlugin2 >> primitiveMeasureStringDetails [

	| utf8Oop utf8 utf8Length  resultOop resultPtr w h result |
	self export: true.
	self var: 'utf8' declareC: 'char *utf8'.
	self var: 'resultPtr' declareC: 'int *resultPtr = 0'.

	utf8Oop := interpreterProxy stackValue: 1.
	utf8 := self cString: utf8Oop.
	resultOop := interpreterProxy stackValue: 0.
	resultPtr := self cWordsPtr: resultOop minSize: 9.
	interpreterProxy failed ifTrue: [^ nil].

	w := h := 0.
	utf8Length := interpreterProxy stSizeOf: utf8Oop.
	self cCode: 'pango2MeasureString(utf8, utf8Length, &w, &h, resultPtr)'.

	result := interpreterProxy makePointwithxValue: w yValue: h.
	interpreterProxy pop: 3 thenPush: result.
	^ 0

]

{ #category : #primitives }
PangoPlugin2 >> primitiveSetColors [

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

	self cCode: 'pango2SetColors(fgRed, fgGreen, fgBlue, bgRed, bgGreen, bgBlue, mapBGToTransparent)'.

	interpreterProxy pop: 7.
	^ 0

]

{ #category : #primitives }
PangoPlugin2 >> primitiveSetFont [

	| fontName fontSize boldFlag italicFlag antiAliasFlag |
	self export: true.
	self var: 'fontName' declareC: 'char fontName[200]'.

	self copyString: (interpreterProxy stackValue: 4) into: fontName max: 200.
	fontSize := interpreterProxy stackIntegerValue: 3.
	boldFlag := interpreterProxy booleanValueOf: (interpreterProxy stackValue: 2).
	italicFlag := interpreterProxy booleanValueOf: (interpreterProxy stackValue: 1).
	antiAliasFlag := interpreterProxy booleanValueOf: (interpreterProxy stackValue: 0).
	interpreterProxy failed ifTrue: [^ nil].

	self cCode: 'pango2SetFont(fontName, fontSize, boldFlag, italicFlag, antiAliasFlag)'.

	interpreterProxy pop: 5.
	^ 0

]

{ #category : #primitives }
PangoPlugin2 >> primitiveSetLanguage [

	| lang |
	self export: true.
	self var: 'lang' declareC: 'char lang[100]'.

	self copyString: (interpreterProxy stackValue: 0) into: lang max: 100.
	interpreterProxy failed ifTrue: [^ nil].

	self cCode: 'pango2SetLanguage(lang)'.

	interpreterProxy pop: 1.
	^ 0

]
