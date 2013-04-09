Class {
	#name : #PhratchSpriteLibraryMorph,
	#superclass : #BorderedMorph,
	#category : #'Phratch-UI-Support'
}

{ #category : #'dropping/grabbing' }
PhratchSpriteLibraryMorph >> acceptDroppingMorph: aMorph event: evt [
	"This method allows re-ordering of sprites in the sprite library area."

	| insertAfter libraryItems spriteLibrary movedThumbnail mostOverlap mostOverlapIndex sf |
	((aMorph isKindOf: LibraryItemMorph) and:
	 [(spriteLibrary := self ownerOrYourselfThatIsA: PhratchSpriteLibraryMorph) notNil])
		ifFalse: [^ super acceptDroppingMorph: aMorph event: evt].

	"Set the new position of the morph that just moved"
	movedThumbnail := self submorphs detect: [:m | (m target == aMorph target)] ifNone: [^ self].

	libraryItems := self submorphs select: [:m | 
		(m bounds intersects: aMorph bounds) and:
		[(m ~~ aMorph)]].

	"Select the thumbnail with the most overlap with movedThumbnail"
	libraryItems := libraryItems sort: [:m1 :m2 | 
		((m1 bounds intersect: aMorph bounds) area < 
			(m2 bounds intersect: aMorph bounds) area)].

	movedThumbnail position: aMorph position.
	aMorph delete.

	libraryItems isEmpty
		ifTrue: [insertAfter := nil]  "end of list"
		ifFalse: [
			mostOverlap := libraryItems last.
			(movedThumbnail center x > mostOverlap center x)
				ifTrue: [
					mostOverlapIndex := self submorphs indexOf: mostOverlap.
					self submorphCount == mostOverlapIndex
						ifTrue: [insertAfter := nil]
						ifFalse: [insertAfter := self submorphs at: (mostOverlapIndex + 1)]]
				ifFalse: [insertAfter := mostOverlap]].

	spriteLibrary insertItem: movedThumbnail before: insertAfter.

	sf := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	sf ifNotNil: [ sf workPane updateSpritesList ].

]

{ #category : #'dropping/grabbing' }
PhratchSpriteLibraryMorph >> insertItem: item1 before: item2orNil [
	"Shuffle my sprite thumbnails.  I rearrange my submorphs so that the library is shuffled and layed out properly.  I don't bother updating the sprites list which is stored in the stage; I let it update on its own when updateSpritesList is called"

	| nextItem |
	item1 == item2orNil ifFalse: [
		item2orNil
			ifNil: [
				self addMorphBack: item1]
			ifNotNil: [
				self removeAllMorphsIn: (Array with: item1).
				self replaceSubmorph: item2orNil by: item1.
				nextItem := item2orNil.
				self submorphsBehind: item1 do: [:s |
					self replaceSubmorph: s by: nextItem.
					nextItem := s].
				self addMorphBack: nextItem]].
	(self ownerOrYourselfThatIsA: PhratchLibraryMorph) fixLayout.

]

{ #category : #'dropping/grabbing' }
PhratchSpriteLibraryMorph >> isPartsBin [

	^ true

]

{ #category : #'dropping/grabbing' }
PhratchSpriteLibraryMorph >> rootForGrabOf: aMorph [
	"I act like a parts bin; answer a new copy of the morph being extracted."

	| root |
	root := aMorph.
	(root isKindOf: BlockMorph) ifFalse: [^ nil].
	[root = self] whileFalse: [
		root owner == self ifTrue: [^ root fullCopy].
		root := root owner].

	^ super rootForGrabOf: aMorph

]

{ #category : #'dropping/grabbing' }
PhratchSpriteLibraryMorph >> wantsDroppedMorph: aMorph event: evt [

	^ (aMorph isKindOf: LibraryItemMorph)

]