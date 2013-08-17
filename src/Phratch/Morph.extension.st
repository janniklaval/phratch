Extension { #name : #Morph }

{ #category : #'*Phratch-Extensions' }
Morph >> allowSubmorphExtraction [
	"Return true if this morph allows its submorphs to be extracted just by grabbing them."

	self isPartsBin ifTrue: [^ false].
	^ self dragNDropEnabled or: [self dragEnabled]

]

{ #category : #'*Phratch-Extensions' }
Morph >> backgroundColor [
	"Answer the background color for this morph, taken to be color of the first owner that is not transparent. Note that this does not take sibling morphs into account."

	| m |
	m := owner.
	[m notNil] whileTrue: [
		(m isKindOf: SystemWindow) ifTrue: [^ Color transparent].
		m color isTransparent ifFalse: [^ m color].
		m := m owner].

	^ m ifNil: [Color white] ifNotNil: [m color].

]

{ #category : #'*Phratch-Extensions' }
Morph >> centerInOwner [

	owner ifNil: [^ self].
	self left: owner left + ((owner width - self width) // 2).

]

{ #category : #'*Phratch-Extensions' }
Morph >> centering: aSymbol [

	self wrapCentering: aSymbol
]

{ #category : #'*Phratch-Extensions' }
Morph >> copyRecordingIn: dict [
	"Recursively copy this entire composite morph, recording the correspondence between old and new morphs in the given dictionary. This dictionary will be used to update intra-composite references in the copy. See updateReferencesUsing:.
	Note: This default implementation copies ONLY morphs in the submorph hierarchy. If a subclass stores morphs in instance variables that it wants to copy, then it should override this method to do so. The same goes for subclasses that contain other data that should be copied when the morph is duplicated."

	| new |
	new := self copy.
	dict at: self put: new.
	submorphs size > 0 ifTrue: [
		new privateSubmorphs:
			(submorphs collect: [:m |
				(m copyRecordingIn: dict) privateOwner: new])].

	self otherProperties ifNotNil: [new setProperties: self otherProperties copyAll].
	^ new

]

{ #category : #'*Phratch-Extensions' }
Morph >> fieldsVersion [

	^ 1

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
Morph >> initFieldsFrom: anObjStream version: classVersion [
	"Set my instance variables from the given object stream."

	self initFieldsNamed: #(
		bounds
		owner
		submorphs
		color
		flags
	) from: anObjStream.
	
	anObjStream nextField  "placeholder for properties".
	
	fullBounds := nil.

]

{ #category : #'*Phratch-Extensions' }
Morph >> initObsoleteFieldNamed: varName from: anObjStream [

	| flags |

	 varName = 'flags' 
		ifFalse: [^ super initObsoleteFieldNamed: varName from: anObjStream].
		
	flags := anObjStream nextField.
	self isHidden: (flags bitAnd: 1) ~= 0.
	self sticky: (flags bitAnd: 2) ~= 0.
	self lock: (flags bitAnd: 4) ~= 0.
	self isPartsDonor: (flags bitAnd: 8) ~= 0.
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
Morph >> isPartsDonor: aBoolean [

	^false
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

{ #category : #'*Phratch-Extensions' }
Morph >> ownerOrYourselfThatIsA: aClass [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isKindOf: aClass)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]

{ #category : #'*Phratch-Extensions' }
Morph >> patchAt: patchRect without: stopMorph andNothingAbove: stopThere [
	"Return a complete rendering of this patch of the display screen without drawing stopMorph and, if stopThere is true, without drawing any morph above it."

	| c morphsToDraw i |
	c := FormCanvas extent: patchRect extent depth: Display depth.
	c := c copyOrigin: patchRect topLeft negated clipRect: (0@0 extent: patchRect extent).

	(self bounds containsRect: patchRect) ifFalse: [
		"fill areas of patchRect outside my bounds with black"
		c form fillColor: Color black].
	(self bounds intersects: patchRect) ifFalse: [^ c form].  "entirely out of bounds"

	"draw all morphs intersecting the given patch, stopping at the given morph"
	self drawOn: c.
	morphsToDraw := submorphs reversed asOrderedCollection.
	(i := morphsToDraw indexOf: stopMorph) > 0 ifTrue: [
		stopThere
			ifTrue: [morphsToDraw := morphsToDraw copyFrom: 1 to: i - 1]  "stop at stopMorph"
			ifFalse: [morphsToDraw removeIndex: i]].  "skip stopMorph"
	morphsToDraw do: [:m | m fullDrawOn: c].
	^ c form
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
Morph >> storeFieldsOn: anObjStream [
	| flags |
	self storeFieldsNamed: #(#bounds #owner #submorphs #color) on: anObjStream.
	flags := 0.
	{(self isHidden).
	(self isSticky).
	(self isLocked)	". self isPartsDonor"}
		doWithIndex: [ :bool :i | 
			| maskInteger |
			maskInteger := 2 raisedTo: i - 1.
			flags := bool
				ifTrue: [ flags bitOr: maskInteger ]
				ifFalse: [ flags bitAnd: maskInteger bitInvert ] ].
	anObjStream putField: flags.
	anObjStream putField: nil	"placeholder for properties"
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
