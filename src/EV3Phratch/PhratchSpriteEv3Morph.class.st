Class {
	#name : #PhratchSpriteEv3Morph,
	#superclass : #PhratchSpriteMorph,
	#instVars : [
		'ev3'
	],
	#category : #EV3Phratch
}

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph class >> addEv3 [

	| newSprite frame |
	newSprite := PhratchSpriteEv3Morph new.
	
	frame := PhratchFrameMorph allInstances anyOne.
	
	frame workPane addMorphFront: newSprite.
	frame workPane sprites addLast: newSprite.
	^ newSprite

]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph class >> stepTimeValue [

	^1000
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> beep: vol time: duration [
	"Play a beep sound."
	<phratchItem: 'beep at volume $Number$ time $Number$' kind: #- category: 'ev3 UI' defaultValues: #(50 100) subCategory: #sound special: #()>
	^ (ev3 sound) beep: vol time: duration
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> cleanSockets [
	"Reset all existing connections"
	<phratchItem: 'clean all existing connections' kind: #- category: 'ev3 brick' defaultValues: #() subCategory: #a special: #()>

	self class allInstancesDo:[:e| [e ev3 bridge disconnect]on: Error do: [PhratchError error: 'error on disconnecting ev3']].
	Ev3BridgeSocket allInstances do:[:e | e disconnect].
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> cleanUI [
	"Clean the screen view."
	<phratchItem: 'clear screen' kind: #- category: 'ev3 UI' defaultValues: #() subCategory: #screen special: #()>
	^ (ev3 screen) cleanUI
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> cleanUIDisableTopLine: aBool [
	"Clean the screen view. You can give a boolean to show or hide the top line."
	<phratchItem: 'clear screen with top line $Boolean$' kind: #- category: 'ev3 UI' defaultValues: #(true) subCategory: #screen special: #()>
	(ev3 screen) cleanUI.
	^ (ev3 screen) enableTopLine: aBool not
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> clearCount: motor [
	"Set to 0 the number of steps of the given motor."
	<phratchItem: '$ev3Motors$ clear count' kind: #- category: 'ev3 motor' defaultValues: #(#motorA) subCategory: #d special: #()>
	^ (ev3 perform: motor) clearCount.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> closeFile: aHandle [
	<phratchItem: 'close file $String$' kind: #ReporterBlockMorph category: 'ev3-exp' defaultValues: #('' ) subCategory: #file special: #()>
	^ (ev3 fileSystem) closeFile: aHandle reply: true
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> connectToBluetooth: aString [ 
	"Connect to the given Ev3 IP"
	<phratchItem: 'bluetooth connect to $String$' kind: #CommandNoMouse category: 'ev3 brick' defaultValues: #('/dev/tty.EV3-SerialPort') subCategory: #a special: #()>
	[self say: 'I am waiting for connection'.
	[ev3 :=  Ev3Vehicle newBluetooth: aString daisyChain: #EV3] 
		on: Error 
		do:[
			self say: 'I am not connected'.
			2 seconds wait.
			self sayNothing.
		].
	ev3 bridge isConnected 
		ifTrue:[self say: 'I am connected'.]
		ifFalse:[self say: 'I am not connected'.].
	2 seconds wait.
	self sayNothing.
	
	[ev3 detectSensors] on: Error do:[self say: 'Error on detection of sensors. Press continue' ].
	2 seconds wait.
	self sayNothing.
	] fork
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> connectToIp: anIp [ 
	"Connect to the given Ev3 IP"
	<phratchItem: 'connect to $String$' kind: #CommandNoMouse category: 'ev3 brick' defaultValues: #('192.168.1.3') subCategory: #a special: #()>
	[self say: 'I am waiting for connection'.
	[ev3 :=  Ev3Vehicle newIp: anIp daisyChain: #EV3] 
		on: Error 
		do:[
			self say: 'I am not connected'.
			2 seconds wait.
			self sayNothing.
		].
	ev3 bridge isConnected 
		ifTrue:[self say: 'I am connected'.]
		ifFalse:[self say: 'I am not connected'.].
	2 seconds wait.
	self sayNothing.
	
	[ev3 detectSensors] on: Error do:[self say: 'Error on detection of sensors. Press continue' ].
	2 seconds wait.
	self sayNothing.
	] fork
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> createDirectory: aPath [
	<phratchItem: 'create directory $String$' kind: #ReporterBlockMorph category: 'ev3-exp' defaultValues: #('/aDirectory' ) subCategory: #file special: #()>
	^ (ev3 fileSystem) createDirectory: aPath reply: true
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> deletFile: aFileName [
	<phratchItem: 'delete file $String$' kind: #ReporterBlockMorph category: 'ev3-exp' defaultValues: #('/aFile' ) subCategory: #file special: #()>
	^ (ev3 fileSystem) deletFile: aFileName reply: true
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> disconnect [
	"Disconnect to the selected Mindstorm"
	<phratchItem: 'disconnect' kind: #- category: 'ev3 brick' defaultValues: #() subCategory: #a special: #()>
	ev3 bridge ifNil: [ ^ false].
	ev3 bridge isConnected ifTrue: [ ev3 bridge disconnect  ]
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> drawCircleColor: aColor x0: x0 y0: y0 radius: r filled: filled [
	"Draw a circle on the screen. After sending this command, you need to update the screen view."
	<phratchItem: 'draw circle color $ev3ScreenColor$ x $Number$ y $Number$ radius $Number$ filled $Boolean$' kind: #- category: 'ev3 UI' defaultValues: #(#Foreground 10 10 10 true) subCategory: #screen special: #()>
	^ (ev3 screen) drawCircleColor: aColor x0: x0 y0: y0 radius: r filled: filled
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> drawFillWindowColor: aColor y0: y0 y1: y1 [
"Fill the screen. After sending this command, you need to update the screen view."
	<phratchItem: 'draw fill window color $ev3ScreenColor$ from $Number$ size $Number$' kind: #- category: 'ev3 UI' defaultValues: #(#Foreground 10 10  20 20 10 20) subCategory: #screen special: #()>
	^ (ev3 screen) drawFillWindowColor: aColor y0: y0 y1: y1
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> drawHorizontalDottedLineColor: aColor y0: y0 x0: x0 x1: x1 onPixels: on offPixels: off [
	"Draw an horizontal dotted line on the screen. After sending this command, you need to update the screen view."
	<phratchItem: 'draw horizontal dotted line color $ev3ScreenColor$ at y $Number$ from x $Number$ to x $Number$ onPixels $Number$ offPixels $Number$' kind: #- category: 'ev3 UI' defaultValues: #(#Foreground 10 10 20) subCategory: #screen special: #()>
	^ (ev3 screen) drawDottedLineColor: aColor x0: x0 y0: y0 x1: x1 y1: y0 onPixels: on offPixels: off
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> drawImageColor: aColor x0: x0 y0: y0 path: aDevicePathToBmpFile [ 
	<phratchItem: 'draw image color $ev3ScreenColor$ x $Number$ y $Number$ path $String$' kind: #- category: 'ev3-exp' defaultValues: #(#Foreground 10 10  '') subCategory: #screen special: #()>
	^ (ev3 screen) drawImageColor: aColor x0: x0 y0: y0 path: aDevicePathToBmpFile
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> drawInverseRectangleX0: x0 y0: y0 width: w height: h [
	"Draw a rectangle with the inverse screen color. After sending this command, you need to update the screen view."
	<phratchItem: 'draw inverse rectangle x $Number$ y $Number$ width $Number$ height $Number$' kind: #- category: 'ev3 UI' defaultValues: #(10 10 10 10) subCategory: #screen special: #()>
	^ (ev3 screen) drawInverseRectangleX0: x0 y0: y0 width: w height: h
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> drawLineColor: aColor x0: x0 y0: y0 x1: x1 y1: y1 [
	"Draw a line on the screen. After sending this command, you need to update the screen view."
	<phratchItem: 'draw line color $ev3ScreenColor$ x $Number$ y $Number$ to x $Number$ y $Number$' kind: #- category: 'ev3 UI' defaultValues: #(Foreground 10 10 100 100) subCategory: #screen special: #()>
	^ (ev3 screen) drawLineColor: aColor x0: x0 y0: y0 x1: x1 y1: y1
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> drawPixelColor: aColor x0: x0 y0: y0 [ 
	"Draw a pixel on the screen. After sending this command, you need to update the screen view."
	<phratchItem: 'draw pixel color $ev3ScreenColor$ x $Number$ y $Number$' kind: #- category: 'ev3 UI' defaultValues: #(#Foreground 10 10) subCategory: #screen special: #()>
	^ (ev3 screen) drawPixelColor: aColor x0: x0 y0: y0
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> drawRectangleColor: aColor x0: x0 y0: y0 width: w height: h filled: filled [
	"Draw a rectangle on the screen. After sending this command, you need to update the screen view."
	<phratchItem: 'draw rectangle color $ev3ScreenColor$ x $Number$ y $Number$ width $Number$ height $Number$ filled $Boolean$' kind: #- category: 'ev3 UI' defaultValues: #(#Foreground 10 10 10 10 true) subCategory: #screen special: #()>
	^ (ev3 screen) drawRectangleColor: aColor x0: x0 y0: y0 width: w height: h filled: filled
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> drawTextColor: aColor x0: x0 y0: y0  text: aString [
	"Draw a text on the screen. After sending this command, you need to update the screen view."
	<phratchItem: 'draw text color $ev3ScreenColor$ x $Number$ y $Number$ text $String$' kind: #- category: 'ev3 UI' defaultValues: #(#Foreground 10 10 'text') subCategory: #screen special: #()>
	^ (ev3 screen) drawTextColor: aColor x0: x0 y0: y0  text: aString
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> drawVerticalDottedLineColor: aColor x0: x0 y0: y0 y1: y1 onPixels: on offPixels: off [
	"Draw a vertical dotted line on the screen. After sending this command, you need to update the screen view."
	<phratchItem: 'draw vertical dotted line color $ev3ScreenColor$ at x $Number$ from y $Number$ to y $Number$ onPixels $Number$ offPixels $Number$' kind: #- category: 'ev3 UI' defaultValues: #(#Foreground 10 10 20) subCategory: #screen special: #()>
	^ (ev3 screen) drawDottedLineColor: aColor x0: x0 y0: y0 x1: x0 y1: y1 onPixels: on offPixels: off
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> enableTopLine [
	"Show the top line of the Minstorm screen."
	<phratchItem: 'enable top line' kind: #- category: 'ev3 UI' defaultValues: #() subCategory: #screen special: #()>
	^ (ev3 screen) enableTopLine: true reply: false
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> ev3 [

	^ ev3
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> getFirmware [
	"Returns the firmware number"
	<phratchItem: 'get firmware number' kind: #ReporterBlockMorph category: 'ev3 brick' defaultValues: #() subCategory: #a special: #()>
	^ (ev3) getFirmware
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> getSensorTypes [
	"Turn the vehicle on the right when two motors are synchronized. You have to set the speed, the percentage of difference between the two motors, and the angle in degree that the motors should turn.""
	<phratchItem: 'sensor types' kind: #- category: 'ev3-exp' defaultValues: #() subCategory: #xxx special: #()>"

	^ (ev3) getSensorTypes
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> getType: motor [
	"Returns the number of steps of the given motor"
	"<phratchItem: '$ev3Motors$ get type' kind: #ReporterBlockMorph category: 'ev3-exp' defaultValues: #(#motorA) subCategory: #motor special: #()>"
	^ (ev3 perform: motor) getType.
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> handleSpinLeftSpeed: speed degrees: degrees [ 
	"Turn the vehicle on the right when two motors are synchronized. You have to set the speed, the percentage of difference between the two motors, and the angle in degree that the motors should turn."
	<phratchItem: 'handle spin left speed: $Number$ degrees: $Number$' kind: #- category: 'ev3 motor' defaultValues: #(10 10) subCategory: #sync special: #()>
	^ (ev3) handleSpinLeftSpeed: speed degrees: degrees
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> handleSpinRightSpeed: speed degrees: degrees [ 
	"Turn the vehicle on the right when two motors are synchronized. You have to set the speed, the percentage of difference between the two motors, and the angle in degree that the motors should turn."
	<phratchItem: 'handle spin right speed: $Number$ degrees: $Number$' kind: #- category: 'ev3 motor' defaultValues: #(10 10) subCategory: #sync special: #()>
	^ (ev3) handleSpinRightSpeed: speed degrees: degrees reply: false
]

{ #category : #initialization }
PhratchSpriteEv3Morph >> initialize [

	super initialize.
	ev3 := Ev3Vehicle basicNew.
	self setMyName: 'Ev3'.
	self initializeSkin.
	self gotoX: 0 y: 0.
]

{ #category : #'initialize-release' }
PhratchSpriteEv3Morph >> initializeSkin [
	| botSkin botImage |
	botSkin := Form fromFileNamed: (FileSystem workingDirectory / 'ScratchSkin' / 'defaultSpriteCostume.png').

	botImage := ImageMedia new form: botSkin.
	botImage mediaName: (self unusedMediaNameFromBaseName: (self defaultImageMedia mediaName)).
	media addLast: botImage.
	self lookLike: botImage mediaName.
	self updateMediaCategory.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> isConnected [
	"Return true if an Ev3 is connected"
	<phratchItem: 'is connected ?' kind: #BooleanWatcherBlockMorph category: 'ev3 brick' defaultValues: #('192.168.2.4' 1234 '0016533f8491') subCategory: #a special: #(#stepTimeForEv3)>
	ev3 bridge ifNil: [ ^ false].
	^ ev3 bridge isConnected
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> isShortPressed: button [
	<phratchItem: '$ev3Buttons$ is pressed' kind: #BooleanWatcherBlockMorph category: 'ev3-exp' defaultValues: #(#buttonAny) subCategory: #xxx special: #()>
	^ (ev3 perform: button) isShortPressed.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> listFilesFromPath: aPath length: aSize [
	"Give a list of the files and folders in the given path. The length is the number of characters you want to display."
	<phratchItem: 'list files from $String$ length $Number$' kind: #ReporterBlockMorph category: 'ev3 brick' defaultValues: #('/' 10) subCategory: #file special: #()>
	^ (ev3 fileSystem) listFilesFromPath: aPath length: aSize Reply: true
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> listOpenHandles [
	<phratchItem: 'list of opened file' kind: #ReporterBlockMorph category: 'ev3-exp' defaultValues: #() subCategory: #file special: #()>
	^ (ev3 fileSystem) listOpenHandlesReply: true
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> motor: motor setPolarity: boolean [
	"Set the polarity of the given motor"
	<phratchItem: '$ev3Motors$ set polarity $Boolean$' kind: #- category: 'ev3 motor' defaultValues: #(#motorA true) subCategory: #d special: #()>
	| b |
	b := boolean ifTrue:[1] ifFalse:[0].
	^ (ev3 perform: motor) setPolarity: b.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> motor: motor setPosition: aPosition [
	"Set the position of the given motor"
	"<phratchItem: '$ev3Motors$ set position $Number$' kind: #- category: 'ev3-exp' defaultValues: #(#motorA 0) subCategory: #motor special: #()>"
	^ (ev3 perform: motor) setPosition: aPosition reply: false.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> motor: motor speed: aSpeed [
	"Set the speed of the given motor"
	<phratchItem: '$ev3Motors$ set speed $Number$' kind: #- category: 'ev3 motor' defaultValues: #(#motorA 50) subCategory: #b special: #()>
	^ (ev3 perform: motor) speed: aSpeed.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> motorCount: motor [
	"Returns the number of steps of the given motor"
	<phratchItem: '$ev3Motors$ count' kind: #ReporterWatcherBlockMorph category: 'ev3 motor' defaultValues: #(#motorA) subCategory: #d special: #(#stepTimeForEv3)>
	^ (ev3 perform: motor) getCount.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> motorEmergencyStop: motor [
	"Break stop of the given motor."
	<phratchItem: '$ev3Motors$ emergency stop' kind: #- category: 'ev3 motor' defaultValues: #(#motorA) subCategory: #b special: #()>
	^ (ev3 perform: motor) emergencyStop.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> motorIsReady: motor [
	"Return true if the given motor is ready to receive comands"
	"<phratchItem: '$ev3Motors$ is ready ?' kind: #BooleanBlockMorph category: 'ev3-exp' defaultValues: #(#motorA) subCategory: #motor special: #(#stepTimeForEv3)>"
	^ (ev3 perform: motor) isReady.
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> motorIsReversed: motor [
	"Return true if the motor is reversed. It means the polarity is set to false"
	<phratchItem: '$ev3Motors$ is reversed ?' kind: #BooleanWatcherBlockMorph category: 'ev3 motor' defaultValues: #(#motorA) subCategory: #d special: #(#stepTimeForEv3)>
	^ (ev3 perform: motor) isReversed.
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> motorIsRunning: motor [
	"Return true if the motor is currently running"
	<phratchItem: '$ev3Motors$ is running ?' kind: #BooleanWatcherBlockMorph category: 'ev3 motor' defaultValues: #(#motorA) subCategory: #d special: #(#stepTimeForEv3)>
	^ (ev3 perform: motor) isRunning.
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> motorReset: motor [
	"Reset the values of the motor. The number of steps is set to 0"
	"<phratchItem: 'reset $ev3Motors$' kind: #- category: 'ev3-exp' defaultValues: #(#motorA) subCategory: #d special: #()>"
	^ (ev3 perform: motor) reset.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> motorReverse: motor [
	"Reverse the polarity of the motor"
	<phratchItem: 'reverse $ev3Motors$' kind: #- category: 'ev3 motor' defaultValues: #(#motorA) subCategory: #d special: #()>
	^ (ev3 perform: motor) reverse.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> motorSpeed: motor [
	"Return the current motor speed"
	<phratchItem: '$ev3Motors$ speed' kind: #ReporterWatcherBlockMorph category: 'ev3 motor' defaultValues: #(#motorA) subCategory: #d special: #(#stepTimeForEv3)>
	^ (ev3 perform: motor) getSpeed.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> motorStart: motor [
	"Start the given motor at the preset speed"
	<phratchItem: '$ev3Motors$ start' kind: #- category: 'ev3 motor' defaultValues: #(#motorA) subCategory: #b special: #()>
	^ (ev3 perform: motor) start.
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> motorStop: motor [
	"Stop the motor by decreasing the speed"
	<phratchItem: '$ev3Motors$ stop' kind: #- category: 'ev3 motor' defaultValues: #(#motorA) subCategory: #b special: #()>
	^ (ev3 perform: motor) stop.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> move: motor toAbsolutePositionSpeed: speed position: pos brake: aBoolBrake [
	"Move the motor to a position with a given speed"
	<phratchItem: 'move $ev3Motors$ speed $Number$ position $Number$ brake $Boolean$' kind: #- category: 'ev3 motor' defaultValues: #(#motorA 10 10 false) subCategory: #b special: #()>
	^ (ev3 perform: motor) moveToAbsolutePositionSpeed: speed position: pos brake: aBoolBrake.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> move: motor toRelativePositionSpeed: speed degrees: degrees brake: aBoolBrake [
	"Move the motor to a position relative to current position with a given speed"
	<phratchItem: 'move $ev3Motors$ speed $Number$ degrees $Number$ brake $Boolean$' kind: #- category: 'ev3 motor' defaultValues: #(#motorA 10 10 false) subCategory: #b special: #()>
	^ (ev3 perform: motor) moveToRelativePositionSpeed: speed degrees: degrees brake: aBoolBrake.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> moveSpeed: speed degrees: degrees [
	"Move the given motor to a given speed for the given degrees."
	<phratchItem: 'move speed: $Number$ step: $Number$' kind: #- category: 'ev3 motor' defaultValues: #(10 50) subCategory: #sync special: #()>
	^ (ev3) moveSpeed: speed degrees: degrees.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> playSoundFile: name volume: vol [
	<phratchItem: 'play file $String$ volume $Number$' kind: #- category: 'ev3-exp' defaultValues: #('test' 10) subCategory: #xxx special: #()>
	^ (ev3 sound) playSoundFile: name volume: vol
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> playToneVolume: vol frequency: freq duration: intTimeMs [
	"Play a tone with the given frequency at the given volume during the given time."
	<phratchItem: 'play tone volume $Number$ frequency $Number$ duration $Number$' kind: #- category: 'ev3 UI' defaultValues: #(10 10 10) subCategory: #sound special: #()>
	^ (ev3 sound) playToneVolume: vol frequency: freq duration: intTimeMs
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> readFile: aFileName [
	<phratchItem: 'read file $String$' kind: #ReporterBlockMorph category: 'ev3-exp' defaultValues: #('/aFile') subCategory: #file special: #()>
	^ (ev3 fileSystem)readFile: aFileName
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> selectFontType: aFontType [
	"Choose a font for the next text displayed on the screen."
	<phratchItem: 'select font type $ev3FontType$' kind: #- category: 'ev3 UI' defaultValues: #() subCategory: #screen special: #()>
	^ (ev3 screen) selectFontType: aFontType
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensor: sensor setMode: aMode [
	"Set the mode of the given sensor. By default, it is set to mode 0"
	<phratchItem: '$ev3Sensors$ set mode $sensorMode$' kind: #- category: 'ev3 sensor' defaultValues: #(#sensor1 #Mode0) subCategory: #sensor special: #()>
	^ (ev3 perform: sensor) setMode: aMode.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorClearAll: sensor [
	"Clean all data of the sensor"
	<phratchItem: 'clear $ev3Sensors$' kind: #CommandBlockMorph category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor2 special: #()>
	^ (ev3 perform: sensor) clearAll.
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorClearChanges: sensor [
	"Clean all changes of the sensor"
	<phratchItem: 'clear changes of $ev3Sensors$' kind: #- category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor2 special: #()>
	^ (ev3 perform: sensor) clearChanges.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorGetBumps: sensor [
	"Get the number of Bumps of the given sensor, if available. It the Bumps is not available, it returns 0"
	<phratchItem: 'bumps of $ev3Sensors$' kind: #ReporterWatcherBlockMorph category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor2 special: #(#stepTimeForEv3)>
	^ (ev3 perform: sensor) getBumbs.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorGetChanges: sensor [
	"Get the changes of the given sensor, if available. It the change is not available, it returns 0"
	<phratchItem: 'changes of $ev3Sensors$' kind: #ReporterWatcherBlockMorph category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor2 special: #(#stepTimeForEv3)>
	^ (ev3 perform: sensor) getChanges.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorGetFigures: sensor [
	"Get the figures of the given sensor, if available. It the figure is not available, it returns 0"
	<phratchItem: '$ev3Sensors$ get figures' kind: #ReporterBlockMorph category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor special: #(#stepTimeForEv3)>
	^ (ev3 perform: sensor) getFigures.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorGetMinMax: sensor [
	"Get the min and max value of the given sensor."
	<phratchItem: 'get min max of $ev3Sensors$' kind: #ReporterWatcherBlockMorph category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor2 special: #(#stepTimeForEv3)>
	^ (ev3 perform: sensor) getMinMax.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorGetModeName: sensor [
	"Get the name of the current mode."
	<phratchItem: 'mode name of $ev3Sensors$' kind: #ReporterWatcherBlockMorph category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor special: #(#stepTimeForEv3)>
	^ (ev3 perform: sensor) getModeName.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorGetName: sensor [
	"Get the name of the given sensor"
	<phratchItem: 'name of $ev3Sensors$' kind: #ReporterWatcherBlockMorph category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor special: #(#stepTimeForEv3)>
	^ (ev3 perform: sensor) getName.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorGetRaw: sensor [
	"Get the raw data of the given sensor."
	<phratchItem: 'get raw of $ev3Sensors$' kind: #ReporterWatcherBlockMorph category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor special: #(#stepTimeForEv3)>
	^ (ev3 perform: sensor) getRaw.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorGetRead: sensor [
	"Read the current value of the given sensor."
	"<phratchItem: 'read $ev3Sensors$' kind: #ReporterBlockMorph category: 'ev3-exp' defaultValues: #(#sensor1) subCategory: #sensor special: #(#stepTimeForEv3)>"
	^ (ev3 perform: sensor) getRead.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorGetSensorMode: sensor [
	"Get the mode of the given sensor."
	<phratchItem: 'mode type of $ev3Sensors$' kind: #ReporterWatcherBlockMorph category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor special: #(#stepTimeForEv3)>
	^ (ev3 perform: sensor) getSensorMode.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorGetSensorType: sensor [
	"Get the type of the given sensor."
	<phratchItem: 'type of $ev3Sensors$' kind: #ReporterWatcherBlockMorph category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor special: #(#stepTimeForEv3)>
	^ (ev3 perform: sensor) getSensorType.
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorGetSymbole: sensor [
	"Get the symbol of the given sensor."
	<phratchItem: 'symbol of $ev3Sensors$' kind: #ReporterWatcherBlockMorph category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor2 special: #(#stepTimeForEv3)>
	^ (ev3 perform: sensor) getSymbole.
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorMode [
	"Provides a drop-down menu for setting the sprite direction."

	| menu o |
	menu := MenuMorph new defaultTarget: self.
	o := (Ev3Sensor sensorMode associations collect:[:a | {a key . a value } ] ) asSortedCollection: [:a :b | a first < b first ].
	"#(	('sensor 1' 1)
		('sensor 2' 2)
		('sensor 3' 3)
		('sensor 4' 4)
	)"
	o do: [:pair |
		menu
			add: pair first localized
			value: pair first].
	menu invokeModal.
	^ menu
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorRead: sensor [
	"Read the current value of the sensor."
	<phratchItem: '$ev3Sensors$ read' kind: #ReporterBlockMorph category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor special: #(#stepTimeForEv3)>
	^ (ev3 perform: sensor) read.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorReadAsString: sensor [
	"Read the sensor and gives the current value with the unit."
	<phratchItem: '$ev3Sensors$ read string' kind: #ReporterBlockMorph category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor special: #(#stepTimeForEv3)>
	^ (ev3 perform: sensor) readAsString.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorReadSi: sensor [
	"Read the Si value of the given sensor."
	<phratchItem: '$ev3Sensors$ read Si' kind: #ReporterBlockMorph category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor special: #(#stepTimeForEv3)>
	^ (ev3 perform: sensor) readSi.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorReadyPct: sensor [
	"Return the latest ready Pct value"
	<phratchItem: '$ev3Sensors$ ready Pct ' kind: #ReporterWatcherBlockMorph category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor2 special: #(#stepTimeForEv3)>
	^((ev3 perform: sensor) readyPct) "= 0 ifTrue: [ ^false ].
	^ true"
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorReadyRaw: sensor [
	"Return the raw data of the sensor."
	<phratchItem: '$ev3Sensors$ ready Raw' kind: #ReporterWatcherBlockMorph category: 'ev3 sensor' defaultValues: #(#sensor1) subCategory: #sensor special: #(#stepTimeForEv3)>
	^ (ev3 perform: sensor) readyRaw.	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> sensorReadySi: sensor [
	"Return the latest ready Si value"
	<phratchItem: '$ev3Sensors$ ready Si' kind: #ReporterWatcherBlockMorph category: 'ev3 sensor' defaultValues: #() subCategory: #sensor2 special: #(#stepTimeForEv3)>
	^((ev3 perform: sensor) readySi) "= 0 ifTrue: [ ^false ].
	^ true"
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> set: motor stepPower: power constantSpeed: constantSpeedSteps brake: aBoolBrake [
	"Move the motor for the given steps with a given power"
	<phratchItem: 'move $ev3Motors$ power $Number$ step $Number$ brake: $Boolean$' kind: #- category: 'ev3 motor' defaultValues: #(#motorA 10 10 false) subCategory: #b special: #()>
	^ (ev3 perform: motor) setStepPower: power constantSpeed: constantSpeedSteps brake: aBoolBrake
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> set: motor stepSpeed: power constantSpeedSteps: constantSpeedSteps brake: aBoolBrake [

	<phratchItem: 'move $ev3Motors$ speed $Number$ steps $Number$ brake $Boolean$' kind: #- category: 'ev3 motor' defaultValues: #(#motorA 10 10 true) subCategory: #b special: #()>
	^ (ev3 perform: motor) setStepSpeed: power constantSpeedSteps: constantSpeedSteps brake: aBoolBrake
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> set: motor timePower: power constantSpeedTime: constantSpeedSteps brake: aBoolBrake [
	"Move the motor during the given time with a given power"
	<phratchItem: 'move $ev3Motors$ power $Number$ time $Number$ brake $Boolean$' kind: #- category: 'ev3 motor' defaultValues: #(#motorA 10 10 false) subCategory: #b special: #()>
	^ (ev3 perform: motor) setTimePower: power constantSpeedTime: constantSpeedSteps brake: aBoolBrake reply: false
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> set: motor timeSpeed: power constantSpeedTime: constantSpeedSteps brake: aBoolBrake [
	"Move the motor during the given time with a given speed."
	<phratchItem: 'move $ev3Motors$ speed $Number$ time $Number$ brake $Boolean$' kind: #- category: 'ev3 motor' defaultValues: #(#motorA 10 10 true) subCategory: #b special: #()>
	^ (ev3 perform: motor) setTimeSpeed: power constantSpeedTime: constantSpeedSteps brake: aBoolBrake reply: false
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> set: motor toPower: aPower [
	"set the power of the given motor"
	<phratchItem: '$ev3Motors$ set power $Number$' kind: #- category: 'ev3 motor' defaultValues: #(#motorA 20) subCategory: #b special: #()>
	^ (ev3 perform: motor) setPower: aPower.
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> setLedPattern: aLedPattern [
	"Change the LED behavior."
	<phratchItem: 'set LED pattern to $ev3Leds$' kind: #- category: 'ev3 UI' defaultValues: #(#Black) subCategory: #led special: #()>
	^ (ev3 led) setLedPattern: (aLedPattern asSymbol)
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> start: motor atSpeed: aNumber [
	"Start the given motor to a given speed."
	<phratchItem: 'start $ev3Motors$ at speed: $Number$' kind: #- category: 'ev3 motor' defaultValues: #(#motorA 50) subCategory: #b special: #()>
	^ (ev3 perform: motor) startAtSpeed: aNumber
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> startAtSpeed: speed turnRatio: turnRatio [
	"Start  two synchronized motors at the given speed with a ratio representing the speed difference between the two motors."
	<phratchItem: 'start at speed $Number$ turn ratio $Number$' kind: #- category: 'ev3 motor' defaultValues: #(10 10) subCategory: #sync special: #()>
	^ (ev3 motorSync) startSpeed: speed turnRatio: turnRatio 
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> startProgram: aString [ 
	"Start the given program."
	<phratchItem: 'start program $String$' kind: #- category: 'ev3 brick' defaultValues: #('../prjs/BrkProg_SAVE/Demo.rpf') subCategory: #xxx special: #()>
	ev3 startProgram: aString reply: false.
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> startSpeed: speed turnRatio: turnRatio degrees: degrees [
	"Start  two synchronized motors at the given speed  for the given degrees with a ratio representing the speed difference between the two motors."
	<phratchItem: 'start speed $Number$ turn ratio $Number$ degrees $Number$' kind: #- category: 'ev3 motor' defaultValues: #(10 10 10) subCategory: #sync special: #()>
	^ (ev3 motorSync) startSpeed: speed turnRatio: turnRatio degrees: degrees
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> stopProgram [
	"Stop the current running program."
	<phratchItem: 'stop current program' kind: #- category: 'ev3 brick' defaultValues: #() subCategory: #program special: #()>
	ev3 stopProgramReply: false.
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> stopSoundPlayback [
	"Stop the current running sound."
	<phratchItem: 'stop sound' kind: #- category: 'ev3 UI' defaultValues: #() subCategory: #sound special: #()>
	^ (ev3 sound) stopSoundPlayback
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> syncMotorsLeft: motorLeft right: motorRight [
	"Allow to synchronize 2 motors"
	<phratchItem: 'sync motors left $ev3Motors$ right $ev3Motors$' kind: #- category: 'ev3 brick' defaultValues: #(#motorA #motorD) subCategory: #sync special: #()>
	^ ev3 syncMotorsLeft: (ev3 perform: motorLeft) right: (ev3 perform: motorRight).
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> timeSyncSpeed: speed turnRatio: turnRatio time: timeInMs brake: brake [
	"Move the  synchonized motors during the given time with a given speed."
	<phratchItem: 'move speed $Number$ turn ratio $Number$ time $Number$ brake $Boolean$' kind: #- category: 'ev3 motor' defaultValues: #(10 10 100 true) subCategory: #sync special: #()>
	^ (ev3 motorSync) timeSyncSpeed: speed turnRatio: turnRatio time: timeInMs brake: brake
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> turnLeftForwardSpeed: speed percent: turnPercent degrees: degrees [
	"Turn the vehicle on the right when two motors are synchronized. You have to set the speed, the percentage of difference between the two motors, and the angle in degree that the motors should turn."
	<phratchItem: 'turn left forward speed: $Number$ percent: $Number$ degrees: $Number$' kind: #- category: 'ev3 motor' defaultValues: #(10 10 50) subCategory: #sync special: #()>
	^ (ev3) turnLeftForwardSpeed: speed percent: turnPercent degrees: degrees.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> turnLefttReverseSpeed: speed percent: turnPercent degrees: degrees [
	"Turn the vehicle on the left and reversed when two motors are synchronized. You have to set the speed, the percentage of difference between the two motors, and the angle in degree that the motors should turn."
	<phratchItem: 'turn left reverse speed: $Number$ percent: $Number$ degrees: $Number$' kind: #- category: 'ev3 motor' defaultValues: #(10 10 50) subCategory: #sync special: #()>
	^ (ev3) turnLefttReverseSpeed: speed percent: turnPercent degrees: degrees.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> turnRightForwardSpeed: speed percent: turnPercent degrees: degrees [
	"Turn the vehicle on the right when two motors are synchronized. You have to set the speed, the percentage of difference between the two motors, and the angle in degree that the motors should turn."
	<phratchItem: 'turn right forward speed: $Number$ percent: $Number$ degrees: $Number$' kind: #- category: 'ev3 motor' defaultValues: #(10 10 50) subCategory: #sync special: #()>
	^ (ev3) turnRightForwardSpeed: speed percent: turnPercent degrees: degrees.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> turnRightReverseSpeed: speed percent: turnPercent degrees: degrees [
	"Turn the vehicle on the right and reversed when two motors are synchronized. You have to set the speed, the percentage of difference between the two motors, and the angle in degree that the motors should turn."
	<phratchItem: 'turn right reverse speed: $Number$ percent: $Number$ degrees: $Number$' kind: #- category: 'ev3 motor' defaultValues: #(10 10 50) subCategory: #sync special: #()>
	^ (ev3) turnRightReverseSpeed: speed percent: turnPercent degrees: degrees.
	
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> updateUI [
	"Update the screen view."
	<phratchItem: 'update screen' kind: #- category: 'ev3 UI' defaultValues: #() subCategory: #screen special: #()>
	^ (ev3 screen) updateUI
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> waitForReady: motor [

	"<phratchItem: 'wait for ready $ev3Motors$' kind: #ReporterBlockMorph category: 'ev3-exp' defaultValues: #(#motorA) subCategory: #xxx special: #()>"
	^ (ev3 perform: motor) waitForReadyReply: true
]

{ #category : #'as yet unclassified' }
PhratchSpriteEv3Morph >> writeFile: aFileName content: data [
	<phratchItem: 'write in file $String$ contents $String$' kind: #ReporterBlockMorph category: 'ev3-exp' defaultValues: #('/aFile') subCategory: #file special: #()>
	^ (ev3 fileSystem) writeFile: aFileName content: data
]
