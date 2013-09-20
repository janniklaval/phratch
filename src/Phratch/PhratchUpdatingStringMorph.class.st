Class {
	#name : #PhratchUpdatingStringMorph,
	#superclass : #UpdatingStringMorph,
	#category : #'Phratch-UI-Watchers'
}

{ #category : #'target access' }
PhratchUpdatingStringMorph >> formatValue: v [

	format = #string ifTrue: [
		^ v asString].

	(format = #default and: [v isNumber]) ifTrue: [
		v isInteger
			ifTrue: [
				v digitLength > 25 ifTrue: [
					v digitLength < 128
						ifTrue: [^ self formatValue: v asFloat]  "use exponential notation"
						ifFalse: [^ v > 0 ifTrue: ['Infinity'] ifFalse: ['-Infinity']]].
				^ v printString]
			ifFalse: [
				v isInf ifTrue: [
					^ v > 0 ifTrue: ['Infinity'] ifFalse: ['-Infinity']].
				v isNaN ifTrue: [^ 'Error!'].
				^ (v asFloat roundTo: floatPrecision) printString]].

	(v isKindOf: Boolean) ifTrue: [^ v printString localized].
	(v isKindOf: String) ifTrue: [^ v].

	^ v printString

]

{ #category : #'target access' }
PhratchUpdatingStringMorph >> readFromTarget [
	"Answer the formatted string for the value read from my target. If the target or selector are nil, or if the value is the same as the last value read, answer my current contents."

	| v |
	(v := self valueFromTargetOrNil) ifNil: [^ contents].
	lastValue = v ifTrue: [^ contents].
	lastValue := v.
	^ self formatValue: v

]

{ #category : #'target access' }
PhratchUpdatingStringMorph >> valueFromTargetOrNil [
	"Answer the value read from my target. Answer nil if my target or selector is nil.."

	| result |
	(target isNil or: [ getSelector isNil ])
		ifTrue: [ ^ nil ].
	result := nil.
	[ 
	result := self parameter
		ifNil: [ target perform: getSelector ]
		ifNotNil: [ target perform: getSelector with: self parameter ] ] ifError: [PhratchError error  ].
	^ result
]
