Extension { #name : #ImageMorph }

{ #category : #'*Phratch-Extensions' }
ImageMorph >> colorform: anImage [

	self image: anImage as8BitColorForm
]

{ #category : #'*Phratch-Extensions' }
ImageMorph >> form: anImage [

	self image: anImage
]
