"
I am used as a scrollable blocks palette morph in a ScratchViewerMorph.

"
Class {
	#name : #PhratchBlockPaletteMorph,
	#superclass : #BorderedMorph,
	#category : #'Phratch-UI-Support'
}

{ #category : #'dropping/grabbing' }
PhratchBlockPaletteMorph >> acceptDroppingMorph: aMorph event: evt [
	"This method allows re-ordering of media in the costumes and sounds tabs."

	| editor mediaItems insertAfter |
	((aMorph isKindOf: MediaItemMorph) and:
	 [(editor := self ownerOrYourselfThatIsA: PhratchScriptEditorMorph) notNil])
		ifFalse: [^ super acceptDroppingMorph: aMorph event: evt].

	mediaItems := self submorphs select: [:m |
		(m isKindOf: MediaItemMorph) and:
		 [(m ~~ aMorph) and:
		 [(m media mediaType = aMorph media mediaType) and:
		 [m bounds intersects: aMorph bounds]]]].
	mediaItems := mediaItems sort: [:m1 :m2 | m1 top < m2 top].

	mediaItems isEmpty
		ifTrue: [insertAfter := nil]  "end of list"
		ifFalse: [
			aMorph center y > mediaItems last center y
				ifTrue: [insertAfter := nil]  "end of list"
				ifFalse: [insertAfter := mediaItems last media]].

	editor target insertMedia: aMorph media before: insertAfter.

]

{ #category : #other }
PhratchBlockPaletteMorph >> fixLayout [
	"Right align the blocks in the palette if RTL is set to true. The watcher toggle checkbox buttons are assumed to be about 18 pixels wide."

	| offset r |
	owner ifNil: [^ self].
	PhratchTranslator isRTL ifTrue:[
		self submorphs do: [:m |
			(m isKindOf: BlockMorph) ifTrue: [
				m canBecomeWatcher
					ifTrue: [m position: (self right - m width - 18 - 10)@(m position y)]
					ifFalse: [m position: (self right - m width - 10)@(m position y)].
				m changed].
			((m isKindOf: ToggleButton) or: [m isKindOf: ResizableToggleButton2]) ifTrue:[	"watcher checkbox case"
				m position: (self right - m width - 10)@(m position y)].
			(m isKindOf: ImageMorph) ifTrue: [
				m position: (self right - m width - 10)@(m position y)]]].
	offset := self topLeft negated.
	r := 0@0 extent: 1@1.
	self submorphsDo: [:m |
		r := r quickMerge: (m fullBounds translateBy: offset) truncated].
	self width: (r width max: owner width).

]

{ #category : #initialization }
PhratchBlockPaletteMorph >> initialize [

	super initialize.
	borderWidth := 0.

]

{ #category : #'dropping/grabbing' }
PhratchBlockPaletteMorph >> isPartsBin [

	^ true

]

{ #category : #'dropping/grabbing' }
PhratchBlockPaletteMorph >> rootForGrabOf: aMorph [
	"I act like a parts bin; answer a new copy of the morph being extracted."

	| root |
	root := aMorph.
	(root isKindOf: BlockMorph) ifFalse: [^ nil].
	[root = self] whileFalse: [
		root owner == self ifTrue: [^ root fullCopy].
		root := root owner].

	^ super rootForGrabOf: aMorph

]

{ #category : #other }
PhratchBlockPaletteMorph >> updateWatcherButtonsForFrame: frame [
	"Update the watcher button on this palette."

	| reporter sprite selAndArg |
	frame ifNil: [^ self].

	submorphs do: [:b |
		((b isKindOf: ToggleButton) and:
		 [b target isKindOf: ReporterBlockMorph]) ifTrue: [
			reporter := b target.
			sprite := reporter getAssociatedSprite.
			selAndArg := reporter selectorAndArg.
			(frame watcherShowingFor: sprite selectorAndArg: selAndArg)
				ifTrue: [b on; setProperty: #balloonText toValue: 'Remove viewer from stage' localized]
				ifFalse: [b off; setProperty: #balloonText toValue: 'View on stage' localized]]].

]

{ #category : #'dropping/grabbing' }
PhratchBlockPaletteMorph >> wantsDroppedMorph: aMorph event: evt [

	| f |
	((aMorph isKindOf: BlockMorph) or:
	 [(aMorph isKindOf: MediaItemMorph) or:
	 [(aMorph isKindOf: LibraryItemMorph) or:
	 [aMorph isKindOf: PhratchCommentMorph]]])
		ifTrue: [^ true].

	(aMorph isKindOf: PhratchSpriteMorph) ifTrue: [
		f := self ownerOrYourselfThatIsA: PhratchFrameMorph.
		f viewerPane pageViewer contents = self ifTrue: [^ true]].

	^ false

]
