Class {
	#name : #Ev3GyroSensor,
	#superclass : #Ev3Sensor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3GyroSensor class >> mode [ 

	^{ 
		#Angle->#Mode0. 
		#AngularVelocity->#Mode1.
		#Fast->#Mode2. 
		#VelocityAndAngle->#Mode3. 
		#Calibrate->#Mode4
	} asDictionary 
]

{ #category : #'as yet unclassified' }
Ev3GyroSensor class >> typeString [

	^'Gyro'
]

{ #category : #'as yet unclassified' }
Ev3GyroSensor >> read [

	^ self getRaw
]
