"
I am an extension of the DialogBoxMorph used to request string input from the user.

Examples:
	StringDialog ask: 'What is your name?'
	StringDialogBoxMorph ask: 'What is your favorite color?' initialAnswer: 'Red, no blue'
	StringDialogBoxMorph askWithCancel: 'File name?' initialAnswer: 'filename.wav'

"
Class {
	#name : #StringDialog,
	#superclass : #DialogBoxMorph,
	#instVars : [
		'typeinMorph'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #'instance creation' }
StringDialog class >> ask: questionString [
	"Put up an instance of me to ask the user for string input (such as file name). Answer the edited string."

	^ self askWithCancel: questionString initialAnswer: ''

]

{ #category : #'instance creation' }
StringDialog class >> ask: questionString initialAnswer: aString [
	"Put up an instance of me to ask the user for string input (such as file name). The initial response text is set to the given string, which the user can replace or edit. Answer the edited string."

	| dialogBox |
	dialogBox := self new
		withButtonsForYes: false no: false okay: true cancel: false;
		message: questionString;
		initialAnswer: aString.
	^ dialogBox getUserResponse

]

{ #category : #'instance creation' }
StringDialog class >> askWithCancel: questionString [
	"Like ask:, but with a cancel button. Answer the empty string if cancelled."

	^ self askWithCancel: questionString initialAnswer: ''


]

{ #category : #'instance creation' }
StringDialog class >> askWithCancel: questionString initialAnswer: aString [
	"Put up an instance of me to ask the user for string input (such as file name). The initial response text is set to the given string, which the user can replace or edit. This version includes a cancel button. Answer the empty string if cancelled."

	| dialogBox |
	dialogBox := self new
		withButtonsForYes: false no: false okay: true cancel: true;
		message: questionString;
		initialAnswer: aString.
	^ dialogBox getUserResponse

]

{ #category : #interaction }
StringDialog >> accept [
	"Enter or carriage return typed or ok button pressed."

	self yes.

]

{ #category : #interaction }
StringDialog >> getUserResponse [
	"Wait for the user to type in and accept a string, then report that string. Answer the empty string if the user cancels the operation."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop."

	| w |
	self openInWorld.
	self centerOnScreen.
	w := self world.
	w activeHand newKeyboardFocus: typeinMorph.
	done := false.
	[done] whileFalse: [w doOneCycle].  "wait for user to press a button"

	self delete.
	w doOneCycle.  "erase myself from the screen"
	response = #cancelled
		ifTrue: [^ '']
		ifFalse: [^ typeinMorph contents asString].

]

{ #category : #'event handling' }
StringDialog >> handlesMouseOver: evt [

	^ true

]

{ #category : #initialization }
StringDialog >> initialAnswer: aString [
	"Set the default answer string."

	typeinMorph contents: aString.

]

{ #category : #initialization }
StringDialog >> initialize [
	"Similar to my superclass, but with a string field for the user's response."

	super initialize.
	self title: '?' translated.	"create and position typeinMorph"
	mainColumn
		addMorph:
				(Morph new
						extent: 5 @ 6;
						color: Color transparent);
		addMorph:
				(typeinMorph := StringFieldMorph new
						client: self;
						borderWidth: 2;
						color: (Color r: 211 / 255 g: 214 / 255 b: 216 / 255));
		addMorph:
				(Morph new
						extent: 5 @ 6;
						color: Color transparent).
	typeinMorph
		font: (PhratchFrameMorph getFont: #StringDialogTypeIn);
		width: 250.
	tabFields add: typeinMorph
]

{ #category : #'event handling' }
StringDialog >> mouseEnter: evt [
	"Grab the keyboard focus when the mouse is over me."

	evt hand newKeyboardFocus: typeinMorph.

]
