Class {
	#name : #NewVariableDialog,
	#superclass : #StringDialog,
	#instVars : [
		'allSpritesRadioButton',
		'thisSpriteRadioButton',
		'spriteSpecificFlag',
		'radioButtons'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #'instance creation' }
NewVariableDialog class >> ask: questionString [
	"Put up an instance of me to ask the user for the name for a new variable."

	| dialogBox |
	dialogBox := self new
		withButtonsForYes: false no: false okay: true cancel: true;
		message: questionString;
		extent: 330@200.
	^ dialogBox getUserResponse

]

{ #category : #'instance creation' }
NewVariableDialog class >> askWithCancel: questionString initialAnswer: aString [
	"Put up an instance of me to ask the user for string input (such as file name). The initial response text is set to the given string, which the user can replace or edit. This version includes a cancel button. Answer the empty string if cancelled."

	| dialogBox |
	dialogBox := self new
		withButtonsForYes: false no: false okay: true cancel: true;
		message: questionString;
		initialAnswer: aString.
	^ dialogBox getUserResponse

]

{ #category : #interaction }
NewVariableDialog >> getUserResponse [

	| newVarName |
	newVarName := super getUserResponse.
	newVarName size = 0 ifTrue: [^ #cancelled].
	^ Array with: newVarName with: spriteSpecificFlag

]

{ #category : #initialization }
NewVariableDialog >> initialize [

	| label1 label2 |
	super initialize.
	spriteSpecificFlag := false.

	radioButtons := AlignmentMorph newRow
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.

	allSpritesRadioButton := ToggleButton
		onForm: (PhratchFrameMorph skinAt: #radioButtonOn)
		offForm: (PhratchFrameMorph skinAt: #radioButton).
	allSpritesRadioButton
		on;
		target: self;
		actionSelector: #toggleSpriteSpecific.
	label1 := PhratchStringMorph new
		contents: ('For all sprites' localized);
		font: (PhratchFrameMorph getFont: #NewVariableDialogBox).
	radioButtons addMorphBack: allSpritesRadioButton.
	radioButtons addMorphBack: (Morph new extent: (5@5); color: Color transparent).
	radioButtons addMorphBack: label1.
	radioButtons addMorphBack: (Morph new extent: (15@5); color: Color transparent).

	thisSpriteRadioButton := allSpritesRadioButton fullCopy off.
	label2 := PhratchStringMorph new
		contents: ('For this sprite only' localized);
		font: (PhratchFrameMorph getFont: #NewVariableDialogBox).
	radioButtons addMorphBack: thisSpriteRadioButton.
	radioButtons addMorphBack: (Morph new extent: (5@5); color: Color transparent).
	radioButtons addMorphBack: label2.

	PhratchTranslator isRTL
		ifTrue: [radioButtons submorphs reversed do: [:m |
			m delete.
			radioButtons addMorphBack: m]].

	mainColumn submorphsDo: [: m |
		((m = messageLineMorphs) not) ifTrue: [m delete]].
	mainColumn
		addMorphBack: (Morph new extent: (5@6); color: Color transparent);
		addMorphBack: typeinMorph;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: radioButtons;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: buttonRow;
		addMorphBack: bottomSpacer.

]

{ #category : #private }
NewVariableDialog >> toggleSpriteSpecific [

	spriteSpecificFlag := spriteSpecificFlag not.
	spriteSpecificFlag
		ifTrue: [
			allSpritesRadioButton off.
			thisSpriteRadioButton on]
		ifFalse: [
			allSpritesRadioButton on.
			thisSpriteRadioButton off].

]
