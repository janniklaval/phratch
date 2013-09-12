Extension { #name : #CommandBlockMorph }

{ #category : #'*Phratch-DefaultArguments' }
CommandBlockMorph >> asArgumentWrapper [

	^ ExpressionWrapper with: self
]
