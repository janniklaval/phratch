"
I am a button with several forms. Clicking on me toggles which form is shown and sends my target a message. If my isMomentary flag is true, then I return to my off state after I am pressed (i.e. when the mouse goes up).

I can also show a different form on mouse-over.

Finally, if I am disabled I can show a disabled form.


"
Class {
	#name : #ToggleButton,
	#superclass : #SimpleButtonMorph,
	#instVars : [
		'onForm',
		'offForm',
		'overForm',
		'disabledForm',
		'isMomentary',
		'toggleMode',
		'isOn',
		'isDisabled',
		'isOver',
		'wasOn',
		'alphaOn'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'instance creation' }
ToggleButton class >> buttonHue: hue [
	"Answer a new ToggleButton that looks like an LED indicator light of the given hue."

	| d onF offF w bezelF |
	w := 2.
	bezelF := ImageMorph bezelDiameter: 14 width: 2 baseColor: Color gray inset: true.
	d := bezelF width - (2 * w).
	onF := bezelF deepCopy.
	(ImageMorph glowDiameter: d color: (Color h: hue s: 0.4 v: 1) on: true)
		displayOn: onF at: w@w rule: Form paint.
	offF := bezelF deepCopy.
	(ImageMorph glowDiameter: d color: (Color h: hue s: 0.4 v: 1) on: false)
		displayOn: offF at: w@w rule: Form paint.
	^ ToggleButton onForm: onF offForm: offF

]

{ #category : #'instance creation' }
ToggleButton class >> onForm: f1 offForm: f2 [
	"Set the forms used for my on and off states."

	^ self new onForm: f1 offForm: f2

]

{ #category : #'instance creation' }
ToggleButton class >> onForm: f1 offForm: f2 overForm: f3 [
	"Set the forms used for my on and off states."

	^ self new onForm: f1 offForm: f2 overForm: f3

]

{ #category : #menu }
ToggleButton >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'change action selector' action: #setActionSelector.
	aCustomMenu add: 'change arguments' action: #setArguments.

]

{ #category : #accessing }
ToggleButton >> alphaOn: aBoolean [

	alphaOn := aBoolean.
]

{ #category : #drawing }
ToggleButton >> areasRemainingToFill: aRectangle [
	"Don't optimize redraw; I may have transparent areas!"

	^ Array with: aRectangle

]

{ #category : #accessing }
ToggleButton >> clearIsOver [

	| f |
	isOver ifFalse: [^ self].  "already cleared"
	isOver := false.

	"update my extent"
	f := isOn ifTrue: [onForm] ifFalse: [offForm].
	isDisabled ifTrue: [f := disabledForm].
	f ifNotNil: [self extent: f extent].

]

{ #category : #accessing }
ToggleButton >> color [

	isOn
		ifNotNil:[isOn
			ifTrue:[^ onForm colorAt: ((onForm width // 2)@(onForm height // 2))]
			ifFalse:[isOver
				ifTrue:[^ overForm colorAt: ((overForm width // 2)@(overForm height // 2))]
				ifFalse:[^ offForm colorAt: ((offForm width // 2)@(offForm height // 2))]]]
		ifNil:[^ super color].
]

{ #category : #geometry }
ToggleButton >> containsPoint: aPoint [

	| f |
	(self bounds containsPoint: aPoint) ifFalse: [^ false].
	f := isOn ifTrue: [onForm] ifFalse: [offForm].
	f ifNil: [^ true].
	^ (f isTransparentAt: aPoint - bounds origin) not

]

{ #category : #drawing }
ToggleButton >> drawOn: aCanvas [

	| form |
	form := isOn ifTrue: [onForm] ifFalse: [offForm].
	isOver & isOn not ifTrue: [form := overForm].
	isDisabled ifTrue: [form := disabledForm].

	form ifNil: [  "default drawing if nil form"
		aCanvas frameRectangle: self bounds
			width: 3
			color: (isOn ifTrue: [Color veryVeryLightGray] ifFalse: [Color gray]).
		^ self].

	"alphaOn
		ifTrue: ["aCanvas translucentImage: form at: bounds origin"]
		ifFalse: [aCanvas paintImage: form at: bounds origin].
"
]

{ #category : #geometry }
ToggleButton >> extent: aRectangle [
	"Overridden because SimpleButtonMorph tries to center the label, if there is one, and we want manual control."

	| labelLoc oldP oldPSub |
	(labelLoc := self findA: StringMorph) ifNil: [
		(self submorphCount = 1) ifTrue: [oldPSub := self firstSubmorph position].
		super extent: aRectangle.
		(self submorphCount = 1) ifTrue: [self firstSubmorph position: oldPSub].
		^self].
	oldP := labelLoc position.
	super extent: aRectangle.
	labelLoc position: oldP.

]

{ #category : #'object i/o' }
ToggleButton >> fieldsVersion [

	^ 1

]

{ #category : #'event handling' }
ToggleButton >> handlesMouseOver: evt [

	^ true

]

{ #category : #'object i/o' }
ToggleButton >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		onForm
		offForm
		overForm
		disabledForm
		isMomentary
		toggleMode
		isOn
		isDisabled
	) from: anObjStream.

]

{ #category : #initialization }
ToggleButton >> initialize [

	super initialize.
	self cornerStyle: #square.
	isMomentary := false.
	toggleMode := true.
	isDisabled := false.
	isOn := isOver := false.
	alphaOn := false.

]

{ #category : #accessing }
ToggleButton >> isDisabled [

	^ isDisabled

]

{ #category : #accessing }
ToggleButton >> isDisabled: aBoolean [

	isDisabled := aBoolean.

]

{ #category : #accessing }
ToggleButton >> isMomentary: aBoolean [

	isMomentary := aBoolean.

]

{ #category : #accessing }
ToggleButton >> isOn [

	^ isOn

]

{ #category : #accessing }
ToggleButton >> label [

	self allMorphsDo: [:m | (m isKindOf: PhratchStringMorph) ifTrue: [^ m]].
	
]

{ #category : #accessing }
ToggleButton >> label: aString font: aFont [
	"Add the given label in the given font centered in my current extent."

	| oldLabel m |
	(oldLabel := self findA: PhratchStringMorph) ifNotNil: [oldLabel delete].
	m := PhratchStringMorph contents: aString font: (aFont ifNil: [PhratchPreferences standardButtonFont]).
	m position: self center - (m extent // 2).
	self addMorph: m.
	m lock.

]

{ #category : #'event handling' }
ToggleButton >> mouseDown: evt [
	"If I am currently turned on, turn myself off and vice versa. If toggleMode is false, then do nothing if I am already on. If isMomentary, then turn myself off immediately. If I am to act when I'm pressed, then send my target my action selector."

	evt hand toolType: nil.
	isDisabled ifTrue: [^ self].

	wasOn := isOn.
	actWhen == #buttonDown ifTrue: [
		self doButtonAction.
		self on.
		isMomentary ifTrue: [self off]].

]

{ #category : #'event handling' }
ToggleButton >> mouseEnter: evt [

	isDisabled ifTrue: [^ self].

	overForm ifNotNil: [
		self changed.
		isOver := true.
		self extent: overForm extent.
		self changed].

]

{ #category : #'event handling' }
ToggleButton >> mouseLeave: evt [

	PhratchToolTipMorph clearToolTips.
	isDisabled ifTrue: [^ self].

	overForm ifNotNil: [
		self changed.
		isOver := false.
		isOn ifTrue: [self on] ifFalse: [self off]].

]

{ #category : #'event handling' }
ToggleButton >> mouseMove: evt [
	"Give feedback depending on whether the mouse is over me. If I was originally on, show my off image if the mouse is over me and my on image if not. Do the opposite if I was originally off."

	isDisabled ifTrue: [^self].

	actWhen == #buttonDown ifTrue: [^ self].
	(toggleMode not & wasOn) ifTrue: [^ self].  "already on and not toggling"
	(self containsPoint: evt cursorPoint)
		ifTrue: [wasOn ifTrue: [self off] ifFalse: [self on]]
		ifFalse: [wasOn ifTrue: [self on] ifFalse: [self off]].

]

{ #category : #'event handling' }
ToggleButton >> mouseUp: evt [
	"If I am a momentary button, then turn off. If I am to act on button up, then send my target my action selector."

	isDisabled ifTrue:[^ self].

	isMomentary ifTrue: [self off].

	(actWhen == #buttonUp and:
	 [self containsPoint: evt cursorPoint])
		ifTrue: [self doButtonAction].

]

{ #category : #accessing }
ToggleButton >> off [
	"Turn myself off."

	isOn ifFalse: [^ self].
	self changed.
	isOn := false.
	offForm ifNotNil: [self extent: offForm extent].
	self changed.

]

{ #category : #initialization }
ToggleButton >> offForm: f1 [

	offForm := f1.
	self on; off
]

{ #category : #accessing }
ToggleButton >> on [
	"Turn myself on."

	isOn ifTrue: [^ self].
	self changed.
	isOn := true.
	onForm ifNotNil: [self extent: onForm extent].
	self changed.

]

{ #category : #initialization }
ToggleButton >> onForm: f1 [

	onForm := f1.
	self on; off
]

{ #category : #initialization }
ToggleButton >> onForm: f1 offForm: f2 [

	onForm := f1.
	offForm := f2.
	self on; off.

]

{ #category : #initialization }
ToggleButton >> onForm: f1 offForm: f2 overForm: f3 [

	onForm := f1.
	offForm := f2.
	overForm := f3.
	self on; off.

]

{ #category : #initialization }
ToggleButton >> onForm: f1 offForm: f2 overForm: f3 disabledForm: f4 [

	onForm := f1.
	offForm := f2.
	overForm := f3.
	disabledForm := f4.
	self on; off.

]

{ #category : #initialization }
ToggleButton >> overForm: f1 [

	overForm := f1.
	self on; off
]

{ #category : #initialization }
ToggleButton >> setDefaultLabel [
	"Overridden to do nothing. I have no label by default, although a label can be added."

]

{ #category : #accessing }
ToggleButton >> setLabelColor: aColor [

	| s |
	s := self findA: PhratchStringMorph.
	s color: aColor.

]

{ #category : #accessing }
ToggleButton >> shortcutLabel: aString font: aFont [
	"Add the given label in the given font centered in my current extent."

	| oldLabel m |
	(oldLabel := self findA: PhratchStringMorph) ifNotNil: [oldLabel delete].
	m := PhratchStringMorph contents: aString font: (aFont ifNil: [PhratchPreferences standardButtonFont]).
	m position: self center - (m extent // 2) + (0@6).
	self addMorph: m.
	m lock.

]

{ #category : #'object i/o' }
ToggleButton >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		onForm
		offForm
		overForm
		disabledForm
		isMomentary
		toggleMode
		isOn
		isDisabled
	) on: anObjStream.


]

{ #category : #accessing }
ToggleButton >> toggleMode: aBoolean [

	toggleMode := aBoolean.

]