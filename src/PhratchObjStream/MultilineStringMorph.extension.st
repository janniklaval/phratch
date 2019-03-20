Extension { #name : #MultilineStringMorph }

{ #category : #'*PhratchObjStream' }
MultilineStringMorph >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
MultilineStringMorph >> initFieldsFrom: anObjStream version: classVersion [

	| fontSpec isOSFont |
	super initFieldsFrom: anObjStream version: classVersion.

	fontSpec := anObjStream nextField.
	isOSFont := ((fontSpec size > 2) and: [fontSpec at: 3]).
	isOSFont
		ifTrue: [self font: (StrikeFont osFontName: fontSpec first size: fontSpec second)]
		ifFalse: [self font: (StrikeFont fontName: fontSpec first size: fontSpec second)].

	self initFieldsNamed: #(
		textColor
		selectionColor
		lines
	) from: anObjStream.
	lines := lines collect: [:s | s].

]
