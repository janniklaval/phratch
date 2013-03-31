Extension { #name : #StringMorph }

{ #category : #'*Phratch-Extensions' }
StringMorph >> closeEditor [
	"Be sure that any StringMorphEditors on me have been removed."

	self doneWithEdits.
	submorphs size = 0 ifTrue: [^ self].
	submorphs copy do: [:m |
		(m isKindOf: StringMorphEditor) ifTrue: [m delete]].
]

{ #category : #'*Phratch-Extensions' }
StringMorph >> contents: aString font: aFont [

	self initialize.
	font := aFont.
	self contents: aString.
]

{ #category : #'*Phratch-Extensions' }
StringMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*Phratch-Extensions' }
StringMorph >> forceUnicodeRendering: ignored [
]

{ #category : #'*Phratch-Extensions' }
StringMorph >> initFieldsFrom: anObjStream version: classVersion [
	| fontSpec |
	super initFieldsFrom: anObjStream version: classVersion.
	fontSpec := anObjStream nextField.
	fontSpec ifNotNil: [ font := StrikeFont fontName: fontSpec first size: fontSpec second ].
	self initFieldsNamed: #(#emphasis #contents) from: anObjStream
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

{ #category : #'*Phratch' }
StringMorph >> rightJustify:  ignored [
]

{ #category : #'*Phratch-Extensions' }
StringMorph >> storeFieldsOn: anObjStream [

	self closeEditor.
	super storeFieldsOn: anObjStream.
	font
		ifNil: [anObjStream putField: nil]
		ifNotNil: [anObjStream putField: (Array with: font name with: font pointSize)].
	self storeFieldsNamed: #(
		emphasis
		contents
	) on: anObjStream.

]

{ #category : #'*Phratch-Extensions' }
StringMorph >> stringExtent: aString [
	"Answer the extent of the given string in my current font."

	| s usingOSFont scanner |
	s := aString.
	usingOSFont := font notNil and: [font isOSFont].
	s isUnicode | usingOSFont ifTrue: [
		ScratchTranslator canRenderUnicode
			ifTrue: [^ ScratchTranslator stringExtent: s asMacRoman    font: self font]
			ifFalse: [s := s asMacRoman]].

	scanner := MultiDisplayScanner quickPrintOn: Display box: Display boundingBox font: self font.
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

	| n s |
	"passwordMode ifNil: [passwordMode := false].
	passwordMode ifTrue: [
		n := (contents isKindOf: UTF8) ifTrue: [contents asUTF32 size] ifFalse: [contents size].
		s := String new: n withAll: $*.
		contents isUnicode ifTrue: [s := s asUTF8].
		^ s]."

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
	ellipses := ScratchTranslator ellipsesSuffix "asUTF32".
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
	"StringMorph new xRangesFor: 'Hello' asUTF8"

	s isUnicode ifTrue: [
		ScratchTranslator canRenderUnicode
			ifTrue: [^ ScratchTranslator xRangesFor: s asMacRoman  font: self font]
			ifFalse: [^ self font xRangesFor: s asMacRoman]].

	^ self font xRangesFor: s

]
