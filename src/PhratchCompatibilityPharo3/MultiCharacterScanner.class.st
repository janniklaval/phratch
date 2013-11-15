Class {
	#name : #MultiCharacterScanner,
	#superclass : #Object,
	#instVars : [
		'destX',
		'lastIndex',
		'destY',
		'stopConditions',
		'text',
		'textStyle',
		'alignment',
		'leftMargin',
		'rightMargin',
		'font',
		'line',
		'runStopIndex',
		'spaceCount',
		'spaceWidth',
		'emphasisCode',
		'kern',
		'indentationLevel',
		'wantsColumnBreaks',
		'presentation',
		'presentationLine',
		'numOfComposition',
		'baselineY',
		'firstDestX',
		'pendingKernX',
		'lastWidth'
	],
	#classVars : [
		'DefaultStopConditions',
		'NilCondition',
		'PaddedSpaceCondition',
		'SpaceCondition'
	],
	#pools : [
		'TextConstants'
	],
	#category : #PhratchCompatibilityPharo3
}

{ #category : #'class initialization' }
MultiCharacterScanner class >> initialize [
"
	MultiCharacterScanner initialize
"
	| a |
	a := TextStopConditions new.
	a at: 1 + 1 put: #embeddedObject.
	a at: Tab asciiValue + 1 put: #tab.
	a at: CR asciiValue + 1 put: #cr.
	a at: Character lf asciiValue + 1 put: #cr.
	
	NilCondition := a copy.
	DefaultStopConditions := a copy.

	PaddedSpaceCondition := a copy.
	PaddedSpaceCondition at: Space asciiValue + 1 put: #paddedSpace.
	
	SpaceCondition := a copy.
	SpaceCondition at: Space asciiValue + 1 put: #space.

]

{ #category : #'multilingual scanning' }
MultiCharacterScanner >> addCharToPresentation: char [

	lastWidth := self widthOf: char inFont: font.
	destX := destX + lastWidth.


]

{ #category : #private }
MultiCharacterScanner >> addEmphasis: code [
	"Set the bold-ital-under-strike emphasis."
	emphasisCode := emphasisCode bitOr: code
]

{ #category : #private }
MultiCharacterScanner >> addKern: kernDelta [
	"Set the current kern amount."
	kern := kern + kernDelta
]

{ #category : #scanning }
MultiCharacterScanner >> basicScanCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX stopConditions: stops kern: kernDelta [
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
	| ascii nextDestX char floatDestX widthAndKernedWidth nextChar atEndOfRun |
	<primitive: 103>
	lastIndex := startIndex.
	floatDestX := destX.
	widthAndKernedWidth := Array new: 2.
	atEndOfRun := false.
	[lastIndex <= stopIndex]
		whileTrue: [
			char := (sourceString at: lastIndex).
			ascii := char asciiValue.
			
			(ascii < stops size and: [(stops at: ascii + 1) notNil]) ifTrue: [^ stops at: ascii + 1].
			(self isBreakableAt: lastIndex in: sourceString in: Latin1Environment) 
				ifTrue: [ self registerBreakableIndex ].
			"Note: The following is querying the font about the width
			since the primitive may have failed due to a non-trivial
			mapping of characters to glyphs or a non-existing xTable."
			nextChar := (lastIndex + 1 <= stopIndex) 
				ifTrue:[sourceString at: lastIndex + 1]
				ifFalse:[
					atEndOfRun := true.
					"if there is a next char in sourceString, then get the kern 
					and store it in pendingKernX"
					lastIndex + 1 <= sourceString size
						ifTrue:[sourceString at: lastIndex + 1]
						ifFalse:[	nil]].
			font 
				widthAndKernedWidthOfLeft: char 
				right: nextChar
				into: widthAndKernedWidth.
			nextDestX := floatDestX + (widthAndKernedWidth at: 1).
			nextDestX > rightX ifTrue: [^stops crossedX].
			floatDestX := floatDestX + kernDelta + (widthAndKernedWidth at: 2).
			atEndOfRun 
				ifTrue:[
					pendingKernX := (widthAndKernedWidth at: 2) - (widthAndKernedWidth at: 1).
					floatDestX := floatDestX - pendingKernX].
			destX := floatDestX.
			lastIndex := lastIndex + 1].
	lastIndex := stopIndex.
	^ stops endOfRun
]

{ #category : #scanning }
MultiCharacterScanner >> columnBreak [

	pendingKernX := 0.
	^true
]

{ #category : #'scanner methods' }
MultiCharacterScanner >> combinableChar: char for: prevEntity [


]

{ #category : #scanning }
MultiCharacterScanner >> embeddedObject [
	| savedIndex |
	savedIndex := lastIndex.
	text attributesAt: lastIndex do:[:attr| 
		attr anchoredMorph ifNotNil:[
			"Following may look strange but logic gets reversed.
			If the morph fits on this line we're not done (return false for true) 
			and if the morph won't fit we're done (return true for false)"
			(self placeEmbeddedObject: attr anchoredMorph) ifFalse:[^true]]].
	lastIndex := savedIndex + 1. "for multiple(!) embedded morphs"
	^false
]

{ #category : #scanning }
MultiCharacterScanner >> handleIndentation [
	self indentationLevel timesRepeat: [
		self plainTab]
]

{ #category : #scanning }
MultiCharacterScanner >> indentationLevel [
	"return the number of tabs that are currently being placed at the beginning of each line"
	^indentationLevel ifNil:[0]
]

{ #category : #scanning }
MultiCharacterScanner >> indentationLevel: anInteger [
	"set the number of tabs to put at the beginning of each line"
	indentationLevel := anInteger
]

{ #category : #initialize }
MultiCharacterScanner >> initialize [
	super initialize.
	destX := destY := leftMargin := 0.
]

{ #category : #initialize }
MultiCharacterScanner >> initializeStringMeasurer [

	stopConditions := TextStopConditions new

]

{ #category : #'scanner methods' }
MultiCharacterScanner >> isBreakableAt: index in: sourceString in: encodingClass [

	^ encodingClass isBreakableAt: index in: sourceString.

]

{ #category : #scanning }
MultiCharacterScanner >> leadingTab [
	"return true if only tabs lie to the left"
	line first to: lastIndex do:
		[:i | (text at: i) == Tab ifFalse: [^ false]].
	^ true
]

{ #category : #scanning }
MultiCharacterScanner >> measureString: aString inFont: aFont from: startIndex to: stopIndex [
	"WARNING: In order to use this method the receiver has to be set up using #initializeStringMeasurer"
	destX := destY := lastIndex := 0.
	baselineY := aFont ascent.
	font := aFont.  " added Dec 03, 2004 "
"	map := aFont characterToGlyphMap."
	self scanCharactersFrom: startIndex to: stopIndex in: aString rightX: 999999 stopConditions: stopConditions kern: 0.
	^destX
]

{ #category : #scanning }
MultiCharacterScanner >> placeEmbeddedObject: anchoredMorph [
	"Place the anchoredMorph or return false if it cannot be placed.
	In any event, advance destX by its width."
	| w |
	"Workaround: The following should really use #textAnchorType"
	anchoredMorph relativeTextAnchorPosition ifNotNil:[^true].
	destX := destX + (w := anchoredMorph width).
	(destX > rightMargin and: [(leftMargin + w) <= rightMargin])
		ifTrue: ["Won't fit, but would on next line"
				^ false].
	lastIndex := lastIndex + 1.
	
	^ true
]

{ #category : #'multilingual scanning' }
MultiCharacterScanner >> registerBreakableIndex [

	"Record left x and character index of the line-wrappable point. 
	The default implementation here does nothing."

	^ false.

]

{ #category : #'multilingual scanning' }
MultiCharacterScanner >> removeLastCharFromPresentation [
	destX := destX - lastWidth.
]

{ #category : #scanning }
MultiCharacterScanner >> scanCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX stopConditions: stops kern: kernDelta [
	| startEncoding selector |
	
	sourceString isByteString
		ifTrue: [ ^ self 
					basicScanCharactersFrom: startIndex 
					to: stopIndex 
					in: sourceString 
					rightX: rightX 
					stopConditions: stops 
					kern: kernDelta ].

	sourceString isWideString ifFalse: [ ^ stops endOfRun ].
		
	startIndex > stopIndex 
		ifTrue: [ 
			lastIndex := stopIndex.
			^ stops endOfRun ].
	
	startEncoding := (sourceString at: startIndex) leadingChar.
	selector := (EncodedCharSet charsetAt: startEncoding) scanSelector.

	^ self 
		perform: selector 
		withArguments: (Array 
							with: startIndex 
							with: stopIndex 
							with: sourceString 
							with: rightX 
							with: stops 
							with: kernDelta).

	

]

{ #category : #'scanner methods' }
MultiCharacterScanner >> scanJapaneseCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX stopConditions: stops kern: kernDelta [

	| ascii encoding f nextDestX maxAscii startEncoding |
	lastIndex := startIndex.
	lastIndex > stopIndex ifTrue: [lastIndex := stopIndex. ^ stops endOfRun].
	startEncoding := (sourceString at: startIndex) leadingChar.
	font ifNil: [font := (TextSharedInformation at: #DefaultMultiStyle) fontArray at: 1].
	font isFontSet ifTrue: [
		f := [font fontArray at: startEncoding + 1]
			on: Exception do: [:ex | nil].
		f ifNil: [ f := font fontArray at: 1].
		maxAscii := f maxAscii.
		"xTable := f xTable.
		maxAscii := xTable size - 2."
		spaceWidth := f widthOf: Space.
	] ifFalse: [
		maxAscii := font maxAscii.
	].
	[lastIndex <= stopIndex] whileTrue: [
		"self halt."
		encoding := (sourceString at: lastIndex) leadingChar.
		encoding ~= startEncoding ifTrue: [lastIndex := lastIndex - 1. ^ stops endOfRun].
		ascii := (sourceString at: lastIndex) charCode.
		ascii > maxAscii ifTrue: [ascii := maxAscii].
		(encoding = 0 and: [ascii < stops size and: [(stops at: ascii + 1) ~~ nil]]) ifTrue: [^ stops at: ascii + 1].
		(self isBreakableAt: lastIndex in: sourceString in: (EncodedCharSet charsetAt: encoding)) ifTrue: [
			self registerBreakableIndex.
		].
		nextDestX := destX + (font widthOf: (sourceString at: lastIndex)).
		nextDestX > rightX ifTrue: [firstDestX ~= destX ifTrue: [^ stops crossedX]].
		destX := nextDestX + kernDelta.
		lastIndex := lastIndex + 1.
	].
	lastIndex := stopIndex.
	^ stops endOfRun
]

{ #category : #scanning }
MultiCharacterScanner >> scanMultiCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX stopConditions: stops kern: kernDelta [

	| ascii encoding f nextDestX maxAscii startEncoding floatDestX widthAndKernedWidth nextChar atEndOfRun |
	lastIndex := startIndex.
	lastIndex > stopIndex ifTrue: [lastIndex := stopIndex. ^ stops endOfRun].
	startEncoding := (sourceString at: startIndex) leadingChar.
	font ifNil: [font := (TextSharedInformation at: #DefaultMultiStyle) fontArray at: 1].
	font isFontSet ifTrue: [
		f := [font fontArray at: startEncoding + 1]
			on: Exception do: [:ex | nil].
		f ifNil: [ f := font fontArray at: 1].
		maxAscii := f maxAscii.
		spaceWidth := f widthOf: Space.
	] ifFalse: [
		maxAscii := font maxAscii.
	].
	floatDestX := destX.
	widthAndKernedWidth := Array new: 2.
	atEndOfRun := false.
	[lastIndex <= stopIndex] whileTrue: [
		encoding := (sourceString at: lastIndex) leadingChar.
		encoding ~= startEncoding ifTrue: [lastIndex := lastIndex - 1. ^ stops endOfRun].
		ascii := (sourceString at: lastIndex) charCode.
		ascii > maxAscii ifTrue: [ascii := maxAscii].
		(encoding = 0 and: [ascii < stops size and: [(stops at: ascii + 1) ~~ nil]]) ifTrue: [^ stops at: ascii + 1].
		(self isBreakableAt: lastIndex in: sourceString in: Latin1Environment) ifTrue: [
			self registerBreakableIndex.
		].
		nextChar := (lastIndex + 1 <= stopIndex) 
			ifTrue:[sourceString at: lastIndex + 1]
			ifFalse:[
				atEndOfRun := true.
				"if there is a next char in sourceString, then get the kern 
				and store it in pendingKernX"
				lastIndex + 1 <= sourceString size
					ifTrue:[sourceString at: lastIndex + 1]
					ifFalse:[	nil]].
		font 
			widthAndKernedWidthOfLeft: (sourceString at: lastIndex) 
			right: nextChar
			into: widthAndKernedWidth.
		nextDestX := floatDestX + (widthAndKernedWidth at: 1).
		nextDestX > rightX ifTrue: [destX ~= firstDestX ifTrue: [^stops crossedX]].
		floatDestX := floatDestX + kernDelta + (widthAndKernedWidth at: 2).
		atEndOfRun 
			ifTrue:[
				pendingKernX := (widthAndKernedWidth at: 2) - (widthAndKernedWidth at: 1).
				floatDestX := floatDestX - pendingKernX].
		destX := floatDestX .
		lastIndex := lastIndex + 1.
	].
	lastIndex := stopIndex.
	^ stops endOfRun
]

{ #category : #private }
MultiCharacterScanner >> setActualFont: aFont [
	"Set the basal font to an isolated font reference."

	font := aFont
]

{ #category : #private }
MultiCharacterScanner >> setAlignment: style [
	alignment := style.
	
]

{ #category : #private }
MultiCharacterScanner >> setConditionArray: aSymbol [

	aSymbol == #paddedSpace ifTrue: [^stopConditions := PaddedSpaceCondition "copy"].
	"aSymbol == #space ifTrue: [^stopConditions := SpaceCondition copy]."
	aSymbol == nil ifTrue: [^stopConditions := NilCondition "copy"].
	self error: 'undefined stopcondition for space character'.

]

{ #category : #private }
MultiCharacterScanner >> setFont [
	| priorFont |
	"Set the font and other emphasis."
	priorFont := font.
	text == nil ifFalse:[
		emphasisCode := 0.
		kern := 0.
		indentationLevel := 0.
		alignment := textStyle alignment.
		font := nil.
		(text attributesAt: lastIndex forStyle: textStyle)
			do: [:att | att emphasizeScanner: self]].
	font == nil ifTrue:
		[self setFont: textStyle defaultFontIndex].
	font := font emphasized: emphasisCode.
	priorFont 
		ifNotNil: [
			font = priorFont 
				ifTrue:[
					"font is the same, perhaps the color has changed?
					We still want kerning between chars of the same
					font, but of different color. So add any pending kern to destX"
					destX := destX + (pendingKernX ifNil:[0])].
			destX := destX + priorFont descentKern].
	pendingKernX := 0. "clear any pending kern so there is no danger of it being added twice"
	destX := destX - font descentKern.
	"NOTE: next statement should be removed when clipping works"
	leftMargin ifNotNil: [destX := destX max: leftMargin].
	kern := kern - font baseKern.

	"Install various parameters from the font."
	spaceWidth := font widthOf: Space.
"	map := font characterToGlyphMap."
	stopConditions := DefaultStopConditions.
]

{ #category : #private }
MultiCharacterScanner >> setFont: fontNumber [
	"Set the font by number from the textStyle."

	self setActualFont: (textStyle fontAt: fontNumber)
]

{ #category : #private }
MultiCharacterScanner >> text: t textStyle: ts [
	text := t.
	textStyle := ts
]

{ #category : #private }
MultiCharacterScanner >> textColor: ignored [
	"Overridden in DisplayScanner"
]

{ #category : #initialize }
MultiCharacterScanner >> wantsColumnBreaks: aBoolean [

	wantsColumnBreaks := aBoolean
]

{ #category : #'multilingual scanning' }
MultiCharacterScanner >> widthOf: char inFont: aFont [

	(char isMemberOf: CombinedChar) ifTrue: [
		^ aFont widthOf: char base.
	] ifFalse: [
		^ aFont widthOf: char.
	].



]
