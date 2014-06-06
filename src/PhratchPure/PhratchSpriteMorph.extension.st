Extension { #name : #PhratchSpriteMorph }

{ #category : #'*PhratchPure' }
PhratchSpriteMorph >> addKompai1 [

	| newSprite frame |
	newSprite := PhratchSpritePureMorph new.
	newSprite initializeKompai1.
	frame := self ownerOrYourselfThatIsAPhratchFrameMorph.
	frame ifNotNil: [
		frame workPane addMorphFront: newSprite.
		frame workPane sprites addLast: newSprite].
	^ newSprite

]

{ #category : #'*PhratchPure' }
PhratchSpriteMorph >> addKompai2 [

	| newSprite frame |
	newSprite := PhratchSpritePureMorph new.
	newSprite initializeKompai2.
	frame := self ownerOrYourselfThatIsA: PhratchFrameMorph.
	frame ifNotNil: [
		frame workPane addMorphFront: newSprite.
		frame workPane sprites addLast: newSprite].
	^ newSprite

]
