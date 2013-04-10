"
Supports Scratch text input from the user.

"
Class {
	#name : #PhratchPrompterMorph,
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
PhratchPrompterMorph class >> clearLastAnswer [

	LastAnswer := ''.

]

{ #category : #initialization }
PhratchPrompterMorph class >> initialize [

	LastAnswer := ''.

]

{ #category : #accessing }
PhratchPrompterMorph class >> lastAnswer [

	^ LastAnswer

]

{ #category : #other }
PhratchPrompterMorph >> accept [
	"Accept button was pressed."

	LastAnswer := typeinMorph contents.
	done := true.
	self delete.
	sprite ifNotNil: [sprite sayNothing].
	World doOneCycle.  "erase myself from the screen"

]

{ #category : #other }
PhratchPrompterMorph >> dispatchKeyStroke: evt [

	typeinMorph keyStroke: evt.

]

{ #category : #other }
PhratchPrompterMorph >> enterKeyPressed [
	"Respond to the enter key being pressed in one of my input fields."

	self accept.

]

{ #category : #geometry }
PhratchPrompterMorph >> extent: aPoint [

	super extent: aPoint.
	self fixLayout.

]

{ #category : #geometry }
PhratchPrompterMorph >> fixLayout [

	typeinMorph ifNil: [^ self].
	typeinMorph
		width: self width - 36;
		bottom: self bottom - 6.
	PhratchTranslator isRTL
		ifTrue:[typeinMorph right: self right - 8]
		ifFalse:[typeinMorph left: self left + 8].

	questionMorph ifNotNil: [
		PhratchTranslator isRTL
			ifTrue: [questionMorph position: self topRight - ((questionMorph width + 8)@0) + (0@5)]
			ifFalse: [questionMorph position: self position + (8@5)]].

	PhratchTranslator isRTL
		ifTrue:[okButton position: typeinMorph topLeft - ((okButton width + 2)@0)]
		ifFalse:[okButton position: typeinMorph topRight + (2@0)].

]

{ #category : #other }
PhratchPrompterMorph >> grabKeyboardFocus [

	World activeHand newKeyboardFocus: typeinMorph.

]

{ #category : #initialize }
PhratchPrompterMorph >> initialize [
	"Set the forms for all my UI elements, create a row to hold my buttons, and a column to hold my shortcut buttons."

	super initialize.
	self initFromForm: (PhratchFrameMorph skinAt: #promptBubbleFrame).
	done := false.

	typeinMorph := StringFieldMorph
		new client: self;
		borderWidth: 2;
		color: (Color gray: 55);
		font: (PhratchFrameMorph getFont: #StringDialogTypeIn).

	okButton := ToggleButton
		onForm: (PhratchFrameMorph skinAt: #promptCheckButtonPressed)
		offForm: (PhratchFrameMorph skinAt: #promptCheckButton).
	okButton
		target: self;
		actionSelector: #accept;
		actWhen: #buttonDown;
		toggleMode: false;
		setBalloonText: 'Close and continue' localized.

	PhratchTranslator isRTL
		ifTrue: [self addMorph: okButton.
			self addMorph: typeinMorph]
		ifFalse: [self addMorph: typeinMorph.
			self addMorph: okButton].

	self extent: 450@37.

]

{ #category : #other }
PhratchPrompterMorph >> isDone [

	^ done

]

{ #category : #accessing }
PhratchPrompterMorph >> question: aString [

	(aString isKindOf: Morph) 
		ifTrue: [
			| frm |
			(aString respondsTo: #displayForm)
				ifTrue: [frm := aString displayForm]
				ifFalse: [frm := aString imageForm].
			questionMorph := ImageMorph new form: frm]
		ifFalse: [
			questionMorph := StringMorph new
				contents: aString asString;
				font: (PhratchFrameMorph getFont: #DialogBoxButton)].

	self addMorph: questionMorph.
	self height: questionMorph height + typeinMorph height + 16.

]

{ #category : #accessing }
PhratchPrompterMorph >> sprite: aSprite [

	sprite := aSprite.

]

{ #category : #other }
PhratchPrompterMorph >> stopAsk [
	"Stop button was pressed."

	done := true.
	self delete.
	sprite ifNotNil: [sprite sayNothing].
	World doOneCycle.  "erase myself from the screen"

]
