Extension { #name : #BitBltDisplayScanner }

{ #category : #'*Phratch-Extensions' }
BitBltDisplayScanner class >> quickPrintOn: aForm box: aRectangle font: aStrikeFont [
	"Create an instance to print on the given form in the given rectangle."

	^(self new) quickPrintOn: aForm box: aRectangle font: aStrikeFont color: Color black
]

{ #category : #'*Phratch-Extensions' }
BitBltDisplayScanner >> quickPrintOn: aForm box: aRectangle font: aStrikeFont color: textColor [
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
BitBltDisplayScanner >> stringExtent: aString [
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
