Class {
	#name : #EnergyMeterSensor,
	#superclass : #Ev3Sensor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
EnergyMeterSensor class >> mode [ 

	^{ 
		#VoltageIn->#Mode0. 
		#AmpsIn->#Mode1.
		#VoltageOut->#Mode2. 
		#AmpsOut->#Mode3. 
		#Joule->#Mode4.
		#WattsIn->#Mode5.
		#WattsOut->#Mode6.
		#All->#Mode7
	} asDictionary 

]

{ #category : #'as yet unclassified' }
EnergyMeterSensor class >> typeString [

	^'EnergyMeter'
]
