Class {
	#name : #NXTUltrasonicSensor,
	#superclass : #Ev3UltrasonicSensor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
NXTUltrasonicSensor class >> mode [ 

	^{ 
		#Centimeters->#Mode0. 
		#Inches->#Mode1.
	} asDictionary 

]

{ #category : #'as yet unclassified' }
NXTUltrasonicSensor class >> typeString [

	^'NXTUltrasonic'
]
