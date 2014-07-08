"
An Ev3GyroSensor is xxxxxxxxx.

"
Class {
	#name : #Ev3UltrasonicSensor,
	#superclass : #Ev3Sensor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3UltrasonicSensor class >> mode [ 

	^{ 
		#Centimeters->#Mode0. 
		#Inches->#Mode1.
		#Listen->#Mode2. 
		#SiCentimeters->#Mode3. 
		#SiInches->#Mode4.
		#DcCentimeters->#Mode5.
		#DcInches->#Mode6.
	} asDictionary 

]

{ #category : #'as yet unclassified' }
Ev3UltrasonicSensor class >> typeString [

	^'Ultrasonic'
]

{ #category : #'as yet unclassified' }
Ev3UltrasonicSensor >> read [

	^ self readSi 
]
