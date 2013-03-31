Class {
	#name : #SyntaxElementMorph,
	#superclass : #Morph,
	#instVars : [
		'label',
		'name'
	],
	#category : #'Phratch-BYOB-Elements'
}

{ #category : #'as yet unclassified' }
SyntaxElementMorph class >> classNameFrom: aUserString [
	"answer a camel-cased uppercased String"

	^(aUserString allWordsCapitalized reject: [:c|
		c = $ ]) capitalized
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
SyntaxElementMorph class >> isDecompilable: selector class: class [

	|  original compiled text node|
	original := class methodDict at: selector.
	text := ((class decompilerClass new)
		decompile: selector in: class method: original) printString.
	node := Compiler new 
		compile: text 
		in: class 
		notifying: nil 
		ifFail: [self inform: 'compilation failed'].
	compiled := node generate: #(0 0 0 0).
	original = compiled
		ifFalse: [Transcript nextPut: $-].
	^original = compiled
		
		
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph class >> objectNameFrom: aUserString [
	"answer a camel-cased String beginning with a lowercase character"

	|ans|
	ans := self classNameFrom: aUserString.
	ans at: 1 put: (ans at: 1) asLowercase.
	^ans
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
SyntaxElementMorph class >> test [
	1 even ifTrue:[] ifFalse:[^'yes']
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph class >> testAllMethods [
	"SyntaxElementMorph testAllMethods"

	| eachClass methods original compiled element|
	Smalltalk classNames do: [: className |
		eachClass := Smalltalk classNamed: className.
		methods := eachClass methodDict.
		methods keysDo: [ :eachSelector|
			(self isDecompilable: eachSelector class: eachClass)
				ifTrue: [
					original := methods at: eachSelector.
					element := ((eachClass decompilerClass new)
						decompile: eachSelector 
						in: eachClass 
						method: original) asSyntaxElement.
					compiled := element asCompiledMethodForClass: eachClass.
					original = compiled
						ifTrue: [Transcript show:'.']
						ifFalse: [Transcript cr; 
							show: className asString, ' -> ', 
								eachSelector printString; cr]]]]
		
		
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph class >> testAllOriginalMethods [

	| eachClass methods original compiled text node|
	Smalltalk classNames do: [: className |
		eachClass := Smalltalk classNamed: className.
		methods := eachClass methodDict.
		methods keysDo: [ :eachSelector|
			original := methods at: eachSelector.
			text := ((eachClass decompilerClass new)
				decompile: eachSelector in: eachClass method: original) printString.
			node := Compiler new 
				compile: text 
				in: eachClass 
				notifying: nil 
				ifFail: [self inform: 'compilation failed'].
			compiled := node generate: #(0 0 0 0).
			original = compiled
				ifTrue: [Transcript show:'.']
				ifFalse: [Transcript cr; 
					show: className asString, ' -> ', 
						eachSelector printString; cr]]]
		
		
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> aboutToBeGrabbedBy: aHand [

	(owner isKindOf: ArgumentElementMorph)
		ifTrue: [owner removeContents. ^self ].
	(owner isKindOf: StepElementMorph)
		ifTrue: [owner removeNext. ^self].
	(owner isKindOf: MessageElementMorph)
		ifTrue: [owner removeCascadedElement: self. ^self].
	^ self



]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> asSmalltalk [
	^''
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> borderColorDark [
	^color twiceDarker
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> borderColorLight [
	^color twiceLighter lighter
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> borderColorVeryDark [
	^color twiceDarker darker
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> borderColorVeryLight [
	^color twiceLighter twiceLighter lighter
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> borderWidth [
	^1

]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> changed [
	super changed
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> contextMenu [

	^nil
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> duplicate [
	World activeHand addMorph: super fullCopy
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> evaluate [
	^Compiler evaluate: self asSmalltalk
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> fit [
	self extent: label extent + (self borderWidth * 2).
	self width: (self width + (self labelFont widthOf: $ )).
	label position: bounds center - (label extent // 2).
	(owner respondsTo: #fit)
		ifTrue: [owner fit]

]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> handlesMouseDown: evt [
	"Return true if this morph wants to receive mouseDown events (i.e., mouseDown:, mouseMove:, mouseUp:). The default response is false; subclasses that implement mouse messages should override this to return true." 

	^ true
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> initialize [
	super initialize.
	color := Color red
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> invokeContextMenu [
	|m choice|
	m := self contextMenu.
	m ifNotNil: [
		choice := m startUp.
		choice ifNotNil: [self perform: choice] ]
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> isRenameable [
	| editor |
	editor := (self ownerThatIsA: ElementsMethodEditorMorph).
	^editor isNil
	
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> label [
	^name
	"^label contents"
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> label: aString [

	name := aString.
	label ifNil: [
		label := StringMorph contents: '' font: self labelFont.
		label color: self labelColor.
		self addMorphFront: label].
	label contents: (self wordsFrom: name).
	self fit

]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> labelColor [
	^Color white
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> labelFont [
	^StrikeFont fontName: 'Verdana' size: 10
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> mouseDown: evt [
	"Handle a mouse down event."

	evt rightButtonPressed
		ifTrue: [ ^self invokeContextMenu].
	self startDrag: evt

]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> name [
	^name
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> representsNil [
	^false
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> rootForGrabOf: aMorph [
	"Allow myself to be extracted."

	(owner notNil and: [owner isPartsBin])
		ifTrue: [^ super rootForGrabOf: aMorph]
		ifFalse: [^ self].

]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> showGeneratedSmalltalk [
	"StringHolder new contents: self asSmalltalk; openLabel: self class printString"	
	self inform: self asSmalltalk
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> showResult [
	self inform: self evaluate printString
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> throwAway [
	self aboutToBeGrabbedBy: nil; delete
]

{ #category : #'as yet unclassified' }
SyntaxElementMorph >> wordsFrom: camelCase [
	^self class wordsFrom: camelCase
]
