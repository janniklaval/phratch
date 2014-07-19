Extension { #name : #TextMorph }

{ #category : #'*Phratch-extension' }
TextMorph >> editView [
	^ self
]

{ #category : #'*Phratch-extension' }
TextMorph >> isEmpty [

	^ self contents isEmpty
]
