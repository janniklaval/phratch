Class {
	#name : #UpdatingColorMorph,
	#superclass : #PhratchBorderedMorph,
	#instVars : [
		'selector',
		'target',
		'parameter',
		'stepTime',
		'lastValue'
	],
	#category : #'Phratch-UI-Watchers'
}

{ #category : #'target access' }
UpdatingColorMorph >> contents [
	
	^ self valueFromTargetOrNil
]

{ #category : #accessing }
UpdatingColorMorph >> getSelector [

	^ selector.
]

{ #category : #accessing }
UpdatingColorMorph >> getSelector: sym [

	selector := sym asString asSymbol.
]

{ #category : #initialization }
UpdatingColorMorph >> initialize [

	super initialize.
	self extent: 12@12.
	selector := nil.
	target := nil.
	borderWidth := 1.
]

{ #category : #accessing }
UpdatingColorMorph >> parameter [

	^ parameter
]

{ #category : #accessing }
UpdatingColorMorph >> parameter: a [

	parameter := a.
]

{ #category : #'target access' }
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

{ #category : #'stepping and presenter' }
UpdatingColorMorph >> step [

	super step.
	self readFromTarget.
]

{ #category : #accessing }
UpdatingColorMorph >> stepTime [

	^ stepTime ifNil: [100] ifNotNil: [stepTime].
]

{ #category : #accessing }
UpdatingColorMorph >> stepTime: anInteger [

	stepTime := anInteger asInteger.
]

{ #category : #accessing }
UpdatingColorMorph >> target [
	^ target
]

{ #category : #accessing }
UpdatingColorMorph >> target: anObject [

	target := anObject
]

{ #category : #'target access' }
UpdatingColorMorph >> valueFromTargetOrNil [
	"Answer the value read from my target. Answer nil if my target or selector is nil.."

	| result |
	(target isNil or: [ selector isNil ])
		ifTrue: [ ^ nil ].
	result := nil.
	[ result := parameter ifNil: [ target perform: selector ] ifNotNil: [ target perform: selector with: parameter ] ]
		ifError: [ PhratchError error  ].
	^ result
]
