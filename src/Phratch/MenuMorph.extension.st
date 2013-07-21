Extension { #name : #MenuMorph }

{ #category : #'*Phratch' }
MenuMorph >> add: aString toolTip: tString action: aSelector [

	^ self add: aString action: aSelector
]

{ #category : #'*Phratch' }
MenuMorph >> addIcon: aForm tooltip: aString selector: aSymbol argument: arg [
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object with the given arguments. If the selector takes one more argument than the number of arguments in the given list, then the triggering event is supplied as as the last argument."

	| item |
	item := FormMenuItemMorph new
		form: aForm;
		contents: '';
		setBalloonText: aString;
		target: defaultTarget;
		selector: aSymbol;
		arguments: {arg}.
	self addMorphBack: item.



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
