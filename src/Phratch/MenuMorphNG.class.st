Class {
	#name : #MenuMorphNG,
	#superclass : #MenuMorph,
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #'as yet unclassified' }
MenuMorphNG >> add: aString action: aSymbolOrBlock [
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the default target object."
	"Details: Note that the menu item added captures the default target object at the time the item is added; the default target can later be changed before added additional items without affecting the targets of previously added entries. The model is that each entry is like a button that knows everything it needs to perform its action."

	aSymbolOrBlock isBlock ifTrue:[ 
		^self add: aString
		target: aSymbolOrBlock
		selector: #value
		argumentList: EmptyArray
	].
	super add: aString action: aSymbolOrBlock
]

{ #category : #adding }
MenuMorphNG >> add: aString value: aValue [

	|item|
	item := ValuedMenuItemMorph new
		contents: aString;
		selectedValue: aValue;
		yourself.
	self addMenuItem: item.
]

{ #category : #accessing }
MenuMorphNG >> addIcon: aForm tooltip: aString value: aValue [
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

{ #category : #accessing }
MenuMorphNG >> addListOfValues: aList [
	"Add the given items to this menu, where each item is a pair (<string> <actionSelector>)..  If an element of the list is simply the symobl $-, add a line to the receiver.  The optional third element of each entry, if present, provides balloon help. The optional fourth element provide the icon selector"

	aList do: [:tuple |
		(tuple == #-)
			ifTrue: [self addLine]
			ifFalse:
				[self add: tuple first capitalized value: tuple second.
				(tuple size > 2 and: [tuple third notNil]) ifTrue:
					[self balloonTextForLastItem: tuple third].
				(tuple size > 3 and: [tuple fourth notNil]) ifTrue: 
					[self lastItem icon: (self theme iconNamed: tuple fourth)]]]
]

{ #category : #accessing }
MenuMorphNG >> selectedValue [
	self selectedItem ifNil:[^nil].
	^self  selectedItem selectedValue
]
