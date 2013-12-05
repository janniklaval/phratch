Class {
	#name : #BlockType,
	#superclass : #Object,
	#instVars : [
		'labelMorph',
		'implicitValue'
	],
	#classVars : [
		'DropDownMenuForm'
	],
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
BlockType >> executeOn: aBlock [ 
	
	^ aBlock
]

{ #category : #'as yet unclassified' }
BlockType >> initialize [ 

	^super initialize
]
