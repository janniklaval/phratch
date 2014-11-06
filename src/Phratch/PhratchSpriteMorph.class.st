"
I represent a programmable Scratch object.

I have a costume, a bitmapped image that can be rotated, scaled, and image-filtered.

The raw Form before any rotation or scaling is stored in originalForm. rotatedForm is a cache of the rotated and scaled version of originalForm.

rotationStyle has three possible values:
	normal		continuous rotation with direction
	leftRight	for directions with x component < 0, flip the bitmap around the y-axis, otherwise no rotation
	none		don't rotate with direction

The leftRight style is useful for side-views of things such as cars, horses, etc.

"
Class {
	#name : #PhratchSpriteMorph,
	#superclass : #ScriptablePhratchMorph,
	#instVars : [
		'scalePoint',
		'rotationDegrees',
		'rotationStyle',
		'rotatedForm',
		'offsetWhenRotated',
		'draggable',
		'penDown',
		'penSize',
		'penColor',
		'penHue',
		'penShade',
		'subsprites',
		'ownerSprite',
		'offset',
		'virtualScale',
		'rotateWithOwner',
		'refPos',
		'prototype'
	],
	#category : #'Phratch-Objects'
}

{ #category : #nesting }
PhratchSpriteMorph >> addSubsprite: aSprite [
	"private"

	subsprites add: aSprite
	
]

{ #category : #nesting }
PhratchSpriteMorph >> allBounds [

	| l t r b |
	l := ((self allSubsprites add: self; yourself) collect: [:s | s fullBounds left]) min.
	t := ((self allSubsprites add: self; yourself) collect: [:s | s fullBounds top]) min.
	r := ((self allSubsprites add: self; yourself) collect: [:s | s fullBounds right]) max.
	b := ((self allSubsprites add: self; yourself) collect: [:s | s fullBounds bottom]) max.

	^l@t corner: r@b


]

{ #category : #nesting }
PhratchSpriteMorph >> allSubsprites [

	| all |
	all := subsprites copy.
	subsprites do: [: sub |
		all addAll: sub allSubsprites ].
	^ all
]

{ #category : #'sensing ops' }
PhratchSpriteMorph >> attributeNames [

	^ #('x position' 'y position' 'direction' 'costume #' 'size' 'volume') collect: [:s | s]

]

{ #category : #'looks ops' }
PhratchSpriteMorph >> bubble: obj thinkFlag: thinkFlag promptFlag: promptFlag [
	"Make a talk bubble with the given string."

	| s talkBubble objToShow |
	self sayNothing.
	objToShow := (obj respondsTo: #morphToShow)
		ifTrue: [ obj morphToShow ]
		ifFalse: [ obj ].
	obj isNumber
		ifTrue: [ 
			s := obj isInteger
				ifTrue: [ objToShow printString ]
				ifFalse: [ (objToShow asFloat roundTo: 0.01) printString ] ]
		ifFalse: [ 
			(objToShow isBoolean)
				ifTrue: [ s := objToShow asString localized ]
				ifFalse: [ 
					(objToShow isMorph)
						ifFalse: [ s := objToShow asString ] ] ].
	(s isString)
		ifTrue: [ 
			(s skipDelimiters: ' 	' startingAt: 1) > s size
				ifTrue: [ ^ self ].
			s size < 5
				ifTrue: [ s := s , ' ' ] ]
		ifFalse: [ 
			s := (objToShow respondsTo: #thumbnailImageForm)
				ifTrue: [ ImageMorph new form: objToShow thumbnailImageForm ]
				ifFalse: [ ImageMorph new form: objToShow imageForm ] ].
	talkBubble := PhratchTalkBubbleMorph new message: s.
	thinkFlag
		ifTrue: [ talkBubble beThoughtBubble: true ].
	promptFlag
		ifTrue: [ talkBubble bePrompt: true ].
	talkBubble
		lock;
		position: self position.
	self setProperty: #talkBubble toValue: talkBubble.
	self addMorphFront: talkBubble.
	self positionTalkBubble.
	"World displayWorldSafely."
	^ talkBubble
]

{ #category : #nesting }
PhratchSpriteMorph >> cacheRefPos [
	refPos := self referencePosition.
	self spread
]

{ #category : #'looks ops' }
PhratchSpriteMorph >> changeSizeBy: delta [
	"Change my size by the given delta."
	<phratchItem: 'change size by $Number$' kind: #- category: 'looks' defaultValues: #() subCategory: #a4 special: #()>
	self setSizeTo: (self virtualScale + delta).

]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> children [
	^ PhratchListMorph on: self instances
]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> choosePrototype [
	| stage choice |
	stage := self ownerOrYourselfThatIsAPhratchStageMorph.
	stage ifNil: [^ self].
	choice := stage userSelectSpriteDefault: prototype butNotAnyOf: {self. prototype}.
	choice ifNil: [^ self].
	choice = #null ifTrue: [
		choice := nil].
	self prototype: choice
]

{ #category : #'pen ops' }
PhratchSpriteMorph >> clearPenTrails [
	"Clear the pen trails layer."
	<phratchItem: 'clear pen trails' kind: #- category: 'pen' defaultValues: #() subCategory: #a5 special: #()>
	| m |
	(m := self ownerOrYourselfThatIsAPhratchStageMorph)
		ifNotNil: [m clearPenTrails].

]

{ #category : #'panther actions' }
PhratchSpriteMorph >> cloneMe [
	"Clone me without registering me in the environemnt"
	<phratchItem: 'clone me' kind: #ReporterBlockMorph category: 'control' defaultValues: #() subCategory: #self special: #()>
	| stage clone |
	(self ownerThatIsAOffscreenWorldMorph) ifNotNil: [
		stage := (self ownerThatIsAOffscreenWorldMorph) frame workPane.
		clone := (self fullCopy).
		stage addMorphFront: clone.]
	ifNil: [
	clone := self duplicateNoAttach.
	clone referencePosition: self referencePosition].
	clone isClone: true.
	clone eventReceived: (PhratchEvent new name: 'Phratch-CreationEvent' argument: 0)

]

{ #category : #'BYOB attributes' }
PhratchSpriteMorph >> comeToFront [
	"Put me on front of the display"
	<phratchItem: 'go to front' kind: #- category: 'looks' defaultValues: #() subCategory: #a7 special: #()>
	^super comeToFront
]

{ #category : #geometry }
PhratchSpriteMorph >> containsPoint: aPoint [

	^ (self bounds containsPoint: aPoint) and:
	  [(self rotatedForm isTransparentAt: aPoint - bounds origin) not]

]

{ #category : #nesting }
PhratchSpriteMorph >> copyForExport [
	"Answer a copy of me for exporting."
	"Note: Sprites are always exported in the context of an empty background."

	| objToExport |
	objToExport := PhratchStageMorph new clearMediaAndCostume.
	objToExport position: owner position.
	customBlocks ifNotNil: [
		customBlocks do: [:eachDef | 
			eachDef isGlobal ifTrue: [
				objToExport
					updateCustomBlockDefinitionId: eachDef id with: eachDef;
					updateLocalId: eachDef id withSpec: eachDef userSpec]]].
	objToExport addMorph: super copyForExport.
	^ objToExport

]

{ #category : #private }
PhratchSpriteMorph >> costumeChanged [

	costumeChangeMSecs := Time millisecondClockValue.
	filterPack ifNotNil: [filterPack clearFilterCaches].
	self layoutChanged.
	self keepOnScreen.

]

{ #category : #'panther actions' }
PhratchSpriteMorph >> deleteMe [
	"Delete me only if I am a clone"
	<phratchItem: 'delete me if I am a clone' kind: #- category: 'control' defaultValues: #() subCategory: #self special: #()>
	self isClone ifTrue: [self deleteSprite].
]

{ #category : #'motion ops' }
PhratchSpriteMorph >> directionMenu [
	"Provides a drop-down menu for setting the sprite direction."

	| menu |
	menu := MenuMorph new defaultTarget: self.
	#(	('right' 90)
		('left' -90)
		('up' 0)
		('down' 180)
	) do: [:pair |
		menu
			add: '(', pair second printString, ') ', pair first localized
			value: pair second].
	menu invokeModal.
	^ menu
]

{ #category : #accessing }
PhratchSpriteMorph >> draggable [

	draggable ifNil: [draggable := true].
	^ draggable

]

{ #category : #accessing }
PhratchSpriteMorph >> draggable: aBoolean [

	self undeleteAttribute: #isDraggable.
	self passiveSetDraggable: aBoolean

]

{ #category : #drawing }
PhratchSpriteMorph >> drawOn: aCanvas [
	"Draw myself if my visibility is > 0. If my visibility is 1, draw using the normal 'paint' mode. Otherwise, draw using 'alpha' resulting in a partially transparent rendering."

	| f alpha |
	f := self filteredForm.
	visibility < 100 ifTrue: [
		visibility > 0 ifTrue: [
			alpha := ((255.0 * visibility) / 100.0) truncated.
			aCanvas paintImage: f at: bounds origin sourceRect: f boundingBox alpha: alpha].
		^ self].

	f changed.
	aCanvas translucentImage: f at: bounds origin.

]

{ #category : #drawing }
PhratchSpriteMorph >> drawSubmorphsOn: aCanvas [
	"Display submorphs back to front, but do not draw and talk/think bubble submorphs."

	submorphs reverseDo: [:m |
		(m isPhratchTalkBubbleMorph) ifFalse: [
			aCanvas fullDrawMorph: m]].

]

{ #category : #drawing }
PhratchSpriteMorph >> drawTalkBubbleOn: aCanvas [
	"Draw and talk/think bubble submorphs."

	submorphs size = 0 ifTrue: [^ self].
	submorphs reverseDo: [:m |
		(m isPhratchTalkBubbleMorph) ifTrue: [
			aCanvas fullDrawMorph: m]].

]

{ #category : #nesting }
PhratchSpriteMorph >> feedbackMorph [

	|outline1 outline2 rf stage realPos|
	rf := self rotatedForm.
	outline1 := Form extent: (rf extent + (4@4)) depth: 8.
	outline2 := Form extent: (rf extent + (6@6)) depth: 8.

	(WarpBlt toForm: outline1)
		sourceForm: rf;
		cellSize: 2; 
		combinationRule: Form over;
		copyQuad: rf boundingBox innerCorners toRect: (outline1 boundingBox insetBy: 2).

	outline1 := outline1
		outlineWidth: 2
		color: (Color yellow mixed: 0.5 with: Color white)
		depth: 8.

	(WarpBlt toForm: outline2)
		sourceForm: rf;
		cellSize: 2; 
		combinationRule: Form over;
		copyQuad: rf boundingBox innerCorners toRect: (outline2 boundingBox insetBy: 3).

	outline2 := outline2
		outlineWidth: 3
		color: ("Color gray "Color yellow mixed: 0.2 with: Color white)
		depth: 8.

	(WarpBlt toForm: outline2)
		sourceForm: outline1;
		cellSize: 2; 
		combinationRule: Form paint;
		copyQuad: outline1 boundingBox innerCorners toRect: (outline2 boundingBox insetBy: 3).

	stage := self ownerOrYourselfThatIsAPhratchStageMorph.
	(stage notNil and: [stage isQuarterSize]) ifTrue: [
		outline2 := outline2 magnifyBy: 0.5.
		realPos := stage position + (self position - stage position / 2).
		^ImageMorph new form:  outline2;
			position: realPos - (3 @ 3);
			yourself ].
		

	^ImageMorph new form:  outline2;
		position: self position - (6 @ 6);
		yourself


]

{ #category : #nesting }
PhratchSpriteMorph >> follow [
	offset ifNil: [
		offset := self referencePosition - ownerSprite referencePosition].
	self spread
]

{ #category : #nesting }
PhratchSpriteMorph >> followNow [
	self step.
	self spread.

]

{ #category : #private }
PhratchSpriteMorph >> generateRotatedForm [
	"Compute my rotatedForm and offsetWhenRotated."

	"headed left; use flipped"

	| adjustedAngle srcForm smoothPix pair |
	adjustedAngle := rotationStyle = #normal
		ifTrue: [ self rotationDegrees ]
		ifFalse: [ 0.0 ].	"smooth rotation"	"leftRight or none"
	srcForm := self costumeForm.
	srcForm width = 1 & (srcForm height = 1)
		ifTrue: [ adjustedAngle := 0.0 ].	"don't rotate a 1x1 costume"
	((adjustedAngle closeTo: 0.0) and: [ 1.0 @ 1.0 = scalePoint ])
		ifTrue: [ 
			"no rotation or scaling; use original"
			rotatedForm := srcForm.
			offsetWhenRotated := costume rotationCenter ]
		ifFalse: [ 
			"generated rotated and/or scaled form"
			(adjustedAngle rounded \\ 90 = 0 and: [ 1.0 @ 1.0 = scalePoint ])
				ifTrue: [ ^ self rotateByFlipping ].
			smoothPix := (scalePoint x < 1.0 or: [ scalePoint y < 1.0 ])
				ifTrue: [ 2 ]
				ifFalse: [ 1 ].
			pair := WarpBlt
				rotatePhratch: srcForm
				degrees: adjustedAngle negated
				center: costume rotationCenter
				scaleBy: scalePoint
				smoothing: smoothPix.
			rotatedForm := pair first.
			offsetWhenRotated := (costume rotationCenter + pair last) rounded ].
	(rotationStyle = #leftRight and: [ self rotationDegrees > 90.0 and: [ self rotationDegrees < 270.0 ] ])
		ifFalse: [ ^ self ].
	rotatedForm := rotatedForm flipBy: #horizontal centerAt: 0 @ 0.
	offsetWhenRotated := (rotatedForm width - offsetWhenRotated x - 1) @ offsetWhenRotated y
]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> getIsDraggable [

	| att |
	att := #isDraggable.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^self draggable
]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> getRotationStyle [
	"Set my rotation style to #normal, #leftRight, or #none. Styles mean:
		#normal	-- smooth 360 degree rotation
		#leftRight	-- flip about the vertical axis
		#none		-- do not rotate"

	| att |
	att := #rotationStyle.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	#none = rotationStyle ifTrue: [^ 0].
	#normal = rotationStyle ifTrue: [^ 1].
	#leftRight = rotationStyle ifTrue: [^ 2].

	^ 1
]

{ #category : #'motion ops' }
PhratchSpriteMorph >> gotoX: x y: y [
	"Go to the given position."
	<phratchItem: 'go to x:$Number$ y:$Number$' kind: #- category: 'motion' defaultValues: #(0 0) subCategory: #a3 special: #()>
	self xpos: x; ypos: y

]

{ #category : #private }
PhratchSpriteMorph >> grabFormFromScreen [
	"Grab a rectangular portion of the screen selected by the user and trim white pixels from around edges (this assumes the stage is white). If the resulting form is empty, return nil."

	| f f2 |
	f := Form fromUser.
	f2 := (Form extent: (f extent + 2) depth: f depth) fillWhite.
	f displayOn: f2 at: 1@1 rule: Form over.
	f2 shapeFill: Color transparent interiorPoint: 0@0.
	f := f2 trimBordersOfColor: Color transparent.
	(f width = 0) | (f height = 0) ifTrue: [^ nil].

	^ f

]

{ #category : #'right button menu' }
PhratchSpriteMorph >> grabFromScreen [
	"Set my form to be a rectangular portion of the screen."

	| f el |
	(f := self grabFormFromScreen) ifNil: [^ self].
	el := ImageMedia new form: f.
	el mediaName: (self unusedMediaNameFromBaseName: 'costume1').
	media addLast: el.
	self lookLike: el mediaName.
	self updateMediaCategory.

	self undeleteAttribute: #costumes.
	self propagateCostumes

]

{ #category : #nesting }
PhratchSpriteMorph >> hasSubsprites [
	^subsprites size > 0
]

{ #category : #accessing }
PhratchSpriteMorph >> heading [
	"Answer my heading in degrees, a number between -180 and 180."
	<phratchItem: 'direction' kind: #ReporterWatcherBlockMorph category: 'motion' defaultValues: #() subCategory: #a7 special: #()>
	| result att |
	att := #heading.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	result := self rotationDegrees + 90.
	result > 180 ifTrue: [result := result - 360].
	^ result


]

{ #category : #accessing }
PhratchSpriteMorph >> heading: headingDegrees [
	"Set my heading in degrees, where 0 degrees is facing up and the heading increases clockwise."
	"Note: Our convention is that artwork is drawing facing to the right. Thus, a heading of 90 corresponds to a rotationDegrees of zero."
	<phratchItem: 'point in direction $Directions$' kind: #- category: 'motion' defaultValues: #(90) subCategory: #a2 special: #()>
	self turn: headingDegrees asNumberNoError - self heading

]

{ #category : #nesting }
PhratchSpriteMorph >> holdSubsprites [
	"private"

	subsprites do: [:each | each follow].
]

{ #category : #initialization }
PhratchSpriteMorph >> initialize [

	super initialize.
	subsprites := OrderedCollection new.
	scalePoint := 1.0@1.0.
	rotationDegrees := 0.0.				"clockwise angle of rotation"
	rotationStyle := #normal.				"#normal, #leftRight, or #none"
	rotatedForm := self costumeForm.		"cached rotated/scaled copy of costume form"
	offsetWhenRotated := 0@0.			"offset for rotated form needed to keep rotation center invariant"
	draggable := false.
	penDown := false.
	penSize := 1.
	penHue := 133.3.
	penShade := 50.
	self penColor: Color blue.
	self extent: rotatedForm extent.

]

{ #category : #nesting }
PhratchSpriteMorph >> initializeNodes [
	ownerSprite := nil.
	subsprites := OrderedCollection new.
]

{ #category : #'motion ops' }
PhratchSpriteMorph >> isClone [
	"Return true if I am a clone"
	<phratchItem: 'Am I a clone?' kind: #BooleanBlockMorph category: 'control' defaultValues: #() subCategory: #self special: #()>
	^ isClone

]

{ #category : #accessing }
PhratchSpriteMorph >> isClone: aBoolean [

	isClone := aBoolean.

]

{ #category : #'panther actions' }
PhratchSpriteMorph >> isDraggable [
	"Return true if I am draggable"
	<phratchItem: 'draggable?' kind: #BooleanWatcherBlockMorph category: 'motion' defaultValues: #() subCategory: #a8 special: #()>
	^ draggable.
]

{ #category : #nesting }
PhratchSpriteMorph >> isNested [
	^self hasSubsprites or: [ownerSprite notNil]
]

{ #category : #'motion ops' }
PhratchSpriteMorph >> isOnEdge [
	"Answer true if I'm touching the edge of my owner."

	| result |
	owner ifNil: [^ false].
	result := (owner bounds containsRect: self bounds) not.
	result ifTrue: [^true]. 
	^(subsprites collect: [:sub | sub isOnEdge ]) includes: true


]

{ #category : #nesting }
PhratchSpriteMorph >> isOrContains: aSprite [

	self == aSprite
		ifTrue: [^ true].
	^ (subsprites collect: [:sub |
		sub isOrContains: aSprite ])
			includes: true
]

{ #category : #accessing }
PhratchSpriteMorph >> isPhratchSpriteMorph [

	^ true
]

{ #category : #accessing }
PhratchSpriteMorph >> isSprite [

	^ true

]

{ #category : #'looks ops' }
PhratchSpriteMorph >> isVisible [
	"Return true if I am visible."
	<phratchItem: 'visible?' kind: #BooleanWatcherBlockMorph category: 'looks' defaultValues: #() subCategory: #a6 special: #()>
	^super isVisible

]

{ #category : #'event handling' }
PhratchSpriteMorph >> justDroppedInto: newOwner event: evt [
	
	self releaseSubsprites.
	super justDroppedInto: newOwner event: evt.
	(newOwner isPhratchStageMorph) ifTrue: [self positionTalkBubble].

	self xpos: self xpos.
	self ypos: self ypos 


]

{ #category : #nesting }
PhratchSpriteMorph >> keepOnScreen [
	"Make me stick to edge of my owner."

	| edgeBox allBounds xpos ypos |

	self class keepOnStage ifFalse: [^self].

	ownerSprite ifNotNil: [^self].
	owner ifNil: [^ self].
	(owner isPhratchStageMorph) ifFalse: [^ self].
	
	allBounds := self allBounds.
	(owner bounds containsRect: allBounds) ifTrue: [^ self].  "entirely on screen"
	edgeBox := owner bounds insetBy: (18 min: (allBounds width min: allBounds height) // 2).
	(allBounds intersects: edgeBox) ifTrue: [^ self].

	xpos:= self xpos.
	ypos := self ypos.

	self holdSubsprites.
	allBounds right < edgeBox left ifTrue: [
		self right: edgeBox left - (allBounds right - self right); followNow].
	allBounds left > edgeBox right ifTrue: [
		self left: edgeBox right + (self left - allBounds left); followNow].
	allBounds bottom < edgeBox top ifTrue: [
		self bottom: edgeBox top - (allBounds bottom - self bottom); followNow].
	allBounds top > edgeBox bottom ifTrue: [
		self top: edgeBox bottom + (self top - allBounds top); followNow].
	self releaseSubsprites.

	(xpos closeTo: self xpos) ifFalse: [self passiveXpos: self xpos].
	(ypos closeTo: self ypos) ifFalse: [self passiveYpos: self ypos]


]

{ #category : #private }
PhratchSpriteMorph >> layoutChanged [
	"Update rotatedForm and offsetWhenRotated and compute new bounds."

	| refPoint stage |
	refPoint := bounds origin + offsetWhenRotated.
	(rotationStyle == #none and: [scalePoint = (1.0@1.0)])
		ifTrue: [  "zero rotation and scale; use original Form"
			rotatedForm := self costumeForm. 	
			offsetWhenRotated := costume rotationCenter]
		ifFalse: [self generateRotatedForm].	"compute the new rotatedForm and offsetWhenRotated"

	bounds := (refPoint - offsetWhenRotated) extent: rotatedForm extent.
	super layoutChanged.
	
	(stage := self ownerOrYourselfThatIsAPhratchStageMorph) ifNil: [^ self].
	stage invalidRect: stage bounds.
	
	self changed.

]

{ #category : #'looks ops' }
PhratchSpriteMorph >> lookLike: costumeName [
	"Change my Costume"
	<phratchItem: 'switch to costume $Costumes$' kind: #- category: 'looks' defaultValues: #() subCategory: #a1 special: #()>
	self undeleteAttribute: #costumeIndex.
	self passiveLookLike: costumeName.
	costumeName isNumber ifFalse: [
		self lookLike: self costumeIndex ].
]

{ #category : #accessing }
PhratchSpriteMorph >> maxXStage [
	"Answer true if any of my non-transparent pixels touch pixels of the given color in the world."
	<phratchItem: 'stage maximum x' kind: #ReporterBlockMorph category: 'sensing' defaultValues: #() subCategory: #sensorStage special: #()>
	
	^ self ownerThatIsAPhratchStageMorph extent x // 2
]

{ #category : #accessing }
PhratchSpriteMorph >> maxYStage [
	"Answer true if any of my non-transparent pixels touch pixels of the given color in the world."
	<phratchItem: 'stage maximum y' kind: #ReporterBlockMorph category: 'sensing' defaultValues: #() subCategory: #sensorStage special: #()>
	
	^ self ownerThatIsAPhratchStageMorph extent y // 2
]

{ #category : #accessing }
PhratchSpriteMorph >> minXStage [
	"Answer true if any of my non-transparent pixels touch pixels of the given color in the world."
	<phratchItem: 'stage minimum x' kind: #ReporterBlockMorph category: 'sensing' defaultValues: #() subCategory: #sensorStage special: #()>
	
	^ (self ownerThatIsAPhratchStageMorph extent x // 2) * (-1)
]

{ #category : #accessing }
PhratchSpriteMorph >> minYStage [
	"Answer true if any of my non-transparent pixels touch pixels of the given color in the world."
	<phratchItem: 'stage minimum y' kind: #ReporterBlockMorph category: 'sensing' defaultValues: #() subCategory: #sensorStage special: #()>
	
	^ (self ownerThatIsAPhratchStageMorph extent y // 2) * (-1)
]

{ #category : #'looks ops' }
PhratchSpriteMorph >> multiplySizeBy: factor [
	"Used by the magnifying glass tool. Multiply my scale by the given factor."

	self setSizeTo: 100.0 * (self scalePoint x max: self scalePoint y) * factor.

]

{ #category : #nesting }
PhratchSpriteMorph >> ownerSprite [

	| att |
	att := #anchor.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ownerSprite
]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> parts [
	^ PhratchListMorph on: self subsprites
]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> passiveLookLike: costumeName [

	super lookLike: costumeName.
	self positionTalkBubble.

	self propagate: #costumeIndex


]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> passivePenColor: aColor [
	"Set my pen color."

	| b |
	penColor := aColor.
	penHue := penColor hue * 200.0 / 360.0.
	b := penColor brightness.
	penShade := (b closeTo: 1.0)
		ifTrue: [ 50.0 + (50.0 * (1.0 - penColor saturation)) ]
		ifFalse: [ 50.0 * b ].
	self propagate: #penColor
]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> passiveRotationStyle: aNumber [
	"Set my rotation style to #normal, #leftRight, or #none. Styles mean:
		#normal	-- smooth 360 degree rotation
		#leftRight	-- flip about the vertical axis
		#none		-- do not rotate"

	| se |
	rotationStyle := #(none normal leftRight) at: aNumber asNumberNoError rounded + 1 ifAbsent: [#normal].
	self costumeChanged.
	self positionTalkBubble.
	se := blocksBin ownerOrYourselfThatIsAPhratchScriptEditorMorph.
	se ifNil: [^ self].
	se updateRotationButtonHighlight.
	se animateRotationStyle.

	self propagate: #rotationStyle

]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> passiveSetDraggable: aBoolean [

	| se |
	draggable := aBoolean.
	se := blocksBin ownerOrYourselfThatIsAPhratchScriptEditorMorph.
	se ifNil: [^ self].
	se updateLockButton

]

{ #category : #nesting }
PhratchSpriteMorph >> passiveSetRotateWithOwner: aBoolean [
	rotateWithOwner := aBoolean.
	self costumeChanged

]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> passiveSetSizeTo: percent [
	"Set my size to the given percent of the original size. Limit the range to avoid accidentally 
	making me invisibly tiny or really huge. Retain my aspect ratio (i.e., my stretch)."

	| pc origExtent minExtent maxExtent minScale maxScale curDist oldPercent unit newDist factor|
	pc := percent asNumberNoError.
	oldPercent := self virtualScale.
	oldPercent = 0 ifTrue: [oldPercent := 1/100000].

	origExtent := self costumeForm extent asFloatPoint.
	minExtent := (origExtent min: 5@5) asFloatPoint.
	maxExtent := PhratchFrameMorph workpaneExtent asFloatPoint * 1.5.
	minScale := ((minExtent x / origExtent x) max: (minExtent y / origExtent y)) min: 1.0.
	maxScale := (maxExtent x / origExtent x) min: (maxExtent y / origExtent y).

	virtualScale := pc.
	self scalePoint: ((pc / 100.0) within: minScale and: maxScale) asPoint.

	subsprites do: [:sub |
			curDist := sub referencePosition - self referencePosition.
			unit := curDist / oldPercent.
			newDist := unit * percent.
			sub holdSubsprites.
			sub referencePosition: self referencePosition + newDist.
			sub releaseSubsprites.
			factor := sub virtualScale / oldPercent.
			sub changeSizeBy: (self virtualScale * factor) - sub virtualScale].

	self propagate: #size


]

{ #category : #nesting }
PhratchSpriteMorph >> passiveStickTo: aSprite [

	(aSprite isPhratchSpriteMorph) ifFalse: [
		^ self unhinge].

	(self isOrContains: aSprite) ifTrue: [^self].
	ownerSprite ifNotNil: [
		ownerSprite removeSubsprite: self].
	ownerSprite := aSprite.
	aSprite addSubsprite: self.
	rotateWithOwner := true.

	LibraryItemMorph allInstances do: [:each| each updateThumbnail]. "this needs to be changed to something better -jens"

	self propagate: #anchor
]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> passiveTurn: degrees [
	| newPos |
	"Turn clockwise the given number of degrees."

	self rotationDegrees: self rotationDegrees + degrees.
	subsprites do: [:sub |
		newPos := sub referencePosition rotateBy: degrees degreesToRadians about: self referencePosition.
		sub gotoX: newPos x y: newPos y ].

	self rotateWithOwner
		ifTrue: [ self spreadToFollowers ].

	self propagate: #heading


]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> passiveXpos: aNumber [ 

	| num newX |
	num := aNumber asNumberNoError.
	newX := (num isInteger ifTrue: [num] ifFalse: [num asFloat] ) .
	self holdSubsprites.
	self referencePosition: newX @ self ypos.
	self releaseSubsprites.

	self propagate: #xPosition


]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> passiveYpos: aNumber [

	| num newY |
	num := aNumber asNumberNoError.
	newY := num isInteger ifTrue: [num] ifFalse: [num asFloat].
	self holdSubsprites.
	self referencePosition: (self xpos @ newY).
	self releaseSubsprites.

	self propagate: #yPosition


]

{ #category : #'pen ops' }
PhratchSpriteMorph >> penColor [
	"Return my pen color"
	<phratchItem: 'pen color' kind: #ReporterWatcherBlockMorph category: 'pen' defaultValues: #() subCategory: #a1 special: #()>
	^ penColor

]

{ #category : #'pen ops' }
PhratchSpriteMorph >> penColor: aColor [
	"Set my pen color."
	<phratchItem: 'set pen color to $Color$' kind: #- category: 'pen' defaultValues: #() subCategory: #a3 special: #()>
	self undeleteAttribute: #penColor.
	self passivePenColor: aColor
]

{ #category : #'pen ops' }
PhratchSpriteMorph >> penDown [

	| att |
	att := #penDown.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ penDown

]

{ #category : #'pen ops' }
PhratchSpriteMorph >> penPosition [

	^ self referencePosition

]

{ #category : #'pen ops' }
PhratchSpriteMorph >> penSize [
	"Return my pen size"
	<phratchItem: 'pen size' kind: #ReporterWatcherBlockMorph category: 'pen' defaultValues: #() subCategory: #a1 special: #()>
	| att |
	att := #penSize.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ penSize

]

{ #category : #private }
PhratchSpriteMorph >> positionTalkBubble [

	| bubble stage stageBounds y f r yInset strip x |
	(bubble := self valueOfProperty: #talkBubble) ifNil: [^ self].
	(stage := self ownerOrYourselfThatIsAPhratchStageMorph) ifNil: [^ self].
	stageBounds := stage bounds.

	f := self imageForm.
	r := f rectangleEnclosingPixelsNotOfColor: Color transparent.
	yInset := 0.
	((r area = 0) or: [r height < 10])
		ifTrue: [r := f boundingBox]
		ifFalse: [
			yInset := (r top max: 0) min: (r height - 10).
			strip := f copy: ((0@r top) extent: (f width@(10 min: f height))).
			r := strip rectangleEnclosingPixelsNotOfColor: Color transparent].

	x := self right - ((f width - r right) min: f width // 2).
	bubble pointLeft: true.
	((x + bubble width) <= stageBounds right) ifFalse: [
		x := (self left - bubble width) + (r left min: (f width // 2)).
		bubble pointLeft: false].

	y := (self top + yInset + 10 - bubble height) within: stageBounds top and: (stageBounds bottom - bubble height).
	bubble position: x@y.
	self layoutChanged.

]

{ #category : #scripts }
PhratchSpriteMorph >> prepareForExport [
	super prepareForExport.

	self subsprites do: [:sub |
			sub prepareForExport ]

]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> prototype [
	^ prototype
]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> prototype: aSprite [

	| sFrame |
	prototype := aSprite.
	prototype = false ifTrue: [
		prototype := nil].
	self
		undeleteAllAttributes;
		undeleteAllVariables;
		undeleteAllBlocks.
	(sFrame := self ownerOrYourselfThatIsAPhratchFrameMorph) ifNil: [^ self].
	sFrame viewerPane categoryChanged: sFrame viewerPane currentCategory.
	self inheritCostumesNow.
	self inheritSoundsNow
]

{ #category : #nesting }
PhratchSpriteMorph >> realScale [
	^(100 * scalePoint x)
]

{ #category : #'looks ops' }
PhratchSpriteMorph >> recordScene: sceneName [

	| state |
	self isHidden ifTrue: [
		sceneStates removeKey: sceneName ifAbsent: [].
		^ self ].

	state := Dictionary new.
	state at: #referencePosition put: self referencePosition.
	state at: #size put: self scale.
	state at: #heading put: self heading.
	sceneStates at: sceneName put: state.

]

{ #category : #accessing }
PhratchSpriteMorph >> referencePosition [

	| p s |
	p := (bounds origin + offsetWhenRotated) - PhratchOrigin.

	"adjust when in Hand in quartersize mode:"
	((owner isHandMorph) and:
	 [((s := owner formerOwner) isPhratchStageMorph) and:
	 [s isQuarterSize]]) ifTrue: [
		"Note: this is not quite right when rotation center is offset"
		p := (p * 2) + (240@180)].

	^ p x @ p y negated

]

{ #category : #accessing }
PhratchSpriteMorph >> referencePosition: aPoint [
	"Set my reference position. Avoid infinite or NaN coordinates. Keep on screen."

	| newX newY p |
	newX := aPoint x.
	newX isNaN ifTrue: [newX := 0].
	newX isInfinite ifTrue: [newX := newX sign * 10000].
	newY := aPoint y.
	newY isNaN ifTrue: [newY := 0].
	newY isInfinite ifTrue: [newY := newY sign * 10000].

	p := newX @ newY negated.
	self position: PhratchOrigin + (p - offsetWhenRotated).
	self keepOnScreen.

]

{ #category : #nesting }
PhratchSpriteMorph >> releaseSubsprites [

	self followNow.
	subsprites do: [:each | each stopFollowing].
]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> removeLocalBlockDefinitions [
	customBlocks ifNil: [^ self].
	customBlocks := customBlocks select: [:def |
		def isGlobal]
]

{ #category : #nesting }
PhratchSpriteMorph >> removeSubsprite: aSprite [
	"private"

	subsprites remove: aSprite ifAbsent: [].
	self makeVisible
]

{ #category : #'handle ops' }
PhratchSpriteMorph >> resizeHandle [

	SpriteHandleMorph resize: self
]

{ #category : #'right button menu' }
PhratchSpriteMorph >> rightButtonMenu [
	"Present the right button menu."

	| menu |
	menu := MenuMorph new defaultTarget: self.
	menu add: 'grab screen region for new costume' localized selector: #grabFromScreen.
	menu add: 'export this sprite' localized selector: #exportObject.
	
	menu addLine.
	menu add: 'duplicate' localized selector: #spawn.
	menu add: 'delete' localized selector: #undoableDeleteSprite.
	menu addLine.
	menu add: 'resize this sprite' localized selector: #resizeHandle.
	menu add: 'rotate this sprite' localized selector: #rotateHandle.
	self isNested
		ifTrue: [ menu addLine ].
	self hasSubsprites
		ifTrue: [ menu add: 'detach all subsprites' localized selector: #unhingeAll ].
	ownerSprite ifNotNil: [ menu add: 'detach from '  localized, self ownerSprite objName selector: #unhinge ].
	menu
		localize;
		invokeModal
]

{ #category : #private }
PhratchSpriteMorph >> rotateByFlipping [
	"Compute my rotatedForm and offsetWhenRotated for unscaled rotation by a multiple of 90 degrees."

	| a center srcForm |
	a := self rotationDegrees rounded \\ 360.
	a < 0
		ifTrue: [ a := a + 360 ].
	srcForm := self costumeForm.
	center := costume rotationCenter.
	0 = a
		ifTrue: [ 
			rotatedForm := srcForm.
			offsetWhenRotated := center ].
	90 = a
		ifTrue: [ 
			rotatedForm := srcForm rotateBy: #right centerAt: 0 @ 0.
			offsetWhenRotated := (srcForm height - 1 - center y) @ center x ].
	180 = a
		ifTrue: [ 
			rotatedForm := srcForm rotateBy: #pi centerAt: 0 @ 0.
			offsetWhenRotated := srcForm extent - 1 - center ].
	270 = a
		ifFalse: [ ^ self ].
	rotatedForm := srcForm rotateBy: #left centerAt: 0 @ 0.
	offsetWhenRotated := center y @ (srcForm width - 1 - center x)
]

{ #category : #'handle ops' }
PhratchSpriteMorph >> rotateHandle [

	SpriteHandleMorph rotate: self
]

{ #category : #nesting }
PhratchSpriteMorph >> rotateWithOwner [

	| att |
	att := #rotateWithOwner.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^rotateWithOwner ifNil: [
		rotateWithOwner := true ]
]

{ #category : #nesting }
PhratchSpriteMorph >> rotateWithOwner: aBoolean [

	self undeleteAttribute: #rotateWithOwner.
	self passiveSetRotateWithOwner: aBoolean

]

{ #category : #accessing }
PhratchSpriteMorph >> rotatedForm [
	"Answer my rotated and scaled form."

	rotatedForm ifNil: [self costumeChanged].
	^ rotatedForm

]

{ #category : #accessing }
PhratchSpriteMorph >> rotationCenter [

	^ costume rotationCenter

]

{ #category : #accessing }
PhratchSpriteMorph >> rotationDegrees [

	^ rotationDegrees

]

{ #category : #accessing }
PhratchSpriteMorph >> rotationDegrees: newRotationDegrees [
	rotationDegrees ~= newRotationDegrees
		ifFalse: [ ^ self ].
	rotationDegrees := newRotationDegrees asFloat \\ 360.0.
	rotationStyle = #none
		ifTrue: [ ^ self ].
	self positionTalkBubble.
	self costumeChanged
]

{ #category : #private }
PhratchSpriteMorph >> rotationDegrees: newRotationDegrees scalePoint: newScalePoint [
	(newRotationDegrees ~= self rotationDegrees or: [ scalePoint ~= newScalePoint ])
		ifFalse: [ ^ self ].
	rotationDegrees := newRotationDegrees asFloat \\ 360.0.
	scalePoint := newScalePoint.
	self costumeChanged
]

{ #category : #accessing }
PhratchSpriteMorph >> rotationStyle [
"Return my rotation style"
	<phratchItem: 'rotation style' kind: #ReporterWatcherBlockMorph category: 'motion' defaultValues: #() subCategory: #a6 special: #()>
    ^ rotationStyle
]

{ #category : #accessing }
PhratchSpriteMorph >> rotationStyle: aSymbol [
	"Set my rotation style to #normal, #leftRight, or #none. Styles mean:
		#normal	-- smooth 360 degree rotation
		#leftRight	-- flip about the vertical axis
		#none		-- do not rotate"
	<phratchItem: 'set rotation style to $Rotation$' kind: #- category: 'motion' defaultValues: #() subCategory: #a6 special: #()>
	rotationStyle := aSymbol.
	self costumeChanged.
	self positionTalkBubble.

]

{ #category : #'motion ops' }
PhratchSpriteMorph >> rotationStyleChanger [
    ^ #('normal' 'leftRight' 'none' )
]

{ #category : #'looks ops' }
PhratchSpriteMorph >> sayNothing [
	"Delete my talk bubble if I have one."

	| talkBubble |
	(talkBubble := self valueOfProperty: #talkBubble) ifNil: [^ self].
	talkBubble delete.
	self setProperty: #talkBubble toValue: nil.

]

{ #category : #accessing }
PhratchSpriteMorph >> scale [
	"Return the size percentage of the costume"
	<phratchItem: 'size' kind: #ReporterWatcherBlockMorph category: 'looks' defaultValues: #() subCategory: #a4 special: #()>
	| att |
	att := #size.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^self virtualScale rounded
]

{ #category : #accessing }
PhratchSpriteMorph >> scalePoint [

	^ scalePoint

]

{ #category : #accessing }
PhratchSpriteMorph >> scalePoint: aPoint [

	scalePoint := aPoint.
	self costumeChanged.
	self positionTalkBubble.

]

{ #category : #'looks ops' }
PhratchSpriteMorph >> scenes [

	^ sceneStates keys

]

{ #category : #accessing }
PhratchSpriteMorph >> select: string where: aBoolean [
	"Return my y position"
	<phratchItem: 'select $String$ where $Boolean$' kind: #ReporterWatcherBlockMorph category: 'motion' defaultValues: #() subCategory: #xxx special: #()>
	^ string

]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> setRotationStyle: aNumber [
	"Set my rotation style to #normal, #leftRight, or #none. Styles mean:
		#normal	-- smooth 360 degree rotation
		#leftRight	-- flip about the vertical axis
		#none		-- do not rotate"

	self undeleteAttribute: #rotationStyle.
	self passiveRotationStyle: aNumber
]

{ #category : #'looks ops' }
PhratchSpriteMorph >> setSizeTo: percent [
	"Set my size to the given percent of the original size. Limit the range to avoid accidentally making me invisibly tiny or really huge. Retain my aspect ratio (i.e., my stretch)."
	<phratchItem: 'set size to $Number$%' kind: #- category: 'looks' defaultValues: #(100) subCategory: #a4 special: #()>
	self undeleteAttribute: #size.
	self passiveSetSizeTo: percent

]

{ #category : #nesting }
PhratchSpriteMorph >> slideBackToFormerSituation: evt [

	self holdSubsprites.
	super slideBackToFormerSituation: evt.
	self releaseSubsprites.

	self xpos: self xpos.
	self ypos: self ypos 


]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> spawn [
	"Duplicate me: My duplication is registered in the environment"
	<phratchItem: 'duplicate' kind: #ReporterBlockMorph category: 'control' defaultValues: #() subCategory: #self special: #()>
	| stage child |
"
	(frame := self ownerOrYourselfThatIsAPhratchFrameMorph) ifNil: [^ nil].
"
	stage := self ownerOrYourselfThatIsAPhratchStageMorph.
	stage ifNil: [^ self].
	child := self fullCopy.
	child blocksBin allMorphsDo: [:m |
		(m isBlockMorph) ifTrue: [m stop]].
	child unhinge; unhingeAll; initializeNodes.
	child prototype: self.
	child initializeVarsAndLists.
	child removeLocalBlockDefinitions.
	"frame workPane" stage addMorphFront: child.
	stage sprites addLast: child.
	child deleteAttributes: self deletedAttributes.
	child deleteAttribute: #costumes.
	(Smalltalk at: #PhratchCategorySound ifPresent:[child deleteAttribute: #sounds]).

	^ child	
]

{ #category : #nesting }
PhratchSpriteMorph >> spread [
	"private - apply the method calling me to all subsprites"

	| sel args |
	subsprites isEmpty ifTrue: [^self].
	sel := thisContext sender method selector.
	args := OrderedCollection new.
	1 to: thisContext sender method numArgs do: [:idx |
		args add: (thisContext sender tempAt: idx) ].
	subsprites do: [:eachPart |
		args isEmpty
			ifTrue: [ eachPart perform: sel]
			ifFalse: [ eachPart perform: sel withArguments: args asArray]]
]

{ #category : #nesting }
PhratchSpriteMorph >> spreadToFollowers [
	"private - apply the method calling me to all subsprites who follow my rotation"

	| followers sel args |
	subsprites isEmpty ifTrue: [^self].
	followers := subsprites select: [:each |
		each rotateWithOwner ].
	followers isEmpty ifTrue: [ ^self ].
	sel := thisContext sender method selector.
	args := OrderedCollection new.
	1 to: thisContext sender method numArgs do: [:idx |
		args add: (thisContext sender tempAt: idx) ].
	followers do: [:eachPart |
		args isEmpty
			ifTrue: [ eachPart perform: sel]
			ifFalse: [ eachPart perform: sel withArguments: args asArray]]
]

{ #category : #'event handling' }
PhratchSpriteMorph >> startDrag: evt [
	"This is a drag gesture; pick me up."

	self holdSubsprites.
	super startDrag: evt.

]

{ #category : #stepping }
PhratchSpriteMorph >> step [

	offset notNil & ownerSprite notNil ifTrue: [
		self referencePosition: ownerSprite referencePosition + offset ].
	super step.

]

{ #category : #nesting }
PhratchSpriteMorph >> stickTo: aSprite [

	self undeleteAttribute: #anchor.
	self passiveStickTo: aSprite
]

{ #category : #nesting }
PhratchSpriteMorph >> stopFollowing [

	offset := nil.
	self spread
]

{ #category : #'movie ops' }
PhratchSpriteMorph >> stopPlaying [
	"Reset my transient state, such as pen down."

	super stopPlaying.
	self sayNothing.


]

{ #category : #nesting }
PhratchSpriteMorph >> subsprites [
	^subsprites
]

{ #category : #nesting }
PhratchSpriteMorph >> toggleRotationRule [

	rotateWithOwner := self rotateWithOwner not
]

{ #category : #'motion ops' }
PhratchSpriteMorph >> turn: degrees [
	"Turn clockwise the given number of degrees."

	self undeleteAttribute: #heading.
	self passiveTurn: degrees
]

{ #category : #'motion ops' }
PhratchSpriteMorph >> turnLeft: degrees [
	"Turn counter-clockwise the given number of degrees."
	<phratchItem: 'turn $Number$ degrees' kind: #- category: 'motion' defaultValues: #(15) subCategory: #a1 special: #()>
	| newPos |
	self rotationDegrees: self rotationDegrees - degrees.

	subsprites do: [:sub |
		newPos := sub referencePosition rotateBy: degrees negated degreesToRadians about: self referencePosition.
		sub gotoX: newPos x y: newPos y ].
	self rotateWithOwner
		ifTrue: [ self spreadToFollowers ]


]

{ #category : #'motion ops' }
PhratchSpriteMorph >> turnRight: degrees [
	"Turn clockwise the given number of degrees."
	<phratchItem: 'turn $Number$ degrees' kind: #- category: 'motion' defaultValues: #(15) subCategory: #a1 special: #()>
	| newPos |
	"Turn clockwise the given number of degrees."

	self rotationDegrees: self rotationDegrees + degrees.

	subsprites do: [:sub |
		newPos := sub referencePosition rotateBy: degrees degreesToRadians about: self referencePosition.
		sub gotoX: newPos x y: newPos y ].
	self rotateWithOwner
		ifTrue: [ self spreadToFollowers ]


]

{ #category : #private }
PhratchSpriteMorph >> undoableDeleteSprite [
	"Delete the sprite and store it in the clipboard in case of an undo."

	self notEditingBlock ifFalse: [^self].
	self unhinge; unhingeAll.
	PhratchFrameMorph putInClipboard: self.
	self deleteSprite.

]

{ #category : #nesting }
PhratchSpriteMorph >> unhinge [

	(ownerSprite isPhratchSpriteMorph)
		ifFalse: [ownerSprite := nil].
	ownerSprite ifNil: [^self].
	ownerSprite removeSubsprite: self.
	ownerSprite := nil. 
	self makeVisible.

	LibraryItemMorph allInstances do: [:each| each updateThumbnail]
]

{ #category : #nesting }
PhratchSpriteMorph >> unhingeAll [

	subsprites copy do: [:each |
		each unhinge ].

	LibraryItemMorph allInstances do: [:each| each updateThumbnail]
]

{ #category : #copying }
PhratchSpriteMorph >> veryDeepFixupWith: deepCopier [
	"If fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals."

	super veryDeepFixupWith: deepCopier.
"	ownerSprite := deepCopier references at: ownerSprite ifAbsent: [ownerSprite].	"
	prototype := deepCopier references at: prototype ifAbsent: [prototype].
"	subsprites := subsprites collect: [:m | deepCopier references at: m ifAbsent: [m]]"
]

{ #category : #copying }
PhratchSpriteMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

	super veryDeepInner: deepCopier.
	scalePoint := scalePoint veryDeepCopyWith: deepCopier.
	rotationDegrees := rotationDegrees veryDeepCopyWith: deepCopier.
	rotationStyle := rotationStyle veryDeepCopyWith: deepCopier.
	rotatedForm := rotatedForm veryDeepCopyWith: deepCopier.
	offsetWhenRotated := offsetWhenRotated veryDeepCopyWith: deepCopier.
	draggable := draggable veryDeepCopyWith: deepCopier.
	penDown := penDown veryDeepCopyWith: deepCopier.
	penSize := penSize veryDeepCopyWith: deepCopier.
	penColor := penColor veryDeepCopyWith: deepCopier.
	penHue := penHue veryDeepCopyWith: deepCopier.
	penShade := penShade veryDeepCopyWith: deepCopier.
	offset := offset veryDeepCopyWith: deepCopier.
	virtualScale := virtualScale veryDeepCopyWith: deepCopier.
	rotateWithOwner := rotateWithOwner veryDeepCopyWith: deepCopier.
	refPos := refPos veryDeepCopyWith: deepCopier.
	
	ownerSprite := ownerSprite veryDeepCopyWith: deepCopier.
	subsprites := subsprites veryDeepCopyWith: deepCopier.
]

{ #category : #nesting }
PhratchSpriteMorph >> virtualScale [

	^virtualScale ifNil: [
		virtualScale := self realScale]
]

{ #category : #'motion ops' }
PhratchSpriteMorph >> whenSpriteCreated [
	"Following blocks are executed when the given sprite is created"
	<phratchItem: 'when $Sprite$ created' kind: #CreationEventHatMorph category: 'control' defaultValues: #() subCategory: #ahat special: #()>


]

{ #category : #accessing }
PhratchSpriteMorph >> xpos [
	"Return my x position"
	<phratchItem: 'x position' kind: #ReporterWatcherBlockMorph category: 'motion' defaultValues: #() subCategory: #a7 special: #()>
	| att |
	att := #xPosition.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ self referencePosition x

]

{ #category : #accessing }
PhratchSpriteMorph >> xpos: aNumber [ 
	"Set my x position"
	<phratchItem: 'set x to $Number$' kind: #- category: 'motion' defaultValues: #(0) subCategory: #a4 special: #()>
	self undeleteAttribute: #xPosition.
	self passiveXpos: aNumber
]

{ #category : #accessing }
PhratchSpriteMorph >> ypos [
	"Return my y position"
	<phratchItem: 'y position' kind: #ReporterWatcherBlockMorph category: 'motion' defaultValues: #() subCategory: #a7 special: #()>
	| att |
	att := #yPosition.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ self referencePosition y

]

{ #category : #accessing }
PhratchSpriteMorph >> ypos: aNumber [ 
	"Set my y position"
	<phratchItem: 'set y to $Number$' kind: #- category: 'motion' defaultValues: #(0) subCategory: #a4 special: #()>
	self undeleteAttribute: #yPosition.
	self passiveYpos: aNumber
]
