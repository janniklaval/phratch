"
I represent a Scratch event. I have a name and an optional argument

"
Class {
	#name : #ScratchEvent,
	#superclass : #Object,
	#instVars : [
		'name',
		'argument'
	],
	#category : #'Phratch-Execution Engine'
}

{ #category : #accessing }
ScratchEvent >> argument [

	^ argument

]

{ #category : #accessing }
ScratchEvent >> name [

	^ name

]

{ #category : #accessing }
ScratchEvent >> name: aString argument: anObjectOrNil [
	"Set my event name and argument."

	name := aString.
	argument := anObjectOrNil.

]
