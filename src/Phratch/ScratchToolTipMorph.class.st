Class {
	#name : #ScratchToolTipMorph,
	#superclass : #RectangleMorph,
	#instVars : [
		'target',
		'message',
		'initialCursorPoint'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #utilities }
ScratchToolTipMorph class >> clearToolTips [
	"Delete all tooltip morphs from the world."

	World ifNil: [^ self].
	World submorphsDo: [:m |
		(m isKindOf: ScratchToolTipMorph) ifTrue: [m delete]].

]

{ #category : #'instance creation' }
ScratchToolTipMorph class >> string: str for: morph [

	^ self new
		message: str;
		target: morph;
		color: Color paleYellow;
		borderWidth: 1;
		borderColor: Color black

]

{ #category : #accessing }
ScratchToolTipMorph >> initialCursorPoint: aPoint [

	initialCursorPoint := aPoint.

]

{ #category : #accessing }
ScratchToolTipMorph >> message: aString [

	| str |
	(aString isKindOf: Form)
		ifTrue: [message := ImageMorph new colorform: aString ]
		ifFalse: [
			str := aString.
			(aString isKindOf: String) ifFalse: [
				str := aString printString].
			message := PhratchStringMorph
				contents: str
				font: self messageFont ].
	self addMorph: message.
	self extent: message extent + (12@3).
	message position: 6@1.

]

{ #category : #accessing }
ScratchToolTipMorph >> messageColor: aColor [

	message color: aColor.


]

{ #category : #accessing }
ScratchToolTipMorph >> messageFont [

	^ ScratchFrameMorph getFont: #ToolTip

]

{ #category : #stepping }
ScratchToolTipMorph >> step [

	initialCursorPoint ifNotNil: [
		(Sensor lastMousePosition - initialCursorPoint) r > 80 ifTrue: [
			target ifNotNil: [target setProperty: #toolTip toValue: nil].
			self delete]].

]

{ #category : #stepping }
ScratchToolTipMorph >> stepTime [

	^ 200

]

{ #category : #accessing }
ScratchToolTipMorph >> target: aMorph [

	target := aMorph.

]
