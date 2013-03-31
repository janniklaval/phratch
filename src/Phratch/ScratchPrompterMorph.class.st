"
Supports Scratch text input from the user.

"
Class {
	#name : #ScratchPrompterMorph,
	#superclass : #ImageFrameMorph,
	#instVars : [
		'typeinMorph',
		'questionMorph',
		'okButton',
		'done',
		'sprite'
	],
	#classVars : [
		'LastAnswer'
	],
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #accessing }
ScratchPrompterMorph class >> clearLastAnswer [

	LastAnswer := ''.

]

{ #category : #initialization }
ScratchPrompterMorph class >> initialize [

	LastAnswer := ''.

]

{ #category : #accessing }
ScratchPrompterMorph class >> lastAnswer [

	^ LastAnswer

]

{ #category : #other }
ScratchPrompterMorph >> accept [
	"Accept button was pressed."

	LastAnswer := typeinMorph contents.
	done := true.
	self delete.
	sprite ifNotNil: [sprite sayNothing].
	World doOneCycle.  "erase myself from the screen"

]

{ #category : #other }
ScratchPrompterMorph >> dispatchKeyStroke: evt [

	typeinMorph keyStroke: evt.

]

{ #category : #other }
ScratchPrompterMorph >> enterKeyPressed [
	"Respond to the enter key being pressed in one of my input fields."

	self accept.

]

{ #category : #geometry }
ScratchPrompterMorph >> extent: aPoint [

	super extent: aPoint.
	self fixLayout.

]

{ #category : #geometry }
ScratchPrompterMorph >> fixLayout [

	typeinMorph ifNil: [^ self].
	typeinMorph
		width: self width - 36;
		bottom: self bottom - 6.
	ScratchTranslator isRTL
		ifTrue:[typeinMorph right: self right - 8]
		ifFalse:[typeinMorph left: self left + 8].

	questionMorph ifNotNil: [
		ScratchTranslator isRTL
			ifTrue: [questionMorph position: self topRight - ((questionMorph width + 8)@0) + (0@5)]
			ifFalse: [questionMorph position: self position + (8@5)]].

	ScratchTranslator isRTL
		ifTrue:[okButton position: typeinMorph topLeft - ((okButton width + 2)@0)]
		ifFalse:[okButton position: typeinMorph topRight + (2@0)].

]

{ #category : #other }
ScratchPrompterMorph >> grabKeyboardFocus [

	World activeHand newKeyboardFocus: typeinMorph.

]

{ #category : #initialize }
ScratchPrompterMorph >> initialize [
	"Set the forms for all my UI elements, create a row to hold my buttons, and a column to hold my shortcut buttons."

	super initialize.
	self initFromForm: (ScratchFrameMorph skinAt: #promptBubbleFrame).
	done := false.

	typeinMorph := StringFieldMorph
		new client: self;
		borderWidth: 2;
		color: (Color gray: 55);
		font: (ScratchFrameMorph getFont: #StringDialogTypeIn).

	okButton := ToggleButton
		onForm: (ScratchFrameMorph skinAt: #promptCheckButtonPressed)
		offForm: (ScratchFrameMorph skinAt: #promptCheckButton).
	okButton
		target: self;
		actionSelector: #accept;
		actWhen: #buttonDown;
		toggleMode: false;
		setBalloonText: 'Close and continue' localized.

	ScratchTranslator isRTL
		ifTrue: [self addMorph: okButton.
			self addMorph: typeinMorph]
		ifFalse: [self addMorph: typeinMorph.
			self addMorph: okButton].

	self extent: 450@37.

]

{ #category : #other }
ScratchPrompterMorph >> isDone [

	^ done

]

{ #category : #accessing }
ScratchPrompterMorph >> question: aString [

	(aString isKindOf: Morph) 
		ifTrue: [
			| frm |
			(aString respondsTo: #displayForm)
				ifTrue: [frm := aString displayForm]
				ifFalse: [frm := aString imageForm].
			questionMorph := ImageMorph new form: frm]
		ifFalse: [
			questionMorph := ScratchStringMorph new
				contents: aString asString;
				font: (ScratchFrameMorph getFont: #DialogBoxButton)].

	self addMorph: questionMorph.
	self height: questionMorph height + typeinMorph height + 16.

]

{ #category : #accessing }
ScratchPrompterMorph >> sprite: aSprite [

	sprite := aSprite.

]

{ #category : #other }
ScratchPrompterMorph >> stopAsk [
	"Stop button was pressed."

	done := true.
	self delete.
	sprite ifNotNil: [sprite sayNothing].
	World doOneCycle.  "erase myself from the screen"

]
