Class {
	#name : #ResizableToggleButton,
	#superclass : #SimpleButtonMorph,
	#instVars : [
		'sideMargin',
		'isOn',
		'offLabelColor',
		'normalFormLeft',
		'normalFormEdge',
		'normalFormRight',
		'pressedFormLeft',
		'pressedFormEdge',
		'pressedFormRight'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'instance creation' }
ResizableToggleButton class >> normalFormLeft: f1 normalFormEdge: f2 normalFormRight: f3 label: aLabel sideMargin: aNumber [
	"Set the forms used for my normal state."

	^ self new
		normalFormLeft: f1
		normalFormEdge: f2
		normalFormRight: f3
		label: aLabel
		sideMargin: aNumber.
]

{ #category : #accessing }
ResizableToggleButton >> actWhen [

	^ actWhen
]

{ #category : #drawing }
ResizableToggleButton >> areasRemainingToFill: aRectangle [
	"Don't optimize redraw; I may have transparent areas!"

	^ Array with: aRectangle

]

{ #category : #accessing }
ResizableToggleButton >> color [

	isOn
		ifNotNil:[isOn
			ifTrue:[^ pressedFormEdge colorAt: ((pressedFormEdge width // 2)@(pressedFormEdge height // 2))]
			ifFalse:[^ normalFormEdge colorAt: ((normalFormEdge width // 2)@(normalFormEdge height // 2))]]
		ifNil:[^ super color].
]

{ #category : #drawing }
ResizableToggleButton >> drawOn: aCanvas [
	"Draw my normalLeft/normalEdge/normalRight forms and extend the normalEdgeForm to the width of my bounds."

	| startPoint p clipC lastX formLeft formEdge formRight |

	isOn & pressedFormLeft notNil
		ifTrue: [formLeft := pressedFormLeft.
				formEdge := pressedFormEdge.
				formRight := pressedFormRight] 
		ifFalse: [formLeft := normalFormLeft.
				formEdge := normalFormEdge.
				formRight := normalFormRight].
	
	startPoint := self bounds origin + (formLeft width@0).
	p := startPoint.
	clipC := aCanvas copyClipRect: self bounds.
	lastX := self bounds right - (formRight width) - 1.

	clipC paintImage: formLeft at: self bounds origin.
	[p x <= lastX] whileTrue: [
		clipC paintImage: formEdge at: p.
		p := (p x + formEdge width) @ p y].
	clipC paintImage: formRight at: p.
	
	

]

{ #category : #accessing }
ResizableToggleButton >> helpScreenName [
	"Answer the name of the help screen for this block, or nil if no help is available."

	#addGlobalVariable = actionSelector ifTrue: [^ 'addVariable'].
	(#(addVariable addGlobalVariable deleteVariable) includes: actionSelector)
		ifTrue: [^ actionSelector asString].

	^ nil

]

{ #category : #initialization }
ResizableToggleButton >> initialize [

	super initialize.
	self cornerStyle: #square.
	isOn := false.
]

{ #category : #accessing }
ResizableToggleButton >> isOn [

	^ isOn
]

{ #category : #accessing }
ResizableToggleButton >> label: aString font: aFont [

	| oldLabel m |
	(oldLabel := self findA: PhratchStringMorph) ifNotNil: [oldLabel delete].
	m := PhratchStringMorph contents: aString font: (aFont ifNil: [PhratchPreferences standardButtonFont]).
	m color: (Color r: (78/255) g: (82/255) b: (82/255)).
	self extent: m extent + borderWidth.
	self width: self width + sideMargin.
	self height: (self height max: normalFormLeft height).
	m position: (self center - (m extent // 2)) - (0@1).
	self addMorph: m.
	m lock.

]

{ #category : #'event handling' }
ResizableToggleButton >> mouseDown: evt [

	evt rightButtonPressed ifTrue: [^ self rightButtonMenu].

	evt hand toolType: nil.

	self on.
	actWhen = #buttonDown ifTrue: [
		self doButtonAction.
		self off].


]

{ #category : #'event handling' }
ResizableToggleButton >> mouseLeave: evt [

	ScratchToolTipMorph clearToolTips.

]

{ #category : #'event handling' }
ResizableToggleButton >> mouseMove: evt [

	actWhen = #buttonDown ifTrue: [^ self].
	(self containsPoint: evt cursorPoint)
		ifTrue: [self on]
		ifFalse: [self off].


]

{ #category : #'event handling' }
ResizableToggleButton >> mouseUp: evt [
	
	(actWhen = #buttonUp and:
	 [self containsPoint: evt cursorPoint])
		ifTrue: [self doButtonAction].

	self off.

]

{ #category : #initialization }
ResizableToggleButton >> normalFormLeft: f1 normalFormEdge: f2 normalFormRight: f3 label: aLabel sideMargin: aNumber [

	normalFormLeft := f1.
	normalFormEdge := f2.
	normalFormRight := f3.
	sideMargin := aNumber.
	self label: aLabel font: TextStyle defaultFont.

]

{ #category : #accessing }
ResizableToggleButton >> off [
	"Turn myself off."

	| myLabel |
	isOn ifFalse: [^ self].
	isOn := false.
	self changed.

	(myLabel := self findA: PhratchStringMorph) ifNotNil: [
		offLabelColor ifNotNil: [
			myLabel color: offLabelColor]].

]

{ #category : #accessing }
ResizableToggleButton >> on [
	"Turn myself on."

	| myLabel |
	isOn ifTrue: [^ self].
	isOn := true.
	self changed.

	(myLabel := self findA: PhratchStringMorph) ifNotNil: [
		offLabelColor := myLabel color.
		myLabel color: Color black].

]

{ #category : #accessing }
ResizableToggleButton >> presentHelpScreen [
	"Answer the name of the help screen for this block, or nil if no help is available."

	| fr |
	fr := self ownerOrYourselfThatIsA: ScratchFrameMorph.
	fr
		ifNil: [^ nil]
		ifNotNil: [fr presentHelpScreen: self helpScreenName]

]

{ #category : #initialization }
ResizableToggleButton >> pressedFormLeft: f1 pressedFormEdge: f2 pressedFormRight: f3 [ 

	pressedFormLeft := f1.
	pressedFormEdge := f2.
	pressedFormRight := f3.

]

{ #category : #'event handling' }
ResizableToggleButton >> rightButtonMenu [

	| menu |

	(self owner isKindOf: PhratchBlockPaletteMorph) ifTrue: [
		menu := MenuMorph new defaultTarget: self.
		menu add: 'help' action: #presentHelpScreen.
		menu localize; popUpInWorld].


]

{ #category : #initialization }
ResizableToggleButton >> setDefaultLabel [
	"Overridden to do nothing. I have no label by default, although a label can be added."

]
