Class {
	#name : #PhratchNotesDialog,
	#superclass : #DialogBoxMorph,
	#instVars : [
		'scratchFrame',
		'commentMorph'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #'instance creation' }
PhratchNotesDialog class >> editNotesFor: aScratchFrameMorph [
	"Choose a name for sharing the current Scratch project file. Display the project thumbnail and info string and allow the info string to be edited. Answer the new project name."

	^ self new
		createNotesDialogFor: aScratchFrameMorph;
		extent: 350@450.

]

{ #category : #other }
PhratchNotesDialog >> comment [

	^ commentMorph contents

]

{ #category : #initialization }
PhratchNotesDialog >> createNotesDialogFor: aScratchFrameMorph [
	"Create a Scratch project notes dialog box."

	| commentFont |
	commentFont := (ScratchFrameMorph getFont: #ProjectNotes).

	commentMorph := ScrollingStringMorph new
		borderWidth: 0;
		contents: '';
		font: commentFont;
		backForm: (ScratchFrameMorph skinAt: #stringFieldFrame);
		width: 300.

	self title: 'Project Notes'.
	mainColumn addMorphBack: commentMorph.
	mainColumn addMorphBack: buttonRow.

	scratchFrame := aScratchFrameMorph.
	commentMorph contents: scratchFrame projectCommentOrTemplate.
	bottomSpacer delete.
	bottomSpacer := nil.

	tabFields add: commentMorph.

]

{ #category : #other }
PhratchNotesDialog >> getUserResponse [
	"Wait for the user to respond, then answer #ok if the okay button was pressed or #cancelled if the user cancels the operation."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop."

	| w |
	self openInWorld.
	self centerOnScreen.

	w := self world.
	w activeHand newKeyboardFocus: commentMorph.

	done := false.	
	[done] whileFalse: [w doOneCycle].
	response = #cancelled ifTrue: [^ #cancelled].

	"save notes in project"
	scratchFrame projectComment: commentMorph contents.

	^ #ok

]

{ #category : #initialization }
PhratchNotesDialog >> initialize [

	super initialize.
	self withButtonsForYes: false no: false okay: true cancel: true.

]
