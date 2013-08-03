Class {
	#name : #TriangleButtonMorph,
	#superclass : #ElementsButtonMorph,
	#category : #'Phratch-UI-Support'
}

{ #category : #drawing }
TriangleButtonMorph >> borderColorDark [
	^owner color twiceDarker
]

{ #category : #drawing }
TriangleButtonMorph >> borderColorLight [
	^owner color twiceLighter lighter
]

{ #category : #drawing }
TriangleButtonMorph >> borderColorVeryDark [
	^owner color twiceDarker darker
]

{ #category : #drawing }
TriangleButtonMorph >> borderColorVeryLight [
	^owner color twiceLighter twiceLighter lighter
]

{ #category : #drawing }
TriangleButtonMorph >> drawOn: aCanvas [
	aCanvas
		line: self topLeft + 1 to: (self topRight + (-1@1)) color: self borderColorVeryLight;
		line: (self topRight + (-1@1)) to: (self center x @ (self bottom - 1)) color: self borderColorVeryDark;
		line: self center x @ (self bottom - 1) to: self topLeft + 1 color: self borderColorLight

]
