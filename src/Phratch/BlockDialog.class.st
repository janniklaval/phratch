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
		extent: 330@200;
		yourself.
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
	catList := ((PhratchCategory allSubclasses select: [ :e | e visible ]) sort: [ :e :f | e order < f order ]) asArray.
		
	categoryChooser := ImageFrameMorph new.
	categoryChooser initFromForm: (PhratchFrameMorph skinAt: #paintOptionsBackground).	"Create new buttons, keeping End of statement list encounted -> track of the maximum extent."
	maxExtent := 75 @ 0.
	buttons := catList
		collect: [ :cat | 
			label := (PhratchTranslator translationFor: cat asString) capitalized.
			
			offForm := PhratchFrameMorph offFormBasicColor: cat color.
			onForm := PhratchFrameMorph onFormBasicColor: cat color.
			overForm := PhratchFrameMorph overFormBasicColor: cat color.
			
			b :=  ResizableToggleButton new offForm: offForm onForm: onForm overForm: overForm .
			b
				label: label font: (PhratchFrameMorph getFont: #Category);
				setLabelColor: Color white;
				target: self;
				actionSelector: #category:;
				arguments: (Array with: cat);
				toggleButtonMode: true;
				toggleMode: false.
			 b leftJustifyInset: 10 .
			maxExtent := maxExtent max: b extent + (3 @ -6).
			b ].	"calculate catButtonsExtent"
	pad := 15.	"padding on left, right, and betwen the button columns"
	catButtonsExtent := (2 * maxExtent x + (3 * pad) -10 ) @ (catList size // 2 * (maxExtent y + 6) + 25).	"place the buttons"
	leftColumnX := self left + 8 + pad.
	rightColumnX := leftColumnX + maxExtent x + pad.
	x := leftColumnX.
	y := categoryChooser top + 17.
	1 to: buttons size do: [ :i | 
		b := buttons at: i.
		b extent: maxExtent.
		categoryChooser addMorph: (b position: x @ y).
		i even
			ifTrue: [ 
				x := leftColumnX.
				y := y + b height + 6 ]
			ifFalse: [ x := rightColumnX ] ].
	categoryChooser width: catButtonsExtent x + 20.
	categoryChooser height: catButtonsExtent y
]

{ #category : #initialization }
BlockDialog >> buildScopeRadioButtons [
	| label1 label2 |
	scopeRadioButtons := AlignmentMorph newRow
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
		contents: ('For all sprites' localized);
		font: (PhratchFrameMorph getFont: #NewVariableDialogBox);
		yourself.
	scopeRadioButtons addMorphBack: allSpritesRadioButton.
	scopeRadioButtons addMorphBack: (Morph new extent: (5@5); color: Color transparent;
		yourself).
	scopeRadioButtons addMorphBack: label1.
	scopeRadioButtons addMorphBack: (Morph new extent: (15@5); color: Color transparent;
		yourself).

	thisSpriteRadioButton := allSpritesRadioButton fullCopy off.
	label2 := StringMorph new
		contents: ('For this sprite only' localized);
		font: (PhratchFrameMorph getFont: #NewVariableDialogBox);
		yourself.
	scopeRadioButtons addMorphBack: thisSpriteRadioButton.
	scopeRadioButtons addMorphBack: (Morph new extent: (5@5); color: Color transparent;
		yourself).
	scopeRadioButtons addMorphBack: label2.


]

{ #category : #initialization }
BlockDialog >> buildTypeChooser [
	| spacer |

	spacer := (Morph new extent: (5@5); color: Color transparent;
		yourself).

	radioButtons := AlignmentMorph newRow
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		yourself.

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
		(m isResizableToggleButton) ifTrue: [
			m arguments first = category
				ifTrue: [m on]
				ifFalse: [m off]]].

	World activeHand newKeyboardFocus: tabFields first.

]

{ #category : #initialization }
BlockDialog >> disableAllButCategory [
	mainColumn
		submorphsDo: [ :m | 
			m = messageLineMorphs
				ifFalse: [ m delete ] ].
	mainColumn
		addMorphBack:
				(Morph new
						extent: 5 @ 7;
						color: Color transparent;
		yourself);
		addMorphBack: categoryChooser;
		addMorphBack:
				(Morph new
						extent: 5 @ "110" (categoryChooser height - 20);
						color: Color transparent;
		yourself);
		addMorphBack: buttonRow;
		addMorphBack: bottomSpacer
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
		addMorphBack: (Morph new extent: (5@7); color: Color transparent;
		yourself);
		addMorphBack: categoryChooser;
		addMorphBack: (Morph new extent: (5@"175" (categoryChooser height - 20)); color: Color transparent;
		yourself);

		addMorphBack: radioButtons;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent;
		yourself);

		addMorphBack: buttonRow;
		addMorphBack: bottomSpacer.
]

{ #category : #private }
BlockDialog >> formTypeCommandOff [

	^ (CommandBlockMorph new 
			color: ((PhratchCategory blockColorFor: category asString) mixed: 0.2 with: Color veryLightGray); 
			commandSpec: 'command' localized;
		yourself) 
		imageForm.

]

{ #category : #private }
BlockDialog >> formTypeCommandOn [

	^ (CommandBlockMorph new
			color: (PhratchCategory blockColorFor: category asString); 
			commandSpec: 'command' localized;
		yourself) 
		imageForm.

]

{ #category : #private }
BlockDialog >> formTypeCommandOver [

	^ (CommandBlockMorph new 
			color: ((PhratchCategory blockColorFor: category asString) mixed: 0.4 with: Color veryLightGray); 
			commandSpec: 'command' localized;
		yourself) 
		imageForm.

]

{ #category : #private }
BlockDialog >> formTypePredicateOff [

	^ (ReporterBlockMorph new 
			isBoolean: true; 
			color: ((PhratchCategory blockColorFor: category asString) mixed: 0.2 with: Color veryLightGray); 
			commandSpec: 'predicate' localized;
		yourself) 
		imageForm.

]

{ #category : #private }
BlockDialog >> formTypePredicateOn [

	^ (ReporterBlockMorph new 
			isBoolean: true; 
			color: (PhratchCategory blockColorFor: category asString); 
			commandSpec: 'predicate' localized;
		yourself) 
		imageForm.

]

{ #category : #private }
BlockDialog >> formTypePredicateOver [

	^ (ReporterBlockMorph new 
			isBoolean: true; 
			color: ((PhratchCategory blockColorFor: category asString) mixed: 0.4 with: Color veryLightGray); 
			commandSpec: 'predicate' localized;
		yourself) 
		imageForm.
]

{ #category : #private }
BlockDialog >> formTypeReporterOff [

	^ (ReporterBlockMorph new 
			color: ((PhratchCategory blockColorFor: category asString) mixed: 0.2 with: Color veryLightGray); 
			commandSpec: 'reporter' localized;
		yourself) 
		imageForm.

]

{ #category : #private }
BlockDialog >> formTypeReporterOn [

	^ (ReporterBlockMorph new color: (PhratchCategory blockColorFor: category asString); commandSpec: 'reporter' localized;
		yourself) imageForm.

]

{ #category : #private }
BlockDialog >> formTypeReporterOver [

	^ (ReporterBlockMorph new 
			color: ((PhratchCategory blockColorFor: category asString) mixed: 0.4 with: Color veryLightGray); 
			commandSpec: 'reporter' localized;
		yourself) 
		imageForm.

]

{ #category : #interaction }
BlockDialog >> getUserResponse [

	| newBlockSpec |
	newBlockSpec := super getUserResponse.
	newBlockSpec size = 0 ifTrue: [^ #cancelled].
	category  = #other ifTrue: [
		category := #none ].
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
		addMorphBack: categoryChooser;
		addMorphBack:
				(Morph new
						extent: 5 @ "115" (categoryChooser height - 20);
						color: Color transparent;
		yourself);
		addMorphBack: radioButtons;
		addMorphBack:
				(Morph new
						extent: 5 @ 7;
						color: Color transparent;
		yourself);
		addMorphBack: typeinMorph;
		addMorphBack:
				(Morph new
						extent: 5 @ 7;
						color: Color transparent;
		yourself);
		addMorphBack: scopeRadioButtons;
		addMorphBack:
				(Morph new
						extent: 5 @ 7;
						color: Color transparent;
		yourself);
		addMorphBack: buttonRow;
		addMorphBack: bottomSpacer.
	self category: category
]

{ #category : #testing }
BlockDialog >> isBlockDialog [

	^ true
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
