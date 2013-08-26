Class {
	#name : #PhratchTalkBubbleMorph,
	#superclass : #ImageFrameMorph,
	#instVars : [
		'leftPointerForm',
		'rightPointerForm',
		'pointLeft',
		'contentsMorph'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #intialization }
PhratchTalkBubbleMorph >> bePrompt: aBoolean [
	self initFromForm: (PhratchFrameMorph skinAt: #promptBubbleFrame).
	leftPointerForm := aBoolean
		ifTrue: [ PhratchFrameMorph skinAt: #promptBubblePointer ]
		ifFalse: [ PhratchFrameMorph skinAt: #talkBubbleTalkPointer ].
	rightPointerForm := leftPointerForm flipBy: #horizontal centerAt: leftPointerForm center.
	self changed
]

{ #category : #intialization }
PhratchTalkBubbleMorph >> beThoughtBubble: aBoolean [
	"If true, then be a thought bubble. Otherwise, be a talk bubble."

	leftPointerForm := aBoolean
		ifTrue: [ PhratchFrameMorph skinAt: #talkBubbleThinkPointer ]
		ifFalse: [ PhratchFrameMorph skinAt: #talkBubbleTalkPointer ].
	rightPointerForm := leftPointerForm flipBy: #horizontal centerAt: leftPointerForm center
]

{ #category : #drawing }
PhratchTalkBubbleMorph >> drawOn: aCanvas [

	| f x y |
	super drawOn: aCanvas.
	y := self bottom - leftPointerForm height.
	pointLeft
		ifTrue: [f := leftPointerForm. x := self left + 7]
		ifFalse: [f := rightPointerForm. x := self right - 53].
	aCanvas paintImage: f at: (x@y) truncated.

]

{ #category : #geometry }
PhratchTalkBubbleMorph >> extent: aPoint [

	super extent: (aPoint max: 100@42).

]

{ #category : #drawing }
PhratchTalkBubbleMorph >> hasTranslucentColor [

	^ false

]

{ #category : #intialization }
PhratchTalkBubbleMorph >> initialize [
	"Initialize the forms for all my elements."

	super initialize.
	self initFromForm: (PhratchFrameMorph skinAt: #talkBubbleFrame).
	self beThoughtBubble: false.
	pointLeft := false.

	contentsMorph := MultilineStringMorph new
		centerText: true;
		font: (PhratchFrameMorph getFont: #TalkBubble);
		yourself.
	contentsMorph
		borderWidth: 0;
		lock.
	self addMorph: contentsMorph.

]

{ #category : #geometry }
PhratchTalkBubbleMorph >> insetBottom [

	^ self bottom - leftPointerForm height + 3

]

{ #category : #accessing }
PhratchTalkBubbleMorph >> message [

	contentsMorph ifNil: [^ ''].
	^ contentsMorph contents

]

{ #category : #accessing }
PhratchTalkBubbleMorph >> message: aString [
	"(PhratchTalkBubbleMorph new message: 'Hello!') openInWorld"

	| maxWidth xOffset |
	
	maxWidth := 145.
	(aString isKindOf: String)
		ifTrue: [
			contentsMorph
				width: maxWidth;
				contents: aString trimBoth;
				fitContents ]
		ifFalse: [
			contentsMorph := aString.
			self addMorphFront: contentsMorph ].


	self extent: contentsMorph extent + (30@28).
	xOffset := contentsMorph width >= maxWidth
		ifTrue: [3]
		ifFalse: [((self width - contentsMorph width) // 2) ].
	contentsMorph position: self position + (xOffset @ 5).

]

{ #category : #accessing }
PhratchTalkBubbleMorph >> pointLeft: aBoolean [

	pointLeft := aBoolean.
	self changed.

]
