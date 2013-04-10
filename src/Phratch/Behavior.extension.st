Extension { #name : #Behavior }

{ #category : #'*Phratch-Extensions' }
Behavior >> classThatUnderstands: selector [
	"Answer the class that can respond to the message whose selector
	is the argument. The selector can be in the method dictionary of the
	receiver's class or any of its superclasses."

	(self includesSelector: selector) ifTrue: [^ self].
	superclass == nil ifTrue: [^ nil].
	^ superclass classThatUnderstands: selector
]
