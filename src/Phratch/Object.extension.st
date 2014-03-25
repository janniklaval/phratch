Extension { #name : #Object }

{ #category : #'*Phratch-Extensions' }
Object >> asArgString [
	^ self asString
]

{ #category : #'*Phratch-Extensions' }
Object >> asNumberNoError [
	"This message is intended to be sent to strings, booleans, and numbers. This method is a backstop in case some other type of object receives this message."

	^ 0

]

{ #category : #'*Phratch-Extensions' }
Object >> inform: informationString withDetails: detailsString [
	"Put up a DialogBox to give the user an informational message and wait until they click the 'ok' button before proceeding."

	DialogBoxMorph inform: informationString withDetails: detailsString.
]

{ #category : #'*Phratch-Extensions' }
Object >> isArgMorph [

	^false
]

{ #category : #'*Phratch-Extensions' }
Object >> isBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isBoolean [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isCArgSlotMorph [

	^false
]

{ #category : #'*Phratch-Extensions' }
Object >> isCBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isCReporterSlotMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isCSlotMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isCommandBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isCommandScriptBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isExpressionArgMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isHatBlockMorph [

	^ false

]

{ #category : #'*Phratch-Extensions' }
Object >> isMultiArgMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isOSlotMorph [
	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isPhratchScriptsMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isPhratchStageMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isReporterBlockMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isStringFieldMorph [

	^ false
]

{ #category : #'*Phratch-Extensions' }
Object >> isStringMorph [
	^ false
]
