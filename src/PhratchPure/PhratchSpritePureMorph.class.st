Class {
	#name : #PhratchSpritePureMorph,
	#superclass : #PhratchSpriteMorph,
	#instVars : [
		'connectedRobot'
	],
	#category : #PhratchPure
}

{ #category : #'as yet unclassified' }
PhratchSpritePureMorph class >> blockSpecs [

	| blocks |
	blocks := #(
		'pure'
			('move %n cm'				-	forward: 100)
			-
			('go to x:%n y:%n'				-	gotoX:y: 0 0)
			-
			('set x to %n'					-	xpos: 0)
			('set y to %n'					-	ypos: 0)
			('set orientation to %n'			-	heading: 0)
			-
			('x position'						r	xpos)
			('y position'						r	ypos)
			('direction'						r	heading)
			-
			('laser position'						r	laserpos)
			('telemeter position'						r	telemeterpos)
			('infrared position'						r	infraredpos)
		).

	^ blocks, super blockSpecs

]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> forward: distance [

	| currentPosition nextPosition |
	super forward: distance.
	currentPosition := connectedRobot localizationService currentPosition.
	nextPosition :=  (currentPosition x + (distance/100)) @ (currentPosition y). 
	connectedRobot trajectoryService 
		insertSegmentFrom:  currentPosition to: nextPosition  speed: 0.25;
		startMotion.
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> gotoX: x y: y [

	| currentPosition |
	super gotoX: x y: y.
	currentPosition := connectedRobot localizationService currentPosition.
	self trajectoryService 
		insertSegmentFrom:  currentPosition to: (x/100)@(y/100)  speed: 0.25;
		startMotion.
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> heading [

	super heading.
	^ connectedRobot localizationService currentPosition orientation.
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> heading: headingDegrees [

	super heading: headingDegrees.
	^ connectedRobot localizationService x: self xpos y: self ypos orientation: headingDegrees.
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> infraredpos [

	| laser notification |
	laser := connectedRobot irTelemeterService.
	laser enableNotificationsEvery: 10.
	notification := self notificationOrNilFrom: laser.
	^ notification distances
]

{ #category : #'as yet unclassified' }
PhratchSpritePureMorph >> initializeKompai1 [

	connectedRobot := PNGRobulabHandcodedFactory kompai1.
	self setMyName: 'Kompai1'.
	"self xpos: 0; ypos:0.
	"
	self initializeSkin.
	^ connectedRobot
]

{ #category : #'as yet unclassified' }
PhratchSpritePureMorph >> initializeKompai2 [

	connectedRobot := PNGRobulabHandcodedFactory kompai2.
	self setMyName: 'Kompai2'.
	"self xpos: 0; ypos:0."
	self initializeSkin.
	^ connectedRobot
]

{ #category : #'as yet unclassified' }
PhratchSpritePureMorph >> initializeSkin [
	| botSkin botImage |
	botSkin := Form fromFileNamed: (FileSystem workingDirectory / 'ScratchSkin' / 'bot.png').

	botImage := ImageMedia new form: botSkin.
	botImage mediaName: (self unusedMediaNameFromBaseName: (self defaultImageMedia mediaName)).
	media addLast: botImage.
	self lookLike: botImage mediaName.
	self updateMediaCategory.
	
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> laserpos [

	| laser notification |
	laser := connectedRobot laserService.
	laser enableNotificationsEvery: 10.
	notification := self notificationOrNilFrom: laser.
	^ notification distances
]

{ #category : #'as yet unclassified' }
PhratchSpritePureMorph >> stopPlaying [
	"Reset my transient state, such as pen down."

	super stopPlaying.
	connectedRobot emergencyStop.


]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> telemeterpos [

	| laser notification |
	laser := connectedRobot sonarTelemeterService.
	laser enableNotificationsEvery: 10.
	notification := self notificationOrNilFrom: laser.
	^ notification distances
]

{ #category : #'as yet unclassified' }
PhratchSpritePureMorph >> viewerPageForPure [
	"Answer a morph containing my variables."

	| page addButton x y maxX addButton2 |
	page := PhratchBlockPaletteMorph new
		color: (Color r: 0.8 g: 0.8 b: 1.0);
		borderWidth: 0.

	addButton := PhratchFrameMorph
		buttonLabel: 'Make kompai1' localized
		selector: #addKompai1.
	"(self isKindOf: PhratchSpritePureMorph) ifFalse: [addButton actionSelector: #addKompai1WithAlert]."

	addButton2 := PhratchFrameMorph
		buttonLabel: 'Make kompai2' localized
		selector: #addKompai2.
	"(self isKindOf: PhratchSpritePureMorph) ifFalse: [addButton actionSelector: #addKompai2WithAlert]."
	
	x := 13.
	page addMorph: (addButton target: self; position: x@7).
	y := addButton bottom + 3.
	
	y := y + 0.
	page addMorph: (addButton2 target: self; position: x@30).
	y := addButton2 bottom + 3.

	self addGenericPureBlocksTo: page x: x y: y.
	maxX := page submorphs inject: 0 into: [:t :m | t max: m right].
	page extent: (maxX + 10) @ y.
	^ page
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> xpos [

	super xpos.
	^ connectedRobot localizationService currentPosition x * 100.
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> xpos: aNumber [ 

	super xpos: (aNumber/100) .
	^ connectedRobot localizationService x: (aNumber/100) y: self ypos orientation: self heading.
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> ypos [

	super ypos.
	^ connectedRobot localizationService currentPosition x * 100.
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> ypos: aNumber [ 

	super ypos: (aNumber/100).
	^ connectedRobot localizationService x: self xpos y: (aNumber/100) orientation: self heading.
]
