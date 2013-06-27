Class {
	#name : #PhratchSpritePureMorph,
	#superclass : #PhratchSpriteMorph,
	#instVars : [
		'connectedRobot'
	],
	#category : #PhratchPure
}

{ #category : #'motion ops' }
PhratchSpritePureMorph >> forward: distance [
	<phratchItem: 'move $Number$ cm' kind: #- category: 'pure' defaultValues: #(100) subCategory: 1>
	
	| currentPosition nextPosition |
	super forward: distance.
	[currentPosition := connectedRobot localizationService currentPosition.
	nextPosition :=  (currentPosition x + (distance/100)) @ (currentPosition y). 
	connectedRobot trajectoryService 
		insertSegmentFrom:  currentPosition to: nextPosition  speed: 0.25;
		startMotion.
	] on: Exception do: [ Transcript show: 'forward:'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> gotoX: x y: y [

	<phratchItem: 'go to x:$Number$ y:$Number$' kind: #- category: 'pure' defaultValues: #(0 0) subCategory: 2>
	
	| currentPosition |
	super gotoX: x y: y.
	[currentPosition := connectedRobot localizationService currentPosition.
	self trajectoryService 
		insertSegmentFrom:  currentPosition to: (x/100)@(y/100)  speed: 0.25;
		startMotion.
	] on: Exception do: [ Transcript show: 'gotox:y:'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> heading [

	<phratchItem: 'direction' kind: #r category: 'pure' defaultValues: #() subCategory: 4>
	
	"super heading."
	[^ connectedRobot localizationService currentPose orientation.
	] on: Exception do: [ Transcript show: 'heading'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> heading: headingDegrees [

	<phratchItem: 'set orientation to $Number$' kind: #- category: 'pure' defaultValues: #(0) subCategory: 3>
	"super heading: headingDegrees."
	[^ connectedRobot localizationService x: self xpos y: self ypos orientation: headingDegrees.
	] on: Exception do: [ Transcript show: 'heading:'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> infraredpos [

	| laser notification |
	laser := connectedRobot irTelemeterService.
	[laser enableNotificationsEvery: 100.]on: Exception do:[].
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
	[laser enableNotificationsEvery: 100.]on: Exception do:[].
	notification := self notificationOrNilFrom: laser.
	^ notification distances
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> minInfraredpos [

	<phratchItem: 'min infrared position' kind: #r category: 'pure' defaultValues: #() subCategory: 5>
	| laser notification |
	laser := connectedRobot irTelemeterService.
	[laser enableNotificationsEvery: 100.]on: Exception do:[].
	notification := self notificationOrNilFrom: laser.
	
	^ notification distances min
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> minLaserpos [

	<phratchItem: 'min laser position' kind: #r category: 'pure' defaultValues: #() subCategory: 5>
	| laser notification |
	laser := connectedRobot laserService.
	[laser enableNotificationsEvery: 100.]on: Exception do:[].
	notification := self notificationOrNilFrom: laser.
	^ notification distances min
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> minTelemeterpos [
	
	<phratchItem: 'min telemeter position' kind: #r category: 'pure' defaultValues: #() subCategory: 5>
	| laser notification |
	laser := connectedRobot sonarTelemeterService.
	[laser enableNotificationsEvery: 100.]on: Exception do:[].
	notification := self notificationOrNilFrom: laser.
	
	^ notification distances min
]

{ #category : #'as yet unclassified' }
PhratchSpritePureMorph >> notificationOrNilFrom: notifyingService [
	| semaphore notification |
	semaphore := Semaphore new.
	notifyingService onNotificationDo: [ :notif | 
			notification := notif.
			semaphore signal ].
	semaphore waitTimeoutMSecs: 500.
	^ notification
]

{ #category : #'as yet unclassified' }
PhratchSpritePureMorph >> stopPlaying [
	"Reset my transient state, such as pen down."

	super stopPlaying.
	connectedRobot trajectoryService emergencyStop.


]

{ #category : #'as yet unclassified' }
PhratchSpritePureMorph >> stopRobot [
	<phratchItem: 'Stop robot' kind: #- category: 'pure' defaultValues: #() subCategory: 1>
	connectedRobot trajectoryService emergencyStop.


]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> telemeterpos [

	| laser notification |
	laser := connectedRobot sonarTelemeterService.
	[laser enableNotificationsEvery: 100.]on: Exception do:[].
	notification := self notificationOrNilFrom: laser.
	^ notification distances
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> xpos [

	<phratchItem: 'x position' kind: #r category: 'pure' defaultValues: #() subCategory: 4>
	"super xpos."
	[^ connectedRobot localizationService currentPosition x * 100.
	] on: Exception do: [ Transcript show: 'xpos'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> xpos: aNumber [ 

	<phratchItem: 'set x to $Number$' kind: #- category: 'pure' defaultValues: #(0) subCategory: 3>
	"super xpos: (aNumber/100) ."
	[^ connectedRobot localizationService x: (aNumber/100) y: self ypos orientation: self heading.
	] on: Exception do: [ Transcript show: 'xpos:'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> ypos [

	<phratchItem: 'y position' kind: #r category: 'pure' defaultValues: #() subCategory: 4>
	"super ypos."
	[^ connectedRobot localizationService currentPosition x * 100.
	] on: Exception do: [ Transcript show: 'ypos'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> ypos: aNumber [ 

	<phratchItem: 'set y to $Number$' kind: #- category: 'pure' defaultValues: #(0) subCategory: 3>
	"super ypos: (aNumber/100)."
	[^ connectedRobot localizationService x: self xpos y: (aNumber/100) orientation: self heading.
	] on: Exception do: [ Transcript show: 'ypos:'; cr ]
]
