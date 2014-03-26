Extension { #name : #MenuMorph }

{ #category : #'*Phratch' }
MenuMorph >> addIcon: aForm toolTip: helpString action: aSymbol [ 
	"Append the given submenu with the given label."
	
	self
		addToggle: ''
		target: defaultTarget
		selector: aSymbol.
	self lastItem
		icon: aForm.
	helpString isNil
		ifFalse: [self lastItem setBalloonText: helpString].
]

{ #category : #'*Phratch' }
MenuMorph >> isMenuMorph [

	^ true
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
