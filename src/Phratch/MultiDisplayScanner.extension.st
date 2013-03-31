Extension { #name : #MultiDisplayScanner }

{ #category : #'*Phratch-Extensions' }
MultiDisplayScanner >> drawString: aString at: aPoint [
	"Draw the given string."

	destX := aPoint x asInteger.
	destY := aPoint y asInteger.
	self primScanCharactersFrom: 1 to: aString size in: aString
		rightX: bitBlt clipX + bitBlt clipWidth + font maxWidth
		stopConditions: stopConditions kern: kern.
	font displayString: aString on: bitBlt from: 1 to: lastIndex at: aPoint kern: kern.
	
]

{ #category : #'*Phratch-Extensions' }
MultiDisplayScanner >> primScanCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX stopConditions: stops kern: kernDelta [
	"Primitive. This is the inner loop of text display--but see 
	scanCharactersFrom: to:rightX: which would get the string, 
	stopConditions and displaying from the instance. March through source 
	String from startIndex to stopIndex. If any character is flagged with a 
	non-nil entry in stops, then return the corresponding value. Determine 
	width of each character from xTable, indexed by map. 
	If dextX would exceed rightX, then return stops at: 258. 
	Advance destX by the width of the character. If stopIndex has been
	reached, then return stops at: 257. Optional. 
	See Object documentation whatIsAPrimitive."
	| ascii nextDestX char |
	<primitive: 103>
	lastIndex := startIndex.
	[lastIndex <= stopIndex]
		whileTrue: 
			[char := (sourceString at: lastIndex).
			ascii := char asciiValue + 1.
			(stops at: ascii) == nil ifFalse: [^stops at: ascii].
			"Note: The following is querying the font about the width
			since the primitive may have failed due to a non-trivial
			mapping of characters to glyphs or a non-existing xTable."
			nextDestX := destX + (font widthOf: char).
			nextDestX > rightX ifTrue: [^stops at: CrossedX].
			destX := nextDestX + kernDelta.
			lastIndex := lastIndex + 1].
	lastIndex := stopIndex.
	^stops at: EndOfRun

]

{ #category : #'*Phratch-Extensions' }
MultiDisplayScanner classSide >> quickPrintOn: aForm box: aRectangle [
	"Create an instance to print on the given form in the given rectangle."

	^(super new) quickPrintOn: aForm box: aRectangle font: self defaultFont color: Color black

]

{ #category : #'*Phratch-Extensions' }
MultiDisplayScanner classSide >> quickPrintOn: aForm box: aRectangle font: aStrikeFont [
	"Create an instance to print on the given form in the given rectangle."

	^(super new) quickPrintOn: aForm box: aRectangle font: aStrikeFont color: Color black
]

{ #category : #'*Phratch-Extensions' }
MultiDisplayScanner >> quickPrintOn: aForm box: aRectangle font: aStrikeFont color: textColor [
	"Initialize myself."
	bitBlt := BitBlt toForm: aForm.
	backgroundColor := Color transparent.
	paragraphColor := textColor.
	font := aStrikeFont ifNil: [TextStyle defaultFont].
	emphasisCode := 0.
	kern := 0.
	indentationLevel := 0.
	self setFont.
	"Override cbrule and map"
	bitBlt combinationRule: Form paint.
	bitBlt colorMap: (Bitmap with: 0      "Assumes 1-bit deep fonts"
						with: (textColor pixelValueForDepth: bitBlt destForm depth)).
	bitBlt clipRect: aRectangle.
]

{ #category : #'*Phratch-Extensions' }
MultiDisplayScanner classSide >> quickPrintOn: aForm box: aRectangle font: aStrikeFont color: textColor [
	"Create an instance to print on the given form in the given rectangle."

	^ (super new) quickPrintOn: aForm box: aRectangle font: aStrikeFont color: textColor
]

{ #category : #'*Phratch-Extensions' }
MultiDisplayScanner >> stringExtent: aString [
	"Answer the extent of the given string using my font."
	"(1 to: 10) collect: [:i |
		(DisplayScanner quickPrintOn: Display) stringExtent: (String new: i withAll: $A)]"

	aString ifNil: [^ 0@0].

	destX := destY := 0.
	aString ifNil: [^ 0].
	self scanCharactersFrom: 1 to: aString size in: aString
		rightX: 99999	"virtual infinity"
		stopConditions: stopConditions
		kern: 0.

	^ (destX + (kern * ((aString size - 1) max: 0))) @ font height
]
