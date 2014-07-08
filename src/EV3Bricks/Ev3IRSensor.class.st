Class {
	#name : #Ev3IRSensor,
	#superclass : #Ev3Sensor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3IRSensor class >> mode [ 

	^{ 
		#Proximity->#Mode0. 
		#Seek->#Mode1.
		#Remote->#Mode2.
		#RemoteAdvanced->#Mode3.
		#Calibrate->#Mode5
	} asDictionary 
]

{ #category : #'as yet unclassified' }
Ev3IRSensor class >> typeString [

	^'IR'
]

{ #category : #'as yet unclassified' }
Ev3IRSensor >> read [
	(mode == (self class mode at: #Proximity)) ifTrue:[
		^ self getRead.
	].
	^ self getRaw
]
