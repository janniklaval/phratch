Class {
	#name : #SyntaxElementMorph,
	#superclass : #Morph,
	#instVars : [
		'label',
		'name'
	],
	#category : #'Phratch-UI-Elements'
}

{ #category : #accessing }
SyntaxElementMorph class >> classNameFrom: aUserString [
	"answer a camel-cased uppercased String"

	^(aUserString allWordsCapitalized reject: [:c|
		c = $ ]) capitalized
]

{ #category : #'instance creation' }
SyntaxElementMorph class >> fromString: aString [

	|strg method compiler|
	strg := aString, '.^self'.
	compiler := Compiler new.
	compiler from: (ReadStream on: strg)
		class: nil class
		context: nil
		notifying: nil.

	method := compiler translate: (ReadStream on: strg) noPattern: true ifFail: nil.
	World activeHand attachMorph: method asElementFromText

	
]

{ #category : #accessing }
SyntaxElementMorph class >> objectNameFrom: aUserString [
	"answer a camel-cased String beginning with a lowercase character"

	|ans|
	ans := self classNameFrom: aUserString.
	ans at: 1 put: (ans at: 1) asLowercase.
	^ans
]

{ #category : #accessing }
SyntaxElementMorph class >> selectorFrom: aUserString [
	"answer a camel-cased Symbol beginning with a lowercase character"

	|ans ws char|
	ans := self classNameFrom: aUserString.
	ans at: 1 put: (ans at: 1) asLowercase.
	ws := WriteStream on: String new.
	1 to: ans size do: [:i|
		char := ans at: i.
		(char isUppercase and: [ (ans at: i - 1) = ($:)])
			ifTrue: [ws nextPut: char asLowercase]
			ifFalse: [ws nextPut: char]].
	^ws contents asSymbol
]

{ #category : #tests }
SyntaxElementMorph class >> test [
	1 even ifTrue:[] ifFalse:[^'yes']
]

{ #category : #accessing }
SyntaxElementMorph class >> wordsFrom: camelCase [
	| ws cap |
	
	cap := camelCase first isUppercase.

	(camelCase = 'ifTrue')
		ifTrue: [^'yes'].
	(camelCase = 'ifFalse')
		ifTrue: [^'no '].
	(camelCase = '_')
		ifTrue: [^':='].

	ws := WriteStream on: String new.

	camelCase do: [:c|
		c isUppercase 
			ifTrue: [ 
			ws nextPut: $ ; 
			nextPut: (cap ifTrue: [c] ifFalse: [c asLowercase ])]
			ifFalse: [ 
				ws nextPut: c.
				(c = ($:)) ifTrue: [ws nextPut: $ ]]].
	^ws contents

]

{ #category : #'dropping/grabbing' }
SyntaxElementMorph >> aboutToBeGrabbedBy: aHand [

	(owner isKindOf: ArgumentElementMorph)
		ifTrue: [owner removeContents. ^self ].
	(owner isKindOf: StepElementMorph)
		ifTrue: [owner removeNext. ^self].
	(owner isKindOf: MessageElementMorph)
		ifTrue: [owner removeCascadedElement: self. ^self].
	^ self



]

{ #category : #converting }
SyntaxElementMorph >> asSmalltalk [
	^''
]

{ #category : #drawing }
SyntaxElementMorph >> borderColorDark [
	^color twiceDarker
]

{ #category : #drawing }
SyntaxElementMorph >> borderColorLight [
	^color twiceLighter lighter
]

{ #category : #drawing }
SyntaxElementMorph >> borderColorVeryDark [
	^color twiceDarker darker
]

{ #category : #drawing }
SyntaxElementMorph >> borderColorVeryLight [
	^color twiceLighter twiceLighter lighter
]

{ #category : #accessing }
SyntaxElementMorph >> borderWidth [
	^1

]

{ #category : #menu }
SyntaxElementMorph >> contextMenu [

	^nil
]

{ #category : #drawing }
SyntaxElementMorph >> drawOn: aCanvas [ 

	|r bw |
	bw := self borderWidth.

	"border"
	"top"
	r := Rectangle origin: ((self left + bw) @ self top) corner: (self right @ (self top + bw)).
	aCanvas fillRectangle: r color: self borderColorVeryLight.

	"left"
	r := Rectangle origin: (self topLeft) corner: (self left + bw) @ (self bottom - bw).
	aCanvas fillRectangle: r color: self borderColorLight.

	"right"
	r := Rectangle origin: ((self right - bw) @ (self top + bw)) corner: self bottomRight.
	aCanvas fillRectangle: r color: self borderColorDark.

	"bottom"
	r := Rectangle origin: (self left @ (self bottom - bw)) corner: (self right - bw) @ self bottom.
	aCanvas fillRectangle: r color: self borderColorVeryDark.

	"body"
"	aCanvas fillRectangle: (Rectangle origin: (self topLeft + bw) corner: (self bottomRight - bw)) color: color"

	aCanvas fillRectangle: (Rectangle origin: (self topLeft + bw) corner: (self right - bw) @ (self center y - bw)) color: color twiceLighter.

	aCanvas fillRectangle: (Rectangle origin: (self left + bw) @ (self center y - bw) corner: (self right - bw) @ (self center y)) color: color lighter.

	aCanvas fillRectangle: (Rectangle origin: (self left + bw @ (self center y)) corner: (self bottomRight - bw)) color: color


]

{ #category : #copying }
SyntaxElementMorph >> duplicate [
	World activeHand addMorph: super fullCopy
]

{ #category : #evaluation }
SyntaxElementMorph >> evaluate [
	^Compiler evaluate: self asSmalltalk
]

{ #category : #private }
SyntaxElementMorph >> fit [
	self extent: label extent + (self borderWidth * 2).
	self width: (self width + (self labelFont widthOf: $ )).
	label position: bounds center - (label extent // 2).
	(owner respondsTo: #fit)
		ifTrue: [owner fit]

]

{ #category : #'event handling' }
SyntaxElementMorph >> handlesMouseDown: evt [
	"Return true if this morph wants to receive mouseDown events (i.e., mouseDown:, mouseMove:, mouseUp:). The default response is false; subclasses that implement mouse messages should override this to return true." 

	^ true
]

{ #category : #initialize }
SyntaxElementMorph >> initialize [
	super initialize.
	color := Color red
]

{ #category : #menu }
SyntaxElementMorph >> invokeContextMenu [
	|m choice|
	m := self contextMenu.
	m ifNotNil: [
		choice := m startUp.
		choice ifNotNil: [self perform: choice] ]
]

{ #category : #testing }
SyntaxElementMorph >> isRenameable [
	| editor |
	editor := (self ownerThatIsA: ElementsMethodEditorMorph).
	^editor isNil
	
]

{ #category : #accessing }
SyntaxElementMorph >> label [
	^name
	"^label contents"
]

{ #category : #accessing }
SyntaxElementMorph >> label: aString [

	name := aString.
	label ifNil: [
		label := StringMorph contents: '' font: self labelFont.
		label color: self labelColor.
		self addMorphFront: label].
	label contents: (self wordsFrom: name).
	self fit

]

{ #category : #private }
SyntaxElementMorph >> labelColor [
	^Color white
]

{ #category : #private }
SyntaxElementMorph >> labelFont [
	^StrikeFont fontName: 'Verdana' size: 10
]

{ #category : #'event handling' }
SyntaxElementMorph >> mouseDown: evt [
	"Handle a mouse down event."

	evt rightButtonPressed
		ifTrue: [ ^self invokeContextMenu].
	self startDrag: evt

]

{ #category : #accessing }
SyntaxElementMorph >> name [
	^name
]

{ #category : #accessing }
SyntaxElementMorph >> representsNil [
	^false
]

{ #category : #'*Phratch-Extensions' }
SyntaxElementMorph >> rootForGrabOf: aMorph [
	"Allow myself to be extracted."

	(owner notNil and: [owner isPartsBin])
		ifTrue: [^ super rootForGrabOf: aMorph]
		ifFalse: [^ self].

]

{ #category : #display }
SyntaxElementMorph >> showGeneratedSmalltalk [
	"StringHolder new contents: self asSmalltalk; openLabel: self class printString"	
	self inform: self asSmalltalk
]

{ #category : #display }
SyntaxElementMorph >> showResult [
	self inform: self evaluate printString
]

{ #category : #evaluation }
SyntaxElementMorph >> throwAway [
	self aboutToBeGrabbedBy: nil; delete
]

{ #category : #accessing }
SyntaxElementMorph >> wordsFrom: camelCase [
	^self class wordsFrom: camelCase
]
