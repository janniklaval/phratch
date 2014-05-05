Extension { #name : #PasteUpMorph }

{ #category : #'*PhratchColor' }
PasteUpMorph >> patchAt: patchRect without: stopMorph andNothingAbove: stopThere [
	"Return a complete rendering of this patch of the display screen without drawing stopMorph and, if stopThere is true, without drawing any morph above it."

	| c morphsToDraw i |
	c := FormCanvas extent: patchRect extent depth: Display depth.
	c := c copyOrigin: patchRect topLeft negated clipRect: (0@0 extent: patchRect extent).

	(self bounds containsRect: patchRect) ifFalse: [
		"fill areas of patchRect outside my bounds with black"
		c form fillColor: Color black].
	(self bounds intersects: patchRect) ifFalse: [^ c form].  "entirely out of bounds"

	"draw all morphs intersecting the given patch, stopping at the given morph"
	c fillRectangle: self bounds color: color.  "draw world color"
	morphsToDraw := submorphs reversed asOrderedCollection.
	(i := morphsToDraw indexOf: stopMorph) > 0 ifTrue: [
		stopThere
			ifTrue: [morphsToDraw := morphsToDraw copyFrom: 1 to: i - 1]  "stop at stopMorph"
			ifFalse: [morphsToDraw removeIndex: i]].  "skip stopMorph"
	morphsToDraw do: [:m | m fullDrawOn: c].
	^ c form
]
