Extension { #name : #BlockElementMorph }

{ #category : #'*Phratch-Extensions' }
BlockElementMorph >> rootForGrabOf: aMorph [
	"Allow myself to be extracted."

	(self ownerThatIsA: ElementPaletteMorph) ifNotNil: [
		(self ownerThatIsA: MessageElementMorph)
			ifNotNil: [^owner rootForGrabOf: owner ]].
	^super rootForGrabOf: aMorph
]
