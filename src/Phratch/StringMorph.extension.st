Extension { #name : #StringMorph }

{ #category : #'*Phratch-Extensions' }
StringMorph >> contents: aString font: aFont [

	self initialize.
	font := aFont.
	self contents: aString.
]

{ #category : #'*Phratch-Extensions' }
StringMorph >> isStringMorph [
	^ true
]

{ #category : #'*Phratch-Extensions' }
StringMorph >> justificationOffsetFor: aString [

	^ 0
	"^ (self width - (self stringWidth: self stringToDisplay)) max: 0"
]

{ #category : #'*Phratch-Extensions' }
StringMorph >> leftMargin [
	"Answer the left edge of this StringMorph. For a left-justified string, this the left edge of its bounding box, but for a right-justified string it may be inset."

	^ self left + (self justificationOffsetFor: contents)

]

{ #category : #'*Phratch-Extensions' }
StringMorph >> rightJustify:  ignored [
]

{ #category : #'*Phratch-Extensions' }
StringMorph >> stringExtent: aString [
	"Answer the extent of the given string in my current font."

	| s scanner |
	s := aString.
	"font notNil and: [font isOSFont]."
	scanner := (Smalltalk at: #BitBltDisplayScanner) quickPrintOn: Display box: Display boundingBox font: self font.
	scanner setStopConditions.
	^ scanner stringExtent: s
]

{ #category : #'*Phratch-Extensions' }
StringMorph >> stringHeight: aString [
	"Answer the height of the given string in my current font."

	^ (self stringExtent: aString) y

]

{ #category : #'*Phratch-Extensions' }
StringMorph >> stringToDisplay [
	"Answer the string that is displayed. In password mode, this will be all asterisks."

	^ contents
]

{ #category : #'*Phratch-Extensions' }
StringMorph >> stringWidth: aString [
	"Answer the width of the given string in my current font."

	^ (self stringExtent: aString) x
]

{ #category : #'*Phratch-Extensions' }
StringMorph >> stringWithEllipses: aString limitedToWidth: aNumber [
	"Answer the given string limited in width. If the string is too wide to fit, truncate it and append ellipses."

	| ellipses maxW s w |
	ellipses := '...' "asUTF32".
	maxW := (aNumber - (self stringWidth: ellipses)) max: 10.
	s := aString "asUTF32".
	(self stringWidth: s) < maxW ifTrue: [^ aString].

	1 to: s size do: [:i |
		w := self stringWidth: (s copyFrom: 1 to: i), ellipses.
		w > maxW ifTrue: [
			^ ((s copyFrom: 1 to: i - 1), ellipses) "asUTF8"]].

	^ aString

]

{ #category : #'*Phratch-Extensions' }
StringMorph >> xRangesFor: s [
	"Anwer an array of (leftX, rightX) pairs for the given string. For Unicode, there will be an entry in the resulting array for each UTF character in the input string, even when characters combine, so the x ranges for characters may overlap."
	"StringMorph new xRangesFor: 'Hello' "
	^ self font xRangesFor: s

]
