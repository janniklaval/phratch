Extension { #name : #PhratchSpriteMorph }

{ #category : #'*PhratchSensing' }
PhratchSpriteMorph >> attribute: attr [
	"Answer the value of my variable or built-in attribute with the given name. Answer zero if I have no attribute or variable with the given name."

	| a |
	
	(attr isCommandBlockMorph)
		ifTrue: [^ attr fullCopy newScriptOwner: self; yourself] 		"self blockLike: attr body]".

	a := attr asString.
	(vars includesKey: a) ifTrue: [^ vars at: a].
	(self allLocalBlockIds includes: a) ifTrue: [ ^self lambda: a ].

	a := a localized.
	'x position' localized = a ifTrue: [^ self xpos].
	'y position' localized = a ifTrue: [^ self ypos].
	'direction' localized = a ifTrue: [^ self heading].
	'costume #' localized = a ifTrue: [^ self costumeIndex].
	'size' localized = a ifTrue: [^ self scale].
	"'volume' localized = a ifTrue: [^ self volume]."

	'name' localized = a ifTrue: [^ self objName].
	'prototype' localized = a ifTrue: [^ self prototype].
	'owner' localized = a ifTrue: [^ self ownerSprite].
	'parts' localized = a ifTrue: [^ PhratchListMorph on: self subsprites].

	^ 0

]

{ #category : #'*PhratchSensing' }
PhratchSpriteMorph >> bounceOffSprite: aName [ 
	"Set my direction to bounce off when touching the given sprite"
	<phratchItem: 'if touching $Sprite$ bounce' kind: #- category: 'motion' defaultValues: #() subCategory: #a5 special: #()>
    | sprite oldDir |
    sprite := self coerceSpriteArg: aName.
    (self touching: sprite)
        ifFalse: [^ self].
    oldDir := self heading.
    self pointTowards: sprite.
    self turnRight: self heading - oldDir + 180.
    [self touching: sprite]
        whileTrue: [self forward: 1]
]

{ #category : #'*PhratchSensing' }
PhratchSpriteMorph >> dist: t1 and: t2 [ 
	"Compute the distance between two points"
	<phratchItem: 'distance to x $Number$ y $Number$' kind: #ReporterBlockMorph category: 'sensing' defaultValues: #(0 0) subCategory: #sensor special: #()>
    ^ ((self xpos - t1) * (self xpos - t1) + ((self ypos - t2) * (self ypos - t2))) abs sqrt
]

{ #category : #'*PhratchSensing' }
PhratchSpriteMorph >> distanceTo: anObject [
	"Answer the distance to the given sprite."
	<phratchItem: 'distance to $Sprite$' kind: #ReporterBlockMorph category: 'sensing' defaultValues: #() subCategory: #sensor special: #()>
	| aSpriteOrSymbol |
	aSpriteOrSymbol := self coerceSpriteArg: anObject.

	aSpriteOrSymbol = #mouse ifTrue: [
		^ ((self mouseX @ self mouseY)  - self referencePosition) r].

	(aSpriteOrSymbol isPhratchSpriteMorph) ifFalse: [^ 10000].
	^ (aSpriteOrSymbol referencePosition - self referencePosition) r

]

{ #category : #'*PhratchSensing' }
PhratchSpriteMorph >> setMyName: aName [
	"Change my name to the given string"
	<phratchItem: 'set sprite name to $String$' kind: #- category: 'sensing' defaultValues: #() subCategory: #a1 special: #()>
	self objName: (aName asString).
]

{ #category : #'*PhratchSensing' }
PhratchSpriteMorph >> showQuestion: aString [
	"Show the given question prompt."

	self bubble: aString thinkFlag: false promptFlag: true.

]

{ #category : #'*PhratchSensing' }
PhratchSpriteMorph >> touching: anObject [
	"Answer true if any visible part of me touches a visible part of the given sprite."
	"Details: Currently uses the bounding box; should follow this up with comparison of visible pixels."
	<phratchItem: 'touching $Sprite$?' kind: #BooleanBlockMorph category: 'sensing' defaultValues: #() subCategory: #sensor special: #()>
	| aSpriteOrSymbol stage intersection f1 f2 map oldVis result |
	aSpriteOrSymbol := self coerceSpriteArg: anObject.

	aSpriteOrSymbol = #mouse ifTrue: [
		(stage := self ownerOrYourselfThatIsAPhratchStageMorph) ifNil: [^ false].
		result := self containsPoint: stage adjustedCursorPoint.
			result ifTrue: [^true].
	^(subsprites collect: [:sub | sub touching: anObject ]) includes: true ].

	aSpriteOrSymbol = #edge ifTrue: [^ self isOnEdge].

	(aSpriteOrSymbol isPhratchSpriteMorph) ifFalse: [^ false].

	(self isHidden not and: [aSpriteOrSymbol isHidden not]) ifFalse: [
		((subsprites collect: [:sub | sub touching: anObject ]) includes: true)
			ifFalse: [^ false]].

	intersection := self bounds intersect: aSpriteOrSymbol bounds.
	(intersection width > 0 and: [intersection height > 0]) ifFalse: [
		((subsprites collect: [:sub | sub touching: anObject ]) includes: true)
			ifFalse: [^ false]].

	f1 := Form extent: intersection extent depth: 2.
	f2 := f1 deepCopy.
	oldVis := self visibility. self visibility: 100.
	self drawOn: ((FormCanvas on: f1) copyOffset: intersection topLeft negated).
	self visibility: oldVis.

	oldVis := aSpriteOrSymbol visibility. aSpriteOrSymbol visibility: 100.	
	aSpriteOrSymbol drawOn: ((FormCanvas on: f2) copyOffset: intersection topLeft negated).
	aSpriteOrSymbol visibility: oldVis.

	map := Bitmap new: 4 withAll: 1.
	map at: 1 put: 0.  "transparent"
	f1 copyBits: f1 boundingBox from: f1 at: 0@0 colorMap: map.	"make mask with 0 where transparent, 1 elsewhere"
	f2 copyBits: f2 boundingBox from: f2 at: 0@0 colorMap: map.	"ditto for other sprite image"
	f2 displayOn: f1 at: 0@0 rule: Form and.						"and the masks together"

	result := (f1 tallyPixelValues at: 1) < (f1 width * f1 height).
	result ifTrue: [^true].
	^(subsprites collect: [:sub | sub touching: anObject ]) includes: true 			"are any pixels of the result non-zero?"

]
