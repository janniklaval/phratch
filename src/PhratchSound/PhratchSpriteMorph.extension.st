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

{ #category : #'*PhratchSound' }
PhratchSpriteMorph >> spawn [
	"Duplicate me: My duplication is registered in the environment"
	<phratchItem: 'duplicate' kind: #ReporterBlockMorph category: 'control' defaultValues: #() subCategory: #self special: #()>
	| stage child |
"
	(frame := self ownerOrYourselfThatIsAPhratchFrameMorph) ifNil: [^ nil].
"
	stage := self ownerOrYourselfThatIsAPhratchStageMorph.
	stage ifNil: [^ self].
	child := self fullCopy.
	child blocksBin allMorphsDo: [:m |
		(m isBlockMorph) ifTrue: [m stop]].
	child unhinge; unhingeAll; initializeNodes.
	child prototype: self.
	child initializeVarsAndLists.
	child removeLocalBlockDefinitions.
	"frame workPane" stage addMorphFront: child.
	stage sprites addLast: child.
	child deleteAttributes: self deletedAttributes.
	child deleteAttribute: #costumes.
	child deleteAttribute: #sounds.

	^ child	
]
