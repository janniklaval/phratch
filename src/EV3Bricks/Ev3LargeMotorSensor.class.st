Class {
	#name : #Ev3LargeMotorSensor,
	#superclass : #Ev3Sensor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3LargeMotorSensor class >> mode [ 

	^{ 
		#Degree->#Mode0. 
		#Rotation->#Mode1.
		#Power->#Mode2} asDictionary 
]

{ #category : #'as yet unclassified' }
Ev3LargeMotorSensor class >> typeString [

	^'LargeMotor'
]
