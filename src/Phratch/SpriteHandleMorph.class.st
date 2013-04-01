"
I am an interactive sprite handle, sort of like a halo button in Scratch. I am meant to be a singleton. Currently I can only resize or rotate a sprite.
"
Class {
	#name : #SpriteHandleMorph,
	#superclass : #Morph,
	#instVars : [
		'type',
		'offset',
		'target',
		'reversed'
	],
	#classVars : [
		'Current'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'instance creation' }
SpriteHandleMorph class >> resize: aSprite [
	"create my single instance and set it to resize aSprite"	

	self vanish.
	Current := self new 
		type: #resize;
		form: (PhratchFrameMorph skinAt: #spriteResize); 
		target: aSprite;
		setBalloonText: 'drag to resize' localized.
	^ Current

]

{ #category : #'instance creation' }
SpriteHandleMorph class >> rotate: aSprite [
	"create my single instance and set it to rotate aSprite"	

	self vanish.
	Current := self new 
		type: #rotate;
		form: (PhratchFrameMorph skinAt: #spriteRotate); 
		target: aSprite;
		setBalloonText: 'drag to rotate' localized.
	^ Current

]

{ #category : #accessing }
SpriteHandleMorph class >> vanish [
	"delete my single instance"

	Current ifNotNil: [
		Current delete.
		Current := nil ]
]

{ #category : #testing }
SpriteHandleMorph >> atMax [
	"answer true if the target sprite cannot be made any bigger"

	| maxExtent |
	maxExtent := PhratchFrameMorph workpaneExtent asFloatPoint * 1.5.
	^(target extent x >= maxExtent x) or:
		[target extent y >= maxExtent y]
]

{ #category : #testing }
SpriteHandleMorph >> atMin [
	"answer true if the target sprite cannot be made any smaller"

	| minExtent|
	minExtent := target costumeForm extent min: 10@10.
	^(target extent x <= minExtent x) or: [target extent y <= minExtent y].

]

{ #category : #private }
SpriteHandleMorph >> form: aForm [

	(self submorphs at: 1) form: aForm.
	self extent: (self submorphs at: 1) extent.

]

{ #category : #'event handling' }
SpriteHandleMorph >> handlesMouseDown: evt [
	"Return true if this morph wants to receive mouseDown events" 

	^true
]

{ #category : #'event handling' }
SpriteHandleMorph >> handlesMouseOver: evt [

	^ true

]

{ #category : #initialization }
SpriteHandleMorph >> initialize [

	super initialize.
	reversed := false.
	self
		color: Color transparent;
		addMorph: ImageMorph new.

]

{ #category : #'event handling' }
SpriteHandleMorph >> mouseDown: evt [

	#resize = type
		ifTrue: [
			offset := evt hand cursorPoint x - self left.
			^self ].
	
	offset := self targetBounds center dist: self center.
]

{ #category : #'event handling' }
SpriteHandleMorph >> mouseEnter: evt [

	(#resize = type)
		ifTrue: [self form: (PhratchFrameMorph skinAt: #spriteResizeOver)]
		ifFalse: [self form: (PhratchFrameMorph skinAt: #spriteRotateOver)].

]

{ #category : #'event handling' }
SpriteHandleMorph >> mouseLeave: evt [

	(#resize = type)
		ifTrue: [self form: (PhratchFrameMorph skinAt: #spriteResize)]
		ifFalse: [self form: (PhratchFrameMorph skinAt: #spriteRotate)].

]

{ #category : #'event handling' }
SpriteHandleMorph >> mouseMove: evt [

	| dist tc |
	offset ifNil: [^self].

	#resize = type 
		ifTrue: [
			dist := evt hand cursorPoint x - offset - self left.
			reversed
				ifTrue: [((dist negative & self atMax) | 
					(dist negative not & self atMin)) ifTrue: [^self ]]
				ifFalse: [((dist negative & self atMin) | 
					(dist negative not & self atMax)) ifTrue: [^self ]].
			^self 
				left: self left + dist;
				resizeTarget ].

	tc := self targetBounds center.
	self 
		center: (tc + (Point r: offset degrees: (evt cursorPoint - tc)
			 theta radiansToDegrees rounded));
		rotateTarget



]

{ #category : #'event handling' }
SpriteHandleMorph >> mouseUp: evt [

	offset := nil
]

{ #category : #'sprite handling' }
SpriteHandleMorph >> resizeTarget [

	| factor  tb|
	tb := self targetBounds.
	reversed
		ifTrue: [ factor := (self center x - tb center x) / (tb left - tb center x) ]
		ifFalse: [ factor := (self center x - tb center x) / (tb right - tb center x) ].

	target multiplySizeBy: factor
]

{ #category : #'sprite handling' }
SpriteHandleMorph >> rotateTarget [

	reversed
		ifTrue: [target heading: (self center - self targetBounds center) 
			theta radiansToDegrees rounded - 90]
		ifFalse: [target heading: (self center - self targetBounds center) 
			theta radiansToDegrees rounded + 90 ]
]

{ #category : #accessing }
SpriteHandleMorph >> target: aSprite [
	"show me"

	| stage tb x |
	target := aSprite.
	stage := target ownerOrYourselfThatIsA: PhratchStageMorph.
	tb := self targetBounds.

	"make sure the target sprite is onstage"
	stage notNil & stage fullContainsPoint: target center.
	(stage notNil and: [stage bounds containsPoint: target center]) ifFalse: [
		target referencePosition: 0@0.
		tb := self targetBounds].
	self	openInWorld.

	#resize = type
		ifTrue: [
			target xpos > 0
				ifTrue: [
					reversed := true.
					x := tb left]
				ifFalse: [x := tb right].
			^self center: x @ tb center y].

	(target xpos > 0 & (target heading > 0))
		ifTrue: [
			reversed := true.
			self position: (tb center + (Point r: (tb width/2) degrees: target rotationDegrees + 180))]
		ifFalse: [self center: (tb center + (Point r: (tb width/2) degrees: target rotationDegrees))].

]

{ #category : #private }
SpriteHandleMorph >> targetBounds [
	"private - answer the target's bounds as it displayed on screen, i.e. in q-size mode"

	| stage ratio home center |

	ratio := 1.
	stage := target ownerOrYourselfThatIsA: PhratchStageMorph.
	stage notNil & stage isQuarterSize ifTrue: [ratio := 0.5 ].
	home:= 0 @ 0.
	stage ifNotNil: [home := stage position ].

	center := target center - home * ratio + home.
	^Rectangle center: center extent: target extent * ratio
]

{ #category : #private }
SpriteHandleMorph >> type: aSymbol [
	"#resize / #rotate"

	type := aSymbol.

]
