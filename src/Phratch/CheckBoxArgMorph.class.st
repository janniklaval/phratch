Class {
	#name : #CheckBoxArgMorph,
	#superclass : #BooleanArgMorph,
	#instVars : [
		'isChecked'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #'as yet unclassified' }
CheckBoxArgMorph >> click: evt [

	isChecked := isChecked not.
	self changed.
]

{ #category : #'as yet unclassified' }
CheckBoxArgMorph >> defaultValue: aBoolean [

	isChecked := aBoolean.
]

{ #category : #'as yet unclassified' }
CheckBoxArgMorph >> drawOn: aCanvas [

	| left top checkBoxForm |
	super drawOn: aCanvas.

	checkBoxForm := isChecked ifTrue: [PhratchFrameMorph skinAt: #watcherButtonPressed] ifFalse: [PhratchFrameMorph skinAt: #watcherButton].
	left := (self extent x - checkBoxForm width) // 2.
	top := (self extent y - checkBoxForm height) // 2.

	aCanvas paintImage: checkBoxForm at: (self position + (left@top)).
]

{ #category : #'as yet unclassified' }
CheckBoxArgMorph >> evaluate [

	^ isChecked
]

{ #category : #'as yet unclassified' }
CheckBoxArgMorph >> handlesMouseDown: evt [

	^ evt hand toolType isNil.
]

{ #category : #'as yet unclassified' }
CheckBoxArgMorph >> initialize [

	super initialize.
	isChecked := false.
]

{ #category : #'as yet unclassified' }
CheckBoxArgMorph >> mouseDown: evt [

	evt hand waitForClicksOrDrag: self event: evt.

]

{ #category : #'as yet unclassified' }
CheckBoxArgMorph >> preemptsMouseDown: evt [

	^ true

]
