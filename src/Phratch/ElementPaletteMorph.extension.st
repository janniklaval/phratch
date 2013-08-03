Extension { #name : #ElementPaletteMorph }

{ #category : #'*Phratch-Extensions' }
ElementPaletteMorph >> isPartsBin [

	^ true

]

{ #category : #'*Phratch-Extensions' }
ElementPaletteMorph >> rootForGrabOf: aMorph [
	"I act like a parts bin; answer a new copy of the morph being extracted."

	| v |

	v := aMorph ownerThatIsA: SyntaxElementMorph.
	v ifNotNil: [
		(v isKindOf: ArgumentElementMorph)
			ifTrue: [^v owner fullCopy].
		^v fullCopy].

	^nil
]
