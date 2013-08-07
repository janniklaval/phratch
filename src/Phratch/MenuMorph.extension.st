Extension { #name : #MenuMorph }

{ #category : #'*Phratch' }
MenuMorph >> add: aString toolTip: tString action: aSelector [

	^ self add: aString action: aSelector
]

{ #category : #'*Phratch' }
MenuMorph >> labels [

	^ self menuItems 
]

{ #category : #'*Phratch' }
MenuMorph >> localize [

	"not yet implemented"
]

{ #category : #'*Phratch' }
MenuMorph >> popUpAt: aPosition inWorld: aWorld [
	"Present this menu under control of the given hand."
	^self popUpAt: aPosition forHand: aWorld primaryHand in: aWorld

]
