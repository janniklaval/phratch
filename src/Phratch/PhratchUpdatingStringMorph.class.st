Class {
	#name : #PhratchUpdatingStringMorph,
	#superclass : #PhratchStringMorph,
	#instVars : [
		'format',
		'target',
		'lastValue',
		'getSelector',
		'putSelector',
		'parameter',
		'floatPrecision',
		'growable',
		'stepTime'
	],
	#category : #'Phratch-Compatibility'
}

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph class >> on: targetObject selector: aSymbol [

	^ self new
		getSelector: aSymbol;
		target: targetObject

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> acceptContents [

	| newValue |
	((target ~~ nil) and: [putSelector ~~ nil]) ifTrue: [
		"compute the new value"
		format = #string
			ifTrue: [newValue := contents]
			ifFalse: [newValue := contents asNumberNoError].

		newValue ifNotNil: [
			parameter
				ifNil: [target perform: putSelector with: newValue]
				ifNotNil: [target perform: putSelector with: parameter with: newValue].
			target isMorph ifTrue: [target changed]].

		self fitContents].

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> addCustomMenuItems: menu hand: aHandMorph [

	| prefix |
	super addCustomMenuItems: menu hand: aHandMorph.
	prefix := growable ifTrue: ['stop'] ifFalse: ['start'].
	menu add: prefix, ' being growable' action: #toggleGrowability.
	menu add: 'decimal places...' action: #setPrecision.
	menu add: 'font size...' action: #setFontSize.
	menu add: 'font style...' action: #setFontStyle.

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> fieldsVersion [

	^ 1

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> fitContents [

	|  newExtent |
	newExtent := (font 
		ifNil: [self stringExtent: contents] 
		ifNotNil: [PhratchTranslator stringExtent: contents font: font]) max: 5@0.
	self extent = newExtent ifFalse: [
		self extent: newExtent.
		self changed.
		(self ownerOrYourselfThatIsA: EventHatMorph) ifNotNil:[
			(self ownerOrYourselfThatIsA: EventHatMorph) forceLayout]].

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> floatPrecision [

	^ floatPrecision

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> floatPrecision: aNumber [

	floatPrecision := aNumber.

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> formatValue: v [

	format = #string ifTrue: [
		v isUnicode ifTrue: [^ v].
		^ v asString].

	(format = #default and: [v isNumber]) ifTrue: [
		v isInteger
			ifTrue: [
				v digitLength > 25 ifTrue: [
					v digitLength < 128
						ifTrue: [^ self formatValue: v asFloat]  "use exponential notation"
						ifFalse: [^ v > 0 ifTrue: ['Infinity'] ifFalse: ['-Infinity']]].
				^ v printString]
			ifFalse: [
				v isInf ifTrue: [
					^ v > 0 ifTrue: ['Infinity'] ifFalse: ['-Infinity']].
				v isNaN ifTrue: [^ 'Error!'].
				^ (v asFloat roundTo: floatPrecision) printString]].

	(v isKindOf: Boolean) ifTrue: [^ v printString localized].
	(v isKindOf: String) ifTrue: [^ v].

	^ v printString

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> getSelector [

	^ getSelector

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> getSelector: aSymbol [

	getSelector := aSymbol.

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> growable [

	^ growable

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> growable: aBoolean [

	growable := aBoolean.

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> handlesMouseDown: evt [

	putSelector ifNil: [^ false].

	(owner wantsKeyboardFocusFor: self)
		ifTrue: [^ self uncoveredAt: evt cursorPoint].
	^ super handlesMouseDown: evt

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		format
		target
		getSelector
		putSelector
		parameter
		floatPrecision
		growable
		stepTime
	) from: anObjStream.

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> initialize [

	super initialize.
	format := #default.  "formats: #string, #default"
	target := getSelector := lastValue := putSelector := parameter := nil.
	floatPrecision := 1.
	growable := true.
	stepTime := 50.

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> lostFocusWithoutAccepting [
	"The message is sent when the user, having been in an editing episode on the receiver, changes the keyboard focus without having accepted the current edits. In This case, we just accept the edits."

	self acceptContents.

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> mouseDown: evt [
	(owner wantsKeyboardFocusFor: self) ifTrue:
		[putSelector ifNotNil: [self launchMiniEditor: evt]]
]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> parameter [

	^ parameter

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> parameter: anObject [
	"Set a parameter (e.g., an array index) to be sent with both my get selector and my put selector. The default is nil, which means no parameter is used."

	parameter := anObject.

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> putSelector [

	^ putSelector

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> putSelector: aSymbol [

	putSelector := aSymbol.

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> readFromTarget [
	"Answer the formatted string for the value read from my target. If the target or selector are nil, or if the value is the same as the last value read, answer my current contents."

	| v |
	(v := self valueFromTargetOrNil) ifNil: [^ contents].
	lastValue = v ifTrue: [^ contents].
	lastValue := v.
	^ self formatValue: v

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> step [
	| s |
	super step.
	hasFocus ifFalse:
		["update contents, but only if user isn't editing this string"
		s := self readFromTarget.
		s = contents ifFalse:
			[self updateContentsFrom: s]]

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> stepTime [

	^ stepTime ifNil: [50]

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> stepTime: mSecsPerStep [

	stepTime := mSecsPerStep truncated.

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		format
		target
		getSelector
		putSelector
		parameter
		floatPrecision
		growable
		stepTime
	) on: anObjStream.

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> target [

	^ target

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> target: anObject [

	target := anObject.
	lastValue := nil.

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> toggleGrowability [

	growable := growable not.
	self updateContentsFrom: self readFromTarget.
	growable ifTrue: [self fitContents].

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> updateContentsFrom: aValue [

	growable
		ifTrue: [self contents: aValue]
		ifFalse: [self contentsClipped: aValue].

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> useDefaultFormat [
	"Use the object's own printString format."

	format := #default.

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> useStringFormat [

	format := #string.
]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> valueFromTargetOrNil [
	"Answer the value read from my target. Answer nil if my target or selector is nil.."

	| result |
	((target == nil) or: [getSelector == nil]) ifTrue: [^ nil].
	result := nil.
	[result := parameter
		ifNil: [target perform: getSelector]
		ifNotNil: [target perform: getSelector with: parameter]
	] ifError: [].
	^ result

]
