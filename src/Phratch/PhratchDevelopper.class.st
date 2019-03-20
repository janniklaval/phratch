Class {
	#name : #PhratchDevelopper,
	#superclass : #Object,
	#category : #'Phratch-Installation'
}

{ #category : #'as yet unclassified' }
PhratchDevelopper class >> allBlocksCommentWithoutTranslation [
	| allPragmas comment |
	allPragmas := (Pragma allNamed: #phratchItem:kind:category:defaultValues:subCategory:special: in: ScriptablePhratchMorph) asOrderedCollection.
	ScriptablePhratchMorph allSubclasses
		do: [ :aSC | allPragmas addAll: (Pragma allNamed: #phratchItem:kind:category:defaultValues:subCategory:special: in: aSC) ].
	allPragmas.
	^allPragmas
		collect: [ :ap | 
			comment := ap method comment.
			comment ifNil: [ comment := '' ] ifNotNil: [ comment := comment copyFrom: 2 to: comment size - 1 ].
			comment ]
		thenSelect: [ :comm | comm localized = comm ]
]

{ #category : #'as yet unclassified' }
PhratchDevelopper class >> allBlocksWithoutComment [
	| allPragmas |
	allPragmas := (Pragma
		allNamed: #phratchItem:kind:category:defaultValues:subCategory:special:
		in: ScriptablePhratchMorph) asOrderedCollection.
	ScriptablePhratchMorph allSubclasses
		do: [ :aSC | 
			allPragmas
				addAll: (Pragma allNamed: #phratchItem:kind:category:defaultValues:subCategory:special: in: aSC) ].
	^ allPragmas collect: [ :e | e method ] thenSelect: [ :e | e comment isNil ]
]
