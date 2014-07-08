Class {
	#name : #Ev3TouchSensor,
	#superclass : #Ev3Sensor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
Ev3TouchSensor class >> mode [ 

	^ { #Boolean->#Mode0. #Count->#Mode1} asDictionary.
]

{ #category : #'as yet unclassified' }
Ev3TouchSensor class >> typeString [

	^'Touch'
]

{ #category : #'as yet unclassified' }
Ev3TouchSensor >> read [
	| value |
	value := 0.
	self modeName == #Count
		ifTrue: [ value := self getBumbs ].
	self modeName == #Boolean
		ifTrue: [ 
			value := self getRead > 50
				ifTrue: [ 1 ]
				ifFalse: [ 0 ] ].
	^ value
]

{ #category : #'as yet unclassified' }
Ev3TouchSensor >> reset [

	^ self clearChanges.
]
