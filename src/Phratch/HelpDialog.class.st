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
HelpDialog class >> showForm: aForm [
	"HelpDialogMorph showForm: (Form fromFileNamed: 'move.gif')"

	| dialog |
	dialog := super new
		withButtonsForYes: false no: false okay: true cancel: false;
		title: 'help';
		helpForm: aForm;
		extent: (aForm extent + (80@145)).
	^ dialog getUserResponse

]

{ #category : #other }
HelpDialog >> helpForm: anImage [

	| f |
	f := anImage.
	(f isKindOf: ColorForm) ifTrue: [
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

	mainColumn addMorph: imageMorph.

]
