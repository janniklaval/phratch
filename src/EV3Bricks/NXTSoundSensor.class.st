Class {
	#name : #NXTSoundSensor,
	#superclass : #Ev3Sensor,
	#category : #EV3Bricks
}

{ #category : #'as yet unclassified' }
NXTSoundSensor class >> mode [ 

	^{ 
		#SoundDB->#Mode0. 
		#SoundDBA->#Mode1} asDictionary 
]

{ #category : #'as yet unclassified' }
NXTSoundSensor class >> typeString [

	^'Sound'
]
