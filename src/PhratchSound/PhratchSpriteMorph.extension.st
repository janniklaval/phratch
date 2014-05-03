Extension { #name : #PhratchSpriteMorph }

{ #category : #'*PhratchSound' }
PhratchSpriteMorph >> attribute: attr [
	"Answer the value of my variable or built-in attribute with the given name. Answer zero if I have no attribute or variable with the given name."

	| a |
	
	(attr isCommandBlockMorph)
		ifTrue: [^ attr fullCopy newScriptOwner: self; yourself] 		"self blockLike: attr body]".

	a := attr asString.
	(vars includesKey: a) ifTrue: [^ vars at: a].
	(self allLocalBlockIds includes: a) ifTrue: [ ^self lambda: a ].

	a := a localized.
	'x position' localized = a ifTrue: [^ self xpos].
	'y position' localized = a ifTrue: [^ self ypos].
	'direction' localized = a ifTrue: [^ self heading].
	'costume #' localized = a ifTrue: [^ self costumeIndex].
	'size' localized = a ifTrue: [^ self scale].
	'volume' localized = a ifTrue: [^ self volume].

	'name' localized = a ifTrue: [^ self objName].
	'prototype' localized = a ifTrue: [^ self prototype].
	'owner' localized = a ifTrue: [^ self ownerSprite].
	'parts' localized = a ifTrue: [^ PhratchListMorph on: self subsprites].

	^ 0

]
