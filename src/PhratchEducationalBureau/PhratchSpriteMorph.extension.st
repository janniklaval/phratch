Extension { #name : #PhratchSpriteMorph }

{ #category : #'*PhratchEducationalBureau' }
PhratchSpriteMorph >> addTable [

	| newSprite frame |
	newSprite := BlocksBoardMorph new.
	
	frame := self ownerOrYourselfThatIsAPhratchFrameMorph.
	frame ifNotNil: [
		frame workPane addMorphFront: newSprite.
		frame workPane sprites addLast: newSprite].
	^ newSprite
]

{ #category : #'*PhratchEducationalBureau' }
PhratchSpriteMorph >> addTable15 [

	| newSprite frame |
	
	newSprite := BlocksBoardMorph15 new.
	frame := self ownerOrYourselfThatIsAPhratchFrameMorph.
	frame ifNotNil: [
		frame workPane addMorphFront: newSprite.
		frame workPane sprites addLast: newSprite].
	^ newSprite
]
