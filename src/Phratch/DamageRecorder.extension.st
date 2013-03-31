Extension { #name : #DamageRecorder }

{ #category : #'*Phratch-Extensions' }
DamageRecorder >> filteredDamageWithin: aRectangle [
	"Remove and answer a collection of damage rectangles that fit entirely within the given Rectangle. Answer the empty list if a full repaint has been requested."

	| result filteredDamage |
	totalRepaint
		ifTrue: [ ^ #() ].
	result := OrderedCollection new: 20.
	filteredDamage := OrderedCollection new: 20.
	invalidRects
		do: [ :r | 
			(aRectangle containsRect: r)
				ifTrue: [ result add: r ]
				ifFalse: [ filteredDamage add: r ] ].
	result size > 0
		ifTrue: [ invalidRects := filteredDamage ].
	^ result
]

{ #category : #'*Phratch-Extensions' }
DamageRecorder >> initialize [ 

	self reset
]
