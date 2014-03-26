Class {
	#name : #ResizableToggleButton,
	#superclass : #SimpleButtonMorph,
	#instVars : [
		'label',
		'iconMorph',
		'current',
		'normal',
		'pressed',
		'over',
		'labelColorOff',
		'labelColorOn',
		'labelColorOver',
		'isOn',
		'wasOn',
		'toggleMode',
		'toggleButtonMode',
		'justification',
		'padding',
		'hOffset',
		'vOffset'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #accessing }
ResizableToggleButton >> action [

	^ actionSelector

]

{ #category : #accessing }
ResizableToggleButton >> color [

	current ifNil: [^ Color white].
	^ current color

]

{ #category : #'event handling' }
ResizableToggleButton >> copyRecordingIn: dict [
	"Copy frame morphs for all states."

	| result |
	result := super copyRecordingIn: dict.
	normal ifNotNil: [result normal: (normal copyRecordingIn: dict)].
	pressed ifNotNil: [result pressed: (pressed copyRecordingIn: dict)].
	over ifNotNil: [result over: (over copyRecordingIn: dict)].
	^ result
]

{ #category : #geometry }
ResizableToggleButton >> extent: aPoint [

	super extent: aPoint.
	current ifNotNil: [current extent: aPoint].
	self updateLayout.
	iconMorph ifNotNil: [
		iconMorph position: self position + ((self extent - iconMorph extent) // 2)].

]

{ #category : #initialization }
ResizableToggleButton >> forceUnicodeRendering: aBoolean [

	label forceUnicodeRendering: aBoolean.
	self updateSize.


]

{ #category : #'event handling' }
ResizableToggleButton >> handlesMouseOver: evt [
	
	^ true

]

{ #category : #private }
ResizableToggleButton >> helpScreenName [
	"Answer the name of the help screen for this block, or nil if no help is available."

	#addGlobalVariable = actionSelector ifTrue: [^ 'addVariable'].
	#addGlobalList = actionSelector ifTrue: [^ 'addList'].
	(#(addVariable addGlobalVariable deleteVariable addList addGlobalList deleteList addCustomBlock) includes: actionSelector)
		ifTrue: [^ actionSelector asString].

	^ nil

]

{ #category : #accessing }
ResizableToggleButton >> icon: aForm [
	"Add an icon to this button."

	iconMorph ifNotNil: [iconMorph delete].  "delete old icon"
	iconMorph := ImageMorph new form: aForm.
	self addMorph: iconMorph.
	self extent: (iconMorph extent + 10).


]

{ #category : #initialization }
ResizableToggleButton >> initialize [

	super initialize.
	self cornerStyle: #square.
	color := Color transparent.
	borderWidth := 0.
	isOn := false.
	toggleButtonMode := false.
	toggleMode := true.
	justification := #center.
	hOffset := 0.
	vOffset := 5.
	padding := 8@8.

	label := StringMorph new.
	labelColorOff := Color r: (78/255) g: (82/255) b: (82/255).
	labelColorOn := Color black.
	labelColorOver := labelColorOff.

]

{ #category : #accessing }
ResizableToggleButton >> isOn [

	^ isOn

]

{ #category : #'as yet unclassified' }
ResizableToggleButton >> isResizableToggleButton [

	^ true
]

{ #category : #'event handling' }
ResizableToggleButton >> keyStroke: evt [
	"	ch := evt unicodeChar.
	ch = 0 ifTrue: [ch := evt keyValue]."

	"cr, lf, or enter key"

	| ch m |
	ch := evt keyValue.
	ch = 9
		ifTrue: [ 
			"tab"
			(m := self ownerOrYourselfThatIsA: DialogBoxMorph) ifNotNil: [ m tabToNextField: evt ].
			^ self ].
	ch = 27
		ifTrue: [ 
			"escape key"
			(m := self ownerOrYourselfThatIsA: DialogBoxMorph) ifNotNil: [ m escapeKeyPressed: evt ].
			^ self ].
	({10 . 13} includes: ch)
		ifFalse: [ ^ self ].
	(m := self ownerOrYourselfThatIsA: DialogBoxMorph) ifNotNil: [ ^ m enterKeyPressed: evt ].
	evt hand newKeyboardFocus: nil.
	^ self
]

{ #category : #'event handling' }
ResizableToggleButton >> keyboardFocusChange: aBoolean [

	aBoolean
		ifTrue: [self on]
		ifFalse: [self off].


]

{ #category : #accessing }
ResizableToggleButton >> label [

	^ label

]

{ #category : #initialization }
ResizableToggleButton >> label: aString font: font [

	label delete.
	label
		contents: aString font: font;
		color: (isOn ifTrue: [labelColorOn] ifFalse: [labelColorOff]).
	self addMorphFront: label.
	self updateSize.

]

{ #category : #private }
ResizableToggleButton >> labelColorOn: onColor labelColorOff: offColor labelColorOver: overColor [
	
	labelColorOn := onColor.
	labelColorOff := offColor.
	labelColorOver := overColor.
	isOn ifTrue: [ label color: onColor ] ifFalse: [ label color: offColor ].

]

{ #category : #layout }
ResizableToggleButton >> leftJustifyInset: anInteger [
	"Left-justify the label with the given inset from the left edge."

	justification := #left.
	hOffset := anInteger.
	self updateLayout.

]

{ #category : #'event handling' }
ResizableToggleButton >> mouseDown: evt [
	evt hand toolType: nil.
	wasOn := isOn.
	evt hand newKeyboardFocus: nil.
	evt rightButtonPressed
		ifTrue: [ 
			Sensor waitNoButton.
			^ self rightButtonMenu ].
	toggleButtonMode
		ifTrue: [ 
			toggleMode
				ifTrue: [ 
					isOn
						ifTrue: [ 
							isOn := false.
							self over ]
						ifFalse: [ self on ] ]
				ifFalse: [ 
					isOn
						ifTrue: [ ^ self ]
						ifFalse: [ self on ] ] ]
		ifFalse: [ self on ].
	actWhen = #buttonDown
		ifFalse: [ ^ self ].
	self doButtonAction.
	self off
]

{ #category : #'event handling' }
ResizableToggleButton >> mouseEnter: evt [

	self over.

]

{ #category : #'event handling' }
ResizableToggleButton >> mouseLeave: evt [

	isOn ifFalse: [ over ifNotNil: [self off] ].
	PhratchToolTipMorph clearToolTips.

]

{ #category : #'event handling' }
ResizableToggleButton >> mouseMove: evt [
 
	| containsPoint |
	actWhen = #buttonDown ifTrue: [^ self].

	containsPoint := self containsPoint: evt cursorPoint.
	toggleButtonMode
		ifFalse: [
			containsPoint
				ifTrue: [isOn ifFalse: [self on]]
				ifFalse: [isOn ifTrue: [self off]]]
		ifTrue: [
			toggleMode
				ifTrue: [
					containsPoint
						ifTrue: [
							wasOn
								ifTrue: [isOn ifTrue: [isOn := false. self over]]
								ifFalse: [isOn ifTrue: [^ self] ifFalse: [self on]]]
						ifFalse: [
							wasOn
								ifTrue: [isOn ifFalse: [self on]]
								ifFalse: [isOn ifTrue: [self off]]]]
				ifFalse: [
					containsPoint
						ifTrue: [
							wasOn
								ifTrue: [^ self]
								ifFalse: [isOn ifFalse: [self on]]]
						ifFalse: [
							wasOn
								ifTrue: [^ self]
								ifFalse: [isOn ifTrue: [isOn := false. self over]]]]].

]

{ #category : #'event handling' }
ResizableToggleButton >> mouseUp: evt [
	
	(actWhen = #buttonUp and:
	 [self containsPoint: evt cursorPoint])
		ifTrue: [self doButtonAction].

	toggleButtonMode ifFalse: [ self off ].

]

{ #category : #private }
ResizableToggleButton >> normal: aMorph [

	normal := aMorph.

]

{ #category : #accessing }
ResizableToggleButton >> off [
	"Turn myself off."

	isOn := false.
	self setCurrent: normal.
	label color: labelColorOff.


]

{ #category : #initialization }
ResizableToggleButton >> offForm: offForm onForm: onForm [

	normal := ImageFrameMorph new initFromForm: offForm.
	pressed := ImageFrameMorph new initFromForm: onForm.
	over := nil.
	current := normal.
	padding := normal minExtent - (0@5).

	toggleMode := false.
	self off.


]

{ #category : #initialization }
ResizableToggleButton >> offForm: offForm onForm: onForm overForm: overForm [

	self offForm: offForm onForm: onForm.
	overForm ifNotNil: [over := ImageFrameMorph new initFromForm: overForm].


]

{ #category : #accessing }
ResizableToggleButton >> on [
	"Turn myself on."

	isOn := true.
	self setCurrent: pressed.
	label color: labelColorOn.


]

{ #category : #accessing }
ResizableToggleButton >> over [
	"Show my over skin."

	"toggleButtonMode ifFalse: [^ self]."
	isOn ifTrue: [^ self].
	over ifNil: [^ self].

	self setCurrent: over.
	label color: labelColorOver.

]

{ #category : #private }
ResizableToggleButton >> over: aMorph [

	over := aMorph.

]

{ #category : #accessing }
ResizableToggleButton >> padding: aPoint [

	padding := aPoint.

]

{ #category : #private }
ResizableToggleButton >> presentHelpScreen [
	"Answer the name of the help screen for this block, or nil if no help is available."

	| fr |
	fr := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	fr
		ifNil: [^ nil]
		ifNotNil: [fr presentHelpScreen: self helpScreenName].

]

{ #category : #private }
ResizableToggleButton >> pressed: aMorph [

	pressed := aMorph.

]

{ #category : #'event handling' }
ResizableToggleButton >> rightButtonMenu [
	| menu |
	(self owner isPhratchBlockPaletteMorph)
		ifFalse: [ ^ self ].
	menu := MenuMorph new defaultTarget: self.
	menu add: 'help' translated action: #presentHelpScreen.
	menu
		localize;
		invokeModal
]

{ #category : #private }
ResizableToggleButton >> setCurrent: aMorph [
	"Make the given morph be the one currently displayed."

	aMorph ifNil: [^ self].  "should not happen"
	aMorph
		position: self position;
		extent: self extent.

	current delete.
	current := aMorph.
	self addMorphBack: current.


]

{ #category : #initialization }
ResizableToggleButton >> setDefaultLabel [
	"Overridden to do nothing. I have no label by default, although a label can be added."

]

{ #category : #initialization }
ResizableToggleButton >> setLabelColor: aColor [
	"Sets all label colors to the given color."

	self labelColorOn: aColor labelColorOff: aColor labelColorOver: aColor.

]

{ #category : #accessing }
ResizableToggleButton >> toggleButtonMode: mode [
	"If set to true, the button switches from on to off with a click, and the button remains in on mode until it is clicked again. If it is set to false, the button goes into on mode only when the mouse button is held down. toggleMode also disables changing the font color when in on mode."

	toggleButtonMode := mode.

]

{ #category : #accessing }
ResizableToggleButton >> toggleMode: mode [
	"The same as ToggleButton's toggleMode. If set to true, clicking the button when turns it from on to off. If false, clicking the button when on does nothing."

	toggleMode := mode.

]

{ #category : #private }
ResizableToggleButton >> updateLayout [
	"Update the label position within the button."

	| x y top |
	x := ((self width - label width) // 2) + hOffset.  "center by default"
	justification = #left ifTrue: [x := hOffset].
	justification = #right ifTrue: [x := self width - hOffset - label width].

	y := ((self height / 2) - vOffset) rounded.

	top := self top + 10.
	(self submorphs size = 2)
		ifTrue: [label position: self position + (x@y)]
		ifFalse: [self submorphs reversed do: [:m |
			(m isImageFrameMorph) ifFalse: [
				m left: self left + ((self width - m width) // 2).
				m top: top.
				top := m bottom + 6]]].

]

{ #category : #'falta adaptar' }
ResizableToggleButton >> updateSize [
	"Set this button size based on the label size. Assume the label has already been set."

	| trim contentsExtent |
	trim := PhratchTranslator verticalTrimForFont: label font.
	contentsExtent := 0@0.
	self submorphsDo: [: m |
		(m isImageFrameMorph) ifFalse: [
			contentsExtent := (contentsExtent x max: m width)@(contentsExtent y + m height)]].
	self extent: contentsExtent + padding - (0@trim).
	vOffset := PhratchTranslator centerOffsetForButtonWithFont: label font.
	self updateLayout.

]
