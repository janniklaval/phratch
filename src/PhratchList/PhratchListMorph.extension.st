Extension { #name : #PhratchListMorph }

{ #category : #'*PhratchList' }
PhratchListMorph >> concatenatedLines [

	| isSingleLetters s |
	isSingleLetters := true.
	cellMorphs do: [:m |
		isSingleLetters ifTrue: [
			m firstSubmorph contents asString size <= 1 ifFalse: [isSingleLetters := false]]].

	s := WriteStream on: (String new: 1000).
	isSingleLetters
		ifTrue: [
			cellMorphs do: [:m | s nextPutAll: m firstSubmorph contents asString]]
		ifFalse: [
			cellMorphs do: [:m | s nextPutAll: m firstSubmorph contents asString; space].
			s position > 0 ifTrue: [s skip: -1]].

	^ s contents

]

{ #category : #'*PhratchList' }
PhratchListMorph >> listName [

	^ listName

]
