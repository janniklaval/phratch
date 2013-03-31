Class {
	#name : #DividedImageFrameMorph,
	#superclass : #ImageFrameMorph,
	#instVars : [
		'topSectionHeight',
		'middleBarForm',
		'leftJointForm',
		'rightJointForm',
		'leftMargin',
		'rightMargin'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #drawing }
DividedImageFrameMorph >> drawDividerOn: aCanvas [
	"Draw my divider edge."

	| w r f slice |
	w := self width - (leftJointForm width + rightJointForm width) - leftMargin - rightMargin.
	r := ((self left + leftJointForm width + leftMargin) @ (self top + topSectionHeight - 4))
		extent: (w @ middleBarForm height).

	f := edgeCache at: 5.
	(f isNil or: [f extent ~= r extent]) ifTrue: [
		f := Form extent: r extent depth: 32.
		slice := middleBarForm copy: (((middleBarForm width // 2) @ 0) extent: (1 @ r height)).
		0 to: r width by: slice width do: [:x | slice displayOn: f at: x@0 rule: Form blend].
		edgeCache at: 5 put: f].

	aCanvas translucentImage: f at: r topLeft.

]

{ #category : #drawing }
DividedImageFrameMorph >> drawFrameOn: aCanvas [

	super drawFrameOn: aCanvas.
	self drawDividerOn: aCanvas.

	"draw middle bar left and right joints"
	aCanvas
		translucentImage: leftJointForm
		at: self topLeft + (leftMargin@(topSectionHeight-4)).
	aCanvas
		translucentImage: rightJointForm
		at: (self right - rightJointForm width - rightMargin) @ (self top + topSectionHeight - 4).

]

{ #category : #intialization }
DividedImageFrameMorph >> initFrontFromForm: aForm topSectionHeight: aNumber [

	| w h |
	super initFrontFromForm: aForm.

	topSectionHeight := aNumber.
	leftMargin := 0.
	rightMargin := 0.
	middleBarForm := ScratchFrameMorph skinAt: #dividedImageFrameBar.

	w := (middleBarForm width // 2) + 2.
	h := middleBarForm height.
	leftJointForm := middleBarForm copy: (0@0 extent: w@h).
	rightJointForm := middleBarForm copy: ((middleBarForm width - w) @ 0 extent: w@h).

]

{ #category : #accessing }
DividedImageFrameMorph >> middleBarLeftMargin: aNumber rightMargin: aNumber2 [

	leftMargin := aNumber.
	rightMargin := aNumber2.
]
