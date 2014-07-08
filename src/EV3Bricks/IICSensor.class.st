Class {
	#name : #IICSensor,
	#superclass : #Ev3Sensor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
IICSensor class >> mode [ 

	^{ 
		#Byte ->#Mode0.
		#Word ->#Mode1} asDictionary 
]

{ #category : #'as yet unclassified' }
IICSensor class >> typeString [

	^'IIC'
]
