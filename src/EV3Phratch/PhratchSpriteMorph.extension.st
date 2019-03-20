Extension { #name : #PhratchSpriteMorph }

{ #category : #'*EV3Phratch' }
PhratchSpriteMorph >> addEv3 [

	| newSprite frame |
	newSprite := PhratchSpriteEv3Morph new.
	
	frame := self ownerOrYourselfThatIsAPhratchFrameMorph.
	frame ifNotNil: [
		frame workPane addMorphFront: newSprite.
		frame workPane sprites addLast: newSprite].
	^ newSprite

]
