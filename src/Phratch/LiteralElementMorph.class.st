Class {
	#name : #LiteralElementMorph,
	#superclass : #SyntaxElementMorph,
	#instVars : [
		'textBox'
	],
	#category : #'Phratch-UI-Elements'
}

{ #category : #converting }
LiteralElementMorph >> asSmalltalk [
	^textBox contents
]

{ #category : #accessing }
LiteralElementMorph >> contents: aLiteral [
	(aLiteral isMemberOf: Array)
		ifTrue: [ textBox label: '#', aLiteral printString ]
		ifFalse: [ textBox label: aLiteral printString ]
]

{ #category : #menu }
LiteralElementMorph >> contextMenu [
	| m |
	m := MenuMorph new.	"	m add: 'duplicate' action: #duplicate. "
	m add: 'delete' translated action: #throwAway.
	m addLine.
	m add: 'show code...' translated action: #showGeneratedSmalltalk.
	^ m
]

{ #category : #private }
LiteralElementMorph >> fit [

	| bw cw handle |
	bw := self borderWidth.
	cw := self labelFont widthOf: $ .
	handle := cw * 2.

	self extent: textBox extent + (bw * 4).
	self width: self width + handle.

	textBox position: (self left + handle + bw) @ (self center - (textBox extent // 2)) y.

	(owner respondsTo: #fit)
		ifTrue: [owner fit]

]

{ #category : #initialize }
LiteralElementMorph >> initialize [
	super initialize.
	color := Color blue darker.
	textBox := TextBoxElementMorph new label: ''.
	self addMorph: textBox.
	self fit
]
