Class {
	#name : #TextBoxElementMorph,
	#superclass : #ArgumentElementMorph,
	#instVars : [
		'doResizing',
		'insetX',
		'heightPadding',
		'stringMorph',
		'insetY',
		'selectionColor',
		'selectionEnd',
		'selectionStart',
		'undoState',
		'blinkState',
		'lastContents',
		'isKeyboardFocus',
		'acceptWhenFocusLost',
		'frame',
		'isNumeric',
		'client',
		'dragStartIndex',
		'isEditable'
	],
	#category : #'Phratch-UI-Elements'
}

{ #category : #'as yet unclassified' }
TextBoxElementMorph >> contents [
	^label contents
]

{ #category : #'as yet unclassified' }
TextBoxElementMorph >> fit [
	label ifNil: [^self ].
	self extent: label extent + (self borderWidth * 2).
	self width: (self width + (self labelFont widthOf: $ )).
	label position: bounds center - (label extent // 2).
	(owner respondsTo: #fit)
		ifTrue: [owner fit]

]

{ #category : #'as yet unclassified' }
TextBoxElementMorph >> handlesMouseDown: evt [
	"Return true if this morph wants to receive mouseDown events (i.e., mouseDown:, mouseMove:, mouseUp:). The default response is false; subclasses that implement mouse messages should override this to return true." 

	^ true

]

{ #category : #'as yet unclassified' }
TextBoxElementMorph >> initialize [
	super initialize.
	color := Color white.
	self fit
]

{ #category : #'as yet unclassified' }
TextBoxElementMorph >> label: aString [
	label ifNil: [
		label := StringElementMorph contents: aString font: self labelFont.
		label color: self labelColor.
		self addMorphFront: label ].
	label contents: aString.
	self fit

]

{ #category : #'as yet unclassified' }
TextBoxElementMorph >> labelColor [
	^Color black
]

{ #category : #'as yet unclassified' }
TextBoxElementMorph >> labelFont [
	^StrikeFont fontName: 'Verdana' size: 9
]

{ #category : #'as yet unclassified' }
TextBoxElementMorph >> layoutChanged [

	super layoutChanged.
	self resizeToLabel.
]

{ #category : #'as yet unclassified' }
TextBoxElementMorph >> mouseDown: evt [
	"Handle a mouse down event. This default implementation does nothing."
	label launchMiniEditor: evt
]

{ #category : #'as yet unclassified' }
TextBoxElementMorph >> resizeToLabel [
	| le h ne |
	label ifNil: [^self ].

	le := (label extent + (self borderWidth * 2) + ((self labelFont widthOf: $ ) @ 0)).
	h := MessageElementMorph labelFont height.
	ne := ( h max: le x ) @ ( h max: le y).
	(self extent = ne) ifFalse: [self extent: ne ].

	(owner respondsTo: #fit)
		ifTrue: [owner fit]

]

{ #category : #'as yet unclassified' }
TextBoxElementMorph >> wantsDroppedMorph: aMorph event: evt [

	^false
]
