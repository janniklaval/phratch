Extension { #name : #HatBlockMorph }

{ #category : #'*Phratch-objects' }
HatBlockMorph >> changeLanguageString [

	self hasSubmorphs ifTrue:[self submorphsDo: [:sm | sm changeLanguageString]].
	^ self commandSpec ifNotNil: [:cmd | 
					|index|
					index := 1.
					(self submorphs select:[:s | s isStringMorph ] ) 
						do: [:s | s contents: ((PhratchTranslator labelPartsFor: (self commandSpec)) at: index).
						index := index+1.
					]
				].
]
