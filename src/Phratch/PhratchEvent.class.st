"
I represent a Scratch event. I have a name and an optional argument

"
Class {
	#name : #PhratchEvent,
	#superclass : #Object,
	#instVars : [
		'name',
		'argument'
	],
	#category : #'Phratch-Execution Engine'
}

{ #category : #accessing }
PhratchEvent >> argument [

	^ argument

]

{ #category : #accessing }
PhratchEvent >> name [

	^ name

]

{ #category : #accessing }
PhratchEvent >> name: aString argument: anObjectOrNil [
	"Set my event name and argument."

	name := aString.
	argument := anObjectOrNil.

]
