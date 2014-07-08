Class {
	#name : #NXTTemperatureSensor,
	#superclass : #Ev3Sensor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
NXTTemperatureSensor class >> mode [ 

	^{ 
		#Celcius->#Mode0. 
		#Fahrenheit->#Mode1
	} asDictionary 
]

{ #category : #'as yet unclassified' }
NXTTemperatureSensor class >> typeString [

	^'NXTTemperature'
]

{ #category : #'as yet unclassified' }
NXTTemperatureSensor >> read [

	^ self readSi
]
