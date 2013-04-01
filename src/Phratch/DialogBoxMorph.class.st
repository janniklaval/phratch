"
I am a DialogBox for presenting messages to the user and asking them simple yes/no/okay/cancel questions. I have instance variables for all the forms that comprise my frame which I draw myself.

Examples:
	DialogBoxMorph ask: 'Time for lunch?'
	DialogBoxMorph askWithCancel: 'Save project before quitting?'
	DialogBoxMorph inform: 'Operation complete.'
	DialogBoxMorph informWithCancel: 'This operation may take a while...'
	DialogBoxMorph warn: 'File not found'

For string input, see StringDialogBoxMorph.

"
Class {
	#name : #DialogBoxMorph,
	#superclass : #ImageFrameMorph,
	#instVars : [
		'titleMorph',
		'buttonRow',
		'messageLineMorphs',
		'percentMorph',
		'done',
		'response',
		'topLeftForms',
		'topRightForms',
		'bottomLeftForms',
		'bottomRightForms',
		'topEdgeForms',
		'leftEdgeForms',
		'rightEdgeForms',
		'bottomEdgeForms',
		'mainColumn',
		'shortcutColumn',
		'fileInfoColumn',
		'titleBin',
		'bottomSpacer',
		'tabFields'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #'instance creation' }
DialogBoxMorph class >> ask: questionString [
	"Put up an instance of me to ask a yes/no question. Answer true or false depending on which button the user presses."
	"DialogBoxMorph ask: 'Time for lunch?'"

	| dialogBox |
	dialogBox := self new
		title: '?';
		withButtonsForYes: true no: true okay: false cancel: false;
		message: questionString.
	^ dialogBox getUserResponse

]

{ #category : #'instance creation' }
DialogBoxMorph class >> askWithCancel: questionString [
	"Put up an instance of me to ask a yes/no question but include a cancel button as well. Answer either a boolean or the symbol #cancelled."
	"DialogBoxMorph askWithCancel: 'Save project before quitting?'"

	| dialogBox |
	dialogBox := self new
		title: '?';
		withButtonsForYes: true no: true okay: false cancel: true;
		message: questionString.
	^ dialogBox getUserResponse

]

{ #category : #'instance creation' }
DialogBoxMorph class >> inform: informationString [
	"Put up an instance of me to give the user an informational message and wait until they click the 'ok' button before proceeding."
	"DialogBoxMorph inform: 'Operation complete.'"

	| dialogBox |
	dialogBox := self new
		withButtonsForYes: false no: false okay: true cancel: false.
	dialogBox
		message: informationString
		font: (PhratchFrameMorph getFont: #DialogBoxMessage).

	^ dialogBox getUserResponse

]

{ #category : #'instance creation' }
DialogBoxMorph class >> inform: informationString title: titleString [
	"Put up an instance of me to give the user an informational message and wait until they click the 'ok' button before proceeding."
	"DialogBoxMorph inform: 'Operation complete.' title: 'Status'"

	| dialogBox |
	dialogBox := self new
		withButtonsForYes: false no: false okay: true cancel: false;
		title: titleString.
	dialogBox
		message: informationString
		font: (StrikeFont fontName: 'VerdanaBold' size: 13).

	^ dialogBox getUserResponse

]

{ #category : #'instance creation' }
DialogBoxMorph class >> inform: informationString withDetails: detailsString [
	"Put up an instance of me to give the user an informational message and wait until they click the 'ok' button before proceeding."
	"DialogBoxMorph inform: 'Operation complete.'"

	| dialogBox |
	dialogBox := self new
		withButtonsForYes: false no: false okay: true cancel: false.
	dialogBox
		message: (informationString localized, PhratchTranslator colonSuffix)
		details: detailsString
		font: (PhratchFrameMorph getFont: #DialogBoxMessage).

	^ dialogBox getUserResponse

]

{ #category : #'instance creation' }
DialogBoxMorph class >> informWithCancel: informationString [
	"Put up an instance of me to give the user an informational message and wait until they click the 'ok' button before proceeding."
	"DialogBoxMorph informWithCancel: 'This operation may take a while...'"

	| dialogBox |
	dialogBox := self new
		withButtonsForYes: false no: false okay: false cancel: true;
		message: informationString.
	^ dialogBox getUserResponse

]

{ #category : #'instance creation' }
DialogBoxMorph class >> warn: informationString [
	"Put up an instance of me to give the user a warning message and wait until they click the 'ok' button before proceeding."
	"DialogBoxMorph warn: 'File not found'"

	| dialogBox |
	dialogBox := self new
		title: '!';
		withButtonsForYes: false no: false okay: true cancel: false;
		message: informationString.
	^ dialogBox getUserResponse

]

{ #category : #accessing }
DialogBoxMorph >> addMessageLine: aMorph [
	"Add the given morph (some kind of StringMorph, probably) centered below the other message lines."

	| ypos |
	messageLineMorphs ifNil: [messageLineMorphs := OrderedCollection new].
	ypos := self top + 50.
	messageLineMorphs submorphsDo: [:m | ypos := ypos max: (m bottom + 5)].
	aMorph position: (self left + ((self width - aMorph width) // 2))@ypos.
	messageLineMorphs addMorphBack: aMorph.
	self height: (aMorph bottom - self top) + 75.

]

{ #category : #initialization }
DialogBoxMorph >> addNoShadowFrameFromForm: aForm [

	| cornerExtent center |
	cornerExtent := (aForm extent - 1) // 2.
	center := aForm extent // 2.

	topLeftForms := Array new: 2.
	bottomLeftForms := Array new: 2.
	topRightForms := Array new: 2.
	bottomRightForms := Array new: 2.
	topEdgeForms := Array new: 2.
	leftEdgeForms := Array new: 2.
	rightEdgeForms := Array new: 2.
	bottomEdgeForms := Array new: 2.

	topLeftForms
		at: 1 put: topLeftForm deepCopy;
		at: 2 put: (aForm copy: (0@0 extent: cornerExtent)).
	topRightForms
		at: 1 put: topRightForm copy;
		at: 2 put: (aForm copy: ((aForm width - cornerExtent x) @ 0 extent: cornerExtent)).
	bottomLeftForms
		at: 1 put: bottomLeftForm copy;
		at: 2 put: (aForm copy: (0 @ (aForm height - cornerExtent y) extent: cornerExtent)).
	bottomRightForms
		at: 1 put: bottomRightForm copy;
		at: 2 put: (aForm copy: ((aForm extent - cornerExtent) extent: cornerExtent)).

	topEdgeForms
		at: 1 put: topEdgeForm copy;
		at: 2 put: (aForm copy: ((center x@0) extent: (1 @ cornerExtent y))).
	leftEdgeForms
		at: 1 put: leftEdgeForm copy;
		at: 2 put: (aForm copy: ((0 @ center y) extent: (cornerExtent x @ 1))).
	rightEdgeForms
		at: 1 put: rightEdgeForm copy;
		at: 2 put: (aForm copy: (((aForm width - cornerExtent x) @ center y) extent: (cornerExtent x @ 1))).
	bottomEdgeForms
		at: 1 put: bottomEdgeForm copy;
		at: 2 put: (aForm copy: ((center x@(aForm height - cornerExtent y)) extent: (1 @ cornerExtent y))).


]

{ #category : #drawing }
DialogBoxMorph >> areasRemainingToFill: aRectangle [
	"Drawing optimization. This method tells Morphic that it isn't necessary to draw any morphs covered by me. (My bounds must be inset due to my rounded corners)."
	
	^ aRectangle areasOutside: (self bounds insetBy: 16)

]

{ #category : #private }
DialogBoxMorph >> buttonLabel: labelString action: actionSelector [
	"Answer a new button with the given label and selector. The button target will be me and it will use my button forms."
	"(DialogBoxMorph new buttonLabel: 'Yes' action: #beep) openInWorld"

	| onForm offForm button overForm |
	onForm := PhratchFrameMorph skinAt: #dialogButtonFrameOver.
	offForm := PhratchFrameMorph skinAt: #dialogButtonFrame.
	overForm := PhratchFrameMorph skinAt: #dialogButtonFrame.

	button := ResizableToggleButton2 new
		offForm: offForm
		onForm: onForm
		overForm: overForm.

	^ button
		padding: 39@22;
		label: labelString font: (PhratchFrameMorph getFont: #DialogBoxButton);
		target: self;
		actionSelector: actionSelector;
		setLabelColor: (Color gray: 0.15)

]

{ #category : #accessing }
DialogBoxMorph >> buttons [

	^ buttonRow submorphs select: [:m |
		m isKindOf: ResizableToggleButton2].

]

{ #category : #interaction }
DialogBoxMorph >> cancelled [
	"Cancel button was pressed."

	response := #cancelled.
	done := true.
	self delete.
	World doOneCycle.  "erase myself from the screen"

]

{ #category : #geometry }
DialogBoxMorph >> centerOnScreen [
	"Center myself on the screen, if possible. Otherwise, adjust position so buttons are visible."

	| w |
	w := self world.
	self extent: self extent.  "force layout"
	self position: w center - (self extent // 2) + (0@5).  "center on screen but disregard the shadow on the bottom"
	self bottom > w bottom ifTrue: [
		self bottom: w bottom + 37.  "make sure cancel button is on screen"
		self top > -2 ifTrue: [self top: -2]]. "make top flush with the top of the screen"

	(self top < -2 and: [self top > -34]) ifTrue: [
		"if title bar partway off screen, move it all the way off"
		self top: -34].

]

{ #category : #interaction }
DialogBoxMorph >> deleteItem [
	"Delete button was pressed."

	response := #deleted.
	done := true.
	self delete.
	World doOneCycle.  "erase myself from the screen"

]

{ #category : #drawing }
DialogBoxMorph >> drawOn: aCanvas [

	| i |
	i := (owner isKindOf: HandMorph) ifTrue: [2] ifFalse: [1].

	topLeftForm := topLeftForms at: i.
	bottomLeftForm := bottomLeftForms at: i.
	topRightForm := topRightForms at: i.
	bottomRightForm := bottomRightForms at: i.
	topEdgeForm := topEdgeForms at: i.
	leftEdgeForm := leftEdgeForms at: i.
	rightEdgeForm := rightEdgeForms at: i.
	bottomEdgeForm := bottomEdgeForms at: i.
	edgeCache := Array new: edgeCache size.

	super drawOn: aCanvas.

]

{ #category : #'event handling' }
DialogBoxMorph >> enterKeyPressed: evt [
	"Respond to the enter key being pressed in one of my input fields or on one of my buttons."

	"if a button has focus, do that button"
	(evt hand keyboardFocus isKindOf: ResizableToggleButton2) ifTrue: [
		evt hand keyboardFocus doButtonAction.
		^ self].

	"if any other submorph has focus, return OK"
	self yes.

]

{ #category : #'event handling' }
DialogBoxMorph >> escapeKeyPressed: evt [
	"Respond to the escape key being pressed in one of my input fields or on one of my buttons by cancelling this dialog."

	self cancelled.

]

{ #category : #geometry }
DialogBoxMorph >> extent: aPoint [
	
	| w |
	(self isKindOf: PaintFrame) ifTrue: [^ super extent: aPoint].
	self fixLayoutForExtent: aPoint.
	super extent: self fullBounds extent.
	w := self world.
	w ifNotNil: [self position: w center - (self extent // 2)].  "center on screen"

]

{ #category : #geometry }
DialogBoxMorph >> fixLayoutForExtent: aPoint [

	| xPos yPos shortcutWidth fileColumnWidth |
	shortcutColumn ifNil: [^ self].
	xPos := self left + 20.
	yPos := self top + 40.

	"position and size the shortcut column"
	shortcutColumn position: xPos@yPos.
	shortcutWidth := 0.
	shortcutColumn submorphsDo: [: m |
		shortcutWidth := m width max: shortcutWidth].
	shortcutColumn submorphsDo: [: m |
		m width: shortcutWidth].

	"position main column"
	mainColumn position: (shortcutColumn right + 5)@yPos.

	"position and size the fileInfo column"
	fileInfoColumn position: (mainColumn right + 5)@yPos.
	fileColumnWidth := 0.
	fileInfoColumn submorphsDo: [: m |
		fileColumnWidth := m width max: fileColumnWidth].
	fileInfoColumn submorphsDo: [: m |
		(m isKindOf: PhratchStringMorph)
			ifFalse: [m width: fileColumnWidth]].

	"position and size title"
	titleBin left: self left.
	titleBin width: shortcutColumn width + mainColumn width + fileInfoColumn width + 55.

	"add a bottom spacer to the tallest column"
	bottomSpacer ifNil: [
		bottomSpacer := (Morph new extent: (5@22); color: Color transparent).
		(shortcutColumn height > mainColumn height)
			ifTrue: [shortcutColumn addMorphBack: bottomSpacer]
			ifFalse: [(mainColumn height > fileInfoColumn height)
				ifTrue: [mainColumn addMorphBack: bottomSpacer]
				ifFalse: [fileInfoColumn addMorphBack: bottomSpacer]]].


]

{ #category : #interaction }
DialogBoxMorph >> getUserResponse [
	"Wait for the user to respond, then report their response. The symbol #cancel is returned if the user wishes to cancel the operation. True/false is returned if they respond yes/no, and a string is returned if this this a string input dialog and they don't cancel."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop."

	| w |
	self openInWorld.
	self centerOnScreen.
	w := self world.
	self buttons size > 0 ifTrue: [
		w activeHand newKeyboardFocus: self buttons last].
	tabFields size > 0 ifTrue: [
		w activeHand newKeyboardFocus: (tabFields at: 1)].
	done := false.
	[done] whileFalse: [w doOneCycle].  "wait for user to press a button"

	^ response

]

{ #category : #initialization }
DialogBoxMorph >> initialize [
	"Set the forms for all my UI elements, create a row to hold my buttons, and a column to hold my shortcut buttons."

	super initialize.
	self initFromForm: (PhratchFrameMorph skinAt: #dialogFrame).
	self addNoShadowFrameFromForm: (PhratchFrameMorph skinAt: #dialogFrameNoShadow).
	done := false.
	tabFields := OrderedCollection new.

	"create columns"
	mainColumn := AlignmentMorph newColumn
		color: Color transparent;
		cellPositioning: #topCenter; 
		centering: #center;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.
	shortcutColumn := AlignmentMorph newColumn
		color: Color transparent;
		cellPositioning: #topCenter; 
		centering: #center;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.
	fileInfoColumn := AlignmentMorph newColumn
		color: Color transparent;
		cellPositioning: #topLeft;  
		centering: #topLeft;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap.
	titleBin := AlignmentMorph newRow
		color: Color transparent;
		cellPositioning: #leftCenter; 
		centering: #center;
		hResizing: #spaceFill;
		vResizing: #rigid;
		height: 32.
	buttonRow := AlignmentMorph newRow
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		height: 32.

	PhratchTranslator isRTL
		ifTrue: [fileInfoColumn centering: #bottomRight]
		ifFalse: [fileInfoColumn centering: #topLeft].

	self
		addMorph: mainColumn;
		addMorph: shortcutColumn;
		addMorph: fileInfoColumn;
		addMorph: titleBin.

	mainColumn addMorph: buttonRow.

	self extent: 50@50.

]

{ #category : #accessing }
DialogBoxMorph >> isDone [

	^ done

]

{ #category : #'dropping/grabbing' }
DialogBoxMorph >> justDroppedInto: aMorph event: evt [
	"Never embed myself in a morph (e.g. the Stage)."

	self world addMorphFront: self.

]

{ #category : #interaction }
DialogBoxMorph >> message: aMessage [
	"Set my message/question text."

	self
		message: aMessage localized
		font: (PhratchFrameMorph getFont: #DialogBoxMessage).

]

{ #category : #interaction }
DialogBoxMorph >> message: aMessage details: aDetailsString font: aStrikeFont [
	"Set and position my message/question text."

	| lines m |
	messageLineMorphs ifNotNil: [
		messageLineMorphs submorphsDo: [:lineM | lineM delete]].

	messageLineMorphs := AlignmentMorph newColumn
		cellPositioning: #topCenter;
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		centering: #center.
	lines := aMessage lines.
	1 to: lines size do: [:n |
		m := PhratchStringMorph
			contents: (lines at: n)
			font: aStrikeFont.
		messageLineMorphs addMorphBack: m].
	lines := aDetailsString lines.
	1 to: lines size do: [:n |
		m := PhratchStringMorph
			contents: (lines at: n)
			font: aStrikeFont.
		messageLineMorphs addMorphBack: m].

	mainColumn addMorph: messageLineMorphs.

	self changed.

]

{ #category : #interaction }
DialogBoxMorph >> message: aMessage font: aStrikeFont [
	"Set and position my message/question text."

	| lines m |
	messageLineMorphs ifNotNil: [
		messageLineMorphs submorphsDo: [:lineM | lineM delete]].

	messageLineMorphs := AlignmentMorph newColumn
		cellPositioning: #topCenter;
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		centering: #center.
	lines := aMessage lines.
	1 to: lines size do: [:n |
		m := PhratchStringMorph
			contents: (lines at: n)
			font: aStrikeFont.
		messageLineMorphs addMorphBack: m].

	mainColumn addMorph: messageLineMorphs.

	self changed.

]

{ #category : #interaction }
DialogBoxMorph >> no [
	"No button was pressed."

	response := false.
	done := true.
	self delete.
	World doOneCycle.  "erase myself from the screen"

]

{ #category : #interaction }
DialogBoxMorph >> percentDone: aNumber [
	"Show a percent complete indicator. The argument should be in the range 0-100."

	| percent fullWidth indicator |
	percentMorph ifNil: [
		percentMorph := RectangleMorph new
			extent: 104@16;
			borderWidth: 1;
			color: Color transparent;
			borderColor: (Color gray: 0.5).
		indicator := Morph new
			extent: 0@12;
			color: (Color r: 0.35 g: 0.50 b: 0.67);
			position: percentMorph position + 2.
		percentMorph addMorph: indicator.
		percentMorph position: (self center x - (percentMorph width // 2) - 5)@(buttonRow top - 27).
		mainColumn addMorph: percentMorph].

	fullWidth := percentMorph width - 4.
	indicator := percentMorph firstSubmorph.
	percent := (aNumber * fullWidth / 100.0) rounded within: 0 and: fullWidth.
	indicator width: percent.

	World displayWorld.

]

{ #category : #accessing }
DialogBoxMorph >> shortcutButtonLabel: labelString action: actionSelector icon: aSymbol [
	"Answer a new shortcut button with the given label and selector. A shortcut button has a folder icon on it. The button target will be me and it will use my button forms. Icon can be: #folderIcon, #folderCatIcon, #folderHouseIcon #folderPicIcon, #folderSoundIcon"
	"(DialogBoxMorph new shortcutButtonLabel: 'Yes' action: #beep isCat: true) openInWorld"

	| onForm offForm overForm button |
	onForm := PhratchFrameMorph skinAt: #dialogButtonFrameOver.
	offForm := PhratchFrameMorph skinAt: #dialogButtonFrame.
	overForm := PhratchFrameMorph skinAt: #dialogButtonFrameOver.

	button := ResizableToggleButton2 new
		offForm: offForm
		onForm: onForm.

	button addMorph: (ImageMorph new form: (PhratchFrameMorph skinAt: aSymbol)).

	^ (button
		label: labelString localized font: (PhratchFrameMorph getFont: #FolderShortcut);
		target: self;
		actionSelector: actionSelector;
		setLabelColor: (Color gray: 0.15)).

]

{ #category : #'event handling' }
DialogBoxMorph >> tabToNextField: evt [
	"Move the keyboard focus to the next submorph that responds to keyboard events."

	| current |

	tabFields size = 0 ifTrue: [^ self].

	current := (1 to: tabFields size) detect: [:i |
		(tabFields at: i) == evt hand keyboardFocus] ifNone: [tabFields size].
	evt hand newKeyboardFocus: (tabFields at: (current \\ tabFields size) + 1).

]

{ #category : #'event handling' }
DialogBoxMorph >> tabToPreviousField: evt [
	"Move the keyboard focus to the previous submorph that responds to keyboard events."

	| current |

	tabFields size = 0 ifTrue: [^ self].

	current := (1 to: tabFields size) detect: [:i |
		(tabFields at: i) == evt hand keyboardFocus] ifNone: [tabFields size].
	evt hand newKeyboardFocus: (tabFields at: ((current \\ tabFields size) + 1 max: 1)).

]

{ #category : #accessing }
DialogBoxMorph >> title: aString [
	"Note: Title is actually two StringMorphs with the same contents and font: a gray shadow of the text with a white submorph of the same text, offset by a small amount."

	titleBin ifNotNil: [titleBin delete].
	titleBin removeAllMorphs.
	titleMorph ifNotNil: [titleMorph delete].

	titleMorph := ShadowedStringMorph new
		contents: aString localized
		color: Color white
		font: (PhratchFrameMorph getFont: #DialogBoxTitle)
		kern: 1.

	titleBin
		addMorph: (AlignmentMorph newSpacer: Color transparent);
		addMorph: (Morph new extent: (5@5); color: Color transparent);
		addMorph: titleMorph;
		addMorph: (AlignmentMorph newSpacer: Color transparent).


	self addMorphBack: titleBin.
	self changed.

]

{ #category : #interaction }
DialogBoxMorph >> wantsToBeDroppedInto: aMorph [
"I don't wanna be dropped into a Stage"
	^ (aMorph isKindOf: PhratchStageMorph) not
]

{ #category : #initialization }
DialogBoxMorph >> withButtonsForYes: yesFlag no: noFlag okay: okayFlag cancel: cancelFlag [
	"Replace my current buttons with the ones specified."
	"Note: The button row morph was created by initialize; I just replace its contents with a new collection of buttons."

	| spacer |
	spacer := Morph new extent: 10@5; color: Color transparent.
	buttonRow removeAllMorphs.

	buttonRow addMorphBack: (AlignmentMorph newSpacer: Color transparent).
	buttonRow addMorphBack: spacer.
	yesFlag ifTrue: [
		buttonRow addMorphBack: (self buttonLabel: 'Yes' localized action: #yes).
		buttonRow addMorphBack: spacer fullCopy].

	noFlag ifTrue: [
		buttonRow addMorphBack: (self buttonLabel: 'No' localized action: #no).
		buttonRow addMorphBack: spacer fullCopy].

	okayFlag ifTrue: [
		buttonRow addMorphBack: (self buttonLabel: 'OK' localized action: #yes).
		buttonRow addMorphBack: spacer fullCopy].

	cancelFlag ifTrue: [
		buttonRow addMorphBack: (self buttonLabel: 'Cancel' localized action: #cancelled).
		buttonRow addMorphBack: spacer fullCopy].

	buttonRow submorphs do: [:b |
		(b isKindOf: ResizableToggleButton2) ifTrue: [tabFields add: b]].

]

{ #category : #initialization }
DialogBoxMorph >> withButtonsForYes: yesFlag no: noFlag okay: okayFlag delete: deleteFlag cancel: cancelFlag [
	"Replace my current buttons with the ones specified."
	"Note: The button row morph was created by initialize; I just replace its contents with a new collection of buttons."

	| spacer |
	spacer := Morph new extent: 10@5; color: Color transparent.
	buttonRow removeAllMorphs.

	buttonRow addMorphBack: (AlignmentMorph newSpacer: Color transparent).
	buttonRow addMorphBack: spacer.
	yesFlag ifTrue: [
		buttonRow addMorphBack: (self buttonLabel: 'Yes' localized action: #yes).
		buttonRow addMorphBack: spacer fullCopy].

	noFlag ifTrue: [
		buttonRow addMorphBack: (self buttonLabel: 'No' localized action: #no).
		buttonRow addMorphBack: spacer fullCopy].

	okayFlag ifTrue: [
		buttonRow addMorphBack: (self buttonLabel: 'OK' localized action: #yes).
		buttonRow addMorphBack: spacer fullCopy].

	deleteFlag ifTrue: [
		buttonRow addMorphBack: (self buttonLabel: 'Delete' localized action: #deleteItem).
		buttonRow addMorphBack: spacer fullCopy].

	cancelFlag ifTrue: [
		buttonRow addMorphBack: (self buttonLabel: 'Cancel' localized action: #cancelled).
		buttonRow addMorphBack: spacer fullCopy].

	buttonRow submorphs do: [:b |
		(b isKindOf: ResizableToggleButton2) ifTrue: [tabFields add: b]].

]

{ #category : #interaction }
DialogBoxMorph >> yes [
	"Yes button was pressed."

	response := true.
	done := true.
	self delete.
	World doOneCycle.  "erase myself from the screen"

]
