Extension { #name : #PhratchSpriteMorph }

{ #category : #'*MinecraftPhratch' }
PhratchSpriteMorph >> addMinecraft [

	| newSprite frame |
	newSprite := PhratchMinecraftMorph new.
	
	frame := self ownerOrYourselfThatIsAPhratchFrameMorph.
	frame ifNotNil: [
		frame workPane addMorphFront: newSprite.
		frame workPane sprites addLast: newSprite].
	^ newSprite

]
