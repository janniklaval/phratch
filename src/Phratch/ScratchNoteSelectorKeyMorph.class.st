Class {
	#name : #ScratchNoteSelectorKeyMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'midiKey'
	],
	#category : #'Phratch-Sound'
}

{ #category : #accessing }
ScratchNoteSelectorKeyMorph >> highlight: aBoolean [
	"If the argumet is true, highlight to show that I'm pressed. Otherwise, set my color based on whether I am a black or white key."

	| isBlackKey |
	aBoolean
		ifTrue: [self color: Color yellow]
		ifFalse: [
			isBlackKey := #(1 3 6 8 10) includes: (midiKey \\ 12).
			isBlackKey
				ifTrue: [self color: Color black]
				ifFalse: [self color: (Color gray: 0.95)]].

]

{ #category : #initialization }
ScratchNoteSelectorKeyMorph >> initialize [

	super initialize.
	borderWidth := 1.
	midiKey := 60.
	self highlight: false.

]

{ #category : #accessing }
ScratchNoteSelectorKeyMorph >> midiKey [

	^ midiKey

]

{ #category : #accessing }
ScratchNoteSelectorKeyMorph >> midiKey: anInteger [
	"Set my midiKey, which determines the pitch of this note. Middle-C is 60."

	midiKey := anInteger.
	self highlight: false.

]
