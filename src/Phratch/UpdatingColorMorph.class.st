Class {
	#name : #UpdatingColorMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'selector',
		'target',
		'parameter',
		'stepTime',
		'lastValue'
	],
	#category : #'Phratch-UI-Watchers'
}

{ #category : #'as yet unclassified' }
UpdatingColorMorph >> fieldsVersion [

	^ 1
]

{ #category : #'as yet unclassified' }
UpdatingColorMorph >> getSelector [

	^ selector.
]

{ #category : #'as yet unclassified' }
UpdatingColorMorph >> getSelector: sym [

	selector := sym asString asSymbol.
]

{ #category : #'as yet unclassified' }
UpdatingColorMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		target
		selector
		parameter
		stepTime
	) from: anObjStream.

]

{ #category : #'as yet unclassified' }
UpdatingColorMorph >> initialize [

	super initialize.
	self extent: 12@12.
	selector := nil.
	target := nil.
	borderWidth := 1.
]

{ #category : #'as yet unclassified' }
UpdatingColorMorph >> parameter [

	^ parameter
]

{ #category : #'as yet unclassified' }
UpdatingColorMorph >> parameter: a [

	parameter := a.
]

{ #category : #'as yet unclassified' }
UpdatingColorMorph >> readFromTarget [
	"Answer the formatted string for the value read from my target. If the target or selector are nil, or if the value is the same as the last value read, answer my current contents."

	| v |
	(v := self valueFromTargetOrNil) ifNil: [^ nil].
	lastValue = v ifTrue: [^ nil].
	lastValue := v.
	(v isKindOf: Color) ifTrue: [
		^ self color: v]
	ifFalse: [
		^ nil].
]

{ #category : #'as yet unclassified' }
UpdatingColorMorph >> step [

	super step.
	self readFromTarget.
]

{ #category : #'as yet unclassified' }
UpdatingColorMorph >> stepTime [

	^ stepTime ifNil: [100] ifNotNil: [stepTime].
]

{ #category : #'as yet unclassified' }
UpdatingColorMorph >> stepTime: anInteger [

	stepTime := anInteger asInteger.
]

{ #category : #'as yet unclassified' }
UpdatingColorMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		target
		selector
		parameter
		stepTime
	) on: anObjStream.
]

{ #category : #'as yet unclassified' }
UpdatingColorMorph >> target [
	^ target
]

{ #category : #'as yet unclassified' }
UpdatingColorMorph >> target: anObject [

	target := anObject
]

{ #category : #'as yet unclassified' }
UpdatingColorMorph >> valueFromTargetOrNil [
	"Answer the value read from my target. Answer nil if my target or selector is nil.."

	| result |
	((target == nil) or: [selector == nil]) ifTrue: [^ nil].
	result := nil.
	[result := parameter
		ifNil: [target perform: selector]
		ifNotNil: [target perform: selector with: parameter]
	] ifError: [].
	^ result
]
