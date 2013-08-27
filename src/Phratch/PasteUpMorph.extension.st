Extension { #name : #PasteUpMorph }

{ #category : #'*Phratch-Extensions' }
PasteUpMorph >> abandonAllHalos [
	self haloMorphs do: [:m | m delete]
]

{ #category : #'*Phratch-Extensions' }
PasteUpMorph >> cycleWhileWaitingMSecs: waitMSecs doInput: doInputFlag doSteps: doStepFlag [
	"Perform the interactive loop repeatedly for the given number of milliseconds."

	| startT now |
	startT := Time millisecondClockValue.
	[((now := Time millisecondClockValue) < startT) or:
	 [(now - startT) < waitMSecs]] whileTrue: [
		doInputFlag ifTrue: [
			"process user input events"
			self handsDo: [:h |
				"self activeHand: h."
				h processEvents]].

		doStepFlag ifTrue: [self runStepMethods].
		self displayWorldSafely].
]

{ #category : #'*Phratch-Extensions' }
PasteUpMorph >> doOneCycleNoInput [
	"Do one cycle of the display and step loop without user input."

	self runStepMethods.
	self displayWorldSafely.

]

{ #category : #'*Phratch-Extensions' }
PasteUpMorph >> fieldsVersion [

	^ 1
]

{ #category : #'*Phratch-Extensions' }
PasteUpMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		backgroundMorph 
	) from: anObjStream.

]

{ #category : #'*Phratch-Extensions' }
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

{ #category : #'*Phratch-Extensions' }
PasteUpMorph >> rootForGrabOf: aMorph [
	"If open to drag-n-drop, allow the given submorph to be extracted. If I am a parts bin answer a new copy of it."

	| root |
	root := aMorph.
	[root = self] whileFalse: [
		root owner == self ifTrue: [
			self isPartsBin ifTrue: [^ root fullCopy].
			self dragNDropEnabled ifTrue: [^ root]].
		root := root owner].

	^ super rootForGrabOf: aMorph

]

{ #category : #'*Phratch-Extensions' }
PasteUpMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		backgroundMorph 
	) on: anObjStream.

]
