Extension { #name : #Number }

{ #category : #'*Phratch-Extensions' }
Number >> /\/ aNumber [

	^ self / aNumber
]

{ #category : #'*Phratch-Extensions' }
Number >> asNumberNoError [

	^ self

]

{ #category : #'*Phratch-Extensions' }
Number >> hhmmss [

	^ self rounded hhmmss

]

{ #category : #'*Phratch-Extensions' }
Number >> isInf [
	^false
]

{ #category : #'*Phratch-Extensions' }
Number >> localized [

	^ self

]

{ #category : #'*Phratch-Extensions' }
Number >> printStringNoExponent [

	^ self printString

]
