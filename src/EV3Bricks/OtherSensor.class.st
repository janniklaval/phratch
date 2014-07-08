Class {
	#name : #OtherSensor,
	#superclass : #Ev3Sensor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
OtherSensor class >> mode [ 

	^{ 
		#Mode0 ->#Mode0.} asDictionary 
]

{ #category : #'as yet unclassified' }
OtherSensor class >> typeString [

	^'Other'
]
