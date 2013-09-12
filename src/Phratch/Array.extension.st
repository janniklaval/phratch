Extension { #name : #Array }

{ #category : #'*Phratch-DefaultArguments' }
Array >> asArgumentWrapper [

	^ BlockWrapper with: self
]
