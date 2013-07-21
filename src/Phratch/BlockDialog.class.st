Class {
	#name : #BlockDialog,
	#superclass : #StringDialog,
	#instVars : [
		'allSpritesRadioButton',
		'thisSpriteRadioButton',
		'spriteSpecificFlag',
		'scopeRadioButtons',
		'radioButtons',
		'commandBlockRadioButton',
		'reporterBlockRadioButton',
		'booleanBlockRadioButton',
		'booleanBlockFlag',
		'reporterBlockFlag',
		'categoryChooser',
		'category',
		'userSpec',
		'type'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #'instance creation' }
BlockDialog class >> ask: questionString [
	"Put up an instance of me to ask the user for the name for a new variable."

	| dialogBox |
	dialogBox := self new
		withButtonsForYes: false no: false okay: true cancel: true;
		title: questionString;
		message: 'category:' localized;
		extent: 330@200.
	^ dialogBox getUserResponse

]

{ #category : #'instance creation' }
BlockDialog class >> askWithCancel: questionString initialAnswer: aString [
	"Put up an instance of me to ask the user for string input (such as file name). The initial response text is set to the given string, which the user can replace or edit. This version includes a cancel button. Answer the empty string if cancelled."

	| dialogBox |
	dialogBox := self new
		withButtonsForYes: false no: false okay: true cancel: true;
		message: questionString;
		initialAnswer: aString.
	^ dialogBox getUserResponse

]

{ #category : #'instance creation' }
BlockDialog class >> isOpen [
	self allInstancesDo: [:bd |
		bd isInWorld ifTrue: [^true]].
	^ false
]

{ #category : #initialization }
BlockDialog >> buildCategoryChooser [

	| catList maxExtent buttons label offForm onForm overForm b pad leftColumnX rightColumnX x y catButtonsExtent |
	catList := #(
		motion		control
		looks		sensing
		sound		operators
		pen			variables
		other		list).

	categoryChooser := ImageFrameMorph new.
	categoryChooser initFromForm: (PhratchFrameMorph skinAt: #paintOptionsBackground).

	"Create new buttons, keeping track of the maximum extent."
	maxExtent := 75@0.
	buttons := catList collect: [:cat |
		label := (PhratchTranslator translationFor: cat asString) capitalized.

		(#(other list) includes: cat)
			ifTrue:[
				offForm := (PhratchFrameMorph skinAt: #variables).
				onForm := (PhratchFrameMorph skinAt: #variablesPressed).
				overForm := (PhratchFrameMorph skinAt: #variablesOver)]
			ifFalse: [
				offForm := (PhratchFrameMorph skinAt: cat).
				onForm := (PhratchFrameMorph skinAt: (cat, 'Pressed')).
				overForm := (PhratchFrameMorph skinAt: (cat, 'Over'))].

		PhratchTranslator isRTL
			ifTrue:[
				b := ResizableToggleButton2 new
					offForm:	(offForm flipBy: #horizontal centerAt: offForm center)
					onForm:		(onForm flipBy: #horizontal centerAt: onForm center)
					overForm:	(overForm flipBy: #horizontal centerAt: overForm center)]
			ifFalse:[
				b := ResizableToggleButton2 new
					offForm:	offForm
					onForm:		onForm
					overForm:	overForm].
		b
			label: label font: (PhratchFrameMorph getFont: #Category);
			setLabelColor: Color white;
			target: self;
			actionSelector: #category:;
			arguments: (Array with: cat);
			toggleButtonMode: true;
			toggleMode: false.
		PhratchTranslator isRTL
			ifTrue:[b rightJustifyInset: 10]
			ifFalse:[b leftJustifyInset: 10].
		maxExtent := maxExtent max: (b extent + (3 @ (-6))).
		b].

	"calculate catButtonsExtent"
	pad := 15. "padding on left, right, and betwen the button columns"
	catButtonsExtent := ((2 * maxExtent x) + (3 * pad)) @ (((catList size // 2) * (maxExtent y + 6)) + 25).

	"place the buttons"
	leftColumnX := self left + 12 + pad.
	rightColumnX := leftColumnX + maxExtent x + pad.
	x := leftColumnX.
	y := categoryChooser top + 17.
	1 to: buttons size do: [:i |
		b := buttons at: i.
		b extent: maxExtent.
		categoryChooser addMorph: (b position: x@y).
		i even
			ifTrue: [x := leftColumnX. y := y + b height + 6]
			ifFalse: [x := rightColumnX]].

	categoryChooser width: catButtonsExtent x + 25.
	categoryChooser height: catButtonsExtent y.

]

{ #category : #initialization }
BlockDialog >> buildScopeRadioButtons [
	| label1 label2 |
	scopeRadioButtons := AlignmentMorph newRow
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
	label1 := StringMorph new
		contents: ('For all sprites' localized);
		font: (PhratchFrameMorph getFont: #NewVariableDialogBox).
	scopeRadioButtons addMorphBack: allSpritesRadioButton.
	scopeRadioButtons addMorphBack: (Morph new extent: (5@5); color: Color transparent).
	scopeRadioButtons addMorphBack: label1.
	scopeRadioButtons addMorphBack: (Morph new extent: (15@5); color: Color transparent).

	thisSpriteRadioButton := allSpritesRadioButton fullCopy off.
	label2 := StringMorph new
		contents: ('For this sprite only' localized);
		font: (PhratchFrameMorph getFont: #NewVariableDialogBox).
	scopeRadioButtons addMorphBack: thisSpriteRadioButton.
	scopeRadioButtons addMorphBack: (Morph new extent: (5@5); color: Color transparent).
	scopeRadioButtons addMorphBack: label2.

	PhratchTranslator isRTL
		ifTrue: [scopeRadioButtons submorphs reversed do: [:m |
			m delete.
			scopeRadioButtons addMorphBack: m]].


]

{ #category : #initialization }
BlockDialog >> buildTypeChooser [
	| spacer |

	spacer := (Morph new extent: (5@5); color: Color transparent).

	radioButtons := AlignmentMorph newRow
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.

	commandBlockRadioButton := ToggleButton
		onForm: self formTypeCommandOn
		offForm: self formTypeCommandOff
		overForm: self formTypeCommandOver.
	commandBlockRadioButton
		on;
		target: self;
		actionSelector: #selectCommandBlock.

	radioButtons addMorphBack: commandBlockRadioButton.
	radioButtons addMorphBack: spacer fullCopy.

	reporterBlockRadioButton := ToggleButton
		onForm: self formTypeReporterOn
		offForm: self formTypeReporterOff
		overForm: self formTypeReporterOver.
	reporterBlockRadioButton
		off;
		target: self;
		actionSelector: #selectReporterBlock.

	radioButtons addMorphBack: reporterBlockRadioButton.
	radioButtons addMorphBack: spacer fullCopy.

	booleanBlockRadioButton := ToggleButton
		onForm: self formTypePredicateOn
		offForm: self formTypePredicateOff
		overForm: self formTypePredicateOver.
	booleanBlockRadioButton
		off;
		target: self;
		actionSelector: #selectBooleanBlock.

	radioButtons addMorphBack: booleanBlockRadioButton.

]

{ #category : #interaction }
BlockDialog >> category: aString [

	category := aString.

	self updateTypeSelection.

	categoryChooser submorphs do: [:m |
		(m isKindOf: ResizableToggleButton2) ifTrue: [
			m arguments first = category
				ifTrue: [m on]
				ifFalse: [m off]]].

	World activeHand newKeyboardFocus: tabFields first.

]

{ #category : #initialization }
BlockDialog >> disableAllButCategory [

	mainColumn submorphsDo: [: m |
		((m = messageLineMorphs) not) ifTrue: [m delete]].
	mainColumn
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: categoryChooser;
		addMorphBack: (Morph new extent: (5@75); color: Color transparent);
		addMorphBack: buttonRow;
		addMorphBack: bottomSpacer.

]

{ #category : #initialization }
BlockDialog >> disableAllButCategoryAndShape [

	| keep |

	keep := Array
				with: messageLineMorphs
				with: radioButtons.


	mainColumn submorphsDo: [: m |
		(keep includes: m)
			ifFalse: [m delete]].

	mainColumn
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: categoryChooser;
		addMorphBack: (Morph new extent: (5@75); color: Color transparent);

		addMorphBack: radioButtons;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);

		addMorphBack: buttonRow;
		addMorphBack: bottomSpacer.
]

{ #category : #interaction }
BlockDialog >> disableTypeDeclaration [

	radioButtons isHidden: true
]

{ #category : #private }
BlockDialog >> formTypeCommandOff [

	^ (CommandBlockMorph new 
			color: ((ScriptablePhratchMorph blockColorFor: category asString) mixed: 0.2 with: Color veryLightGray); 
			commandSpec: 'command' localized) 
		imageForm.

]

{ #category : #private }
BlockDialog >> formTypeCommandOn [

	^ (CommandBlockMorph new
			color: (ScriptablePhratchMorph blockColorFor: category asString); 
			commandSpec: 'command' localized) 
		imageForm.

]

{ #category : #private }
BlockDialog >> formTypeCommandOver [

	^ (CommandBlockMorph new 
			color: ((ScriptablePhratchMorph blockColorFor: category asString) mixed: 0.4 with: Color veryLightGray); 
			commandSpec: 'command' localized) 
		imageForm.

]

{ #category : #private }
BlockDialog >> formTypePredicateOff [

	^ (ReporterBlockMorph new 
			isBoolean: true; 
			color: ((ScriptablePhratchMorph blockColorFor: category asString) mixed: 0.2 with: Color veryLightGray); 
			commandSpec: 'predicate' localized) 
		imageForm.

]

{ #category : #private }
BlockDialog >> formTypePredicateOn [

	^ (ReporterBlockMorph new 
			isBoolean: true; 
			color: (ScriptablePhratchMorph blockColorFor: category asString); 
			commandSpec: 'predicate' localized) 
		imageForm.

]

{ #category : #private }
BlockDialog >> formTypePredicateOver [

	^ (ReporterBlockMorph new 
			isBoolean: true; 
			color: ((ScriptablePhratchMorph blockColorFor: category asString) mixed: 0.4 with: Color veryLightGray); 
			commandSpec: 'predicate' localized) 
		imageForm.
]

{ #category : #private }
BlockDialog >> formTypeReporterOff [

	^ (ReporterBlockMorph new 
			color: ((ScriptablePhratchMorph blockColorFor: category asString) mixed: 0.2 with: Color veryLightGray); 
			commandSpec: 'reporter' localized) 
		imageForm.

]

{ #category : #private }
BlockDialog >> formTypeReporterOn [

	^ (ReporterBlockMorph new color: (ScriptablePhratchMorph blockColorFor: category asString); commandSpec: 'reporter' localized) imageForm.

]

{ #category : #private }
BlockDialog >> formTypeReporterOver [

	^ (ReporterBlockMorph new 
			color: ((ScriptablePhratchMorph blockColorFor: category asString) mixed: 0.4 with: Color veryLightGray); 
			commandSpec: 'reporter' localized) 
		imageForm.

]

{ #category : #initialization }
BlockDialog >> getUserResponse [

	| newBlockSpec |
	newBlockSpec := super getUserResponse.
	newBlockSpec size = 0 ifTrue: [^ #cancelled].
	category  = #other ifTrue: [
		category = #none ].
	^ Array with: newBlockSpec with: reporterBlockFlag with: booleanBlockFlag with: category with: spriteSpecificFlag

]

{ #category : #initialization }
BlockDialog >> initialize [

	super initialize.
	reporterBlockFlag := false.
	booleanBlockFlag := false.
	type := #none.
	category := #other.
	spriteSpecificFlag := false.

	self buildTypeChooser.
	self buildCategoryChooser.
	self buildScopeRadioButtons.

	mainColumn submorphsDo: [: m |
		((m = messageLineMorphs) not) ifTrue: [m delete]].
	mainColumn
		addMorphBack: (Morph new extent: (5@6); color: Color transparent);
		addMorphBack: categoryChooser;
		addMorphBack: (Morph new extent: (5@115); color: Color transparent);
		addMorphBack: radioButtons;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: typeinMorph;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: scopeRadioButtons;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: buttonRow;
		addMorphBack: bottomSpacer.

	self category: category.


]

{ #category : #private }
BlockDialog >> selectBooleanBlock [

	reporterBlockFlag := true.
	booleanBlockFlag := true.
	type := #boolean.
	booleanBlockRadioButton
		onForm: self formTypePredicateOn;
		overForm: self formTypePredicateOn;
		on.
	commandBlockRadioButton
		offForm: self formTypeCommandOff;
		overForm: self formTypeCommandOver;
		off.
	reporterBlockRadioButton
		offForm: self formTypeReporterOff;
		overForm: self formTypeReporterOver;
		off.
	World activeHand newKeyboardFocus: tabFields first.

]

{ #category : #private }
BlockDialog >> selectCommandBlock [

	reporterBlockFlag := false.
	booleanBlockFlag := false.
	type := #none.
	booleanBlockRadioButton
		offForm: self formTypePredicateOff;
		overForm: self formTypePredicateOver;
		off.
	commandBlockRadioButton
		onForm: self formTypeCommandOn;
		overForm: self formTypeCommandOn;
		on.
	reporterBlockRadioButton
		offForm: self formTypeReporterOff;
		overForm: self formTypeReporterOver;
		off.
	World activeHand newKeyboardFocus: tabFields first.

]

{ #category : #private }
BlockDialog >> selectReporterBlock [

	reporterBlockFlag := true.
	booleanBlockFlag := false.
	type := #reporter.
	booleanBlockRadioButton
		offForm: self formTypePredicateOff;
		overForm: self formTypePredicateOver;
		off.
	commandBlockRadioButton
		offForm: self formTypeCommandOff;
		overForm: self formTypeCommandOver;
		off.
	reporterBlockRadioButton
		onForm: self formTypeReporterOn;
		overForm: self formTypeReporterOn;
		on.
	World activeHand newKeyboardFocus: tabFields first.

]

{ #category : #accessing }
BlockDialog >> setCategory: aSymbol [

	#none = aSymbol ifTrue: [
		^category := #other ].
	category := aSymbol
]

{ #category : #accessing }
BlockDialog >> setType: aSymbol [

	type := aSymbol
]

{ #category : #accessing }
BlockDialog >> setUserSpec: aString [

	userSpec := aString
]

{ #category : #private }
BlockDialog >> toggleSpriteSpecific [

	spriteSpecificFlag := spriteSpecificFlag not.
	spriteSpecificFlag
		ifTrue: [
			allSpritesRadioButton off.
			thisSpriteRadioButton on]
		ifFalse: [
			allSpritesRadioButton on.
			thisSpriteRadioButton off].
	World activeHand newKeyboardFocus: tabFields first.

]

{ #category : #accessing }
BlockDialog >> updateInitialSettings [

	self
		initialAnswer: userSpec;
		category: category;
		updateTypeSelection
]

{ #category : #private }
BlockDialog >> updateTypeSelection [
	#none = type ifTrue: [
		^self selectCommandBlock].

	#boolean = type ifTrue: [
		^self selectBooleanBlock].

	self selectReporterBlock
]
