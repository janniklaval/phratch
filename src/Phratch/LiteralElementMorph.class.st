Class {
	#name : #LiteralElementMorph,
	#superclass : #SyntaxElementMorph,
	#instVars : [
		'textBox',
		'contents'
	],
	#category : #'Phratch-BYOB-Elements'
}

{ #category : #'as yet unclassified' }
LiteralElementMorph >> asSmalltalk [
	^textBox contents
]

{ #category : #'as yet unclassified' }
LiteralElementMorph >> contents: aLiteral [
	(aLiteral isMemberOf: Array)
		ifTrue: [ textBox label: '#', aLiteral printString ]
		ifFalse: [ textBox label: aLiteral printString ]
]

{ #category : #'as yet unclassified' }
LiteralElementMorph >> contextMenu [
	|m|
	m := MenuMorph new.
"	m add: 'duplicate' action: #duplicate. "
	m add: 'delete' action: #throwAway.
	m addLine.
	m add: 'show code...' action: #showGeneratedSmalltalk.

	^m
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
LiteralElementMorph >> initialize [
	super initialize.
	color := Color blue darker.
	textBox := TextBoxElementMorph new label: ''.
	self addMorph: textBox.
	self fit
]
