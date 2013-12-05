Class {
	#name : #HatType,
	#superclass : #PhratchBlockMorphBuilder,
	#category : #'Phratch-BlockType'
}

{ #category : #'as yet unclassified' }
HatType class >> initBlock: aBlock on: aScriptablePhratchMorph withSpec: spec color: blockColor [

	^ aBlock 
]
