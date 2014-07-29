Extension { #name : #MenuMorph }

{ #category : #'*Phratch' }
MenuMorph >> add: aString value: aValue [

	|item|
	item := ValuedMenuItemMorph new
		contents: aString;
		selectedValue: aValue;
		yourself.
	self addMenuItem: item.
]

{ #category : #'*Phratch' }
MenuMorph >> add: aString value: aValue target: aTarget arguments: aCollection [

	|item|
	item := ValuedMenuItemMorph new
		contents: aString;
		selectedValue: aValue;
		arguments: aCollection;
		selector: aValue;
		target: aTarget;
		yourself.
	self addMenuItem: item.
]

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
MenuMorph >> addIcon: aForm tooltip: aString value: aValue [
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object with the given arguments. If the selector takes one more argument than the number of arguments in the given list, then the triggering event is supplied as as the last argument."

	| item |
	item := FormValuedMenuItemMorph new
		form: aForm;
		contents: '';
		setBalloonText: aString;
		target: defaultTarget;
		selectedValue: aValue;
		yourself.
	self addMenuItem: item.



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

{ #category : #'*Phratch' }
MenuMorph >> selectedValue [
	self selectedItem ifNil:[^nil].
	^self  selectedItem selectedValue
]
