"
I manage language translations for Scratch. All of my code in in class methods.

"
Class {
	#name : #PhratchTranslator,
	#superclass : #Object,
	#classVars : [
		'ColonSuffix',
		'EllipsesSuffix',
		'HeaderString',
		'ISODict',
		'IsRTL',
		'IsRTLMath',
		'Language',
		'MIDITranslationSet',
		'RenderAntiAliasing',
		'RenderCenterOffsetCache',
		'RenderFont',
		'RenderHintString',
		'RenderScale',
		'RenderSuppressBold',
		'RenderVerticalTrimCache',
		'RenderWithSqueak',
		'TranslationDict',
		'UITranslationSet'
	],
	#category : #'Phratch-Objects'
}

{ #category : #'language translation' }
PhratchTranslator class >> addMIDITranslation: aString [

	MIDITranslationSet add: aString.

]

{ #category : #'language translation' }
PhratchTranslator class >> addSensorTranslations [
	"Add translations for the sensor names such as 'resistance-A' and 'A connected' from the translations of the root words if they exist."

	| root prefix postfix |
	root := TranslationDict at: 'connected' ifAbsent: [nil].
	root ifNotNil: [
		#(A B C D) do: [:ch |
			prefix := ch asString, ' '.
			TranslationDict at: (prefix, 'connected') put: (prefix, root)]].

	root := TranslationDict at: 'resistance' ifAbsent: [nil].
	root ifNotNil: [
		#(A B C D) do: [:ch |
			postfix := '-', ch asString.
			TranslationDict at: ('resistance', postfix) put: (root, postfix)]].

]

{ #category : #'language translation' }
PhratchTranslator class >> addUITranslation: aString [

	UITranslationSet add: aString.

]

{ #category : #'Unicode rendering' }
PhratchTranslator class >> centerOffsetForButtonWithFont: aStrikeFont [
	"Answer the vertical offset above the center of a button for the given font. If the translator has provided a render hint string, return an offset that will center the first character of that string. Otherwise, return an offset that will center a lowercase 'x'."
	"[self centerOffsetForFont: (StrikeFont fontName: 'VerdanaBold' size: 10)] msecs"

	| f r vOffset |
	(RenderCenterOffsetCache includesKey: aStrikeFont) ifTrue: [
		^ RenderCenterOffsetCache at: aStrikeFont].

	f := (StringMorph contents: self renderHintString font: aStrikeFont) imageForm.
	r := f rectangleEnclosingPixelsNotOfColor: Color transparent.
	vOffset := r top + (r height // 2).  "offset of string morph above the centerline of a button to center the given letter"

	r height = 0 ifTrue: [vOffset := f height // 2].

	RenderCenterOffsetCache at: aStrikeFont put: vOffset.
	^ vOffset

]

{ #category : #'language translation' }
PhratchTranslator class >> colonSuffix [
	"Answer a colon suffix. If the current language is RTL, then include the Unicode RTL mark after the colon."

	^ self isRTL ifTrue: [ColonSuffix] ifFalse: [':']

]

{ #category : #'Unicode rendering' }
PhratchTranslator class >> convertToMacRoman [
	"Convert my translations from UTF8 to MacRoman."

	| s |
	TranslationDict associationsDo: [:assoc |
		(assoc key asLowercase ~= 'language-name') ifTrue: [
			s := assoc value]].

]

{ #category : #'language translation' }
PhratchTranslator class >> currentLanguage [

	Language ifNil: [Language := 'en'].
	^ Language

]

{ #category : #'language translation' }
PhratchTranslator class >> ellipsesSuffix [
	"Answer an ellipses suffix (three periods). If the current language is RTL, then include the Unicode RTL mark after the colon."

	^ self isRTL ifTrue: [EllipsesSuffix] ifFalse: ['...']

]

{ #category : #'import/export' }
PhratchTranslator class >> extractLanguageFromFileNamed: aFilename [
	"Return the UTF8 value of the 'Language-Name:' header from the file with the given name, or nil if the file does not exist or it does not include that header."
	"self extractLanguageFromFileNamed: (self translationDir fullNameFor: 'Scratch.pot')"

	| f s i line lang nextLine lineSize |
	f := FileStream readOnlyFileNamedOrNil: aFilename.
	f ifNil: [^ nil].
	s := f contentsOfEntireFile.
	i := 0.
	[true] whileTrue: [
		i := s findString: 'language-name' startingAt: i + 1 caseSensitive: false.
		i = 0 ifTrue: [^ nil].
		line := (self withoutComment: (self lineOf: s containingIndex: i)) trimBoth.
		lineSize := line size.
		((line size > 0) and: [line first = $m and: [line last = $"]]) ifTrue: [
			line := (self extractQuotedStringFrom: line) trimBoth.
			(line asLowercase beginsWith: 'language-name') ifTrue: [
				nextLine := (self withoutComment: (self lineOf: s containingIndex: (i + lineSize))) trimBoth.
				lang := (nextLine copyFrom: 9 to: (nextLine size - 1)) trimBoth.
				^ (String withAll: lang)]]].
	^ nil

]

{ #category : #'language translation' }
PhratchTranslator class >> extractQuotedStringFrom: aString [
	"Extract the contents of a quoted string from a translation file line. If the line contains no double-quote characters, the string after the first space character is returned or, if there is no space character, the entire line. Only two escape sequences are currently recognized: newline and double-quote."

	| i s result ch |
	i := aString indexOf: $".
	i = 0 ifTrue: [aString indexOf: String space].
	s := ReadStream on: (aString copyFrom: i + 1 to: aString size).

	result := WriteStream on: String new.
	[s atEnd] whileFalse: [
		ch := s next.
		ch = $" ifTrue: [^ result contents].
		ch = $\
			ifTrue: [
				ch := s next.
				ch = $n ifTrue: [result cr].
				ch = $" ifTrue: [result nextPut: $"]]
			ifFalse: [result nextPut: ch]].

]

{ #category : #'Unicode rendering' }
PhratchTranslator class >> fixAmbigousRTLPunctuation [
	"In a right-to-left language such as Arabic, punctuation characters such as period can be treated as either right-to-left or left-to-right characters. When they appear at the beginning of a string, the directionality is ambiguous. We assume that translation strings that start with punctuation characters are intended to start in left-to-right mode. This method prefixes punctuation characters with the Unicode LTR mark character, U+200E."
	"Note: Embedded colons are prefixed with the LTR mark everwhere that they appear since block translation strings are broken into component parts that can start with a colon."

]

{ #category : #'rendering menu' }
PhratchTranslator class >> fontScaleMenu [
	"Present a menu of font scales."

	| menu s |
	menu := MenuMorph new defaultTarget: self.
	(0.8 to: 2.01 by: 0.1) do: [:n |
		s := n printString, 'x'.
		n = RenderScale ifTrue: [s := s, ' *'].
		menu add: s
			target: self 
			selector: #renderFontScale:
			argument: n].
	menu popUpInWorld.
]

{ #category : #locale }
PhratchTranslator class >> guessLanguage [
	"Try to guess a language setting based on the local."

	"PhratchTranslator guessLanguage"

	| lang country myLocale |
	(lang := Locale current primLanguage) ifNil: [ ^ 'en' ].
	lang size > 2
		ifTrue: [ lang := lang copyFrom: 1 to: 2 ].
	country := Locale current primCountry ifNil: [ ^ lang ].
	country size > 2
		ifTrue: [ country := country copyFrom: 1 to: 2 ].	"first try lang + country:"
	myLocale := lang asLowercase , '_' , country asLowercase.
	ISODict
		keysDo: [ :code | 
			code asLowercase = myLocale
				ifTrue: [ ^ code ] ].	"then try just lang:"
	myLocale := lang asLowercase.
	ISODict
		keysDo: [ :code | 
			code asLowercase = myLocale
				ifTrue: [ ^ code ] ].
	^ 'en'	"if no match, use English"
]

{ #category : #'language translation' }
PhratchTranslator class >> importLanguagesList [
	"Import the list of languages and language codes translated for Phratch by file names from 'Help/Translations'"

	| dir code lang |
	ISODict := Dictionary new.
	ISODict at: 'en' put: 'English'.
	dir := self translationDir.
	dir asFileReference fileNames do: [:f |
		(f endsWith: '.po') ifTrue: [
			code := f copyFrom: 1 to: (f size - 3).
			lang := self extractLanguageFromFileNamed: (dir / f) asFileReference fullName.
			lang ifNil: [lang := code].
			self insertISOCode: code forLanguage: code]].

]

{ #category : #'import/export' }
PhratchTranslator class >> importTranslation: aFilename [
	"Import a translation dictionary."
	"self importTranslation: 'cs.po'"

	| f lines lstream result |
	f := FileStream readOnlyFileNamedOrNil: (self translationDir / aFilename)asFileReference fullName.
	f ifNil: [
		DialogBoxMorph inform: 'File not found' withDetails: aFilename.
		^ nil].
	lines := f contentsOfEntireFile lines.

	"trim blanks"
	lines := lines collect: [:s | s withoutLeadingBlanks].

	lstream := ReadStream on: lines.
	[result := self parseTranslationLines: lstream] ifError: [
		PhratchError errorWithDialog: 'Error reading file: ', aFilename,' at line ', (lstream position asString), '.'].

	^ result

]

{ #category : #'class initialization' }
PhratchTranslator class >> initialize [
	"PhratchTranslator initialize"

	TranslationDict := Dictionary new.
	ISODict := Dictionary new.
	MIDITranslationSet := Set new.
	UITranslationSet := Set new.

	RenderAntiAliasing := false.
	HeaderString := ''.
	self setRenderingHints.

	ColonSuffix := ':', (String value: 16r200F).
	EllipsesSuffix := '...', (String value: 16r200F).

]

{ #category : #'language translation' }
PhratchTranslator class >> insertISOCode: code forLanguage: lang [

	ISODict at: code put: lang.

]

{ #category : #'import/export' }
PhratchTranslator class >> isRTL [
	"Returns true if the header 'Language-Direction' is set to 'RTL'"

	^ IsRTL

]

{ #category : #'language translation' }
PhratchTranslator class >> isRTLMath [
	"Returns true if the header 'Language-Direction' is set to 'RTL-math'"

	^ IsRTLMath

]

{ #category : #'language translation' }
PhratchTranslator class >> isoCodeForName: aString [

	(ISODict includes: aString)
		ifFalse:[^ aString]
		ifTrue:[^ ISODict keyAtValue: aString].

]

{ #category : #'language translation' }
PhratchTranslator class >> labelPartsFor: aString [
	"Answer a collection label strings for the translation of given block label. Currently handles one or two-part labels. In a two-part label, the label is split at the field name begginning with a percent sign. For example, 'when $String$ clicked' would yield the two label parts 'when' and 'clicked'."
	| s i p1 p2 j |
	s := PhratchTranslator translationFor: aString.
	i := s indexOf: $$ ifAbsent: [^ Array with: s with: ''].
	p1 := (s copyFrom: 1 to: i - 1) trimBoth.
	j := s indexOf: $$ startingAt: i+1 ifAbsent: [^ Array with: s with: ''].
	p2 := (s copyFrom: j+1 to: s size) trimBoth.
	^ Array with: p1 with: p2

]

{ #category : #'language translation' }
PhratchTranslator class >> languageNames [
	"Answer a list of language names for the languages menu. These are generally in the native language (e.g. 'Español') and must match the strings in the setLanguage: method."

	self importLanguagesList.
	^ ISODict values sort

]

{ #category : #'import/export' }
PhratchTranslator class >> lineOf: aString containingIndex: anIndex [
	"Answer the line of the given string that contains the given index."

	| cr lf i j ch |
	cr := Character cr.
	lf := Character lf.
	i := j := (anIndex within: 1 and: aString  size).
	[(i > 1) and: [((ch := aString at: i - 1) ~= cr) & (ch ~= lf)]] whileTrue: [i := i - 1].
	[(j < aString size) and: [((ch := aString at: j + 1) ~= cr) & (ch ~= lf)]] whileTrue: [j := j + 1].
	^ aString copyFrom: i to: j

]

{ #category : #'import/export' }
PhratchTranslator class >> parseCommandSpec: aCommandSpec [
	"Answer an array of token strings containing my keywords and argument specs."
	"self parseCommandSpec: '$Attributes$ of $Sprite$'"

	| result len i j spec k |
	result := OrderedCollection new.
	spec := aCommandSpec.
	len := aCommandSpec size.

	i := 1.
	[(i < len) and: [(spec at: i) isSeparator]] whileTrue: [i := i + 1].
	[i <= len] whileTrue: [
		j := spec indexOf: $$ startingAt: i.
		j > 0
			ifTrue: [
				j > i ifTrue: [result addLast: (spec copyFrom: i to: j - 1)].
				j < len
					ifTrue: [k := j + 1.
						((spec at: k) isLetter)
							ifTrue: [[(k+1 <= len) and: [(spec at: k+1) ~= $$]] whileTrue:[
								k := k + 1].
								(k >= len)
									ifTrue: [result addLast: (spec copyFrom: j to: len).
										i := len + 1]
									ifFalse: [result addLast: (spec copyFrom: j to: k).
										i := k+2]]
							ifFalse: [result addLast: '$'.
										i := j + 1]]
					ifFalse: [result addLast: '$'].
				i := j + 2]
			ifFalse: [
				result addLast: (spec copyFrom: i to: len).
				i := len + 1]].
	result := result select: [:s | s ~= ' '].
	^ result asArray collect: [:s | s trimBoth].
]

{ #category : #'import/export' }
PhratchTranslator class >> parseTranslationLines: lineStream [
	"Parse a language translation from the given stream of lines and answer the resulting translation dictionary."

	| result key val comments fuzzy |
	result := Dictionary new.
	"initialComments := OrderedCollection new."
	comments := OrderedCollection new.
	fuzzy := nil.

	"collect all translation diciontary entries"
	[lineStream atEnd] whileFalse: [
		((lineStream peek beginsWith: '# ')
			and: [(#('# BLOCKS' '# USER INTERFACE' '# MIDI INSTRUMENTS' '# FORMATTING') includes: (lineStream peek)) not])
			ifTrue: [comments add: (String withAll: (lineStream next))]
			ifFalse: [(lineStream peek beginsWith: '#, fuzzy')
				ifTrue: [fuzzy := lineStream next]
				ifFalse: [((lineStream peek beginsWith: 'msgid') or: [lineStream peek beginsWith: 'Ôªømsgid']) "BOM"
					ifTrue: [
						key := self extractQuotedStringFrom: lineStream next.
						val := ''.
						[lineStream atEnd not and: [lineStream peek beginsWith: 'msgstr']] whileTrue: [
							val := val, (self extractQuotedStringFrom: lineStream next).
							[lineStream atEnd not and: [lineStream peek beginsWith: '"']] whileTrue:[
								val := val, (self extractQuotedStringFrom: lineStream next)]].
						comments size > 0 ifTrue: [result at: key,'-comments' put: comments].
						fuzzy ifNotNil: [result at: key,'-fuzzy' put: (String withAll: fuzzy)].
						result at: key put: (String withAll: val).
						comments := OrderedCollection new.
						fuzzy := nil]
					ifFalse: [lineStream next.
						lineStream atEnd ifTrue: [^ result]]]]].

	^ result

]

{ #category : #'rendering menu' }
PhratchTranslator class >> renderFontScale: choice [

		choice ifNotNil: [
			RenderScale := choice.
			self updatePhratchUI].
]

{ #category : #'Unicode rendering' }
PhratchTranslator class >> renderHintString [
	"Answer a string to be used as an example button lable to adjust button size and label centering."
	"self renderHintString"
	"self showHintString"

	| result srcs |
	result := RenderHintString.
	result ifNil: [
		result := String new.
		srcs := #('New' 'Open' 'Save' 'Save As' 'Share!' 'Undo' 'Language' 'Extras' 'Want Help?' 'motion' 'looks' 'sound' 'pen' 'control' 'sensing' 'operators' 'variables').
		srcs do: [: s |
			result := result, (self translationFor: s)]].

	RenderWithSqueak ifTrue: [result := String withAll: result].

	^ result

]

{ #category : #'Unicode rendering' }
PhratchTranslator class >> renderScale [

	^ RenderScale

]

{ #category : #'Unicode rendering' }
PhratchTranslator class >> renderWithSqueak [

	^ RenderWithSqueak

]

{ #category : #'rendering menu' }
PhratchTranslator class >> renderingMenu [
	"Present a menu for experimenting with rendering settings."
	"self renderingMenu"

	| menu |
	World activeHand toolType: nil.
	Cursor normal show.
	RenderWithSqueak
		ifTrue: [ ^ Beeper beep ].

	menu := MenuMorph new defaultTarget: self.
	menu add: 'set font scale...' translated action: #fontScaleMenu.
	RenderSuppressBold
		ifTrue: [ menu add: 'allow bold' translated action: #toggleSuppressBold ]
		ifFalse: [ menu add: 'suppress bold' translated action: #toggleSuppressBold ].
	menu
		localize;
		popUpInWorld
]

{ #category : #'language translation' }
PhratchTranslator class >> setLanguage: aString [
	"Set the current language. If the language is not supported, use English (i.e. an empty translation dictionary)."

	| dict |
	"default to English"
	Language := 'en'. 
	TranslationDict := Dictionary new.
	HeaderString := ''.
	self setRenderingHints.  "clear rendering hints"

	aString = 'en' ifTrue: [^ self].

	dict := self importTranslation: aString, '.po'.
	dict ifNotNil: [
		Language := aString.
		TranslationDict := dict.
		HeaderString := dict at: '' ifAbsent: [''].
		dict removeKey: '' ifAbsent: [].
		self setRenderingHints.
		RenderWithSqueak ifTrue: [self convertToMacRoman].
		self isRTL ifTrue: [self fixAmbigousRTLPunctuation].
		self addSensorTranslations].

]

{ #category : #'Unicode rendering' }
PhratchTranslator class >> setRenderingHints [
	"Set optional rendering hints from fields in the translation file header. If a given hint is not explicitly set by the header, set it to its default value."

	| s |
	"default values:"
	IsRTL := false.
	IsRTLMath := false.
	RenderAntiAliasing := Smalltalk os isMacOSX.
	RenderFont := nil.
	RenderHintString := nil.
	RenderScale := 1.
	RenderSuppressBold := false.
	RenderCenterOffsetCache := IdentityDictionary new.
	RenderVerticalTrimCache := IdentityDictionary new.
	RenderWithSqueak := true.

	TranslationDict isEmpty
		ifTrue: [ ^ self ].
	(TranslationDict includesKey: 'Language-Direction')
		ifTrue: [ 
			IsRTLMath := (TranslationDict at: 'Language-Direction') = 'RTL-MATH'.	"asString asUppercase"
			IsRTL := IsRTLMath
				ifTrue: [ true ]
				ifFalse: [ (TranslationDict at: 'Language-Direction') = 'RTL'	"asString asUppercase" ] ].
	Smalltalk os isWin32
		ifTrue: [ 
			((TranslationDict includesKey: 'Win-Font') and: [ (TranslationDict at: 'Win-Font') size > 0 ])
				ifTrue: [ RenderFont := TranslationDict at: 'Win-Font' ] ].
	Smalltalk os isMacOSX
		ifTrue: [ 
			((TranslationDict includesKey: 'Mac-Font') and: [ (TranslationDict at: 'Mac-Font') size > 0 ])
				ifTrue: [ RenderFont := TranslationDict at: 'Mac-Font' ] ].
	Smalltalk os isWin32 | Smalltalk os isMacOSX
		ifFalse: [ 
			((TranslationDict includesKey: 'Linux-Font') and: [ (TranslationDict at: 'Linux-Font') size > 0 ])
				ifTrue: [ RenderFont := TranslationDict at: 'Linux-Font' ] ].
	s := TranslationDict at: 'Font-Scale' ifAbsent: [ '' ].
	s size > 0
		ifTrue: [ 
			RenderScale := s asString asNumber.
			RenderScale = 0
				ifTrue: [ RenderScale := 1 ].	"non-number string"
			RenderScale := RenderScale asNumber within: 0.5 and: 2.5 ].
	s := TranslationDict at: 'Suppress-Bold' ifAbsent: [ '' ].
	s size > 0
		ifTrue: [ 
			s asLowercase = 'true'
				ifTrue: [ RenderSuppressBold := true ] ].	"even though we are not actively using the hint string, keep this code in case we need it in the future:"
	s := TranslationDict at: 'Layout-Hint' ifAbsent: [ '' ].
	s size > 0
		ifTrue: [ RenderHintString := s ].
	RenderWithSqueak := self useSqueakRendering

]

{ #category : #'Unicode rendering' }
PhratchTranslator class >> stringExtent: aString font: aStrikeFont [
	"Answer the extent of the given string using my font under the current font rendering system."
	"self stringExtent: 'Hello, Phratch!' font: (StrikeFont fontName: 'Verdana' size: 18)"

	^ (aStrikeFont widthOfString: aString asString) @ aStrikeFont height
]

{ #category : #'rendering menu' }
PhratchTranslator class >> toggleSuppressBold [

	RenderSuppressBold := RenderSuppressBold not.
	self updatePhratchUI.

]

{ #category : #'import/export' }
PhratchTranslator class >> translationDir [
	"Returns the directory which contains the translation files and creates it if it doesn't exist."
	
	| dir |
	
	dir := FileSystem workingDirectory.
	(dir / 'locale') exists
		ifFalse: [[(dir / 'locale') createDirectory] ifError: [^ dir]].
	dir := dir / 'locale'.

	^ dir

]

{ #category : #'language translation' }
PhratchTranslator class >> translationFor: englishString [
	"Return the translation of the given (English) string for the current language. If there is no entry for the given string, return the original string."

	| s |
	s := TranslationDict at: englishString ifAbsent: [englishString].
	s size = 0 ifTrue: [s := englishString].
	^ s


]

{ #category : #'Unicode copy/paste' }
PhratchTranslator class >> unicodeClipboard [
	"Get the contents of the Unicode clipboard as UTF32."
	"self unicodeClipboard asArray"
	"(StringMorph contents: self unicodeClipboard) openInWorld"

	^ (String withAll: Clipboard clipboardText)
]

{ #category : #'Unicode copy/paste' }
PhratchTranslator class >> unicodeClipboardPut: unicodeOrString [
	"Store the given string in the Unicode paste buffer of the underlying OS. If the argument is a String, it is assumed to be encoded in MacRoman and is converted to Unicode."
	"self unicodeClipboardPut: (String withAll: #(65 0 0 66 67 13 12354 0 27700 119070))"
 " Corregido error sintaxsis"

	Clipboard clipboardText: unicodeOrString.
	^ self
]

{ #category : #'rendering menu' }
PhratchTranslator class >> updatePhratchUI [
	"Update the UI of all PhratchFrameMorphs after changing the font or font scale."

	RenderCenterOffsetCache := RenderCenterOffsetCache species new.
	RenderVerticalTrimCache := RenderVerticalTrimCache species new.
	PhratchFrameMorph allInstancesDo: [:m | m rebuildUIForNewLanguage].

]

{ #category : #'Unicode rendering' }
PhratchTranslator class >> useSqueakRendering [
	"Answer true if the current langauge can (or must) be rendered using Squeak,based on the availablility of a rendering plugin, the settings in the .po file and the contents of the translations. Assume that the header has already been processed to initialize HeaderDict."
	^ true
]

{ #category : #'Unicode rendering' }
PhratchTranslator class >> verticalTrimForFont: aStrikeFont [
	"Answer the number of pixels to trim from a button labeled with the given font. Some rendering systems (e.g. Pango on Mac OS), add excess space below the lowest extent of a font in some languages. This method computes the actual space needed by from the render hints string. It is the translator's responsibility to provide a render hints string that includes the tallest character and the the character with the maximum descent."
	"[self verticalTrimForFont: (StrikeFont fontName: 'VerdanaBold' size: 10)] msecs"

	| f r extra |
	(RenderVerticalTrimCache includesKey: aStrikeFont) ifTrue: [
		^ RenderVerticalTrimCache at: aStrikeFont].

	f := (StringMorph contents: self renderHintString font: aStrikeFont) imageForm.
	r := f rectangleEnclosingPixelsNotOfColor: (f colorAt: 0@0).
	extra := (f height - r height - 2) max: 0.
	RenderVerticalTrimCache at: aStrikeFont put: extra.
	^ extra


]

{ #category : #'import/export' }
PhratchTranslator class >> withoutComment: s [
	"Answer the given string without any comment. A hash character (#) begins a comment that runs to the end of the line unless the hash character is inside a double-quoted string."
	"PhratchTranslator withoutComment: '# full line comment'"
	"PhratchTranslator withoutComment: 'contents Öffnen # plus s comment'"

	| inString lastCh ch |
	(s indexOf: $#) = 0 ifTrue: [^ s].

	inString := false.
	lastCh := Character space.
	1 to: s size do: [:i |
		ch := s at: i.
		ch = $# ifTrue: [
			inString ifFalse: [^ s copyFrom: 1 to: i - 1]].
		ch = $" ifTrue: [
			(inString and: [lastCh = $\]) ifFalse: [
				inString := inString not]]].
	^ s

]
