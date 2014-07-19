Extension { #name : #ScrollingStringMorph }

{ #category : #'*PhratchObjStream' }
ScrollingStringMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
ScrollingStringMorph >> initFieldsFrom: anObjStream version: classVersion [

	| fontSpec showScrollbar |
	super initFieldsFrom: anObjStream version: classVersion.
	fontSpec := anObjStream nextField.
	fontSpec ifNotNil: [
		font := StrikeFont fontName: fontSpec first size: fontSpec second].

	showScrollbar := anObjStream nextField.

	self initFieldsNamed: #(
		firstVisibleLine
		textColor
		selectionColor
		lines
	) from: anObjStream.

	self font: font.
	self showScrollbar: false.
	self showScrollbar: showScrollbar.


]

{ #category : #'*PhratchObjStream' }
ScrollingStringMorph >> showScrollbar: aBoolean [
	"Show or hide my scrollbar."

	aBoolean = (scrollbar owner = self) ifTrue: [^ self].

	aBoolean
		ifTrue: [self addMorph: scrollbar]
		ifFalse: [scrollbar delete].

	self extent: self extent.  "fix layout"

]
