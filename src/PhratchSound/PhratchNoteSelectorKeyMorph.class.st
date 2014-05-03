Class {
	#name : #PhratchNoteSelectorKeyMorph,
	#superclass : #PhratchBorderedMorph,
	#instVars : [
		'midiKey'
	],
	#category : #PhratchSound
}

{ #category : #accessing }
PhratchNoteSelectorKeyMorph >> highlight: aBoolean [
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
PhratchNoteSelectorKeyMorph >> initialize [

	super initialize.
	borderWidth := 1.
	midiKey := 60.
	self highlight: false.

]

{ #category : #testing }
PhratchNoteSelectorKeyMorph >> isPhratchNoteSelectorKeyMorph [

	^ true
]

{ #category : #accessing }
PhratchNoteSelectorKeyMorph >> midiKey [

	^ midiKey

]

{ #category : #accessing }
PhratchNoteSelectorKeyMorph >> midiKey: anInteger [
	"Set my midiKey, which determines the pitch of this note. Middle-C is 60."

	midiKey := anInteger.
	self highlight: false.

]
