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

{ #category : #'*PhratchObjStream' }
MultilineStringMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.

	lines := lines collect: [:s | s].
	anObjStream putField: {font name. font pointSize. font isOSFont}.  "font spec"
	self storeFieldsNamed: #(
		textColor
		selectionColor
		lines
	) on: anObjStream.
	lines := lines collect: [:s | s].


]
