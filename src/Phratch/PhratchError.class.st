Class {
	#name : #PhratchError,
	#superclass : #Object,
	#category : #'Phratch-Error-Management'
}

{ #category : #'error handling' }
PhratchError class >> error [	
	
	self error: 'an error occured in Phratch'
]

{ #category : #'error handling' }
PhratchError class >> error: aMessage [
	ScriptablePhratchMorph noviceMode
		ifTrue: [ Beeper beep ].
	^ self errorWithDialog: aMessage
]

{ #category : #'error handling' }
PhratchError class >> errorWithDialog: aMessage [
	
	DialogBoxMorph inform: aMessage title: 'an error occured !'.
	ScriptablePhratchMorph noviceMode ifFalse:[
		^super error: aMessage
	]

]

{ #category : #'error handling' }
PhratchError class >> primitiveFailed: aMessage [
	
	ScriptablePhratchMorph noviceMode ifTrue:[
		^Beeper beep]
	ifFalse:[
		^super primitiveFailed: 'PhratchPlugin primitive failed'
	]

]
