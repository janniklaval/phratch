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
	((aMorph isMediaItemMorph) and: [ (editor := self ownerOrYourselfThatIsAPhratchScriptEditorMorph) notNil ])
		ifFalse: [ ^ super acceptDroppingMorph: aMorph event: evt ].
	mediaItems := self submorphs
		select: [ :m | 
			(m isMediaItemMorph)
				and: [ m ~~ aMorph and: [ m media mediaType = aMorph media mediaType and: [ m bounds intersects: aMorph bounds ] ] ] ].
	mediaItems := mediaItems sort: [ :m1 :m2 | m1 top < m2 top ].
	insertAfter := mediaItems isEmpty
		ifTrue: [ nil ]
		ifFalse: [ 
			aMorph center y > mediaItems last center y
				ifTrue: [ nil ]
				ifFalse: [ mediaItems last media ]	"end of list" ].	"end of list"
	editor target insertMedia: aMorph media before: insertAfter
]

{ #category : #other }
PhratchBlockPaletteMorph >> fixLayout [
	"Right align the blocks in the palette if RTL is set to true. The watcher toggle checkbox buttons are assumed to be about 18 pixels wide."

	| offset r |
	owner ifNil: [^ self].
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

{ #category : #testing }
PhratchBlockPaletteMorph >> isPhratchBlockPaletteMorph [

	^ true
]

{ #category : #'dropping/grabbing' }
PhratchBlockPaletteMorph >> rootForGrabOf: aMorph [
	"I act like a parts bin; answer a new copy of the morph being extracted."

	| root |
	root := aMorph.
	(root isBlockMorph) ifFalse: [^ nil].
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
		((b isToggleButton) and:
		 [b target isReporterBlockMorph]) ifTrue: [
			reporter := b target.
			sprite := reporter getAssociatedSprite.
			selAndArg := reporter selectorAndArg.
			(frame watcherShowingFor: sprite selectorAndArg: selAndArg)
				ifTrue: [b on; helpText: 'Remove viewer from stage' localized]
				ifFalse: [b off; helpText: 'View on stage' localized]]].

]

{ #category : #'dropping/grabbing' }
PhratchBlockPaletteMorph >> wantsDroppedMorph: aMorph event: evt [

	| f |
	((aMorph isBlockMorph) or:
	 [(aMorph isMediaItemMorph) or:
	 [(aMorph isLibraryItemMorph) or:
	 [aMorph isPhratchCommentMorph]]])
		ifTrue: [^ true].

	(aMorph isPhratchSpriteMorph) ifTrue: [
		f := self ownerOrYourselfThatIsAPhratchFrameMorph.
		f viewerPane pageViewer contents = self ifTrue: [^ true]].

	^ false

]
