Extension { #name : #Array }

{ #category : #'*Phratch-DefaultArguments' }
Array >> asArgumentWrapper [

	^ BlockWrapper with: self
]

{ #category : #'*Phratch-DefaultArguments' }
Array >> showError [

	^(self at:1) showError
]
