"
Shows a help Form in a dialog box with an ok button.

"
Class {
	#name : #HelpDialog,
	#superclass : #DialogBoxMorph,
	#instVars : [
		'imageMorph'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #'instance creation' }
HelpDialog class >> inform: informationString title: titleString form: aForm [
	"Put up an instance of me to give the user an informational message and wait until they click the 'ok' button before proceeding."
	"DialogBoxMorph inform: 'Operation complete.' title: 'Status'"

	| dialogBox |
	dialogBox := self new
		withButtonsForYes: false no: false okay: true cancel: false;
		title: titleString localized;
		extent: aForm extent + (80 @ 300);
		yourself.
	dialogBox
		message: informationString localized
		font: (StrikeFont fontName: 'VerdanaBold' size: 13).
	dialogBox
		helpForm: aForm.
		
	^ dialogBox getUserResponse
]

{ #category : #'instance creation' }
HelpDialog class >> showForm: aForm [
	"HelpDialogMorph showForm: (Form fromFileNamed: 'move.gif')"

	| dialog |
	dialog := self new
		withButtonsForYes: false
			no: false
			okay: true
			cancel: false;
		title: 'help' localized;
		helpForm: aForm;
		extent: aForm extent + (80 @ 145);
		yourself.
	^ dialog getUserResponse

]

{ #category : #other }
HelpDialog >> helpForm: anImage [

	| f |
	f := anImage.
	(f isColorForm) ifTrue: [
		f := f copy.
		f colors: (f colors collect: [:c | c isTransparent ifTrue: [Color black] ifFalse: [c]])].

	imageMorph form: f.

]

{ #category : #initialization }
HelpDialog >> initialize [

	super initialize.

	"position morphs"
	imageMorph := ImageMorph new form: (Form extent: 32@32 depth: 1).
	imageMorph position: 36@55.

	mainColumn addMorph:  imageMorph.

]
