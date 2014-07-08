Class {
	#name : #NXTColorSensor,
	#superclass : #Ev3ColorSensor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
NXTColorSensor class >> mode [ 

	^{#Reflection->#Mode0.
		#Ambient->#Mode1.
		#Color->#Mode2.
		#Green->#Mode3.
		#Blue->#Mode4.
		#Raw->#Mode5.
		} asDictionary

]

{ #category : #'as yet unclassified' }
NXTColorSensor class >> typeString [

	^'NXTColor'
]
