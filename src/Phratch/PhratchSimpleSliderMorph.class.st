Class {
	#name : #PhratchSimpleSliderMorph,
	#superclass : #Slider,
	#instVars : [
		'target',
		'arguments',
		'minVal',
		'maxVal',
		'truncate'
	],
	#category : #'Phratch-UI-Watchers'
}

{ #category : #scripting }
PhratchSimpleSliderMorph class >> authoringPrototype [
	| aSlider nominalColor |
	"self currentHand attachMorph: SimpleSliderMorph authoringPrototype"

	aSlider := super authoringPrototype beSticky.
	aSlider extent: 14@120.
	nominalColor := Color r: 0.4 g: 0.86 b: 0.7.
	aSlider color: nominalColor.
	aSlider sliderColor: nominalColor muchLighter.
	aSlider descending: true.
	aSlider setScaledValue: 0.3.
	^ aSlider
]

{ #category : #printing }
PhratchSimpleSliderMorph class >> defaultNameStemForInstances [
	"Answer a basis for names of default instances of the receiver"
	^ 'Slider'
]

{ #category : #'parts bin' }
PhratchSimpleSliderMorph class >> descriptionForPartsBin [
	^ self partName:	'Slider'
		categories:		#('Scripting')
		documentation:	'A scriptable control that allows you to choose a numeric value by dragging a knob.'
]

{ #category : #initialization }
PhratchSimpleSliderMorph class >> initialize [

	self registerInFlapsRegistry.	
]

{ #category : #initialization }
PhratchSimpleSliderMorph class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: #(SimpleSliderMorph		authoringPrototype		'Slider'			'A slider for showing and setting numeric values.')
						forFlapNamed: 'PlugIn Supplies'.
						cl registerQuad: #(SimpleSliderMorph		authoringPrototype		'Slider'			'A slider for showing and setting numeric values.')
						forFlapNamed: 'Supplies'.
						cl registerQuad: #(SimpleSliderMorph		authoringPrototype		'Slider'			'A slider for showing and setting numeric values.')
						forFlapNamed: 'Scripting']
]

{ #category : #initialization }
PhratchSimpleSliderMorph class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #accessing }
PhratchSimpleSliderMorph >> actionSelector [

	^ setValueSelector

]

{ #category : #accessing }
PhratchSimpleSliderMorph >> actionSelector: aSymbolOrString [

	(nil = aSymbolOrString or:
	 ['nil' = aSymbolOrString or:
	 [aSymbolOrString isEmpty]])
		ifTrue: [^ setValueSelector := nil].

	setValueSelector := aSymbolOrString asSymbol.

]

{ #category : #menu }
PhratchSimpleSliderMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"To all the other Custom menu items add slider and targeting items."
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	self addSliderMenuItems: aCustomMenu hand: aHandMorph .
	self addTargetingMenuItems: aCustomMenu hand: aHandMorph .
]

{ #category : #menu }
PhratchSimpleSliderMorph >> addSliderMenuItems: aCustomMenu hand: aHandMorph [ 
	"Add items to set slider parameters"
	aCustomMenu addLine.
	""
	aCustomMenu add: 'set action selector' translated selector: #setActionSelector.
	aCustomMenu add: 'change arguments' translated selector: #setArguments.
	""
	aCustomMenu add: 'set minimum value' translated selector: #setMinVal.
	aCustomMenu add: 'set maximum value' translated selector: #setMaxVal.
	""
	aCustomMenu addUpdating: #descendingString selector: #toggleDescending.
	aCustomMenu addUpdating: #truncateString selector: #toggleTruncate.
	
]

{ #category : #menu }
PhratchSimpleSliderMorph >> addTargetingMenuItems: aCustomMenu hand: aHandMorph [ 
	"Add targeting menu items"
	aCustomMenu addLine.

	aCustomMenu add: 'set target' translated selector: #targetWith:.
	aCustomMenu add: 'sight target' translated selector: #sightTargets:.
	target
		ifNotNil: [aCustomMenu add: 'clear target' translated selector: #clearTarget]
]

{ #category : #private }
PhratchSimpleSliderMorph >> adjustToValue: aNumber [
	"Adjust the position of this slider to correspond to the given value in the range minVal..maxVal."
	"Details: Internal values are normalized to the range 0..1."

	self value:
		(aNumber - minVal) asFloat / (maxVal - minVal).

]

{ #category : #accessing }
PhratchSimpleSliderMorph >> arguments [

	^ arguments

]

{ #category : #accessing }
PhratchSimpleSliderMorph >> arguments: aCollection [

	arguments := aCollection asArray copy.

]

{ #category : #menu }
PhratchSimpleSliderMorph >> clearTarget [

	target := nil.

]

{ #category : #menu }
PhratchSimpleSliderMorph >> descendingString [
	^ (self descending
		ifTrue: ['switch to ascending']
		ifFalse: ['switch to descending']) translated
]

{ #category : #private }
PhratchSimpleSliderMorph >> getScaledValue [
	| aValue |
	aValue := (value * (maxVal - minVal)) + minVal.
	^ truncate ifTrue: [aValue truncated] ifFalse: [aValue]
]

{ #category : #initialization }
PhratchSimpleSliderMorph >> initialize [

	super initialize.
	target := nil.
	arguments := EmptyArray.
	minVal := 0.0.
	maxVal := 1.0.
	truncate := false.

]

{ #category : #'parts bin' }
PhratchSimpleSliderMorph >> initializeToStandAlone [
	| nominalColor |

	self initialize.
	self beSticky.
	self extent: 14@120.
	nominalColor := Color r: 0.452 g: 0.645 b: 0.935.
	self color: nominalColor.
	self borderColor: Color veryDarkGray.
	self sliderColor: nominalColor muchLighter.
	self descending: true.
	self setScaledValue: 0.3
]

{ #category : #'e-toy support' }
PhratchSimpleSliderMorph >> isLikelyRecipientForMouseOverHalos [

	^ true.

]

{ #category : #accessing }
PhratchSimpleSliderMorph >> maxVal [

	^ maxVal

]

{ #category : #accessing }
PhratchSimpleSliderMorph >> maxVal: aNumber [

	maxVal := aNumber.

]

{ #category : #accessing }
PhratchSimpleSliderMorph >> minVal [

	^ minVal

]

{ #category : #accessing }
PhratchSimpleSliderMorph >> minVal: aNumber [

	minVal := aNumber.

]

{ #category : #menu }
PhratchSimpleSliderMorph >> setActionSelector [
	| oldSel newSel |
	oldSel := setValueSelector isNil ifTrue: [''] ifFalse: [setValueSelector].
	newSel := UIManager default 
				request: 'Please type the selector to be sent to
the target when this slider is changed' translated
				initialAnswer: oldSel.
	newSel isEmptyOrNil ifFalse: [self actionSelector: newSel]
]

{ #category : #menu }
PhratchSimpleSliderMorph >> setArguments [

	| s newArgs newArgsArray |
	s := WriteStream on: ''.
	arguments do: [:arg | arg printOn: s. s nextPutAll: '. '].
	newArgs := UIManager default
		request:
'Please type the arguments to be sent to the target
when this button is pressed separated by periods' translated
		initialAnswer: s contents.
	newArgs isEmptyOrNil ifFalse: [
		newArgsArray := Compiler evaluate: '{', newArgs, '}' for: self logged: false.
		self arguments: newArgsArray].

]

{ #category : #menu }
PhratchSimpleSliderMorph >> setLabel [

	| newLabel |
	newLabel := UIManager default
		request:
'Please a new label for this button' translated
		initialAnswer: self label.
	newLabel isEmptyOrNil ifFalse: [self label: newLabel].

]

{ #category : #menu }
PhratchSimpleSliderMorph >> setMaxVal [

	| newMaxVal |
	newMaxVal := UIManager default
		request: 'Maximum value?' translated
		initialAnswer: maxVal printString.
	newMaxVal isEmptyOrNil ifFalse: [
		maxVal := newMaxVal asNumber.
		minVal := minVal min: maxVal].

]

{ #category : #private }
PhratchSimpleSliderMorph >> setMaxVal: newMaxVal [
	maxVal := newMaxVal asNumber.
	minVal := maxVal min: minVal

]

{ #category : #menu }
PhratchSimpleSliderMorph >> setMinVal [

	| newMinVal |
	newMinVal := UIManager default
		request: 'Minimum value?' translated
		initialAnswer: minVal printString.
	newMinVal isEmptyOrNil ifFalse: [
		minVal := newMinVal asNumber.
		maxVal := maxVal max: minVal].

]

{ #category : #menu }
PhratchSimpleSliderMorph >> setMinVal: newMinVal [
	minVal := newMinVal asNumber.
	maxVal := maxVal max: minVal

]

{ #category : #private }
PhratchSimpleSliderMorph >> setScaledValue: aNumber [
	| denom |
	(denom := maxVal - minVal) > 0
		ifTrue:
			[self setValue: (aNumber - minVal) / denom]
		ifFalse:
			[self setValue: maxVal]
	"If minVal = maxVal, that value is the only one this (rather unuseful!) slider can bear"
]

{ #category : #menu }
PhratchSimpleSliderMorph >> setTarget: evt [ 
	| rootMorphs |
	rootMorphs := self world rootMorphsAt: evt hand targetOffset.
	target := rootMorphs size > 1
				ifTrue: [rootMorphs second]
]

{ #category : #'model access' }
PhratchSimpleSliderMorph >> setValue: newValue [ 
	"Update the target with this sliders new value."

	| scaledValue |
	self value: newValue.
	scaledValue := newValue * (maxVal - minVal) + minVal.
	truncate ifTrue: [scaledValue := scaledValue truncated].
	(target notNil and: [setValueSelector notNil]) 
		ifTrue: 
			[Cursor normal showWhile: 
					[target perform: setValueSelector
						withArguments: (arguments copyWith: scaledValue)]]
]

{ #category : #accessing }
PhratchSimpleSliderMorph >> target [

	^ target

]

{ #category : #accessing }
PhratchSimpleSliderMorph >> target: anObject [

	target := anObject

]

{ #category : #menu }
PhratchSimpleSliderMorph >> toggleDescending [

	descending := self descending not

]

{ #category : #menu }
PhratchSimpleSliderMorph >> toggleTruncate [

	truncate := truncate not.

]

{ #category : #private }
PhratchSimpleSliderMorph >> truncate [
	^ truncate
]

{ #category : #private }
PhratchSimpleSliderMorph >> truncate: aBoolean [
	truncate := aBoolean
]

{ #category : #menu }
PhratchSimpleSliderMorph >> truncateString [
	^ (truncate
		ifTrue: ['turn off truncation']
		ifFalse: ['turn on truncation'])  translated
]

{ #category : #copying }
PhratchSimpleSliderMorph >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
target := deepCopier references at: target ifAbsent: [target].
arguments := arguments collect: [:each |
	deepCopier references at: each ifAbsent: [each]].

]

{ #category : #copying }
PhratchSimpleSliderMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
"target := target.		Weakly copied"
"arguments := arguments.		All weakly copied"
minVal := minVal veryDeepCopyWith: deepCopier.		"will be fast if integer"
maxVal := maxVal veryDeepCopyWith: deepCopier.
truncate := truncate veryDeepCopyWith: deepCopier.

]
