Class {
	#name : #PhratchSpritePureMorph,
	#superclass : #PhratchSpriteMorph,
	#instVars : [
		'connectedRobot'
	],
	#category : #PhratchPure
}

{ #category : #'motion ops' }
PhratchSpritePureMorph >> cleanNotif [

	<phratchItem: 'clean notification services' kind: #- category: 'pure' defaultValues: #() subCategory: #brick special: #()>
	
	"super heading."
	[^ connectedRobot deleteAllNotifyingServices.
	] on: Exception do: [ Transcript show: 'heading'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> clearTrajectory [

	<phratchItem: 'clear trajectory' kind: #- category: 'pure' defaultValues: #(0 0) subCategory: #trajectory special: #()>
	
	[
	connectedRobot trajectoryService
		clearTrajectory .
	] on: Exception do: [ Transcript show: 'movestep'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> closeConnection [

	<phratchItem: 'close connection' kind: #- category: 'pure' defaultValues: #() subCategory: #brick special: #()>
	
	"super heading."
	[^ connectedRobot finalize.
	] on: Exception do: [ Transcript show: 'heading'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> dir [

	<phratchItem: 'direction' kind: #ReporterWatcherBlockMorph category: 'pure' defaultValues: #() subCategory: #localization special: #()>
	
	"super heading."
	[^ connectedRobot localizationService currentPose orientation.
	] on: Exception do: [ Transcript show: 'heading'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> dir: headingDegrees [

	<phratchItem: 'set orientation to $Number$' kind: #- category: 'pure' defaultValues: #(0) subCategory: #localization special: #()>
	"super heading: headingDegrees."
	[^ connectedRobot localizationService x: self xposition y: self yposition orientation: headingDegrees.
	] on: Exception do: [ Transcript show: 'heading:'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> forwardRobot: distance [
	<phratchItem: 'move $Number$ cm' kind: #- category: 'pure' defaultValues: #(100) subCategory: #localization special: #()>
	
	| currentPosition nextPosition |
	"super forward: distance."
	[currentPosition := connectedRobot localizationService currentPosition.
	nextPosition :=  (currentPosition x + (distance/100)) @ (currentPosition y). 
	connectedRobot trajectoryService 
		insertSegmentFrom:  currentPosition to: nextPosition  speed: 0.25;
		startMotion.
	] on: Exception do: [ Transcript show: 'forward:'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> getServices [

	<phratchItem: 'get all services' kind: #ReporterBlockMorph  category: 'pure' defaultValues: #() subCategory: #brick special: #()>
	
	[^ (connectedRobot directoryService allServices) collect:[:e | e class name asString].
	] on: Exception do: [ Transcript show: 'heading'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> goTowardX: x y: y [

	<phratchItem: 'go toward x:$Number$ cm y:$Number$ cm' kind: #- category: 'pure' defaultValues: #(0 0) subCategory: #localization special: #()>
	
	| currentPosition nextPosition |
	"super gotoX: x y: y."
	[currentPosition := connectedRobot localizationService currentPosition.
	nextPosition :=  (currentPosition x + (x/100)) @ (currentPosition y + (y/100)). 
	connectedRobot trajectoryService 
		insertSegmentFrom:  currentPosition to: nextPosition speed: 0.25;
		startMotion.
	] on: Exception do: [ Transcript show: 'gotowardx:y:'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> goX: x y: y [

	<phratchItem: 'go to x:$Number$ cm y:$Number$ cm' kind: #- category: 'pure' defaultValues: #(0 0) subCategory: #localization special: #()>
	
	| currentPosition |
	"super gotoX: x y: y."
	[currentPosition := connectedRobot localizationService currentPosition.
	connectedRobot trajectoryService 
		insertSegmentFrom:  currentPosition to: (x/100)@(y/100)  speed: 0.25;
		startMotion.
	] on: Exception do: [ Transcript show: 'gotox:y:'; cr ]
]

{ #category : #'as yet unclassified' }
PhratchSpritePureMorph >> initializeSkin [
	| botSkin botImage |
	botSkin := Form fromFileNamed: (FileSystem workingDirectory / 'ScratchSkin' / 'phratchicon.png').

	botImage := ImageMedia new form: botSkin.
	botImage mediaName: (self unusedMediaNameFromBaseName: (self defaultImageMedia mediaName)).
	media addLast: botImage.
	self lookLike: botImage mediaName.
	self updateMediaCategory.
	
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> insertSegmentFromX: xorigin y: yorigin toX: xdestination y: ydestination speed: speed [

	<phratchItem: 'create segment from x $Number$ cm y $Number$ cm to x $Number$ cm y $Number$ cm speed $Number$' kind: #- category: 'pure' defaultValues: #(0 0) subCategory: #trajectory special: #()>
	
	[
	connectedRobot trajectoryService
		insertSegmentFrom: (xorigin/100)@(yorigin/100) to: (xdestination/100)@(ydestination/100) speed: speed .
	] on: Exception do: [ Transcript show: 'movestep'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> ip: aString port: portNumber [ 

	<phratchItem: 'connect to $String$ port $Number$' kind: #- category: 'pure' defaultValues: #('192.168.1.2' 60000) subCategory: #brick special: #()>
	
	"super heading."
	| sub b |
	[
	b := ByteArray new: 4.
	sub := aString subStrings: '.'.
	b byteAt: 1 put: (sub first asInteger).
	b byteAt: 2 put: (sub second asInteger).
	b byteAt: 3 put: (sub third asInteger).
	b byteAt: 4 put: (sub fourth asInteger).
		
	connectedRobot := PNGRobulabHandcodedFactory kompaiVersion2010Pure41Ip: b port: portNumber serial: '10-1-6206-2'.
	self setMyName: 'Kompai'.
	"self xpos: 0; ypos:0."
	self initializeSkin.
	
	^ connectedRobot.
	] on: Exception do: [ Transcript show: 'heading'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> isConnected [

	<phratchItem: 'is connected' kind: #ReporterWatcherBlockMorph category: 'pure' defaultValues: #() subCategory: #brick special: #()>
	
	[^ connectedRobot bridge socket isConnected] on: Error do:[^false]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> minInfraredpos [

	<phratchItem: 'min infrared position' kind: #ReporterWatcherBlockMorph category: 'pure' defaultValues: #() subCategory: #sensor special: #()>
	| laser notification |
	laser := connectedRobot irTelemeterService.
	[laser enableNotificationsEvery: 100.]on: Exception do:[].
	notification := self notificationOrNilFrom: laser.
	
	[^ notification distances min] on: Error do: [ ^'NaN' ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> minLaserpos [

	<phratchItem: 'min laser position' kind: #ReporterWatcherBlockMorph category: 'pure' defaultValues: #() subCategory: #sensor special: #()>
	| laser notification |
	laser := connectedRobot laserService.
	[laser enableNotificationsEvery: 100.]on: Exception do:[].
	notification := self notificationOrNilFrom: laser.
	[^ notification distances min] on: Error do: [ ^'NaN' ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> minTelemeterpos [
	
	<phratchItem: 'min telemeter position' kind: #ReporterWatcherBlockMorph category: 'pure' defaultValues: #() subCategory: #sensor special: #()>
	| laser notification |
	laser := connectedRobot sonarTelemeterService.
	[laser enableNotificationsEvery: 100.]on: Exception do:[].
	notification := self notificationOrNilFrom: laser.
	
	[^ notification distances min] on: Error do: [ ^'NaN' ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> moveAt: aLinearSpeed and: anAngularSpeed [ 

	<phratchItem: 'move at speed $Number$ angular speed $Number$' kind: #- category: 'pure' defaultValues: #(0 0) subCategory: #differential special: #()>
	
	[
	connectedRobot differentialService
		moveAt: aLinearSpeed and: anAngularSpeed .
	] on: Exception do: [ Transcript show: 'movestep'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> moveStepDist: aDist at: aSpeed [

	<phratchItem: 'move steps distance:$Number$ speed:$Number$' kind: #- category: 'pure' defaultValues: #(0 0) subCategory: #step special: #()>
	
	|   |
	"super gotoX: x y: y."
	[
	connectedRobot stepService
		moveForward:  aDist at: aSpeed.
	] on: Exception do: [ Transcript show: 'movestep'; cr ]
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

{ #category : #'motion ops' }
PhratchSpritePureMorph >> resetPosition [

	<phratchItem: 'reset position' kind: #- category: 'pure' defaultValues: #(0) subCategory: #localization special: #()>
	"super ypos: (aNumber/100)."
	[^ connectedRobot localizationService resetPose.
	] on: Exception do: [ Transcript show: 'ypos:'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> rotate: aDist at: aSpeed [

	<phratchItem: 'rotate steps value $Number$ speed $Number$' kind: #- category: 'pure' defaultValues: #(0 0) subCategory: #step special: #()>
	
	[
	connectedRobot stepService
		rotate:  aDist at: aSpeed.
	] on: Exception do: [ Transcript show: 'movestep'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> startMotion [

	<phratchItem: 'start motion' kind: #- category: 'pure' defaultValues: #(0 0) subCategory: #trajectory special: #()>
	
	[
	connectedRobot trajectoryService
		startMotion .
	] on: Exception do: [ Transcript show: 'movestep'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> stepStop [

	<phratchItem: 'stop steping' kind: #- category: 'pure' defaultValues: #(0 0) subCategory: #step special: #()>
	
	[
	connectedRobot stepService
		stop.
	] on: Exception do: [ Transcript show: 'movestep'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> stopMotion [

	<phratchItem: 'pause motion' kind: #- category: 'pure' defaultValues: #(0 0) subCategory: #trajectory special: #()>
	
	[
	connectedRobot trajectoryService
		stopMotion .
	] on: Exception do: [ Transcript show: 'movestep'; cr ]
]

{ #category : #'as yet unclassified' }
PhratchSpritePureMorph >> stopPlaying [
	"Reset my transient state, such as pen down."

	super stopPlaying.
	[connectedRobot trajectoryService emergencyStop] ifError: [].

]

{ #category : #'as yet unclassified' }
PhratchSpritePureMorph >> stopRobot [
	<phratchItem: 'stop robot' kind: #- category: 'pure' defaultValues: #() subCategory: #trajectory special: #()>
	connectedRobot trajectoryService emergencyStop.


]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> xposition [

	<phratchItem: 'x position' kind: #ReporterWatcherBlockMorph category: 'pure' defaultValues: #() subCategory: #localization special: #()>
	"super xpos."
	[^ connectedRobot localizationService currentPosition x * 100.
	] on: Exception do: [ Transcript show: 'xpos'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> xposition: aNumber [ 

	<phratchItem: 'set x to $Number$' kind: #- category: 'pure' defaultValues: #(0) subCategory: #localization special: #()>
	"super xpos: (aNumber/100) ."
	[^ connectedRobot localizationService x: (aNumber/100) y: self yposition orientation: self heading.
	] on: Exception do: [ Transcript show: 'xpos:'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> yposition [

	<phratchItem: 'y position' kind: #ReporterWatcherBlockMorph category: 'pure' defaultValues: #() subCategory: #localization special: #()>
	"super ypos."
	[^ connectedRobot localizationService currentPosition x * 100.
	] on: Exception do: [ Transcript show: 'ypos'; cr ]
]

{ #category : #'motion ops' }
PhratchSpritePureMorph >> yposition: aNumber [ 

	<phratchItem: 'set y to $Number$' kind: #- category: 'pure' defaultValues: #(0) subCategory: #localization special: #()>
	"super ypos: (aNumber/100)."
	[^ connectedRobot localizationService x: self xposition y: (aNumber/100) orientation: self heading.
	] on: Exception do: [ Transcript show: 'ypos:'; cr ]
]
