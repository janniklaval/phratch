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
		'RenderPlugin',
		'RenderScale',
		'RenderSuppressBold',
		'RenderVerticalTrimCache',
		'RenderWithSqueak',
		'TranslationDict',
		'UITranslationSet'
	],
	#category : #'Phratch-Translation'
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
			root isUnicode ifTrue: [prefix := UTF8 withAll: prefix].
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
PhratchTranslator class >> canRenderUnicode [

	^ RenderPlugin notNil

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

{ #category : #'Unicode rendering' }
PhratchTranslator class >> centerOffsetForLabelWithFont: aStrikeFont [
	
	| co |
	co := self centerOffsetForButtonWithFont: aStrikeFont.
	^ co - 8.

]

{ #category : #'language translation' }
PhratchTranslator class >> checkAllTranslations [
	"Check all the translation dictionaries."
	"self checkAllTranslations"

	| untranslated |
	self languageNames do: [:lang |
		self setLanguage: lang.
		untranslated := self checkTranslationDict.
		untranslated size > 0 ifTrue: [lang, ' missing ', untranslated size printString]].

]

{ #category : #'language translation' }
PhratchTranslator class >> checkTranslationDict [
	"Do some sanity check on the current translation dictionary."

	| categories allSpecs mathOps |
	TranslationDict size = 0 ifTrue: [^ #()].  "English"

	categories := #(motion control looks pen numbers	sound sensing variables).
	categories do: [:cat | self assert: [TranslationDict includesKey: cat asString]].

	"make sure all translations have the same number arguments"
	TranslationDict associationsDo: [:assoc |
		self assert: [(self parameterSpecs: assoc key) = (self parameterSpecs: assoc value)]].

	"makes sure there is a translation for every block in every category (except variables)"
	allSpecs := Set new: 100.
	(PhratchSpriteMorph blockSpecs, PhratchStageMorph blockSpecs) do: [:spec |
		(spec isKindOf: Array) ifTrue: [allSpecs add: spec]].
	allSpecs add: #('else').

	"remove obsolete specs and math operators"
	PhratchSpriteMorph obsoleteBlockSpecs do: [:spec |  "remove obsolete block specs"
		allSpecs remove: spec ifAbsent: []].
	mathOps := ('+-*/<=>' asArray collect: [:ch | '$Number$ ', ch asString, ' $Number$']) asSet.
	allSpecs := allSpecs select: [:spec | (mathOps includes: spec first) not].

	allSpecs := allSpecs asArray sort: [:s1 :s2 | s1 first < s2 first].
	^ allSpecs select: [:spec | (TranslationDict includesKey: spec first) not]

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
			s := assoc value.
			s isUnicode ifTrue: [
				assoc value: s asMacRoman]]].

]

{ #category : #'language translation' }
PhratchTranslator class >> currentLanguage [

	Language ifNil: [Language := 'en'].
	^ Language

]

{ #category : #'Unicode rendering' }
PhratchTranslator class >> detectRenderPlugin [
	"Determine which plugin is available for rendering Unicode."
	"self detectRenderPlugin"

	| hasPlugin |
	RenderPlugin := nil.

	RenderCenterOffsetCache := IdentityDictionary new.
	RenderVerticalTrimCache := IdentityDictionary new.

	"first try the Uniscribe plugin"
	hasPlugin := true.
	[UnicodePlugin primMeasureString: 'test'] ifError: [hasPlugin := false].
	hasPlugin ifTrue: [RenderPlugin := UnicodePlugin. ^ self].

	"then try the Pango plugin"
	hasPlugin := true.
	[PangoPlugin2 primMeasureString: 'test'] ifError: [hasPlugin := false].
	hasPlugin ifTrue: [RenderPlugin := PangoPlugin2. ^ self].

	"if we get here, we don't have a Unicode rendering plugin"
	RenderPlugin := nil.

]

{ #category : #'language translation' }
PhratchTranslator class >> doNotTranslate [

	^ #(
	'!'
	'0'
	'1'
	'2'
	'3'
	'4'
	'5'
	'6'
	'7'
	'8'
	'9'
	'10'
	'a'
	'b'
	'c'
	'd'
	'e'
	'f'
	'g'
	'h'
	'i'
	'j'
	'k'
	'l'
	'm'
	'n'
	'o'
	'p'
	'q'
	'r'
	's'
	't'
	'u'
	'v'
	'w'
	'x'
	'y'
	'z'
	'A'
	'B'
	'$Number$ * $Number$'
	'$Number$ + $Number$'
	'$Number$ - $Number$'
	'$Number$ / $Number$'
	'$Number$ < $Number$'
	'$Number$ = $Number$'
	'$Number$ > $Number$'
	'$String$ > $String$'
	'$String$ = $String$'
	'$String$ < $String$'
	'*'
	'+'
	'-'
	'/'
	'<'
	'='
	'>'
	'sin'
	'cos'
	'tan'
	'asin'
	'acos'
	'atan'
	'ln'
	'log'
	'e ^'
	'10 ^'
	'enter'
	'motor'
	'Scratch'
	'Sprite1'
	'['
	']'
	'set translation formatting...'
	'enable remote access...'
	'Host Mesh'
	'Join Mesh'
	're-record')

]

{ #category : #'language translation' }
PhratchTranslator class >> ellipsesSuffix [
	"Answer an ellipses suffix (three periods). If the current language is RTL, then include the Unicode RTL mark after the colon."

	^ self isRTL ifTrue: [EllipsesSuffix] ifFalse: ['...']

]

{ #category : #'import/export' }
PhratchTranslator class >> export: keyString value: aStringOrUTF8 to: aStream [
	"Write the given string to the given stream as a quoted gettext format. If the string is multiple lines. store it as a sequence of strings in double quotes, each ending with '\n'."

	| lines |
	aStream nextPutAll: keyString; space.
	lines := (String withAll: aStringOrUTF8) lines.
	lines size = 1
		ifTrue: [aStream nextPut: $"; nextPutAll: lines first; nextPut: $"; crlf]
		ifFalse: [
			aStream nextPutAll: '""'; crlf.
			lines do: [:s | aStream nextPut: $"; nextPutAll: s; nextPutAll: '\n"'; crlf]].

]

{ #category : #'import/export' }
PhratchTranslator class >> exportPootleTranslations [
	"Exports translations from the locale folder into a new localeForPootle directory with a different subdirectory structure"
	"Need to figure out how to overwrite files without getting a permission dialog"
	"self exportPootleTranslations"

	| defaultDir localeDir localeForPootleDir fs dirName sdir |
	defaultDir := FileSystem workingDirectory.
	(defaultDir directoryNames includes: 'locale')
		ifTrue: [localeDir := self translationDir]
		ifFalse: [^ self "dialog should say no locale folder found"].
	localeForPootleDir := defaultDir directoryNamed: 'translate.scratch.mit.edu'.
	localeForPootleDir := localeForPootleDir directoryNamed: 'scratch'.
	localeDir fileNames do: [:n |
		(n endsWith: '.po') ifTrue: [
			dirName := (n copyFrom: 1 to: n size - 3).
			sdir := localeForPootleDir directoryNamed: dirName.
			fs := sdir newFileNamed: n.
			fs nextPutAll: (localeDir fileNamed: n) contentsOfEntireFile.
			fs close]].

]

{ #category : #'import/export' }
PhratchTranslator class >> exportStringsToTranslateFrom: aDictionary toFile: fName [
	"Export the strings to be translated either to Scratch.pot or an existing translation (.po) file."
	"self resetUITranslationSet. self resetMIDITranslationSet. self exportStringsToTranslateFrom: nil toFile: nil"
	"self resetMIDITranslationSet. self exportStringsToTranslateFrom: (self importTranslation: 'es.po') toFile: 'exportTest.po'"

	| dir fn header f sections templateDict title keys comments |

	self setLanguage: 'en'.
	header := HeaderString.
	dir := self translationDir.
	fn := fName.
	fn ifNil: [fn := self templateFilename].
	(dir exists: fn) ifTrue: [  "extract the existing header, then delete the old .po file"
		aDictionary ifNotNil: [
			header := aDictionary at: '' ifAbsent: [''].
			(dir / fn) delete]].
	f := FileStream newFileNamed: (dir / fn) fullName.
	"f nextPutAll: #(239 187 191) asByteArray asString."  "UTF8 byte-order mark - removed for now (Pootle)"

	"header comments are stored as '-comments' because the header key is the empty string"
	aDictionary ifNotNil: [
		comments := aDictionary at: '-comments' ifAbsent: [#()].
		comments do: [:s | f nextPutAll: s; crlf]].

	"header is stored as a multi-line translation entry for the empty string"
	self export: 'msgid' value: '' to: f.
	self export: 'msgstr' value: header to: f.
	f crlf.

	sections := {
		{'FORMATTING'.			self formattingHeaderFields}.
		{'BLOCKS'.				ScriptablePhratchMorph blockSpecsForTranslation}.
		{'USER INTERFACE'.		self uiTranslationSetAsSortedArray}.
 		{'MIDI INSTRUMENTS'.	self midiTranslationSet asArray sort}
	}.

	aDictionary ifNotNil: [templateDict := self importTranslation: self templateFilename].

	sections do: [:pair |
		title := pair first.
		keys := pair second asOrderedCollection.
		f nextPutAll: '############################################'; crlf.
		f nextPutAll: '# ', title; crlf.
		f nextPutAll: '############################################'; crlf.
		f crlf.

		((title = 'FORMATTING') and: [aDictionary isNil]) ifTrue: [
			f nextPutAll: self formattingSectionForPOT.
			keys := OrderedCollection new].

		keys removeAllSansError: self doNotTranslate.
		keys do: [:k |
			(aDictionary isNil or: [templateDict includesKey: k]) ifTrue: [
				"COMMENTS"
				comments := #().
				(templateDict notNil and: [templateDict includesKey: k,'-comments'])
					ifTrue: [ "use the comment from template .pot file if there is one"
						comments := (templateDict at: k, '-comments')]
					ifFalse: [ "else use the comment from the translation file"
						aDictionary ifNotNil: [
							comments := aDictionary at: k, '-comments' ifAbsent: [#()]]].
				comments do: [:s | f nextPutAll: s; crlf].

				"FUZZY TAG"
				(aDictionary notNil and: [aDictionary includesKey: k, '-fuzzy'])
					ifTrue: [f nextPutAll: '#, fuzzy'; crlf].

				"KEY"
				self export: 'msgid' value: k to: f.

				"TRANSLATION"
				(aDictionary notNil and: [aDictionary includesKey: k])
					ifTrue: [
						self export: 'msgstr' value: (aDictionary at: k) to: f]
					ifFalse: [
						(aDictionary notNil and: [aDictionary includesKey: k asLowercase])
							ifTrue: [  "TEMPORARY CAPITALIZATION HACK"
								self export: 'msgstr' value: (aDictionary at: k asLowercase) to: f]
							ifFalse: [
								(aDictionary notNil and: [(k endsWith: '?') and: [aDictionary includesKey: (k copyFrom: 1 to: k size - 1)]])
									ifTrue: [  "TEMPORARY QUESTION HACK"
										self export: 'msgstr' value: (aDictionary at: (k copyFrom: 1 to: k size - 1)) to: f]
									ifFalse: [  "BLANK TRANSLATION"
										self export: 'msgstr' value: '' to: f]]].
				f crlf]]].
	f close.

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
				^ (UTF8 withAll: lang)]]].
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

	| punctuation colon prefix utf32 s |
	punctuation := '.!%#' asByteArray.
	colon := $: asciiValue.
	prefix := UTF32 with: 16r200E.
	TranslationDict keys do: [:k |
		((TranslationDict at: k) isKindOf: UTF8) ifTrue: [
		utf32 := (UTF8 withAll: (TranslationDict at: k)) asUTF32.
		(utf32 size > 0 and: [punctuation includes: utf32 first]) ifTrue: [
			TranslationDict at: k put: (prefix, utf32) asUTF8].
		(utf32 includes: colon) ifTrue: [
			s := WriteStream on: (UTF32 new: 100).
			utf32 do: [:ch |
				ch = colon ifTrue: [s nextPut: 16r200E].
				s nextPut: ch].
			TranslationDict at: k put: s contents asUTF8]]].


]

{ #category : #'rendering menu' }
PhratchTranslator class >> fontMenu [
	"Present a menu of fonts."

	| menu choice |
	RenderPlugin ifNil: [^ Beeper beep].
	menu := MenuMorph new defaultTarget: self.
	RenderPlugin getFontList do: [:fn | 
		menu add: fn
			target: self 
			selector: #renderFont:
			argument: fn].
	menu popUpInWorld.
	
]

{ #category : #'rendering menu' }
PhratchTranslator class >> fontScaleMenu [
	"Present a menu of font scales."

	| menu choice s |
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

{ #category : #'Unicode rendering' }
PhratchTranslator class >> formFor: aString font: aStrikeFont fgColor: fgColor bgColor: bgColor [
	"Answer a Form containing the given string in the given font and color rendered with the current rendering system. Answer nil if no rendering system is available."
	"(self formFor: 'Hello, Phratch!' font: (StrikeFont fontName: 'VerdanaBold' size: 48) fgColor: Color black bgColor: Color blue) display"

	| f s |
	RenderPlugin ifNil: [^ nil].

	self setFont: aStrikeFont antialias: RenderAntiAliasing.
	RenderAntiAliasing
		ifTrue: [RenderPlugin setColorFG: fgColor BG: bgColor bgTransparent: true]
		ifFalse: [RenderPlugin setColorFG: fgColor BG: Color transparent bgTransparent: true].
 
	s := aString.
	s isUnicode ifTrue: [s := s asUTF8].  "convert from UTF32 to UTF8 if necessary"
	f := Form extent: (RenderPlugin primMeasureString: s) depth: 32.
	RenderPlugin drawString: s on: f.
	^ f

]

{ #category : #'Unicode rendering' }
PhratchTranslator class >> formFor: aString font: aStrikeFont fgColor: fgColor bgColor: bgColor suppressAntiAliasing: suppressAntiAliasing [
	"Answer a Form containing the given string in the given font and color rendered with the current rendering system. The suppressAntiAliasing flag is useful when the background color is not constant, such as when part of the text is highlighted during editing. Answer nil if no rendering system is available."
	"(self formFor: 'Hello, Phratch!' font: (StrikeFont fontName: 'VerdanaBold' size: 48) fgColor: Color black bgColor: Color blue) display"

	| f s |
	RenderPlugin ifNil: [^ nil].

	self setFont: aStrikeFont antialias: (RenderAntiAliasing & suppressAntiAliasing not).
	RenderAntiAliasing
		ifTrue: [RenderPlugin setColorFG: fgColor BG: bgColor bgTransparent: true]
		ifFalse: [RenderPlugin setColorFG: fgColor BG: Color transparent bgTransparent: true].
 
	s := aString.
	s isUnicode ifTrue: [s := s asUTF8].  "convert from UTF32 to UTF8 if necessary"
	f := Form extent: (RenderPlugin primMeasureString: s) depth: 32.
	RenderPlugin drawString: s on: f.
	^ f

]

{ #category : #'language translation' }
PhratchTranslator class >> formattingHeaderFields [

	^ #(
		'Language-Name'
		'Language-Direction'
		'Font-Scale'
		'Suppress-Bold'
		'Win-Font'
		'Mac-Font'
		'Linux-Font')

]

{ #category : #'language translation' }
PhratchTranslator class >> formattingSectionForPOT [

	| s |
	s :=
'# Language name as you''d like it to appear in the Languages menu
# (Required)
msgid "Language-Name"
msgstr ""

# Directionality of language
# LTR = Left to Right
# RTL = Right to Left
msgid "Language-Direction"
msgstr ""

# Scale to apply to font size (2 for twice as large)
# Use this if the font is too small for legibility on the Phratch interface
msgid "Font-Scale"
msgstr ""

# Set to ''true'' or ''false''
# Use this if you do not want any of the text to be bolded, for legibility
msgid "Suppress-Bold"
msgstr ""

# Font to use on a Windows system
msgid "Win-Font"
msgstr ""

# Font to use on a Mac system
msgid "Mac-Font"
msgstr ""

# Font to use on a Linux system
msgid "Linux-Font"
msgstr ""

'.

	s := s copyReplaceTokens: String cr with: String crlf.

	^ s.

]

{ #category : #locale }
PhratchTranslator class >> guessLanguage [
	"Try to guess a language setting based on the local."
	"PhratchTranslator guessLanguage"

	| lang country myLocale |
	(lang := self primLanguage) ifNil: [^ 'en'].
	lang size > 2 ifTrue: [lang := lang copyFrom: 1 to: 2].
	country := self primCountry ifNil: [^ lang].
	country size > 2 ifTrue: [country := country copyFrom: 1 to: 2].

	"first try lang + country:"
	myLocale := lang asLowercase, '_', country asLowercase.
	ISODict keys do: [:code | code asLowercase = myLocale ifTrue: [^ code]].

	"then try just lang:"
	myLocale := lang asLowercase.
	ISODict keys do: [:code | code asLowercase = myLocale ifTrue: [^ code]].

	^ 'en'  "if no match, use English"


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
			self canRenderUnicode
				ifTrue: [self insertISOCode: code forLanguage: lang]
				ifFalse: [self insertISOCode: code forLanguage: code]]].

]

{ #category : #'import/export' }
PhratchTranslator class >> importOLPCTranslations [
	"Imports translations from the OLPC Pootle translation directory into the Phratch/locale/ directory and renames the .po files"
	"First copy the /phratch/ folder from https://dev.laptop.org/~sayamindu/scratch_translations.zip to the local directory, then run this"
	"self importOLPCTranslations"

	| dir subDir |
	dir := FileSystem workingDirectory.
	(dir directoryNames includes: 'scratch')
		ifTrue: [dir := dir directoryNamed: 'scratch']
		ifFalse: [^ self "dialog should say no scratch folder found"].
	dir directoryNames do: [:n |
		subDir := dir directoryNamed: n.
		subDir rename: 'Scratch.po' toBe: (self translationDir fullNameFor: n,'.po')].

]

{ #category : #'import/export' }
PhratchTranslator class >> importPootleTranslations [
	"Imports translations from the LLK Pootle translation directory into the phratch/locale/ directory"
	"First checkout svn://translate.scratch.mit.edu:52400 to the local directory, then run this"
	"self importPootleTranslations"

	| dir subDir fs |
	dir := FileSystem workingDirectory.
	(dir directoryNames includes: 'translate.scratch.mit.edu')
		ifTrue: [dir := dir directoryNamed: 'translate.scratch.mit.edu'.
			(dir directoryNames includes: 'scratch')
				ifTrue: [dir := dir directoryNamed: 'scratch']
				ifFalse: [^ self "dialog should say no scratch folder found"]]
		ifFalse: [^ self "dialog should say no scratch folder found"].
	dir directoryNames do: [:n |
		(n = '.svn') ifFalse: [
			subDir := dir directoryNamed: n.
			fs := self translationDir newFileNamed: n,'.po'.
			fs nextPutAll: (subDir fileNamed: n,'.po') contentsOfEntireFile.
			fs close]].

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
		DialogBoxMorph inform: 'Error reading file: ', aFilename,' at line ', (lstream position asString), '.'].

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
	RenderPlugin := nil.
	self setRenderingHints.

	ColonSuffix := ':' asUTF8, (UTF32 with: 16r200F) asUTF8.
	EllipsesSuffix := '...' asUTF8, (UTF32 with: 16r200F) asUTF8.

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

{ #category : #'Unicode rendering' }
PhratchTranslator class >> isRTL: aBoolean [

	IsRTL := aBoolean.

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
PhratchTranslator class >> isoDict [

	^ ISODict

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

{ #category : #'language translation' }
PhratchTranslator class >> midiTranslationSet [

	^ MIDITranslationSet

]

{ #category : #'language translation' }
PhratchTranslator class >> parameterSpecs: aString [
	"Answer the sequence of parameter specs (e.g. $Number$) for the given block specification. Used for checking translations."
	"self parameterSpecs: 'this $Boolean$ is $String$ a $Color$ test $Number$'"
	"self parameterSpecs: 'this $Boolean$'"
	"self parameterSpecs: 'this $'"

	| result i j |
	result := OrderedCollection new.
	i := 1.
	[i < aString size] whileTrue: [
		i := aString indexOf: $$ startingAt: i.
		i = 0 ifTrue: [i := aString size]. 
		i < aString size ifTrue: [
			j := aString indexOf: $$ startingAt: i+1.
			j <= aString size ifTrue: [
				result addLast: (aString copyFrom: i to: j)].
			i := j+1].
		].
	^ result asArray

]

{ #category : #'import/export' }
PhratchTranslator class >> parseCommandSpec: aCommandSpec [
	"Answer an array of token strings containing my keywords and argument specs."
	"self parseCommandSpec: '$Attributes$ of $Sprite$'"

	| result len i j spec k |
	result := OrderedCollection new.
	spec := aCommandSpec.
	(spec isKindOf: UTF8) ifTrue: [spec := String withAll: spec].
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
								k _ k + 1].
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
			ifTrue: [comments add: (UTF8 withAll: (lineStream next))]
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
						fuzzy ifNotNil: [result at: key,'-fuzzy' put: (UTF8 withAll: fuzzy)].
						result at: key put: (UTF8 withAll: val).
						comments := OrderedCollection new.
						fuzzy := nil]
					ifFalse: [lineStream next.
						lineStream atEnd ifTrue: [^ result]]]]].

	^ result

]

{ #category : #locale }
PhratchTranslator class >> primCountry [
	"Return a string with ISO 639 country tag for this system, or nil if the primitive fails."
	"self primCountry"

	<primitive: 'primitiveCountry' module: 'LocalePlugin'>
	^ nil

]

{ #category : #locale }
PhratchTranslator class >> primLanguage [
	"Return a string with ISO 639 language tag for this system, or nil if the primitive fails."
	"self primLanguage"

	<primitive:'primitiveLanguage' module: 'LocalePlugin'>
	^ nil

]

{ #category : #'rendering menu' }
PhratchTranslator class >> renderAntiAliasing [

	^ RenderAntiAliasing


]

{ #category : #'as yet unclassified' }
PhratchTranslator class >> renderFont: choice [
	choice ifNotNil: [
		RenderFont := choice.
		self updatePhratchUI].

]

{ #category : #'as yet unclassified' }
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
		result := UTF8 new.
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
	RenderWithSqueak ifTrue: [^ Beeper beep].

	menu := MenuMorph new defaultTarget: self.
	menu add: 'set font scale...' action: #fontScaleMenu.
	RenderSuppressBold
		ifTrue: [menu add: 'allow bold' action: #toggleSuppressBold]
		ifFalse: [menu add: 'suppress bold' action: #toggleSuppressBold].

	menu localize; popUpInWorld
]

{ #category : #'language translation' }
PhratchTranslator class >> resetMIDITranslationSet [

	MIDITranslationSet := Set new.
	#('Accordion' 'Acoustic Bass' 'Acoustic Bass Drum' 'Acoustic Grand' 'Acoustic Snare' 'Agogo' 'Alto Sax' 'Applause' 'Bagpipe' 'Banjo' 'Baritone Sax' 'Bass Drum 1' 'Bassoon' 'Bird Tweet' 'Blown Bottle' 'Brass Section' 'Breath Noise' 'Bright Acoustic' 'Cabasa' 'Celesta' 'Cello' 'Chinese Cymbal' 'Choir Aahs' 'Church Organ' 'Clarinet' 'Claves' 'Clavinet' 'Closed Hi-Hat' 'Contrabass' 'Cowbell' 'Crash Cymbal 1' 'Crash Cymbal 2' 'Distortion Guitar' 'Drawbar Organ' 'Dulcimer' 'Electric Bass (finger)' 'Electric Bass (pick)' 'Electric Clean Guitar' 'Electric Grand' 'Electric Jazz Guitar' 'Electric Muted Guitar' 'Electric Piano 1' 'Electric Piano 2' 'Electric Snare' 'English Horn' 'FX 1 (rain)' 'FX 2 (soundtrack)' 'FX 3 (crystal)' 'FX 4 (atmosphere)' 'FX 5 (brightness)' 'FX 6 (goblins)' 'FX 7 (echoes)' 'FX 8 (sci-fi)' 'Fiddle' 'Flute' 'French Horn' 'Fretless Bass' 'Glockenspiel' 'Guitar Fret Noise' 'Guitar Harmonics' 'Gunshot' 'Hand Clap' 'Harmonica' 'Harpsichord' 'Helicopter' 'Hi Bongo' 'Hi Wood Block' 'Hi-Mid Tom' 'High Agogo' 'High Floor Tom' 'High Timbale' 'High Tom' 'Honky-Tonk' 'Kalimba' 'Koto' 'Lead 1 (square)' 'Lead 2 (sawtooth)' 'Lead 3 (calliope)' 'Lead 4 (chiff)' 'Lead 5 (charang)' 'Lead 6 (voice)' 'Lead 7 (fifths)' 'Lead 8 (bass+lead)' 'Long Guiro' 'Long Whistle' 'Low Agogo' 'Low Bongo' 'Low Conga' 'Low Floor Tom' 'Low Timbale' 'Low Tom' 'Low Wood Block' 'Low-Mid Tom' 'Maracas' 'Marimba' 'Melodic Tom' 'Music Box' 'Mute Cuica' 'Mute Hi Conga' 'Mute Triangle' 'Muted Trumpet' 'Nylon String Guitar' 'Oboe' 'Ocarina' 'Open Cuica' 'Open Hi Conga' 'Open Hi-Hat' 'Open Triangle' 'Orchestra Hit' 'Orchestral Strings' 'Overdriven Guitar' 'Pad 1 (new age)' 'Pad 2 (warm)' 'Pad 3 (polysynth)' 'Pad 4 (choir)' 'Pad 5 (bowed)' 'Pad 6 (metallic)' 'Pad 7 (halo)' 'Pad 8 (sweep)' 'Pan Flute' 'Pedal Hi-Hat' 'Percussive Organ' 'Piccolo' 'Pizzicato Strings' 'Recorder' 'Reed Organ' 'Reverse Cymbal' 'Ride Bell' 'Ride Cymbal 1' 'Ride Cymbal 2' 'Rock Organ' 'Seashore' 'Shakuhachi' 'Shamisen' 'Shanai' 'Short Guiro' 'Short Whistle' 'Side Stick' 'Sitar' 'Slap Bass 1' 'Slap Bass 2' 'Soprano Sax' 'Splash Cymbal' 'Steel Drums' 'Steel String Guitar' 'String Ensemble 1' 'String Ensemble 2' 'Synth Bass 1' 'Synth Bass 2' 'Synth Drum' 'Synth Voice' 'SynthBrass 1' 'SynthBrass 2' 'SynthStrings 1' 'SynthStrings 2' 'Taiko Drum' 'Tambourine' 'Tango Accordion' 'Telephone Ring' 'Tenor Sax' 'Timpani' 'Tinkle Bell' 'Tremolo Strings' 'Trombone' 'Trumpet' 'Tuba' 'Tubular Bells' 'Vibraphone' 'Vibraslap' 'Viola' 'Violin' 'Voice Oohs' 'Whistle' 'Woodblock' 'Xylophone') do:[:t |
		self addMIDITranslation: t].

	
]

{ #category : #'language translation' }
PhratchTranslator class >> resetUITranslationSet [

	UITranslationSet := Set new.
	#('Normal' 'new' 'New' 't' 'New sound:' 'New sprite:' 'No' 'New costume:' 'New Filename:' 'New background:' 'No motion blocks' 'OK' 'New Sprite' '3' 'No variables.' 'no scripts' 'm' 'normal readout' 'No serial ports found' 'No MIDI ports currently available.' 'Open' 'Off' 'f' 'Open Project' 'On' 'Preparing project...' 'or' 'Open a Scratch project' 'only face left-right' '10 ^' 'B' '10' 'play' 'Pictures' 'Password:' 'Project Notes' 'Project notes' 'Paint' 'pop' 'Project uploaded.' 'u' 'Project name' 'Please enter a number' 'Paint Editor' 'Projects' 'Paintbrush' 'pixelate' 'Project author:' 'Paint new sprite' 'Percent? (100 gives original size)' '4' 'n' 'abs' 'atan' 'Position the cross-hair to set the rotation center' 'asin' 'Quit' 'Quit Scratch' 'About Scratch' 'and' '-' 'acos' 'all' 'any' 'Brush size: ' 'g' '1 script' 'add comment' 'Animation' 'Art' 'add comment here' 'About this project:' 'Redo' 'right' 'resistance' 'backgrounds' 'Backgrounds' 'button pressed' 'Reference Guide' 'button' 'save picture of stage...' 'recording' 'Save As' 'record' 'Record' 'right arrow' '<' 'background' 'brightness' 'Remove viewer from stage' 'v' 're-record' 'set translation formatting...' 'reverse' 'Rotate clock-wise' 'Rotation degrees?' 'resize this sprite' 'rotate this sprite' 'Remote sensor connections enabled' 'Reading' 'Rotate counter-clock-wise' '5' 'Clear' 'o' 'space' 'Sounds' 'slider' 'cancel' 'sin' 'Sprite1' 'Sprites' 'connected' 'Stage' 'Could not read' 'stop' 'Choose a folder' 'color' 'Sound Recorder' 'cos' 'Save failed' 'Slider range:' 'costumes' 'sqrt' 'set slider min and max' 'Costumes' 'show ScratchBoard watcher' 'Cancel' 'Single-step speed?' 'costume' 'Computer' 'Sounds compressed' 'Set language' 'Camera' 'Clear canvas' 'Compress Sounds' 'select serial/USB port' 'Sprite' 'e ^' 'close port' 'Close dialog?' 'Compress Images' 'Rectangle tool (draw outlined or filled rectangle or square)' 'Save this project' 'Share this project' 'Scratch' 'Save the current project' 'Share' 'Switch to full stage' 'Show Motor Blocks' 'Could not write file' 'Switch to small stage' 'Stage selected:' 'Switch to presentation mode' 'a' 'Copy' 'tan' 'Set costume center' 'Save changes before quitting?' 'Shrink' 'Story' 'Save Project' 'Close paint editor?' 'thing' 'Support Site' 'Close sound recorder?' 'Select tool (move, modify, or delete selection)' 'Set Single Stepping' 'Start Single Stepping' 'Save the current project?' 'Simulation' 'Set rotation center' 'Create an empty project' 'Share This Project Online' 'Save' 'Stop everything' 'Scripts' 'Close and continue' 'Switch colors' 'Turbo speed' 'h' 'Stamp tool (select area, then stamp copies of it)' 'Done' 'can rotate' 'Tags:' 'Delete a list' 'Don''t Save' 'down arrow' 'Shrink sprite' 'clean up' 'distance' 'disable remote sensor connections' 'Save Stage Shot' 'Save Scripts Snapshot' 'this way' 'delete' 'Delete' 'drag to rotate' 'down' 'Text tool (edit text layer)' 'duplicate' 'Duplicate' 'Documents' 'Delete a variable' 'drag to resize' 'don''t rotate' 'Desktop' 'that way' 'p' 'Delete this background' 'Export failed' 'up' 'That variable name is already in use' 'tilt' 'Delete this sprite' 'enter' 'Eraser' 'Save a copy of the current project' 'Exit presentation mode' 'Export Costume' 'Undelete' 'Examples' 'Could not read project; file may be damaged' 'Updating thumbnails' 'Exit presentation' 'Export Sprite' 'Create account' 'Choose new sprite from file' 'Compress sounds and images' 'Eraser size' 'export this sprite' '/' 'Delete this costume' 'Connecting to ' '=' 'Upload succeeded!' 'true' 'up arrow' 'enable remote sensor connections' 'export' 'Extras menu' 'Export Sound' 'Eyedropper tool (select a color)' 'Enter presentation mode' 'save picture of scripts' 'Upload to Scratch Server' 'Start green flag scripts' 'Export Background' 'Data sent. Waiting for response...' 'edge' '6' 'Failed:' 'Edit' 'Ellipse tool (draw outlined or filled ellipse or circle)' 'draggable on website?' 'Stop Single Stepping' 'File' 'Delete this sound' 'w' 'Variable name?' 'View on stage' 'For all sprites' 'b' 'enable remote access...' 'false' 'first' 'Undo' 'Flip vertically' 'File not found' 'Flip horizontally' 'i' 'turn into new sprite' 'fisheye' 'For this sprite only' 'Sound quality:' 'The file name already exists. Overwrite existing file?' 'Uploading' 'Error!' 'export this costume' 'Flash blocks (fast)' 'export this sound' 'Flash blocks (slow)' '!' '>' 'x' 'Hmm...' 'Fill tool (fill areas with color or gradient)' 'Game' 'Grow' 'Getting Started' 'world' '7' 'whirl' 'ghost' 'What''s your name?' 'q' 'Get the last thing deleted' 'Grow sprite' 'Write Multiple Project Summaries' 'Get surprise sprite' 'Write Project Summary' 'Go To Scratch Website' 'grab screen region for new costume' '0' 'j' 'grab screen region for new sprite' 'help' 'Home' 'Help' 'Help Page' 'Hello!' 'hello ' 'Help Screens' 'Hide Motor Blocks' 'Host Mesh' 'c' '(empty)' 'High (biggest)' 'Yes' 'y' 'JPEG Quality (10-100)?' 'Import Project' 'import project' 'Import Image' 'Images compressed' 'import' 'Import' 'Import Sound' 'Import Costume' 'Your project is now online at' 'Import Background' '8' 'Incompatible Scratch file format' 'Import List' 'r' 'Your Scratch website login name:' 'Import an image on top of your current canvas' 'Is the folder read-only?' '1' 'k' 'Zoom in' 'Join Mesh' #'[' 'Zoom out' '*' 'd' 'kbytes' 'z' '9' 's' 'left' 'light' 'Language' 'ln' 'List name?' 'Low' 'log' '2' 'last' 'l' 'left arrow' 'length' 'large readout' 'Lowest (smallest)' 'Line tool (draw lines)' '+' 'e' 'Music' 'mosaic' 'Message name:' 'meow' 'mod' #']' 'Min:' 'more' 'mouse-pointer' 'Move' 'Make a variable' 'Max:' 'More tags:' 'Make a list' 'My Projects' 'mouse x:' 'mouse y:' 'A' 'New file name?') do: [:t |
		self addUITranslation: t].

]

{ #category : #'Unicode rendering' }
PhratchTranslator class >> setFont: aStrikeFont antialias: antialiasFlag [

	| font isBold fontName fontSize |
	font := aStrikeFont.
	font ifNil: [font := StrikeFont fontName: 'Times' size: 14].

	fontName := font name.
	fontSize := (font pointSize * RenderScale) rounded.
	isBold := false.

	(fontName asLowercase endsWith: 'bold') ifTrue: [
		fontName := fontName copyFrom: 1 to: (fontName size - 4).
		isBold := true].

	aStrikeFont isOSFont ifFalse: [
		(fontName beginsWith: 'VerdanaBoldNarrowSpace') ifTrue: [
			fontName := 'Verdana'.
			isBold := true].

		(fontName beginsWith: 'Times') ifTrue: [ "Squeak font; not used by Phratch"
			fontName := 'Comic'.
			fontSize := font pointSize + 1].

		RenderFont ifNotNil: [fontName := RenderFont].
		RenderSuppressBold ifTrue: [isBold := false]].

	RenderPlugin
		primSetFont: fontName
		size: fontSize
		bold: isBold
		italic: false
		antialias: antialiasFlag.

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
	PhratchTranslator detectRenderPlugin.

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
	RenderAntiAliasing := OSPlatform isMacOSX.
	RenderFont := nil.
	RenderHintString := nil.
	RenderScale := 1.
	RenderSuppressBold := false.
	RenderCenterOffsetCache := IdentityDictionary new.
	RenderVerticalTrimCache := IdentityDictionary new.
	RenderWithSqueak := true.

	TranslationDict isEmpty ifTrue: [^ self].

	(TranslationDict includesKey: 'Language-Direction') ifTrue: [
		IsRTLMath := (TranslationDict at: 'Language-Direction') "asString asUppercase" = 'RTL-MATH'.
		IsRTLMath
			ifTrue: [IsRTL := true]
			ifFalse: [IsRTL := (TranslationDict at: 'Language-Direction') "asString asUppercase" = 'RTL']].

	OSPlatform isWin32 ifTrue: [
		((TranslationDict includesKey: 'Win-Font') and: [(TranslationDict at: 'Win-Font') size > 0])
			ifTrue: [RenderFont := TranslationDict at: 'Win-Font']].

	OSPlatform isMacOSX ifTrue: [
		((TranslationDict includesKey: 'Mac-Font') and: [(TranslationDict at: 'Mac-Font') size > 0])
			ifTrue: [RenderFont := TranslationDict at: 'Mac-Font']].

	(OSPlatform isWin32 | OSPlatform isMacOSX) ifFalse: [
		((TranslationDict includesKey: 'Linux-Font') and: [(TranslationDict at: 'Linux-Font') size > 0])
			ifTrue: [RenderFont := TranslationDict at: 'Linux-Font']].

	s := TranslationDict at: 'Font-Scale' ifAbsent: [''].
	s size > 0 ifTrue: [
		RenderScale := s asString asUTF32  asNumber.
		RenderScale = 0 ifTrue: [RenderScale := 1].  "non-number string"
		RenderScale := RenderScale asNumber within: 0.5 and: 2.5].

	s := TranslationDict at: 'Suppress-Bold' ifAbsent: [''].
	s size > 0 ifTrue: [s asMacRoman  asLowercase = 'true' ifTrue: [RenderSuppressBold := true]].

	"even though we are not actively using the hint string, keep this code in case we need it in the future:"
	s := TranslationDict at: 'Layout-Hint' ifAbsent: [''].
	s size > 0 ifTrue: [RenderHintString := s].

	RenderWithSqueak := self useSqueakRendering.

]

{ #category : #'Unicode rendering' }
PhratchTranslator class >> showHintString [
	"self showHintString"

	| f p r |
	p := 20@70.
	f := (StringMorph contents: self renderHintString font: (StrikeFont fontName: 'Verdana' size: 18)) imageForm.
	r := f rectangleEnclosingPixelsNotOfColor: (f colorAt: 0@0).
	Display fillWhite: (p extent: f extent).
	f displayOn: Display at: p rule: Form paint.
	Display border: (r translateBy: p) width: 1 rule: Form over fillColor: Color blue.

	^ {
		f height.
		r height.
		f height - r height.
		self verticalTrimForFont: (StrikeFont fontName: 'VerdanaBold' size: 10)
	}
]

{ #category : #startup }
PhratchTranslator class >> shutDown [
	"Clear the rendering plugin."

	RenderPlugin := nil.

]

{ #category : #startup }
PhratchTranslator class >> startUp [
	"self startup"

	self detectRenderPlugin.

]

{ #category : #'Unicode rendering' }
PhratchTranslator class >> stringExtent: aString font: aStrikeFont [
	"Answer the extent of the given string using my font under the current font rendering system."
	"self stringExtent: 'Hello, Phratch!' font: (StrikeFont fontName: 'Verdana' size: 18)"

	| s |
	RenderPlugin ifNil: [  "no renderer; use Squeak font size"
		^ (aStrikeFont widthOfString: aString asString) @ aStrikeFont height].

	aString size = 0 ifTrue: [^ 5@((aStrikeFont pointSize * RenderScale) rounded)].

	s := aString.
	s isUnicode ifTrue: [s := s asUTF8].  "convert from UTF32 to UTF8 if necessary"
	self setFont: aStrikeFont antialias: RenderAntiAliasing.
	^ RenderPlugin primMeasureString: s

]

{ #category : #'import/export' }
PhratchTranslator class >> templateFilename [
	"Returns the filename for the translation template file to send to users."

	^ 'BYOB.pot'

]

{ #category : #'rendering menu' }
PhratchTranslator class >> toggleAntiAliasing [

	RenderAntiAliasing := RenderAntiAliasing not.
	self updatePhratchUI.

]

{ #category : #'rendering menu' }
PhratchTranslator class >> toggleSuppressBold [

	RenderSuppressBold := RenderSuppressBold not.
	self updatePhratchUI.

]

{ #category : #'language translation' }
PhratchTranslator class >> translationDict [

	^ TranslationDict

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
	RenderWithSqueak
		ifTrue: [s isUnicode ifTrue: [s := s asMacRoman]]
		ifFalse: [s := s asString].
	^ s


]

{ #category : #'language translation' }
PhratchTranslator class >> uiTranslationSet [

	#('' '?'), ScriptablePhratchMorph blockSpecsForTranslation do: [:e |
		UITranslationSet remove: e ifAbsent: []].

	^ UITranslationSet

]

{ #category : #'language translation' }
PhratchTranslator class >> uiTranslationSetAsSortedArray [

	^ self uiTranslationSet asArray
		sort: [:a :b | a asLowercase <= b asLowercase]

]

{ #category : #'Unicode copy/paste' }
PhratchTranslator class >> unicodeClipboard [
	"Get the contents of the Unicode clipboard as UTF32."
	"self unicodeClipboard asArray"
	"(StringMorph contents: self unicodeClipboard) openInWorld"

	| n buf raw ch out s ch2 |
	RenderPlugin ifNil: [
		"if there is no plugin, return the normal text clipboard as UTF32"
		^ (UTF8 withAll: Clipboard clipboardText) asUTF32].

	n := RenderPlugin primClipboardSize.
	n = 0 ifTrue: [
		"if unicode clipboard is empty, try the normal one"
		^ (UTF8 withAll: Clipboard clipboardText) asUTF32].

	buf := SoundBuffer new: n.
	n := RenderPlugin primGetCliboardInto: buf.
	raw := (1 to: n) collect: [:i |
		ch := buf at: i.
		ch < 0 ifTrue: [ch := ch + 65536].
		ch].

	out := WriteStream on: (UTF32 new: n).
	s := ReadStream on: raw.
	[s atEnd] whileFalse: [
		ch := s next.
		(ch between: 16rD800 and: 16rDBFF)
			ifTrue: [
				(s atEnd not and: [s peek between: 16rDC00 and: 16rDFFF]) ifTrue: [
					ch2 := s next.
					ch := ((ch bitAnd: 16r3FF) << 10) + (ch2 bitAnd: 16r3FF) + 16r10000.
					out nextPut: ch]]
			ifFalse: [
				((ch = 0) | (ch = 10)) ifFalse: [out nextPut: ch]]].

	^ out contents

]

{ #category : #'Unicode copy/paste' }
PhratchTranslator class >> unicodeClipboardPut: unicodeOrString [
	"Store the given string in the Unicode paste buffer of the underlying OS. If the argument is a String, it is assumed to be encoded in MacRoman and is converted to Unicode."
	"self unicodeClipboardPut: (UTF32 withAll: #(65 0 0 66 67 13 12354 0 27700 119070))"
 " Corregido error sintaxsis"
	| useCRLF s buf ch|
	RenderPlugin ifNil: [
		"if there is no plugin, put UTF8 for string into the normal text clipboard"
		Clipboard clipboardText: unicodeOrString asUTF8.
		^ self].

	useCRLF := OSPlatform isWin32.
	s := unicodeOrString.
	s isUnicode ifFalse: [s := s asUTF8].
	s := s asUTF32.
	buf := WriteStream on: (Array new: 2 * s size).
	s do: [:ch1 | ch:= ch1.
		ch > 16r10000
			ifTrue: [
				"extended range character"
				ch := ch - 16r10000.
				buf nextPut: (16rD800 bitOr: ((ch >> 10) bitAnd: 16r3FF)) - 16r10000.
				buf nextPut: (16rDC00 bitOr: (ch bitAnd: 16r3FF)) - 16r10000]
			ifFalse: [
				ch >= 16r8000 ifTrue: [
					 "make signed to allow storage in SoundBuffer"
					ch := ch - 16r10000].
				ch ~= 0 ifTrue: [buf nextPut: ch].
				(useCRLF and: [ch = 13]) ifTrue: [buf nextPut: 10]]].

	RenderPlugin primCliboardPut: (SoundBuffer withAll: buf contents) size: buf size.

]

{ #category : #'rendering menu' }
PhratchTranslator class >> updatePhratchUI [
	"Update the UI of all PhratchFrameMorphs after changing the font or font scale."

	RenderCenterOffsetCache := RenderCenterOffsetCache species new.
	RenderVerticalTrimCache := RenderVerticalTrimCache species new.
	PhratchFrameMorph allInstancesDo: [:m | m rebuildUIForNewLanguage].

]

{ #category : #'import/export' }
PhratchTranslator class >> updateTranslationFiles [
	"Takes the existing .po files and updates them to reflect the latest Phratch strings to be translated."
	"self updateTranslationFiles"

	| translationDict codes |
	self importLanguagesList.
	codes := self isoDict keys.
	codes do: [:c |
		(c = 'en') ifFalse:[
			translationDict := self importTranslation: c,'.po'.
			self exportStringsToTranslateFrom: translationDict toFile: c,'.po']].

]

{ #category : #'Unicode rendering' }
PhratchTranslator class >> useSqueakRendering [
	"Answer true if the current langauge can (or must) be rendered using Squeak,based on the availablility of a rendering plugin, the settings in the .po file and the contents of the translations. Assume that the header has already been processed to initialize HeaderDict."

	self canRenderUnicode ifFalse: [^ true].

	IsRTL ifTrue: [^ false].
	RenderScale ~= 1 ifTrue: [^ false].
	RenderSuppressBold ifTrue: [^ false].

true ifTrue: [^ false].  "disable Squeak rendering, even if language can be represented in MacRoman"

	TranslationDict associationsDo: [:assoc |
		((assoc key endsWith: '-comment') not and:
		 [(assoc key asLowercase = 'language-name') not and:
		 [assoc value isUnicode]]) ifTrue: [
			assoc value isMacRoman ifFalse: [^ false]]].

	^ true

]

{ #category : #'language translation' }
PhratchTranslator class >> varSpecTranslationFor: spec varName: varName [
	"Return the translation of a variable setter command spec for the given variable."

	| s i |
	s :=  PhratchTranslator translationFor: spec.
	i := s indexOfSubCollection: '$Variable$' startingAt: 1.
	^ (s copyFrom: 1 to: i - 1), varName, (s copyFrom: (i + 2) to: s size).

]

{ #category : #'import/export' }
PhratchTranslator class >> verifyTranslationFiles [
	"Returns a dictionary with each language filename as a key and a dictionary with the header and formatting fields as the key's value"
	"self verifyTranslationFiles"

	| verificationDict dict subDict |
	verificationDict := Dictionary new.
	self translationDir fileNames do: [: n |
		dict := self importTranslation: n.
		subDict := Dictionary new.
		subDict at: 'header' put: (dict at: '' ifAbsent: ['no header']).
		self formattingHeaderFields do: [:f |
			subDict at: f put: (dict at: f ifAbsent: [''])].

		verificationDict at: n put: subDict].
	^ verificationDict
]

{ #category : #'import/export' }
PhratchTranslator class >> verifyTranslationFilesArgOrder [
	"Returns a dictionary with any language file with invalid arguments as the key and the invalid arguments as the value"
	"self verifyTranslationFilesArgOrder2"

	| verificationDict dict subDict ts argsS argsTS |
	verificationDict := Dictionary new.
	self translationDir fileNames do: [: n |
		dict := self importTranslation: n.
		subDict := Dictionary new.
		ScriptablePhratchMorph blockSpecsForTranslation do: [:s |
			ts := dict at: s ifAbsent: [s].
			argsS := (CommandBlockMorph parseCommandSpec: s) select: [:a | CommandBlockMorph isArgSpec: a].
			argsTS := (CommandBlockMorph parseCommandSpec: ts) select: [:a | CommandBlockMorph isArgSpec: a].
			(argsS sort = argsTS sort)
				ifFalse: [(ts size > 0) ifTrue: [subDict at: s put: ts]]].
		(subDict values size > 0)
			ifTrue: [verificationDict at: n put: subDict]].

	^ verificationDict

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

{ #category : #'Unicode rendering' }
PhratchTranslator class >> xRangesFor: utf8 font: aStrikeFont [
	"Anwer an array of (leftX, rightX) pairs for the given Unicode string. There will be an entry in the resulting array for each UTF character in the input string, even when characters combine. Thus, in general, the x ranges for characters can overlap."

	RenderPlugin ifNil: [^ Array new: (utf8 asUTF32 size) withAll: #(0 0)].
	self setFont: aStrikeFont antialias: RenderAntiAliasing.
	^ RenderPlugin xRangesFor: utf8

]
