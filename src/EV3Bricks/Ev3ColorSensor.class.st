Class {
	#name : #Ev3ColorSensor,
	#superclass : #Ev3Sensor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3ColorSensor class >> color [
	^ { 
		#None->0.
		#Black->1.
		#Blue->2.
		#Green->3.
		#Yellow->4.
		#Red->5.
		#White->6.
		#Brown->7		
	} asDictionary.
]

{ #category : #'as yet unclassified' }
Ev3ColorSensor class >> mode [ 

	^{#Reflection->#Mode0.
		#Ambient->#Mode1.
		#Color->#Mode2.
		#ReflectiveRaw->#Mode3.
		#RgbRaw->#Mode4.
		#Calibration->#Mode5.
		} asDictionary

]

{ #category : #'as yet unclassified' }
Ev3ColorSensor class >> typeString [

	^'Color'
]

{ #category : #'initialize-release' }
Ev3ColorSensor >> initialize [ 

	super initialize.
	mode := self class mode at: #Color.
	
]

{ #category : #'as yet unclassified' }
Ev3ColorSensor >> read [

	(self modeName == #Ambient or: [self modeName == #Reflexion ]) ifTrue:[
		^ self getRead.
	].
	^ self getRaw
]
