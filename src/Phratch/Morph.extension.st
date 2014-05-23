Extension { #name : #Morph }

{ #category : #'*Phratch-Extensions' }
Morph >> allowSubmorphExtraction [
	"Return true if this morph allows its submorphs to be extracted just by grabbing them."

	self isPartsBin ifTrue: [^ false].
	^ self dragNDropEnabled or: [self dragEnabled]

]

{ #category : #'*Phratch-Extensions' }
Morph >> centering: aSymbol [

	self wrapCentering: aSymbol
]

{ #category : #'*Phratch-Extensions' }
Morph >> flags [

	self valueOfProperty: #flags ifAbsentPut: [ 0 ].
]

{ #category : #'*Phratch-Extensions' }
Morph >> fullCopy [
	^ self veryDeepCopy
]

{ #category : #'*Phratch-Extensions' }
Morph >> inset: aNumber [

	self layoutInset: aNumber
]

{ #category : #'*Phratch-Extensions' }
Morph >> isHidden [

	^ self visible not
]

{ #category : #'*Phratch-Extensions' }
Morph >> isHidden: aBoolean [

	self visible: aBoolean not
]

{ #category : #'*Phratch-Extensions' }
Morph >> isPartsBin [
	^ false
]

{ #category : #'*Phratch-Extensions' }
Morph >> isSticky: aBoolean [

	^ self sticky: aBoolean
]

{ #category : #'*Phratch-Extensions' }
Morph >> isVisible [

	^ self isHidden not

]

{ #category : #'*Phratch-Extensions' }
Morph >> isVisible: aBoolean [
 self extension visible: aBoolean 
]

{ #category : #'*Phratch-Extensions' }
Morph >> mayNeedLayout [
	"Answer true if something has occured that might require my layout to change That is, if layoutChanged has been sent to me or any of my submorphs."

	^ fullBounds isNil

]

{ #category : #'*Phratch-Extensions' }
Morph >> orientation: aSymbol [

	self listDirection: (aSymbol caseOf: {
		[#vertical] -> [#topToBottom].
		[#horizontal] -> [#leftToRight]})
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsABlockEditorFrameMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isBlockEditorFrameMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsABlockMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isBlockMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsACommandBlockMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isCommandBlockMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsACustomCommandBlockMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isCustomCommandBlockMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsACustomReporterBlockMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isCustomReporterBlockMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsADialogBoxMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isDialogBoxMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAHandMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isHandMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAHatBlockMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isHatBlockMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAOffscreenWorldMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isOffscreenWorldMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAPhratchBlockPaletteMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isPhratchBlockPaletteMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAPhratchFileChooserDialog [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isPhratchFileChooserDialog)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAPhratchFrameMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isPhratchFrameMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAPhratchLibraryMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isPhratchLibraryMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAPhratchListMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isPhratchListMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAPhratchPrompterMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isPhratchPrompterMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAPhratchScriptEditorMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isPhratchScriptEditorMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAPhratchScriptsMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isPhratchScriptsMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAPhratchSpriteLibraryMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isPhratchSpriteLibraryMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAPhratchStageMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isPhratchStageMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAPhratchViewerMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isPhratchViewerMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAScrollFrameMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isScrollFrameMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAWatcherMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isWatcherMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerOrYourselfThatIsAWatcherReadoutFrameMorph [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current  |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isWatcherReadoutFrameMorph)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerThatIsADialogBoxMorph [
	"Return the first enclosing morph that is a kind of aClass, or nil if none"

	^ self firstOwnerSuchThat: [:m | m isDialogBoxMorph]
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerThatIsAOffscreenWorldMorph [
	"Return the first enclosing morph that is a kind of aClass, or nil if none"

	^ self firstOwnerSuchThat: [:m | m isOffscreenWorldMorph]
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerThatIsAPhratchBlockPaletteMorph [
	"Return the first enclosing morph that is a kind of aClass, or nil if none"

	^ self firstOwnerSuchThat: [:m | m isPhratchBlockPaletteMorph]
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerThatIsAPhratchFrameMorph [
	"Return the first enclosing morph that is a kind of aClass, or nil if none"

	^ self firstOwnerSuchThat: [:m | m isPhratchFrameMorph]
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerThatIsAPhratchListMorph [
	"Return the first enclosing morph that is a kind of aClass, or nil if none"

	^ self firstOwnerSuchThat: [:m | m isPhratchListMorph]
]

{ #category : #'*Phratch-Extensions-OwnerOrYourself' }
Morph >> ownerThatIsAPhratchStageMorph [
	"Return the first enclosing morph that is a kind of aClass, or nil if none"

	^ self firstOwnerSuchThat: [:m | m isPhratchStageMorph]
]

{ #category : #'*Phratch-Extensions' }
Morph >> rootForGrabOf: aMorph [
	"Answer the root of the morph structure to be picked up when the given morph is grabbed."

	(self isSticky "and: [self isPartsDonor not]")
		ifTrue: [^ nil]
		ifFalse: [
			(owner isNil or: [owner isWorldOrHandMorph])
				ifTrue: [^ self]
				ifFalse: [
					owner allowSubmorphExtraction
						ifTrue: [^ self]
						ifFalse: [^ owner rootForGrabOf: aMorph]]].

]

{ #category : #'*Phratch-Extensions' }
Morph >> unlockedMorphsAt: aPoint [
	"Return a collection of all unlocked morphs in this morph structure that contain the given point, possibly including the receiver itself.  Simplified "

	^ self unlockedMorphsAt: aPoint addTo: OrderedCollection new
]

{ #category : #'*Phratch-Extensions' }
Morph >> unlockedMorphsAt: aPoint addTo: mList [
	"Return a collection of all morphs in this morph structure that contain the given point, possibly including the receiver itself.  Must do this recursively because of transforms.  "
	(self fullBounds containsPoint: aPoint) ifFalse: [^ mList].  "quick elimination"
	self isLocked ifTrue: [^ mList].
	submorphs size > 0 ifTrue:
		[submorphs do: [:m | m unlockedMorphsAt: aPoint addTo: mList]].
	(self containsPoint: aPoint) ifTrue: [mList addLast: self].
	^ mList
]

{ #category : #'*Phratch-Extensions' }
Morph >> updateReferencesUsing: aDictionary [
	"Update intra-morph references within a composite morph that has
been copied. For example, if a button refers to morph X in the orginal
composite then the copy of that button in the new composite should refer to
the copy of X in new composite, not the original X. This default
implementation updates the contents of any morph-bearing slot. It may be
overridden to avoid this behavior if so desired."

	| old prop |
	Morph instSize + 1 to: self class instSize do: [:i |
		old := self instVarAt: i.
		old isMorph ifTrue:
			[self instVarAt: i put: (aDictionary at: old ifAbsent: [old])]].

	"map morph values in my properties list"
	prop := self otherProperties.
	
	prop notNil ifTrue: [ 
		prop do:[:e |
			old := e value.
			old isMorph ifTrue: [
				prop value: (aDictionary at: old ifAbsent: [old])].
		]
	].
]
