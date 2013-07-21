Class {
	#name : #BlockLabelFragment,
	#superclass : #Object,
	#instVars : [
		'label',
		'type',
		'isInput',
		'default',
		'isDeleted'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #'as yet unclassified' }
BlockLabelFragment >> default [
	^ default
]

{ #category : #'as yet unclassified' }
BlockLabelFragment >> default: aValue [
	default := aValue
]

{ #category : #'as yet unclassified' }
BlockLabelFragment >> delete [
	isDeleted := true
]

{ #category : #'as yet unclassified' }
BlockLabelFragment >> initialize [

	super initialize.
	isDeleted := false.
	label := ''.
	isInput := false.
	type := #any.
	default := ''
]

{ #category : #'as yet unclassified' }
BlockLabelFragment >> isDeleted [
	^ isDeleted
]

{ #category : #'as yet unclassified' }
BlockLabelFragment >> isInput [
	^ isInput
]

{ #category : #'as yet unclassified' }
BlockLabelFragment >> isInput: aBool [
	isInput := aBool
]

{ #category : #'as yet unclassified' }
BlockLabelFragment >> isLoop [

	isInput ifFalse: [^ false].
	type ifNil: [^ false].
	^ type = #loop
]

{ #category : #'as yet unclassified' }
BlockLabelFragment >> isMultipleInput [

	isInput ifFalse: [^ false].
	type ifNil: [^ false].
	^ type endsWith: 'List'
]

{ #category : #'as yet unclassified' }
BlockLabelFragment >> isTemplate [

	isInput ifFalse: [^ false].
	type ifNil: [^ false].
	^ type = #template
]

{ #category : #'as yet unclassified' }
BlockLabelFragment >> isUnevaluated [

	isInput ifFalse: [^ false].
	type ifNil: [^ false].
	^ type beginsWith: 'unevaluated'
]

{ #category : #'as yet unclassified' }
BlockLabelFragment >> label [
	^label
]

{ #category : #'as yet unclassified' }
BlockLabelFragment >> label: aString [

	label := aString

]

{ #category : #'as yet unclassified' }
BlockLabelFragment >> spec [
	| spec |
	isDeleted ifTrue: [^''].
	isInput ifFalse: [^ label].
	label isEmpty ifTrue: [^ label].
	spec := '$', label, '$'. 
	^spec


]

{ #category : #'as yet unclassified' }
BlockLabelFragment >> type [
	^type
]

{ #category : #'as yet unclassified' }
BlockLabelFragment >> type: aSymbol [
	type := aSymbol
]

{ #category : #'as yet unclassified' }
BlockLabelFragment >> updateLabel [

	"make sure an ellipsis (...) is added to the label
	if I am a multiple input type - unused for now"

	(self isMultipleInput and: [
		(label endsWith: '...') not]) ifTrue: [
			label := label, '...'.
			^ self].

	(label endsWith: '...') ifTrue: [
		label := label copyFrom: 1 to: label size - 3]
]
