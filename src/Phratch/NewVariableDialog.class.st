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
		extent: 330@200; 
		yourself.
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
		vResizing: #shrinkWrap; 
		yourself.
	allSpritesRadioButton := ToggleButton
		onForm: (PhratchFrameMorph skinAt: #radioButtonOn)
		offForm: (PhratchFrameMorph skinAt: #radioButton).
	allSpritesRadioButton
		on;
		target: self;
		actionSelector: #toggleSpriteSpecific.
	label1 := StringMorph new
		contents: 'For all sprites' localized;
		font: (PhratchFrameMorph getFont: #NewVariableDialogBox); 
		yourself.
	radioButtons addMorphBack: allSpritesRadioButton.
	radioButtons
		addMorphBack:
			(Morph new
				extent: 5 @ 5;
				color: Color transparent; 
		yourself).
	radioButtons addMorphBack: label1.
	radioButtons
		addMorphBack:
			(Morph new
				extent: 15 @ 5;
				color: Color transparent; 
		yourself).
	thisSpriteRadioButton := allSpritesRadioButton fullCopy off.
	label2 := StringMorph new
		contents: 'For this sprite only' localized;
		font: (PhratchFrameMorph getFont: #NewVariableDialogBox); 
		yourself.
	radioButtons addMorphBack: thisSpriteRadioButton.
	radioButtons
		addMorphBack:
			(Morph new
				extent: 5 @ 5;
				color: Color transparent; 
		yourself).
	radioButtons addMorphBack: label2.
	PhratchTranslator isRTL
		ifTrue: [ 
			radioButtons submorphs reversed
				do: [ :m | 
					m delete.
					radioButtons addMorphBack: m ] ].
	mainColumn
		submorphsDo: [ :m | 
			m = messageLineMorphs
				ifFalse: [ m delete ] ].
	mainColumn
		addMorphBack:
				(Morph new
						extent: 5 @ 6;
						color: Color transparent; 
		yourself);
		addMorphBack: typeinMorph;
		addMorphBack:
				(Morph new
						extent: 5 @ 7;
						color: Color transparent; 
		yourself);
		addMorphBack: radioButtons;
		addMorphBack:
				(Morph new
						extent: 5 @ 7;
						color: Color transparent; 
		yourself);
		addMorphBack: buttonRow;
		addMorphBack: bottomSpacer
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
