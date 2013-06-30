Class {
	#name : #PhratchToolTipMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'target',
		'message',
		'initialCursorPoint'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #utilities }
PhratchToolTipMorph class >> clearToolTips [
	"Delete all tooltip morphs from the world."

	World ifNil: [^ self].
	World submorphsDo: [:m |
		(m isKindOf: PhratchToolTipMorph) ifTrue: [m delete]].

]

{ #category : #'instance creation' }
PhratchToolTipMorph class >> string: str for: morph [

	^ self new
		message: str;
		target: morph;
		color: Color paleYellow;
		borderWidth: 1;
		borderColor: Color black

]

{ #category : #accessing }
PhratchToolTipMorph >> initialCursorPoint: aPoint [

	initialCursorPoint := aPoint.

]

{ #category : #accessing }
PhratchToolTipMorph >> message: aString [

	| str |
	(aString isKindOf: Form)
		ifTrue: [message := ImageMorph new colorform: aString ]
		ifFalse: [
			str := aString.
			(aString isKindOf: String) ifFalse: [
				str := aString printString].
			message := StringMorph
				contents: str
				font: self messageFont ].
	self addMorph: message.
	self extent: message extent + (12@3).
	message position: 6@1.

]

{ #category : #accessing }
PhratchToolTipMorph >> messageColor: aColor [

	message color: aColor.


]

{ #category : #accessing }
PhratchToolTipMorph >> messageFont [

	^ PhratchFrameMorph getFont: #ToolTip

]

{ #category : #stepping }
PhratchToolTipMorph >> step [

	initialCursorPoint ifNotNil: [
		(Sensor lastMousePosition - initialCursorPoint) r > 80 ifTrue: [
			target ifNotNil: [target setProperty: #toolTip toValue: nil].
			self delete]].

]

{ #category : #stepping }
PhratchToolTipMorph >> stepTime [

	^ 200

]

{ #category : #accessing }
PhratchToolTipMorph >> target: aMorph [

	target := aMorph.

]
