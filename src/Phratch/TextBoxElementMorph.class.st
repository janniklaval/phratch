Class {
	#name : #TextBoxElementMorph,
	#superclass : #ArgumentElementMorph,
	#category : #'Phratch-UI-Elements'
}

{ #category : #accessing }
TextBoxElementMorph >> contents [
	^label contents
]

{ #category : #private }
TextBoxElementMorph >> fit [
	label ifNil: [^self ].
	self extent: label extent + (self borderWidth * 2).
	self width: (self width + (self labelFont widthOf: $ )).
	label position: bounds center - (label extent // 2).
	(owner respondsTo: #fit)
		ifTrue: [owner fit]

]

{ #category : #initialize }
TextBoxElementMorph >> initialize [
	super initialize.
	color := Color white.
	self fit
]

{ #category : #accessing }
TextBoxElementMorph >> label: aString [
	label ifNil: [
		label := StringElementMorph contents: aString font: self labelFont.
		label color: self labelColor.
		self addMorphFront: label ].
	label contents: aString.
	self fit

]

{ #category : #private }
TextBoxElementMorph >> labelColor [
	^Color black
]

{ #category : #private }
TextBoxElementMorph >> labelFont [
	^StrikeFont fontName: 'Verdana' size: 9
]

{ #category : #widgets }
TextBoxElementMorph >> layoutChanged [

	super layoutChanged.
	self resizeToLabel.
]

{ #category : #'event handling' }
TextBoxElementMorph >> mouseDown: evt [
	"Handle a mouse down event. This default implementation does nothing."
	label launchMiniEditor: evt
]

{ #category : #private }
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

{ #category : #'dropping/grabbing' }
TextBoxElementMorph >> wantsDroppedMorph: aMorph event: evt [

	^false
]
