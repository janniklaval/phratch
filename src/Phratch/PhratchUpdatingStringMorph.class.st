"
A StringMorph that constantly tries to show the current data from the target object.  When sent #step, it shows what the target objects has (target perform: getSelector).  When edited (with shift-click), it writes back to the target.

floatPrecision = 1. to round to integer.
floatPrecision = .1 to round to 1 decimal place, etc.

Even when ((target isNil) or: [getSelector == nil]), the user would still like to edit the string with shift-click.
"
Class {
	#name : #PhratchUpdatingStringMorph,
	#superclass : #StringMorph,
	#instVars : [
		'format',
		'target',
		'lastValue',
		'getSelector',
		'putSelector',
		'floatPrecision',
		'growable',
		'stepTime',
		'autoAcceptOnFocusLoss',
		'minimumWidth',
		'maximumWidth',
		'isUpdating',
		'isUpdating',
		'isUpdating'
	],
	#pools : [
		'TextConstants'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'instance creation' }
PhratchUpdatingStringMorph class >> on: targetObject selector: aSymbol [

	^ self new
		getSelector: aSymbol;
		target: targetObject


]

{ #category : #editing }
PhratchUpdatingStringMorph >> acceptContents [

	self informTarget.

]

{ #category : #'target access' }
PhratchUpdatingStringMorph >> acceptValueFromTarget: v [
	"Accept a value from the target"

	lastValue := v.
	self format == #string ifTrue: [^ v asString].
	self format == #symbol ifTrue: [^ v asString translated].
	(format == #default and: [v isNumber]) ifTrue:
		[^ self stringForNumericValue: v].
	^ v printString translated
]

{ #category : #editing }
PhratchUpdatingStringMorph >> addCustomMenuItems: menu hand: aHandMorph [ 
	| prefix |
	super addCustomMenuItems: menu hand: aHandMorph.
	prefix := (self growable
				ifTrue: ['stop being growable']
				ifFalse: ['start being growable']) translated.
	menu add: prefix action: #toggleGrowability.
	menu add: 'decimal places...' translated action: #setPrecision.
	menu add: 'font size...' translated action: #setFontSize.
	menu add: 'font style...' translated action: #setFontStyle
]

{ #category : #accessing }
PhratchUpdatingStringMorph >> autoAcceptOnFocusLoss [
	^ autoAcceptOnFocusLoss ~~ false
]

{ #category : #'target access' }
PhratchUpdatingStringMorph >> checkTarget [
	getSelector ifNil: [^ true].
	^ getSelector numArgs = 0.

]

{ #category : #accessing }
PhratchUpdatingStringMorph >> contents: newContents [ 
	"This is the original StringMorph implementation of #contents:, restored down in UpdatingStringMorph because a recent 'optimization' of the StringMorph version of this method broke UpdatingStringMorphs."

	contents := newContents isText 
				ifTrue:  
					[emphasis := newContents emphasisAt: 1.
					newContents string]
				ifFalse: 
					[contents = newContents ifTrue: [^self].	"no substantive change"
					newContents].
	self fitContents.
	self changed
]

{ #category : #accessing }
PhratchUpdatingStringMorph >> decimalPlaces [
	"Answer the number of decimal places to show."

	| places |
	(places := self valueOfProperty: #decimalPlaces) ifNotNil: [^ places].
	self 
		setProperty: #decimalPlaces 
		toValue: (places := self decimalPlacesForFloatPrecision: self floatPrecision).
	^ places
]

{ #category : #accessing }
PhratchUpdatingStringMorph >> decimalPlaces: aNumber [ 
	"Set the receiver's number of decimal places to be shown. If my
	target is a morph or a player, tell it about the change, in case it wants
	to remember it."
	| constrained |
	self setProperty: #decimalPlaces toValue: (constrained := aNumber min: 11).
	floatPrecision := self floatPrecisionForDecimalPlaces: constrained
]

{ #category : #private }
PhratchUpdatingStringMorph >> decimalPlacesForFloatPrecision: precision [
	"Answer the number of decimal places that correspond to the given floatPrecision"

	^ (#(1 0.1 0.01 0.001 0.0001 0.00001 0.000001 0.0000001 0.00000001 0.000000001) indexOf: precision ifAbsent: [ ^precision log negated floor ]) - 1

"
#(1 0.1 0.01 0.001 0.0001 0.00001 0.000001 0.0000001 0.00000001 0.000000001) collect: [:prec | Utilities decimalPlacesForFloatPrecision: prec]
"
]

{ #category : #editing }
PhratchUpdatingStringMorph >> doneWithEdits [
	"If in a SyntaxMorph, shrink min width after editing"

	| editor |
	super doneWithEdits.
	(owner respondsTo: #parseNode) ifTrue: [minimumWidth := 8].
	editor := (submorphs detect: [ :sm | sm isKindOf: StringMorphEditor ] ifNone: [ ^self ]).
	editor delete.
]

{ #category : #accessing }
PhratchUpdatingStringMorph >> fitContents [
	| newExtent f |
	f := self fontToUse.
	newExtent := (((f widthOfString: contents) max: self minimumWidth) min: self maximumWidth) @ f height.
	self extent = newExtent
		ifTrue: [ ^ self ].
	self extent: newExtent.
	self changed
]

{ #category : #accessing }
PhratchUpdatingStringMorph >> floatPrecision [
	"Answer the floatPrecision to use:
		1.0 ->	show whole number
		0.1	->	show one digit of precision
		.01 ->	show two digits of precision
		etc.
	Initialize the floatPrecision to 1 if it is not already defined"

	^ floatPrecision ifNil: [floatPrecision := 1.0]

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> floatPrecision: aNumber [
	"to be migrated to Morphic"
	floatPrecision := aNumber
]

{ #category : #private }
PhratchUpdatingStringMorph >> floatPrecisionForDecimalPlaces: places [
	"Answer the floatPrecision that corresponds to the given number of decimal places"

	^ places caseOf:
			{[0]->[1] .
			[1]->[0.1] . 
			[2]->[0.01] .
			[3]->[0.001] .
			[4]->[0.0001] .
			[5]->[0.00001] .
			[6]->[0.000001] .
			[7]->[0.0000001] .
			[8]->[0.00000001] .
			[9]->[0.000000001]}
		otherwise:
			[(10.0 raisedTo: places negated) asFloat]

"
(0 to: 6) collect: [:i | Utilities floatPrecisionForDecimalPlaces: i]
(-10 to: 20) collect: [:i | Utilities floatPrecisionForDecimalPlaces: i]
"
]

{ #category : #accessing }
PhratchUpdatingStringMorph >> format [
	"Answer the receiver's format: #default or #string"

	^ format ifNil: [format := #default]
]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> formatValue: v [

	format = #string ifTrue: [
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

	(v isBoolean) ifTrue: [^ v printString localized].
	(v isString) ifTrue: [^ v].

	^ v printString

]

{ #category : #accessing }
PhratchUpdatingStringMorph >> getSelector [

	^ getSelector

]

{ #category : #accessing }
PhratchUpdatingStringMorph >> getSelector: aSymbol [

	getSelector := aSymbol.

]

{ #category : #accessing }
PhratchUpdatingStringMorph >> growable [

	^ growable ~~ false

]

{ #category : #accessing }
PhratchUpdatingStringMorph >> growable: aBoolean [

	growable := aBoolean.

]

{ #category : #'events-processing' }
PhratchUpdatingStringMorph >> handlerForMouseDown: evt [
	"Answer an object to field the mouseDown event provided, or nil if none"

	| aHandler |
	aHandler := super handlerForMouseDown: evt.
	aHandler == self ifTrue:	[^ self]. "I would get it anyways"
	"Note: This is a hack to allow value editing in viewers"
	((owner wantsKeyboardFocusFor: self) and:
		[self userEditsAllowed]) ifTrue: [^ self].
	^ aHandler
]

{ #category : #'event handling' }
PhratchUpdatingStringMorph >> handlesMouseDown: evt [
	(owner wantsKeyboardFocusFor: self)
		ifTrue:[^true].
	^ super handlesMouseDown: evt
]

{ #category : #'target access' }
PhratchUpdatingStringMorph >> informTarget [
	"Obtain a value from my contents, and tell my target about it.  The putSelector can take one argument (traditional) or two (as used by Croquet)"

	| newValue typeIn |
	(target notNil and: [ putSelector notNil ])
		ifFalse: [ ^ self ].
	typeIn := contents.
	(newValue := self valueFromContents)
		ifNotNil: [ 
			self checkTarget.
			putSelector numArgs = 1
				ifTrue: [ target perform: putSelector with: newValue ].
			putSelector numArgs = 2
				ifTrue: [ target perform: putSelector with: newValue with: self ].
			target isMorph
				ifTrue: [ target changed ] ].
	self fitContents.
	(format == #default and: [ newValue isNumber ])
		ifTrue: [ self setDecimalPlacesFromTypeIn: typeIn ]
]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> initialize [
	"Initialie the receiver to have default values in its instance variables "
	super initialize.

	format := #default.
	"formats: #string, #default"
	target := getSelector := putSelector := nil.
	floatPrecision := 1.
	growable := true.
	stepTime := 50.
	autoAcceptOnFocusLoss := true.
	minimumWidth := 8.
	maximumWidth := 300.
	isUpdating:= false.
]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> kern: ignored [
]

{ #category : #editing }
PhratchUpdatingStringMorph >> lostFocusWithoutAccepting [
	"The message is sent when the user, having been in an editing episode on the receiver, changes the keyboard focus -- typically by clicking on some editable text somewhere else -- without having accepted the current edits."

	self autoAcceptOnFocusLoss ifTrue: [self doneWithEdits; acceptContents]
]

{ #category : #accessing }
PhratchUpdatingStringMorph >> maximumWidth [
	"Answer the maximum width that the receiver can have.   A nil value means no maximum, and for practical purposes results in a value of 99999 here temporarily, for help in future debugging"

	^ maximumWidth ifNil: [99999]
]

{ #category : #accessing }
PhratchUpdatingStringMorph >> minimumWidth [
	"Answer the minimum width that the receiver can have.  A nonzero value here keeps the receiver from degenerating into something that cannot ever be seen or touched again!  Obeyed by fitContents."

	^ minimumWidth ifNil: [minimumWidth := 8]
]

{ #category : #'event handling' }
PhratchUpdatingStringMorph >> mouseDown: evt [
	"The mouse went down over the receiver.  If appropriate, launch a mini-editor so that the user can commence text-editing here"

	(owner wantsKeyboardFocusFor: self) ifTrue:
		[self userEditsAllowed ifTrue:
			[(owner respondsTo: #parseNode)
					ifTrue: 	"leave space for editing"
						[minimumWidth := (49 max: minimumWidth)].
			self launchMiniEditor: evt]]
]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> parameter [

	^ self valueOfProperty: #scratchParameter
]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> parameter: anObject [

	self setProperty: #scratchParameter toValue: anObject
]

{ #category : #accessing }
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

{ #category : #editing }
PhratchUpdatingStringMorph >> setDecimalPlaces: places [
	"Set the number of decimal places, and update the display."

	self decimalPlaces: places.
	self acceptValueFromTarget: lastValue
]

{ #category : #'target access' }
PhratchUpdatingStringMorph >> setDecimalPlacesFromTypeIn: typeIn [
	"The user has typed in a number as the new value of the receiver.  Glean off decimal-places-preference from the type-in"

	| decimalPointPosition tail places |
	(typeIn includes: $e) ifTrue: [^ self].
	decimalPointPosition := typeIn indexOf: $. ifAbsent: [nil].
	places := 0.
	decimalPointPosition
		ifNotNil:
			[tail := typeIn copyFrom: decimalPointPosition + 1 to: typeIn size.
			[places < tail size and: [(tail at: (places + 1)) isDigit]]
				whileTrue:
					[places := places + 1]].
		
	self decimalPlaces: places
]

{ #category : #editing }
PhratchUpdatingStringMorph >> setFontSize [
	| sizes reply family |
	family := font 
				ifNil: [TextStyle default]
				ifNotNil: [font textStyle].
	family
		ifNil: [family := TextStyle default].
	"safety net -- this line SHOULD be unnecessary now "
	sizes := family fontNamesWithPointSizes.
	reply := UIManager default chooseFrom: sizes values: sizes.
	reply
		ifNotNil: [self
				font: (family
						fontAt: (sizes indexOf: reply))]
]

{ #category : #editing }
PhratchUpdatingStringMorph >> setFontStyle [
	| aList reply style |
	aList := (TextSharedInformation select: [:anItem | anItem isKindOf: TextStyle]) 
				keys asOrderedCollection.
	reply := UIManager default chooseFrom: aList values: aList.
	reply ifNotNil: 
			[(style := TextStyle named: reply) ifNil: 
					[Beeper beep.
					^true].
			self font: style defaultFont]
]

{ #category : #editing }
PhratchUpdatingStringMorph >> setPrecision [
	"Allow the user to specify a number of decimal places. This UI is
	invoked from a menu. Nowadays the precision can be set by simple
	type-in, making this menu approach mostly obsolete. However, it's
	still useful for read-only readouts, where type-in is not allowed."
	| aMenu |
	aMenu := UIManager default 
				 newMenuIn: self for: self.
	aMenu
		addTitle: ('How many decimal places? (currently {1})' translated format: {self decimalPlaces}).
	0
		to: 5 
		do: [:places | aMenu
				add: places asString
				target: self
				selector: #setDecimalPlaces:
				argument: places].
	aMenu popUpInWorld
]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> step [

	super step.
	hasFocus ifFalse:
		[
		isUpdating ifFalse:[
				[isUpdating := true.
				self updateContentsFrom: self readFromTarget.
				isUpdating := false] fork.
			]
		]
	

]

{ #category : #testing }
PhratchUpdatingStringMorph >> stepTime [

	^ stepTime ifNil: [50]

]

{ #category : #stepping }
PhratchUpdatingStringMorph >> stepTime: mSecsPerStep [

	stepTime := mSecsPerStep truncated.

]

{ #category : #'target access' }
PhratchUpdatingStringMorph >> stringForNumericValue: aValue [
	"Answer a suitably-formatted string representing the value."

	| barePrintString |
	((barePrintString := aValue printString) includes: $e)  ifTrue: [^ barePrintString].
	^ aValue printShowingDecimalPlaces: self decimalPlaces
]

{ #category : #accessing }
PhratchUpdatingStringMorph >> target [

	^ target

]

{ #category : #accessing }
PhratchUpdatingStringMorph >> target: anObject [
	target := anObject.

]

{ #category : #editing }
PhratchUpdatingStringMorph >> toggleGrowability [
	growable := self growable not.
	self updateContentsFrom: self readFromTarget.
	growable ifTrue: [self fitContents]
]

{ #category : #stepping }
PhratchUpdatingStringMorph >> updateContentsFrom: aValue [
	self growable
		ifTrue:
			[self contents: aValue]
		ifFalse:
			[self contentsClipped: aValue]
]

{ #category : #formats }
PhratchUpdatingStringMorph >> useStringFormat [

	format := #string.
]

{ #category : #editing }
PhratchUpdatingStringMorph >> userEditsAllowed [
	"Answer whether user-edits are allowed to this field"

	^ putSelector notNil or: [self hasProperty: #okToTextEdit]
]

{ #category : #accessing }
PhratchUpdatingStringMorph >> valueFromContents [
	"Return a new value from the current contents string."

	format = #symbol ifTrue: [^ lastValue].
	format = #string ifTrue: [^ contents].
	^ self class evaluatorClass evaluate: contents

]

{ #category : #'as yet unclassified' }
PhratchUpdatingStringMorph >> valueFromTargetOrNil [
	"Answer the value read from my target. Answer nil if my target or selector is nil.."

	| result |
	(target isNil or: [ getSelector isNil ])
		ifTrue: [ ^ nil ].
	result := nil.
	[ 
	result := self parameter
		ifNil: [ target perform: getSelector ]
		ifNotNil: [ target perform: getSelector with: self parameter ]] ifError: [PhratchError error  ].
	^ result
]

{ #category : #copying }
PhratchUpdatingStringMorph >> veryDeepFixupWith: deepCopier [
	"If target field is weakly copied, fix it here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
target := deepCopier references at: target ifAbsent: [target].

]

{ #category : #copying }
PhratchUpdatingStringMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared."

	super veryDeepInner: deepCopier.
	format := format veryDeepCopyWith: deepCopier.
	target := target.					"Weakly copied"
	lastValue := lastValue veryDeepCopyWith: deepCopier.
	getSelector := getSelector.			"Symbol"
	putSelector := putSelector.		"Symbol"
	floatPrecision := floatPrecision veryDeepCopyWith: deepCopier.
	growable := growable veryDeepCopyWith: deepCopier.
	stepTime := stepTime veryDeepCopyWith: deepCopier.
	autoAcceptOnFocusLoss := autoAcceptOnFocusLoss veryDeepCopyWith: deepCopier.
	minimumWidth := minimumWidth veryDeepCopyWith: deepCopier.
	maximumWidth := maximumWidth veryDeepCopyWith: deepCopier.

]

{ #category : #'event handling' }
PhratchUpdatingStringMorph >> wouldAcceptKeyboardFocus [
	^ (self hasProperty: #okToTextEdit) or: [super wouldAcceptKeyboardFocus]
]
