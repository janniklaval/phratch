Class {
	#name : #Ev3MediumMotorSensor,
	#superclass : #Ev3Sensor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3MediumMotorSensor class >> mode [ 

	^{ 
		#Degree->#Mode0. 
		#Rotation->#Mode1.
		#Power->#Mode2} asDictionary 
]

{ #category : #'as yet unclassified' }
Ev3MediumMotorSensor class >> typeString [

	^'MediumMotor'
]
