Class {
	#name : #OSlotMorph,
	#superclass : #ReporterScriptBlockMorph,
	#instVars : [
		'implicitValue'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #'argument slot behavior' }
OSlotMorph >> acceptsTypeOf: aBlockMorph [
	"Answer true if I can accept a dropped reporter of the given type. Answer false by default."

	^ aBlockMorph isReporter
]

{ #category : #'stack/tuple conversion' }
OSlotMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its arguments."

	| blockTuple arg |
	
	blockTuple := Array new: 4.
	blockTuple
		at: 1 put: #byob;
		at: 2 put: self rcvr;
		at: 3 put: selector.

	arg := self nestedBlock.
	(arg isKindOf: ReporterBlockMorph)
		ifTrue: [blockTuple at: 4 put: (Array with: argMorphs first asBlockTuple)]
		ifFalse: [blockTuple at: 4 put: nil]. 
	^ blockTuple
]

{ #category : #'argument slot behavior' }
OSlotMorph >> defaultValue: default [
	"do nothing"
]

{ #category : #drawing }
OSlotMorph >> drawOn: aCanvas [ 

	(owner respondsTo: #color) ifTrue: [
		color = owner color ifFalse: [
			color := owner color]].

	self nestedBlock ifNil: [
		aCanvas
			fillRectangle: self bounds color: color].

	self drawSlotOn: aCanvas
]

{ #category : #drawing }
OSlotMorph >> drawSlotOn: aCanvas [

	| dark |

	(type = #booleanslot and: [argMorphs first isKindOf: SpecialArgMorph])
		ifTrue: [^ self].

	dark := Color gray " (color mixed: 0.45 with: Color darkGray)". 

	(argMorphs first isKindOf: ReporterBlockMorph) ifTrue: [
		argMorphs first isBooleanReporter
			ifTrue: [
				aCanvas paintImage: ((argMorphs first imageForm withOutlineColor: dark width: 4) 
					withHalfEmbeddedOutlineColor: dark)
					at: (argMorphs first position - 5).
				]
			ifFalse: [
				aCanvas paintImage: ((argMorphs first imageForm withOutlineColor: dark width: 4) 
					"withHalfEmbeddedOutlineColor: dark)"
					withEmbeddedOutlineColor: dark width: 1)
					at: (argMorphs first position - 5).
				].
			^self
			].

	aCanvas paintImage: (argMorphs first imageForm outlineEmbeddedAdjustedColor: dark) 
		at: (argMorphs first position - 1)


]

{ #category : #'argument slot behavior' }
OSlotMorph >> evaluate [

	implicitValue notNil
		ifTrue: [^implicitValue].
	^ "super evaluate" nil
]

{ #category : #'argument slot behavior' }
OSlotMorph >> evaluateWithArgs: rawArgs [

	implicitValue notNil
		ifTrue: [^implicitValue].
	^super evaluateWithArgs: rawArgs
]

{ #category : #'argument slot behavior' }
OSlotMorph >> fixArgLayout [
	"Fix my layout. This default implementation does nothing."
]

{ #category : #'event handling' }
OSlotMorph >> handlesMouseDown: evt [

	^false
]

{ #category : #'argument slot behavior' }
OSlotMorph >> implicitValue: anObject [
	implicitValue := anObject
]

{ #category : #initialisation }
OSlotMorph >> initialize [
	super initialize.
	isSpecialForm := true.
	minArgs := 0.
	maxArgs := 0.
"	self type: #reporterslot."
	removeElementMorph ifNotNil: [
		removeElementMorph delete]
]

{ #category : #'argument slot behavior' }
OSlotMorph >> isEmptySlot [
	^ self body isNil
]

{ #category : #'argument slot behavior' }
OSlotMorph >> isKindOf: aClass [
	aClass = ArgMorph 
		or:[ super isKindOf: aClass]
]

{ #category : #'argument slot behavior' }
OSlotMorph >> isLambdaForm [
	^ false
]

{ #category : #other }
OSlotMorph >> printArgOn: aStream [
	"Print this argument morph on the given stream."

	| v |
	v := self evaluate.
	(v isKindOf: String)
		ifTrue: [ 
			aStream
				nextPutAll: '"';
				nextPutAll: v;
				nextPutAll: '"' ]
		ifFalse: [ aStream nextPutAll: v asString ]
]

{ #category : #accessing }
OSlotMorph >> receiver [

	^receiver ifNil: [
		(owner respondsTo: #receiver)
			ifTrue: [^receiver := owner receiver]
			ifFalse: [^nil]]	
]

{ #category : #accessing }
OSlotMorph >> type: aSymbol [

	type := aSymbol.

	#reporterslot = type ifTrue: [
		selector := #autoBlock.
		self commandSpec: '$SAReporter$'].

	#booleanslot = type ifTrue: [
		selector := #autoPredicate.
		self commandSpec: '$SABoolean$'].

	self addLabel.

	removeElementMorph ifNotNil: [
		removeElementMorph delete]

]

{ #category : #private }
OSlotMorph >> veryDeepFixupWith: deepCopier [
	"If fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals."

	super veryDeepFixupWith: deepCopier.
	implicitValue := deepCopier references at: implicitValue ifAbsent: [implicitValue]

]
