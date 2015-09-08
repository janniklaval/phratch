Class {
	#name : #PhratchBlockSettings,
	#superclass : #Object,
	#classVars : [
		'configuredMessages',
		'requestMessage'
	],
	#classInstVars : [
		'configuredMessages'
	],
	#category : #'Phratch-Installation'
}

{ #category : #accessing }
PhratchBlockSettings class >> addConfiguredMessages: aBlockName [
	configuredMessages  isNil ifTrue: [ configuredMessages := OrderedCollection  new  ].
	configuredMessages add: 	aBlockName
]

{ #category : #accessing }
PhratchBlockSettings class >> blockVisible [
  	^ ScriptablePhratchMorph isBlockVisible: requestMessage selector 
]

{ #category : #accessing }
PhratchBlockSettings class >> blockVisible: aValue [
  

	  ScriptablePhratchMorph blockVisible:  requestMessage selector 
]

{ #category : #accessing }
PhratchBlockSettings class >> doesNotUnderstand: aMessage [
 
	 requestMessage := aMessage 
]
