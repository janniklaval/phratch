Class {
	#name : #ScaleSensor,
	#superclass : #Ev3Sensor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
ScaleSensor class >> mode [ 

	^{ 
		#Scale0_4095 ->#Mode0.
		#Scale0_5000 ->#Mode1.
		#Scale0_10000 ->#Mode2.
		#Scale0_20000 ->#Mode3.} asDictionary 
]

{ #category : #'as yet unclassified' }
ScaleSensor class >> typeString [

	^'ScaleDevice'
]
