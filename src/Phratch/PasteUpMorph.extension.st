Extension { #name : #PasteUpMorph }

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
PasteUpMorph >> unlockedMorphsAt: aPoint addTo: mList [
	"Overridden to exclude spurious hits on extralimital submorphs."
	((self containsPoint: aPoint) and: [self isLocked not]) ifTrue:
		[submorphs size > 0 ifTrue:
			[submorphs do: [:m | m unlockedMorphsAt: aPoint addTo: mList]].
		mList addLast: self].
	^ mList
]
