Class {
	#name : #ValuedMenuItemMorph,
	#superclass : #MenuItemMorph,
	#instVars : [
		'selectedValue'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #accessing }
ValuedMenuItemMorph >> selectedValue [
	^selectedValue
]

{ #category : #accessing }
ValuedMenuItemMorph >> selectedValue: anObject [
	selectedValue := anObject
]
