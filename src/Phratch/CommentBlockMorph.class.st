Class {
	#name : #CommentBlockMorph,
	#superclass : #BlockMorph,
	#instVars : [
		'labelMorph',
		'showHideMorph',
		'commentMorph',
		'isShowing'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #other }
CommentBlockMorph >> asBlockTuple [

	^ Array
		with: #comment:
		with: commentMorph contents
		with: isShowing

]

{ #category : #other }
CommentBlockMorph >> comment: aStringOrUTF8 [
	"Set the contents of this comment to the given string."

	commentMorph contents: aStringOrUTF8 asString.

]

{ #category : #layout }
CommentBlockMorph >> fixBlockLayout [
	"Update the positions of my submorphs."

	| nextB tabInset xOffset |
	blockLayoutNeeded ifFalse: [^ self].
	super fixBlockLayout.

	tabInset := 10.
	xOffset := tabInset + ((self width - tabInset - labelMorph width) // 2).
	labelMorph position: self position + (xOffset@2).

	commentMorph owner = self
		ifTrue: [
			self extent: commentMorph extent + (10@26).
			showHideMorph position: labelMorph topRight + (4@4).
			commentMorph position: self position + (5@16)]
		ifFalse: [
			self height: 22.
			showHideMorph position: labelMorph topRight + (5@3)].

	(nextB := self nextBlock) ifNotNil: [
		nextB position: self left@(self bottom - 4).
		nextB fixBlockLayout].

]

{ #category : #initialization }
CommentBlockMorph >> initialize [

	super initialize.
	self color: (Color r: 0.670 g: 0.685 b: 0.670).
	isShowing := true.

	labelMorph := (ScratchStringMorph contents: 'comment' localized font: (ScratchFrameMorph getFont: #Label)) color: LabelColor.
	self addMorph: labelMorph.

	commentMorph := MultilineStringMorph new
		growWithText: true;
		borderWidth: 1;
		borderColor: color darker;
		font: (ScratchFrameMorph getFont: #CommentBlock);
		contents: '';
		width: 160;
		color: (Color gray: 0.88).
	self addMorph: commentMorph.

	showHideMorph := ImageMorph new form: (ScratchFrameMorph skinAt: #arrowOpenComment).
	showHideMorph form colors: (Array
		with: Color transparent
		with: (self color mixed: 0.5 with: Color black)).
	self addMorph: showHideMorph.

	self fixBlockLayout.

]

{ #category : #'event handling' }
CommentBlockMorph >> mouseDown: evt [

	| p |
	p := evt cursorPoint.
	((showHideMorph bounds expandBy: 4) containsPoint: p) ifTrue: [^ self toggleShowing].
	(isShowing and: [commentMorph containsPoint: p])
		ifTrue: [^ commentMorph mouseDown: evt].

	super mouseDown: evt.

]

{ #category : #'event handling' }
CommentBlockMorph >> toggleShowing [

	| colors |
	isShowing := isShowing not.
	colors := showHideMorph form colors.
	isShowing
		ifTrue: [
			showHideMorph form: (ScratchFrameMorph skinAt: #arrowOpenComment).
			showHideMorph form colors: colors.
			self addMorph: commentMorph.
			commentMorph startStepping]
		ifFalse: [
			showHideMorph form: (ScratchFrameMorph skinAt: #arrowClosedComment).
			showHideMorph form colors: colors.
			commentMorph delete].

]

{ #category : #'event handling' }
CommentBlockMorph >> wantsKeyboardFocusFor: aSubmorph [
	"Allow editing of my comment."

	^ aSubmorph == commentMorph

]
