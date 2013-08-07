Class {
	#name : #PhratchCloseDialog,
	#superclass : #DialogBoxMorph,
	#category : #'Phratch-UI-Dialogs'
}

{ #category : #other }
PhratchCloseDialog >> getUserResponse [
	| w |
	self openInWorld.
	self centerOnScreen.
	w := self world.
	w activeHand newKeyboardFocus: (buttonRow submorphs at: 7).
	done := false.
	[done] whileFalse: [w doOneCycle].  "wait for user to press a button"

	^ response

]

{ #category : #initialization }
PhratchCloseDialog >> initialize [
	| spacer |
	super initialize.
	self title: 'Quit' translated.
	self message: 'Save changes before quitting?'.	"Note: The button row morph was created by initialize; I just replace its contents with a new collection of buttons."
	spacer := Morph new
		extent: 10 @ 5;
		color: Color transparent.
	buttonRow removeAllMorphs.
	buttonRow addMorphBack: (AlignmentMorph newSpacer: Color transparent).
	buttonRow addMorphBack: spacer.
	buttonRow addMorphBack: (self buttonLabel: 'Save' localized action: #yes).
	buttonRow addMorphBack: spacer fullCopy.
	buttonRow addMorphBack: (self buttonLabel: 'Don''t Save' localized action: #no).
	buttonRow addMorphBack: spacer fullCopy.
	buttonRow addMorphBack: (self buttonLabel: 'Cancel' localized action: #cancelled).
	buttonRow addMorphBack: spacer fullCopy.
	buttonRow submorphs
		do: [ :b | 
			(b isKindOf: ResizableToggleButton)
				ifTrue: [ tabFields add: b ] ]
]
