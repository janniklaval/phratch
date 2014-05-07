"
I am an abstract superclass for all kinds of argument morphs--morphs that are used to hold the argument for various kinds of BlockMorph.

"
Class {
	#name : #ArgMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'labelMorph',
		'implicitValue'
	],
	#classVars : [
		'DropDownMenuForm'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #'class initialization' }
ArgMorph class >> dropDownMenuForm [
	^DropDownMenuForm
]

{ #category : #'initialize-release' }
ArgMorph class >> initialize [
	"self initialize"

	DropDownMenuForm := Form
		extent: 7@4
		depth: 1
		fromArray: #(4261412864 2080374784 939524096 268435456)
		offset: 0@0.
	DropDownMenuForm := DropDownMenuForm colorReduced.  "become a ColorForm"
	DropDownMenuForm colors:
		(Array with: Color transparent with: (Color gray: 0.25)).


]

{ #category : #visitor }
ArgMorph >> acceptsDroppedReporters [
	"Answer true if I accept dropped reporter blocks. Answer false by default."

	^ false

]

{ #category : #visitor }
ArgMorph >> acceptsTypeOf: aBlockMorph [
	"Answer true if I can accept a dropped reporter of the given type. Answer false by default."

	^ false

]

{ #category : #byob }
ArgMorph >> defaultValue [

	| def pos pname val |
	(owner respondsTo: #definition)
		ifFalse: [^ nil].
	def := owner definition.
	pos := (owner submorphs select: [:sm | sm isArgMorph]) indexOf: self.
	pname := def parameterNames at: pos.
	val := def defaultOf: pname.
	val = '' ifTrue: [^ nil].
	^ val
]

{ #category : #accessing }
ArgMorph >> defaultValue: anObject [
	"Set my default value. This default implementation does nothing."

]

{ #category : #drawing }
ArgMorph >> drawHLineFrom: startX to: endX y: yOffset color: c on: aCanvas [

	| y |
	y := self top + yOffset.
	aCanvas
		fillRectangle: ((self left + startX)@y corner: (self left + endX)@(y + 1))
		color: c.

]

{ #category : #evaluation }
ArgMorph >> evaluate [

	self subclassResponsibility
]

{ #category : #other }
ArgMorph >> fixArgLayout [
	"Fix my layout. This default implementation does nothing."
]

{ #category : #accessing }
ArgMorph >> implicitValue: anObject [
	implicitValue := anObject
]

{ #category : #accessing }
ArgMorph >> isArgMorph [

	^true
]

{ #category : #testing }
ArgMorph >> isEmptySlot [
	^true
]

{ #category : #other }
ArgMorph >> isReporter [
	"Answer true since every ArgMorph reports a value."

	^ true

]

{ #category : #other }
ArgMorph >> labelMorph [

	^ labelMorph

]

{ #category : #other }
ArgMorph >> printArgOn: aStream [
	"Print this argument morph on the given stream."

	| v |
	self labelMorph
		ifNotNil: [ 
			v := self evaluate.
			aStream nextPutAll: v asArgString]
]
