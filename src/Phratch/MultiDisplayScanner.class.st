"
I'm a class related to the computation of characters counting for text flow.
"
Class {
	#name : #MultiDisplayScanner,
	#superclass : #MultiCharacterScanner,
	#instVars : [
		'bitBlt',
		'lineY',
		'runX',
		'foregroundColor',
		'backgroundColor',
		'fillBlt',
		'lineHeight',
		'paragraph',
		'paragraphColor',
		'morphicOffset',
		'ignoreColorChanges'
	],
	#pools : [
		'TextConstants'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #queries }
MultiDisplayScanner class >> defaultFont [
	^ TextStyle defaultFont
]

{ #category : #'*Phratch-Extensions' }
MultiDisplayScanner class >> quickPrintOn: aForm box: aRectangle font: aStrikeFont [
	"Create an instance to print on the given form in the given rectangle."

	^(self new) quickPrintOn: aForm box: aRectangle font: aStrikeFont color: Color black
]

{ #category : #'*Phratch-Extensions' }
MultiDisplayScanner class >> quickPrintOn: aForm box: aRectangle font: aStrikeFont color: textColor [
	"Create an instance to print on the given form in the given rectangle."

	^ (self new) quickPrintOn: aForm box: aRectangle font: aStrikeFont color: textColor
]

{ #category : #'stop conditions' }
MultiDisplayScanner >> cr [
	"When a carriage return is encountered, simply increment the pointer 
	into the paragraph."

	pendingKernX := 0.
	(lastIndex < text size and: [(text at: lastIndex) = CR and: [(text at: lastIndex+1) = Character lf]])
		ifTrue: [lastIndex := lastIndex + 2]
		ifFalse: [lastIndex := lastIndex + 1].
	^false
]

{ #category : #'stop conditions' }
MultiDisplayScanner >> crossedX [
	"This condition will sometimes be reached 'legally' during display, when, 
	for instance the space that caused the line to wrap actually extends over 
	the right boundary. This character is allowed to display, even though it 
	is technically outside or straddling the clipping ectangle since it is in 
	the normal case not visible and is in any case appropriately clipped by 
	the scanner."

	^ true 
]

{ #category : #scanning }
MultiDisplayScanner >> displayLine: textLine offset: offset leftInRun: leftInRun [
	"The call on the primitive (scanCharactersFrom:to:in:rightX:) will be interrupted according to an array of stop conditions passed to the scanner at which time the code to handle the stop condition is run and the call on the primitive continued until a stop condition returns true (which means the line has terminated).  leftInRun is the # of characters left to scan in the current run; when 0, it is time to call setStopConditions."
	| stopCondition nowLeftInRun startIndex string lastPos |
	line := textLine.
	morphicOffset := offset.
	lineY := line top + offset y.
	lineHeight := line lineHeight.
	rightMargin := line rightMargin + offset x.
	lastIndex := line first.
	leftInRun <= 0 ifTrue: [self setStopConditions].
	leftMargin := (line leftMarginForAlignment: alignment) + offset x.
	destX := runX := leftMargin.
	fillBlt == nil ifFalse:
		["Not right"
		fillBlt destX: line left destY: lineY
			width: line width left height: lineHeight; copyBits].
	lastIndex := line first.
	leftInRun <= 0
		ifTrue: [nowLeftInRun := text runLengthFor: lastIndex]
		ifFalse: [nowLeftInRun := leftInRun].
	baselineY := lineY + line baseline.
	destY := baselineY - font ascent.
	runStopIndex := lastIndex + (nowLeftInRun - 1) min: line last.
	spaceCount := 0.
	string := text string.
	[
		startIndex := lastIndex.
		lastPos := destX@destY.
		stopCondition := self scanCharactersFrom: lastIndex to: runStopIndex
						in: string rightX: rightMargin stopConditions: stopConditions
						kern: kern.
		lastIndex >= startIndex ifTrue:[
			bitBlt displayString: string 
				from: startIndex 
	"XXXX: The following is an interesting bug. All stopConditions exept #endOfRun
		have lastIndex past the last character displayed. #endOfRun sets it *on* the character.
		If we display up until lastIndex then we will also display invisible characters like
		CR and tab. This problem should be fixed in the scanner (i.e., position lastIndex
		consistently) but I don't want to deal with the fallout right now so we keep the
		fix minimally invasive."
				to: (stopCondition == #endOfRun ifTrue:[lastIndex] ifFalse:[lastIndex-1])
				at: lastPos kern: kern baselineY: baselineY font: font].
		(emphasisCode allMask: 4) ifTrue:[
			font displayUnderlineOn: bitBlt from: lastPos x@baselineY to: destX@baselineY.
		].
		(emphasisCode allMask: 16) ifTrue:[
			font displayStrikeoutOn: bitBlt from: lastPos x@baselineY to: destX@baselineY.
		].
		"see setStopConditions for stopping conditions for displaying."
		self perform: stopCondition.
		"or: [lastIndex > runStopIndex]."
	] whileFalse.
	^ runStopIndex - lastIndex   "Number of characters remaining in the current run"
]

{ #category : #'stop conditions' }
MultiDisplayScanner >> endOfRun [
	"The end of a run in the display case either means that there is actually 
	a change in the style (run code) to be associated with the string or the 
	end of this line has been reached."
	| runLength |
	lastIndex = line last ifTrue: [^true].
	runX := destX.
	runLength := text runLengthFor: (lastIndex := lastIndex + 1).
	runStopIndex := lastIndex + (runLength - 1) min: line last.
	self setStopConditions.
	^ false
]

{ #category : #'multilingual scanning' }
MultiDisplayScanner >> isBreakableAt: index in: sourceString in: encodingClass [

	^ false.

]

{ #category : #'stop conditions' }
MultiDisplayScanner >> paddedSpace [
	"Each space is a stop condition when the alignment is right justified. 
	Padding must be added to the base width of the space according to 
	which space in the line this space is and according to the amount of 
	space that remained at the end of the line when it was composed."

	spaceCount := spaceCount + 1.
	destX := destX + spaceWidth + (line justifiedPadFor: spaceCount  font: font).
	lastIndex := lastIndex + 1.
	pendingKernX := 0.
	^ false
]

{ #category : #scanning }
MultiDisplayScanner >> placeEmbeddedObject: anchoredMorph [
	anchoredMorph relativeTextAnchorPosition ifNotNil:[
		anchoredMorph position: 
			anchoredMorph relativeTextAnchorPosition +
			(anchoredMorph owner textBounds origin x @ 0)
			- (0@morphicOffset y) + (0@lineY).
		^true
	].
	(super placeEmbeddedObject: anchoredMorph) ifFalse: [^ false].
	anchoredMorph isMorph ifTrue: [
		anchoredMorph position: ((destX - anchoredMorph width)@lineY) - morphicOffset
	] ifFalse: [
		destY := lineY.
		baselineY := lineY + anchoredMorph height..
		runX := destX.
		anchoredMorph 
			displayOn: bitBlt destForm 
			at: destX - anchoredMorph width @ destY
			clippingBox: bitBlt clipRect
			rule: Form blend
			fillColor: Color white 
	].
	^ true
]

{ #category : #'stop conditions' }
MultiDisplayScanner >> plainTab [
	| oldX |
	oldX := destX.
	super plainTab.
	fillBlt == nil ifFalse:
		[fillBlt destX: oldX destY: destY width: destX - oldX height: font height; copyBits]
]

{ #category : #private }
MultiDisplayScanner >> presentationText: t [

	text := t.

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

{ #category : #private }
MultiDisplayScanner >> setDestForm: df [
	bitBlt setDestForm: df.
]

{ #category : #private }
MultiDisplayScanner >> setFont [ 
	foregroundColor := paragraphColor.
	super setFont.  "Sets font and emphasis bits, and maybe foregroundColor"
	font installOn: bitBlt foregroundColor: foregroundColor backgroundColor: Color transparent.
	text ifNotNil:[
		baselineY := lineY + line baseline.
		destY := baselineY - font ascent].

]

{ #category : #private }
MultiDisplayScanner >> setPort: aBitBlt [
	"Install the BitBlt to use"
	bitBlt := aBitBlt.
	bitBlt sourceX: 0; width: 0.	"Init BitBlt so that the first call to a primitive will not fail"
	bitBlt sourceForm: nil. "Make sure font installation won't be confused"

]

{ #category : #'stop conditions' }
MultiDisplayScanner >> setStopConditions [
	"Set the font and the stop conditions for the current run."
	
	self setFont.
	self setConditionArray: (alignment = Justified ifTrue: [#paddedSpace]).

"
	alignment = Justified ifTrue: [
		stopConditions == DefaultStopConditions 
			ifTrue:[stopConditions := stopConditions copy].
		stopConditions at: Space asciiValue + 1 put: #paddedSpace]
"
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

{ #category : #'stop conditions' }
MultiDisplayScanner >> tab [
	self plainTab.
	lastIndex := lastIndex + 1.
	^ false
]

{ #category : #private }
MultiDisplayScanner >> text: t textStyle: ts foreground: foreColor background: backColor fillBlt: blt ignoreColorChanges: shadowMode [
	text := t.
	textStyle := ts. 
	foregroundColor := paragraphColor := foreColor.
	(backgroundColor := backColor) isTransparent ifFalse:
		[fillBlt := blt.
		fillBlt fillColor: backgroundColor].
	ignoreColorChanges := shadowMode
]

{ #category : #private }
MultiDisplayScanner >> textColor: textColor [
	ignoreColorChanges ifTrue: [^ self].
	foregroundColor := textColor
]
