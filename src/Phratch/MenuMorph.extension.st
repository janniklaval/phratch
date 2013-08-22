Extension { #name : #MenuMorph }

{ #category : #'*Phratch' }
MenuMorph >> labels [

	^ self menuItems 
]

{ #category : #'*Phratch' }
MenuMorph >> localize [

	"not yet implemented"
]

{ #category : #'*Phratch' }
MenuMorph >> popUpAt: aPosition forActiveHandIn: aWorld [
	"Present this menu under control of the given hand."
	^self popUpAt: aPosition forHand: aWorld activeHand in: aWorld

]

{ #category : #'*Phratch' }
MenuMorph >> popUpAt: aPosition inWorld: aWorld [
	"Present this menu under control of the given hand."
	^self popUpAt: aPosition forHand: aWorld primaryHand in: aWorld

]
