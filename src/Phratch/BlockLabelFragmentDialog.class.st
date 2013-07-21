Class {
	#name : #BlockLabelFragmentDialog,
	#superclass : #StringDialog,
	#instVars : [
		'fragment',
		'inputRadioButton',
		'textRadioButton',
		'slotShapeButton',
		'fragmentRadioButtons',
		'category',
		'isCollapsed',
		'slotShapesGroup',
		'groupExtent',
		'radioObject',
		'radioAny',
		'radioNumber',
		'radioText',
		'radioBoolean',
		'radioList',
		'radioCommand',
		'radioReporter',
		'radioPredicate',
		'radioLoop',
		'radioUnevaluated',
		'radioUnevaluatedBoolean',
		'defaultLabel',
		'defaultField',
		'divBar',
		'singleRadioButton',
		'multipleRadioButton',
		'externalizedRadioButton'
	],
	#classVars : [
		'Expanded'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #'class initialization' }
BlockLabelFragmentDialog class >> initialize [
	Expanded := false
]

{ #category : #accessing }
BlockLabelFragmentDialog class >> isExpanded [
	"currently disabled - commented out, -jens"

	^ Expanded
]

{ #category : #accessing }
BlockLabelFragmentDialog class >> isExpanded: bool [
	Expanded := bool
]

{ #category : #'instance creation' }
BlockLabelFragmentDialog class >> on: aBlockLabelFragment category: aSymbol [
	"Put up an instance of me to ask the user for the name for a new variable."

	| dialogBox |
	(World allMorphs detect: [:m | m isKindOf: self] ifNone: [nil])
		ifNotNil: [^self].
	dialogBox := self new
		category: aSymbol;
		fragment: aBlockLabelFragment;
		buildWidgets;
		refresh;
		toggleExpandIfInput.
	^ dialogBox getUserResponse

]

{ #category : #interaction }
BlockLabelFragmentDialog >> acceptDefaultValue [

	| cnts |

	(#(any number text unevaluated) includes: fragment type) 
		ifFalse: [ 
			fragment default: ''. 
			^ self].
		
	#number = fragment type 
		ifTrue: [
			cnts := defaultField contents.
			cnts = ' '
				ifTrue: [ fragment default: cnts ]
				ifFalse: [ fragment default: cnts asNumberNoError ]]
		ifFalse: [fragment default: defaultField contents asString ]

]

{ #category : #interaction }
BlockLabelFragmentDialog >> arityMultiple [

	singleRadioButton off.
	multipleRadioButton on.
	externalizedRadioButton off.
	self updateSlotShape

]

{ #category : #interaction }
BlockLabelFragmentDialog >> aritySingle [

	singleRadioButton on.
	multipleRadioButton off.
	externalizedRadioButton off.
	self updateSlotShape

]

{ #category : #initialization }
BlockLabelFragmentDialog >> buildSlotTypeChoices [
	 | lineObject lineAny lineNumber lineText lineBoolean lineList lineCommand lineReporter linePredicate lineLoop lineUnevaluated lineUnevaluatedBoolean
	picture label typeChooser picSize lineWidth typeLabel typeFont bg titleClr labelClr labelSingle
	labelMultiple labelExternalized temp onForm offForm|

	onForm :=  PhratchFrameMorph skinAt: #radioButtonOn.
	offForm := PhratchFrameMorph skinAt: #radioButton.

	picSize := 45@25.
	lineWidth := 160 "125".
	titleClr := Color gray muchLighter.
	labelClr := Color white.

	typeChooser := ImageFrameMorph new.
	bg := (PhratchFrameMorph skinAt:  #paintOptionsBackground) deepCopy.
	bg replaceColor: (bg colorAt: bg center) with: PhratchFrameMorph palettePaneColor.
	typeChooser initFromForm: bg.
	typeChooser extent: (lineWidth + 20) * 3 @ (picSize y * 9).

	typeFont := PhratchFrameMorph getFont: #FilePickerEntry.

	typeLabel := ((StringMorph contents: 'Input type/Shape of slot:' localized font: (PhratchFrameMorph getFont: #Label))
		color: titleClr;
		position: typeChooser position + (15@14);
		yourself).

	typeChooser addMorph: typeLabel.

"+++++++++++  object ++++++++++++++++"

	radioObject := ToggleButton
		onForm: onForm
		offForm: offForm.
	radioObject
		off;
		target: self;
		actionSelector: #typeObject;
		top: 6.
	picture := ImageMorph new form: (self slotShapeFormFor: #object size: picSize).
	label := (StringMorph contents: 'Object' localized font: typeFont)
		color: labelClr.
	lineObject := Morph new color: Color transparent.
	lineObject extent: lineWidth @ picSize y.
	picture left: radioObject right.
	label left: picture right; top: 4.
	lineObject
		addMorph: radioObject;
		addMorph: picture;
		addMorph: label.
	lineObject position: typeLabel bottomLeft + (0@10).
	typeChooser addMorph: lineObject.	

"+++++++++++  number ++++++++++++++++"

	radioNumber := ToggleButton
		onForm: onForm
		offForm: offForm.
	radioNumber
		off;
		target: self;
		actionSelector: #typeNumber;
		top: 6.
	picture := ImageMorph new form: (self slotShapeFormFor: #number size: picSize).
	label := (StringMorph contents: 'Number' localized font: typeFont)
		color: labelClr.
	lineNumber := Morph new color: Color transparent.
	lineNumber extent: lineWidth @ picSize y.
	picture left: radioNumber right.
	label left: picture right; top: 4.
	lineNumber
		addMorph: radioNumber;
		addMorph: picture;
		addMorph: label.
	lineNumber position: lineObject bottomLeft.
	typeChooser addMorph: lineNumber.	

"++++++++++++++  text  +++++++++++++"

	radioText := ToggleButton
		onForm: onForm
		offForm: offForm.
	radioText
		off;
		target: self;
		actionSelector: #typeText;
		top: 6.
	picture := ImageMorph new form: (self slotShapeFormFor: #text size: picSize).
	label := (StringMorph contents: 'Text' localized font: typeFont)
		color: labelClr.
	lineText := Morph new color: Color transparent.
	lineText extent: lineWidth @ picSize y.
	picture left: radioText right.
	label left: picture right; top: 4.
	lineText
		addMorph: radioText;
		addMorph: picture;
		addMorph: label. 
	lineText position: lineObject topRight + (10@0).
	typeChooser addMorph: lineText.	

"++++++++++++  list  +++++++++++++++"

	radioList := ToggleButton
		onForm: onForm
		offForm: offForm.
	radioList
		off;
		target: self;
		actionSelector: #typeList;
		top: 6.
	picture := ImageMorph new form: (self slotShapeFormFor: #list size: picSize).
	label := (StringMorph contents: 'List' localized font: typeFont)
		color: labelClr.
	lineList := Morph new color: Color transparent.
	lineList extent: lineWidth @ picSize y.
	picture left: radioList right.
	label left: picture right; top: 4.
	lineList
		addMorph: radioList;
		addMorph: picture;
		addMorph: label. 
	lineList position: lineText topRight + (10@0).
	typeChooser addMorph: lineList.	

"++++++++++++  any  +++++++++++++++"
	
	radioAny := ToggleButton
		onForm: onForm
		offForm: offForm.
	radioAny
		off;
		target: self;
		actionSelector: #typeAny; 
		top: 6.
	picture := ImageMorph new form: (self slotShapeFormFor: #any size: picSize).
	label := (StringMorph contents: 'Any type' localized font: typeFont)
		color: labelClr.
	lineAny := Morph new color: Color transparent.
	lineAny extent: lineWidth @ picSize y.
	picture left: radioAny right.
	label left: picture right; top: 4.
	lineAny
		addMorph: radioAny;
		addMorph: picture;
		addMorph: label. 
	lineAny position: lineText bottomLeft.
	typeChooser addMorph: lineAny.	

"++++++++++++  bool  +++++++++++++++"

	radioBoolean := ToggleButton
		onForm: onForm
		offForm: offForm.
	radioBoolean
		off;
		target: self;
		actionSelector: #typeBoolean;
		top: 6.
	picture := ImageMorph new form: (self slotShapeFormFor: #boolean size: picSize).
	label := (StringMorph contents: 'Boolean (T/F)' localized font: typeFont)
		color: labelClr.
	lineBoolean := Morph new color: Color transparent.
	lineBoolean extent: lineWidth @ picSize y.
	picture left: radioBoolean right.
	label left: picture right; top: 4.
	lineBoolean
		addMorph: radioBoolean;
		addMorph: picture;
		addMorph: label. 
	lineBoolean position: lineList bottomLeft.
	typeChooser addMorph: lineBoolean.	

"++++++++++++  command  +++++++++++++++"

	radioCommand := ToggleButton
		onForm: onForm
		offForm: offForm.
	radioCommand
		off;
		target: self;
		actionSelector: #typeCommand;
		top: 6.
	picture := ImageMorph new form: (self slotShapeFormFor: #command size: picSize).
	label := (StringMorph contents: 'Command (inline)' localized font: typeFont)
		color: labelClr.
	lineCommand := Morph new color: Color transparent.
	lineCommand extent: lineWidth @ picSize y.
	picture left: radioCommand right.
	label left: picture right; top: 4.
	lineCommand
		addMorph: radioCommand;
		addMorph: picture;
		addMorph: label. 
	lineCommand position: lineNumber left @ lineAny bottom.
	typeChooser addMorph: lineCommand.	

"+++++++++++  reporter  ++++++++++++++++"

	radioReporter := ToggleButton
		onForm: onForm
		offForm: offForm.
	radioReporter
		off;
		target: self;
		actionSelector: #typeReporter;
		top: 6.
	picture := ImageMorph new form: (self slotShapeFormFor: #reporter size: picSize).
	label := (StringMorph contents: 'Reporter' localized font: typeFont)
		color: labelClr.
	lineReporter := Morph new color: Color transparent.
	lineReporter extent: lineWidth @ picSize y.
	picture left: radioReporter right.
	label left: picture right; top: 4.
	lineReporter
		addMorph: radioReporter;
		addMorph: picture;
		addMorph: label. 
	lineReporter position: lineAny bottomLeft.
	typeChooser addMorph: lineReporter.	

"+++++++++++  predicate  ++++++++++++++++"

	radioPredicate := ToggleButton
		onForm: onForm
		offForm: offForm.
	radioPredicate
		off;
		target: self;
		actionSelector: #typePredicate;
		top: 6.
	picture := ImageMorph new form: (self slotShapeFormFor: #predicate size: picSize).
	label := (StringMorph contents: 'Predicate' "(Reporter of Boolean)" localized font: typeFont)
		color: labelClr.
	linePredicate := Morph new color: Color transparent.
	linePredicate extent: lineWidth @ picSize y.
	picture left: radioPredicate right.
	label left: picture right; top: 4.
	linePredicate
		addMorph: radioPredicate;
		addMorph: picture;
		addMorph: label. 
	linePredicate position:  lineBoolean bottomLeft. 
	typeChooser addMorph: linePredicate.

"+++++++++++++  command (C-shape)  ++++++++++++++"

	radioLoop := ToggleButton
		onForm: onForm
		offForm: offForm.
	radioLoop
		off;
		target: self;
		actionSelector: #typeLoop;
		top: 6.
	picture := ImageMorph new form: (self slotShapeFormFor: #loop size: picSize).
	label := (StringMorph contents: 'C-shape' localized font: typeFont)
		color: labelClr.
	lineLoop := Morph new color: Color transparent.
	lineLoop extent: lineWidth @ picSize y.
	picture left: radioLoop right.
	label left: picture right; top: 4.
	lineLoop
		addMorph: radioLoop;
		addMorph: picture;
		addMorph: label. 
	lineLoop position: lineCommand bottomLeft.
	typeChooser addMorph: lineLoop.

"++++++++++++++  any (unevaluated)  +++++++++++++"

	radioUnevaluated := ToggleButton
		onForm: onForm
		offForm: offForm.
	radioUnevaluated
		off;
		target: self;
		actionSelector: #typeUnevaluated;
		top: 6.
	picture := ImageMorph new form: (self slotShapeFormFor: #unevaluated size: picSize).
	label := (StringMorph contents: 'Any (unevaluated)' localized font: typeFont)
		color: labelClr.
	lineUnevaluated := Morph new color: Color transparent.
	lineUnevaluated extent: lineWidth @ picSize y.
	picture left: radioUnevaluated right.
	label left: picture right; top: 4.
	lineUnevaluated
		addMorph: radioUnevaluated;
		addMorph: picture;
		addMorph: label. 
	lineUnevaluated position: lineReporter bottomLeft.
	typeChooser addMorph: lineUnevaluated.	

"++++++++++++++  boolean (unevaluated)  +++++++++++++"

	radioUnevaluatedBoolean := ToggleButton
		onForm: onForm
		offForm: offForm.
	radioUnevaluatedBoolean
		off;
		target: self;
		actionSelector: #typeUnevaluatedBoolean;
		top: 6.
	picture := ImageMorph new form: (self slotShapeFormFor: #unevaluatedBoolean size: picSize).
	label := (StringMorph contents: 'Boolean (unevaluated)' localized font: typeFont)
		color: labelClr.
	lineUnevaluatedBoolean := Morph new color: Color transparent.
	lineUnevaluatedBoolean extent: lineWidth @ picSize y.
	picture left: radioUnevaluatedBoolean right.
	label left: picture right; top: 4.
	lineUnevaluatedBoolean
		addMorph: radioUnevaluatedBoolean;
		addMorph: picture;
		addMorph: label. 
	lineUnevaluatedBoolean position: linePredicate bottomLeft.
	typeChooser addMorph: lineUnevaluatedBoolean.	

"+++++++++++++++++++++++++++"

	divBar := ImageMorph new form: (PhratchFrameMorph skinAt: #connector).
	divBar 
		top: lineLoop bottom + 5;
		left: "lineReporter left "typeChooser left + (typeChooser width - (divBar width * 3) // 3).
	typeChooser addMorph: divBar.

	temp := divBar veryDeepCopy.
	temp position: divBar topRight.
	typeChooser addMorph: temp.

	temp := divBar veryDeepCopy.
	temp position: divBar topRight + (temp width @ 0).
	typeChooser addMorph: temp.


	singleRadioButton := ToggleButton
		onForm: (PhratchFrameMorph skinAt: #radioButtonOn)
		offForm: (PhratchFrameMorph skinAt: #radioButton).
	singleRadioButton
		on;
		target: self;
		actionSelector: #aritySingle;
		position: lineLoop left @ (divBar bottom + 9).
	typeChooser addMorph: singleRadioButton.	

	labelSingle := ((StringMorph contents: 'Single input.' localized font: (PhratchFrameMorph getFont: #Label))
		color: titleClr;
		position: singleRadioButton topRight + (4@0);
		yourself).
	typeChooser addMorph: labelSingle.

	defaultLabel := ((StringMorph contents: 'Default value:' localized font: (PhratchFrameMorph getFont: #Label))
		color: titleClr;
		position: labelSingle topRight + (10@0);
		yourself).
	typeChooser addMorph: defaultLabel.

	typeChooser
		addMorph: (defaultField := StringFieldMorph
			new client: self;
			borderWidth: 2;
			color: "Color lightGray twiceLighter "(Color r: (211/255) g: (214/255) b: (216/255))).
	defaultField
		font: typeFont;
		width: lineWidth;
		position: defaultLabel topRight + (10@ -4);
		isNumeric: fragment default isNumber;
		contents: fragment default asString.

	groupExtent := typeChooser extent.
	slotShapesGroup := typeChooser.

	multipleRadioButton := ToggleButton
		onForm: (PhratchFrameMorph skinAt: #radioButtonOn)
		offForm: (PhratchFrameMorph skinAt: #radioButton).
	multipleRadioButton
		off;
		target: self;
		actionSelector: #arityMultiple;
		position: singleRadioButton bottomLeft + (0@6).
	typeChooser addMorph: multipleRadioButton.	

	labelMultiple := ((StringMorph contents: 'Multiple inputs (value is list of inputs)' localized font: (PhratchFrameMorph getFont: #Label))
		color: titleClr;
		position: multipleRadioButton topRight + (4@0);
		yourself).
	typeChooser addMorph: labelMultiple.

	externalizedRadioButton := ToggleButton
		onForm: (PhratchFrameMorph skinAt: #radioButtonOn)
		offForm: (PhratchFrameMorph skinAt: #radioButton).
	externalizedRadioButton
		off;
		target: self;
		actionSelector: #externalized;
		position: multipleRadioButton bottomLeft + (0@6).
	typeChooser addMorph: externalizedRadioButton.	

	labelExternalized := ((StringMorph contents: 'Make internal variable visible to caller' localized font: (PhratchFrameMorph getFont: #Label))
		color: titleClr;
		position: externalizedRadioButton topRight + (4@0);
		yourself).
	typeChooser addMorph: labelExternalized.


]

{ #category : #initialization }
BlockLabelFragmentDialog >> buildWidgets [


	| titleLabel inputLabel |
	fragmentRadioButtons := AlignmentMorph newRow
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.

	textRadioButton := ToggleButton
		onForm: (PhratchFrameMorph skinAt: #radioButtonOn)
		offForm: (PhratchFrameMorph skinAt: #radioButton).
	textRadioButton
		on;
		target: self;
		actionSelector: #toggleIsInput.

	titleLabel := ImageMorph new form: self labelButtonForm.
	fragmentRadioButtons addMorphBack: textRadioButton.
	fragmentRadioButtons addMorphBack: (Morph new extent: (5@5); color: Color transparent).
	fragmentRadioButtons addMorphBack: titleLabel.
	fragmentRadioButtons addMorphBack: (Morph new extent: (15@5); color: Color transparent).

	inputRadioButton := textRadioButton fullCopy off.
	inputLabel := ImageMorph new form: self inputButtonForm.
	fragmentRadioButtons addMorphBack: inputRadioButton.
	fragmentRadioButtons addMorphBack: (Morph new extent: (5@5); color: Color transparent).
	fragmentRadioButtons addMorphBack: inputLabel "label2".


	fragmentRadioButtons addMorphBack: (Morph new extent: (5@5); color: Color transparent).

	slotShapeButton := IconicButton new
		labelGraphic: (PhratchFrameMorph skinAt: #arrowOpenComment) borderWidth: 1;
		actionSelector: #toggleExpand;
		target: self;
		actWhen: #buttonDown.
	fragmentRadioButtons addMorphBack: slotShapeButton.

	self buildSlotTypeChoices.

	mainColumn submorphsDo: [: m |
		((m = messageLineMorphs) not) ifTrue: [m delete]].
	mainColumn
		addMorphBack: (Morph new extent: (5@6); color: Color transparent);
		addMorphBack: typeinMorph;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: fragmentRadioButtons;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: slotShapesGroup;
		addMorphBack: (Morph new extent: (5@7); color: Color transparent);
		addMorphBack: buttonRow;
		addMorphBack: bottomSpacer.


]

{ #category : #accessing }
BlockLabelFragmentDialog >> category: aSymbol [
	category := aSymbol
]

{ #category : #interaction }
BlockLabelFragmentDialog >> deleteItem [
	"Delete button was pressed."

	fragment delete.
	response := fragment.
	done := true.
	self delete.
	World doOneCycle.  "erase myself from the screen"

]

{ #category : #private }
BlockLabelFragmentDialog >> extent: aPoint [
	
	bounds extent = aPoint ifFalse: [
		self changed.
		bounds := bounds topLeft extent: aPoint.
		self layoutChanged.
		self changed].

	self fixLayoutForExtent: aPoint.

"	UserPos isNil & resizeOffset isNil ifTrue: [
		w := self world.
		w ifNotNil: [self position: w center - (self extent // 2)]]."  "center on screen"

]

{ #category : #interaction }
BlockLabelFragmentDialog >> externalized [

	singleRadioButton off.
	multipleRadioButton off.
	externalizedRadioButton on.
	self updateSlotShape

]

{ #category : #accessing }
BlockLabelFragmentDialog >> fragment: aBlockLabelFragment [
	fragment := aBlockLabelFragment
]

{ #category : #interaction }
BlockLabelFragmentDialog >> getUserResponse [

	| txt |
	txt := super getUserResponse.
	txt size = 0 ifTrue: [^ #cancelled].
	self acceptDefaultValue.
	self class isExpanded: isCollapsed not.
	^ fragment label: txt; yourself

]

{ #category : #initialization }
BlockLabelFragmentDialog >> initialize [

	super initialize.
	"typeinMorph width: 550."
	category := #none.
	isCollapsed := false



]

{ #category : #drawing }
BlockLabelFragmentDialog >> inputButtonForm [
	| bg block |
	block := VariableBlockMorph new commandSpec: 'Input name' localized; color: (ScriptablePhratchMorph blockColorFor: 'variables').
	bg := LabelFragmentBlockMorph new commandSpec: '$ListIndex$'; color: (ScriptablePhratchMorph blockColorFor: category asString).
	bg replaceArgMorph: bg argMorphs first by: block.
	^bg imageForm
]

{ #category : #drawing }
BlockLabelFragmentDialog >> labelButtonForm [

	| block |

	block := LabelFragmentBlockMorph new 
		color: (ScriptablePhratchMorph blockColorFor: category asString);
		commandSpec: 'Title text' localized.

	^block imageForm

]

{ #category : #initialization }
BlockLabelFragmentDialog >> refresh [

	self
		setInitialValues;
		updateInputRadioButtons;
		updateArity;
		updateSlotShape;
		withButtonsForYes: false no: false okay: true delete: (fragment label size > 0) cancel: true
]

{ #category : #initialization }
BlockLabelFragmentDialog >> setInitialValues [

	fragment isInput 
		ifTrue: [ 
			fragment label isEmpty
				ifTrue: [ self message: 'Create input name' localized]
				ifFalse: [ self message: 'Edit input name' localized].
			self initialAnswer: (String withAll: fragment label)]
		ifFalse: [ 
			fragment label isEmpty
				ifTrue: [ self message: 'Create label fragment' localized]
				ifFalse: [ self message: 'Edit label fragment' localized].
			self initialAnswer: fragment label]

]

{ #category : #private }
BlockLabelFragmentDialog >> shouldBeExpanded [
	^self class isExpanded
]

{ #category : #drawing }
BlockLabelFragmentDialog >> slotShapeFormFor: type size: aPoint [

	| specs block slot morph img |

	specs := Dictionary new.
	specs
		at: #command put: '$CSlot$';
		at: #loop put: '$CArgSlot$';
		at: #unevaluated put: '$UnEExp$';
		at: #reporter put: '$OSReporter$';
		at: #predicate put: '$OSBoolean$';
		at: #list put: '$SAList$';
		at: #text put: '$Text$';
		at: #any put: '$String$';
		at: #boolean put: '$Boolean$';
		at: #number put: '$Number$';
		at: #unevaluatedBoolean put: '$UnEBool$';
		at: #object put: '$SAObjS$'.

	block := LabelFragmentBlockMorph new
		color: (ScriptablePhratchMorph blockColorFor: category asString); 
		commandSpec: '_', (specs at: type), '_'.

	(#(predicate boolean unevaluatedBoolean reporter typeInReporter command text loop reporterSlot) includes: type) ifTrue: [
		block commandSpec: (specs at: type)].

	slot := block argMorphs first.
	#number = type ifTrue: [
		slot numExpression: ''].	

	block fixBlockLayout.
	img := ImageMorph new form: block imageForm.

	morph := Morph new color: Color transparent; extent: aPoint.
	morph addMorph: img.
	img position: morph position + (morph extent - img extent // 2).
	^ morph imageForm

]

{ #category : #interaction }
BlockLabelFragmentDialog >> toggleExpand [

	isCollapsed := isCollapsed not.

	isCollapsed
		ifTrue: [slotShapeButton labelGraphic: (PhratchFrameMorph skinAt: #arrowClosedComment) ]
		ifFalse: [slotShapeButton labelGraphic: (PhratchFrameMorph skinAt: #arrowOpenComment)].

	mainColumn submorphsDo: [: m |
		((m = messageLineMorphs) not) ifTrue: [m delete]].

	isCollapsed
		ifTrue: [ 
			typeinMorph width: 250. 
			mainColumn
			addMorphBack: (Morph new extent: (5@6); color: Color transparent);
			addMorphBack: typeinMorph;
			addMorphBack: (Morph new extent: (5@7); color: Color transparent);
			addMorphBack: fragmentRadioButtons;
			addMorphBack: (Morph new extent: (5@7); color: Color transparent);
			addMorphBack: buttonRow;
			addMorphBack: bottomSpacer]
		ifFalse: [
			typeinMorph width: 550. 
			mainColumn
			addMorphBack: (Morph new extent: (5@6); color: Color transparent);
			addMorphBack: typeinMorph;
			addMorphBack: (Morph new extent: (5@7); color: Color transparent);
			addMorphBack: fragmentRadioButtons;
			addMorphBack: (Morph new extent: (5@7); color: Color transparent);
			addMorphBack: slotShapesGroup;
			addMorphBack: (Morph new extent: (5@200); color: Color transparent);
			addMorphBack: buttonRow;
			addMorphBack: bottomSpacer.
			].

	self extent: mainColumn fullBounds extent + (60@50).

	fragment isInput ifTrue: [self class isExpanded: isCollapsed not].

]

{ #category : #interaction }
BlockLabelFragmentDialog >> toggleExpandIfInput [

	self toggleExpand.
	fragment isInput ifFalse: [
		self toggleExpand ]
]

{ #category : #interaction }
BlockLabelFragmentDialog >> toggleIsInput [

	fragment isInput: fragment isInput not.
	self updateInputRadioButtons


]

{ #category : #interaction }
BlockLabelFragmentDialog >> typeAny [
	fragment type: #any.
	self updateSlotShape

]

{ #category : #interaction }
BlockLabelFragmentDialog >> typeBoolean [
	fragment type: #boolean.
	self updateSlotShape

]

{ #category : #interaction }
BlockLabelFragmentDialog >> typeCommand [
	fragment type: #command.
	self updateSlotShape

]

{ #category : #interaction }
BlockLabelFragmentDialog >> typeList [
	fragment type: #list.
	self updateSlotShape

]

{ #category : #interaction }
BlockLabelFragmentDialog >> typeLoop [
	fragment type: #loop.
	self updateSlotShape

]

{ #category : #interaction }
BlockLabelFragmentDialog >> typeNumber [
	fragment type: #number.
	self updateSlotShape

]

{ #category : #interaction }
BlockLabelFragmentDialog >> typeObject [
	fragment type: #object.
	self updateSlotShape

]

{ #category : #interaction }
BlockLabelFragmentDialog >> typePredicate [
	fragment type: #predicate.
	self updateSlotShape

]

{ #category : #interaction }
BlockLabelFragmentDialog >> typeReporter [
	fragment type: #reporter.
	self updateSlotShape

]

{ #category : #interaction }
BlockLabelFragmentDialog >> typeReporterSlot [
	fragment type: #reporterSlot.
	self updateSlotShape

]

{ #category : #interaction }
BlockLabelFragmentDialog >> typeText [
	fragment type: #text.
	self updateSlotShape

]

{ #category : #interaction }
BlockLabelFragmentDialog >> typeTypeInReporter [
	fragment type: #typeInReporter.
	self updateSlotShape

]

{ #category : #interaction }
BlockLabelFragmentDialog >> typeUnevaluated [
	fragment type: #unevaluated.
	self updateSlotShape

]

{ #category : #interaction }
BlockLabelFragmentDialog >> typeUnevaluatedBoolean [
	fragment type: #unevaluatedBoolean.
	self updateSlotShape

]

{ #category : #interaction }
BlockLabelFragmentDialog >> updateArity [

	fragment type = #template
		ifTrue: [
			singleRadioButton off.
			multipleRadioButton off.
			externalizedRadioButton on.
			^ self].

	(fragment type endsWith: 'List')
		ifTrue: [
			multipleRadioButton on.
			singleRadioButton off.
			externalizedRadioButton off]
		ifFalse: [
			singleRadioButton on.
			multipleRadioButton off.
			externalizedRadioButton off]

]

{ #category : #interaction }
BlockLabelFragmentDialog >> updateDefaultValue [

	| dat |

	(#(any number text unevaluated) includes: fragment type)
		ifFalse: [
			(Array with: defaultLabel with: defaultField) do: [:m |
				m isHidden: true ].
			^ self ].

	dat := defaultField contents.

	{defaultLabel. defaultField} do: [:m |
		m isHidden: false ].

	#number = fragment type ifTrue: [
		defaultField isNumeric: true.
		(dat = ' ' or: [dat = ''])
			ifTrue: [ defaultField contents: ' ' ]
			ifFalse: [ defaultField contents: dat asNumberNoError printString].
		^ self ].

	defaultField
		isNumeric: false.

]

{ #category : #interaction }
BlockLabelFragmentDialog >> updateInputRadioButtons [

	fragment isInput 
		ifTrue: [
			inputRadioButton on.
			textRadioButton off.
			slotShapeButton
				isHidden: false;
				lock: false.
			self shouldBeExpanded
				ifTrue: [self toggleExpand]]
		ifFalse: [
			textRadioButton on.
			inputRadioButton off.
			slotShapeButton
				isHidden: true;
				lock.
			isCollapsed ifFalse: [
				self toggleExpand]]
]

{ #category : #interaction }
BlockLabelFragmentDialog >> updateSlotShape [

	| type types |

	singleRadioButton isOn ifTrue: [
		fragment type = #template ifTrue: [
			fragment type: #any].
		(fragment type endsWith: 'List') ifTrue: [
			fragment type: (fragment type copyFrom: 1 to: fragment type size - 'List' size) asSymbol]].

	multipleRadioButton isOn ifTrue: [
		fragment type = #template ifTrue: [
			fragment type: #any].
		(fragment type endsWith: 'List') ifFalse: [
			fragment type: (fragment type, 'List') asSymbol]].

	externalizedRadioButton isOn ifTrue: [
		fragment type: #template ].

	types := Dictionary new.
	types
		at: #any put: radioAny;
		at: #number put: radioNumber;
		at: #text put: radioText;
		at: #boolean put: radioBoolean;
		at: #list put: radioList;
		at: #command put: radioCommand;
		at: #reporter put: radioReporter;
		at: #predicate put: radioPredicate;
		at: #loop put: radioLoop;
		at: #template put: radioAny;
		at: #unevaluated put: radioUnevaluated;
		at: #unevaluatedBoolean put: radioUnevaluatedBoolean;
		at: #object put: radioObject.

	types
		at: #anyList put: radioAny;
		at: #numberList put: radioNumber;
		at: #textList put: radioText;
		at: #booleanList put: radioBoolean;
		at: #listList put: radioList;
		at: #commandList put: radioCommand;
		at: #reporterList put: radioReporter;
		at: #predicateList put: radioPredicate;
		at: #loopList put: radioLoop;
		at: #unevaluatedList put: radioUnevaluated;
		at: #unevaluatedBooleanList put: radioUnevaluatedBoolean;
		at: #objectList put: radioObject.

	type := fragment type.

	types keysDo: [:key |
		(types at: key) isHidden: true; off].

	types keysDo: [:key |
		#template = type ifFalse: [
			(types at: key) isHidden: false].
		type = key
			ifTrue: [(types at: key) on]].

	self updateDefaultValue
]
