Extension { #name : #ScriptablePhratchMorph }

{ #category : #'*PhratchEducationalBureau' }
ScriptablePhratchMorph >> allTableSprite [
	| stage |
	stage := self ownerOrYourselfThatIsAPhratchStageMorph.
	stage ifNil: [^ PhratchListMorph new].
	^ PhratchListMorph on: (stage sprites collect:[:e | e isKindOf: BlocksBoardMorph])
]

{ #category : #'*PhratchEducationalBureau' }
ScriptablePhratchMorph >> blockRead: anObject [
	<phratchItem: 'read $TableSprite$' kind: #ReporterBlockMorph category: 'educational bureau' defaultValues: #() subCategory: #b special: #()>
	
	| aSpriteOrStage |
	aSpriteOrStage := self coerceSpriteArg: anObject.

	(aSpriteOrStage isScriptablePhratchMorph) ifFalse: [^ 0].
	^ aSpriteOrStage lastString
]

{ #category : #'*PhratchEducationalBureau' }
ScriptablePhratchMorph >> blockRead: anObject atValue: anIndex [
	<phratchItem: 'read $TableSprite$ at $Number$' kind: #ReporterBlockMorph category: 'educational bureau' defaultValues: #() subCategory: #b special: #()>
	
	| aSpriteOrStage |
	aSpriteOrStage := self coerceSpriteArg: anObject.

	(aSpriteOrStage isScriptablePhratchMorph) ifFalse: [^ 0].
	^ (aSpriteOrStage lastString at: anIndex asInteger) asString
]
