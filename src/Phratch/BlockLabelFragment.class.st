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

{ #category : #accessing }
BlockLabelFragment >> default [
	^ default
]

{ #category : #accessing }
BlockLabelFragment >> default: aValue [
	default := aValue
]

{ #category : #'submorphs-add/remove' }
BlockLabelFragment >> delete [
	isDeleted := true
]

{ #category : #'initialize-release' }
BlockLabelFragment >> initialize [

	super initialize.
	isDeleted := false.
	label := ''.
	isInput := false.
	type := #any.
	default := ''
]

{ #category : #accessing }
BlockLabelFragment >> isDeleted [
	^ isDeleted
]

{ #category : #accessing }
BlockLabelFragment >> isInput [
	^ isInput
]

{ #category : #accessing }
BlockLabelFragment >> isInput: aBool [
	isInput := aBool
]

{ #category : #testing }
BlockLabelFragment >> isLoop [

	isInput ifFalse: [^ false].
	type ifNil: [^ false].
	^ type = #loop
]

{ #category : #testing }
BlockLabelFragment >> isMultipleInput [

	isInput ifFalse: [^ false].
	type ifNil: [^ false].
	^ type endsWith: 'List'
]

{ #category : #testing }
BlockLabelFragment >> isTemplate [

	isInput ifFalse: [^ false].
	type ifNil: [^ false].
	^ type = #template
]

{ #category : #testing }
BlockLabelFragment >> isUnevaluated [

	isInput ifFalse: [^ false].
	type ifNil: [^ false].
	^ type beginsWith: 'unevaluated'
]

{ #category : #accessing }
BlockLabelFragment >> label [
	^label
]

{ #category : #accessing }
BlockLabelFragment >> label: aString [

	label := aString

]

{ #category : #accessing }
BlockLabelFragment >> spec [
	| spec |
	isDeleted ifTrue: [^''].
	isInput ifFalse: [^ label].
	label isEmpty ifTrue: [^ label].
	spec := '$', label, '$'. 
	^spec


]

{ #category : #accessing }
BlockLabelFragment >> type [
	^type
]

{ #category : #accessing }
BlockLabelFragment >> type: aSymbol [
	type := aSymbol
]

{ #category : #updating }
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
