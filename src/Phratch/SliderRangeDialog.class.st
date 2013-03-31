"
I am an extension of the DialogBoxMorph used to request the slider max and min from the user.

"
Class {
	#name : #SliderRangeDialog,
	#superclass : #DialogBoxMorph,
	#instVars : [
		'minMorph',
		'maxMorph',
		'radioButtons'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #'instance creation' }
SliderRangeDialog class >> initialMin: defaultMin max: defaultMax [
	"Put up an instance of me to ask the user for string input (such as file name). The initial response text is set to the given string, which the user can replace or edit. Answer the edited string."

	| dialogBox |
	dialogBox := self new
		withButtonsForYes: false no: false okay: true cancel: true;
		initialMin: defaultMin max: defaultMax.
	^ dialogBox getUserResponse

]

{ #category : #interaction }
SliderRangeDialog >> accept [
	"Enter or carriage return typed or ok button pressed."

	self yes.

]

{ #category : #interaction }
SliderRangeDialog >> getUserResponse [
	"Wait for the user to fill in the max and min fields, then report an array containing them. Answer nil if the user cancels the operation."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop."

	| w n m |
	self openInWorld.
	self centerOnScreen.

	w := self world.
	w activeHand newKeyboardFocus: minMorph.
	done := false.
	[done] whileFalse: [w doOneCycle].  "wait for user to press a button"

	self delete.
	w doOneCycle.  "erase myself from the screen"
	response = #cancelled ifTrue: [^ nil].
	
	n := minMorph contents asNumberNoError.
	m := maxMorph contents asNumberNoError.
	^ Array with: (n min: m) with: (n max: m)

]

{ #category : #'event handling' }
SliderRangeDialog >> handlesMouseOver: evt [

	^ true

]

{ #category : #initialization }
SliderRangeDialog >> initialMin: minVal max: maxVal [
	"Set the default min and max values."

	minMorph contents: minVal printString.
	maxMorph contents: maxVal printString.

]

{ #category : #initialization }
SliderRangeDialog >> initialize [
	"Similar to my superclass, but with a string field for the user's response."

	| minLabel maxLabel |
	super initialize.
	self title: '?'.
	self message: 'Slider range:'.

	minLabel := ScratchStringMorph new
		contents: 'Min:' localized;
		forceUnicodeRendering: true;
		font: (ScratchFrameMorph getFont: #StringDialogTypeIn).
	maxLabel := minLabel fullCopy contents: 'Max:' localized.

	minMorph := StringFieldMorph new
		client: self;
		font: (ScratchFrameMorph getFont: #StringDialogTypeIn);
		color: Color transparent;
		width: (40 max: ((maxLabel stringWidth: '100') + 9)).
	maxMorph := minMorph fullCopy.
	tabFields
		add: minMorph;
		add: maxMorph.

	radioButtons := AlignmentMorph newRow color: Color transparent;
		color: self color;
		hResizing: #shrinkWrap;
		cellPositioning: #leftCenter;
		centering: #center.
	radioButtons addMorphBack: minLabel.
	radioButtons addMorphBack: (Morph new extent: (5@5); color: Color transparent).
	radioButtons addMorphBack: minMorph.
	radioButtons addMorphBack: (Morph new extent: (5@5); color: Color transparent).
	radioButtons addMorphBack: maxLabel.
	radioButtons addMorphBack: (Morph new extent: (5@5); color: Color transparent).
	radioButtons addMorphBack: maxMorph.
	ScratchTranslator isRTL
		ifTrue: [radioButtons submorphs reversed do: [:m |
			m delete.
			radioButtons addMorphBack: m]].

	mainColumn submorphsDo: [: m |
		((m = messageLineMorphs) not) ifTrue: [m delete]].
	mainColumn
		addMorphBack: messageLineMorphs;
		addMorphBack: (Morph new extent: (5@6); color: Color transparent);
		addMorphBack: radioButtons;
		addMorphBack: (Morph new extent: (5@6); color: Color transparent);
		addMorphBack: buttonRow;
		addMorphBack: bottomSpacer.

	self extent: 200@200.

]

{ #category : #'event handling' }
SliderRangeDialog >> mouseEnter: evt [
	"Grab the keyboard focus when the mouse enters me."

	evt hand newKeyboardFocus: minMorph.

]
