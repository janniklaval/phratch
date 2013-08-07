Extension { #name : #MethodElementMorph }

{ #category : #'*Phratch-Extensions' }
MethodElementMorph >> rootForGrabOf: aMorph [
	"Allow myself to be extracted."

	(self ownerThatIsA: ElementsMethodEditorMorph) notNil
		ifTrue: [^nil].
	^super rootForGrabOf: aMorph
]
