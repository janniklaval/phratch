"
An editable, multiple-line string in a single font with line wrapping and scrolling.

Best for small amounts of text; for longer texts or texts with multiple type styles, see TextMorph.

My contents are stored in an array of strings ('lines') with all non-printing characters except cr's and spaces stripped out and tabs replaced by a sequence of spaces.

Possible improvements:
  a. handle tabs correctly
  b. preserve non-printing characters (could be useful for editing files)

"
Class {
	#name : #ScrollingStringMorph,
	#superclass : #PhratchBorderedMorph,
	#instVars : [
		'scrollbar',
		'firstVisibleLine',
		'visibleWidth',
		'font',
		'textColor',
		'selectionColor',
		'lines',
		'lineHeight',
		'isEditable',
		'hasFocus',
		'selectionStart',
		'selectionEnd',
		'startLoc',
		'layoutNeeded',
		'renderer',
		'blinkState',
		'backForm'
	],
	#classVars : [
		'CR'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'class initialization' }
ScrollingStringMorph class >> initialize [
	"self initialize"

	CR := 13.

]

{ #category : #menu }
ScrollingStringMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addLine.
	aCustomMenu add: 'set font' translated action: #fontMenu
]

{ #category : #'event handling' }
ScrollingStringMorph >> autoScroll: mouseY [
	"Autoscroll if necessary for the given mouse y position."

	| maxScroll |
	(mouseY between: self top + 3 and: self bottom - 3) ifTrue: [^ self].

	maxScroll := (lines size - (self visibleLineCount // 3)) max: 1.
	mouseY < (self top + 3) ifTrue: [firstVisibleLine := (firstVisibleLine - 1) max: 1].
	mouseY > (self bottom - 3) ifTrue: [firstVisibleLine := (firstVisibleLine + 1) min: maxScroll].
	self updateScrollbar.
	(Delay forMilliseconds: 10) wait.

]

{ #category : #menu }
ScrollingStringMorph >> backForm: f [

	backForm := ImageFrameMorph new initFromForm: f.
	color := Color r: (211/255) g: (214/255) b: (216/255).

]

{ #category : #editing }
ScrollingStringMorph >> backspaceChar [
	"If there is a selection, delete it. Otherwise delete the character just before the insertion point (i.e. backspace)."

	selectionStart = selectionEnd
		ifFalse: [ ^ self deleteSelection ].
	selectionStart > 1
		ifFalse: [ ^ self ].
	selectionEnd := selectionStart.
	selectionStart := selectionStart - 1.
	self deleteSelection
]

{ #category : #private }
ScrollingStringMorph >> breakLine: lineIndex [
	"Break the given line by moving some of it down to the following line. Answer true if the line was broken, false otherwise. (This may cause the next line to become too long, thus propaging the need to word-wrap.)
	Try the following strategies, in order:
		a. break at an embedded if that leaves the line short enough
		b. break at the last space character before a word that hits the edge
		c. break a word that hits the edge if there is no space before that word"

	| line breakIndex i lineUpToBreak lineAfterBreak |
	line := lines at: lineIndex.
	breakIndex := nil.

	(self fits: line) ifTrue: [^ false].  "line already fits"

	(i := line indexOf: CR) ~= 0 ifTrue: [
		(self fits: (line copyFrom: 1 to: i - 1))
			ifTrue: [breakIndex := i]].

	breakIndex ifNil: [
		i := line indexOfSeparatorStartingAt: 1.
		[i <= line size] whileTrue: [
			(self fits: (line copyFrom: 1 to: i - 1))
				ifTrue: [
					breakIndex := i.
					i := line indexOfSeparatorStartingAt: i + 1]
				ifFalse: [i := line size + 1]]].

	breakIndex ifNil: [
		i := line size.
		[i > 1 and:
		 [(self fits: (line copyFrom: 1 to: i)) not]]
			whileTrue: [i := i - 1].
		breakIndex := i].

	lineUpToBreak := line copyFrom: 1 to: breakIndex.
	lineAfterBreak := line copyFrom: breakIndex + 1 to: line size.

	lineIndex = lines size ifTrue: [lines := lines copyWith: self emptyLine].  "make sure there is a next line"
	lines at: lineIndex put: lineUpToBreak.
	lines at: lineIndex + 1 put: lineAfterBreak, (lines at: lineIndex + 1).

	^ true

]

{ #category : #private }
ScrollingStringMorph >> charCount [

	| result |
	result := 0.
	lines do: [:s | result := result + s size].
	^ result

]

{ #category : #accessing }
ScrollingStringMorph >> contents [
	"Answer my contents as a string."

	| sz result i |
	sz := 0.
	lines do: [:s | sz := sz + s size].
	result := String new: sz.
	i := 1.
	lines do: [:s |
		sz := s size.
		result replaceFrom: i to: i + sz - 1 with: s startingAt: 1.
		i := i + sz].
	^ result

]

{ #category : #accessing }
ScrollingStringMorph >> contents: aStringOrText [
	"Set my contents to the given String or Text. Break into lines, emove non-printing characters, and replace tabs with sequences of spaces."

	lines := Array with: (self replaceTabs: aStringOrText).
	selectionStart := selectionEnd := 1.
	layoutNeeded := true.

]

{ #category : #copying }
ScrollingStringMorph >> copy [
	"Return a copy with a copy of my lines array."

	^ super copy setLines: lines copy

]

{ #category : #editing }
ScrollingStringMorph >> copySelection [
	"Record the current selection in the clipboard."

	PhratchTranslator unicodeClipboardPut: self currentSelection.

]

{ #category : #editing }
ScrollingStringMorph >> currentSelection [
	"Answer the current selection as a string."

	| line result start end startLineNum endLineNum |
	self ensureSelectionStartPrecedesEnd.
	start := self lineAndIndexFor: selectionStart.
	end := self lineAndIndexFor: selectionEnd.
	startLineNum := start first.
	endLineNum := end first.

	startLineNum = endLineNum ifTrue: [
		line := lines at: startLineNum.
		^ line copyFrom: start second to: end second - 1].

	result := WriteStream on: (String  new: 1000).

	line := lines at: startLineNum.
	result nextPutAll: (line copyFrom: start second to: line size).

	startLineNum + 1 to: endLineNum - 1 do: [:i |
		result nextPutAll: (lines at: i)].

	line := lines at: endLineNum.
	result nextPutAll: (line copyFrom: 1 to: end second - 1).

	^ result contents

]

{ #category : #'event handling' }
ScrollingStringMorph >> cursorKey: evt [
	"Handle the given cursor control key."

	| ch pair lineNum line |
	ch := evt keyValue.

	selectionStart = selectionEnd ifTrue: [startLoc := selectionStart].

	ch = 28 ifTrue: [ "left"
		evt shiftPressed
			ifTrue: [
				selectionEnd > startLoc
					ifTrue: [selectionEnd := selectionEnd - 1]
					ifFalse: [selectionStart := selectionStart - 1]]
			ifFalse: [
				selectionStart := selectionEnd := selectionStart - 1]].

	ch = 29 ifTrue: [ "right"
		evt shiftPressed
			ifTrue: [
				selectionStart < startLoc
					ifTrue: [selectionStart := selectionStart + 1]
					ifFalse: [selectionEnd := selectionEnd + 1]]
			ifFalse: [
				selectionStart := selectionEnd := selectionStart + 1]].

	ch = 30 ifTrue: [  "up"
		pair := self lineAndIndexFor: selectionStart.	
		lineNum := (pair first - 1) max: 1.
		line := lines at: lineNum.
		selectionStart := (self startOfLine: lineNum) + (pair second min: line size).
		evt shiftPressed ifFalse: [selectionEnd := selectionStart]].

	ch = 31 ifTrue: [  "down"
		pair := self lineAndIndexFor: selectionEnd.	
		lineNum := (pair first + 1) min: lines size.
		line := lines at: lineNum.
		selectionEnd := (self startOfLine: lineNum) + (pair second min: line size).
		evt shiftPressed ifFalse: [selectionStart := selectionEnd]].

	blinkState := true.
	self ensureSelectionStartPrecedesEnd.
	self ensureCursorIsOnScreen.
	self changed.

]

{ #category : #editing }
ScrollingStringMorph >> cutSelection [
	"Record the current selection in the clipboard, then delete it."

	selectionStart = selectionEnd ifTrue: [^ self].  "no selection"
	self copySelection.
	self deleteSelection.

]

{ #category : #editing }
ScrollingStringMorph >> deleteNextChar [
	"If there is a selection, delete it. Otherwise delete the character just after the insertion point (i.e. delete)."

	selectionStart = selectionEnd ifFalse: [^ self deleteSelection].

	selectionEnd := selectionStart + 1.
	self deleteSelection.

]

{ #category : #editing }
ScrollingStringMorph >> deleteSelection [
	"Delete the current selection."

	| start end startLineNum endLineNum s1 s2 mergedLine remainingLines |
	self ensureSelectionStartPrecedesEnd.
	selectionStart = selectionEnd ifTrue: [^ self].  "no selection"

	start := self lineAndIndexFor: selectionStart.
	end := self lineAndIndexFor: selectionEnd.

	startLineNum := start first.
	endLineNum := end first.

	"merge the partial lines before and after the selection"
	s1 := lines at: startLineNum.
	s2 := lines at: endLineNum.
	mergedLine := (s1 copyFrom: 1 to: start second - 1), (s2 copyFrom: end second to: s2 size).

	"combine with following line, if any"
	endLineNum < lines size ifTrue: [
		mergedLine := mergedLine, (lines at: endLineNum + 1).
		remainingLines := lines copyFrom: endLineNum + 2 to: lines size].

	"update lines"
	lines := (lines copyFrom: 1 to: startLineNum - 1) copyWith: mergedLine.
	remainingLines ifNotNil: [lines := lines, remainingLines].

	selectionEnd := selectionStart.
	self lineWrapFrom: startLineNum.
	self ensureCursorIsOnScreen.

]

{ #category : #'event handling' }
ScrollingStringMorph >> doubleClick: evt [
	"Select a word."

	| lineAndIndex lineNum s index wordStart wordEnd lineStart |
	lines size = 0
		ifTrue: [ ^ self ].
	lineAndIndex := self lineAndIndexFor: (self indexForPoint: evt cursorPoint).
	lineNum := lineAndIndex first.
	s := lines at: lineNum.
	s size = 0
		ifTrue: [ ^ self ].	"empty line"
	index := lineAndIndex second.
	index := index min: s size.	"at end of line; try one char back"
	(s at: index) isSeparator
		ifTrue: [ ^ self ].	"on separator; do nothing"
	wordStart := index.
	[ wordStart >= 1 and: [ (s at: wordStart) isSeparator not ] ] whileTrue: [ wordStart := wordStart - 1 ].
	wordEnd := index.
	[ wordEnd < s size and: [ (s at: wordEnd) isSeparator not ] ] whileTrue: [ wordEnd := wordEnd + 1 ].
	(s at: wordEnd) isSeparator
		ifTrue: [ wordEnd := wordEnd - 1 ].
	lineStart := self startOfLine: lineNum.
	selectionStart := lineStart + (wordStart + 1).
	selectionEnd := lineStart + (wordEnd + 1).
	startLoc := selectionStart.
	self changed
]

{ #category : #drawing }
ScrollingStringMorph >> drawCursor: charIndex line: lineIndex on: aCanvas [
	"Draw a cursor at the given character index on the given line."

	| line pair x p |
	line := lines at: lineIndex.
	pair := line size = 0
		ifTrue: [ #(0 0) ]
		ifFalse: [ (renderer xRangesFor: line) at: (charIndex within: 1 and: line size) ].
	x := charIndex > line size
			ifTrue: [ pair max ]
			ifFalse: [ pair min ] .
	p := self offsetForLine: lineIndex.
	aCanvas fillRectangle: (p + (x @ 0) extent: 2 @ lineHeight) color: selectionColor
]

{ #category : #drawing }
ScrollingStringMorph >> drawOn: aCanvas [

	| clipC |
	super drawOn: aCanvas.
	lineHeight ifNil: [self font: font].

	"draw my background, if I have one"
	backForm ifNotNil: [
		backForm
			position: self topLeft;
			extent: self extent.
		backForm drawOn: aCanvas].

	clipC := aCanvas
		copyOffset: bounds origin
		clipRect: (bounds insetBy: borderWidth).

	hasFocus ifTrue: [self drawSelectionOn: clipC].
	self drawTextOn: clipC.

]

{ #category : #drawing }
ScrollingStringMorph >> drawSelectionFrom: startIndex to: endIndex line: lineIndex on: aCanvas [
	"Draw the selection for the given character range of the given line on the given canvas."

	| line xRanges p pair w |
	line := lines at: lineIndex.
	xRanges := renderer xRangesFor: line.
	p := self offsetForLine: lineIndex.
	startIndex to: endIndex - 1 do: [:i |
		pair := xRanges at: (i within: 1 and: line size).
		w := (pair last - pair first) abs.
		aCanvas fillRectangle: ((p + (pair first@0)) extent: w@lineHeight) color: selectionColor].

]

{ #category : #drawing }
ScrollingStringMorph >> drawSelectionLine: lineIndex on: aCanvas [
	"Draw the selection for the entire line with the given index on the given canvas."

	| p w |
	p := self offsetForLine: lineIndex.
	w := renderer stringWidth: (lines at: lineIndex).
	aCanvas fillRectangle: (p extent: w@lineHeight) color: selectionColor.

]

{ #category : #drawing }
ScrollingStringMorph >> drawSelectionOn: aCanvas [
	"Draw my selection onto the given canvas. The canvas has been offset to my origin."

	| start end startLine endLine startIndex endIndex |
	lines size = 0 ifTrue: [^ self].

	self ensureSelectionStartPrecedesEnd.
	start := self lineAndIndexFor: selectionStart.
	end := self lineAndIndexFor: selectionEnd.
	startLine := start first.
	endLine := end first.
	startIndex := start last.
	endIndex := end last.

	startLine = endLine ifTrue: [
		startIndex = endIndex
			ifTrue: [
				blinkState ifTrue: [
					self drawCursor: startIndex line: startLine on: aCanvas]]
			ifFalse: [
				self drawSelectionFrom: startIndex to: endIndex line: startLine on: aCanvas].
		^ self].

	self drawSelectionFrom: startIndex to: (lines at: startLine) size + 1 line: startLine on: aCanvas.
	startLine + 1 to: endLine - 1 do: [:i | self drawSelectionLine: i on: aCanvas].
	self drawSelectionFrom: 1 to: endIndex line: endLine on: aCanvas.

]

{ #category : #drawing }
ScrollingStringMorph >> drawString: aString at: aPoint on: aCanvas [

	| s |
	s := aString.

	aCanvas
		text: s
		bounds: (aPoint extent: 10000@10000)
		font: font
		kern:0
		color: textColor.

]

{ #category : #drawing }
ScrollingStringMorph >> drawTextOn: aCanvas [

	| iStart iEnd p |
	iStart := firstVisibleLine rounded within: 1 and: lines size.
	iEnd := (firstVisibleLine + self visibleLineCount) within: 1 and: lines size.

	iStart to: iEnd do: [:i |
		p := self offsetForLine: i.
		self drawString: (lines at: i) at: p on: aCanvas].


]

{ #category : #private }
ScrollingStringMorph >> emptyLine [

	^ String new

]

{ #category : #private }
ScrollingStringMorph >> ensureCursorIsOnScreen [
	| visibleLines i |
	visibleLines := self visibleLineCount.
	visibleLines >= lines size
		ifTrue: [ ^ self updateScrollbar ].
	i := (self lineAndIndexFor: selectionStart) first.
	(i between: firstVisibleLine and: firstVisibleLine + visibleLines - 2)
		ifTrue: [ ^ self updateScrollbar ].
	firstVisibleLine := i < firstVisibleLine
		ifTrue: [ i - 2 max: 1 ]
		ifFalse: [ i + 1 - visibleLines max: 1 ].
	self updateScrollbar.
	self changed
]

{ #category : #private }
ScrollingStringMorph >> ensureSelectionStartPrecedesEnd [
	"If selectionEnd is before selectionStart, swap them."

	| lastIndex tmp |
	lastIndex := self charCount + 1.
	selectionStart := selectionStart within: 1 and: lastIndex.
	selectionEnd := selectionEnd within: 1 and: lastIndex.
	selectionEnd < selectionStart
		ifFalse: [ ^ self ].
	tmp := selectionEnd.
	selectionEnd := selectionStart.
	selectionStart := tmp
]

{ #category : #menu }
ScrollingStringMorph >> extent: aPoint [
	"Adjust the position and size of my scrollbar and compute visibleWidth. Text layout is handled by my step method."

	super extent: (aPoint max: 120@75).
	backForm
		ifNotNil: [scrollbar position: (self right - borderWidth - scrollbar width - 7)@(self top + borderWidth + 8).
			scrollbar height: self height - (2 * borderWidth) - 14]
		ifNil: [scrollbar position: (self right - borderWidth - scrollbar width - 3)@(self top + borderWidth + 1).
			scrollbar height: self height - (2 * borderWidth)].

	visibleWidth := self width - (2 * self textInset x) - 1.
	scrollbar owner = self ifTrue: [visibleWidth := visibleWidth - scrollbar width].

	layoutNeeded := true.

]

{ #category : #private }
ScrollingStringMorph >> fitContents [
	"Set my extent to just fit around my contents."

	| w |
	w := 10.
	lines do: [:s | w := w max: (self widthWithContents: s)].
	self extent: (w@(lines size * lineHeight)) + (9@7).

]

{ #category : #private }
ScrollingStringMorph >> fits: aString [
	"Answer true if the given string fits within my width."

	| i |
	i := aString indexOf: CR.
	((i > 0) and: [i < aString size]) ifTrue: [^ false].  "line includes an embedded CR; needs to be broken"
	aString size > 500 ifTrue: [^ false].
	^ (renderer stringWidth: aString) < visibleWidth

]

{ #category : #accessing }
ScrollingStringMorph >> font [

	^ font

]

{ #category : #accessing }
ScrollingStringMorph >> font: aFont [

	font := aFont.
	renderer := StringMorph new font: aFont.
	lineHeight := renderer stringHeight: PhratchTranslator renderHintString, 'Ag'.
	lineHeight = 0 ifTrue: [lineHeight := 10].  "workaround for possible bug in stringHeight:"
	layoutNeeded := true.

]

{ #category : #fonts }
ScrollingStringMorph >> fontChangeName:fName size: fSize [
	self font: (StrikeFont fontName: fName size: fSize).
	self changed.

]

{ #category : #menu }
ScrollingStringMorph >> fontMenu [

	| menu |
	menu := MenuMorph new defaultTarget: self.
	StrikeFont fontNames do: [:fn | 
		menu add: fn
			target: self 
			selector: #fontSizeFor:
			argument: fn].
	menu popUpInWorld.

	

]

{ #category : #fonts }
ScrollingStringMorph >> fontSizeFor: fName [

	| menu |
	menu := MenuMorph new defaultTarget: self.
	(StrikeFont sizesForFontName: fName) do: [:sz | 
		menu add: sz printString
			target: self 
			selector: #fontChangeName:size:
			argumentList: (Array with: fName with: sz)].
	menu popUpInWorld.
	
]

{ #category : #'event handling' }
ScrollingStringMorph >> handlesKeyboard: evt [

^true
]

{ #category : #'event handling' }
ScrollingStringMorph >> handlesMouseDown: evt [

	^ self isEditable & evt hand toolType isNil

]

{ #category : #accessing }
ScrollingStringMorph >> hasFocus [

	^ hasFocus

]

{ #category : #private }
ScrollingStringMorph >> indexForPoint: aPoint [
	"Answer the character index for the given point in screen coordinates."
	"Note: This could be speeded up by doing a binary search for the character index, but it seems fast enough."

	| y lineNum x lineStart line xRanges pair |
	lines size = 0 ifTrue: [^ 1].

	y := aPoint y - (self top + self textInset y + 2).
	lineNum := ((y // lineHeight) + firstVisibleLine) max: 1.
	lineNum > lines size ifTrue: [^ (self startOfLine: lineNum) + 1].

	x := (aPoint x - self left - (self offsetForLine: lineNum) x) min: self width.
	x < 0 ifTrue: [  "start of a line"
		lineNum = 1 ifTrue: [^ 1] ifFalse: [^ self startOfLine: lineNum]].

	"search for character index"
	lineStart := self startOfLine: lineNum.
	line := lines at: lineNum.
	xRanges := renderer xRangesFor: line.
	1 to: line size do: [:i |
		pair := xRanges at: i.
		(x between: pair first and: pair second) ifTrue: [^ lineStart + i]].

	"end of line"
	lineNum = lines size
		ifTrue: [^ lineStart + line size + 1]
		ifFalse: [^ lineStart + line size].

]

{ #category : #initialization }
ScrollingStringMorph >> initialize [

	super initialize.
	borderWidth := 2.
	color := Color transparent.
	textColor := Color black.
	selectionColor := Color r: 0.353 g: 0.607 b: 0.788.
	lines := Array with: self emptyLine.
	isEditable := true.
	hasFocus := false.
	selectionStart := selectionEnd := 1.
	blinkState := true.
	layoutNeeded := false.

	scrollbar := PhratchScrollBar newVertical
		width: 16;
		target: self;
		selector: #scrollRelative:;
		yourself.
	firstVisibleLine := 1.
	self addMorph: scrollbar.

	self font: TextStyle defaultFont.
	self extent: 150@300.

]

{ #category : #editing }
ScrollingStringMorph >> insertString: aString [
	"Insert the given string at selectionStart."

	| start lineNum line prefix postfix |
	selectionStart = selectionEnd ifFalse: [self cutSelection].

	start := self lineAndIndexFor: selectionStart.
	lineNum := start first.
	line := lines at: lineNum.
	prefix := line copyFrom: 1 to: start second - 1.
	postfix := line copyFrom: start second to: line size.

	lines at: lineNum put: (prefix, (self replaceTabs: aString), postfix).

	selectionEnd := selectionStart := selectionStart + aString size.
	self lineWrapFrom: lineNum.
	self ensureCursorIsOnScreen.


]

{ #category : #accessing }
ScrollingStringMorph >> isEditable [
	"Answer true if I am editable."

	isEditable ifNil: [isEditable := true].
	^ isEditable

]

{ #category : #accessing }
ScrollingStringMorph >> isEditable: aBoolean [

	isEditable := aBoolean.

]

{ #category : #accessing }
ScrollingStringMorph >> isEmpty [
	"Answer true if my contents is empty."

	^ lines size = 0 or: [lines size = 1 and: [lines first size = 0]]

]

{ #category : #'event handling' }
ScrollingStringMorph >> keyStroke: evt [

	| ch m |
"	ch := evt unicodeChar.
	ch = 0 ifTrue: [ch := evt keyValue]."

	ch := evt keyValue.

	evt commandKeyPressed ifTrue: [ch := ch \\ 32].	"map cmd/alt keys to control keys"
	(ch = 3) & (evt buttons = 0) ifTrue: [ch := 13].	"map enter key to cr"

	ch = 9 ifTrue: [  "tab"
		(m := self ownerThatIsADialogBoxMorph) ifNotNil: [m tabToNextField: evt].
		^ self].

	ch = 27 ifTrue: [  "escape key"
		(m := self ownerThatIsADialogBoxMorph) ifNotNil: [m escapeKeyPressed: evt].
		^ self].

	evt controlKeyPressed | evt commandKeyPressed ifTrue: [	"ctrl (or alt) is pressed"
		ch = 1 ifTrue: [^ self selectAll].			"ctrl-a"
		ch = 3 ifTrue: [^ self copySelection].		"ctrl-c"
		ch = 22 ifTrue: [^ self paste].			"ctrl-v"
		ch = 24 ifTrue: [^ self cutSelection]].		"ctrl-x"

	evt shiftPressed ifTrue: [ "shift is pressed"
		ch = 1 ifTrue: [^ self moveCursorHomeAndSelect: true].		"home"
		ch = 4 ifTrue: [^ self moveCursorEndAndSelect: true].			"end"
		ch = 11 ifTrue: [^ self moveCursorPageUpAndSelect: true].		"page up"
		ch = 12 ifTrue: [^ self moveCursorPageDownAndSelect: true]].	"page down"

	evt buttons = 0 ifTrue: [ "no modifier keys"
		ch = 8 ifTrue: [^ self backspaceChar].						"backspace"
		ch = 127 ifTrue: [^ self deleteNextChar].						"delete"
		ch = 1 ifTrue: [^ self moveCursorHomeAndSelect: false].		"home"
		ch = 4 ifTrue: [^ self moveCursorEndAndSelect: false].		"end"
		ch = 11 ifTrue: [^ self moveCursorPageUpAndSelect: false].	"page up"
		ch = 12 ifTrue: [^ self moveCursorPageDownAndSelect: false]]."page down"

	(ch between: 28 and: 31) ifTrue: [^ self cursorKey: evt].  "arrow keys"

	"not a special character--just insert it"
	self insertString: (String with: evt keyCharacter).

]

{ #category : #'event handling' }
ScrollingStringMorph >> keyboardFocusChange: aBoolean [

	hasFocus = aBoolean ifFalse: [
		self changed].
	hasFocus := aBoolean.

]

{ #category : #private }
ScrollingStringMorph >> lineAndIndexFor: charPos [
	"Answer an Array containing the line number and the character index within that line for the given character position in my text."

	| count line |
	charPos < 1 ifTrue: [^ Array with: 1 with: 1].

	count := 0.
	1 to: lines size do: [:lineNum |
		line := lines at: lineNum.
		(charPos between: count + 1 and: count + line size)
			ifTrue: [^ Array with: lineNum with: charPos - count].
		count := count + line size].
	
	^ Array with: lines size with: ((lines at: lines size) size + 1)

]

{ #category : #private }
ScrollingStringMorph >> lineWrapFrom: startLine [
	"Fix line wrapping starting at the given line."

	| lineIndex |
	lineIndex := startLine.
	[lineIndex <= lines size and: [self breakLine: lineIndex]]
		whileTrue: [lineIndex := lineIndex + 1].

	"if the last line ends with a CR, add a blank line after it"
	(lines last size > 0 and: [lines last last = CR])
		ifTrue: [lines := lines copyWith: self emptyLine].

	self changed.

]

{ #category : #accessing }
ScrollingStringMorph >> lines [

	^ lines

]

{ #category : #'event handling' }
ScrollingStringMorph >> mouseDown: evt [

	evt hand newKeyboardFocus: self.
	startLoc := self indexForPoint: evt cursorPoint.
	evt shiftPressed
		ifTrue: [
			startLoc < selectionStart ifTrue: [startLoc := selectionEnd].
			startLoc > selectionEnd ifTrue: [startLoc := selectionStart]]
		ifFalse: [selectionStart := selectionEnd := startLoc].
	evt hand waitForClicksOrDrag: self event: evt.
	self changed.

]

{ #category : #'event handling' }
ScrollingStringMorph >> mouseMove: evt [

	| newLoc |
	self autoScroll: evt cursorPoint y.

	newLoc := self indexForPoint: evt cursorPoint.
	newLoc < startLoc
		ifTrue: [selectionStart := newLoc. selectionEnd := startLoc]
		ifFalse: [selectionStart := startLoc. selectionEnd := newLoc].

	self changed.

]

{ #category : #editing }
ScrollingStringMorph >> moveCursorEndAndSelect: selectFlag [

	| lineNum line |
	lineNum := (self lineAndIndexFor: selectionStart) first.
	line := lines at: lineNum.
	selectionEnd := (self startOfLine: lineNum) + line size.
	lineNum = lines size ifTrue: [selectionEnd := selectionEnd + 1].
	selectFlag ifFalse: [selectionStart := selectionEnd. self ensureCursorIsOnScreen].
	startLoc := selectionStart.
	self changed.

]

{ #category : #editing }
ScrollingStringMorph >> moveCursorHomeAndSelect: selectFlag [

	selectionStart := (self startOfLine: (self lineAndIndexFor: selectionStart) first) + 1.
	selectFlag ifFalse: [selectionEnd := selectionStart].
	startLoc := selectionEnd.
	self changed.

]

{ #category : #editing }
ScrollingStringMorph >> moveCursorPageDownAndSelect: selectFlag [

	| i lastLine |
	i := (self lineAndIndexFor: selectionStart) second.
	lastLine := lines at: lines size.
	selectionEnd := (self startOfLine: lines size) + (i min: lastLine size + 1).
	selectFlag ifFalse: [selectionStart := selectionEnd. self ensureCursorIsOnScreen].
	startLoc := selectionStart.
	self changed.

]

{ #category : #editing }
ScrollingStringMorph >> moveCursorPageUpAndSelect: selectFlag [

	| i |
	i := (self lineAndIndexFor: selectionStart) second.
	selectionStart := i within: 1 and: (lines at: 1) size.
	selectFlag ifFalse: [selectionEnd := selectionStart].
	startLoc := selectionEnd.
	self changed.

]

{ #category : #private }
ScrollingStringMorph >> offsetForLine: lineIndex [
	"Answer the offset from my origin to the start of the line with the given index, taking RTL into account."

	| top  |
	top := self textInset y + (lineHeight * (lineIndex - firstVisibleLine)).
	^ self textInset x @ top.

]

{ #category : #editing }
ScrollingStringMorph >> paste [
	"Paste the last cut or copied text over the current selection."

	| s |
	s := PhratchTranslator unicodeClipboard..
	s size = 0 ifTrue: [^ self].

	self deleteSelection.
	self insertString: s.

]

{ #category : #private }
ScrollingStringMorph >> replaceTabs: aString [
	"Answer a copy of the given UTF32 with each tab replaced by four spaces and all non-printing characters except spaces and line ends removed. Covert LF's to CR's."

	| s tab lf cr space result |
	s := aString.
	tab := Character codePoint: 9.
	lf := Character codePoint: 10.
	cr := Character codePoint: 13.
	space := Character codePoint: 32.
	result := WriteStream on: (String new: s size * 4).
	s do: [:ch |
		ch < space
			ifTrue: [ "non-printing"
				ch = tab ifTrue: [result nextPutAll: '    '].
				(ch = cr) | (ch = lf) ifTrue: [result nextPut: cr]]
			ifFalse: [
				result nextPut: ch]].

	^ result contents

]

{ #category : #accessing }
ScrollingStringMorph >> scrollRelative: aFloat [
	"Sent by the scrollbar. Scroll to the given relative postion between 0.0 and 1.0."

	| range |
	range := lines size - (0.25 * self visibleLineCount).
	firstVisibleLine := (aFloat * range) rounded.
	firstVisibleLine := firstVisibleLine max: 1.
	self changed.

]

{ #category : #editing }
ScrollingStringMorph >> selectAll [
	"Select all of my text."

	selectionStart := 1.
	selectionEnd := self charCount + 1.
	self changed.

]

{ #category : #accessing }
ScrollingStringMorph >> selectionColor: aColor [

	selectionColor := aColor.

]

{ #category : #private }
ScrollingStringMorph >> setLines: anArray [
	"Private! Used when copying."

	lines := anArray.

]

{ #category : #'event handling' }
ScrollingStringMorph >> startDrag: evt [
	"Do nothing."

]

{ #category : #private }
ScrollingStringMorph >> startOfLine: lineIndex [
	"Answer the character index for the start of the line with the given index. If the line is out of range treat it as if it were the first or last line."

	| result |
	lineIndex < 1 ifTrue: [^ 1].

	result := 0.
	1 to: ((lineIndex - 1) min: lines size) do: [:i | result := result + (lines at: i) size].
	^ result

]

{ #category : #stepping }
ScrollingStringMorph >> step [

	layoutNeeded ifTrue: [
		self wordWrapAll.
		layoutNeeded := false].

	blinkState := blinkState not.
	selectionStart = selectionEnd ifTrue: [self changed].

]

{ #category : #stepping }
ScrollingStringMorph >> stepTime [

	^ 600

]

{ #category : #accessing }
ScrollingStringMorph >> textColor [

	^ textColor

]

{ #category : #accessing }
ScrollingStringMorph >> textColor: aColor [

	textColor := aColor.

]

{ #category : #private }
ScrollingStringMorph >> textInset [

	backForm
		ifNotNil: [^ (13@8) + borderWidth]
		ifNil: [^ (10@8) + borderWidth].

]

{ #category : #geometry }
ScrollingStringMorph >> updateScrollbar [
	"Update my scrollbar's position, percent, and deltas based on my current contents."

	| visibleLines maxScroll |
	visibleLines := self visibleLineCount.
	scrollbar percentVisible: visibleLines asFloat / lines size.
	visibleLines >= lines size
		ifTrue: [ 
			firstVisibleLine := 1.
			self changed ].
	maxScroll := lines size - (self visibleLineCount // 3) max: 1.
	maxScroll > 0
		ifTrue: [ 
			scrollbar scrollDelta: 1.0 / visibleLines pageDelta: 0.6 * visibleLines / maxScroll.
			firstVisibleLine := firstVisibleLine min: maxScroll.
			scrollbar value: (firstVisibleLine - 1) / maxScroll ]
		ifFalse: [ scrollbar value: 0 ]
]

{ #category : #private }
ScrollingStringMorph >> visibleLineCount [
	"Answer the number of full lines that are visible. If less than a full line is visible, answer 1."

	^ ((self height - self textInset x) // lineHeight) max: 1
]

{ #category : #private }
ScrollingStringMorph >> widthWithContents: aString [
	"Answer how wide I would need to be to fit the given string on a single line."

	^ (renderer stringWidth: aString) + self textInset x + borderWidth + scrollbar width + 3

]

{ #category : #private }
ScrollingStringMorph >> wordWrapAll [
	"Redo my wordwrap."

	self contents: self contents.
	self lineWrapFrom: 1.
	self updateScrollbar.

]

{ #category : #'event handling' }
ScrollingStringMorph >> wouldAcceptKeyboardFocus [

	^ true

]
