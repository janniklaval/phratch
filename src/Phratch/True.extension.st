Extension { #name : #True }

{ #category : #'*Phratch-Extensions' }
True >> asNumberNoError [
	"This message is intended to be sent to strings, booleans, and numbers. This method is a backstop in case some other type of object receives this message."

	^ 1
]

{ #category : #'*Phratch-Extensions' }
True >> checkBoxString [

	^ '<yes>'
]
