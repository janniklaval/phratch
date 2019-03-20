Class {
	#name : #FormValuedMenuItemMorph,
	#superclass : #FormMenuItemMorph,
	#instVars : [
		'selectedValue'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #accessing }
FormValuedMenuItemMorph >> selectedValue [
	^selectedValue
]

{ #category : #accessing }
FormValuedMenuItemMorph >> selectedValue: anObject [
	selectedValue := anObject
]
