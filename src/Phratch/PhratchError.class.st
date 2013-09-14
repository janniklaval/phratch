Class {
	#name : #PhratchError,
	#superclass : #Object,
	#category : #'Phratch-Error-Management'
}

{ #category : #'error handling' }
PhratchError class >> error [	
	ScriptablePhratchMorph noviceMode ifTrue:[
		^Beeper beep]
	ifFalse:[
		^super error.
	]

]

{ #category : #'error handling' }
PhratchError class >> error: aMessage [
	
	ScriptablePhratchMorph noviceMode ifTrue:[
		^Beeper beep]
	ifFalse:[
		^super error: aMessage
	]

]

{ #category : #'error handling' }
PhratchError class >> errorWithDialog: aMessage [
	
	DialogBoxMorph inform: aMessage.
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
