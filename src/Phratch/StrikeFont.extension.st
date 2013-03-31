Extension { #name : #StrikeFont }

{ #category : #'*Phratch-Extensions' }
StrikeFont class >> closestNameTo: aString [
	"Answer the font name whose most similar to the given name."

	| lcName closestMatch closestPrefixLength thisName n prefixLength |
	lcName := aString asLowercase.
	(self fontNames includes: #Verdana)
		ifTrue: [closestMatch := #Verdana]
		ifFalse: [closestMatch := StrikeFont allInstances first name].
	closestPrefixLength := 0.
	self fontNames do: [:fn |
		thisName := fn asLowercase.
		thisName = lcName ifTrue: [^ fn].
		n := lcName size min: thisName size.
		prefixLength := ((1 to: n) detect: [:i | (lcName at: i) ~= (thisName at: i)] ifNone: [n + 1]) - 1.
		prefixLength > closestPrefixLength ifTrue: [
			closestMatch := fn.
			closestPrefixLength := prefixLength]].

	^ closestMatch


]

{ #category : #'*Phratch-Extensions' }
StrikeFont class >> fontName: aName size: aSize [ 

	^ self familyName: aName size: aSize

]

{ #category : #'*Phratch-Extensions' }
StrikeFont class >> fontNames [
	"StrikeFont fontNames"

	^ (StrikeFont allInstances collect: [:f | f name]) asSet asArray sort
]

{ #category : #'*Phratch-Extensions' }
StrikeFont >> isOSFont [
	"System fonts, to be rendered using the Unicode plugin, are represented by a StrikeFont with name beginning with an asterisk."

	^true

]

{ #category : #'*Phratch-Extensions' }
StrikeFont class >> osFontName: fontName size: desiredSize [
	"Answer a font to represent an OS font. Find a Squeak font of similar size to act as a placeholder for the OS font, then return a copy of that font with the OS font name and size."
	"Note: This approach allows the placeholder font to be used by the Squeak rendering system if the Unicode plugin is not available."
	"StrikeFont osFontName: 'VerdanaBold' size: 12"

	| font |
	"copy a Squeak font of similar size:"
	font := (StrikeFont familyName: 'Verdana' size: desiredSize) copy.
	font
		name: fontName;
		pointSize: desiredSize ";
		isOSFont: true".
	^ font
]

{ #category : #'*Phratch-Extensions' }
StrikeFont class >> sizesForFontName: fontName [
	"Answer a collection of sizes for the font with the given name. If there are no fonts with the given family name, answer an empty collection."
	"StrikeFont sizesForFontName: 'NewYork'"

	^ ((StrikeFont allInstances select: [:f | f name = fontName])
		collect: [:f | f pointSize]) asArray sort
]

{ #category : #'*Phratch-Extensions' }
StrikeFont >> xRangesFor: aString [
	"Anwer an array of (leftX, rightX) pairs for the given string."
	"(StrikeFont fontName: 'New York' size: 12) xRangesFor: 'Hello'"
	"| f | f := StrikeFont fontName: 'New York' size: 12. (1 to: 5) collect: [:i | f widthOfString: ('Hello' copyFrom: 1 to: i)]"

	| result lastX w right |
	result := Array new: aString size.
	lastX := 0.
	1 to: aString size do: [:i |
		w := self widthOf: (aString at: i).
		right := lastX + w.
		result at: i put: (Array with: lastX with: right).
		lastX := right].

	^ result
]
