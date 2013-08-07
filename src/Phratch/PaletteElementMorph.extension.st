Extension { #name : #PaletteElementMorph }

{ #category : #'*Phratch-Extensions' }
PaletteElementMorph >> isPartsBin [

	^ true

]

{ #category : #'*Phratch-Extensions' }
PaletteElementMorph >> rootForGrabOf: aMorph [
	"I act like a parts bin; answer a new copy of the morph being extracted."

	| v |
	v := aMorph ownerThatIsA: ObjectElementMorph.
	v ifNotNil: [^v fullCopy].

	(owner isKindOf: MethodElementMorph)
		ifTrue: [^owner rootForGrabOf: aMorph].
	^owner
]
