Extension { #name : #PhratchSpriteMorph }

{ #category : #'*PhratchMotion' }
PhratchSpriteMorph >> arrowMove: i1 [ 
"Move the sprite based on the arrow keys"
"Made using Scramble by Hardmath123"
<phratchItem: 'Arrow key move with speed $Number$' kind: #- category: 'motion' defaultValues: #() subCategory: #a1 special: #()>
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

{ #category : #'*PhratchMotion' }
PhratchSpriteMorph >> betweenX: t1 Y: t2 X: t3 Y: t4 [
"Make the sprite goes between two positions"
<phratchItem: 'go in between x: $Number$ y: $Number$ and x: $Number$ y: $Number$' kind: #- category: 'motion' defaultValues: #() subCategory: #a3 special: #()>
| newX newY |

newX:= (t1 + t3) / 2.
newY:= (t2 + t4) / 2.
self referencePosition: newX @ newY
]

{ #category : #'*PhratchMotion' }
PhratchSpriteMorph >> bounceIfBoolean: condition [
	"Set my direction to bounce off the given condition is true"
	<phratchItem: 'if $Boolean$ bounce' kind: #- category: 'motion' defaultValues: #() subCategory: #a5 special: #()>
     condition ifTrue: [self turnRight: 180]
]

{ #category : #'*PhratchMotion' }
PhratchSpriteMorph >> bounceOffEdge [
	"Set my direction to bounce off the edge."
	<phratchItem: 'if on edge, bounce' kind: #- category: 'motion' defaultValues: #() subCategory: #a5 special: #()>
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

{ #category : #'*PhratchMotion' }
PhratchSpriteMorph >> changeXposBy: aNumber [
	"Move right by the given amount."
	<phratchItem: 'change x by $Number$' kind: #- category: 'motion' defaultValues: #(10) subCategory: #a4 special: #()>
	self xpos: self xpos + aNumber

"
	self referencePosition: self referencePosition + (aNumber@0).
	self spread
"
]

{ #category : #'*PhratchMotion' }
PhratchSpriteMorph >> changeYposBy: aNumber [
	"Move up by the given amount."
	<phratchItem: 'change y by $Number$' kind: #- category: 'motion' defaultValues: #(10) subCategory: #a4 special: #()>
	self ypos: self ypos + aNumber

"
	self referencePosition: self referencePosition + (0@aNumber).
	self spread
"
]

{ #category : #'*PhratchMotion' }
PhratchSpriteMorph >> distance: t1 X: t2 Y: t3 [ 
	"Make a part of the way to the given point"
	<phratchItem: 'go $Number$ of the way to x: $Number$ y: $Number$' kind: #- category: 'motion' defaultValues: #() subCategory: #a3 special: #()>
    | newX newY |
    newX := t1 * 0.01 * (t2 - self xpos).
    newY := t1 * 0.01 * (t3 - self ypos).
    self gotoX: newX + self xpos y: newY + self ypos
]

{ #category : #'*PhratchMotion' }
PhratchSpriteMorph >> forward: distance [
	"Move the object forward (i.e., the direction of its heading) by the given distance.
	Avoid infinite or NaN coordinates"
	<phratchItem: 'move $Number$ steps' kind: #- category: 'motion' defaultValues: #() subCategory: #a1 special: #()>
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

{ #category : #'*PhratchMotion' }
PhratchSpriteMorph >> glideSecs: duration toX: endX y: endY elapsed: elapsed from: startPoint [
	"Interpolate my position from my current postion to the given x and y over the given duration. If startPoint is nil, just answer my current position; this sets the starting point for the interpolation."

	<phratchItem: 'glide $Number$ secs to x:$Number$ y:$Number$' kind: #TimeBlockMorph category: 'motion' defaultValues: #(1 50 50)
	subCategory: #a3 special: #()>
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

{ #category : #'*PhratchMotion' }
PhratchSpriteMorph >> gotoSpriteOrMouse: anObject [
	"Go to the given sprite or mouse position."
	<phratchItem: 'go to $Sprite$' kind: #- category: 'motion' defaultValues: #() subCategory: #a3 special: #()>
	| x y len aSpriteOrSymbol p |
	(anObject isPhratchListMorph) ifTrue: [ "try to go the coordinates specified in a list"
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
	(aSpriteOrSymbol isPhratchSpriteMorph) ifFalse: [^ self].
	p := aSpriteOrSymbol referencePosition.
	self gotoX: p x y: p y.


]

{ #category : #'*PhratchMotion' }
PhratchSpriteMorph >> makeDrag [
	"Make me draggable during the execution"
	<phratchItem: 'make draggable' kind: #- category: 'motion' defaultValues: #() subCategory: #a8 special: #()>
	draggable := true.
]

{ #category : #'*PhratchMotion' }
PhratchSpriteMorph >> makeNoDrag [
	"Make me undraggable during the execution"
	<phratchItem: 'make undraggable' kind: #- category: 'motion' defaultValues: #() subCategory: #a8 special: #()>
	draggable := false.
]

{ #category : #'*PhratchMotion' }
PhratchSpriteMorph >> pointToX: x y: y [
	"Set my heading to point at the given point."
	<phratchItem: 'point at x:$Number$ y:$Number$' kind: #- category: 'motion' defaultValues: #() subCategory: #a6 special: #()>
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

{ #category : #'*PhratchMotion' }
PhratchSpriteMorph >> pointTowards: anObject [
	"Point toward the given sprite."
	<phratchItem: 'point towards $Sprite$' kind: #- category: 'motion' defaultValues: #() subCategory: #a2 special: #()>
	| aSpriteOrSymbol p |
	aSpriteOrSymbol := self coerceSpriteArg: anObject.

	aSpriteOrSymbol = #mouse ifTrue: [^ self pointToX: self mouseX y: self mouseY].
	(aSpriteOrSymbol isPhratchSpriteMorph) ifFalse: [^ self].
	p := aSpriteOrSymbol referencePosition.
	self pointToX: p x y: p y.


]

{ #category : #'*PhratchMotion' }
PhratchSpriteMorph >> randxypos [
	"Point me to a random position"
	<phratchItem: 'point at random coordinate' kind: #- category: 'motion' defaultValues: #() subCategory: #a6 special: #()>
    self pointToX: (self randomFrom: -240 to: 240)
        y: (self randomFrom: -180 to: 180)
]
