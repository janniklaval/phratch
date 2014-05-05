Extension { #name : #TranslucentImageMorph }

{ #category : #'*PhratchLooks' }
TranslucentImageMorph >> transparency [

	^ transparency

]

{ #category : #'*PhratchLooks' }
TranslucentImageMorph >> transparency: aNumber [

	transparency := aNumber.
	self changed.

]
