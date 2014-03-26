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

{ #category : #accessing }
PhratchPrompterMorph class >> lastAnswer: anAnswer [

	LastAnswer := anAnswer

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
	typeinMorph left: self left + 8.

	questionMorph ifNotNil: [
		questionMorph position: self position + (8@5)].

	okButton position: typeinMorph topRight + (2@0).

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
		font: (PhratchFrameMorph getFont: #StringDialogTypeIn);
		yourself.

	okButton := ToggleButton
		onForm: (PhratchFrameMorph skinAt: #promptCheckButtonPressed)
		offForm: (PhratchFrameMorph skinAt: #promptCheckButton).
	okButton
		target: self;
		actionSelector: #accept;
		actWhen: #buttonDown;
		toggleMode: false;
		setBalloonText: 'Close and continue' localized.

	self addMorph: typeinMorph.
	self addMorph: okButton.

	self extent: 450@37.

]

{ #category : #other }
PhratchPrompterMorph >> isDone [

	^ done

]

{ #category : #'as yet unclassified' }
PhratchPrompterMorph >> isPhratchPrompterMorph [

	^ true
]

{ #category : #accessing }
PhratchPrompterMorph >> question: aString [
	(aString isMorph)
		ifTrue: [ 
			| frm |
			frm := (aString respondsTo: #displayForm)
				ifTrue: [ aString displayForm ]
				ifFalse: [ aString imageForm ].
			questionMorph := ImageMorph new form: frm ]
		ifFalse: [ 
			questionMorph := StringMorph new
				contents: aString asString;
				font: (PhratchFrameMorph getFont: #DialogBoxButton);
		yourself ].
	self addMorph: questionMorph.
	self height: questionMorph height + typeinMorph height + 16
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
