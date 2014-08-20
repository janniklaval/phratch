Extension { #name : #String }

{ #category : #'*Phratch-Extensions' }
String >> asArgString [
	^ '"', self, '"'
]

{ #category : #'*Phratch-Extensions' }
String >> asNumberNoError [
	"Convert the given string to a number without giving errors about its format. Ignore non-digit characters and allow a leading '+', which kids sometimes type. Answer zero if empty."

	| s sign ch body |
	self size = 0
		ifTrue: [ ^ 0 ].
	s := ReadStream on: self.
	s skipSeparators.	"read sign character, if any"
	sign := 1.
	ch := s peek.
	({$+ . $-} includes: ch)
		ifTrue: [ 
			ch = $-
				ifTrue: [ sign := -1 ].
			s skip: 1 ].
	body := WriteStream on: (String new: 40).
	body nextPut: $0.
	[ s atEnd not and: [ s peek isDigit ] ] whileTrue: [ body nextPut: s next ].	"read digits before decimal point"
	('.,' includes: s peek)
		ifTrue: [ 
			"read decimal point (period or comma) and following digits, if any"
			s skip: 1.
			body nextPut: $..
			[ s atEnd not and: [ s peek isDigit ] ] whileTrue: [ body nextPut: s next ] ].	"read exponent"
	(s atEnd not and: [ 'eE' includes: s peek ])
		ifTrue: [ 
			s next.
			body nextPut: $e.
			(s atEnd not and: [ s peek = $- ])
				ifTrue: [ body nextPut: s next ].	"exponent sign"
			[ s atEnd not and: [ s peek isDigit ] ] whileTrue: [ body nextPut: s next ] ].	"exponent"
	^ sign * body contents asNumber
]

{ #category : #'*Phratch-Extensions' }
String >> blockVisible [

	^ ScriptablePhratchMorph isBlockVisible: self
]

{ #category : #'*Phratch-Extensions' }
String >> blockVisible: aBlock [

	^ ScriptablePhratchMorph blockVisible: self
]

{ #category : #'*Phratch-Extensions' }
String >> caseInsensitiveEqual: aString [ 
	"Answer whether the receiver is equal to aString ignoring case differences."

	^ (self compare: self with: aString collated: CaseInsensitiveOrder) = 2
]

{ #category : #'*Phratch-Extensions' }
String >> indexOfSeparatorStartingAt: index [
	"Answer the index of the next separator character found starting at the given index. Answer size + 1 if none is found."

	^ self
		indexOfAnyOf: CSSeparators
		startingAt: index 
		ifAbsent: [self size + 1]
]

{ #category : #'*Phratch-Extensions' }
String >> localized [
	"Answer myself translated into the current Scratch language. If there is no translation for me, then answer myself."

	| selfAsString |
	selfAsString := self asString.
	^( PhratchTranslator translationFor: selfAsString).

]

{ #category : #'*Phratch-Extensions' }
String >> trailingDigits [
	"Answer the trailing digits of a string such as 'foo123' If the string does not end in a digit, answer the empty string."
	"'foo123' trailingDigits"
	"'foo' trailingDigits"

	| i |
	i := self size.
	[(i > 0) and: [(self at: i) asCharacter isDigit]] whileTrue: [i := i - 1].
	^ self copyFrom: i + 1 to: self size

]

{ #category : #'*Phratch-Extensions' }
String >> withoutLeadingBlanks [
	
	"Return a copy of the receiver from which leading blanks have been
trimmed."

	
	| first |
	
	first := self findFirst: [:c | c isSeparator not ].

	first = 0 ifTrue: [^ ''].  
	
	"no non-separator character"
	
	^ self copyFrom: first to: self size

	
		
	" '    abc  d' withoutLeadingBlanks"

]

{ #category : #'*Phratch-Extensions' }
String >> withoutTrailingBlanks [
	"Return a copy of the receiver from which trailing blanks have been trimmed."

	| last |
	last := self findLast: [:c | c isSeparator not].
	last = 0 ifTrue: [^ ''].  "no non-separator character"
	^ self copyFrom: 1 to: last

	" ' abc  d   ' withoutTrailingBlanks"
]
