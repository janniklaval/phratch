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

{ #category : #'*Phratch-BYOB-see-ddddd lambdas' }
ArgMorph class >> dropDownMenuForm [
	^DropDownMenuForm
]

{ #category : #'class initialization' }
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

{ #category : #other }
ArgMorph >> acceptsDroppedReporters [
	"Answer true if I accept dropped reporter blocks. Answer false by default."

	^ false

]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd' }
ArgMorph >> acceptsTypeOf: aBlockMorph [
	"Answer true if I can accept a dropped reporter of the given type. Answer false by default."

	^ false

]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd' }
ArgMorph >> defaultValue [

	| def pos pname val |
	(owner respondsTo: #definition)
		ifFalse: [^ nil].
	def := owner definition.
	pos := (owner submorphs select: [:sm | sm isKindOf: ArgMorph]) indexOf: self.
	pname := def parameterNames at: pos.
	val := def defaultOf: pname.
	val = '' ifTrue: [^ nil].
	^ val
]

{ #category : #other }
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

{ #category : #'object i/o' }
ArgMorph >> fieldsVersion [

	^ 1

]

{ #category : #other }
ArgMorph >> fixArgLayout [
	"Fix my layout. This default implementation does nothing."
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd' }
ArgMorph >> implicitValue [
	^ implicitValue
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd' }
ArgMorph >> implicitValue: anObject [
	implicitValue := anObject
]

{ #category : #'object i/o' }
ArgMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		labelMorph
	) from: anObjStream.

]

{ #category : #other }
ArgMorph >> isArgMorph [
	"True only for ArgMorphs."

	^ true

]

{ #category : #other }
ArgMorph >> isBlockMorph [
	"True only for BlockMorphs."

	^ false

]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd' }
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
	self labelMorph ifNotNil: [
		v := self evaluate.
		(v isKindOf: String)
			ifTrue: [aStream nextPutAll: '"', v, '"']
			ifFalse: [aStream nextPutAll: v asString]].


]

{ #category : #'object i/o' }
ArgMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		labelMorph
	) on: anObjStream.

]
