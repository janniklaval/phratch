Class {
	#name : #TriangleButtonMorph,
	#superclass : #ElementsButtonMorph,
	#category : #'Phratch-UI-Support'
}

{ #category : #'as yet unclassified' }
TriangleButtonMorph >> borderColorDark [
	^owner color twiceDarker
]

{ #category : #'as yet unclassified' }
TriangleButtonMorph >> borderColorLight [
	^owner color twiceLighter lighter
]

{ #category : #'as yet unclassified' }
TriangleButtonMorph >> borderColorVeryDark [
	^owner color twiceDarker darker
]

{ #category : #'as yet unclassified' }
TriangleButtonMorph >> borderColorVeryLight [
	^owner color twiceLighter twiceLighter lighter
]

{ #category : #'as yet unclassified' }
TriangleButtonMorph >> drawOn: aCanvas [
	aCanvas
		line: self topLeft + 1 to: (self topRight + (-1@1)) color: self borderColorVeryLight;
		line: (self topRight + (-1@1)) to: (self center x @ (self bottom - 1)) color: self borderColorVeryDark;
		line: self center x @ (self bottom - 1) to: self topLeft + 1 color: self borderColorLight

]
