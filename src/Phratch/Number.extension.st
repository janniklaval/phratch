Extension { #name : #Number }

{ #category : #'*Phratch' }
Number >> /\/ aNumber [

	^ self / aNumber
]

{ #category : #'*Phratch-Extensions' }
Number >> asNumberNoError [

	^ self

]

{ #category : #'*Phratch' }
Number >> hhmmss [

	^ self rounded hhmmss

]

{ #category : #'*Phratch-Extensions' }
Number >> isInf [
	^false
]

{ #category : #'*Phratch' }
Number >> localized [

	^ self

]

{ #category : #'*Phratch' }
Number >> printStringNoExponent [

	^ self printString

]
