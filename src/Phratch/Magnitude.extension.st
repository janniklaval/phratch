Extension { #name : #Magnitude }

{ #category : #'*Phratch-Extensions' }
Magnitude >> within: min and: max [
	"Answer the receiver if it is within the given interval [min..max]. Otherwise, answer the closest value within that interval."

	self < min ifTrue: [^ min].
	self > max ifTrue: [^ max].
	^ self

]
