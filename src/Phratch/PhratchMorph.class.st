Class {
	#name : #PhratchMorph,
	#superclass : #Morph,
	#category : #'Phratch-Morphs'
}

{ #category : #'as yet unclassified' }
PhratchMorph >> ownerOrYourselfThatIsA: aClass [
	"Answer this the first morph in the owner chain of the given class, or nil if there isn't one."

	| current |
	current := self.
	[ current isNil ]
		whileFalse: [ 
			(current isKindOf: aClass)
				ifTrue: [ ^ current ].
			current := current owner ].
	^ current
]
