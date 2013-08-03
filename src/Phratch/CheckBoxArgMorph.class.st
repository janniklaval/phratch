Class {
	#name : #CheckBoxArgMorph,
	#superclass : #BooleanArgMorph,
	#instVars : [
		'isChecked'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #'event handling' }
CheckBoxArgMorph >> click: evt [

	isChecked := isChecked not.
	self changed.
]

{ #category : #other }
CheckBoxArgMorph >> defaultValue: aBoolean [

	isChecked := aBoolean.
]

{ #category : #drawing }
CheckBoxArgMorph >> drawOn: aCanvas [

	| left top checkBoxForm |
	super drawOn: aCanvas.

	checkBoxForm := isChecked ifTrue: [PhratchFrameMorph skinAt: #watcherButtonPressed] ifFalse: [PhratchFrameMorph skinAt: #watcherButton].
	left := (self extent x - checkBoxForm width) // 2.
	top := (self extent y - checkBoxForm height) // 2.

	aCanvas paintImage: checkBoxForm at: (self position + (left@top)).
]

{ #category : #evaluation }
CheckBoxArgMorph >> evaluate [

	^ isChecked
]

{ #category : #'event handling' }
CheckBoxArgMorph >> handlesMouseDown: evt [

	^ evt hand toolType isNil.
]

{ #category : #initialization }
CheckBoxArgMorph >> initialize [

	super initialize.
	isChecked := false.
]

{ #category : #'event handling' }
CheckBoxArgMorph >> mouseDown: evt [

	evt hand waitForClicksOrDrag: self event: evt.

]

{ #category : #'event handling' }
CheckBoxArgMorph >> preemptsMouseDown: evt [

	^ true

]
