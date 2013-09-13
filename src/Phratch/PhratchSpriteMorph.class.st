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

{ #category : #adding }
PhratchSpriteMorph >> addCostTyped: aString [
	<phratchItem: 'add $NewCostume$ to costumes' kind: #- category: 'looks' defaultValues: #() subCategory: #a2>
	self addCostumeTyped: aString.
]

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

{ #category : #accessing }
PhratchSpriteMorph >> area [
	<phratchItem: 'area' kind: #r category: 'looks' defaultValues: #() subCategory: #a4>
^self height * self width
]

{ #category : #'blocks API' }
PhratchSpriteMorph >> arrowMove: i1 [ 
"Made using Scramble by Hardmath123"
<phratchItem: 'Arrow key move with speed $Number$' kind: #- category: 'motion' defaultValues: #() subCategory: #a1>
| t4 t3 t2 t1|

t1:= 'up arrow'.
t2:= 'down arrow'.
t3:= 'left arrow'.
t4:= 'right arrow'.

t1:= self keyPressed:t1.
t2:= self keyPressed:t2.
t3:= self keyPressed:t3.
t4:= self keyPressed:t4.

t1 ifTrue: [
self gotoX: self xpos y: (i1+ self ypos).
].

t2 ifTrue: [
t2:=i1 * -1.
self gotoX: self xpos y: (t2+ self ypos).
].

t3 ifTrue: [
t3:=i1 * -1.
self gotoX: (t3+self xpos) y: self ypos.
].

t4 ifTrue: [
self gotoX: (i1+self xpos) y: self ypos.
].
]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> asReferenceTuple [

	" answer an array describing the receiver in an abstract way
	format conventions:"

	^ Array 
		with: #sprite
		with: self objName

]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> attribute: attr [
	"Answer the value of my variable or built-in attribute with the given name. Answer zero if I have no attribute or variable with the given name."

	| a |
	
	(attr isKindOf: CommandBlockMorph)
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
	'volume' localized = a ifTrue: [^ self volume].

	'name' localized = a ifTrue: [^ self objName].
	'prototype' localized = a ifTrue: [^ self prototype].
	'owner' localized = a ifTrue: [^ self ownerSprite].
	'parts' localized = a ifTrue: [^ PhratchListMorph on: self subsprites].

	^ 0

]

{ #category : #'sensing ops' }
PhratchSpriteMorph >> attributeNames [

	^ #('x position' 'y position' 'direction' 'costume #' 'size' 'volume') collect: [:s | s]

]

{ #category : #'blocks API' }
PhratchSpriteMorph >> betweenX: t1 Y: t2 X: t3 Y: t4 [
<phratchItem: 'go in between x: $Number$ y: $Number$ and x: $Number$ y: $Number$' kind: #- category: 'motion' defaultValues: #() subCategory: #a3>
| newX newY |

newX:= (t1 + t3) / 2.
newY:= (t2 + t4) / 2.
self referencePosition: newX @ newY
]

{ #category : #'blocks API' }
PhratchSpriteMorph >> bounceIfBoolean: condition [
	<phratchItem: 'if $Boolean$ bounce' kind: #- category: 'motion' defaultValues: #() subCategory: #a5>
     condition ifTrue: [self turnRight: 180]
]

{ #category : #'motion ops' }
PhratchSpriteMorph >> bounceOffEdge [
	"Set my direction to bounce off the edge."
	<phratchItem: 'if on edge, bounce' kind: #- category: 'motion' defaultValues: #() subCategory: #a5>
	| myBox edgeBox dirX dirY |
	owner ifNil: [^ self].
	ownerSprite ifNotNil: [^ self].
	myBox := self allBounds.
	edgeBox := owner bounds.
	(edgeBox containsRect: myBox) ifTrue: [^ self].

	dirX := self rotationDegrees degreesToRadians cos.
	dirY := self rotationDegrees degreesToRadians sin negated.
	myBox left < edgeBox left ifTrue: [dirX := dirX abs].
	myBox right > edgeBox right ifTrue: [dirX := dirX abs negated].
	myBox top < edgeBox top ifTrue: [dirY := dirY abs negated].
	myBox bottom > edgeBox bottom ifTrue: [dirY := dirY abs].
	self heading: "rotationDegrees:" (dirY negated asFloat arcTan: dirX) radiansToDegrees + 90.
	self holdSubsprites.
	self position: self position + (myBox amountToTranslateWithin: edgeBox).
	self releaseSubsprites.

	self xpos: self xpos.
	self ypos: self ypos 

]

{ #category : #'blocks API' }
PhratchSpriteMorph >> bounceOffSprite: aName [ 
	<phratchItem: 'if touching $Sprite$ bounce' kind: #- category: 'motion' defaultValues: #() subCategory: #a5>
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
			(objToShow isKindOf: Boolean)
				ifTrue: [ s := objToShow asString localized ]
				ifFalse: [ 
					(objToShow isKindOf: Morph)
						ifFalse: [ s := objToShow asString ] ] ].
	(s isKindOf: String)
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
	World displayWorldSafely.
	^ talkBubble
]

{ #category : #nesting }
PhratchSpriteMorph >> cacheRefPos [
	refPos := self referencePosition.
	self spread
]

{ #category : #'pen ops' }
PhratchSpriteMorph >> changePenHueBy: aNumber [
	"Change the pen hue by given number."
	<phratchItem: 'change pen color by $Number$' kind: #- category: 'pen' defaultValues: #() subCategory: #a3>
	self setPenHueTo: penHue + aNumber.


]

{ #category : #'pen ops' }
PhratchSpriteMorph >> changePenShadeBy: aNumber [
	"Change the pen shade (lightness) by given number"
	<phratchItem: 'change pen shade by $Number$' kind: #- category: 'pen' defaultValues: #() subCategory: #a3>
	self setPenShadeTo: penShade + aNumber.

]

{ #category : #'pen ops' }
PhratchSpriteMorph >> changePenSizeBy: aNumber [
	"Change my pen width."
	<phratchItem: 'change pen size by $Number$' kind: #- category: 'pen' defaultValues: #(1) subCategory: #a3>
	self penSize: penSize + aNumber.

]

{ #category : #'looks ops' }
PhratchSpriteMorph >> changeSizeBy: delta [
	"Change my size by the given delta."
	<phratchItem: 'change size by $Number$' kind: #- category: 'looks' defaultValues: #() subCategory: #a4>
	self setSizeTo: (self virtualScale + delta).

]

{ #category : #'looks ops' }
PhratchSpriteMorph >> changeStretchBy: delta [
	"Change my aspect ratio by the given amount."
	<phratchItem: 'change hStretch by $Number$' kind: #- category: 'looks' defaultValues: #() subCategory: #a5>
	| currentStretch |
	currentStretch := (100.0 * scalePoint x) / scalePoint y.
	self setStretchTo: (currentStretch + delta).

]

{ #category : #'panther actions' }
PhratchSpriteMorph >> changeVStretchBy: delta [
	"Change my aspect ratio by the given amount."
	<phratchItem: 'change vStretch by $Number$' kind: #- category: 'looks' defaultValues: #() subCategory: #a5>
	| currentVStretch |
	currentVStretch := (100.0 * scalePoint y) / scalePoint x.
	self setVStretchTo: (currentVStretch + delta).
]

{ #category : #'motion ops' }
PhratchSpriteMorph >> changeXposBy: aNumber [
	"Move right by the given amount."
	<phratchItem: 'change x by $Number$' kind: #- category: 'motion' defaultValues: #(10) subCategory: #a4>
	self xpos: self xpos + aNumber

"
	self referencePosition: self referencePosition + (aNumber@0).
	self spread
"
]

{ #category : #'motion ops' }
PhratchSpriteMorph >> changeYposBy: aNumber [
	"Move up by the given amount."
	<phratchItem: 'change y by $Number$' kind: #- category: 'motion' defaultValues: #(10) subCategory: #a4>
	self ypos: self ypos + aNumber

"
	self referencePosition: self referencePosition + (0@aNumber).
	self spread
"
]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> children [
	^ PhratchListMorph on: self instances
]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> choosePrototype [
	| stage choice |
	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
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
	<phratchItem: 'clear pen trails' kind: #- category: 'pen' defaultValues: #() subCategory: #a5>
	| m |
	(m := self ownerOrYourselfThatIsA: PhratchStageMorph)
		ifNotNil: [m clearPenTrails].

]

{ #category : #'panther actions' }
PhratchSpriteMorph >> cloneMe [
	<phratchItem: 'clone me' kind: #- category: 'control' defaultValues: #() subCategory: #self>
	| stage clone |
	(self ownerThatIsA: OffscreenWorldMorph) ifNotNil: [
		stage := (self ownerThatIsA: OffscreenWorldMorph) frame workPane.
		clone := (self fullCopy).
		stage addMorphFront: clone.]
	ifNil: [
	clone := self duplicateNoAttach.
	clone referencePosition: self referencePosition].
	clone isClone: true.
	clone eventReceived: (PhratchEvent new name: 'Phratch-CreationEvent' argument: 0)

]

{ #category : #'motion ops' }
PhratchSpriteMorph >> color: sensitiveColor sees: soughtColor [
	"Return true if any of my pixels of sensitiveColor intersect with pixels of soughtColor in the world."
	<phratchItem: 'color $ScreenColor$ is touching $ScreenColor$?' kind: #b category: 'sensing' defaultValues: #() subCategory: #sensor>
	| r myImage sensitivePixelsMask map index imageBelowMe result |
	r := self bounds intersect: owner bounds.
	r area = 0 ifTrue: [^ false].

	"make a mask with 1 where pixel = sensitiveColor, 0 elsewhere"
	myImage := self imageForm asFormOfDepth: 16.
	sensitivePixelsMask := Form extent: myImage extent depth: 1.
	map := Bitmap new: (1 bitShift: (myImage depth min: 15)).
	map at: (index := sensitiveColor indexInMap: map) put: 1.
	sensitivePixelsMask
		copyBits: ((r origin - self position) extent: r extent)
		from: myImage form
		at: 0@0
		colorMap: map.

	"grab an image of the world below me"
	imageBelowMe := owner patchAt: r without: self andNothingAbove: false.

	"intersect world pixels of the color we're looking for with sensitive pixels mask"
	map at: index put: 0.  "clear map and reuse it"
	map at: (soughtColor indexInMap: map) put: 1.

	sensitivePixelsMask
		copyBits: imageBelowMe boundingBox
		from: imageBelowMe at: 0@0 clippingBox: imageBelowMe boundingBox
		rule: Form and
		fillColor: nil
		map: map.
	result := (sensitivePixelsMask tallyPixelValues at: 2) > 0.
	result ifTrue: [^true].
	^(subsprites collect: [:sub | sub color: sensitiveColor sees: soughtColor ]) includes: true 


]

{ #category : #'BYOB attributes' }
PhratchSpriteMorph >> comeToFront [

	<phratchItem: 'go to front' kind: #- category: 'looks' defaultValues: #() subCategory: #a7>
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
	objToExport convertStacksToTuples.
	objToExport addMorph: super copyForExport.
	^ objToExport

]

{ #category : #'blocks API' }
PhratchSpriteMorph >> deleteCostAt: aNumber [
	<phratchItem: 'delete costume $Number$' kind: #- category: 'looks' defaultValues: #(1) subCategory: #a2>
	self deleteCostumeAt: aNumber.
]

{ #category : #'panther actions' }
PhratchSpriteMorph >> deleteMe [
	<phratchItem: 'delete me if I am a clone' kind: #- category: 'control' defaultValues: #() subCategory: #self>
	self isClone ifTrue: [self deleteSprite].
]

{ #category : #'motion ops' }
PhratchSpriteMorph >> directionMenu [
	"Provides a drop-down menu for setting the sprite direction."

	| menu |
	menu := MenuMorphNG new defaultTarget: self.
	#(	('right' 90)
		('left' -90)
		('up' 0)
		('down' 180)
	) do: [:pair |
		menu
			add: '(', pair second printString, ') ', pair first localized
			value: pair second].
	menu invokeModal.
	^ menu selectedValue
]

{ #category : #'blocks API' }
PhratchSpriteMorph >> dist: t1 and: t2 [ 
	<phratchItem: 'distance to x $Number$ y $Number$' kind: #r category: 'sensing' defaultValues: #(0 0) subCategory: #sensor>
    ^ ((self xpos - t1) * (self xpos - t1) + ((self ypos - t2) * (self ypos - t2))) abs sqrt
]

{ #category : #'blocks API' }
PhratchSpriteMorph >> distance: t1 X: t2 Y: t3 [ 
	<phratchItem: 'go $Number$ of the way to x: $Number$ y: $Number$' kind: #- category: 'motion' defaultValues: #() subCategory: #a3>
    | newX newY |
    newX := t1 * 0.01 * (t2 - self xpos).
    newY := t1 * 0.01 * (t3 - self ypos).
    self gotoX: newX + self xpos y: newY + self ypos
]

{ #category : #'motion ops' }
PhratchSpriteMorph >> distanceTo: anObject [
	"Answer the distance to the given sprite."
	<phratchItem: 'distance to $Sprite$' kind: #r category: 'sensing' defaultValues: #() subCategory: #sensor>
	| aSpriteOrSymbol |
	aSpriteOrSymbol := self coerceSpriteArg: anObject.

	aSpriteOrSymbol = #mouse ifTrue: [
		^ ((self mouseX @ self mouseY)  - self referencePosition) r].

	(aSpriteOrSymbol isKindOf: self class) ifFalse: [^ 10000].
	^ (aSpriteOrSymbol referencePosition - self referencePosition) r

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

	aCanvas translucentImage: f at: bounds origin.

]

{ #category : #drawing }
PhratchSpriteMorph >> drawSubmorphsOn: aCanvas [
	"Display submorphs back to front, but do not draw and talk/think bubble submorphs."

	submorphs reverseDo: [:m |
		(m isKindOf: PhratchTalkBubbleMorph) ifFalse: [
			aCanvas fullDrawMorph: m]].

]

{ #category : #drawing }
PhratchSpriteMorph >> drawTalkBubbleOn: aCanvas [
	"Draw and talk/think bubble submorphs."

	submorphs size = 0 ifTrue: [^ self].
	submorphs reverseDo: [:m |
		(m isKindOf: PhratchTalkBubbleMorph) ifTrue: [
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

	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
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

{ #category : #'object i/o' }
PhratchSpriteMorph >> fieldsVersion [

	^ 5

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

{ #category : #'motion ops' }
PhratchSpriteMorph >> forward: distance [
	"Move the object forward (i.e., the direction of its heading) by the given distance.
	Avoid infinite or NaN coordinates"
	<phratchItem: 'move $Number$ steps' kind: #- category: 'motion' defaultValues: #() subCategory: #a1>
	| radians deltaP newPos newX newY |
	
	radians := self rotationDegrees degreesToRadians.
	deltaP := ((radians cos)@(radians sin)) * distance.
	newPos := self position + deltaP.
	newX := newPos x.
	newY := newPos y.
	newX isNaN ifTrue: [newX := 0].
	newX isInfinite ifTrue: [newX := newX sign * 10000].
	newY isNaN ifTrue: [newY := 0].
	newY isInfinite ifTrue: [newY := newY sign * 10000].
	self holdSubsprites.
	self position: newX @ newY.
	self releaseSubsprites.
	self keepOnScreen.

	self xpos: self xpos.
	self ypos: self ypos 

]

{ #category : #'blocks API' }
PhratchSpriteMorph >> function [

	<phratchItem: 'the $SAReporter$ block' kind: #Q category: 'operators' defaultValues: #() subCategory: #b2>
]

{ #category : #'blocks API' }
PhratchSpriteMorph >> functionWithArgs [

	<phratchItem: 'the $SAReporter$ block. Input names: $String$' kind: #Q category: 'operators' defaultValues: #() subCategory: #b2>
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
PhratchSpriteMorph >> glideSecs: duration toX: endX y: endY elapsed: elapsed from: startPoint [
	"Interpolate my position from my current postion to the given x and y over the given duration. If startPoint is nil, just answer my current position; this sets the starting point for the interpolation."

	<phratchItem: 'glide $Number$ secs to x:$Number$ y:$Number$' kind: #t category: 'motion' defaultValues: #(1 50 50)
	subCategory: #a3>
	| fraction endPoint rPos |
	startPoint ifNil: [ ^ self referencePosition ].
	endPoint := endX @ endY.
	fraction := duration < 0.001
		ifTrue: [ 1 ]
		ifFalse: [ elapsed asFloat / (1000.0 * duration) ].
	fraction > 1.0
		ifTrue: [ fraction := 1 ].
	fraction < 0.0
		ifTrue: [ fraction := 0 ].
	rPos := startPoint + (fraction * (endPoint - startPoint)) truncated.
	self gotoX: rPos x y: rPos y	"
	| fraction endPoint |
	startPoint ifNil: [
		self holdSubsprites. 
		^ self referencePosition].
	endPoint := endX@endY.
	duration < 0.001
		ifTrue: [fraction := 1]
		ifFalse: [fraction := elapsed asFloat / (1000.0 * duration)].
	fraction > 1.0 ifTrue: [fraction := 1].
	fraction < 0.0 ifTrue: [fraction := 0].
	self referencePosition: startPoint + (fraction * (endPoint - startPoint)) truncated.

	(self referencePosition = endPoint) ifTrue: [
		self releaseSubsprites]

"
]

{ #category : #'looks ops' }
PhratchSpriteMorph >> goBackByLayers: aNumber [
	"Decrease my layer by (i.e., move me towards the back by) the given number of layers."
	<phratchItem: 'go back $Number$ layers' kind: #- category: 'looks' defaultValues: #(1) subCategory: #a7>
	self setLayerTo: self layer + aNumber truncated
]

{ #category : #'motion ops' }
PhratchSpriteMorph >> gotoSpriteOrMouse: anObject [
	"Go to the given sprite or mouse position."
	<phratchItem: 'go to $Sprite$' kind: #- category: 'motion' defaultValues: #() subCategory: #a3>
	| x y len aSpriteOrSymbol p |
	(anObject isKindOf: PhratchListMorph) ifTrue: [ "try to go the coordinates specified in a list"
		x := self xpos.
		y := self ypos.
		len := anObject lineCount.
		len > 0 ifTrue: [
			x := (anObject lineAt: 1) asNumberNoError.
			len > 1 ifTrue: [
				y := (anObject lineAt: 2) asNumberNoError]].
			self gotoX: x y: y].

	aSpriteOrSymbol := self coerceSpriteArg: anObject.

	aSpriteOrSymbol = #mouse ifTrue: [^ self gotoX: self mouseX y: self mouseY].
	(aSpriteOrSymbol isKindOf: self class) ifFalse: [^ self].
	p := aSpriteOrSymbol referencePosition.
	self gotoX: p x y: p y.


]

{ #category : #'motion ops' }
PhratchSpriteMorph >> gotoX: x y: y [
	<phratchItem: 'go to x:$Number$ y:$Number$' kind: #- category: 'motion' defaultValues: #(0 0) subCategory: #a3>
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

{ #category : #'blocks API' }
PhratchSpriteMorph >> hFlip [
	<phratchItem: 'h flip' kind: #- category: 'looks' defaultValues: #() subCategory: #a5>
    costume form: (self form flipBy: #horizontal centerAt: 0 @ 0).
    self costumeChanged
]

{ #category : #'panther actions' }
PhratchSpriteMorph >> hScale [
	<phratchItem: 'hStretch' kind: #r category: 'looks' defaultValues: #() subCategory: #a5>
	^ (100 * scalePoint x) rounded
]

{ #category : #nesting }
PhratchSpriteMorph >> hasSubsprites [
	^subsprites size > 0
]

{ #category : #accessing }
PhratchSpriteMorph >> heading [
	"Answer my heading in degrees, a number between -180 and 180."
	<phratchItem: 'direction' kind: #r category: 'motion' defaultValues: #() subCategory: #a7>
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
	<phratchItem: 'point in direction $Directions$' kind: #- category: 'motion' defaultValues: #(90) subCategory: #a2>
	self turn: headingDegrees asNumberNoError - self heading

]

{ #category : #geometry }
PhratchSpriteMorph >> height [
	<phratchItem: 'height' kind: #r category: 'looks' defaultValues: #() subCategory: #a4>
^super height
]

{ #category : #'looks ops' }
PhratchSpriteMorph >> hide [
	"Make myself invisible."
	<phratchItem: 'hide' kind: #- category: 'looks' defaultValues: #() subCategory: #a6>
	self setHideFlagTo: true

]

{ #category : #nesting }
PhratchSpriteMorph >> holdSubsprites [
	"private"

	subsprites do: [:each | each follow].
]

{ #category : #'object i/o' }
PhratchSpriteMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.

(customBlocks isKindOf: Boolean) ifTrue: [ self error: 'attempting to initialize a wrong class version']. 

	self initFieldsNamed: #(
		visibility
		scalePoint
		rotationDegrees
		rotationStyle
	) from: anObjStream.

	scalePoint ifNil: [scalePoint := 1.0@1.0].
	offsetWhenRotated := 0@0.
	draggable := false.  "default for old sprites"
	self layoutChanged.

	classVersion = 1 ifTrue: [^ self].

	"fields added in version 2"
	self initFieldsNamed: #(
		volume
		tempoBPM
		draggable
	) from: anObjStream.
	classVersion = 2 ifTrue: [^ self].

	"fields added in version 3"
	self initFieldsNamed: #(
		sceneStates
		lists
	) from: anObjStream.
	lists ifNil: [lists := Dictionary new].  "work around"
	classVersion = 3 ifTrue: [^ self].

	"fields added in version 4"
	self initFieldsNamed: #(
		virtualScale
		ownerSprite
		subsprites
		rotateWithOwner
		refPos
	) from: anObjStream.

	classVersion = 4 ifTrue: [^ self].
	"fields added in version 5"
	self initFieldsNamed: #(
		prototype
		deletedAttributes
	) from: anObjStream.

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
	<phratchItem: 'Am I a clone?' kind: #b category: 'control' defaultValues: #() subCategory: #self>
	^ isClone

]

{ #category : #accessing }
PhratchSpriteMorph >> isClone: aBoolean [

	isClone := aBoolean.

]

{ #category : #'panther actions' }
PhratchSpriteMorph >> isDraggable [
	<phratchItem: 'draggable?' kind: #b category: 'motion' defaultValues: #() subCategory: #a8>
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
PhratchSpriteMorph >> isSprite [

	^ true

]

{ #category : #'looks ops' }
PhratchSpriteMorph >> isVisible [
	"Make myself invisible."
	<phratchItem: 'visible?' kind: #b category: 'looks' defaultValues: #() subCategory: #a6>
	^super isVisible

]

{ #category : #'event handling' }
PhratchSpriteMorph >> justDroppedInto: newOwner event: evt [
	
	self releaseSubsprites.
	super justDroppedInto: newOwner event: evt.
	(newOwner isKindOf: PhratchStageMorph) ifTrue: [self positionTalkBubble].

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
	(owner isKindOf: PhratchStageMorph) ifFalse: [^ self].
	
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

	| refPoint |
	self changed.
	refPoint := bounds origin + offsetWhenRotated.
	(rotationStyle == #none and: [scalePoint = (1.0@1.0)])
		ifTrue: [  "zero rotation and scale; use original Form"
			rotatedForm := self costumeForm. 	
			offsetWhenRotated := costume rotationCenter]
		ifFalse: [self generateRotatedForm].	"compute the new rotatedForm and offsetWhenRotated"

	bounds := (refPoint - offsetWhenRotated) extent: rotatedForm extent.
	super layoutChanged.
	self changed.

]

{ #category : #'looks ops' }
PhratchSpriteMorph >> lookLike: costumeName [
	<phratchItem: 'switch to costume $Costumes$' kind: #- category: 'looks' defaultValues: #() subCategory: #a1>
	self undeleteAttribute: #costumeIndex.
	self passiveLookLike: costumeName.
	costumeName isNumber ifFalse: [
		self lookLike: self costumeIndex ].
]

{ #category : #'panther actions' }
PhratchSpriteMorph >> makeDrag [
	<phratchItem: 'make draggable' kind: #- category: 'motion' defaultValues: #() subCategory: #a8>
	draggable := true.
]

{ #category : #'panther actions' }
PhratchSpriteMorph >> makeNoDrag [
	<phratchItem: 'make undraggable' kind: #- category: 'motion' defaultValues: #() subCategory: #a8>
	draggable := false.
]

{ #category : #'looks ops' }
PhratchSpriteMorph >> multiplySizeBy: factor [
	"Used by the magnifying glass tool. Multiply my scale by the given factor."

	self setSizeTo: 100.0 * (self scalePoint x max: self scalePoint y) * factor.

]

{ #category : #'looks ops' }
PhratchSpriteMorph >> nextCostume [
	"Show the next costume in my costumes list."
	<phratchItem: 'next costume' kind: #- category: 'looks' defaultValues: #() subCategory: #a1>
	
	super nextCostume.

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
PhratchSpriteMorph >> passivePenDown: aBoolean [

	| m |
	(aBoolean isKindOf: Boolean)
		ifFalse: [^ self error: 'expecting a boolean'].
	penDown := aBoolean.
	penColor ifNil: [penColor := Color black].  "initialize if necessary"
	penSize ifNil: [penSize := 1].  "initialize if necessary"

	(m := self ownerOrYourselfThatIsA: PhratchStageMorph)
		ifNotNil: [m penUpOrDownChangeFor: self].

	self propagate: #penDown

]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> passivePenSize: aNumber [
	"Set my pen width."

	penSize := aNumber asNumberNoError rounded min: (PhratchFrameMorph workpaneExtent x * 2) max: 1.

	self propagate: #penSize

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
	se := blocksBin ownerOrYourselfThatIsA: PhratchScriptEditorMorph.
	se ifNil: [^ self].
	se updateRotationButtonHighlight.
	se animateRotationStyle.

	self propagate: #rotationStyle

]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> passiveSetDraggable: aBoolean [

	| se |
	draggable := aBoolean.
	se := blocksBin ownerOrYourselfThatIsA: PhratchScriptEditorMorph.
	se ifNil: [^ self].
	se updateLockButton

]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> passiveSetPenHueTo: aNumber [
	"Set the pen hue to given number between 0 and 200. (That makes 100 the 'maximum' distance away from the original color on the color wheel.)"

	penHue := aNumber asNumberNoError \\ 200.
	self setPenShadeTo:  penShade.  "compute and set penColor"

	self propagate: #penColor

]

{ #category : #'byob OOP' }
PhratchSpriteMorph >> passiveSetPenShadeTo: aNumber [
	"Set the pen shade (lightness) to given number between 0 and 100. A shade of 0 is black, 100 is white, and 50 is fully saturated color."
	"Details: We don't want to get all the way to pure black or white, so we divide the range 0..50 by a number > 50 when computing the fraction of the original color to mix with black or white."

	| normalizeShade scale k |
	penShade := aNumber asNumberNoError asFloat \\ 200.0.
	penColor := Color h: (360.0 * penHue) / 200.0 s: 1.0 v: 1.0.
	normalizeShade := penShade > 100.0 ifTrue: [200.0 - penShade] ifFalse: [penShade].

	(normalizeShade closeTo: 50.0) ifTrue: [^ self].  "pure color"

	scale := 1.0 / 60.0.
	k := 1.0 - (50.0 * scale).
	normalizeShade < 50.0 ifTrue: [
		penColor := penColor mixed: (scale * normalizeShade) + k with: Color black].
	normalizeShade > 50.0 ifTrue: [
		penColor := penColor mixed: 1.0 - (scale * (normalizeShade - 50.0)) with: Color white].

	self propagate: #penShade

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

	(aSprite isKindOf: PhratchSpriteMorph) ifFalse: [
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
	<phratchItem: 'pen color' kind: #r category: 'pen' defaultValues: #() subCategory: #a1>
	^ penColor

]

{ #category : #'pen ops' }
PhratchSpriteMorph >> penColor: aColor [
	"Set my pen color."
	<phratchItem: 'set pen color to $Color$' kind: #- category: 'pen' defaultValues: #() subCategory: #a3>
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
PhratchSpriteMorph >> penDown: aBoolean [

	self undeleteAttribute: #penDown.
	self passivePenDown: aBoolean
]

{ #category : #'BYOB attributes' }
PhratchSpriteMorph >> penHue [
	<phratchItem: 'pen hue' kind: #r category: 'pen' defaultValues: #() subCategory: #a1>
	| att |
	att := #penColor.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ penHue
]

{ #category : #'pen ops' }
PhratchSpriteMorph >> penPosition [

	^ self referencePosition

]

{ #category : #'BYOB attributes' }
PhratchSpriteMorph >> penShade [
	<phratchItem: 'pen shade' kind: #r category: 'pen' defaultValues: #() subCategory: #a1>
	| att |
	att := #penShade.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ penShade
]

{ #category : #'pen ops' }
PhratchSpriteMorph >> penSize [
	<phratchItem: 'pen size' kind: #r category: 'pen' defaultValues: #() subCategory: #a1>
	| att |
	att := #penSize.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ penSize

]

{ #category : #'pen ops' }
PhratchSpriteMorph >> penSize: aNumber [
	"Set my pen width."
	<phratchItem: 'set pen size to $Number$' kind: #- category: 'pen' defaultValues: #(1) subCategory: #a3>
	self undeleteAttribute: #penSize.
	self passivePenSize: aNumber
]

{ #category : #'blocks API' }
PhratchSpriteMorph >> perimeter [
	<phratchItem: 'perimeter' kind: #r category: 'looks' defaultValues: #() subCategory: #a4>
^ (2 * self height) + (2 * self width)
]

{ #category : #'motion ops' }
PhratchSpriteMorph >> pointToX: x y: y [
	"Set my heading to point at the given point."
	<phratchItem: 'point at x:$Number$ y:$Number$' kind: #- category: 'motion' defaultValues: #() subCategory: #a6>
	| delta angle |
	delta := (x@y) - self referencePosition.
	angle := (delta x abs < 0.001)
		ifTrue: [
			delta y < 0 ifTrue: [90] ifFalse: [270]]
		ifFalse: [
			((delta x >= 0 ifTrue: [0] ifFalse: [180])
				- ((delta y / delta x) arcTan * 57.2957795131)) rounded].

	self heading: angle + 90


"	self rotationDegrees: angle."


]

{ #category : #'motion ops' }
PhratchSpriteMorph >> pointTowards: anObject [
	"Point toward the given sprite."
	<phratchItem: 'point towards $Sprite$' kind: #- category: 'motion' defaultValues: #() subCategory: #a2>
	| aSpriteOrSymbol p |
	aSpriteOrSymbol := self coerceSpriteArg: anObject.

	aSpriteOrSymbol = #mouse ifTrue: [^ self pointToX: self mouseX y: self mouseY].
	(aSpriteOrSymbol isKindOf: self class) ifFalse: [^ self].
	p := aSpriteOrSymbol referencePosition.
	self pointToX: p x y: p y.


]

{ #category : #private }
PhratchSpriteMorph >> positionTalkBubble [

	| bubble stage stageBounds y f r yInset strip x |
	(bubble := self valueOfProperty: #talkBubble) ifNil: [^ self].
	(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNil: [^ self].
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

{ #category : #nesting }
PhratchSpriteMorph >> privateOwnerSprite: aSprite [

	ownerSprite := aSprite
]

{ #category : #nesting }
PhratchSpriteMorph >> privateSubsprites: anOrderedCollection [

	subsprites := anOrderedCollection
]

{ #category : #'blocks API' }
PhratchSpriteMorph >> procedure [

	<phratchItem: 'the script' kind: #q category: 'operators' defaultValues: #() subCategory: #b2>
]

{ #category : #'blocks API' }
PhratchSpriteMorph >> procedureWithArgs [

	<phratchItem: 'the script. Input names: $String$' kind: #q category: 'operators' defaultValues: #() subCategory: #b2>
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
	(sFrame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ self].
	sFrame viewerPane categoryChanged: sFrame viewerPane currentCategory.
	self inheritCostumesNow.
	self inheritSoundsNow
]

{ #category : #'pen ops' }
PhratchSpriteMorph >> putPenDown [
	"Put down my drawing pen (i.e. start drawing a pen trail)."
	<phratchItem: 'pen down' kind: #- category: 'pen' defaultValues: #() subCategory: #a2>
	self penDown: true.

]

{ #category : #'pen ops' }
PhratchSpriteMorph >> putPenUp [
	"Put up my drawing pen (i.e. stop drawing a pen trail)."
	<phratchItem: 'pen up' kind: #- category: 'pen' defaultValues: #() subCategory: #a2>
	self penDown: false.

]

{ #category : #'blocks API' }
PhratchSpriteMorph >> randxypos [
	<phratchItem: 'point at random coordinate' kind: #- category: 'motion' defaultValues: #() subCategory: #a6>
    self pointToX: (self randomFrom: -240 to: 240)
        y: (self randomFrom: -180 to: 180)
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

{ #category : #nesting }
PhratchSpriteMorph >> refPos [
	^refPos
]

{ #category : #nesting }
PhratchSpriteMorph >> refPos: aPoint [
	refPos := aPoint
]

{ #category : #accessing }
PhratchSpriteMorph >> referencePosition [

	| p s |
	p := (bounds origin + offsetWhenRotated) - PhratchOrigin.

	"adjust when in Hand in quartersize mode:"
	((owner isKindOf: HandMorph) and:
	 [((s := owner formerOwner) isKindOf: PhratchStageMorph) and:
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

{ #category : #'blocks API' }
PhratchSpriteMorph >> replaceCost: name with: sel [
	<phratchItem: 'replace costume $Number$ with $NewCostume$' kind: #- category: 'looks' defaultValues: #(1) subCategory: #a2>
	self replaceCostume: name with: sel.
]

{ #category : #'handle ops' }
PhratchSpriteMorph >> resizeHandle [

	SpriteHandleMorph resize: self
]

{ #category : #'right button menu' }
PhratchSpriteMorph >> rightButtonMenu [
	"Present the right button menu."

	| menu stage |
	menu := MenuMorph new defaultTarget: self.
	menu add: 'grab screen region for new costume' translated action: #grabFromScreen.
	menu add: 'export this sprite' translated action: #exportObject.
	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	stage
		ifNotNil: [ 
			(stage phratchServer notNil and: [ stage phratchServer sessionInProgress ])
				ifTrue: [ menu add: 'share this sprite' translated action: #shareObject ] ].
	menu addLine.
	menu add: 'duplicate' translated action: #duplicate.
	menu add: 'clone' translated action: #spawn.
	menu add: 'delete' translated action: #undoableDeleteSprite.
	menu addLine.
	menu add: 'resize this sprite' translated action: #resizeHandle.
	menu add: 'rotate this sprite' translated action: #rotateHandle.
	self isNested
		ifTrue: [ menu addLine ].
	self hasSubsprites
		ifTrue: [ menu add: 'detach all subsprites' translated action: #unhingeAll ].
	ownerSprite ifNotNil: [ menu add: 'detach from ' , self ownerSprite objName action: #unhinge ].
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
	<phratchItem: 'rotation style' kind: #r category: 'motion' defaultValues: #() subCategory: #a6>
    ^ rotationStyle
]

{ #category : #accessing }
PhratchSpriteMorph >> rotationStyle: aSymbol [
	"Set my rotation style to #normal, #leftRight, or #none. Styles mean:
		#normal	-- smooth 360 degree rotation
		#leftRight	-- flip about the vertical axis
		#none		-- do not rotate"
	<phratchItem: 'set rotation style to $Rotation$' kind: #- category: 'motion' defaultValues: #() subCategory: #a6>
	rotationStyle := aSymbol.
	self costumeChanged.
	self positionTalkBubble.

]

{ #category : #'motion ops' }
PhratchSpriteMorph >> rotationStyleChanger [
    ^ #('normal' 'leftRight' 'none' )
]

{ #category : #'looks ops' }
PhratchSpriteMorph >> say: aValue [
	"Present a talk bubble with the given string."
	<phratchItem: 'say $String$' kind: #- category: 'looks' defaultValues: #('Hello!') subCategory: #a3>
	self bubble: aValue thinkFlag: false promptFlag: false.

]

{ #category : #'looks ops' }
PhratchSpriteMorph >> say: stringOrNum duration: durationSecs elapsed: elapsedMSecs from: startPoint [
	<phratchItem: 'say $String$ for $Number$ secs' kind: #t category: 'looks' defaultValues: #('Hello!' 2) subCategory: #a3>
	startPoint ifNil: [^ self say: stringOrNum].  "first call, show talk bubble"
	elapsedMSecs >= (1000 * durationSecs) ifTrue: [self sayNothing].  "clear bubble"

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
	<phratchItem: 'size' kind: #r category: 'looks' defaultValues: #() subCategory: #a4>
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

{ #category : #'panther actions' }
PhratchSpriteMorph >> setMyName: aName [
	<phratchItem: 'set sprite name to $String$' kind: #- category: 'sensing' defaultValues: #() subCategory: #a1>
	self objName: (aName asString).
]

{ #category : #'pen ops' }
PhratchSpriteMorph >> setPenHueTo: aNumber [
	"Set the pen hue to given number between 0 and 200. (That makes 100 the 'maximum' distance away from the original color on the color wheel.)"
	<phratchItem: 'set pen color to $Number$' kind: #- category: 'pen' defaultValues: #(0) subCategory: #a3>
	self undeleteAttribute: #penColor.
	self passiveSetPenHueTo: aNumber
]

{ #category : #'pen ops' }
PhratchSpriteMorph >> setPenShadeTo: aNumber [
	"Set the pen shade (lightness) to given number between 0 and 100. A shade of 0 is black, 100 is white, and 50 is fully saturated color."
	"Details: We don't want to get all the way to pure black or white, so we divide the range 0..50 by a number > 50 when computing the fraction of the original color to mix with black or white."
	<phratchItem: 'set pen shade to $Number$' kind: #- category: 'pen' defaultValues: #(50) subCategory: #a3>
	self undeleteAttribute: #penShade.
	self passiveSetPenShadeTo: aNumber
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
	<phratchItem: 'set size to $Number$' kind: #- category: 'looks' defaultValues: #(100) subCategory: #a4>
	self undeleteAttribute: #size.
	self passiveSetSizeTo: percent

]

{ #category : #'looks ops' }
PhratchSpriteMorph >> setStretchTo: percent [
	"Set x stretch percent relative to y. For example, a stretch of 200 stretches x by a factor of two relative to y while a stretch of 50 compresses x by a factor of two. As my stretch is changed, my x scale changes but my y scale remains the same."
	<phratchItem: 'set hStretch to $Number$' kind: #- category: 'looks' defaultValues: #(100) subCategory: #a5>
	| baseScale origExtent minStretch maxStretch newStretchFactor |
	baseScale := scalePoint y.
	origExtent := self costumeForm extent.
	minStretch := 8.0 / (baseScale * origExtent x).  "min width 8 pixels"
	maxStretch := 500.0 / (baseScale * origExtent x). "max width 500 pixels"
	newStretchFactor := ((percent max: 0) / 100.0) within: minStretch and: maxStretch.
	self scalePoint: baseScale * (newStretchFactor @ 1.0).

]

{ #category : #'panther actions' }
PhratchSpriteMorph >> setVStretchTo: percent [
	"Set x stretch percent relative to y. For example, a stretch of 200 stretches x by a factor of two relative to y while a stretch of 50 compresses x by a factor of two. As my stretch is changed, my x scale changes but my y scale remains the same."
	<phratchItem: 'set vStretch to $Number$' kind: #- category: 'looks' defaultValues: #(100) subCategory: #a5>
	| baseScale origExtent minStretch maxStretch newStretchFactor |
	baseScale := scalePoint x.
	origExtent := self costumeForm extent.
	minStretch := 8.0 / (baseScale * origExtent y).  "min height 8 pixels"
	maxStretch := 500.0 / (baseScale * origExtent y). "max height 500 pixels"
	newStretchFactor := ((percent max: 0) / 100.0) within: minStretch and: maxStretch.
	self scalePoint: baseScale * (1.0 @ newStretchFactor).
]

{ #category : #'looks ops' }
PhratchSpriteMorph >> show [
	"Make myself visible."
	<phratchItem: 'show' kind: #- category: 'looks' defaultValues: #() subCategory: #a6>
	self setHideFlagTo: false

]

{ #category : #'sensing ops' }
PhratchSpriteMorph >> showQuestion: aString [
	"Show the given question prompt."

	self bubble: aString thinkFlag: false promptFlag: true.

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

	<phratchItem: 'duplicate' kind: #r category: 'operators' defaultValues: #() subCategory: #b3>
	| stage child |
"
	(frame := self ownerOrYourselfThatIsA: PhratchFrameMorph) ifNil: [^ nil].
"
	stage := self ownerOrYourselfThatIsA: PhratchStageMorph.
	stage ifNil: [^ self].
	child := self fullCopy.
	child blocksBin allMorphsDo: [:m |
		(m isKindOf: BlockMorph) ifTrue: [m stop]].
	child unhinge; unhingeAll; initializeNodes.
	child prototype: self.
	child initializeVarsAndLists.
	child removeLocalBlockDefinitions.
	"frame workPane" stage addMorphFront: child.
	stage sprites addLast: child.
	child deleteAttributes: self deletedAttributes.
	child deleteAttribute: #costumes.
	child deleteAttribute: #sounds.

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

{ #category : #'pen ops' }
PhratchSpriteMorph >> stampCostume [
	"Stamp a copy of my current costume on the pen trails layer."
	<phratchItem: 'stamp' kind: #- category: 'pen' defaultValues: #() subCategory: #a4>
	| m |
	self step.  "update costume if necessary"
	(m := self ownerOrYourselfThatIsA: PhratchStageMorph)
		ifNotNil: [m stampCostume: self].

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

{ #category : #'object i/o' }
PhratchSpriteMorph >> storeFieldsOn: anObjStream [

	| oldP |
	self sayNothing.  "delete talk bubble before saving"

	"for backward compatability, remove offsetWhenRotated and subtract costume rotationCenter when saving"
	oldP := self position.
	self position: self position + offsetWhenRotated - costume rotationCenter.

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		visibility
		scalePoint
		rotationDegrees
		rotationStyle
		volume
		tempoBPM
		draggable
		sceneStates
		lists
		virtualScale
		ownerSprite
		subsprites
		rotateWithOwner
		refPos
		prototype
		deletedAttributes
	) on: anObjStream.

	self position: oldP.  "restore position"

]

{ #category : #nesting }
PhratchSpriteMorph >> subsprites [
	^subsprites
]

{ #category : #'looks ops' }
PhratchSpriteMorph >> think: aValue [
	"Present a thought bubble with the given string."
	<phratchItem: 'think $String$' kind: #- category: 'looks' defaultValues: #('Hmm...') subCategory: #a3>
	self bubble: aValue thinkFlag: true promptFlag: false.

]

{ #category : #'looks ops' }
PhratchSpriteMorph >> think: stringOrNum duration: durationSecs elapsed: elapsedMSecs from: startPoint [
	<phratchItem: 'think $String$ for $Number$ secs' kind: #t category: 'looks' defaultValues: #('Hmm...' 2) subCategory: #a3>
	startPoint ifNil: [^ self think: stringOrNum].  "first call, show think bubble"
	elapsedMSecs >= (1000 * durationSecs) ifTrue: [self sayNothing].  "clear bubble"

]

{ #category : #nesting }
PhratchSpriteMorph >> toggleRotationRule [

	rotateWithOwner := self rotateWithOwner not
]

{ #category : #'motion ops' }
PhratchSpriteMorph >> touching: anObject [
	"Answer true if any visible part of me touches a visible part of the given sprite."
	"Details: Currently uses the bounding box; should follow this up with comparison of visible pixels."
	<phratchItem: 'touching $Sprite$?' kind: #b category: 'sensing' defaultValues: #() subCategory: #sensor>
	| aSpriteOrSymbol stage intersection f1 f2 map oldVis result |
	aSpriteOrSymbol := self coerceSpriteArg: anObject.

	aSpriteOrSymbol = #mouse ifTrue: [
		(stage := self ownerOrYourselfThatIsA: PhratchStageMorph) ifNil: [^ false].
		result := self containsPoint: stage adjustedCursorPoint.
			result ifTrue: [^true].
	^(subsprites collect: [:sub | sub touching: anObject ]) includes: true ].

	aSpriteOrSymbol = #edge ifTrue: [^ self isOnEdge].

	(aSpriteOrSymbol isKindOf: self class) ifFalse: [^ false].

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

{ #category : #accessing }
PhratchSpriteMorph >> touchingColor: soughtColor [
	"Answer true if any of my non-transparent pixels touch pixels of the given color in the world."
	<phratchItem: 'touching color $ScreenColor$?' kind: #b category: 'sensing' defaultValues: #() subCategory: #sensor>
	| r myImage sensitivePixelsMask map imageBelowMe result |
	r := self bounds intersect: owner bounds.
	r area = 0 ifTrue: [^ false].

	"make a mask with 0 where transparent, 1 elsewhere"
	myImage := self imageForm asFormOfDepth: 16.
	sensitivePixelsMask := Form extent: myImage extent depth: 1.
	map := Bitmap new: (1 bitShift: (myImage depth min: 15)).
	map atAllPut: 1.
	map at: (Color transparent indexInMap: map) put: 0.
	sensitivePixelsMask
		copyBits: ((r origin - self position) extent: r extent)
		from: myImage form
		at: 0@0
		colorMap: map.

	"grab an image of the world below me"
	imageBelowMe := owner patchAt: r withoutWatchersAnd: self andNothingAbove: false.

	"intersect world pixels of the color we're looking for with sensitive pixels mask"
	map atAllPut: 0.  "clear map and reuse it"
	map at: (soughtColor indexInMap: map) put: 1.
	sensitivePixelsMask
		copyBits: imageBelowMe boundingBox
		from: imageBelowMe at: 0@0 clippingBox: imageBelowMe boundingBox
		rule: Form and
		fillColor: nil
		map: map.

	result := (sensitivePixelsMask tallyPixelValues at: 2) > 0.  "true if any pixels are 1"
	result ifTrue: [^true].
	^(subsprites collect: [:sub | sub touchingColor: soughtColor ]) includes: true.


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
	<phratchItem: 'turn $Number$ degrees' kind: #- category: 'motion' defaultValues: #(15) subCategory: #a1>
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
	<phratchItem: 'turn $Number$ degrees' kind: #- category: 'motion' defaultValues: #(15) subCategory: #a1>
	| newPos |
	"Turn clockwise the given number of degrees."

	self rotationDegrees: self rotationDegrees + degrees.

	subsprites do: [:sub |
		newPos := sub referencePosition rotateBy: degrees degreesToRadians about: self referencePosition.
		sub gotoX: newPos x y: newPos y ].
	self rotateWithOwner
		ifTrue: [ self spreadToFollowers ]


]

{ #category : #nesting }
PhratchSpriteMorph >> unhinge [

	(ownerSprite isKindOf: PhratchSpriteMorph)
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

{ #category : #'blocks API' }
PhratchSpriteMorph >> vFlip [
	<phratchItem: 'v flip' kind: #- category: 'looks' defaultValues: #() subCategory: #a5>
    costume form: (self form flipBy: #vertical centerAt: 0 @ 0).
    self costumeChanged
]

{ #category : #'panther actions' }
PhratchSpriteMorph >> vScale [
	<phratchItem: 'vStretch' kind: #r category: 'looks' defaultValues: #() subCategory: #a5>
	^ (100 * scalePoint y) rounded
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

{ #category : #'instance creation' }
PhratchSpriteMorph >> warn: t1 [ 
	<phratchItem: 'warn $String$' kind: #- category: 'sensing' defaultValues: #('Invalid input') subCategory: #a1>
    DialogBoxMorph warn: t1.
	self updateAfterPopUp.
]

{ #category : #'motion ops' }
PhratchSpriteMorph >> whenSpriteCreated [
	<phratchItem: 'when $Sprite$ created' kind: #C category: 'control' defaultValues: #() subCategory: #ahat>


]

{ #category : #geometry }
PhratchSpriteMorph >> width [
	<phratchItem: 'width' kind: #r category: 'looks' defaultValues: #() subCategory: #a4>
^super width
]

{ #category : #accessing }
PhratchSpriteMorph >> xpos [
	<phratchItem: 'x position' kind: #r category: 'motion' defaultValues: #() subCategory: #a7>
	| att |
	att := #xPosition.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ self referencePosition x

]

{ #category : #accessing }
PhratchSpriteMorph >> xpos: aNumber [ 
	<phratchItem: 'set x to $Number$' kind: #- category: 'motion' defaultValues: #(0) subCategory: #a4>
	self undeleteAttribute: #xPosition.
	self passiveXpos: aNumber
]

{ #category : #accessing }
PhratchSpriteMorph >> ypos [
	<phratchItem: 'y position' kind: #r category: 'motion' defaultValues: #() subCategory: #a7>
	| att |
	att := #yPosition.
	self prototype ifNotNil: [
		(self deletedAttributes includes: att) ifTrue: [
			^ self prototype get: att]].

	^ self referencePosition y

]

{ #category : #accessing }
PhratchSpriteMorph >> ypos: aNumber [ 
	<phratchItem: 'set y to $Number$' kind: #- category: 'motion' defaultValues: #(0) subCategory: #a4>
	self undeleteAttribute: #yPosition.
	self passiveYpos: aNumber
]
