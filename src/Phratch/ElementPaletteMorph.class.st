Class {
	#name : #ElementPaletteMorph,
	#superclass : #Morph,
	#instVars : [
		'elements',
		'variables'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'as yet unclassified' }
ElementPaletteMorph class >> basics [
	^self new
		addElement: StepElementMorph new;
		addElement: ReturnElementMorph new;
		addElement: PrimitiveElementMorph new;
		addElement: BlockElementMorph new;
		addElement: (ObjectElementMorph new label: 'self');
		addElement: (ObjectElementMorph new label: 'super');
		addElement: (ObjectElementMorph new label: 'true');
		addElement: (ObjectElementMorph new label: 'false');
"		addElement: (ObjectElementMorph new label: 'thisContext');"
		addElement: (LiteralElementMorph new);
"		addElement: (MessageElementMorph new selector: #new);"
		addElement: MessageElementMorph new assign;
		addElement: MessageElementMorph new yesNo

]

{ #category : #'as yet unclassified' }
ElementPaletteMorph class >> classVarsFor: aClass [
	| pal |
	pal := self new.
	aClass classVarNames asSortedCollection do: [:vname|
		pal addElement: (ObjectElementMorph new label: vname asString) ].

	pal addElement: ((StringMorph contents: ' inherited:' font: self labelFont) color: self labelColor).

	(aClass allClassVarNames reject: [:iv | aClass classVarNames includes: iv]) asSortedCollection do: [:vname|
		pal addElement: (ObjectElementMorph new label: vname asString) ].

	^pal

]

{ #category : #'as yet unclassified' }
ElementPaletteMorph class >> classes [
	| pal |
	pal := self new.
	Smalltalk classNames asSortedCollection do: [:class|
		pal addElement: (ObjectElementMorph new label: class asString) ].
	^pal

]

{ #category : #'as yet unclassified' }
ElementPaletteMorph class >> currentPackageClasses: aClass [
	| pal packages pkg |
	pkg := ((SystemOrganization categoryOfElement: aClass name asSymbol) asString findTokens: #( $- )) first.
	packages := self packageClassesDict.
	pal := self new.
	(packages at: pkg) asSortedCollection do: [:class|
		pal addElement: (ObjectElementMorph new label: class asString) ].
	^pal

]

{ #category : #'as yet unclassified' }
ElementPaletteMorph class >> globals [
	| pal |
	pal := self new.
	(Smalltalk keys reject: [:key| Smalltalk classNames includes: key]) asSortedCollection do: [:global|
		pal addElement: (ObjectElementMorph new label: global asString) ].
	^pal

]

{ #category : #'as yet unclassified' }
ElementPaletteMorph class >> instVarsFor: aClass [
	| pal |
	pal := self new.
	aClass instVarNames asSortedCollection do: [:vname|
		pal addElement: (ObjectElementMorph new label: vname asString) ].

	pal addElement: ((StringMorph contents: ' inherited:' font: self labelFont) color: self labelColor).

	(aClass allInstVarNames reject: [:iv | aClass instVarNames includes: iv]) asSortedCollection do: [:vname|
		pal addElement: (ObjectElementMorph new label: vname asString) ].

	^pal

]

{ #category : #'as yet unclassified' }
ElementPaletteMorph class >> labelColor [
	^Color darkGray twiceDarker
]

{ #category : #'as yet unclassified' }
ElementPaletteMorph class >> labelFont [
	^StrikeFont fontName: 'Verdana' size: 9
]

{ #category : #'as yet unclassified' }
ElementPaletteMorph class >> messagesFor: aClass [
	
	| pal me |
	pal := self new.
	pal addElement: ((StringMorph contents: (SyntaxElementMorph wordsFrom: aClass name asString) font: self labelFont) color: self labelColor).
	aClass selectors asSortedCollection do: [:selector|
		me := MessageElementMorph new selector: selector.
		((selector asString includes: ($:)) not and: [
			(aClass lookupSelector: selector) numArgs > 0])
				ifTrue: [me beBinary].
		pal addElement: me ].

	pal addElement: ((StringMorph contents: ' inherited:' font: self labelFont) color: self labelColor).

	(aClass allSelectors reject:[:sel| aClass selectors includes: sel ]) asSortedCollection do: [:selector|
		me := MessageElementMorph new selector: selector.
		((selector asString includes: ($:)) not and: [
			(aClass lookupSelector: selector) numArgs > 0])
				ifTrue: [me beBinary].
		pal addElement: me ].


	^pal

]

{ #category : #'as yet unclassified' }
ElementPaletteMorph class >> messagesForSelf: aClass [
	
	| pal me|
	pal := self new.
	aClass allSelectors asSortedCollection do: [:selector|
		me := MessageElementMorph new selector: selector.
		((selector asString includes: ($:)) not and: [
			(aClass lookupSelector: selector) numArgs > 0])
				ifTrue: [me beBinary].
		me receiver: (ObjectElementMorph new label: 'self').
		pal addElement: me ].
	^pal

]

{ #category : #'as yet unclassified' }
ElementPaletteMorph class >> packageClassesDict [
	| packages pkg ans |
	packages := Dictionary new.
	ans := Dictionary new.
	SystemOrganization categories asSortedCollection do: [:cat |
		pkg := (cat asString findTokens: #( $- )) first.
		(packages includesKey: pkg) ifFalse: [
				packages at: pkg put: OrderedCollection new.
				ans at: pkg put: OrderedCollection new].
		(packages at: pkg) add: cat].

	packages keys do: [:eachPkg |
		(packages at: eachPkg) do: [: cat |
			(ans at: eachPkg) addAll:  (SystemOrganization listAtCategoryNamed: cat) ]].
	^ans
]

{ #category : #'as yet unclassified' }
ElementPaletteMorph >> addElement: anElement [
	|maxWidth|
	self addMorph: anElement.
	elements isEmpty
		ifTrue:[ anElement position: self position + (2@2)]
		ifFalse: [ anElement position: self position + (2@(elements last bottom + 2)) ].
	elements add: anElement.
	self height: (elements last bottom + 2) - (self top).
	maxWidth := elements last width + 4.
	elements do: [:element|
		maxWidth := (element width + 4) max: maxWidth ].
	self width: maxWidth
]

{ #category : #'as yet unclassified' }
ElementPaletteMorph >> initialize [
	super initialize.
	elements := OrderedCollection new.
	color := Color gray.
]

{ #category : #'as yet unclassified' }
ElementPaletteMorph >> isPartsBin [

	^ true

]

{ #category : #'as yet unclassified' }
ElementPaletteMorph >> rootForGrabOf: aMorph [
	"I act like a parts bin; answer a new copy of the morph being extracted."

	| v |

	v := aMorph ownerThatIsA: SyntaxElementMorph.
	v ifNotNil: [
		(v isKindOf: ArgumentElementMorph)
			ifTrue: [^v owner fullCopy].
		^v fullCopy].

	^nil
]
