Class {
	#name : #NXTLightSensor,
	#superclass : #Ev3Sensor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
NXTLightSensor class >> mode [ 

	^{#Reflected->#Mode0.
		#Ambient->#Mode1.
		} asDictionary

]

{ #category : #'as yet unclassified' }
NXTLightSensor class >> typeString [

	^'Light'
]
