Extension { #name : #PhratchStageMorph }

{ #category : #'*PhratchSensing' }
PhratchStageMorph >> attribute: attr [
	"Answer the value of my variable or built-in attribute with the given name. Answer zero if I have no attribute or variable with the given name."

	| a |
	
	(attr isCommandBlockMorph)
		ifTrue: [^ attr fullCopy newScriptOwner: self; yourself] 		"self blockLike: attr body]".

	a := attr asString.
	(vars includesKey: a) ifTrue: [^ vars at: a].
	(self allLocalBlockIds includes: a) ifTrue: [ ^self lambda: a ].

	a := a localized.
	'background #' localized = a ifTrue: [^ self backgroundIndex].
	'costume #' localized = a ifTrue: [^ self backgroundIndex].
	(Smalltalk at: #PhratchCategorySound ifPresent:['volume' localized = a ifTrue: [^ self volume]]).
	^ 0

]
